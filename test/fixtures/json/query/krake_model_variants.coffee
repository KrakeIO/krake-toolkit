variants = {}
variants.stringified_content = '{
      "origin_url": "http://stringify",
      "columns": [{
        "col_name"  : "some string col",
        "dom_query" : ".some.col"
      },{
        "col_name"  : "some other string col",
        "dom_query" : ".some.col"
      }]
    }'

variants.simple_krake_model = {
  content: '{
      "origin_url": "http://somewhere",
      "columns": [{
        "col_name"  : "some simple col",
        "dom_query" : ".some.col"
      },{
        "col_name"  : "some other simple col",
        "dom_query" : ".some.col"
      }]
    }'
}

variants.krake_model_with_template = {
  content: '{
      "origin_url": "http://somewhere",
      "columns": [{
        "col_name"  : "some random col",
        "dom_query" : ".some.col"
      },{
        "col_name"  : "some other random col",
        "dom_query" : ".some.col"
      }]
    }',  
  template_id: 999,
  template:
    content: '{
      "origin_url": "http://somewhere_else",
      "columns": [{
        "col_name"  : "some template col",
        "dom_query" : ".some.col"
      },{
        "col_name"  : "some other template col",
        "dom_query" : ".some.col"
      }]
    }'
}

variants.krake_model_with_bad_template = {
  content: '{
      "origin_url": "http://somewhere",
      "columns": [{
        "col_name"  : "some reverted krake col",
        "dom_query" : ".some.col"
      },{
        "col_name"  : "some other reverted krake col",
        "dom_query" : ".some.col"
      }]
    }',  
  template_id: 999
}



module.exports = variants