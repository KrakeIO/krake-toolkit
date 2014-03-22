query = 
  username: "test"
  password: "test"
  tableName: "ktk_test_table_1"
  host: 
    url: "localhost"
    port: "5432"
  database: "scraped_data_repo_test"
  origin_url: "google.com"
  columns: [{
      col_name: "index_col1"
      dom_query: ".css1"
      is_index: true
    },{
      col_name: "index_col2"
      dom_query: ".css2"
      is_index: true   
    },{
      col_name: "norm_col1"
      dom_query: ".css3"
    },{
      col_name: "norm_col2"
      dom_query: ".css4"
  }]
  data:
    param1: "org_val"

module.exports = query