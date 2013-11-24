# @Description schema for initializing the sequalize connector to Krake table
Sequelize = require 'sequelize'
krakeSchema = {
  id: Sequelize.BIGINT
  name: Sequelize.TEXT
  content: Sequelize.TEXT
  frequency: Sequelize.TEXT
  handle: Sequelize.TEXT
  last_ran: Sequelize.DATE
  status: Sequelize.TEXT
}

module.exports = krakeSchema