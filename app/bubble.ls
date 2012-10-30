# based on https://github.com/vlandham/vlandham.github.com/blob/master/vis/gates/coffee/vis.coffee
class BubbleChart
  (@data, @width = 1004, @height = 650) ->
    $('#bubble_tooltip').remove!
    @tooltip = CustomTooltip 'bubble_tooltip', 370
    @center = do
      x: @width / 2 + 210
      y: @height / 2
    @change_scale = d3.scale.linear!domain([-0.25, 0.25])clamp(true)range [@height / 9 * 5, @height / 9 * 4]

    @layout_gravity = 0.01
    @damper = 0.1
    @vis = null
    @nodes = []
    @force = null
    @circles = null
    @fill_color = d3.scale.quantile!domain([ -0.5 -0.25 -0.1 -0.02 0.02 0.1 0.25 0.5 ]).range <[ red orange pink gray yellow lightgreen green ]>
    max_amount = d3.max @data, (d) -> parseInt d.amount
    @radius_scale = ((d3.scale.pow!.exponent 0.5).domain [0, max_amount]).range [2, 65]
    @create_nodes!
    @create_vis!
  create_nodes: ~>
    @data.forEach (d) ~>
      node = {
        id: d.code
        radius: @radius_scale parseInt d.amount
        value: d.amount
        data: d
        org: d.depname
        orgcat: d.depcat
        d.change
        group: d.cat
        year: 2013
        x: Math.random! * 900
        y: Math.random! * 800
      }
      @nodes.push node
    @nodes.sort ((a, b) -> b.value - a.value)
    @nodes
  create_vis: ~>
    @vis = d3.select(\#chart)append \svg
      .attr \width @width
      .attr \height @height
      .attr \id \svg_vis

    @circles = @vis.selectAll("circle")
      .data(@nodes, -> it.id)

    that = this

    for val, i in ([100, 10000, 100000, 284400].map -> it * 1000 * 1000)
        r = @radius_scale val
        @vis.append \circle
          .attr \r r
          .attr \cx 300
          .attr \cy ~> @height / 2 - r - 1 - 60
          .attr \fill \none
          .attr \stroke-width 2
          .attr \stroke \gray
            ..attr \stroke-dasharray, '5, 1, 5' if i == 3
        @vis.append \text
          .attr \x 300
          .attr \y ~> @height / 2 - r * 2 - 7 - 40
          .attr \text-anchor \bottom
          .attr \text-anchor \middle
          .text CurrencyConvert(val) + (if i == 3 => '(2013預計舉債)' else '')

    colors = [-1] +++ @fill_color.quantiles! +++ [NaN]
    y = d3.scale.ordinal!rangeRoundBands([200, 0], 0.1)domain colors
    change = d3.format \+%
    @vis.selectAll(\.change-lenged)data colors
        ..enter!append \rect
            .attr \class \change-legend
            .attr \x 60
            .attr \y -> 60 + y it
            .attr \width -> 10
            .attr \height -> y.rangeBand!
            .attr \fill ~> @fill_color it
            .attr \stroke \none
        ..enter!append \text
            .attr \x 80
            .attr \y -> 60 + (if isNaN it => y.rangeBand!/2 else y.rangeBand!) + (y it)
            .attr \text-anchor \bottom
            .text -> match it
            | isNaN     => '新增'
            | (== -1)   => ''       # XXX: match -1 does not work
            | otherwise => change it

    @circles.enter().append("circle")
      .attr("r", -> it.radius)
      .attr("fill", (d) ~> @fill_color(d.change))
      .attr("stroke-width", 2)
      .attr("stroke", (d) ~> d3.rgb(@fill_color(d.change)).darker())
      .attr("id", (d) -> "bubble_#{d.id}")
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))

  charge: (d) -> (-Math.pow d.radius, 2) / 8
  start: ~> @force = (d3.layout.force!.nodes @nodes).size [@width, @height]
  display_group_all: ~>
    @tooltip.fixPosition true,$ \#bubble-info
    @vis.selectAll(\.attr-legend)remove!
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) ~>
        @circles.each(this.move_towards_center(e.alpha))
          .attr \cx -> it.x
          .attr \cy -> it.y
    @force.start!

  move_towards_center: (alpha) ~>
    (d) ~>
      cy = (@change_scale d.change) ? @center.y
      cy = @center.y if isNaN cy
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (cy - d.y) * (@damper + 0.02) * alpha


  display_by_attr: (attr) ->
    @tooltip.fixPosition false
    nest = d3.nest
    nest = d3.nest!key -> it[attr]
    entries = nest.entries @data
    sums = nest.rollup -> it.map (.amount) .map(-> +it).reduce (+)
        .entries @data
        .sort (a, b) -> (b.values - a.values)
    curr_x = 430
    curr_y = 100
    y_offset = null
    centers = {}
    for {key,values}:entry in sums
        r = @radius_scale values
        curr_x += Math.max(150, r * 2)
        if curr_x > @width - 130
            curr_x = 100 + r * 2
            curr_y += y_offset
            y_offset = null

        y_offset ?= r + 100

        centers[key] = do
            sum: values
            top: curr_y
            x: curr_x - r
            y: curr_y + y_offset / 2
            r: r

    curr_y += y_offset * 2
    @vis.attr \height, curr_y if curr_y > @vis.attr \height

    move_towards = (alpha) ~>
      (d) ~>
        target = centers[ d.data[attr] ]
        d.x = d.x + (target.x - d.x) * (@damper + 0.22 + (100-(if target.r>100 then 100 else target.r))/130) * alpha * 1.1
        d.y = d.y + (target.y - d.y) * (@damper + 0.22 + (100-(if target.r>100 then 100 else target.r))/130) * alpha * 1.1
    @force.gravity @layout_gravity
      .charge @charge
      .friction 0.9
      .on \tick (e) ~>
        @circles.each(move_towards(e.alpha))
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
#        ..enter!append \rect
#            .attr \class \attr-legend
#            .attr \x -> it.value.x - 60
#            .attr \y -> it.value.y - it.value.r*2/3 - 44
#            .attr \rx -> 5
#            .attr \ry -> 5
#            .attr \width -> 120
#            .attr \height -> 36
#            .attr \strok \black
#            .style \opacity \0.2
        ..enter!append \text
            .attr \class "attr-legend fade bubbletext"
            .attr \x -> it.value.x
            .attr \y -> it.value.y - it.value.r*2/3 - 28
            .attr \text-anchor \middle
            .text -> it.key
        ..enter!append \text
            .attr \class "attr-legend fade amount bubbletext"
            .attr \x -> it.value.x
            .attr \y -> it.value.y - it.value.r*2/3 - 14
            .attr \text-anchor \middle
            .text -> UnitMapper.convert(it.value.sum, null, true)
        ..exit!remove!
    <~ (`setTimeout` 500ms)
    @vis.selectAll(\.attr-legend.fade).classed \in true

  show_details: (data, i, element) ~>
    value = d3.format \,
    change = d3.format \+.2%
    (d3.select element).attr 'stroke', 'black'
    content = "<span class='name'>Title:</span><span class='value'> #{data.data.name} / #{data.id} </span><br/>"
    content += "<span class='name'>Amount:</span><span class='value'> $#{value data.value}</span><br/>"
    content += "<span class='name'>Dep:</span><span class='value'> #{data.data.depname}/ #{data.data.depcat} </span><br/>"
    content += "<span class='name'>change:</span><span class='change'> #{change data.change}</span>"
    content += "<div id='year-chart'></div>"
    @tooltip.showTooltip content, d3.event
    @do_show_details data if @do_show_details
  hide_details: (data, i, element) ~>
    (d3.select element).attr 'stroke', (d) ~> (d3.rgb @fill_color d.change).darker!
    @tooltip.hideTooltip!

root = exports ? this
