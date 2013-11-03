# Resurrects forever process 0 of whatever EC2 instance the script was called in
exec = require('child_process').exec
request = require 'request'
fs = require 'fs'
kson = require 'kson'

class Phoenix

  # @Description : default constructor
  # @param : authToken:String — authentication token
  # @param : phoenixServer:String
  constructor: (@authToken, @phoenixServer)->
  
  

  # @Description : kick start the resurrection process — crashes this forever process using remote command
  resurrect : ()->
    @getPublicDNS (publicDNS)=>
      publicDNS && @setFire publicDNS
  
  
  
  # @Description : kick start the reincarnation process — IP rotation sequence
  reincarnate : ()->
    console.log '[PHOENIX] Getting AWS instance id'
    @getInstanceId (instanceId)=>
      console.log '[PHOENIX] Obtained AWS instance id' +
        '\n\t\tinstance id : %s', instanceId
      instanceId && @goHeaven instanceId
  
  
  
  # @Description : gets the public DNS of the current instance 
  #   1st priority checks if KRAKE_STATIC_IP has been set in the ~/.bashrc file
  #   2nd priority assumes it is an EC2 instance, gets the public DNS by calling AWS service
  # @param : callback:function(publicDNS:string)
  getPublicDNS : (callback)->

    if process.env['KRAKE_STATIC_IP']
      callback process.env['KRAKE_STATIC_IP']
      
    else
      command = 'wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname'
      exec command, (err, stdout, stderr)=>
        if err
          console.log '[Phoenix] ERROR, %s', err
        else
          callback stdout



  # @Description : gets the instanceId of the current instance 
  #   assumes it is an EC2 instance, gets the instanceId by calling AWS service
  # @param : callback:function(instanceId:string)
  getInstanceId : (callback)->
  
    command = 'wget -q -O - http://169.254.169.254/latest/meta-data/instance-id'
    console.log '[PHOENIX] executing command ' + 
      '\n\t\t%s', command
    exec command, (err, stdout, stderr)=>
      if err
        console.log '[Phoenix] ERROR, %s', err
      else
        callback stdout



  # @Description : calls supervisor.krake.io to request for restart of process
  setFire : (publicDNS)->
    console.log '[Phoenix] lighting the bonfire'
    @getUID (uid)=>
      if uid      
        request @phoenixServer + '/resurrect/' + publicDNS + '/' + uid, (error, response, body)=>
          if !error && response.statusCode == 200
            console.log body




  # @Description : calls supervisor.krake.io to request for rotation of IP addresses
  # @param : instanceId:String
  goHeaven : (instanceId)->
    console.log '[Phoenix] sending to the after life'
    request @phoenixServer + '/reincarnate/' + @authToken + '/' + instanceId, (error, response, body)=>
      if !error && response.statusCode == 200
        console.log body  
  


  # @Description : derive uid of this current process given process id
  # @param : callback:function(forever_uid:string)  
  getUID : (callback)->
    console.log '[Phoenix] getting UID'
    command = "forever list | grep " + process.pid + " | awk '{print $3}'"
    exec command, (err, stdout, stderr)=>
      if err
        console.log '[Phoenix] ERROR, %s', err
      else if stdout
        console.log '[Phoenix] Current process uid : %s', stdout
        callback && callback stdout
      else
        console.log '[Phoenix] Current process has no forever uid'        



module.exports = Phoenix

if !module.parent

  # Configuration setup
  global.CONFIG = null
  global.ENV = (process.env['NODE_ENV'] || 'development').toLowerCase()

  try 
    CONFIG = kson.parse(fs.readFileSync(__dirname + '/../config/config.js').toString())[ENV];
  catch error
    console.log('cannot parse config.js')
    process.exit(1)

  p = new Phoenix 'DEMO', CONFIG.phoenixServer
  p.setFire 'Earth'
  setTimeout ()=>
    console.log 'DONE'
  , 10000