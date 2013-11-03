KrakeToolKit = {}
KrakeToolKit.query = {}
KrakeToolKit.query.validator = require "./lib/query/query_validator"
KrakeToolKit.query.declarative_var = require "./lib/query/declarative_variable_helper"
KrakeToolKit.query.helper = require "./lib/query/query_helper"

KrakeToolKit.usage = {}
KrakeToolKit.usage.phoenix = require './lib/usage/phoenix'

KrakeToolKit.schema = {}
KrakeToolKit.schema.krake = require './schema/krake_schema'

module.exports = KrakeToolKit