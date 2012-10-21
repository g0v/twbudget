var ret = {};
var category = {};
var depname = {};
var ret = {};
var dep, cat, val;
function add(root, list, idx, value) {
 if(!root["childhash"]) root.childhash = {};
 if(!root.childhash[list[idx]]) root.childhash[list[idx]] = {};
 if(idx<list.length-1) add(root.childhash[list[idx]], list, idx+1, value);
 else {
   root.childhash[list[idx]].value = value;
   root.childhash[list[idx]].cat = list[0];
 }
}
function reorg(node, child) {
  var i,n;
  node.children = [];
  for(i in child) {
    n = {"name": i, "size": child[i]["value"], "cat": child[i]["cat"]};
    if(child[i]["childhash"]) reorg(n, child[i].childhash);
    node.children.push(n);
  }
}
function dump(tag, node, level) {
  tag.innerHTML += ("<div style='margin-left:"+(level*20)+"px;'>"+node.name+" "+(node.children?"":node.value)+"</div>");
  for(i in node.children) {
    dump(node.children[i], level+1);
  }
}

function parse(data) {
  var retval = {"name": "root"};
  for(i in data.drilldown) {
    cat = data.drilldown[i].cat;
    dep = data.drilldown[i].depname;
    val = data.drilldown[i].amount;
    add(ret, [cat,dep], 0, val);
  }
  reorg(retval, ret.childhash);
  //dump(retval, 1);
  return retval;
}
