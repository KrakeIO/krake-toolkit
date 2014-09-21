query = 
  origin_url : [
    'url_1',
    'url_2',
    'url_3'
  ]
  method: "post"
  columns: [{
      col_name: 'product_name'
      dom_query: '.lrg.bold'
      is_index: true
    }]
  post_data: [
    { param1: "hello", param2: "world" },
    { param1: "hello", param2: "world again" },
    { param1: "hello", param2: "world again and again" }
  ]

module.exports = query

