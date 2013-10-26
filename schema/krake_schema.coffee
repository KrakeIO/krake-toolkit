# @Description schema for initializing the sequalize connector to Krake table
Sequelize = require 'sequelize'
krakeSchema = {
  id: Sequelize.BIGINT
  content: Sequelize.TEXT
  handle: Sequelize.TEXT
  status: Sequelize.TEXT
  last_ran: Sequelize.DATE
  project_id : Sequelize.INTEGER    
}

module.exports = krakeSchema