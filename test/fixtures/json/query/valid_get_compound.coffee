query = 
  origin_url : 
    origin_pattern: "http://www.amazon.com/s/ref=nb_sb_noss?field-keywords=@@origin_value@@"
    origin_value: [
      "Iphones",
      "blackberry",        
      "Android",
      "Nokia"
    ]
  columns: [{
      col_name: 'product_name'
      dom_query: '.lrg.bold'
      is_index: true
    },{
      col_name: 'product_image'
      dom_query: '.image img'
      required_attribute : 'src'        
    },{        
      col_name : 'price'
      dom_query : 'span.bld.lrg.red' 
    }, {
      col_name: 'detailed_page'
      dom_query: '.newaps a'
      required_attribute : 'href'
      options :
        columns : [{
          col_name : 'product_description'
          dom_query : '#productDescription'
        }]
    }, {
      col_name: 'detailed_page2'
      dom_query: '.newaps a'
      options :
        origin_url: "http://localhost:9999"
        columns : [{
          col_name : 'product_description'
          dom_query : '#productDescription'
        }]
    },{        
      col_name : 'address_col1'
      dom_query : 'span.bld.lrg.red'
      required_attribute : 'address'
    },{        
      col_name : 'address_col2'
      dom_query : 'span.bld.lrg.red'
      required_attribute : 'address'
  }]

module.exports = query