window.onpagehide = saveFormContents;

var formContents;

function saveFormContents(){
    if(document.getElementById("query-form")){
    formContents = new Object;
    formContents.fundortTitle = document.getElementById("textfield_fundort").value;
    formContents.fundortPlaceID = document.getElementById("place_id_fundort").value;
    formContents.verwahrortTitle = document.getElementById("textfield_verwahrort").value;
    formContents.verwahrortPlaceID = document.getElementById("place_id_verwahrort").value;
    formContents.antikerFundortTitle = document.getElementById("textfield_antikerfundort").value;
    formContents.antikerFundortPlaceID = document.getElementById("place_id_antikerfundort").value;

    window.onpageshow = restoreFormContents;
    }     
}

function restoreFormContents(){
    document.getElementById("textfield_fundort").value = formContents.fundortTitle;
    document.getElementById("place_id_fundort").value = formContents.fundortPlaceID;
    document.getElementById("textfield_verwahrort").value = formContents.verwahrortTitle;
    document.getElementById("place_id_verwahrort").value = formContents.verwahrortPlaceID;
    document.getElementById("textfield_antikerfundort").value = formContents.antikerFundortTitle;
    document.getElementById("place_id_antikerfundort").value = formContents.antikerFundortPlaceID;
}

function xreset(feldname) { 
    document.getElementById("place_id_" + feldname).value = "";
    document.getElementById("reset_img_" + feldname).style.display = "none";
    document.getElementById("textfield_" + feldname).removeAttribute("disabled");
    document.getElementById("textfield_" + feldname).focus();
    document.getElementById("textfield_" + feldname).select();
    document.getElementById("textfield_" + feldname).value = ""; 
}

$(document).ready(function() {
    var feldnamen = ["fundort","verwahrort","antikerfundort"];
    
    for (i=0; i<feldnamen.length; i++) {
        createAutoComplete(feldnamen[i]);
    }

    $(document).keypress(function (e){
        if(e.keyCode == 13){

            $('#query-form input[type=text]').each(function(){
                if(this.value.length>0){
                    e.preventDefault();
                    $('#query-form').submit();
                    return false;
                }
            });
        }
    });
 
    $("#query-form").submit(function(evt){
        var textfeldFundortValue = document.getElementById("textfield_fundort").value;
        var platzIDFundortValue = document.getElementById("place_id_fundort").value;
        if(platzIDFundortValue=="" && textfeldFundortValue.length>0){
            document.getElementById("textfield_fundort").style.color = "#ff0000";
            document.getElementById("textfield_fundort").select();
			//document.getElementById("textfield_fundort").updateSC();
            return false;
        }  

        var textfeldAntikerFundortValue = document.getElementById("textfield_antikerfundort").value;
        var platzIDAntikerFundortValue = document.getElementById("place_id_antikerfundort").value;
        if(platzIDAntikerFundortValue=="" && textfeldAntikerFundortValue.length>0){
            document.getElementById("textfield_antikerfundort").style.color = "#ff0000";
            document.getElementById("textfield_antikerfundort").select();
			//document.getElementById("textfield_antikerfundort").updateSC();
            return false;
        } 

        var textfeldVerwahrortValue = document.getElementById("textfield_verwahrort").value;
        var platzIDVerwahrortValue = document.getElementById("place_id_verwahrort").value;
        if(platzIDVerwahrortValue=="" && textfeldVerwahrortValue.length>0){
            document.getElementById("textfield_verwahrort").style.color = "#ff0000";
            document.getElementById("textfield_verwahrort").select();
			//document.getElementById("textfield_verwahrort").updateSC();
            return false;
        }  
    });

});


function createAutoComplete( feldname ) {
    $("#reset_img_" + feldname).click( function(){xreset(feldname)} )
    //var datatypecontrol = true;
    new autoComplete({
            selector: '#textfield_' + feldname,
            minChars: 1,
			cache: false,
            source: function(term, successHandler) {				
				$.ajax({
				    type: "GET",
				    url: "/queries/completions/finding_place",
					data: {"term": term},
				    dataType: "json",
					cache: false,
				    success: successHandler      
				});
            },
            renderItem: function (item, search){
                search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
                var re = new RegExp("(" + search.split(' ').join('|') + ")", "gi");

				var itemText = "";
				if (item.type) {
					if (item.type.includes("(")) {
					    itemText = " " + item.type;
					} else {
					    itemText = " (" + item.type + ")";
					} 
				}

                return '<div class="autocomplete-suggestion" data-title="' + item.title 
                    + '" data-id="' + item.id 
                    + '" data-path"' + item.path
                    + '" data-type="' + item.type
                    + '" data-val="' + search + '">'
                    + "<span id='outputtitle'>" + item.title.replace(re, "<b>$1</b>") + "</span>" + itemText + "<br> <span='outputpath'>" + item.path + "</span>"
                    + '</div>';
            },
            onSelect: function(e, term, item){
                var output = item.getAttribute('data-title');
                var output_id = item.getAttribute('data-id');
                var output_type = item.getAttribute('data-type');
                var output_path = item.getAttribute('data-path');
                document.getElementById("textfield_" + feldname).value = output + output_type;
                document.getElementById("place_id_" + feldname).value = output_id;
                document.getElementById("textfield_" + feldname).disabled = true;
                document.getElementById("reset_img_" + feldname).style.display = "inline"            
                document.getElementById("textfield_" + feldname).style.color = "black";
                
                if(e.which==13){
                    e.preventDefault();
                }
            }

        });
}