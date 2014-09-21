query = 
  origin_url : 'http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=iphone'
  method: "post"
  columns: [{
      col_name: 'product_name'
      dom_query: '.lrg.bold'
      is_index: true
    }]
  post_data:
    param1: "hello"
    param2: "world"

module.exports = query

