var msg =""
$(function(){
    $("a.editRow").click(function(e){
      var url = $(this).attr("data-url");
      var id  = $(this).attr("data-rel");
      $.ajax({
          url: url,
          method: "get",
          success: function(responseText, status, responseObj){
             $("#tr_"+ id ).html(responseText);
             showNotice();
          }
      });

      e.preventDefault();
      return false;
    });
 });

function showNotice(){
   $("#div_notice").html(msg);
   console.log(msg);
 }