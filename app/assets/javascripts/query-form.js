window.onpagehide = saveFormContents;

var formContents;

function saveFormContents(){
    if(document.getElementById("query-form")){
    formContents = new Object;
    formContents.findingPlaceTitle = document.getElementById("finding_place").value;
    formContents.findingPlaceID = document.getElementById("query_finding_place_id").value;
    formContents.conservationPlaceTitle = document.getElementById("conservation_place").value;
    formContents.conservationPlaceID = document.getElementById("query_conservation_place_id").value;
    formContents.ancientFindingPlaceTitle = document.getElementById("ancient_finding_place").value;
    formContents.ancientFindingPlaceID = document.getElementById("query_ancient_finding_place_id").value;

    window.onpageshow = restoreFormContents;
    }     
}

function restoreFormContents(){
    document.getElementById("finding_place").value = formContents.findingPlaceTitle;
    document.getElementById("query_finding_place_id").value = formContents.findingPlaceID;
    document.getElementById("conservation_place").value = formContents.conservationPlaceTitle;
    document.getElementById("query_conservation_place_id").value = formContents.conservationPlaceID;
    document.getElementById("ancient_finding_place").value = formContents.ancientFindingPlaceTitle;
    document.getElementById("query_ancient_finding_place_id").value = formContents.ancientFindingPlaceID;
}

function xreset(fieldname) { 
    document.getElementById("query_" + fieldname + "_id").value = "";
    document.getElementById("reset_img_" + fieldname).style.display = "none";
    document.getElementById(fieldname).removeAttribute("disabled");
    document.getElementById(fieldname).focus();
    document.getElementById(fieldname).select();
    document.getElementById(fieldname).value = ""; 
}

$(document).ready(function() {
    var fieldnames = ["finding_place","conservation_place","ancient_finding_place"];
    
    for (i=0; i<fieldnames.length; i++) {
        createAutoComplete(fieldnames[i]);
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
        var FindingPlaceValue = document.getElementById("finding_place").value;
        var FindingPlaceID = document.getElementById("query_finding_place_id").value;
        if(FindingPlaceID=="" && FindingPlaceValue.length>0){
            document.getElementById("finding_place").style.color = "#ff0000";
            document.getElementById("finding_place").select();
			document.getElementById("finding_place").updateSC();
            return false;
        }  

        var AncientFindingPlaceValue = document.getElementById("ancient_finding_place").value;
        var AncientFindingPlaceID = document.getElementById("query_ancient_finding_place_id").value;
        if(AncientFindingPlaceID=="" && AncientFindingPlaceValue.length>0){
            document.getElementById("ancient_finding_place").style.color = "#ff0000";
            document.getElementById("ancient_finding_place").select();
			document.getElementById("ancient_finding_place").updateSC();
            return false;
        } 

        var ConservationPlaceValue = document.getElementById("conservation_place").value;
        var ConservationPlaceID = document.getElementById("query_conservation_place_id").value;
        if(ConservationPlaceID=="" && ConservationPlaceValue.length>0){
            document.getElementById("conservation_place").style.color = "#ff0000";
            document.getElementById("conservation_place").select();
			document.getElementById("conservation_place").updateSC();
            return false;
        }  
    });

});


function createAutoComplete( fieldname ) {
    $("#reset_img_" + fieldname).click( function(){xreset(fieldname)} )
    //var datatypecontrol = true;
    new autoComplete({
            selector: '#' + fieldname,
            minChars: 1,
			cache: false,
            source: function(term, successHandler) {				
				$.ajax({
				    type: "GET",
				    url: "/queries/completions/" + fieldname,
					data: {"term": term},
				    dataType: "json",
					cache: false,
				    success: successHandler      
				});
            },
            renderItem: function (item, search){
                search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
                var re = new RegExp("(" + search.split(' ').join('|') + ")", "gi");

				if (item.type) {
					if (item.type.includes("(")) {
					    item.type = " " + item.type;
					} else {
					    item.type = " (" + item.type + ")";
					} 
				}
                else{
                    item.type = "";
                }

                return '<div class="autocomplete-suggestion" data-title="' + item.title 
                    + '" data-id="' + item.id 
                    + '" data-path"' + item.path
                    + '" data-type="' + item.type
                    + '" data-val="' + search + '">'
                    + "<span id='outputtitle'>" + item.title.replace(re, "<b>$1</b>") + "</span>" + item.type + "<br> <span='outputpath'>" + item.path + "</span>"
                    + '</div>';
            },
            onSelect: function(e, term, item){
                var output = item.getAttribute('data-title');
                var output_id = item.getAttribute('data-id');
                var output_type = item.getAttribute('data-type');
                var output_path = item.getAttribute('data-path');

                document.getElementById(fieldname).value = output + output_type;
                document.getElementById("query_" + fieldname + "_id").value = output_id;
                document.getElementById(fieldname).disabled = true;
                document.getElementById("reset_img_" + fieldname).style.display = "inline"            
                document.getElementById(fieldname).style.color = "black";

                function isElementInViewport (el) {
                    var rect = el.getBoundingClientRect();
                    return rect.top >= 0 && rect.bottom <= (window.innerHeight || document.documentElement.clientHeight)
                }

                if(!isElementInViewport(document.getElementById(fieldname))){
                    $(document).scrollTop($("#" + fieldname).parent().offset().top);
                }

                

                if(e.which==13){
                    e.preventDefault();
                }
            }

        });
}