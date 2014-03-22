Sequelize = require 'sequelize'

recordSetSchema = 
  properties:         'hstore'
  datasource_handle:  Sequelize.TEXT
  pingedAt:           Sequelize.DATE


module.exports = recordSetSchema