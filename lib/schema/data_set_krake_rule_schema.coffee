# @Description schema for initializing the sequalize connector to Krake table
Sequelize = require 'sequelize'
dataSetKrakeRuleSchema = {
  org_col: Sequelize.TEXT
  mod_col: Sequelize.TEXT
}

module.exports = dataSetKrakeRuleSchema