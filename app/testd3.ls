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

dataOverYears = (y2013, y2014) ->
    for code, entry of y2014
        entry.byYear = { 2014: +entry.amount, 2013: +y2013[code]?amount }
        entry.change = (entry.byYear.2014 - entry.byYear.2013) / entry.byYear.2013 if entry.byYear.2013
        entry.amount = 0 if entry.amount is \NaN
        entry

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
    by_year.2014 <- mapforyear 2014

    cb by_year

bar_chart = (id,mode) ->
    by_year <- init_year_data!

    data = [{year, amount: +((by_year[year] && by_year[year][id])?amount ? 0)} for year in [2007 to 2014]]
    margin = {top: 10, right: 30, bottom: 20, left: 90}
    width = 360 - margin.left - margin.right
    height = 140 - margin.top - margin.bottom

    x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1)

    y = d3.scale.linear().range([height, 0])

    xAxis = d3.svg.axis().scale(x).orient("bottom")

    yAxis = d3.svg.axis().scale(y).orient("left")


    svg = d3.select('#bubble-detail-change-bar'+if mode=='default' then '' else '2').html('')append("svg")
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

  render_vis = (data) ->
    chart := new BubbleChart {data}
      ..do_show_details = (data, mode) ->
        bar_chart data.id, mode
      ..start!
      ..display_group_all!

  y2013 <- mapforyear 2013
  y2014 <- mapforyear 2014
  data = dataOverYears y2013, y2014
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

    div = d3.select(\#bubble-chart).append("div")
        .style \position \relative
        .style \width  width + \px
        .style \height height + \px

    y2013 <- mapforyear 2013
    y2014 <- mapforyear 2014
    data = dataOverYears y2013, y2014
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

    d3.select(\#y2014).on \click ->
        div.selectAll("div")
            .data treemap.value -> it.byYear?2014
        .transition()
            .duration(1500)
            .call(cell)
    d3.select(\#y2013).on \click ->
        div.selectAll("div")
            .data treemap.value -> it.byYear?2013
        .transition()
            .duration(1500)
            .call(cell)
