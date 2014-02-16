# @Description schema for initializing the sequalize connector to Krake table
Sequelize = require 'sequelize'
krakeSchema = {
  member_id: Sequelize.BIGINT
  name: Sequelize.TEXT
  content: Sequelize.TEXT
  frequency: Sequelize.TEXT
  handle: Sequelize.TEXT
  last_ran: Sequelize.DATE
  status: Sequelize.TEXT
  is_private: Sequelize.BOOLEAN
  description: Sequelize.TEXT
  handle: Sequelize.TEXT
  webhook_url: Sequelize.TEXT
  call_limit: Sequelize.INTEGER 
}

module.exports = krakeSchema