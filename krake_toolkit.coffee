KrakeToolKit = {}

KrakeToolKit.data = {}
KrakeToolKit.data.mongo_schema_factory = require "./lib/data/mongo_schema_factory"
KrakeToolKit.data.pg_handler = require "./lib/data/pg_handler"
KrakeToolKit.data.rdb_handler = require "./lib/data/rdb_handler"

KrakeToolKit.network = {}
KrakeToolKit.network.queue = require "./lib/network/queue_interface"

KrakeToolKit.query = {}
KrakeToolKit.query.data_transformer = require "./lib/query/data_transformer"
KrakeToolKit.query.declarative_var = require "./lib/query/declarative_variable_helper"
KrakeToolKit.query.helper = require "./lib/query/query_helper"
KrakeToolKit.query.validator = require "./lib/query/query_validator"

KrakeToolKit.usage = {}
KrakeToolKit.usage.phoenix = require './lib/usage/phoenix'
KrakeToolKit.usage.call_limit_helper = require './lib/usage/call_limit_helper'
KrakeToolKit.usage.webhook_helper = require './lib/usage/webhook_helper'

KrakeToolKit.schema = {}
KrakeToolKit.schema.krake = require './schema/krake_schema'

module.exports = KrakeToolKit