# @Description schema for initializing the sequalize connector to Krake table
Sequelize = require 'sequelize'
krakeSchema = {
  name: Sequelize.TEXT
  content: Sequelize.TEXT
  frequency: Sequelize.TEXT
  is_private: Sequelize.BOOLEAN
  description: Sequelize.TEXT
  handle: Sequelize.TEXT
  status: Sequelize.TEXT  
  last_ran: Sequelize.DATE  
  webhook_url: Sequelize.TEXT
  call_limit: Sequelize.INTEGER 
  latest_count: Sequelize.INTEGER
  crawl_source_option: Sequelize.INTEGER
  manual_crawl_sources: Sequelize.TEXT
  template_id: Sequelize.INTEGER
  definition_type: Sequelize.INTEGER
}

module.exports = krakeSchema