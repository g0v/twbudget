$("#treemap-backbtn").hide();
function setdebit(v) {
  var debit = $("#debitmask");
  debit.css({"top": v+"px", "height": (520-v)+"px", "line-height": (520-v)+"px"});
  debit.text(v+"億");
}
setdebit(123);
var w = 680 - 80,
    h = 700 - 180,
    x = d3.scale.linear().range([0, w]),
    y = d3.scale.linear().range([0, h]),
    color = d3.scale.category20c(),
    root,
    node;

var treemap = d3.layout.treemap()
    .round(false)
    .size([w, h])
    .sticky(true)
    .value(function(d) { return d.size; });

var svg = d3.select("#treemap-root").append("div")
    .attr("class", "budget-treemap")
    .style("width", w + "px")
    .style("height", h + "px")
  .append("svg:svg")
    .attr("width", w)
    .attr("height", h)
  .append("svg:g")
    .attr("transform", "translate(.5,.5)");


function foo(data) {
  node = root = data;

  var nodes = treemap.nodes(root)
      .filter(function(d) { return !d.children; });
  var lastcell = null;
  var lockcell = null;
  var cell = svg.selectAll("g")
      .data(nodes)
    .enter().append("svg:g")
      .attr("class", "cell")
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })
      .on("mouseover", function(d) { 
         var i;
         if(lockcell || d==lastcell) return; else lastcell=d;
         $("#budget-detail-depname-field").text(d.name);
         $("#budget-detail-amount-field").text(((d.size/100000000)|0)+"億");
         $("#budget-detail-category-field").text(d.cat);
         var scope = angular.element("#BudgetItem").scope()
         scope.$apply(function() { scope.key="view3:"+d.cat+":"+d.name; });
      })
      .on("click", function(d) { 
         for(i in this) console.log(i);
         console.log($(this).find("rect").css("stroke:#000"));
         if(lockcell && lockcell.find) lockcell.find("rect").css({"stroke": "none"});
         if(!lockcell || lockcell.get(0)!=$(this).get(0)) {
           $(this).find("rect").css({"stroke": "rgb(255,0,0)"});
           lockcell = $(this);
           $("#budget-detail-depname-field").text(d.name);
           $("#budget-detail-amount-field").text(((d.size/100000000)|0)+"億");
           $("#budget-detail-category-field").text(d.cat);
           var scope = angular.element("#BudgetItem").scope()
           scope.$apply(function() { scope.key="view3:"+d.cat+":"+d.name; });
         } else { lockcell=null; }
         if(node!=d.parent) {
           $("#treemap-backbtn").fadeIn("slow");
           if(lockcell==null) lockcell = d;
           return zoom(d.parent);
         } else {
           //if(d.name==lockcell.name) { lockcell = null; return zoom(root); }
           //else lockcell = d;
         }
         //return zoom(node == d.parent ? root : d.parent);
      });



  cell.append("svg:rect")
      .attr("width", function(d) { return (d.dx>1?d.dx - 1:0); })
      .attr("height", function(d) { return (d.dy>1?d.dy - 1:0); })
      .style("fill", function(d) { return color(d.parent.name); });

  cell.append("svg:text")
      .attr("class", "name")
      .attr("x", function(d) { return d.dx / 2; })
      .attr("y", function(d) { return d.dy / 2-7; })
      .attr("dy", ".35em")
      .attr("text-anchor", "middle")
      .text(function(d) { return d.name; })
      .style("opacity", function(d) { 
         d.box = this.getBBox();
         d.w=this.getComputedTextLength();  
         return (d.dx>d.w) ? 1 : 0; });
  cell.append("svg:text")
      .attr("class", "amount")
      .attr("x", function(d) { return d.dx / 2; })
      .attr("y", function(d) { return d.dy / 2+7; })
      .attr("dy", ".35em")
      .attr("text-anchor", "middle")
      .text(function(d) { return ((parseInt(d.size)/1000000)|0)/100+"億"; })
      .style("opacity", function(d) { 
         d.box = this.getBBox();
         d.h = d.box.y + d.box.height
         d.w = this.getComputedTextLength();
         return (d.dx > d.w && d.h<d.dy)?1:0;
      });
  d3.select("#treemap-backbtn").on("click",function() { zoom(root); $("#treemap-backbtn").fadeOut("slow"); });

  d3.select("select").on("change", function() {
    treemap.value(this.value == "size" ? size : count).nodes(root);
    zoom(node);
  });
};
function size(d) {
  return d.size;
}

function count(d) {
  return 1;
}

var dx = 0;
function zoom(d) {
  var kx = w / d.dx, ky = h / d.dy;
  x.domain([d.x, d.x + d.dx]);
  y.domain([d.y, d.y + d.dy]);

  var t = svg.selectAll("g.cell").transition()
      .duration(d3.event.altKey ? 7500 : 750)
      .attr("transform", function(d) { return "translate(" + x(d.x) + "," + y(d.y) + ")"; });

  t.select("rect")
      .attr("width", function(d) { return (kx*d.dx>1?kx * d.dx - 1:0); })
      .attr("height", function(d) { return (ky*d.dy>1?ky * d.dy - 1:0); })

  t.select("text.name")
      .attr("x", function(d) { return kx * d.dx / 2; })
      .attr("y", function(d) { return ky * d.dy / 2 - 7; })
      .style("opacity", function(d) { return (kx * d.dx > this.getBBox().width) ? 1 : 0; });

  t.select("text.amount")
      .attr("x", function(d) { return kx * d.dx / 2; })
      .attr("y", function(d) { return ky * d.dy / 2 + 7; })
      .style("opacity", function(d) { 
         var bbox = this.getBBox();
         return (kx*d.dx > d.w && ky*d.dy > d.h ? 1 : 0);
      });

  node = d;
  d3.event.stopPropagation();
}

foo(parse(raw));
