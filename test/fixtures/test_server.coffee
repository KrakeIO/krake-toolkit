express = require 'express'

app = express.createServer()
app.configure ()->
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use(app.router)

app.post '/webhook_url', (req, res)->
  res.send req.body

exports = module.exports = app

if !module.parent
  app.listen 9999