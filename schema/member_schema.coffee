# @Description schema for initializing the sequalize connector to Member table
Sequelize = require 'sequelize'
memberSchema = {
  id : Sequelize.BIGINT
  quota : Sequelize.INTEGER
}

module.exports = memberSchema