function CustomTooltip(tooltipId, width){
	var tooltipId = tooltipId;
        var positionFixed = false;
	$("body").append("<div class='tooltip' id='"+tooltipId+"'></div>");
	
	if(width){
		$("#"+tooltipId).css("width", width);
	}
	
	hideTooltip();
	
	function showTooltip(content, event){
		$("#"+tooltipId).html(content);
		$("#"+tooltipId).show();
		
		if(event) updatePosition(event);
	}
	
	function hideTooltip(){
		if(!positionFixed) $("#"+tooltipId).hide();
	}
	
	function updatePosition(event){
		var ttid = "#"+tooltipId;
		var xOffset = 20;
		var yOffset = 10;
		
		 var ttw = $(ttid).width();
		 var tth = $(ttid).height();
		 var wscrY = $(window).scrollTop();
		 var wscrX = $(window).scrollLeft();
		 var curX = (document.all) ? event.clientX + wscrX : event.pageX;
		 var curY = (document.all) ? event.clientY + wscrY : event.pageY;
		 var ttleft = ((curX - wscrX + xOffset*2 + ttw) > $(window).width()) ? curX - ttw - xOffset*2 : curX + xOffset;
		 if (ttleft < wscrX + xOffset){
		 	ttleft = wscrX + xOffset;
		 } 
		 var tttop = ((curY - wscrY + yOffset*2 + tth) > $(window).height()) ? curY - tth - yOffset*2 : curY + yOffset;
		 if (tttop < wscrY + yOffset){
		 	tttop = curY + yOffset;
		 } 
		 if(!positionFixed) $(ttid).css('top', tttop + 'px').css('left', ttleft + 'px');
	}

        function fixPosition(fixed,parent) {
		positionFixed = fixed;
		var node = $("#"+tooltipId);
		node.remove();
		if(fixed) {
			node.css({top:"0px",left:"0px",width:"100%",height:"100%"});
			parent.append(node);
			showTooltip();
                } else {
			node.css({top:"0px",left:"0px",width:"auto",height:"auto"});
			$(document.body).append(node);
			hideTooltip();
		}
        }
	
	return {
		showTooltip: showTooltip,
		hideTooltip: hideTooltip,
		updatePosition: updatePosition,
                fixPosition: fixPosition
	}
}
