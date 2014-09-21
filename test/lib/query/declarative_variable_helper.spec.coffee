# Only works when header settings not added during 
DeclarativeVariableHelper = require '../../../lib/query/declarative_variable_helper'

describe "return 2 origin urls", ()->
  beforeEach ->
    @dvh = new DeclarativeVariableHelper()  

  it "should return 1 task_obj for HTTP GET", (done)->
    query = require '../../fixtures/json/query/valid'
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs.length).toEqual 1
      expect(stubbed_obj.iterator.callCount).toEqual 1
      done()

  it "should return 3 task_objs for HTTP GET", (done)->
    query = require '../../fixtures/json/query/valid_get_array'
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs.length).toEqual 3
      expect(stubbed_obj.iterator.callCount).toEqual 3
      done()

  it "should return 4 task_objs for HTTP GET", (done)->
    query = require '../../fixtures/json/query/valid_get_compound'
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs.length).toEqual 4
      expect(stubbed_obj.iterator.callCount).toEqual 4
      done()

  it "should return 1 task_obj for HTTP POST", (done)->
    query = require '../../fixtures/json/query/post_data_obj'
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs.length).toEqual 1
      expect(stubbed_obj.iterator.callCount).toEqual 1
      done()

  it "should return 3 task_objs for HTTP POST", (done)->
    query = require '../../fixtures/json/query/post_data_array_objs'
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs.length).toEqual 3
      expect(stubbed_obj.iterator.callCount).toEqual 3
      done()

  it "should return 3 task_objs for HTTP POST", (done)->
    query = require '../../fixtures/json/query/post_data_array_origin_url_array_objs'
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs.length).toEqual 9
      expect(stubbed_obj.iterator.callCount).toEqual 9
      done()      

      