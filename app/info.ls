InfoPanel = 
  setState: (s) ->
    @state = s
    if s==1 then
      d3.select \#bubble-info-right .transition! .duration 750 .style \opacity 0.0
      d3.select \#bubble-info-right .transition! .delay 750 .style \display \none
      d3.select \#bubble-info .transition! .duration 750 .style \width \360px .style \opacity 1.0 .style \margin-right \-100px
      d3.select \#bubble-info .transition! .ease -> 1
        .delay 750 .style \position \absolute .style \left \5px .style \margin-left \0 .style \top \55px .style \z-index -1
      d3.select \#bubble-info-close .transition! .duration 750 .style \opacity 0.0
    if s==2 then
      d3.select \#bubble-info .style \z-index -1 .transition! .duration 475 .style \opacity 0.2
      d3.select \#bubble-info-right .style \display \block
      d3.select \#bubble-info-right .transition! .duration 750 .style \opacity 1.0
      d3.select \#bubble-info .transition! .duration 750 .style \width \994px .style \opacity 0.2
      d3.select \#bubble-info-close .transition! .duration 750 .style \opacity 1.0 .style \margin-right \0px
      d3.select \#bubble-info .transition! .ease -> 1
        .delay 750 .style \position \fixed .style \left \50% .style \margin-left \-497px .style \top \107px .style \z-index -1
    if s==3 then
      d3.select \#bubble-info .style \z-index,100 .transition! .duration 475 .style \opacity 0.9 
      d3.select \#bubble-info-right .style \display \block
      d3.select \#bubble-info-right .transition! .duration 750 .style \opacity 1.0
      d3.select \#bubble-info .transition! .duration 750 .style \width \994px .style \opacity 0.9
      d3.select \#bubble-info-close .transition! .duration 750 .style \opacity 1.0 .style \margin-right \0px
      #d3.select \#bubble-info .transition! .ease -> 1
      #  .delay 750 .style \position \fixed .style \left \50% .style \margin-left \-497px .style \top \107px .style \z-index -1
