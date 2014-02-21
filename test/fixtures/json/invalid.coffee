query = 
  origin_url : 'http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=iphone'
  columns: [{
      col_name: 'detailed_page'
      dom_query: '.newaps a'
      options :
        columns : [{
          col_name : 'product_description'
          dom_query : '#productDescription'
        }]   
    }, {         
      col_name: 'product_name'
      dom_query: '.lrg.bold'
    },{
      col_name: 'product_image'
      dom_query: '.image img'
      required_attribute : 'src'        
    },{        
      col_name : 'price'
      dom_query : 'span.bld.lrg.red' 
  }]

module.exports = query