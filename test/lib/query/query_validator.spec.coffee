amazonQuery = require '../../fixtures/json/valid'
invalidQuery = require '../../fixtures/json/invalid'
ktk = require '../../../krake_toolkit'

describe "QueryValidator", ->
  beforeEach ->
    @qv = new ktk.query.validator()

  it "should have QueryValidator defined", (done)->
    expect(ktk.query.validator).toBeDefined()  
    done()
  
  it "should have return status as false when query is ill-defined", (done)->
    @qv.validate "{", (status, result)->
      expect(status).toBe false
    done()

  it "should have return status as true when query is well-defined", (done)->
    spyOn(@qv, 'validate_root_options_obj').andCallThrough()
    spyOn(@qv, 'validate_options_obj').andCallThrough()
    spyOn(@qv, 'validate_columns_array').andCallThrough()
    spyOn(@qv, 'validate_column_obj').andCallThrough()
    @qv.validate amazonQuery, (status, result)=>
      expect(status).toBe true
      expect(@qv.validate_root_options_obj).toHaveBeenCalled()
      expect(@qv.validate_options_obj).toHaveBeenCalled()
      expect(@qv.validate_columns_array).toHaveBeenCalled()
      expect(@qv.validate_column_obj).toHaveBeenCalled()
      expect(typeof result).toBe 'object'
      done()

  describe "validate_root_options_obj", ->
    it "should do callback with false if origin_url is missing ", ->
      options = 
        next_page:
          dom_query: "something"
      expect(@qv.validate_root_options_obj options).toEqual false
      expect(@qv.logs[0]).toEqual "origin_url is missing"

    it "should call validate_options_obj if has origin_url exist and columns", ->
      options = 
        origin_url: "http://localhost"
        columns : []

      spyOn(@qv, "validate_options_obj")
      @qv.validate_root_options_obj options
      expect(@qv.validate_options_obj).toHaveBeenCalled()
      args = @qv.validate_options_obj.mostRecentCall.args
      expect(args[0]).toEqual options

    it "should call validate_options_obj if has origin_url and permuted_columns", ->
      options = 
        origin_url: "http://localhost"
        permuted_columns : {}
      
      spyOn(@qv, "validate_options_obj")
      @qv.validate_root_options_obj options
      expect(@qv.validate_options_obj).toHaveBeenCalled()
      args = @qv.validate_options_obj.mostRecentCall.args
      expect(args[0]).toEqual options

  describe "validate_options_obj", ->
    it "should return false if both columns and permuted_columns are missing", ->    
      options = {}
      expect(@qv.validate_options_obj options).toEqual false

    it "should call validate_columns_array if columns exist", ->
      options =
        columns: []
      spyOn(@qv, "validate_columns_array")
      @qv.validate_options_obj options
      expect(@qv.validate_columns_array).toHaveBeenCalledWith(options.columns)

    it "should call validate_permuted_columns_obj if columns exist", ->
      options =
        permuted_columns: {}
      spyOn(@qv, "validate_permuted_columns_obj")
      @qv.validate_options_obj options
      expect(@qv.validate_permuted_columns_obj).toHaveBeenCalledWith(options.permuted_columns)

  describe "validate_permuted_columns_obj", ->
    it "should return false if both handles and responses are missing", ->
      options = {}
      expect(@qv.validate_permuted_columns_obj options).toEqual false
      expect(@qv.logs[0]).toEqual 'Neither permuted_columns.handles or permuted_columns.responses exist. At least one must exist'

    it "should validate handles columns", ->
      options =
        handles: []
      spyOn(@qv, "validate_columns_array")        
      @qv.validate_permuted_columns_obj options
      expect(@qv.validate_columns_array).toHaveBeenCalledWith(options.handles)

    it "should validate responses columns", ->
      options =
        responses: []
      spyOn(@qv, "validate_columns_array")
      @qv.validate_permuted_columns_obj options
      expect(@qv.validate_columns_array).toHaveBeenCalledWith(options.responses)

    it "should return the aggregated boolean results from the checking of the sub tree", ->
      options =
        handles: []
        responses: []
      spyOn(@qv, "validate_columns_array").andReturn true
      expect(@qv.validate_permuted_columns_obj options).toEqual true

    it "should return the aggregated boolean results from the checking of the sub tree", ->
      options =
        handles: []
        responses: []
      spyOn(@qv, "validate_columns_array").andReturn false
      expect(@qv.validate_permuted_columns_obj options).toEqual false

  describe "validate_columns_array", ->
    it "should return false if is not array", ->
      col_array = {}
      expect(@qv.validate_columns_array col_array).toEqual false
      expect(@qv.logs[0]).toEqual 'columns_array is not array'

    it "should return false if array is empty", ->
      col_array = []
      expect(@qv.validate_columns_array col_array).toEqual false
      expect(@qv.logs[0]).toEqual 'columns_array is empty'

    it "should return aggregated results if populated array", ->
      col_array = [{
        col_name: "col1"
        dom_query: ".css-selector"
      }]
      spyOn(@qv, "validate_column_obj").andReturn true
      expect(@qv.validate_columns_array col_array).toEqual true      
      expect(@qv.validate_column_obj).toHaveBeenCalledWith col_array[0]


  describe "validate_column_obj", ->
    it "should return false if column_obj does not have col_name", ->
      col = {}
      expect(@qv.validate_column_obj col).toEqual false
      expect(@qv.logs[0]).toEqual "column_obj.col_name is missing"

    it "should return false if column_obj does no no xpath, dom_query or var_query", ->
      col = 
        col_name: "some column"
      
      expect(@qv.validate_column_obj col).toEqual false
      expect(@qv.logs[0]).toEqual "some column has neither dom_query, xpath nor var_query. At least one must exist."

    it "should return if column_obj has options but not have origin_url in option", ->
      col = 
        col_name: "some column"
        dom_query: ".some-class"
        options:
          columns: []
      
      expect(@qv.validate_column_obj col).toEqual false
      expect(@qv.logs[0]).toEqual 'some column has neither options.origin_url, required_attribute == "src" nor  required_attribute == "href". At least one must exist.'

    it "should return check the nest options object", ->
      spyOn(@qv, "validate_options_obj")
      col = 
        col_name: "some column"
        dom_query: ".some-class"
        required_attribute: "href"
        options:
          columns: []
      
      @qv.validate_column_obj col
      expect(@qv.validate_options_obj).toHaveBeenCalled()
      args = @qv.validate_options_obj.mostRecentCall.args
      expect(args[0]).toEqual col.options

    it "should return check the nest options object", ->
      spyOn(@qv, "validate_options_obj")
      col = 
        col_name: "some column"
        dom_query: ".some-class"
        required_attribute: "src"
        options:
          columns: []
      
      @qv.validate_column_obj col
      expect(@qv.validate_options_obj).toHaveBeenCalled()
      args = @qv.validate_options_obj.mostRecentCall.args
      expect(args[0]).toEqual col.options      

    it "should return check the nest options object", ->
      spyOn(@qv, "validate_options_obj")
      col = 
        col_name: "some column"
        dom_query: ".some-class"
        options:
          origin_url: "http://localhost/some-url"
          columns: []
      
      @qv.validate_column_obj col
      expect(@qv.validate_options_obj).toHaveBeenCalled()
      args = @qv.validate_options_obj.mostRecentCall.args
      expect(args[0]).toEqual col.options




