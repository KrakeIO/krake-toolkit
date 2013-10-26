kson = require 'kson'
# @Description: handles the writing of data to Postgresql Database using HSTORE

# [IMPORTANT] - the following command must be ran in the shell of the postgres database this script will be used on
#   CREATE EXTENSION hstore;

Sequelize = require 'sequelize'
Fs = require 'fs'
Hstore = require 'pg-hstore' #https://github.com/scarney81/pg-hstore
QueryHelper = require './query_helper'

class PGHandler

  # @Description: Default constructor
  # @Param: rdbParams:object 
  #     - database: string 
  #     - tableName: string 
  #     - username: string
  #     - password: string
  #     - host: object
  #         - url: string, host's url
  #         - port: string, host's port number
  #     - columns: array, specifying the columns to be extracted
  #     - data: array, additional columns to be extracted  
  constructor:(@rdbParams)->
  
    # catch table naming error - table name does not end with 's'
    @rdbParams.tableName[@rdbParams.tableName.length - 1] != 's' && @rdbParams.tableName += 's'
    
    # catch table naming error - table name is not in lowercase
    @rdbParams.tableName = @rdbParams.tableName.toLowerCase()
    
    @qh = new QueryHelper(@rdbParams)
    @schema_array = @qh.getColumns()
    @is_index_array = @qh.getIndexArray()
    
    @dbHandler = null
    @model = {}
    @connected = false
    @init()
  
  init:()->
    try 
      options = {}
      options.host = @rdbParams.host.host
      options.port = @rdbParams.host.port
      options.dialect = 'postgres'
      options.logging = false
      pool = {}
      pool.maxConnections = 5
      pool.maxIdleTime = 30
      options.pool = pool

      @dbHandler = new Sequelize @rdbParams.database, @rdbParams.username, @rdbParams.password, options
      
      # console.log '================ Making connections to ==================='
      # console.log options
      # console.log @rdbParams
      
      @rdbParams.data && (@schema_array = @schema_array.concat Object.keys(@rdbParams.data))

      cbSuccess = () =>
        console.log '[PgHandler] Data Table is ready'      
        @connected = true
        @processQueue()
      
      cbFailure = (error) =>
        console.log "[PgHandler] Relational db connection failure.\n Error message := "+error
      
      @createTable @rdbParams.tableName, cbSuccess, cbFailure
        
    catch error
      console.log "PgHandler: %s" + error
      # process.exit(1)



  # @Description: publish scraped data to specified destination, if connection was not established yet put the task to the queue
  # @param: dataObject: object, entry returned by scrape engine
  publish: (dataObject)->
    if @connected
      # console.log 'pgHandler: line 74'
      @replaceRecord dataObject
    else
      # console.log 'pgHandler: line 78'    
      @task_queue = @task_queue || []
      @task_queue.push dataObject



  # @Description: publishes all the outstanding records queued up while waiting for table to be created in the database
  processQueue: ()->
    if @task_queue?
      while task = @task_queue.pop()
        @replaceRecord task
  

  
  # @Description : gets the where clause part of the string to use for the HStore
  # @param : criteria:Object
  # @return : query_string:String
  getCriteriaString: (criteria)->
    query_string = ""
    is_start_of_criteria = true

    for key, val of criteria
      if is_start_of_criteria
        is_start_of_criteria = false
        query_string = query_string + "properties -> "
      else  
        query_string = query_string + " AND properties -> "

      query_string = query_string + " \'" +  key + "\' = \'"+ val + "\'"
    
    return query_string



  # @Description : gets the proper query string to use for the HStore
  # @param: columns_in_query:string
  getColumnsQuery : ()->
    # properties::hstore-> ARRAY['price', 'title']
    columns_in_query = ""
    for x in [0...@schema_array.length]
      if x < @schema_array.length - 1
        columns_in_query += "'" + @schema_array[x] + "', "
      else
        columns_in_query += "'" + @schema_array[x] + "'" 

    columns_in_query = 'properties::hstore-> ARRAY[' + columns_in_query + ']' + 
      ' as "properties" ' +
      ' ,\"createdAt\", \"updatedAt\", \"pingedAt\" '
    return columns_in_query    



  # @Description : checks if this record already exist in the database
  #   creates a new record if it does not exist yet
  #   updates existing record if it does not exist yet
  # @param : record:object
  replaceRecord: (record)->
  
    record = @cleanJSON record
    if @is_index_array.length > 0
    
      # statement to check if the record exist
      index_criteria = {}
      for x in [0...@is_index_array.length]
        index_criteria[@is_index_array[x]] = record[@is_index_array[x]]
      
      # Checks if record exist
      index_query_string = 'PERFORM true FROM "' + @rdbParams.tableName + 
        '" WHERE (' + @getCriteriaString(index_criteria) + ')'

      # Checks if record has changed
      full_criteria = {}
      for x in [0...@schema_array.length]
        full_criteria[@schema_array[x]] = record[@schema_array[x]]
      change_query_string = 'PERFORM true FROM "' + @rdbParams.tableName + 
        '" WHERE (' + @getCriteriaString(full_criteria) + ')'      


      @getUpdateStatements record, (update_nochange_statement, update_changed_statement, insert_statement)=>
      
        handle = new Date().getTime();        
        master_statement = '
          CREATE FUNCTION  a' + handle + '_replace_into() RETURNS CHAR AS\r\n
          $$\r\n
          BEGIN\r\n

            -- Select to know if the record exist --\r\n
            ' + index_query_string + ';\r\n

            IF found THEN\r\n

              -- Select to know if the existing record has changed --\r\n
              ' + change_query_string + ';\r\n

              IF found THEN  \r\n
                ' + update_nochange_statement + ';\r\n
                RETURN \'NO CHANGES OCCURRED\';\r\n                
              END IF;\r\n

              -- Record has changed --\r\n
              ' + update_changed_statement + ';\r\n
              RETURN \'CHANGE CAPTURED\';  \r\n
            END IF;\r\n

            -- not there, so try to insert the key\r\n
            -- if someone else inserts the same key concurrently,\r\n
            -- we could get a unique-key failure\r\n
            BEGIN\r\n
              ' + insert_statement + ';\r\n
              RETURN \'RECORD CREATED\';\r\n
            EXCEPTION WHEN unique_violation THEN\r\n
                -- Do nothing, and loop to try the UPDATE again.\r\n
            END;\r\n
          END;\r\n
          $$\r\n
          LANGUAGE plpgsql;\r\n

          select a' + handle + '_replace_into(); \r\n
          DROP FUNCTION a' + handle + '_replace_into();\r\n          
        '
      
        
        @dbHandler.query( master_statement ).success(
            (result)=>
              console.log "PgHandler: Record was successfully updated"
          ).error(
            (e)->
              console.log "PgHandler: Error occured saving record\nError: " + e
              console.log "===================================================="
              console.log master_statement
              console.log "===================================================="              
          )

    # since there is no index key indicated, we just do a flat and simple writing operation        
    else
      @createRecord record
  
  
  
  # @Description: Create table, if not exists
  # @param: tableName: string
  # @param: columnArray: array
  # @param: cbSuccess: function
  # @param: cbFailure: function
  createTable: (tableName, cbSuccess, cbFailure)->

    modelBody = {}
    modelBody["properties"] = 'hstore'
    modelBody["pingedAt"]   = 'timestamp'
    modelBody["createdAt"]  = 'timestamp'
    modelBody["updatedAt"]  = 'timestamp'
    # console.log "\n modelBody := "+kson.stringify modelBody

    @model = @dbHandler.define tableName, modelBody
    @model.sync().success(cbSuccess).error(cbFailure)



  # @Description: Create a record in the destination database
  # @param: obj: object to be saved
  createRecord:(obj)->
  
    if obj.pingedAt
      pingedAt = obj.pingedAt
      delete obj.pingedAt
    
    d = new Date()  
    formated_datetime = d.getFullYear() + "-"  +  (d.getMonth() + 1)  + "-" + d.getDate()  +
      " " + d.getHours() + ":"  +  d.getMinutes()  + ":" + d.getSeconds()    
      
    pingedAt = pingedAt || formated_datetime
    
    insert_statement = 'INSERT INTO "' + @rdbParams.tableName + '" ("properties","pingedAt","createdAt","updatedAt") '    
    insert_at_dates = " , '" + pingedAt + "', '" + pingedAt  + "', '" + pingedAt  + "'  "    
      
    Hstore.stringify( obj, (hstore_obj)=> 
      # statement to create new record
      master_statement = insert_statement + " VALUES ( '" + hstore_obj + "' " + insert_at_dates + " )"

      @dbHandler.query( master_statement ).success(
          (result)=>
            console.log "PgHandler: New record was successfully created"
        ).error(
          (e)->
            console.log "PgHandler: Error occured saving record\nError: %s", e
            console.log "===================================================="
            console.log master_statement
            console.log "===================================================="              
        )
    )
    
    
    
  # @Description: Update record
  # @Param: json_obj, the document(with new values) to replace the existing record
  # @Param: , has_update:boolean, indicates if there was an update
  getUpdateStatements:(json_obj, callback)->
    criteria = {}
    for x in [0...@is_index_array.length]
      criteria[@is_index_array[x]] = json_obj[@is_index_array[x]] 

    @updateRecordWithStatement @rdbParams.tableName, 'properties', json_obj, criteria, callback
  
  
  
  # @Description: Construct raw sql query for updating record
  # @Param: table_name, target table name
  # @Param: hstore_col_name, the name of the column where hstore document is saved
  # @Param: json_obj, the document(with new values) to replace the existing record
  # @Param: criteria, the criteria which uniquely identifies a particular record
  # @Param: updatedAt:timestampe||false, the timestamp to use for the updatedAt column
  #
  # Sample update statement
  #
  # UPDATE linkedins
  # SET properties = properties || '"industry" => "test_industry"'::hstore 
  # WHERE (properties-> 'given_name' = 'index_0'
  #  AND properties-> 'family_name' = 'index_1'
  #  AND properties-> 'job_title' = 'index_2'); 
  updateRecordWithStatement: (table_name, hstore_col_name, json_obj, criteria, callback)->
  
    d = new Date()  
    formated_datetime = d.getFullYear() + "-"  +  (d.getMonth() + 1)  + "-" + d.getDate()  +
      " " + d.getHours() + ":"  +  d.getMinutes()  + ":" + d.getSeconds()
      
    if json_obj.pingedAt
      pingedAt = json_obj.pingedAt
      delete json_obj.pingedAt

    pingedAt = pingedAt || formated_datetime
    
    formated_date = d.getFullYear() + "-"  +  (d.getMonth() + 1)  + "-" + d.getDate() 
      
    update_statement = "UPDATE \"" + table_name + "\" SET " + hstore_col_name + " = " + hstore_col_name + " || "
    update_at_query = " , \"updatedAt\" = '" + pingedAt + "'  " 

    insert_statement = 'INSERT INTO "' + table_name + '" ("properties","pingedAt","createdAt","updatedAt") '    
    insert_at_dates = " , '" + pingedAt + "', '" + pingedAt  + "', '" + pingedAt  + "'  "      
    
    Hstore.stringify json_obj, (hstore_obj)=>
      
      # statement to just update PingedAt
      update_nochange_statement = update_statement + "'" + hstore_obj + "'::hstore, " +
        " \"pingedAt\" = '" + pingedAt  + "'  " +
        " WHERE " + @getCriteriaString(criteria)

      # statement to just update all values        
      update_changed_statement = update_statement + "'" + hstore_obj + "'::hstore, " +
        " \"pingedAt\" = '" + pingedAt  + "'  " +
        update_at_query +
        " WHERE " + @getCriteriaString(criteria)

      # statement to create new record
      insert_statement = insert_statement + " VALUES ( '" + hstore_obj + "' " + insert_at_dates + " )"
      
      callback update_nochange_statement, update_changed_statement, insert_statement


  
  # @Description : cleans up the JSON object by removing empty attributes
  # @params : json_obj:Object
  # @return : json_obj:Object  
  cleanJSON : (json_obj)->
  
    attributes = Object.keys(json_obj)
    for x in [0...attributes.length]
      json_obj[attributes[x]] += ''
      if !json_obj[attributes[x]] || json_obj[attributes[x]].trim('').length == 0
        delete json_obj[attributes[x]]
        
      else
        json_obj[attributes[x]] = json_obj[attributes[x]].replace(/'/g,"&rsquo;")
        
    json_obj

  
  
  # @Description: closes a remote relational database connection
  close: ()->
    # This method needs some form of implementation

module.exports = PGHandler