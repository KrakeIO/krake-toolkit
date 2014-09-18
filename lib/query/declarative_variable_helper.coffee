kson = require 'kson'
# @Description : 
#   converts origin_url objects into strings in task object
#   inserts variables into origin_url 

class DeclarativeVariableHelper

  # @Description : process origin url object and converts it into a String
  # @param : task_option_obj:object
  # @param : prefix:string  
  # @param : callback:function(new_task_option_obj:string)
  # @param : final_callback:function()
  convertOriginUrl : (task_option_obj, prefix, callback, final_callback)->
    prefix = prefix || ''
    switch typeof task_option_obj.origin_url
  
      when "object"
    
        # when is an Array
        if Array.isArray(task_option_obj.origin_url)
          list_of_urls = task_option_obj.origin_url
          for x in [0...list_of_urls.length]
            new_task_option_object = kson.parse(kson.stringify(task_option_obj))
            new_task_option_object.origin_url = list_of_urls[x]
            new_task_option_object.data = new_task_option_object.data || {}
            new_task_option_object.data[ @getVariableName(prefix, 'origin_pattern') ] = new_task_option_object.origin_url
            new_task_option_object.origin_url = @replaceEmbeddedVariableName new_task_option_object.origin_url,
              new_task_option_object.data  
            new_task_option_object.data[ @getVariableName(prefix, 'origin_url') ] = new_task_option_object.origin_url
            callback new_task_option_object
    
        # when is an origin_url_object
        else if task_option_obj.origin_url.origin_value && task_option_obj.origin_url.origin_pattern
          list_of_values = task_option_obj.origin_url.origin_value
          for x in [0...list_of_values.length]
            new_task_option_object = kson.parse(kson.stringify(task_option_obj))
            new_task_option_object.data = new_task_option_object.data || {}
            new_task_option_object.data[ @getVariableName(prefix, 'origin_pattern') ] = new_task_option_object.origin_url.origin_pattern
            new_task_option_object.data[ @getVariableName(prefix, 'origin_value') ] = list_of_values[x]
            new_task_option_object.origin_url = @replaceEmbeddedVariableName task_option_obj.origin_url.origin_pattern,
              new_task_option_object.data
            new_task_option_object.data[  @getVariableName(prefix, 'origin_url') ] = new_task_option_object.origin_url
            
            callback new_task_option_object
          
      when "string"
        new_task_option_object = task_option_obj
        new_task_option_object.data = new_task_option_object.data || {}
        new_task_option_object.data[ @getVariableName(prefix, 'origin_pattern') ] = new_task_option_object.origin_url
        new_task_option_object.origin_url = @replaceEmbeddedVariableName new_task_option_object.origin_url,
          new_task_option_object.data
        new_task_option_object.data[ @getVariableName(prefix, 'origin_url') ] = new_task_option_object.origin_url
                
        callback new_task_option_object  

    final_callback?()

  # @Description : returns the modified variable name given prefix
  # @param : prefix:String
  # @param : variable:String  
  # @return : variable:String
  getVariableName : (prefix, variable)->
  
    prefix = prefix || ''
    if prefix.length > 0
      variable = prefix + '_' + variable
    variable



  # @Description : returns the modified variable name given prefix that is to be detected 
  #   origin_url string variable value insertion dynamically
  # @param : prefix:String
  # @param : variable:String  
  # @return : variable:String  
  getEmbeddedVariableName : (prefix, variable)->
  
    prefix = prefix || ''
    if prefix.length > 0
      variable = prefix + '_' + variable
    embeddedVar = '@@' + variable + '@@'
  
  
  
  # @Description : replaces string_template with all the patter matches in the data object
  # @param : string_template:String
  # @param : data_obj:Object
  # @param : string_result:String
  replaceEmbeddedVariableName : (string_template, data_obj)->
      
    data_keys = Object.keys(data_obj)
    
    for x in [0...data_keys.length]
      originValueRegex = new RegExp @getEmbeddedVariableName( '' , data_keys[x]), "g"
      # string_template = string_template.replace( originValueRegex, encodeURIComponent( data_obj[data_keys[x]] ))      
      string_template = string_template.replace( originValueRegex, data_obj[data_keys[x]] )

    string_template
  
  
module.exports = DeclarativeVariableHelper