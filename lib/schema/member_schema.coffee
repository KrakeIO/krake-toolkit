# @Description schema for initializing the sequalize connector to Member table
Sequelize = require 'sequelize'
memberSchema = {
  quota : Sequelize.INTEGER
  auth_token : Sequelize.TEXT
  package : Sequelize.TEXT
  topup_day : Sequelize.INTEGER
  phone : Sequelize.TEXT
  introduction : Sequelize.TEXT
  email : Sequelize.TEXT
  name : Sequelize.TEXT
}

module.exports = memberSchema