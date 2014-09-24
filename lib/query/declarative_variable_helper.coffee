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

    compiled_objs_final = []
    compiled_obj_urls   = @getCompiledForURLs task_option_obj, prefix

    # Sub compiles to more url objects if the post_data is an array instead of an object
    compiled_obj_urls.forEach (compiled_obj_url)=>
      curr_compiled_finals = @getCompiledForPostData compiled_obj_url

      curr_compiled_finals.forEach (curr_compiled_final)=>
        compiled_objs_final.push curr_compiled_final

    # Makes callback for each compiled_obj_final
    compiled_objs_final.forEach (compiled_obj)=>
      callback? compiled_obj

    final_callback? compiled_objs_final

  getCompiledForPostData: (task_option_obj)->
    compiled_objs = []
    if !task_option_obj.post_data
      compiled_objs.push task_option_obj
    else
      if Array.isArray task_option_obj.post_data
        task_option_obj.post_data.forEach (post_data)=>
          new_task_option_object = kson.parse(kson.stringify(task_option_obj))
          new_task_option_object.data = @mergePostDataToData post_data, new_task_option_object.data
          new_task_option_object.post_data = post_data
          compiled_objs.push new_task_option_object

      else
        task_option_obj.data = @mergePostDataToData task_option_obj.post_data, task_option_obj.data, 
        compiled_objs.push task_option_obj

    compiled_objs

  mergePostDataToData: (post_data_obj, data)->
    post_data_obj = post_data_obj || {}
    data          = data || {}
    Object.keys(post_data_obj).forEach (attr)->
      data[attr] = post_data_obj[attr]
    data

  getCompiledForURLs: (task_option_obj, prefix)->
    compiled_objs = []    
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
            compiled_objs.push new_task_option_object
    
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
            
            compiled_objs.push new_task_option_object
          
      when "string"
        new_task_option_object = task_option_obj
        new_task_option_object.data = new_task_option_object.data || {}
        new_task_option_object.data[ @getVariableName(prefix, 'origin_pattern') ] = new_task_option_object.origin_url
        new_task_option_object.origin_url = @replaceEmbeddedVariableName new_task_option_object.origin_url,
          new_task_option_object.data
        new_task_option_object.data[ @getVariableName(prefix, 'origin_url') ] = new_task_option_object.origin_url
                
        compiled_objs.push new_task_option_object    

    compiled_objs

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