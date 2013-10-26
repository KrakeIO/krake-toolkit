# Dependencies
request = require 'request'

# @Description : scripts will use this client class as an interface to interface with the usage server
class CallLimitHelper

  constructor : (@usage_server)->
  
  setCallLimit : (krake_handle, auth_token, call_limit, callback)->
    url = @usage_server + '/set-call-limit/' + auth_token + '/' + krake_handle + '/' + call_limit
    request url, (error, response, body)->
      console.log '[CALL_LIMIT_HELPER] : Call limit has been set for %s', krake_handle
      callback && callback()


  
  unsetCalLimit : (krake_handle, auth_token, callback)->
    url = @usage_server + '/unset-call-limit/' + auth_token + '/' + krake_handle
    request url, (error, response, body)->
      console.log '[CALL_LIMIT_HELPER] : Call limit has been unset for %s', krake_handle
      callback && callback()      

module.exports = CallLimitHelper
