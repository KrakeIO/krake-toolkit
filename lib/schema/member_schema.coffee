# @Description schema for initializing the sequalize connector to Member table
Sequelize = require 'sequelize'
memberSchema = {
  id : Sequelize.BIGINT
  quota : Sequelize.INTEGER
  auth_token : Sequelize.TEXT
  package : Sequelize.TEXT
  topup_day : Sequelize.INTEGER
}

module.exports = memberSchema