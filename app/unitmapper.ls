
UnitMapper = 
  unit: 0
  random: ->
    UnitMapper.unit=parseInt(Math.random()*UnitMapper.table.length)
    
  set: (des_unit)->
    UnitMapper.unit=des_unit

  convert: (value, des_unit, full_desc) ->
    des_unit?=0
    unitdata=mapunit.table[des_unit]
    value=parseInt(10000*value/unitdata[2])/10000
    value = if value>=1000000000000 then parseInt(value/1000000000000)+"兆"
            else if value>=100000000 then parseInt(value/100000000)+"億"
            else if value>=10000 then parseInt(value/10000)+"萬"
            else if value>=1000 then parseInt(value/1000)+"千"
            else if v>=1 then parseInt(10*value)/10
    return v+c[0]+ if full then c[0]+c[1] 

  init: ->
    $ \.currency-convert .click -> alert(\hi)
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
    <[份 雞排加珍奶60]>
    <[個 晨水匾 700000000]>
    <[個 夢想家 200000000]>
    <[個 林益世(粗估) 83000000]>
    <[座 冰島 2000080000000]>
    <[坪 帝寶 2500000]>
    <[支 iPhone5 25900]>
    <[座 硬兔的小島 2000080000000]>
