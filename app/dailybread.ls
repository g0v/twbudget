OpenSpending ?= {}
<- $
TAXMAN_URL = "http://taxman.openspending.org"
OpenSpending.DailyBread = (elem) ->
  self = this
  @$e = $(elem)
  @$e.data "wdmmg.dailybread", this
  @tiers = []
  @areas = []
  @iconLookup = (name) ->

  @divby = 365
  @init = ->
    @setSalary 22000 # default starting salary
    /* TODO remove after confirming that this is redundent
    @$e.find(".wdmmg-slider").slider do
      value: @salaryVal
      min: 10000
      max: 200000
      step: 10
      animate: true
      slide: ->
        self.sliderSlide.apply self, arguments_
      change: ->
        self.sliderChange.apply self, arguments_
    */
    @$e.delegate ".db-area-col", "click", self.handleClick

  @formatCurrency = (val, prec, sym, dec, sep) ->
    val /= @divby
    prec = (if prec? then 2 else prec)
    sym = sym or "$"
    dec = dec or "."
    sep = sep or ","
    str = void
    valAry = val.toFixed(prec).split(".")
    sepAry = []
    i = valAry[0].length

    while i > 2
      sepAry.unshift valAry[0].slice(i - 3, i)
      i -= 3
    sepAry.unshift valAry[0].slice(0, i)  if i isnt 0
    str = sym + sepAry.join(sep)
    str += dec + valAry[1]  if prec > 0
    str


  @setTax = (tax) ->
      @taxVal = parseFloat(tax)
      self.draw!

  @sliderSlide = (evt, sld) ->
    self.setSalary sld.value
    self.drawTotals()

  @sliderChange = (evt, sld) ->
    self.setSalary sld.value
    self.draw true

  @handleClick = ->
    tier = $(this).closest(".db-tier")
    tierId = parseInt(tier.attr("data-db-tier"), 10)
    areaId = parseInt($(this).attr("data-db-area"), 10)
    
    # Update current selected area
    self.areas[tierId] = areaId
    
    # Slice off more specific selections
    self.areas = self.areas.slice(0, tierId + 1)
    tier.find(".db-area-col").css({"opacity":"1"}).end().find("[data-db-area=" + areaId + "]").css {"opacity":"0.5"}
    self.drawTier tierId + 1
    
    # Hide old tiers
    self.$e.find(".db-tier").each ->
      $(this).hide()  if $(this).attr("data-db-tier") > tierId + 1

    
    # Simulate a click so that auto resize can happen on
    # wheredoesmymoneygo.com. Sadly custom events won't work here, and only
    # click appears to do the trick.
    $(self.$e).click()

  @setData = (data) ->
    self.data = data

  @setDataFromAggregator = (data, skip) ->
    handleChildren = (node, absolute) ->
      _.map _.filter(node.children, (child) ->
        _.indexOf skip, child.name
      ), (child) ->
        daily = (child.amount / node.amount)
        #daily = daily / 365.0  if absolute
        [child.name, child.label, daily, handleChildren(child, false)]


    self.setData handleChildren(data, true)

  @setIconLookup = (lookup) ->
    self.iconLookup = lookup

  @setSalary = (salary) ->
    self.salaryVal = salary

  @getTaxVal = ->
    @taxVal = 80000

  @draw = (sliderUpdate) ->
    _draw = ->
      self.drawTotals()
      if self.tiers.length is 0
        self.drawTier 0, sliderUpdate
      else
        i = 0
        tot = self.tiers.length

        while i < tot
          self.drawTier i, sliderUpdate
          i += 1

    taxUndef = (typeof self.taxVal is "undefined" or not self.taxVal?)
    if taxUndef => self.getTaxVal()
    _draw()

  @drawTotals = ->
    $('#db-salary p').text @formatCurrency(self.salaryVal, 0)
    $('#db-tax p').text @formatCurrency(self.taxVal, 0)

  @drawTier = (tierId, sliderUpdate) ->
    tdAry = self.taxAndDataForTier(tierId)
    return  unless tdAry # No child tier for selected area.
    tax = tdAry[0]
    data = tdAry[1]
    t = self.tiers[tierId] = self.tiers[tierId] or $("<div class='db-tier' data-db-tier='" + tierId + "'></div>").appendTo(self.$e)
    data = data.sort (a,b) -> b.2 - a.2
        .slice(0, 10)
    n = data.length
    w = 100.0 / n
    icons = _.map(data, (d) ->
      self.iconLookup d[0]
    )
    unless sliderUpdate
      tpl = "<div class='db-area-row'>" + "<% _.each(areas, function(area, idx) { %>" + "  <div class='db-area-col db-area-title' style='width: <%= width %>%;' data-db-area='<%= idx %>'>" + "    <h3><%= area[1] %></h3>" + "  </div>" + "<% }); %>" + "</div>" + "<div class='db-area-row'>" + "<% _.each(areas, function(area, idx) { %>" + "  <div class='db-area-col' style='width: <%= width %>%;' data-db-area='<%= idx %>'>" + "    <div class='db-area-icon' data-svg-url='<%= icons[idx] %>'></div>" + "    <div class='db-area-value'></div>" + "  </div>" + "<% }); %>" + "</div>"
      t.html _.template(tpl,
        activeArea: self.areas[tierId]
        areas: data
        width: w
        icons: icons
      )
      self.drawIcons t
    
    # Update values
    valEls = t.find(".db-area-value")
    _.each data, (area, idx) ~>
      valEls.eq(idx).text @formatCurrency(tax * area[2], 2)

    t.show()

  @taxAndDataForTier = (tierId) ->
    data = self.data
    tax = self.taxVal
    areaId = void
    i = 0
    tot = tierId

    while i < tierId
      areaId = self.areas[i]
      if data[areaId]
        tax = tax * data[areaId][2]
        data = data[areaId][3]
      else
        return null
      i += 1
    [tax, data]

  @drawIcons = (t) ->
    iconRad = 35
    $(".db-area-icon svg", t).remove()
    $(".db-area-icon", t).each (i, e) ->
      iconUrl = void
      paper = void
      iconUrl = $(e).data("svg-url")
      paper = Raphael(e, iconRad + iconRad, iconRad + iconRad + 5)
      paper.circle(iconRad, iconRad, iconRad).attr do
        fill: '#830242'
        stroke: "none"

      paper.circle(iconRad, iconRad, iconRad - 2).attr do
        fill: "none"
        stroke: '#eee'
        opacity: 0.8
        "stroke-dasharray": "- "

      $.get iconUrl, (svg) ->
        if typeof (svg) is "string"
          svg = $(svg)
          svg = svg[svg.length - 1]
        return  unless svg.getElementsByTagName
        j = void
        icon = void
        joined = ""
        paths = svg.getElementsByTagName("path")
        j = 0
        while j < paths.length
          joined += paths[j].getAttribute("d") + " "
          j++
        icon = paper.path(joined)
        icon.attr do
          fill: "white"
          stroke: "none"

        icon.scale iconRad / 50, iconRad / 50, 0, 0



  @init()
  this
