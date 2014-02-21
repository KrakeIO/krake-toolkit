# Takes in the JSON query object converts makes available the different attributes via method calls to this class
QueryValidator = require './query_validator'

class QueryHelper

  # Sets up the query helper object
  constructor:(@query_object)->
    @origin_query_obj = @query_object
    @qv = new QueryValidator()
    
    @is_index_array = []
    @is_url_array = []
    
    @qv.validate @query_object, (@is_valid, @query_object)=>
      if @is_valid
        @columns = @getSchemaRecursive @query_object.columns
        @columns.push 'origin_url'
        @columns.push 'origin_pattern'
        if @query_object.origin_url && @query_object.origin_url.origin_value
          @columns.unshift 'origin_value'
      else
        @origin_query_obj = @query_object = {}
        @columns = []
  
  # @Description : returns columns containing urls
  # @return columns:array || []
  getUrlColumns : ()->
    if @is_url_array
      @is_url_array
    else
      []
  
  
  
  # @Description : gets the columns if it was set
  # @return columns:array
  getColumns : ()->
    if @columns
      @columns
      
    else
      []
  
  
  
  # @Description : gets the filtered columns if it has been set
  #   if it has not been set, get the full set of columns
  #   otherwise return false
  # @return columns:array || false:boolean
  getFilteredColumns : ()->
    if @query_object.column_filter
      @query_object.column_filter
    else if !@query_object.column_filter
      @columns
    else
      false
    
    
  
  # @Description : checks if column name already exist as an index key before adding it
  # @param : column_name:string
  addToIndexArray : (column_name)->
    if @is_index_array.indexOf(column_name) == -1
      @is_index_array.push column_name  
  
  
  
  # @Description : gets array column names that are indexes
  # @return : index_array:array  
  getIndexArray : ()->
    @is_index_array
  
  
  
  # @Description: obtain an array of all column names given a scrape input json
  # @param: columnArray: array
  getSchemaRecursive : (columnArray)->

    schema_array = []
    url_values = []  
    counter = 1

    if columnArray 
      for x in [0...columnArray.length] 
        curr_column = columnArray[x]
        
        #Used for identifying unique record
        if curr_column.is_index #has is_index attribute
          @addToIndexArray curr_column.col_name        
        
        # when there is a fuzzy url
        if curr_column.options # Has nested column
          url_values.push curr_column.col_name
          schema_array = schema_array.concat @getSchemaRecursive curr_column.options.columns

          # Used for identifying fuzzy urls
          if curr_column.options.origin_url
          
            url_values.push curr_column.col_name + '_origin_pattern'
            url_values.push curr_column.col_name + '_origin_url'    
                  
            if curr_column.options.origin_url.origin_value && curr_column.options.origin_url.origin_pattern
              schema_array.push curr_column.col_name + '_origin_value'
                
        # Is asking for url
        else if curr_column.required_attribute && curr_column.required_attribute == 'href' || curr_column.required_attribute == 'src'  
          url_values.push curr_column.col_name   

        # Has no nested column
        else if curr_column.col_name  

          schema_array.push curr_column.col_name

          #Handles additional fields when the required field is an address
          if curr_column.required_attribute == 'address'
            country_key = curr_column.country || curr_column.col_name + '_country' 
            schema_array.push country_key

            zip_key = curr_column.zipcode || curr_column.col_name + '_zip'          
            schema_array.push zip_key

            lat_key = curr_column.latitude || curr_column.col_name + '_lat'
            schema_array.push lat_key

            lng_key = curr_column.longitude || curr_column.col_name + '_lng'
            schema_array.push lng_key

      schema_array = schema_array.concat(url_values)
      @is_url_array = @is_url_array.concat(url_values)

    return schema_array

  getRootAddressColumns : ()->
    cols = @origin_query_obj.columns?.filter (column)->
      column.required_attribute == 'address'
    cols = cols || []

  getRootColumnsWithNestedChild : ()->
    cols = @origin_query_obj.columns?.filter (column)->
      column.options? && ( ( column.options.origin_url && column.options.columns ) || column.required_attribute == 'href' )
    cols = cols || []

module.exports = QueryHelper