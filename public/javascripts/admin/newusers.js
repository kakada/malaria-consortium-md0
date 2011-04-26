$(document).ready(function() {
        //window
        window.selectedRow = null;
        
        //validate createusers form
	$("#createusers").validate({
		rules: {
			user_name: {
				required: function(element) {return $('#phone_number').val().length == 0},
				no_duplicates: true
			},
			password: {
				required: function(element) {return $('#phone_number').val().length == 0},
			},
			email: {
				required: function(element) {return $('#phone_number').val().length == 0},
				email: true,
				no_duplicates: true
			},
			phone_number: {
				required: function(element) {return $('#user_name').val().length == 0 || $('#password').val().length == 0 || $('#email').val().length == 0},
				number: true,
				no_duplicates: true
			},
			place_code: {
				number: true
			}
		},
		messages: {
			user_name: {
				required: "Required unless you provide a phone number"		
			},
			email: {
				required: "Required unless you provide a phone number"		
			},
			password: {
				required: "Required unless you provide a phone number"		
			},
		   	phone_number: {
				required: "Required unless you provide a username, email and password"		
			}		
		},
		errorPlacement: function(error, element) { 
                    error.appendTo(element.next());
                },
                onsubmit: false
	});




        $("#formUserDir").validate({
		rules: {
			user_name_dir: {
				required: function(element) {return $('#user_name_dir').val().length == 0},
				no_duplicates: true
			},
			password_dir: {
				required: function(element) {return $('#phone_number_dir').val().length == 0},
			},
			email_dir: {
				required: function(element) {return $('#phone_number_dir').val().length == 0},
				email: true,
				no_duplicates: true
			},
			phone_number_dir: {
				required: function(element) {return $('#user_name_dir').val().length == 0 || $('#password_dir').val().length == 0 || $('#email_dir').val().length == 0},
				number: true,
				no_duplicates: true
			},
			place_code_dir: {
				number: true
			}
		},
		messages: {
			user_name_dir: {
				required: "Required unless you provide a phone number"
			},
			email_dir: {
				required: "Required unless you provide a phone number"
			},
			password_dir: {
				required: "Required unless you provide a phone number"
			},
		   	phone_number_dir: {
				required: "Required unless you provide a username, email and password"
			}
		},
		errorPlacement: function(error, element) {
                                error.appendTo(element.next());
                },
	   onsubmit: false
	});




		
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
           });
        });
        $(".editRow").fancybox({
            'scrolling'		: 'no',
            'titleShow'		: false,
            'autoScale'         : true,
            'onClosed'		: function() {
                window.selectedRow = null;
            },
            "onStart": function(){
                $("label.error").each(function(i){
                    if(this.innerHTML == ""){
                        this.style.display = "none";
                    }
                });
            }
            
	});

        $("#editFormSubmit").click(function(){
            if($('#formUserDir').valid()){
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
               parent.$.fancybox.close();
            }
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
            console.log("element: " + hiddenElement +  "index: " + index + " selected: " + selectedRow );

            if(index != selectedRow){
                if ($(this).val() == value){
                        already_exists = true;
                }
            }
	});
    return value == '' || !already_exists;
}, "Has already been taken");

function updateRow(){
    
}

function addRow() {
	if ($('#createusers').valid()) {	
		var name = $("#user_name").val();
		var email = $("#email").val();
		var password = $("#password").val();
		var phone = $("#phone_number").val();
		var place_code = $("#place_code").val();

		var icon = '<div style="float:right;"><img src="/images/trash.png" alt="Remove" title="Remove" class="clickable removeRow"/></div>';

		var tr = "<tr>" +
		         "<td><input type='hidden' name='admin[user_name][]' value='" + name + "' /> <span>" + name +  "</span> </td>" +
		         "<td><input type='hidden' name='admin[email][]' value='" + email + "' /></span> " + email + "</span> </td>" +
		         "<td><input type='hidden' name='admin[password][]' value='" + password + "' /><span> " + showPwd(password) + "</span> </td>" +
		         "<td><input type='hidden' name='admin[phone_number][]' value='"+ phone + "' /></span>" + phone + "</span></td>" +
		         "<td><input type='hidden' name='admin[place_code][]' value='" + place_code  + "' /></span>" + place_code + "</span></td>" +
		         "<td>" + icon + "</td>" +			
		         "</tr>" ;

		var tr_new = $(tr);
		tr_new.insertBefore($("#inputRow"));     
		addIconClick();
	}
}

function addClickTo(clickable){
	$(clickable).click(function(){
	   var tr = this.parentNode.parentNode.parentNode;
	   tr.parentNode.removeChild(tr);
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