# @Description schema for initializing the sequalize connector to Usage table
Sequelize = require 'sequelize'
usageSchema = {
  page_url : Sequelize.TEXT
  krake_id : Sequelize.INTEGER
}

module.exports = usageSchema