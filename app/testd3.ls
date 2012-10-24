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
        .value -> it.byYear.2013

    div = d3.select(\#chart).append("div")
        .style \position \relative
        .style \width  width + \px
        .style \height height + \px

    y2012 <- mapforyear 2012
    y2013 <- mapforyear 2013
    data = for code, entry of y2013
        entry.byYear = { 2013: +entry.amount, 2012: +y2012[code]?amount }
        entry

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
