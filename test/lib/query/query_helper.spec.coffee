valid_query = require '../../fixtures/json/valid'
filtered_query = require '../../fixtures/json/filtered'
invalid_query = require '../../fixtures/json/invalid'
permuted_query = require '../../fixtures/json/valid_permuted'
permuted_nested_query = require '../../fixtures/json/valid_permuted_nested'
ktk = require '../../../krake_toolkit'

describe "Testing Query Helper", ->

  it "should have QueryHelper defined", ->
    expect(ktk.query.helper).toBeDefined()  

  it "should set query_object to {} when valid_query is empty", ->
    qh = new ktk.query.helper ""
    expect(qh.query_object).nil?.toBe false
  
  it "should return all columns", ->
    qh = new ktk.query.helper valid_query  
    expect(qh.getColumns().length).toEqual 21

  it "should return all permuted_columns in query", ->
    qh = new ktk.query.helper permuted_query
    expect(qh.getColumns().length).toEqual 9

  it "should return all permuted_columns in query", ->
    qh = new ktk.query.helper permuted_nested_query
    expect(qh.getColumns().length).toEqual 27

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

