KrakeToolKit = {}

KrakeToolKit.query = {}
KrakeToolKit.query.data_transformer     = require "./lib/query/data_transformer"
KrakeToolKit.query.declarative_var      = require "./lib/query/declarative_variable_helper"
KrakeToolKit.query.helper               = require "./lib/query/query_helper"
KrakeToolKit.query.validator            = require "./lib/query/query_validator"

KrakeToolKit.usage = {}
KrakeToolKit.usage.phoenix              = require './lib/usage/phoenix'
KrakeToolKit.usage.call_limit_helper    = require './lib/usage/call_limit_helper'
KrakeToolKit.usage.webhook_helper       = require './lib/usage/webhook_helper'

KrakeToolKit.schema = {}
KrakeToolKit.schema.config              = require './lib/schema/schema_config'
KrakeToolKit.schema.krake               = require './lib/schema/krake_schema'
KrakeToolKit.schema.member              = require './lib/schema/member_schema'
KrakeToolKit.schema.usage               = require './lib/schema/usage_schema'
KrakeToolKit.schema.data_set            = require './lib/schema/data_set_schema'
KrakeToolKit.schema.data_template       = require './lib/schema/data_template_schema'
KrakeToolKit.schema.data_set_krake      = require './lib/schema/data_set_krake_schema'
KrakeToolKit.schema.data_set_krake_rule = require './lib/schema/data_set_krake_rule_schema'
KrakeToolKit.schema.record              = require './lib/schema/record_schema'
KrakeToolKit.schema.record_set          = require './lib/schema/record_set_schema'

module.exports  = KrakeToolKit