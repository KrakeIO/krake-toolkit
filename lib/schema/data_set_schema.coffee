# @Description schema for initializing the sequalize connector to Krake table
Sequelize = require 'sequelize'
dataSetSchema = {
  name: Sequelize.TEXT
  handle: Sequelize.TEXT
}

module.exports = dataSetSchema