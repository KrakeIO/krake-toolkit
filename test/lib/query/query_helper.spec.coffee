testQuery = require '../../fixtures/json/valid'
filteredQuery = require '../../fixtures/json/filtered'
invalidQuery = require '../../fixtures/json/invalid'
ktk = require '../../../krake_toolkit'

describe "Testing Query Helper", ()->

  it "should have QueryHelper defined", (done)->
    expect(ktk.query.helper).toBeDefined()  
    done()

  it "should set query_object to {} when testQuery is empty", (done)->
    qh = new ktk.query.helper ""
    expect(qh.query_object).nil?.toBe false
    done()
  
  it "should return all columns", (done)->
    qh = new ktk.query.helper testQuery  
    expect(qh.getColumns().length).toEqual 21
    done()

  it "should return all url columns", (done)->
    qh = new ktk.query.helper testQuery
    expect(qh.getUrlColumns().length).toEqual 5
    done() 
    
  it "should return all filtered columns", (done)->
    qh = new ktk.query.helper filteredQuery
    expect(qh.getFilteredColumns().length).toEqual 2
    expect(qh.getFilteredColumns()[0]).toBe 'product_name'
    expect(qh.getFilteredColumns()[1]).toBe 'detailed_page'    
    done()
    
  it "should return all indexed columns", (done)->
    qh = new ktk.query.helper testQuery
    expect(qh.getFilteredColumns()[0]).toBe 'product_name'
    done()
  
  it "should return an empty array when the schema is invalid", (done)->
    qh = new ktk.query.helper "{"
    expect(qh.getIndexArray().length).toEqual 0
    done()

  it "should return address columns at the root level", ->
    qh = new ktk.query.helper testQuery
    address_cols = qh.getRootAddressColumns()
    expect(address_cols.length).toEqual 2
    expect(address_cols[0].col_name).toEqual "address_col1"
    expect(address_cols[1].col_name).toEqual "address_col2"

    qh = new ktk.query.helper invalidQuery
    expect(qh.getRootAddressColumns().length).toEqual 0
    
  it "should return nested columns at the root level", ->
    qh = new ktk.query.helper testQuery
    root_nested_cols = qh.getRootColumnsWithNestedChild()
    expect(root_nested_cols.length).toEqual 2

    qh = new ktk.query.helper invalidQuery
    root_nested_cols = qh.getRootColumnsWithNestedChild()
    expect(qh.getRootColumnsWithNestedChild().length).toEqual 0