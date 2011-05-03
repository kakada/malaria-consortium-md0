$(document).ready(function() {
        window.selectedRow = null;

        //validate createusers form
	$("#createusers").validate(validateOption());
        $("#formUserDir").validate(validateOption("_dir"));
        addRoleChange();
        addRoleChange("_dir");

        //submit data to the server only if there are record in the table
        $("#createusers").submit(function(){
           return $("#bodyRow tr").length > 1
        });

	makeEditSubmitable();
	$("#addMoreUser").click(function(){
		addRow();
        });

	$('#createusers .input').blur(function(){
		$('#phone_number').valid();
	});

	$('.removeRow').each(function(){
		addClickTo(this);
	});


        /* lightbox */
        $(".editRow").each(function(){
           $(this).click(function(){
              window.selectedRow = this.rel;
              window.editTr = this.parentNode.parentNode.parentNode ;

              var rows = $("#editDirFancy").get(0);
              $("#user_name_dir").val(editTr.children[0].children[0].value);
              rows.children[0].children[1].children[1].innerHTML = '<label for="user_name_dir" generated="true"  class="error" >' + editTr.children[0].children[2].innerHTML +"</label>";

              $("#email_dir").val(editTr.children[1].children[0].value);
              rows.children[1].children[1].children[1].innerHTML ='<label for="email_dir" generated="true" class="error" >' + editTr.children[1].children[2].innerHTML +"</label>";

              $("#password_dir").val(editTr.children[2].children[0].value);
              rows.children[2].children[1].children[1].innerHTML = '<label for="password_dir" generated="true" class="error" >' + editTr.children[2].children[2].innerHTML +"</label>";

              $("#phone_number_dir").val(editTr.children[3].children[0].value);
              rows.children[3].children[1].children[1].innerHTML ='<label for="phone_number_dir" generated="true"  class="error" >' +  editTr.children[3].children[2].innerHTML +"</label>";

              $("#place_code_dir").val(editTr.children[4].children[0].value);
              rows.children[4].children[1].children[1].innerHTML ='<label for="place_code_dir" generated="true" class="error">' + editTr.children[4].children[2].innerHTML +"</label>";

              $("#role_dir").val(editTr.children[5].children[0].value);
              rows.children[5].children[1].children[1].innerHTML ='<label for="role_dir" generated="true" class="error">' + editTr.children[5].children[2].innerHTML +"</label>";


            });
        });
        $(".editRow").fancybox({
            'scrolling'		: 'no',
            'titleShow'		: false,
            'autoScale'         : true,
            'onClosed'		: function() {
                window.selectedRow = null;
            },
            "onComplete": function(){
                var labels = $("#formUserDir label.error");
                var forcusSet = false;
                for(var i= 0 ; i< labels.length; i++){
                    if(labels[i].innerHTML == ""){
                        labels[i].style.display = "none";
                    }
                    else{ //set forcus on error component
                          if(!forcusSet){ // if a comp is set then other is being set then it will fire the onblur event. we dont want that
                            labels[i].parentNode.parentNode.children[0].focus();
                            forcusSet = true
                          }
                    }
                }
            }

	});

        $("#editFormSubmit").click(function(){
            validateEditForm();
            return false;
        });
});

jQuery.validator.addMethod("no_duplicates", function(value, element) {
	var already_exists = false;
        var hiddenElement = element.id;
        var pos = hiddenElement.indexOf("_dir")
        if( pos !=-1){
            hiddenElement = hiddenElement.substring(0,pos);
        }
        var path = ':hidden[name *= ' + hiddenElement + ']';
	$(path).each(function(index){
            if(index != selectedRow){
                if ($(this).val() == value){
                        already_exists = true;
                }
            }
	});
    return value == '' || !already_exists;
}, "Has already been taken");


function addRow() {
	if ($('#createusers').valid()) {
            validateUser();
	}
}
function insertRowTable(){
    var name = $("#user_name").val();
    var email = $("#email").val();
    var password = $("#password").val();
    var phone = $("#phone_number").val();
    var place_code = $("#place_code").val();
    var role = $("#role").val();


    var icon = '<div style="float:right;"><img src="/images/trash.png" alt="Remove" title="Remove" class="clickable removeRow"/></div>';

    var tr = "<tr>" +
             "<td><input type='hidden' name='user[user_name][]' value='" + name + "' /> <span>" + name +  "</span> </td>" +
             "<td><input type='hidden' name='user[email][]' value='" + email + "' /></span> " + email + "</span> </td>" +
             "<td><input type='hidden' name='user[password][]' value='" + password + "' /><span> " + showPwd(password) + "</span> </td>" +
             "<td><input type='hidden' name='user[phone_number][]' value='"+ phone + "' /></span>" + phone + "</span></td>" +
             "<td><input type='hidden' name='user[place_code][]' value='" + place_code  + "' /></span>" + place_code + "</span></td>" +
             "<td><input type='hidden' name='user[role][]' value='" + role  + "' /></span>" + role + "</span></td>" +
             "<td>" + icon + "</td>" +
             "</tr>" ;

    var tr_new = $(tr);
    tr_new.insertBefore($("#inputRow"));
    addIconClick();
}

function validateEditForm(){
    if($('#formUserDir').valid()){
       validateUser("_dir");
    }
}

