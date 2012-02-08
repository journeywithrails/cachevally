//
// google.js
// Google Highlighter
//
// Copyright(C)2001 - 2003
// Cal Henderson <cal@iamcal.com>
//
// Thanks to Ian Beveridge for bugfixes
//
// This code may be freely redistributed,
// providing this message remains intact.
//

//Script featured on & available at Dynamic Drive (http://www.dynamicdrive.com)
//Changes: Modification to window.onload code

var google_text_color = '#000000';

var google_link_colors = new Array('#ffff66','#a0ffff','#99ff99','#ff9999','#ff66ff');

function init_google(){
	var pattern = /google\./i;
	if (pattern.exec(document.referrer) != null){
		var url_parts = document.referrer.split('?');
		if (url_parts[1]){ 
			var url_args = url_parts[1].split('&');
			for(var i=0; i<url_args.length; i++){
				var keyval = url_args[i].split('=');
				if (keyval[0] == 'q'){
					go_google(decode_url(keyval[1]));
					return;
				}
			}
		}
	}
}

function decode_url(url){
	return unescape(url.replace(/\+/g,' '));
}

function go_google(terms){
	terms = terms.replace(/\"/g,"");
	var terms_split = terms.split(' ');
	var c = 0;
	for(var i=0; i<terms_split.length; i++){
		highlight_goolge(terms_split[i], document.body,google_link_colors[c]);
		c = (c == google_link_colors.length-1)?0:c+1;
	}
}

function highlight_goolge(term, container, color){
	var term_low = term.toLowerCase();

	for(var i=0; i<container.childNodes.length; i++){
		var node = container.childNodes[i];

		if (node.nodeType == 3){
			var data = node.data;
			var data_low = data.toLowerCase();
			if (data_low.indexOf(term_low) != -1){
				//term found!
				var new_node = document.createElement('SPAN');
				node.parentNode.replaceChild(new_node,node);
				var result;
				while((result = data_low.indexOf(term_low)) != -1){
					new_node.appendChild(document.createTextNode(data.substr(0,result)));
					new_node.appendChild(create_node_google(document.createTextNode(data.substr(result,term.length)),color));
					data = data.substr(result + term.length);
					data_low = data_low.substr(result + term.length);
				}
				new_node.appendChild(document.createTextNode(data));
			}
		}else{
			//recurse
			highlight_goolge(term, node, color);
		}
	}
}

function create_node_google(child, color){
	var node = document.createElement('SPAN');
	node.style.backgroundColor = color;
	node.style.color = google_text_color;
	node.appendChild(child);
	return node;
}

if (window.addEventListener)
window.addEventListener("load", init_google, false)
else if (window.attachEvent)
window.attachEvent("onload", init_google)
else if (document.getElementById)
window.onload=init_google
