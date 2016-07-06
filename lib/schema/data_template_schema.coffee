# @Description schema for initializing the sequalize connector to DataTemplate table
Sequelize = require 'sequelize'

dataTemplateSchema = {
  name: Sequelize.TEXT
  content: Sequelize.TEXT
}

module.exports = dataTemplateSchema