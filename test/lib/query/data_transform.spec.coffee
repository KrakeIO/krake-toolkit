# Only works when header settings not added during 
DataTransformer = require '../../../lib/query/data_transformer'

value = "歡迎光臨 ICEWOODS 冰河森林數位科技有限公司的購物商城!
  您可以透過以下管道與我們聯絡:
  MSN: sms01@playwoods.com
  E-mail: serv001@icewoods.com
  電話: (02)2528-2825#600(客服專線)


  我們在台北國父紀念館捷運站附近,步行約5分鐘。歡迎周一到周五15:00~20:00 預約 面交。
  周六周日可於板橋捷運站面交
  **面交前請先電話確認，否則白跑一趟就不好意思囉^^


  如需 (貨到付) 服務， 請來電訂購詢問。
  黑貓貨到付款手續費 120 元(大型物件或是外島另行報價)


  如果在 Yahoo 超級商城 使用 (超商取貨(全家/萊爾富/OK) 方式取貨，
  請您於匯款完成後，將您指定的超商資訊寄到serv001@icewoods.com；
  (超商資訊請參考 http://cvs.map.com.tw/)
  資料確認後我們會盡快出貨。


  如果在 Yahoo 超級商城 使用 (面交) 方式取貨，
  請您於匯款完成後30天內到本公司取貨；
  若逾時不取，則本公司會以 [客戶的名義]，
  將商品捐贈給 [台灣兒童暨家庭扶助基金會] ；
  替[忘記取貨]或是[有意做善事]的您，積福積壽積功德。


  感謝大家的支持與愛護!!



  冰河森林公司官網 http://www.ICEWOODS.com/


  本公司四個專屬網站：

  [遊戲森林PS3/Wii/XBOX360 相關遊戲或周邊商品]
  http://www.GameWoods.net/

  [華人最大審判之眼/審判魔眼專門網站]
  http://www.EOJgame.com/

  [自產自銷台灣咖啡豆]
  http://www.La-Coffee.com.tw/

  [利佳龍有限公司 Zexon 品牌的專門抗菌 N95口罩 等商品]
  http://www.ZEXON.com.tw/


  聯絡方式：
  TEL: (02)2733-7333 分機600
  地址: 台北市信義區基隆路二段77號8樓之3 (1樓是合作金庫)
  地圖請參考: http://www.icewoods.com/contactus.html



  重要 ：
  注意事項


  如需貨到付服務， 請來電訂購詢問。
  黑貓貨到付款手續費 120 元(大型物件或是外島另行報價) 



  PS: 
  本公司有分下列產品線，請大家依照需要輸入關鍵字，尋找自己需要的商品喔

  關鍵字範例如右 : 玩具森林 星際大戰
  (鍵入此關鍵字，就能搜尋到本公司的公仔商品)


  商品線如下：

  [冰河森林]
  魔法風雲會卡片商品；本公司自製或研發的商品；合作廠商商品等。

  [遊戲森林] 或是 [GameWoods] 
  PS3/Wii/XBOX360 相關遊戲或周邊商品、 審判之眼/審判魔眼/魔法風雲會商品專區、 所有益智遊戲或是不插電桌上遊戲

  [玩具森林] 
  有最新的變形金剛；Mighty Muggs；HASBRO孩之寶；樂高模型；日版、美版、陸版品牌玩具模型公仔等。"


describe "test extraction of phone number ", ()->
  it "should return a valid phone number ", (done)->

    column_object = {
        "col_name": "phone number extracted using regex",
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
    }
    
    dt = new DataTransformer value, column_object
    
    phones = dt.getPhone()
    expect(phones).toEqual "(02)2528-2825,(02)2733-7333"
    done()



describe "test extraction of email address ", ()->
  it "should return a valid email ", (done)->

    column_object = {
        "col_name": "phone number extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
    }

    dt = new DataTransformer value, column_object

    emails = dt.getEmail()
    expect(emails).toEqual "sms01@playwoods.com,serv001@icewoods.com,serv001@icewoods.com"
    done()
    
    
    
describe "test extraction of using required attribite email ", ()->
  it "should return a valid email ", (done)->

    column_object = {
        "col_name": "email extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'required_attribute' : 'email'
    }

    dt = new DataTransformer value, column_object

    output = dt.getValue()
    expect(output).toEqual "sms01@playwoods.com,serv001@icewoods.com,serv001@icewoods.com"
    done()



describe "test extraction of using required attribite email on string with no email ", ()->
  it "should return a valid email ", (done)->

    column_object = {
        "col_name": "email extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'required_attribute' : 'email'
    }

    empty_val = 'A Perfect Slideshow to present to all your Guest during your Wedding Dinner\nNight in Full HD (1080P) glory.\n\nWhether it\'s for the rehearsal dinner or to recap the big day, we are able to\ntransform your still photos to a stunning wedding video slideshow with\nProfessional Transition.\n\nThere will be Pan and Zoom Effects, Background Music and Animated Caption. All\nyou need is to provide us with the photos, the song you want appear on the video\nand we\'ll add the magic touch. \n\nBoth Standard DVD & Full HD (1080P) Quality Video Files available. \n\nwww.avshowroom.com\nTel: 90077960'
    dt = new DataTransformer empty_val, column_object

    output = dt.getValue()
    expect(output).toEqual ''
    done()



describe "test extraction of using required attribite phone ", ()->
  it "should return a valid phone ", (done)->

    column_object = {
        "col_name": "phone extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'required_attribute' : 'phone'
    }

    dt = new DataTransformer value, column_object

    output = dt.getValue()
    expect(output).toEqual "(02)2528-2825,(02)2733-7333"
    done()


describe "test extraction of 1st number ", ()->
  it "should return a number ", (done)->

    column_object = {
        "col_name": "number extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'regex_pattern' : /[0-9]+/
    }

    dt = new DataTransformer value, column_object

    output = dt.getValue()
    expect(output).toEqual "01"
    done()



describe "test extraction using string Regex type ", ()->
  it "should return a number ", (done)->

    column_object = {
        "col_name": "number extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'regex_pattern' : "[0-9]+"
    }

    dt = new DataTransformer value, column_object

    output = dt.getValue()
    expect(output).toEqual "01"
    done()



describe "test extraction of 2nd numbers ", ()->
  it "should return a number ", (done)->

    column_object = {
        "col_name": "number extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'regex_pattern' : /[0-9]+/ig
        'regex_group' : 2
    }

    dt = new DataTransformer value, column_object

    output = dt.getValue()
    expect(output).toEqual "02"
    done()


    
describe "test extraction of a string of comma separated numbers ", ()->
  it "should return a string of comma separated number ", (done)->

    column_object = {
        "col_name": "string of numbers extracted using regex"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'regex_pattern' : /[0-9]+/ig
        'regex_group' : 1
    }

    dt = new DataTransformer value, column_object

    output = dt.getValue()
    expect(output).toEqual "001"
    done()

describe "getting number", ()->
  it "should return the first number in the string", (done)->
    column_object = {
        "col_name": "year of car"
        "xpath": "//*[@id='thelist']/tr/td/table/tbody/tr/td[3]"
        'regex_pattern' : /[0-9]+/
    }
    
    value = "2014 FORD FOCUS SE - MARION, IL"
    dt = new DataTransformer value, column_object

    output = dt.getValue()
    expect(output).toEqual "2014"
    done()    