kson = require 'kson'
Sequelize = require 'sequelize'
Fs = require 'fs'
QueryHelper = require './query_helper'

class RelationalDBHandler

  # @Description: Default constructor
  # @Param: rdbParams:object 
  #     - database: string 
  #     - tableName: string 
  #     - username: string
  #     - password: string
  #     - host: object
  #         - host: string, host's url
  #         - port: string, host's port number
  #     - columns: array, specifying the columns to be extracted
  #     - data: array, additional columns to be extracted  
  constructor:(@rdbParams)->

    @dbHandler = null
    
    @qh = new QueryHelper(@rdbParams)    
    @schemaArray = @qh.getColumns()
    @isIndexArray = @qh.getIndexArray()
    
    @model = {}
    @connected = false
    @recordExists = false
    @init()
  
  
  
  init:()->
    try 
      @dbHandler = new Sequelize @rdbParams.database, @rdbParams.username, @rdbParams.password, @rdbParams.host
      @rdbParams.data && (@schemaArray = @schemaArray.concat Object.keys(@rdbParams.data))

      cbSuccess = () =>
        console.log 'rdb_handler: callback successful'
        @connected = true
        @processQueue()
      
      cbFailure = (error) =>
        console.log "rational db connection failure.\n Error message := "+error
      
      @createTable @rdbParams.tableName, cbSuccess, cbFailure
        
    catch error
      console.log error
      process.exit(1)



  # @Description: publish scraped data to specified destination, if connection was not established yet put the task to the queue
  # @param: dataObject: object, entry returned by scrape engine
  publish: (dataObject)->
    if @connected
      @checkIfRecordExists dataObject
      #@createRecord dataObject
    else
      @task_queue = @task_queue || []
      @task_queue.push dataObject



  # @Description: publishes all the outstanding records queued up while waiting for table to be created in the database
  processQueue: ()->
    if @task_queue?
      while task = @task_queue.pop()
        @checkIfRecordExists task
  
  

  # @Description : checks if this record already exist in the database
  #   creates a new record if it does not exist yet
  #   updates existing record if it does not exist yet
  # @param : record:object
  checkIfRecordExists: (record)->
    
    # If has is_index columns at all
    if @isIndexArray.length > 0
      query = {}    
      query.where = {}
      for x in [0...@isIndexArray.length]
        query.where[@isIndexArray[x]] = record[@isIndexArray[x]]    
    
      @model.find(query).success(
        (model)=>        
          console.log  model
          if model
            console.log "### record exists ###"
            model.updateAttributes(record).success(
              ()->
                console.log "record successfully updated").error(
              ()->
                console.log "error occurs while updating record")
          else
            console.log "### record does not exist ###"  
            @createRecord record 
        ).error(
          (model)->
            console.log "error occurs while finding record")
    
    # since there is no index key indicated, we just do a flat and simple writing operation
    else
      @createRecord record 


  
  # @Description: Create table, if not exists as well as creates the model 
  # @param: tableName: string
  # @param: columnArray: array
  # @param: cbSuccess: function
  # @param: cbFailure: function
  createTable: (tableName, cbSuccess, cbFailure)->

    modelBody = {}
      
    for i in [0...@schemaArray.length]
      modelBody[@schemaArray[i]] = Sequelize.TEXT
    # console.log "\n modelBody := "+kson.stringify modelBody

    @model = @dbHandler.define tableName, modelBody
    @model.sync().success(cbSuccess).error(cbFailure)
    
    
    
  # @Description: Create a record in the destination database
  # @param: recordBody: object
  createRecord:(recordBody)->
    record = @model.build recordBody
    record.save().success(
      ()->
        # console.log "record saved successfully"
    ).error(
      (error)->
        console.log "error occurs while saving record into relational db: %s", error
    )
  
  
  
  # @Description : cleans up the JSON object by removing empty attributes
  # @params : json_obj:Object
  # @return : json_obj:Object  
  cleanJSON : (json_obj)->
    attributes = Object.keys(json_obj)
    for x in [0...attributes.length]
      if json_obj[attributes[x]].trim('').length == 0
        console.log attributes[x]
        delete json_obj[attributes[x]]
      else
        json_obj[attributes[x]] = json_obj[attributes[x]].replace(/'/g,"&rsquo;")
    json_obj
      
      
        
  # @Description: closes a remote relational database connection
  close: ()->
    # This method needs some form of implementation



module.exports = RelationalDBHandler