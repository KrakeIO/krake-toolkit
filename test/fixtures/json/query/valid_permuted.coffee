query = {
  "origin_url" : "http://localhost:9999/form_simple",
  "permuted_columns" : {
    "handles": [{
      "col_name" : "radio value",
      "dom_query" : "input[type='radio']",
      "required_attribute" : "value"
    },{
      "col_name" : "option value",
      "dom_query" : "option",
      "required_attribute" : "value"
    },{
      "col_name" : "checkbox value",
      "dom_query" : "input[type='checkbox']",
      "required_attribute" : "value"
    },{
      "col_name" : "clickable div value",
      "dom_query" : ".div.clicklables",
      "selected_checksum" : ".selected"
    },{
      "col_name" : "clickable image value",
      "dom_query" : ".f_elements.clk_img",
      "selected_checksum" : ".selected_img",
      "required_attribute" : "src"
    }],
    "responses": [{
      "col_name" : "response1",
      "dom_query" : "#response1"
    },{
      "col_name" : "response2",
      "dom_query" : "#response2"
    }]
  }
}

module.exports = query