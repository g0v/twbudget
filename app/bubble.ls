# based on https://github.com/vlandham/vlandham.github.com/blob/master/vis/gates/coffee/vis.coffee
class BubbleChart
  ({@data, @width = 1004, @height = 650, @damper = 0.1, @layout_gravity = 0.01, @amount_attr = \amount}) ->
    $('#bubble_tooltip').remove!
    @tooltip = CustomTooltip 'bubble_tooltip', 370
    @center = do
      x: @width / 2 + 210
      y: @height / 2

    @mode = 'default'
    @nodes = []
    @change_scale = d3.scale.linear!domain([-0.25, 0.25])clamp(true)range [@height / 9 * 5, @height / 9 * 4]
    @fill_color = d3.scale.quantile!domain([ -0.5 -0.25 -0.1 -0.02 0.02 0.1 0.25 0.5 ]).range <[ red orange pink gray yellow lightgreen green ]>
    @radius_scale = d3.scale.pow!exponent 0.5
      .domain [0, d3.max @data, (d) ~> +d[@amount_attr]]
      .range [2, 65]
    @create_nodes!
    @create_vis!
  create_nodes: ->
    @nodes = @data.map (d) ~> do
        id: d.code
        radius: @radius_scale +d[@amount_attr]
        value: +d[@amount_attr]
        data: d
        org: d.depname
        orgcat: d.depcat
        change: d.change
        group: d.cat
        year: 2013
        x: Math.random! * 900
        y: Math.random! * 800
  create_vis: ->
    @vis = d3.select(\#bubble-chart)append \svg
      .attr \width @width
      .attr \height @height
      .attr \id \svg_vis

    @circles = @vis.selectAll("circle.budget")
      .data(@nodes, -> it.id)

    colors = [-1] +++ @fill_color.quantiles! +++ [NaN]
    x = d3.scale.ordinal!rangeRoundBands([200, 0], 0.1)domain colors
    y = d3.scale.ordinal!rangeRoundBands([200, 0], 0.1)domain colors
    change = d3.format \+%
    @vis.selectAll(\.change-lenged)data colors
        ..enter!append \rect
            .attr \class \change-legend
            .attr \x -> 260 + (x it)*1.5
            .attr \y 20
            .attr \width -> x.rangeBand!
            .attr \height -> 10
            .attr \fill ~> @fill_color it
            .attr \stroke \none
        ..enter!append \text
            .attr \x -> 246 + (if isNaN it => x.rangeBand!/2 else x.rangeBand!) + (x it)*1.55
            .attr \y 15
            .attr \text-anchor \right
            .text -> match it
            | isNaN     => '新增'
            | (== -1)   => ''       # XXX: match -1 does not work
            | otherwise => change it
    @locking = (d,i) ~>
      @lockcell.node
        .attr \fill ~> @fill_color it.change
        .attr \stroke, (d) ~> (d3.rgb @fill_color d.change).darker! 
        .style \opacity,1.0 if @lockcell.node
      if !d || d.id==@lockcell.id
        if @mode!='default'
          d3.select \#bubble-info .style \z-index -1 .transition! .duration 475 .style \opacity 0.2
        @lockcell
          ..id = null
          ..node = null
        return 
      d3.select \#bubble-info .style \z-index,100 .transition! .duration 475 .style \opacity 0.9 
      @lockcell
        ..id = d.id
        ..node = d3.select d3.event.target
      @show_details d, i
      @lockcell.node
        .attr \fill, 'url(#MyGradient)'
        .attr \stroke, \#f00
        .style \opacity,0.5

    @lockcell = {node: null, id: null}
    d3.select '\#bubble-info-close' .on('click', (d,i) ~>
      @locking null,i
    )
    @circles.enter!append \circle
      .attr \class -> \bubble-budget
      .attr \r -> it.radius
      .attr \fill ~> @fill_color it.change
      .attr \stroke-width, 2
      .attr \stroke ~> d3.rgb(@fill_color(it.change))darker!
      .attr \id -> "bubble_#{it.id}"
      .on \mousemove (d,i) ~> if !@lockcell.node then @show_details d, i, d3.event.target
      .on \mouseout  (d,i) ~> if !@lockcell.node then @hide_details d, i, d3.event.target
      .on \click (d,i) ~> @locking d,i  

    @depict = @vis.append \g
          .style \opacity 0.0
          .style \display \none
          .attr \transform "translate(430,150)"
    @depict.append \rect
          .attr \width 550
          .attr \height 350
          .attr \rx 10
          .attr \ry 10
          .attr \fill \#222
    for val, i in ([100, 10000, 100000, 284400].map -> it * 1000 * 1000)
        r = @radius_scale val
        @depict.append \circle
          .attr \r r
          .attr \cx 275 - r
          .attr \cy 310 - 2 * r
          .attr \fill \none
          .attr \stroke-width 2
          .attr \stroke \#fff
            ..attr \stroke-dasharray, '5, 1, 5' if i == 3
        @depict.append \text
          .attr \x 285
          .attr \y 315 - 2 * r
          .attr \text-anchor \bottom
          .attr \text-anchor \left
          .attr \fill \#fff
          .text CurrencyConvert(val) + (if i == 3 => '(2013預計舉債)' else '')
    d3.select('#bubble-circle-size').on \mouseover (d,i) ~>
      @depict.transition().duration(750).style \opacity 0.7
      .style \display \block
    .on \mouseout (d,i) ~>
      @depict.transition().duration(750).style \opacity 0.0
      @depict.transition().delay(750).style \display \none
      #setTimeout( ~> @depict.style( \display \none )
      #,750)
  charge: (d) -> (-Math.pow d.radius, 2) / 8
  start: -> @force = d3.layout.force!nodes(@nodes)size [@width, @height]
  display_group_all: ->
    #@tooltip.setPosition \default,$ \#bubble-info
    @mode = 'default'
    i=parseInt Math.random!*@nodes.length
    @show_details @nodes[i],i
    d3.select \#bubble-info .transition! .duration 750 .style \width \360px .style \opacity 1.0 .style \margin-right \-100px
    d3.select \#bubble-info .transition! .ease -> 1
      .delay 750 .style \position \absolute .style \left \5px .style \margin-left \0 .style \top \55px .style \z-index -1
    d3.select \#bubble-info-close .transition! .duration 750 .style \opacity 0.0
    @vis.selectAll(\.attr-legend)remove!
    @force.gravity @layout_gravity
      .charge @charge
      .friction 0.9
      .on \tick (e) ~>
        @circles.each @move_towards_center e.alpha
          .attr \cx -> it.x
          .attr \cy -> it.y
    for k,v of @groups
      @groups[k].transition().style("opacity",0)
    @force.start!

  move_towards_center: (alpha) ->
    (d) ~>
      cy = (@change_scale d.change) ? @center.y
      cy = @center.y if isNaN cy
      d.x += (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y += (cy - d.y) * (@damper + 0.02) * alpha


  display_by_attr: (attr) ->
    #@tooltip.setPosition \float
    #d3.select \#bubble-info .transition! .duration 750 .style \opacity 0.0
    @mode = attr
    d3.select \#bubble-info .transition! .duration 750 .style \width \994px .style \opacity 0.2
    d3.select \#bubble-info-close .transition! .duration 750 .style \opacity 1.0 .style \margin-right \0px
    d3.select \#bubble-info .transition! .ease -> 1
      .delay 750 .style \position \fixed .style \left \50% .style \margin-left \-497px .style \top \107px .style \z-index -1
    nest = d3.nest!key -> it[attr]
    entries = nest.entries @data
    amount_attr = @amount_attr
    sums = nest.rollup -> it.map (.[amount_attr]) .map(-> +it).reduce (+)
        .entries @data
        .sort (a, b) -> (b.values - a.values)
    curr_x = 50
    curr_y = 100
    y_offset = null
    centers = {}
    for {key,values}:entry in sums
        r = @radius_scale values
        curr_x += Math.max(150, r * 2)
        if curr_x > @width - 50
            #if curr_y <=350 then curr_x = 430 + Math.max(150,r*2)
            #else curr_x = 50 + r * 2 todo: remove
            curr_x = 50 + r * 2
            curr_y += y_offset
            y_offset = null

        y_offset ?= r + 170

        centers[key] = do
            key: key
            sum: values
            top: curr_y
            x: curr_x - r
            y: curr_y + y_offset / 2
            r: r
            group: do
              r: (r>?30*(130-(r<?100))/100)
              sparse: false

    group_relocate = (d, des, sparse) ~>
      if des.key==d.data[attr]
        if sparse
          d.des_x = des.x+Math.random!*80-40
          d.des_y = des.y+Math.random!*80-40
        #  d.x = des.x+Math.random!*70-35
        #  d.y = des.y+Math.random!*70-35
        else
          d.des_x = des.x+Math.random!*10-5
          d.des_y = des.y+Math.random!*10-5
        #  d.x = des.x+Math.random!*10-5
        #  d.y = des.y+Math.random!*10-5

    group_sparser = (d) ~> # group hover test function. not used currently
                           # to use this, add (d)~> in group_relocate
      a = d.group.r**2
      b = ((d3.event.pageX - $('#bubble-chart svg').offset().left - d.x )**2)  +
          ((d3.event.pageY - $('#bubble-chart svg').offset().top  - d.y )**2)
      console.log a + ' vs ' + b
      if a>b && !d.group.sparse
        d.group.sparse = true
        @circles.each group_relocate(d,true) 
        @force.start(0.1)
      if a<=b && d.group.sparse
        d.group.sparse = false
        @circles.each group_relocate(d,false)
        @force.start(0.1)
    @circles.each (d,i) -> d.c = centers[d.data[attr]]
    .each (d,i) -> group_relocate(d, d.c,true)
    #.on("click", (d,i) ~>
      #if @lockcell==d then @lockcell=null
      #else lockcell=d
      #@tooltip.setPosition (if !lockcell then \float else \center) ,$ \#bubble-info
      #if @lockcell==d
        #@lockcell=null
        #@tooltip.setPosition \float ,$ \#bubble-info
      #else 
        #@lockcell = d
        #@tooltip.setPosition \center ,$ \#bubble-info
    #)

    if !@groups then @groups = {}
    if !@groups[attr]
      @groups[attr] = @vis.insert("g",":first-child").attr("class",".group-#attr").style("opacity", 0)
      @groups[attr].selectAll("g.group-#attr circle.bubble-groups")
        .data(d3.map centers .values!).enter().insert \circle
        .attr \class -> \bubble-groups
        .attr \r (d) -> d.group.r
        .attr \cx (d) -> d.x
        .attr \cy (d) -> d.y
        .attr \fill \#f5f5f5
        .attr \stroke \#000
        .attr \stroke-dasharray "2,8"
    for k,v of @groups
      if k!=attr then @groups[k].transition().duration(750).style("opacity", 0)
      else @groups[k].transition().duration(750).style("opacity", 1)

    curr_y += y_offset * 2
    @vis.attr \height, curr_y if curr_y > @vis.attr \height

    move_towards = (alpha) ~>
      (d) ~>
        {x,y,r} = centers[ d.data[attr] ]
        factor = (@damper + 0.22 + 1.0*(100-(r <? 100))/130) * alpha * 0.9
        d.x += ((d.des_x ?= x) - d.x) * factor
        d.y += ((d.des_y ?= y) - d.y) * factor
    @force.gravity @layout_gravity
      .charge @charge
      .friction 0.9
      .on \tick (e) ~>
        @circles.each move_towards e.alpha
          .attr \cx -> it.x
          .attr \cy -> it.y
    @force.start!

    @vis.selectAll(\.attr-legend)remove!
    @vis.selectAll(\.attr-legend)data d3.entries centers
#        ..enter!append \rect
#            .attr \class \attr-legend
#            .attr \x -> it.value.x - it.value.r/2
#            .attr \y -> it.value.y - it.value.r/2
#            .attr \width -> it.value.r
#            .attr \height -> it.value.r
#            .attr \strok \black
#            .style \opacity \0.5
        ..enter!append \text
            .attr \class "attr-legend fade bubbletext"
            .attr \x -> it.value.x
            .attr \y -> it.value.y - it.value.group.r - 28
            .attr \text-anchor \middle
            .text -> it.key
        ..enter!append \text
            .attr \class "attr-legend fade amount bubbletext"
            .attr \x -> it.value.x
            .attr \y -> it.value.y - it.value.group.r - 14
            .attr \text-anchor \middle
            .text -> UnitMapper.convert(it.value.sum, null, true)
        ..exit!remove!
    <~ (`setTimeout` 500ms)
    @vis.selectAll(\.attr-legend.fade).classed \in true

  show_details: (data, i, element) ->
    value = d3.format \,
    change = d3.format \+.2%
    if element then (d3.select element).attr 'stroke', 'black'
    content = "<span class='name'>Title:</span><span class='value'> #{data.data.name} / #{data.id} </span><br/>"
    content += "<span class='name'>Amount:</span><span class='value'> $#{value data.value}</span><br/>"
    content += "<span class='name'>Dep:</span><span class='value'> #{data.data.depname}/ #{data.data.depcat} </span><br/>"
    content += "<span class='name'>change:</span><span class='change'> #{change data.change}</span>"
    content += "<div id='bubble-detail-change-bar2'></div>"
    $('#bubble-detail-name').text(data.data.name)
    $('#bubble-detail-depname').text(data.data.depname+'/'+data.data.depcat)
    $('#bubble-detail-amount-value').text(UnitMapper.convert data.value,undefined,false)
    $('#bubble-detail-amount-quantifier').text(UnitMapper.getQuantifier!)
    $('#bubble-detail-amount-unit').text(UnitMapper.getUnit!)
    $('#bubble-detail-amount-change').text(change data.change)
    $('#bubble-detail-amount-alt').text UnitMapper.convert data.value,-1,true
    @tooltip.showTooltip content, d3.event if @mode!='default'
    @do_show_details data,(if element then @mode else 'default') if @do_show_details
    if !element then @tooltip.hideTooltip!
  hide_details: (data, i, element) ->
    (d3.select element).attr 'stroke', (d) ~> (d3.rgb @fill_color d.change).darker!
    @tooltip.hideTooltip!

root = exports ? this
