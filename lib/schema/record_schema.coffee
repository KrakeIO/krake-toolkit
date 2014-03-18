Sequelize = require 'sequelize'

recordSchema = 
  properties: 'hstore',
  pingedAt: Sequelize.DATE


module.exports = recordSchema