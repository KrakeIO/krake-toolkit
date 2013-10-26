# @Description : This class specifically handles the transformation of raw text into actual required text using Regex patterns
class DataTransformer
  constructor : (@value, @column_object)->
  
  # @Description : gets the transformed value based on inputs of this current Object
  # @return : result:String
  getValue : ()->
  
    return_value = ''
    switch @column_object.required_attribute
    
      when 'email'
        return_value = @getEmail()
      
      when 'phone'
        return_value = @getPhone()
      
      else
        return_value = @value
    
    if return_value then @transformRegex(return_value)
    else
      return_value
    
  # @Description : transforms free text into 
  transformRegex : (curr_value)->
  
    curr_value = curr_value || @value
    return curr_value if !@column_object.regex_pattern  
    group = @column_object.regex_group || 0
    switch typeof(@column_object.regex_pattern)
      when "string"
        flag    = @column_object.regex_flag || 'ig'
        pattern = new RegExp(@column_object.regex_pattern, flag)
        
      else # assume regex
        # regex_flag is ignored, flags can be included e.g. /Meow/i
        pattern = @column_object.regex_pattern
    
    values = curr_value.match(pattern) || []
    
    # Select only base on number
    if values && typeof group == 'number'
      values[group] && values[group].trim()
      
    # Introduction of wild card *
    else if values && group == '*'
      values = values.filter((curr)->
        curr.trim().length > 0
      ).map (curr)->
        curr.trim()
        
      values.join()
    
    # when nothing was returned
    else 
      ''


  
  # @Description : extracts email address from text. If more than one exist combine using COMMA
  # @param : curr_value:String
  # @return : email_addresses:String||null
  getEmail : (curr_value)->  
    curr_value = curr_value || @value
    email_regex = /[a-zA-Z0-9_.]+@[a-zA-Z0-9_]+?\.[a-zA-Z]{2,3}/ig
    email_array = curr_value.match(email_regex) || []
    email_array = email_array.filter((curr)->
      curr.trim().length > 0
    ).map (curr)->
      curr.trim()

    email_array.join() || ''
    
    
  
  # @Description : extracts phone numbers from text. If more than one exist combine using COMMA
  # @param : curr_value:String
  # @return : phone_numbers:Array[String]||null  
  getPhone : (curr_value)->
    curr_value = curr_value || @value
    curr_value = curr_value.replace(/[\r|\n|\t]/ig, '')
    phone_regex = /[+]{0,1}[0-9\-().\s]{10,16}/ig
    phone_array = curr_value.match(phone_regex) || []
    phone_array = phone_array.filter((curr)->
      curr.trim().length > 0
    ).map (curr)->
      curr.trim()

    phone_array.join() || ''
  
  
  
module.exports = DataTransformer