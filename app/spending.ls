blah = ->
  OpenSpending.scriptRoot = \/openspendingjs
  OpenSpending.localeGroupSeparator = \,
  OpenSpending.localeDecimalSeparator = \.
  showspending 1
showspending = (type) ->
  <- jQuery.ajax do
    url: \/openspendingjs/widgets/treemap/main.js
    cache: true
    dataType: "script"
  .done
  dfd = new OpenSpending.Treemap $(\#bubbletree), do 
    dataset: \twbudget 
    siteUrl: \http://openspending.org
  , do
    drilldowns: <[cat depname]>
  <- dfd.done
