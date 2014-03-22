query = {
  "origin_url" : "http://localhost:9999/form_simple"
  "permuted_columns" : {
    "handles": [{
      "col_name" : "radio value"
      "dom_query" : "input[type='radio']"
      "required_attribute" : "href"
      "options" : {
          "columns" : [{
            "col_name": "nested_address"
            "dom_query": ".nested-col"
            "required_attribute": "href"
            "options": 
              "permuted_columns": 
                "handles": [{
                  "col_name": "tri_nested_handles_col"
                  "dom_query": ".nested-col"
                }]
                "responses": [{
                  "col_name": "tri_nested_response_col"
                  "dom_query": ".nested-col"
                }]
          }]
      }
    }],
    "responses": [{
      "col_name" : "response1"
      "dom_query" : "#response1"
    }]
  }
}

module.exports = query