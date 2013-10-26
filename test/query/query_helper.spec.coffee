testQuery = require '../fixtures/amazon'
filteredQuery = require '../fixtures/filtered'
ktk = require '../../krake_toolkit'

describe "Testing Query Helper", ()->

  it "should have QueryHelper defined", (done)->
    expect(ktk.query.helper).toBeDefined()  
    done()
  
  it "should return all columns", (done)->
    qh = new ktk.query.helper testQuery  
    expect(qh.getColumns().length).toEqual 7
    done()

  it "should return all url columns", (done)->
    qh = new ktk.query.helper testQuery
    expect(qh.getUrlColumns().length).toEqual 2
    done() 
    
  it "should return all filtered columns", (done)->
    qh = new ktk.query.helper filteredQuery
    expect(qh.getFilteredColumns().length).toEqual 2
    expect(qh.getFilteredColumns()[0]).toBe 'product_name'
    expect(qh.getFilteredColumns()[1]).toBe 'detailed_page'    
    done()
    
  it "should return all indexed columns", (done)->
    qh = new ktk.query.helper testQuery
    expect(qh.getIndexArray().length).toEqual 1
    expect(qh.getFilteredColumns()[0]).toBe 'product_name'
    done()
  
  it "should return an empty array when the schema is invalid", (done)->
    qh = new ktk.query.helper "{"
    expect(qh.getIndexArray().length).toEqual 0
    done()