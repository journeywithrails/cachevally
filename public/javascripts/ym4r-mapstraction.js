function addCodeToFunction(func,code){
    if(func == undefined)
	return code;
    else{
	return function(){
	    func();
	    code();
	}
    }
}

function addDataToMarker(marker,options){
    if(options.label)
	marker.setLabel(options.label);
    if(options.infoBubble)
	marker.setInfoBubble(options.infoBubble);
    if(options.icon)
	marker.setIcon(options.icon);
    if(options.infoDiv)
	marker.setInfoDiv(options.infoDiv[0],options.infoDiv[1]);
    return marker;
}


//For full screen mode
function setWindowDims(elem) {
    if (window.innerWidth){
	elem.style.height = (window.innerHeight) + "px;";
	elem.style.width = (window.innerWidth) + "px;";
    }else if (document.body.clientWidth){
	elem.style.height = (document.body.clientHeight) + "px";
	elem.style.width = (document.body.clientWidth) + "px";
    }
}

//MarkerGroup
//Method to add and remove marker group to a Mapstraction map

Mapstraction.prototype.addMarkerGroup = function(markerGroup){
    markerGroup.initalize(this);
}

Mapstraction.prototype.removeMarkerGroup = function(markerGroup){
    markerGroup.hide();
}

function MarkerGroup(markers,visible){
    this.visible = visible == undefined ? true : visible;
    this.markers = markers;
}

MarkerGroup.prototype.initalize = function(map){
    this.map = map;
    if(this.visible){
	for(var i = 0 , len = this.markers.length; i < len; i++){
	    this.map.addMarker(this.markers[i]);
	}
    }
}

MarkerGroup.prototype.show = function(){
    if(!this.visible){
	if(this.map != undefined){
	    for(var i = 0 , len = this.markers.length; i < len; i++){
		this.map.addMarker(this.markers[i]);
	    }
	}
	this.visible = true;
    }
}

MarkerGroup.prototype.hide = function(){
    if(this.visible){
	if(this.map != undefined){
	    for(var i = 0 , len = this.markers.length; i < len; i++){
		this.map.removeMarker(this.markers[i])
	    }
	}
	this.visible = false;
    }
}

MarkerGroup.prototype.toggle = function(){
    if(this.visible){
	this.hide();
    }else{
	this.show();
    }
}