function makeEditSubmitable(){
    $("#formUserDir .submitable").each(function(i){
       $(this).keypress(function(e){
           if(e.which ==13){
               validateEditForm();
               e.preventDefault();
           }


       })
    });
}

function addClickTo(clickable){
	$(clickable).click(function(){
	   var tr = this.parentNode.parentNode.parentNode;
	   tr.parentNode.removeChild(tr);
	});
}

function addRoleChange(suffix){

    suffix = suffix? suffix: "";
    var id = "#role"+ suffix ;
    $(id).change(function(){
        var value = $(this).val();
        if( value == "default"){
          $("#place_code" + suffix)[0].disabled = false;
        }
        else if( value == "admin" || value =="national" ){
             $("#place_code" + suffix)[0].disabled = true;
             $("#place_code" + suffix).val("");
        }

    });
}

function addIconClick() {
	var removeIcon = $(".removeRow");
	var last = removeIcon.length;
	var removeIconElm = removeIcon.get(last - 1);
	addClickTo(removeIconElm);

        $(".editRow").each(function(i){

        });
}

function showPwd(pwd) {
	var str = "";
	for (var i = 0; i < pwd.length; i++) str += "*" ;
	return str;
}

function validateOption(suffix ){
     suffix = suffix ? suffix : "";
     rules = {};
     rules["user_name" + suffix] = {
         required: function(element) { return $('#phone_number' + suffix ).val().length == 0},
         no_duplicates: true
     }

     rules["password"+ suffix] = {
				required: function(element) {return $('#phone_number' + suffix).val().length == 0}
			};

     rules["email" + suffix] = {
				required: function(element) {return $('#phone_number' + suffix).val().length == 0},
				email: true,
				no_duplicates: true
			};
     rules["phone_number"] = {
				required: function(element) {return $('#user_name' + suffix).val().length == 0 || $('#password' + suffix ).val().length == 0 || $('#email' + suffix ).val().length == 0},
				number: true,
				no_duplicates: true
			};




    messages = {};
    messages["user_name" + suffix] = { required: "Required unless you provide a phone number" };
    messages["email" + suffix] =  { required: "Required unless you provide a phone number" };
    messages["password"+ suffix] =  { required: "Required unless you provide a phone number" };
    messages["phone_number" + suffix] = { required: "Required unless you provide a username, email and password" }
    messages["place_code" + suffix] = { required: "Required unless user is an admin or national" };
    return  {
                "rules" : rules,
		"messages": messages,
		errorPlacement: function(error, element) {
                    error.appendTo(element.next());
                },
                onsubmit: false
	}
}
function validateUser(suffix){
    //suffix = "_dir";
    suffix = (suffix)?suffix:""
    var params = {}

    params["user_name"] = $("#user_name" + suffix ).val();
    params["email"] = $("#email" + suffix ).val();
    params["phone_number"] = $("#phone_number" + suffix ).val();
    params["password"] = $("#password" + suffix ).val();
    params["place_code"] = $("#place_code" + suffix ).val();
    params["role"] = $("#role" + suffix ).val();


    $($("#formUserDir").serializeArray()).each(function(i,elm){
        pos = elm["name"].indexOf(suffix);
        name = elm["name"].substr(0,pos);
        params[name] = elm["value"];
    });

    $.ajax({
      url: "/users/validate",
      data: $.param(params),
      dataType: "json",
      success: function(errors){
        var found = false
        for(name in errors ){
           if(name=="intended_place_code")
               id = "place_code" + suffix;
           else
                id = name + suffix;

           var divError = $("#"+id).get(0).parentNode.children[1];
           if(divError.children.length){
               divError.children[0].innerHTML = errors[name];
               divError.children[0].style.display = "block";
           }
           else{
               divError.innerHTML = "<label for='" + name + suffix + "' generated='true' class='error'>" + errors[name] + "</label>";
           }
           found = true;
        }
        if(found==false){
            if(suffix)
                setTableRow();
            else
                insertRowTable();
        }

      }
});
}
function setTableRow(){
   editTr.children[0].children[0].value = $("#user_name_dir").val();
   editTr.children[0].children[1].innerHTML = $("#user_name_dir").val();
   editTr.children[0].children[2].innerHTML="";

   editTr.children[1].children[0].value = $("#email_dir").val();
   editTr.children[1].children[1].innerHTML = $("#email_dir").val();
   editTr.children[1].children[2].innerHTML="";

   editTr.children[2].children[0].value = $("#password_dir").val();
   editTr.children[2].children[1].innerHTML =showPwd($("#password_dir").val());
   editTr.children[2].children[2].innerHTML="";

   editTr.children[3].children[0].value = $("#phone_number_dir").val();
   editTr.children[3].children[1].innerHTML = $("#phone_number_dir").val();
   editTr.children[3].children[2].innerHTML="";

   editTr.children[4].children[0].value = $("#place_code_dir").val();
   editTr.children[4].children[1].innerHTML = $("#place_code_dir").val();
   editTr.children[4].children[2].innerHTML="";

   editTr.children[5].children[0].value = $("#role_dir").val();
   editTr.children[5].children[1].innerHTML = $("#role_dir").val();
   editTr.children[5].children[2].innerHTML="";
   parent.$.fancybox.close();
}
