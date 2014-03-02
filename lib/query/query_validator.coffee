# Validates the JSON query objects and identifies raises the errors
try
  async = require 'async'
  kson = require 'kson'
catch error

class QueryValidator

  constructor : ->
    @logs = []

  # @Description : takes in the JSON object and checks for validity
  # @param : schema:string
  validate : (schema, callback)->
    @logs = []
    
    # Is already an object that does not need any further conversion
    if typeof schema == 'object'
      options = schema
    
    # Valid JSON string that needs conversion to actual JSON object
    else
      try
        options = kson.parse(schema)

      # Valid JSON string that is needs to be eval to JSON object instead
      catch e
        try
          schema = 'options = ' + schema
          eval schema
            
        catch f
          @logs.push "Please check your definition for JSON syntax error"
          callback false, @logs

    if options
      validation_outcome = @validate_root_options_obj options
      if validation_outcome
        callback validation_outcome, options
      else
        callback validation_outcome, @logs
  
  
  # @Description : takes in the Option JSON object and checks the presence of attributes
  # @param : options:object
  validate_root_options_obj : (options)->
  
    # console.log 'Validating root option'  
    if !options.origin_url
      @logs.push 'origin_url is missing'
      return false
    return @validate_options_obj options
  
  # @Description : takes in the Option JSON object and checks the presence of attributes
  # @param : options:object
  validate_options_obj : (options)->
  
    if !(options.columns || options.permuted_columns)
      @logs.push 'Both columns or permuted_columns are missing in options object. At least one must exist.'
      return false

    is_valid = true
    if options.columns
      is_valid = is_valid && @validate_columns_array options.columns

    if options.permuted_columns
      is_valid = is_valid && @validate_permuted_columns_obj options.permuted_columns

    is_valid
  
  validate_permuted_columns_obj : (permuted_columns)->
    if !permuted_columns.handles
      @logs.push 'permuted_columns.handles is missing'
      return false

    is_valid = true
    if permuted_columns.handles
      is_valid = is_valid && @validate_columns_array permuted_columns.handles

    if permuted_columns.responses
      is_valid = is_valid && @validate_columns_array permuted_columns.responses      

    is_valid
  
  # @Description : takes in the column array and validates each and every column
  # @param : columns_array:array
  validate_columns_array : (columns_array)->
  
    if !(columns_array instanceof Array)
      @logs.push 'columns_array is not array'
      return false
    
    if columns_array.length == 0
      @logs.push 'columns_array is empty'
      return false

    is_valid = true
    columns_array.forEach (column_obj)=>
      is_valid = is_valid && @validate_column_obj(column_obj)

    is_valid


  # @Description : takes in the column object and validates its attributes
  # @param : column_obj:object
  validate_column_obj : (column_obj)->
    if !column_obj.col_name
      @logs.push 'column_obj.col_name is missing'
      return false
      
    if !(column_obj.dom_query || column_obj.xpath || column_obj.var_query)
      @logs.push column_obj.col_name + ' has neither dom_query, xpath nor var_query. At least one must exist.'
      return false
    
    # Has natural nested options
    if column_obj.options && column_obj.required_attribute && 
    ( column_obj.required_attribute == 'href' || column_obj.required_attribute == 'src' )
      
      return @validate_options_obj column_obj.options
      
    # Has nested options with origin url
    else if column_obj.options && column_obj.options.origin_url
      return @validate_options_obj column_obj.options

    # Is simple column
    else if !column_obj.options
      return true
    
    # Invalid columns
    else
      @logs.push column_obj.col_name + ' has neither options.origin_url, required_attribute == "src" nor  required_attribute == "href". At least one must exist.'
      return false

try
  module.exports = QueryValidator
catch error