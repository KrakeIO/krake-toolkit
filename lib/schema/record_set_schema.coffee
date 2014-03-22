Sequelize = require 'sequelize'

recordSetSchema = 
  properties:         'hstore'
  datasource_handle:  Sequelize.INTEGER
  pingedAt:           Sequelize.DATE


module.exports = recordSetSchema