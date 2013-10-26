amazonQuery = require '../fixtures/amazon'
invalidQuery = require '../fixtures/amazon'
ktk = require '../../krake_toolkit'

describe "Testing Query Validator", ()->

  it "should have QueryValidator defined", (done)->
    expect(ktk.QueryValidator).toBeDefined()  
    done()
  
  it "should have return status as false when query is ill-defined", (done)->
    qv = new ktk.QueryValidator()
    qv.validate "{", (status, result)->
      expect(status).toBe false
    done()

  it "should have return status as true when query is well-defined", (done)->
    qv = new ktk.QueryValidator()
    spyOn(qv, 'validate_root_options_obj').andCallThrough()
    spyOn(qv, 'validate_options_obj').andCallThrough()
    spyOn(qv, 'validate_columns_array').andCallThrough()
    spyOn(qv, 'validate_column_obj').andCallThrough()
    qv.validate amazonQuery, (status, result)->
      expect(status).toBe true
      expect(qv.validate_root_options_obj).toHaveBeenCalled()
      expect(qv.validate_options_obj).toHaveBeenCalled()
      expect(qv.validate_columns_array).toHaveBeenCalled()
      expect(qv.validate_column_obj).toHaveBeenCalled()
      expect(typeof result).toBe 'object'
      done()