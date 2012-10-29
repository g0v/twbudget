# based on https://github.com/vlandham/vlandham.github.com/blob/master/vis/gates/coffee/vis.coffee
class BubbleChart
  (@data, @width = 1004, @height = 650) ->
    @tooltip = CustomTooltip 'bubble_tooltip', 240
    @center = do
      x: @width / 2
      y: @height / 2
    @change_scale = d3.scale.linear!domain([-0.25, 0.25])clamp(true)range [@height / 9 * 5, @height / 9 * 4]
    @center = do
      x: @width / 2
      y: @height / 2
    @year_centers = do
      '2008': do
        x: @width / 3
        y: @height / 2
      '2009': do
        x: @width / 2
        y: @height / 2
      '2010': do
        x: 2 * @width / 3
        y: @height / 2

    @layout_gravity = -0.01
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
        d.name
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
        legend = @vis.append \circle
          .attr \r r
          .attr \cx 300
          .attr \cy ~> @height / 2 - r - 1 - 30
          .attr \fill \none
          .attr \stroke-width 2
          .attr \stroke \gray
          .attr \id \legend_1
            ..attr \stroke-dasharray, '5, 1, 5' if i == 3
        @vis.append \text
          .attr \x 300
          .attr \y ~> @height / 2 - r * 2 - 7 - 30
          .attr \text-anchor \bottom
          .attr \text-anchor \middle
          .text CurrencyConvert(val) + (if i == 3 => '(2013預計舉債)' else '')

    colors = [-1] +++ @fill_color.quantiles! +++ [NaN]
    x = d3.scale.ordinal!rangeRoundBands([0, 300], 0.1)domain colors
    y = d3.scale.ordinal!rangeRoundBands([0, 200], 0.1)domain colors
    change = d3.format \+%
    change_legend = @vis.selectAll(\.change-lenged)data colors
        ..enter!append \rect
            .attr \class \change-legend
            .attr \x 60
            .attr \y -> 100 + y it
            .attr \width -> x.rangeBand!
            .attr \height 10
            .attr \fill ~> @fill_color it
            .attr \stroke \black
        ..enter!append \text
            .attr \x 100
            .attr \y -> 110 + (if isNaN it => 0 else -25) + y it
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
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) ~>
        @circles.each(this.move_towards_center(e.alpha))
          .attr \cx -> it.x + 210
          .attr \cy -> it.y
    @force.start!

    @hide_years()

  move_towards_center: (alpha) ~>
    (d) ~>
      cy = (@change_scale d.change) ? @center.y
      cy = @center.y if isNaN cy
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (cy - d.y) * (@damper + 0.02) * alpha
  display_by_year: ~>
    (((@force.gravity @layout_gravity).charge @charge).friction 0.9).on 'tick', (e) ~> ((@circles.each @move_towards_year e.alpha).attr 'cx', (d) -> d.x).attr 'cy', (d) -> d.y
    @force.start!
    @display_years!
  move_towards_year: (alpha) ~>
    (d) ~>
      target = @year_centers[d.year]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1
  display_years: ~>
    years_x = {
      '2008': 160
      '2009': @width / 2
      '2010': @width - 160
    }
    years_data = d3.keys years_x
    years = (@vis.selectAll '.years').data years_data
    (((((years.enter!.append 'text').attr 'class', 'years').attr 'x', (d) ~> years_x[d]).attr 'y', 40).attr 'text-anchor', 'middle').text ((d) -> d)
  hide_years: ~> years = (@vis.selectAll '.years').remove!
  show_details: (data, i, element) ~>
    value = d3.format \,
    change = d3.format \+.2%
    (d3.select element).attr 'stroke', 'black'
    content = "<span class='name'>Title:</span><span class='value'> #{data.name} / #{data.id} </span><br/>"
    content += "<span class='name'>Amount:</span><span class='value'> $#{value data.value}</span><br/>"
    content += "<span class='name'>Dep:</span><span class='value'> #{data.org}/ #{data.orgcat} </span><br/>"
    content += "<span class='name'>change:</span><span class='change'> #{change data.change}</span>"
    @tooltip.showTooltip content, d3.event
    @do_show_details data if @do_show_details
  hide_details: (data, i, element) ~>
    (d3.select element).attr 'stroke', (d) ~> (d3.rgb @fill_color d.change).darker!
    @tooltip.hideTooltip!

root = exports ? this
