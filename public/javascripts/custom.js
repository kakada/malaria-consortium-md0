function loading(container,message){
       var map = $(container);

       var loading = $("#ajax_loading")
       if(typeof message != "undefined")
           loading.html(message);
       else
           loading.html("Waiting for server response");
       
       var pos =  map.offset();

       var loading_width = loading.width();
       var loading_height= loading.height();

       var width = map.width();
       var height = map.height();

       var top = pos.top + (height/2) -(loading_height/2) + "px" ;
       var left = pos.left + (width/2) -(loading_width/2) + "px" ;
       $("#ajax_loading").css("left",left);
       $("#ajax_loading").css("top",top);
       $("#ajax_loading").show();
       return $("#ajax_loading");
}