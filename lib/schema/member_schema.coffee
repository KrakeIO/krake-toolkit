# @Description schema for initializing the sequalize connector to Member table
Sequelize = require 'sequelize'
memberSchema = {
  id : Sequelize.BIGINT
  quota : Sequelize.INTEGER
  auth_token : Sequelize.TEXT
}

module.exports = memberSchema