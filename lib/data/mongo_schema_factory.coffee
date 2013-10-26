mongoose = require 'mongoose'
Schema = mongoose.Schema
fs = require 'fs'

class MongoSchemaFactory
  
  # @Description: default constructor
  # @params: options:object
  #   - host:string
  #   - database:string
  #   - columns: array, specifying the columns to be extracted
  #   - collection:string
  #   - data: array, additional columns to be extracted  
  constructor : (@options)->

    @connection = mongoose.createConnection 'mongodb://' + @options.host + '/' + @options.database  
    # full column set, top level    
    @attribute_array = []    
    # columns that have multiple entries. For instance, job title and company
    @array_array = []
    # columns that form composite key which uniquely identifies record
    @index_array = []
    @setArrays @options.columns    
    @options.data && (@attribute_array = @attribute_array.concat Object.keys(@options.data))
    @setMongooseModel()    

  # @Description: publish scraped data to specified mongodb
  # @param: data:Object, entry returned by scrape engine
  publish : (data)->
    Model = @Model
    filter = {}
    for x in [0...@index_array.length]
      data[@index_array[x]] && filter[@index_array[x]] = data[@index_array[x]]
        
    (Object.keys(filter).length > 0) && Model.findOne filter, (error, record)=>
      if error 
        console.log 'error occured while finding document to mongodb'      
      else if record
        @update record, data
      else
        @create data
      
    !(Object.keys(filter).length > 0) && @create(data)

  # @Description: creates a new record in specified mongodb
  # @param: record:Object, record returned by mongodb
  # @param: data:Object, entry returned by scrape engine
  update : (record, data)->

    for x in [0... @attribute_array.length]
    
      if(@attribute_array[x] in @array_array) # add in array if it does not exist yet
        !(data[@attribute_array[x]] in record[@attribute_array[x]]) && record[@attribute_array[x]].push(data[@attribute_array[x]])
        
      else # straight forward replace
        data[@attribute_array[x]] && record[@attribute_array[x]] = data[@attribute_array[x]]
      
    record.save (error)->
      if error
        console.log 'error occured while updating document to mongodb'
      else
        # console.log 'data updated with no issue'
  
  # @Description: creates a new record in specified mongodb
  # @param: data:Object, entry returned by scrape engine
  create : (data)->
    Model = @Model
    record = new Model data
    record.save (error)->
      if error
        console.log "error occured while saving document to mongodb"
      else
        # console.log 'data saved with no issue'  
  
  # @Description: creates a schema model that is to be used directly by the Mongoose library
  # @return: model:Object
  setMongooseModel : ()->
 
    literal = {}
    for i in [0...@attribute_array.length]      
      (@attribute_array[i] in @array_array) && curr_attr_obj = [String]
      !(@attribute_array[i] in @array_array) && curr_attr_obj = {type : String}
      literal[@attribute_array[i]] = curr_attr_obj
    schema = new Schema(literal)
    @Model = @connection.model @options.collection, schema

  # @Description: gets all the column names in the defined schema in the form of a single dimension array
  # @param: columnArray: array, specifying the columns to be extracted
  # @return: schema_array:array[String]
  #   - col_name_1, col_name_2, col_name_3, col_name_4...
  setArrays : (columnArray)->
  
    if columnArray 
      for x in [0...columnArray.length] 
        curr_column = columnArray[x]
        
        @attribute_array.push curr_column.col_name
        curr_column.is_index && @index_array.push curr_column.col_name
        curr_column.is_array && @array_array.push curr_column.col_name  

        # Has nested column
        curr_column.options && @setArrays(curr_column.options.columns)        

        # when there is a fuzzy url
        curr_column.options && curr_column.options.fuzzy_url && @attribute_array.push(curr_column.col_name + '_fuzzyurl')

        #Handles additional fields when the required field is an address
        if curr_column.required_attribute == 'address'
          country_key = curr_column.country || curr_column.col_name + '_country' 
          @attribute_array.push country_key
        
          zip_key = curr_column.zipcode || curr_column.col_name + '_zip'          
          @attribute_array.push zip_key
                  
          lat_key = curr_column.latitude || curr_column.col_name + '_lat'
          @attribute_array.push lat_key
                  
          lng_key = curr_column.longitude || curr_column.col_name + '_lng'
          @attribute_array.push lng_key


  # @Description: closes the remote mongodb connection
  close : ()->
    @connection.close()

module.exports = MongoSchemaFactory