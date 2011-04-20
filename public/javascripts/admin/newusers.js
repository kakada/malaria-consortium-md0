$(document).ready(function() {
	$("#createusers").validate({
		rules: {
			user_name: {
				required: true
			   },
			email: {
				email: true
			},
			password: {
				required: true
			},
			phone_number: {
				number: true
			},
			place_code: {
				number: true
			}
		},
		errorPlacement: function(error, element) { 
            error.appendTo(element.next()); 
        },
	})
});

$(function() {
    $("#addMoreUser").click(function(){	
      addRow();
    });
  })

  function addRow() {
     var name = $("#user_name").val();
     var email = $("#email").val();
     var password = $("#password").val();
     var phone = $("#phone_number").val();
     var place_code = $("#place_code").val();

     var icon = '<div style="float:right;" > <%= image_tag "trash.png",:alt=>"Remove",:title=>"Remove", :class=>"clickable removeRow" %></div> ';

     var tr = "<tr>" +
              "<td><input type='hidden' name='admin[user_name][]' value='" + name + "' /> " + name +  " </td>" +
              "<td><input type='hidden' name='admin[email][]' value='" + email + "' /> " + email + " </td>" +
              "<td><input type='hidden' name='admin[password][]' value='" + password + "' /> " + showPwd(password) + " </td>" +
              "<td><input type='hidden' name='admin[phone_number][]' value='"+ phone + "' />" + phone + "</td>" +
              "<td><input type='hidden' name='admin[place_code][]' value='" + place_code  + "' />" + place_code + icon + "</td>" +
              "</tr>" ;

     var tr_new = $(tr);
     tr_new.insertBefore($("#sourceRow"));     
     addIconClick();
  }

  function addIconClick() {
    var clickable = $(".removeRow");
    var last = clickable.length;
    var clickable_new = clickable.get(last-1);

    $(clickable_new).click(function(){
       var tr = this.parentNode.parentNode.parentNode;
       tr.parentNode.removeChild(tr);
    });
  }

  function showPwd(pwd) {
    var str = "";
    for (var i = 0; i < pwd.length; i++) str += "*" ;
    return str;
  }