function loading(container,message){
       if(typeof container == "undefined" || !container )
           container = document.body
       var containner = $(container);

       var loading = $("#ajax_loading")
       if(typeof message == "undefined" || !message)
           loading.html("Waiting for server response");
       else
           loading.html(message);
       
       var pos =  containner.offset();

       var loading_width = loading.width();
       var loading_height= loading.height();

       var width = containner.width();
       var height = containner.height();

       var top = pos.top + (height/2) -(loading_height/2) + "px" ;
       var left = pos.left + (width/2) -(loading_width/2) + "px" ;
       $("#ajax_loading").css("left",left);
       $("#ajax_loading").css("top",top);
       $("#ajax_loading").show();
       return $("#ajax_loading");
}