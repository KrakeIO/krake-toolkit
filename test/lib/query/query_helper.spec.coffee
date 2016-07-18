valid_query = require '../../fixtures/json/query/valid'
filtered_query = require '../../fixtures/json/query/filtered'
invalid_query = require '../../fixtures/json/query/invalid'
permuted_query = require '../../fixtures/json/query/valid_permuted'
permuted_nested_query = require '../../fixtures/json/query/valid_permuted_nested'
krake_model_test_variants = require '../../fixtures/json/query/krake_model_variants'
ktk = require '../../../krake_toolkit'

describe "Testing Query Helper", ->

  it "should have QueryHelper defined", ->
    expect(ktk.query.helper).toBeDefined()  

  it "should set query_object to {} when valid_query is empty", ->
    qh = new ktk.query.helper ""
    expect(qh.query_object).nil?.toBe false

  describe "extractContent", ->
    it "returns all columns when given simple JSON string", ->
      qh = new ktk.query.helper krake_model_test_variants.stringified_content
      columns = qh.getColumns()
      expect(columns.length).toEqual 4
      expect(columns.indexOf("some string col") >= 0).toEqual true
      expect(columns.indexOf("some other string col") >= 0).toEqual true

    it "returns all columns when given simple Krake Model", ->
      qh = new ktk.query.helper krake_model_test_variants.simple_krake_model
      columns = qh.getColumns()
      expect(columns.length).toEqual 4
      expect(columns.indexOf("some simple col") >= 0).toEqual true
      expect(columns.indexOf("some other simple col") >= 0).toEqual true

    it "returns all columns when given Krake Model associated Template Model", ->
      qh = new ktk.query.helper krake_model_test_variants.krake_model_with_template
      columns = qh.getColumns()
      expect(columns.length).toEqual 4
      expect(columns.indexOf("some template col") >= 0).toEqual true
      expect(columns.indexOf("some other template col") >= 0).toEqual true

    it "returns all columns when given Krake Model ill-associated Template Model", ->
      qh = new ktk.query.helper krake_model_test_variants.krake_model_with_bad_template
      columns = qh.getColumns()
      expect(columns.length).toEqual 4
      expect(columns.indexOf("some reverted krake col") >= 0).toEqual true
      expect(columns.indexOf("some other reverted krake col") >= 0).toEqual true
    
  describe "translating provided content", ->
    
    it "should return all columns that are unique", ->
      qh = new ktk.query.helper valid_query
      expect(qh.getColumns().length).toEqual 20

    it "should return all permuted_columns in query", ->
      qh = new ktk.query.helper permuted_query
      expect(qh.getColumns().length).toEqual 9

    it "should return all permuted_columns in 3 level nested query", ->
      permuted_nested_query_l3 = require '../../fixtures/json/query/valid_permuted_nested_3_lvl_1'
      qh = new ktk.query.helper permuted_nested_query_l3
      expect(qh.getColumns().length).toEqual 6

    it "should return all permuted_columns in 3 level nested query", ->
      permuted_nested_query_l3 = require '../../fixtures/json/query/valid_permuted_nested_3_lvl_2'
      qh = new ktk.query.helper permuted_nested_query_l3
      expect(qh.getColumns().length).toEqual 7

    it "should return all url columns", ->
      qh = new ktk.query.helper valid_query
      expect(qh.getUrlColumns().length).toEqual 5
      
    it "should return all filtered columns", ->
      qh = new ktk.query.helper filtered_query
      expect(qh.getFilteredColumns().length).toEqual 2
      expect(qh.getFilteredColumns()[0]).toBe 'product_name'
      expect(qh.getFilteredColumns()[1]).toBe 'detailed_page'    
      
    it "should return all indexed columns", ->
      qh = new ktk.query.helper valid_query
      expect(qh.getFilteredColumns()[0]).toBe 'product_name'
    
    it "should return an empty array when the schema is invalid", ->
      qh = new ktk.query.helper "{"
      expect(qh.getIndexArray().length).toEqual 0

    it "should return data in getColumns", ->
      query = 
        origin_url: "some url"
        columns: [{
          col_name: "col name"
          dom_query: ".css"
        }]
        data:
          val1: "value"
      qh = new ktk.query.helper query
      expect(qh.getColumns().indexOf('val1') > -1 ).toBe true

    it "should return nested data in getColumns", ->
      query = 
        origin_url: "some url"
        columns: [{
          col_name: "col name"
          dom_query: ".css"
          required_attribute: "href"
          options:
            columns: [{
              col_name: "col name2"
              dom_query: ".css2"
            }]
            data:
              val1: "value"
        }]
      qh = new ktk.query.helper query
      expect(qh.getColumns().indexOf('val1') > -1 ).toBe true

    it "should return not have duplicated data col in getColumns", ->
      query = 
        origin_url: "some url"
        columns: [{
          col_name: "col1"
          dom_query: ".css"
        }]
        data:
          col1: "value"
      qh = new ktk.query.helper query
      expect(qh.getColumns().indexOf('col1') > -1 ).toBe true    
      expect(qh.getColumns().length).toEqual 3    

    it "should return nested data col in getColumns", ->
      query = 
        origin_url: "some url"
        columns: [{
          col_name: "col name"
          dom_query: ".css"
          required_attribute: "href"
          options:
            columns: [{
              col_name: "col2"
              dom_query: ".css2"
            }]
            data:
              col2: "value"
        }]
      qh = new ktk.query.helper query
      expect(qh.getColumns().indexOf('col2') > -1 ).toBe true
      expect(qh.getColumns().length).toEqual 4

    it "should not return duplicated nested data col in getColumns", ->
      query = 
        origin_url: "some url"
        columns: [{
          col_name: "col name"
          dom_query: ".css"
          required_attribute: "href"
          options:
            columns: [{
              col_name: "col2"
              dom_query: ".css2"
            }]
            data:
              col2: "value"
        }]
        data:
          col2: "value"

      qh = new ktk.query.helper query
      expect(qh.getColumns().indexOf('col2') > -1 ).toBe true
      expect(qh.getColumns().length).toEqual 4

    it "should not return duplicated deeply nested data col in getColumns", ->
      query = 
        origin_url: "some url"
        columns: [{
          col_name: "col name"
          dom_query: ".css"
          required_attribute: "href"
          options:
            columns: [{
              col_name: "col2"
              dom_query: ".css2"
            }]
            data:
              col2: "value"
        },{
          col_name: "col2"
          dom_query: ".css"
        }]
        data:
          col2: "value"
                
      qh = new ktk.query.helper query
      expect(qh.getColumns().indexOf('col2') > -1 ).toBe true
      expect(qh.getColumns().length).toEqual 4

    it "should post_data in getColumns", ->
      query = 
        origin_url: "some url"
        columns: [{
          col_name: "col name"
          dom_query: ".css"
          required_attribute: "href"
          options:
            columns: [{
              col_name: "col2"
              dom_query: ".css2"
            }]
            data:
              col2: "value"
            post_data:
              form_data_edge: 1
        },{
          col_name: "col2"
          dom_query: ".css"
        }]
        data:
          col2: "value"
        post_data:
          form_data_root: 2      
                
      qh = new ktk.query.helper query
      expect(qh.getColumns().indexOf('col2') > -1 ).toBe true
      expect(qh.getColumns().length).toEqual 6

  describe "getRootColumnsQueryObjects", ->
    it "should return columns objects in options.columns", ->
      qh = new ktk.query.helper valid_query
      expect(qh.getRootColumnsQueryObjects().length).toEqual 7

    it "should return columns objects in options.permuted_columns.handles and options.permuted_columns.responses", ->
      qh = new ktk.query.helper permuted_nested_query
      expect(qh.getRootColumnsQueryObjects().length).toEqual 7


  describe "getRootAddressColumns", ->
    it "should return address columns at the root level", ->
      qh = new ktk.query.helper valid_query
      address_cols = qh.getRootAddressColumns()
      expect(address_cols.length).toEqual 2
      expect(address_cols[0].col_name).toEqual "address_col1"
      expect(address_cols[1].col_name).toEqual "address_col2"

      qh = new ktk.query.helper invalid_query
      expect(qh.getRootAddressColumns().length).toEqual 0

    it "should return permuted address columns  at the root level", ->
      qh = new ktk.query.helper permuted_nested_query
      address_cols = qh.getRootAddressColumns()
      expect(address_cols.length).toEqual 2
      expect(address_cols[0].col_name).toEqual "option value"
      expect(address_cols[1].col_name).toEqual "response1"
  
  describe "getRootColumnsWithNestedChild", ->
    it "should return nested columns at the root level", ->
      qh = new ktk.query.helper valid_query
      root_nested_cols = qh.getRootColumnsWithNestedChild()
      expect(root_nested_cols.length).toEqual 2

      qh = new ktk.query.helper invalid_query
      root_nested_cols = qh.getRootColumnsWithNestedChild()
      expect(qh.getRootColumnsWithNestedChild().length).toEqual 0

    it "should return permuted nested columns  at the root level", ->
      qh = new ktk.query.helper permuted_nested_query
      root_nested_cols = qh.getRootColumnsWithNestedChild()
      expect(root_nested_cols.length).toEqual 2

  describe "getUniqueColumns", ->
    it "should return only unique values in a column", ->
      qh = new ktk.query.helper valid_query
      unique_cols = qh.getUniqueColumns ["wwww", "aaaa", "cccc", "kkkk", "aaaa"]
      expect(unique_cols).toEqual ["wwww", "aaaa", "cccc", "kkkk"]

  describe "getPostDataColumns", ->
    it "should return all values from object", ->
      qh = new ktk.query.helper valid_query
      columns = qh.getPostDataColumns 
        what: "if"
        cant: "do"
        oris:   "else"
      expect(columns).toEqual [ "what", "cant", "oris" ]

    it "should return all values from array of object", ->
      qh = new ktk.query.helper valid_query
      columns = qh.getPostDataColumns [{
          what: "if"
          cant: "do"
          oris:   "else"
        },{
          what: "if"
          cant: "do"
          living: "caut"          
        }]

      expect(columns).toEqual [ "what", "cant", "oris", "what", "cant", "living" ]