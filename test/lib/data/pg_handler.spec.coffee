PGHandler = require "../../../lib/data/pg_handler"

describe "PGHandler", ->
  describe "queries with index", ->
    beforeEach (done)->
      connection_query = require "../../fixtures/json/data/connection_query_with_index"
      connection_query.host.url = process.env['KRAKE_PG_HOST']     || connection_query.host.url
      connection_query.username = process.env['KRAKE_PG_USERNAME'] || connection_query.postgres.username
      connection_query.password = process.env['KRAKE_PG_PASSWORD'] || connection_query.postgres.password

      @new_data = require "../../fixtures/json/data/new_record"
      @updated_data = require "../../fixtures/json/data/updated_record"
      @pg_handler = new PGHandler connection_query, ()=>
        done()

    afterEach (done)->
      @pg_handler.trucateTable ()=>
        done()
    
    it "should have established a connection to the database", ->
      expect(@pg_handler.connected).toEqual true

    it "should have extracted is_index columns", ->
      expect(@pg_handler.is_index_array.length).toEqual 2

    it "should alway check for existing records if query has indexs", (done)->
      spyOn(@pg_handler, "getUpdateStatements").andCallThrough()
      @pg_handler.publish @new_data
      expect(@pg_handler.getUpdateStatements).toHaveBeenCalled()
      done()

    it "should insert a new record without problems", (done)->
      @pg_handler.publish @new_data, ()=>
        @pg_handler.fetchRecords (records)=>
          expect(records.length).toEqual 1
          record = records[0]
          expect(record.index_col1).toEqual "index col1"
          done()

    it "should update an existing a record instead of creating a new one", (done)->
      @pg_handler.publish @new_data, ()=>
        @pg_handler.fetchRecords (records)=>
          expect(records.length).toEqual 1
          record = records[0]
          expect(record.index_col1).toEqual "index col1"     

          @pg_handler.publish @updated_data, ()=>
            @pg_handler.fetchRecords (records)=>
              expect(records.length).toEqual 1
              record = records[0]
              expect(record.norm_col1).toEqual "sumtin wong"
              expect(record.norm_col2).toEqual "bang deng ou"
              done()

    it "should update an existing a record instead of creating a new one", (done)->
      new_data = require "../../fixtures/json/data/new_record_with_url_index"
      updated_data = require "../../fixtures/json/data/updated_record_with_url_index"

      @pg_handler.publish new_data, ()=>
        @pg_handler.fetchRecords (records)=>
          expect(records.length).toEqual 1
          record = records[0]
          expect(record.index_col1).toEqual "http://index1/html?whattodo"
          expect(record.norm_col1).toEqual "normal col1"
          expect(record.norm_col2).toEqual "normal col2"          

          @pg_handler.publish updated_data, ()=>
            @pg_handler.fetchRecords (records)=>
              expect(records.length).toEqual 1
              record = records[0]
              expect(record.index_col1).toEqual "http://index1/html?whattodo"
              expect(record.norm_col1).toEqual "sumtin wong"
              expect(record.norm_col2).toEqual "bang deng ou"
              done()

