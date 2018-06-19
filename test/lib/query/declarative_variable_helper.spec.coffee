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

  it "should return 4 task_objs for HTTP GET", (done)->
    query = require '../../fixtures/json/query/valid_get_compound_new'
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

  it "should return post_data attributes in data", ->
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"

    query =
      origin_url: "some_url",
      columns: [{
        col_name: "a col"
        dom_query: ".a-col"
      }]
      post_data: 
        oh_well: "what to do"

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs).toEqual [{
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data:
          oh_well: "what to do"
        data:
          oh_well: "what to do"
          origin_url: "some_url"
          origin_pattern: "some_url"
      }]

  it "should return post_data attributes in array in each data", ->
    stubbed_obj = 
      iterator: ()->
    spyOn stubbed_obj, "iterator"
    query =
      origin_url: "some_url",
      columns: [{
        col_name: "a col"
        dom_query: ".a-col"
      }]
      post_data: [
        { oh_well: "what to do" },
        { what_to_do: "can't do much" },
      ]

    @dvh.convertOriginUrl query, false, stubbed_obj.iterator, (compiled_objs)=>
      expect(compiled_objs).toEqual [{
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data:
          oh_well: "what to do"
        data:
          oh_well: "what to do"
          origin_url: "some_url"
          origin_pattern: "some_url"
      },
      {
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data:
          what_to_do: "can't do much"
        data:
          what_to_do: "can't do much"
          origin_url: "some_url"
          origin_pattern: "some_url"
      }]

  describe "getCompiledForPostData", ->
    it "should return normal krake definition object", ->
      result = @dvh.getCompiledForPostData
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]

      expect(result).toEqual [{
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
      }]

    it "should return post_data attributes in data", ->
      result = @dvh.getCompiledForPostData
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data: 
          oh_well: "what to do"

      expect(result).toEqual [{
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data:
          oh_well: "what to do"
        data:
          oh_well: "what to do"        
      }]

    it "should return post_data attributes in array in each data", ->
      result = @dvh.getCompiledForPostData
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data: [
          { oh_well: "what to do" },
          { what_to_do: "can't do much" },
        ]
          

      expect(result).toEqual [{
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data:
          oh_well: "what to do"
        data:
          oh_well: "what to do"        
      },
      {
        origin_url: "some_url",
        columns: [{
          col_name: "a col"
          dom_query: ".a-col"
        }]
        post_data:
          what_to_do: "can't do much"
        data:
          what_to_do: "can't do much"
      }]


  describe "mergePostDataToData", ->
    it "should merge post_data into data", ->
      post_data =
        attr_1: "val_1"
        attr_2: "val_2"
        attr_3: "val_3"

      data = 
        org_val: "itis"
      combined_data = @dvh.mergePostDataToData post_data, data

      expect(combined_data).toEqual
        attr_1: "val_1"
        attr_2: "val_2"
        attr_3: "val_3"
        org_val: "itis"

    it "should guard agaist nil post_data", ->
      post_data =
        attr_1: "val_1"
        attr_2: "val_2"
        attr_3: "val_3"

      data = 
        org_val: "itis"
      combined_data = @dvh.mergePostDataToData null, data

      expect(combined_data).toEqual
        org_val: "itis"


    it "should guard agaist nil data", ->
      post_data =
        attr_1: "val_1"
        attr_2: "val_2"
        attr_3: "val_3"

      combined_data = @dvh.mergePostDataToData post_data, null

      expect(combined_data).toEqual
        attr_1: "val_1"
        attr_2: "val_2"
        attr_3: "val_3"

    it "should covert value in data with value in post_data", ->
      post_data =
        org_val: "new_tis"
        attr_2: "val_2"
        attr_3: "val_3"

      data = 
        org_val: "itis"

      combined_data = @dvh.mergePostDataToData post_data, data

      expect(combined_data).toEqual
        org_val: "new_tis"
        attr_2: "val_2"
        attr_3: "val_3"