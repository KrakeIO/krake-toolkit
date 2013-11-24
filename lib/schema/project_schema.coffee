# @Description schema for initializing the sequalize connector to Project table
Sequelize = require 'sequelize'
projectSchema = {
  id: Sequelize.BIGINT
  quota: Sequelize.INTEGER
}

module.exports = projectSchema