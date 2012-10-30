
UnitMapper = 
  unit: 0
  callbacks: []
  random: ->
    this.unit=parseInt(Math.random()*this.table.length)
  get: -> return this.unit  
  getUnit: (des_unit) ->
    des_unit ?= this.unit
    return this.table[des_unit][1]

  getQuantifier: (des_unit) ->
    des_unit ?= this.unit
    return this.table[des_unit][0]

  convert: (value, des_unit, full_desc) ->
    if des_unit==-1 then des_unit=parseInt Math.random()*this.table.length
    des_unit ?= this.unit
    unitdata=this.table[des_unit]
    value=parseInt(10000*value/unitdata[2])/10000
    value = if value>=1000000000000 then parseInt(value/1000000000000)+"兆"
            else if value>=100000000 then parseInt(value/100000000)+"億"
            else if value>=10000 then parseInt(value/10000)+"萬"
            else if value>=1000 then parseInt(value/1000)+"千"
            else if value>=1 then parseInt(10*value)/10
            else value
    return value + if full_desc then unitdata[0]+unitdata[1] else ""

  onchange: (func) ->
    this.callbacks.push(func)

  update: (idx) ->
    if this.unit>=0 
      #$('#unit-selector li:eq('+this.unit+') a i').css {"visibility":"hidden"}
      $('#unit-selector li:eq('+this.unit+') ').removeClass \active
    this.unit = if idx==-1 then parseInt Math.random()*this.table.length
                      else if idx==undefined then 0 
                      else idx

    #$('#unit-selector li:eq('+this.unit+') a i').css visibility:\visible
    $('#unit-selector li:eq('+this.unit+')').addClass \active
      
    d3.selectAll(\text.amount).text (d) ->
      UnitMapper.convert d.size || d.value.sum, UnitMapper.unit, true
    jQuery.each $(".unit-convert"), ->
      $(this).text UnitMapper.convert $(this).attr("cc-value"), UnitMapper.unit, true
    jQuery.each this.callbacks, (x)-> this()
      
  init: ->
    return

  table:
    ["" \元  1] 
    <[份 營養午餐 25]>
    <[份 營養午餐(回扣) 30]>
    <[人的 年薪 308000]>
    <[座 釣魚台 80000000]>
    <[分鐘 太空旅遊 1000000]>
    <[碗 鬍鬚張魯肉飯 68]>
    <[個 便當 50]>
    <[杯 珍奶 30]>
    <[份 雞排加珍奶 60]>
    <[個 晨水匾 700000000]>
    <[個 夢想家 200000000]>
    <[個 林益世(粗估) 83000000]>
    <[座 冰島 2000080000000]>
    <[坪 帝寶 2500000]>
    <[支 iPhone5 25900]>
    <[座 硬兔的小島 2000080000000]>
