kson = require 'kson'
# Validates the JSON query objects and identifies raises the errors
async = require 'async'

class QueryValidator

  # @Description : takes in the JSON object and checks for validity
  # @param : schema:string
  # @param : callback:function(validation:boolean, value:string||object)
  validate : (schema, callback)->
    
    # Is already an object that does not need and further conversion
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
          callback false

    if options
      @validate_root_options_obj options, (is_valid, err_msg )=>
        if is_valid
          callback is_valid, options
        else
          callback is_valid, err_msg
  
  
  # @Description : takes in the Option JSON object and checks the presence of attributes
  # @param : options:object
  # @param : callback:function(validation:boolean)
  validate_root_options_obj : (options, callback)->
  
    # console.log 'Validating root option'  
    if !options.origin_url
      return callback(false, 'origin_url is missing')
            
    if !options.columns
      return callback(false, 'columns array is missing')
    
    @validate_columns_array options.columns, callback
  
  # @Description : takes in the Option JSON object and checks the presence of attributes
  # @param : options:object
  # @param : callback : function(validation:boolean)
  validate_options_obj : (options, callback)->
  
    if !options.columns
      return callback(false, 'columns array is missing')

    @validate_columns_array options.columns, callback
  
  # @Description : takes in the column array and validates each and every column
  # @param : columns_array:array
  # @param : callback : function(validation:boolean)  
  validate_columns_array : (columns_array, callback)->
  
    if !(columns_array instanceof Array)
      return callback(false, 'columns_array is not Array')
    
    if columns_array.length == 0
      return callback(false, 'columns_array is empty')
    
    error_msg = false
    
    # iterates through each column
    async.every columns_array, (column_obj, next)=>
      @validate_column_obj column_obj, (result, error)=>
      
        if error && !error_msg
          error_msg = error        
        else if error && error_msg
          error_msg += ',' + error
          
        next result
                  
    , (result)=>
      callback result, error_msg

  # @Description : takes in the column object and validates its attributes
  # @param : column_obj:object
  # @param : callback : function(validation:boolean)  
  validate_column_obj : (column_obj, callback)->
  
    if !column_obj.col_name
      return callback(false, 'a column has no col_name')
      
    if !(column_obj.dom_query || column_obj.xpath)
      return callback(false, 'column[' + column_obj.col_name + '] has neither dom_query nor xpath')
    
    # Has natural nested options
    if column_obj.options && column_obj.required_attribute && ( column_obj.required_attribute == 'href' || column_obj.required_attribute == 'src' )
      @validate_options_obj column_obj.options, callback
      
    # Has nested options with origin url
    else if column_obj.options && column_obj.options.origin_url
      @validate_options_obj column_obj.options, callback

    # Is simple column
    else if !column_obj.options
      callback true
    
    # Invalid columns
    else
      err_msg = 'column[' + column_obj.col_name + '] is invalid. ' + 
        'Make sure you declared either fuzzy_url : "...PATTERN.."  in the nested options object or ' + 
        ' required_attribute : "href" '
        
      callback false, err_msg
  
module.exports = QueryValidator