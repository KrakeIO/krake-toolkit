# Takes in the JSON query object converts makes available the different attributes via method calls to this class
QueryValidator = require './query_validator'

class QueryHelper

  # Sets up the query helper object
  constructor:(@query_object)->
    @origin_query_obj = @query_object
    @query_object = @extractContent @query_object
    @qv = new QueryValidator()
    
    @is_index_array = []
    @is_url_array = []
    
    @qv.validate @query_object, (@is_valid, @query_object)=>
      if @is_valid
        @domain = @getDomain @query_object
        @columns = []
        # if @query_object.columns
        #   @columns = @columns.concat @getColumnsRecursive @query_object.columns

        # if @query_object.permuted_columns && @query_object.permuted_columns.handles
        #   @columns = @columns.concat @getColumnsRecursive @query_object.permuted_columns.handles

        # if @query_object.permuted_columns && @query_object.permuted_columns.responses
        #   @columns = @columns.concat @getColumnsRecursive @query_object.permuted_columns.responses
        @columns = @getSchemaRecursive @query_object

        @columns.push 'origin_url'
        @columns.push 'origin_pattern'
        if @query_object.origin_url && @query_object.origin_url.origin_value
          @columns.unshift 'origin_value'
      else
        @origin_query_obj = @query_object = {}
        @columns = []

      @columns = @getUniqueColumns @columns

  extractContent: ( query_object )->  
    if typeof query_object == "string"
      query_object

    else if typeof query_object == "object"
      if query_object.template_id? && query_object.template? && query_object.template.content?
        query_object.template.content
      else if query_object.content?
        query_object.content
      else 
        query_object

  getDomain : ( query_object )->
    raw_url = false
    domain = false
    if query_object?.origin_url
      
      if typeof query_object.origin_url is 'string'
        raw_url = query_object.origin_url

      else if query_object.origin_url instanceof Array
        raw_url = query_object.origin_url[0]

      else if typeof query_object.origin_url is 'object' and query_object.origin_url.origin_pattern
        raw_url = query_object.origin_url?.origin_pattern

    if raw_url
      matches = raw_url.match(/^https?\:\/\/([^\/?#]+)(?:[\/?#]|$)/i)
      domain = matches && matches[1]
    domain

  # @Description : returns columns containing urls
  # @return columns:array[string1, string2, string3, ...] || []
  getUrlColumns : ()->
    if @is_url_array
      @is_url_array
    else
      []
  
  # @Description : gets the columns if it was set
  # @return columns:array[string1, string2, string3, ...]
  getColumns : ()->
    if @columns
      @columns
      
    else
      []
  
  # @Description : gets the filtered columns if it has been set
  #   if it has not been set, get the full set of columns
  #   otherwise return false
  # @return columns:array[string1, string2, string3, ...] || false:boolean
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
  # @return : index_array:array[string1, string2, string3, ...]
  getIndexArray : ()->
    @is_index_array
  
  # @Description: obtain an array of all column names given a scrape input json
  # @param: columnArray: array[string1, string2, string3, ...]
  getSchemaRecursive : (query_object)->
    columns = []
    if query_object?.columns
      columns = columns.concat @getColumnsRecursive query_object.columns

    if query_object?.permuted_columns?.handles
      columns = columns.concat @getColumnsRecursive query_object.permuted_columns.handles

    if query_object?.permuted_columns?.responses
      columns = columns.concat @getColumnsRecursive query_object.permuted_columns.responses

    if query_object?.post_data?
      columns = columns.concat @getPostDataColumns query_object.post_data

    if query_object?.data?
      for col_name, col_val of query_object.data
        columns.push(col_name)

    @getUniqueColumns columns

  # @Description: returns all the columns in the post data
  getPostDataColumns: (post_data)->
    post_data = post_data || {}
    columns = []
    if Array.isArray post_data
      post_data.forEach (curr_post_data)=>
        columns = columns.concat Object.keys(curr_post_data)
    else
      columns = Object.keys(post_data)
    columns
  
  # @Description: only unique values in columns
  getUniqueColumns : (raw_columns)->
    raw_columns = raw_columns || []    
    unique_cols = []
    raw_columns.forEach (curr_col)=>
      if curr_col not in unique_cols
        unique_cols.push curr_col
    unique_cols


  # @Description: obtain an array of all column names given a scrape input json
  # @param: columnArray: array[string1, string2, string3, ...]
  getColumnsRecursive : (columnArray)->

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
          schema_array = schema_array.concat @getSchemaRecursive curr_column.options

          # Used for identifying fuzzy urls
          if curr_column.options.origin_url
          
            url_values.push curr_column.col_name + '_origin_pattern'
            url_values.push curr_column.col_name + '_origin_url'
                  
            if curr_column.options.origin_url.origin_value && curr_column.options.origin_url.origin_pattern
              schema_array.push curr_column.col_name + '_origin_value'
                
        # Is asking for url
        else if curr_column.required_attribute && ( curr_column.required_attribute == 'href' || curr_column.required_attribute == 'src' )
          url_values.push curr_column.col_name   

        # Has no nested column
        else

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

  # @Description: Returns an array of column_objects at the root level
  #
  # @return: array[{ col_name_2: "var 1", dom_query: ".col-1" },{ col_nam_2: "var 2", dom_query: ".col-2" }...]
  getRootColumnsQueryObjects : ()->
    cols = []
    if @origin_query_obj.columns
      cols = cols.concat @origin_query_obj.columns

    if @origin_query_obj.permuted_columns?.handles
      cols = cols.concat @origin_query_obj.permuted_columns.handles

    if @origin_query_obj.permuted_columns?.responses
      cols = cols.concat @origin_query_obj.permuted_columns.responses

    cols = cols || []    


  # @Description: Returns an array col_names at the root level that have address as required_attribute
  #   from columns, permuted_columns.handles, permuted_columns.responses
  #
  # @return: array[string1, string2, string3, ...]
  getRootAddressColumns : ()->
    cols = []
    if @origin_query_obj.columns
      cols = cols.concat @origin_query_obj.columns.filter (column)->
        column.required_attribute == 'address'

    if @origin_query_obj.permuted_columns?.handles
      cols = cols.concat @origin_query_obj.permuted_columns.handles.filter (column)->
        column.required_attribute == 'address'

    if @origin_query_obj.permuted_columns?.responses
      cols = cols.concat @origin_query_obj.permuted_columns.responses.filter (column)->
        column.required_attribute == 'address'

    cols = cols || []

  # @Description: Returns an array col_names at the root level that nested columns
  #   from columns, permuted_columns.handles, permuted_columns.responses
  #  
  # @return: array[string1, string2, string3, ...]
  getRootColumnsWithNestedChild : ()->
    cols = []
    if @origin_query_obj.columns
      cols = cols.concat @origin_query_obj.columns.filter (column)->
        column.options?

    if @origin_query_obj.permuted_columns?.handles
      cols = cols.concat @origin_query_obj.permuted_columns.handles.filter (column)->
        column.options?

    if @origin_query_obj.permuted_columns?.responses
      cols = cols.concat @origin_query_obj.permuted_columns.responses.filter (column)->
        column.options?

    cols = cols || []

module.exports = QueryHelper