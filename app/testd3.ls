mapforyear = (year, cb) ->
    json <- d3.csv "/data/tw#{year}ap.csv"
    cb {[code, entry] for {code}:entry in json}

dataforyear = (year, cb) ->
    json <- d3.csv "/data/tw#{year}ap.csv"
    json = d3.nest!
        .key -> it.cat 
        .key -> it.depname 
        .map json
    cb {key: \root, values: json}

dataOverYears = (y2012, y2013) ->
    for code, entry of y2013
        entry.byYear = { 2013: +entry.amount, 2012: +y2012[code]?amount }
        entry.change = (entry.byYear.2013 - entry.byYear.2012) / entry.byYear.2012 if entry.byYear.2012
        entry.amount = 0 if entry.amount is \NaN
        entry

root = exports ? this

by_year = null
init_year_data = (cb) ->
    return cb by_year if by_year

    by_year := {}
    by_year.2007 <- mapforyear 2007
    by_year.2008 <- mapforyear 2008
    by_year.2009 <- mapforyear 2009
    by_year.2010 <- mapforyear 2010
    by_year.2011 <- mapforyear 2011
    by_year.2012 <- mapforyear 2012
    by_year.2013 <- mapforyear 2013

    cb by_year

bar_chart = (id) ->
    by_year <- init_year_data!

    data = [{year, amount: +(by_year[year][id]?amount ? 0)} for year in [2007 to 2013]]
    margin = {top: 20, right: 20, bottom: 30, left: 100}
    width = 400 - margin.left - margin.right
    height = 250 - margin.top - margin.bottom

    x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1)

    y = d3.scale.linear().range([height, 0])

    xAxis = d3.svg.axis().scale(x).orient("bottom")

    yAxis = d3.svg.axis().scale(y).orient("left")


    svg = d3.select('#year-chart').html('')append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain data.map -> it.year
    y.domain [0, d3.max(data, -> it.amount/1000000)]

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", -86)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("金額(百萬元)");

    svg.selectAll(\.bar)data(data)
        .enter!append \rect
        .attr \class \bar
        .attr \x      -> x it.year
        .attr \width  x.rangeBand!
        .attr \y      -> y it.amount/1000000
        .attr \height -> height - y(it.amount/1000000)

test_bubble = ->
  chart = null

  render_vis = (csv) ->
    chart := new BubbleChart csv
    chart.do_show_details = (data) ->
        bar_chart data.id
    chart.start!
    root.display_all!
  root.display_all = ~>
    chart.display_group_all()
  root.display_year = ~>
    chart.display_by_year()
  root.toggle_view = (view_type) ~>
    if view_type == 'year'
      root.display_year!
    else
      root.display_all!

#  return d3.csv "/data/gates_money.csv", render_vis
  y2012 <- mapforyear 2012
  y2013 <- mapforyear 2013
  data = dataOverYears y2012, y2013
  data .= sort (a, b) -> b.amount - a.amount
  #data .= slice 0, 600
  render_vis data
  $('.btn.bycat')click -> chart.display_by_attr \cat
  $('.btn.bytop')click -> chart.display_by_attr \topname
  $('.btn.default')click -> chart.display_group_all!

testd3 = ->
    cell = ->
        @style \left -> it.x + \px
        .style \top -> it.y + \px
        .style \width -> Math.max(0, it.dx - 1) + \px
        .style \height -> Math.max(0, it.dy - 1) + \px

    width = 960
    height = 500

    color = d3.scale.category20c!

    treemap = d3.layout.treemap!children -> it.values
        .size [ width, height ]
        .sticky true
        .value -> it.change

    div = d3.select(\#chart).append("div")
        .style \position \relative
        .style \width  width + \px
        .style \height height + \px

    y2012 <- mapforyear 2012
    y2013 <- mapforyear 2013
    data = dataOverYears y2012, y2013
    json = d3.nest!
        .key -> it.cat 
        .key -> it.depname 
        .entries data
    json = {key: \root, values: json}

    div.data([ json ]).selectAll("div")
        .data treemap.nodes
        .enter!append("div")attr \class \cell
        .style \background ->
            if it.values then null else color(it.cat)
        .call cell
        .text -> if it.values then null else it.name

    d3.select(\#y2013).on \click ->
        div.selectAll("div")
            .data treemap.value -> it.byYear?2013
        .transition()
            .duration(1500)
            .call(cell)
    d3.select(\#y2012).on \click ->
        div.selectAll("div")
            .data treemap.value -> it.byYear?2012
        .transition()
            .duration(1500)
            .call(cell)
