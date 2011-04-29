function getDynaAttribute(attr){
	return document.getElementById('dyna_attributes').getAttribute('data-' + attr);
}

$(document).ready(function(){
	var select = $('#alert_recipient_id');
	select.change(function(event){
		window.location = getDynaAttribute('refresh') + '?od_id=' + select.val();
	});	
	
	if (getDynaAttribute('blink') == 'true')	
		$('#alert_controls').effect("highlight", {}, 2000);
});
