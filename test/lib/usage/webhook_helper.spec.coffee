WebHookHelper = require "../../../lib/usage/webhook_helper"
test_server = require "../../fixtures/test_server"
dateFormat = require 'dateformat'

describe "WebHookHelper", ->
  beforeEach ->
    test_server.listen 9999

  afterEach ->
    test_server.close()

  it "should POST to url in webhook", (done)->
    krake_settings = 
      name: "what to do"
      handle: "handle much"

    date = dateFormat new Date(), "yyyy-mm-dd HH:MM:ss"

    job_wrapper =
      query:
        data:
          pingedAt: date

    whh = new WebHookHelper "not used any more", "http://localhost:9999/webhook_url", krake_settings, job_wrapper
    whh.process "complete",  (response)=>
      expect(response.krake_name).toEqual "what to do"
      expect(response.krake_handle).toEqual "handle much"
      expect(response.event_name).toEqual "complete"
      expect(response.batch_time).toEqual date
      done()