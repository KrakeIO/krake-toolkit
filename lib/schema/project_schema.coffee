# @Description schema for initializing the sequalize connector to Project table
Sequelize = require 'sequelize'
projectSchema = {
  quota: Sequelize.INTEGER
}

module.exports = projectSchema