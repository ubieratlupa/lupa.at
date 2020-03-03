function isElementInViewport (el) {
    var rect = el.getBoundingClientRect();
    return rect.top >= 0 && rect.bottom <= (window.innerHeight || document.documentElement.clientHeight)
}

window.onpagehide = saveFormContents;

var autocomplete_fieldnames = ["finding_place","conservation_place","ancient_finding_place", "dating_phase"];
var formContents;

function saveFormContents(){
    if (document.getElementById("query-form")) {
        formContents = new Object;
        for (i=0; i<autocomplete_fieldnames.length; i++) {
            var titleField = document.getElementById(autocomplete_fieldnames[i]);
            var idField = document.getElementById("query_" + autocomplete_fieldnames[i] + "_id");
            formContents[autocomplete_fieldnames[i]] = { title: titleField.value, id: idField.value }
        }
        window.onpageshow = restoreFormContents;
    }
}

function restoreFormContents(){
    for (i=0; i<autocomplete_fieldnames.length; i++) {
        var titleField = document.getElementById(autocomplete_fieldnames[i]);
        var idField = document.getElementById("query_" + autocomplete_fieldnames[i] + "_id");
        titleField.value = formContents[autocomplete_fieldnames[i]].title;
        idField.value = formContents[autocomplete_fieldnames[i]].id;
        if (formContents[autocomplete_fieldnames[i]].id) {
            document.getElementById(autocomplete_fieldnames[i] + "_menu_img").style.display = "none";
            document.getElementById("reset_img_" + autocomplete_fieldnames[i]).style.display = "inline";
        }
    }
}

function xreset(fieldname) { 
    document.getElementById("query_" + fieldname + "_id").value = "";
    document.getElementById("reset_img_" + fieldname).style.display = "none";
    document.getElementById(fieldname).removeAttribute("disabled");
    document.getElementById(fieldname).value = ""; 
    document.getElementById(fieldname).focus();
    document.getElementById(fieldname).select();

    document.getElementById(fieldname + "_menu_img").style.display = "inline";
}

$(document).ready(function() {
 
    for (i=0; i<autocomplete_fieldnames.length; i++) {
        createAutoComplete(autocomplete_fieldnames[i]);
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
            return false;
        }  

        var AncientFindingPlaceValue = document.getElementById("ancient_finding_place").value;
        var AncientFindingPlaceID = document.getElementById("query_ancient_finding_place_id").value;
        if(AncientFindingPlaceID=="" && AncientFindingPlaceValue.length>0){
            document.getElementById("ancient_finding_place").style.color = "#ff0000";
            document.getElementById("ancient_finding_place").select();
            return false;
        } 

        var ConservationPlaceValue = document.getElementById("conservation_place").value;
        var ConservationPlaceID = document.getElementById("query_conservation_place_id").value;
        if(ConservationPlaceID=="" && ConservationPlaceValue.length>0){
            document.getElementById("conservation_place").style.color = "#ff0000";
            document.getElementById("conservation_place").select();
            return false;
        }  
    });

});

function createSuggestions(evt, fieldname) {

    evt.target.src = document.getElementById("loadingGif").src;

    if(evt.target.className == "menu_img_child"){
        var ajaxdata = {"parent_id": evt.target.parentElement.getAttribute("data-id")};
    } else {
        var ajaxdata = {}
    }

    $.ajax({
        type: "GET",
        url: "/queries/suggestions/" + fieldname,
        data: ajaxdata,
        dataType: "json",
        cache: false,
        success: function (data){    
            evt.target.src = document.getElementById("menuDownIMG").src;
            document.getElementById(fieldname).focus();
            document.getElementById(fieldname).suggest(data, true);

            if(!isElementInViewport(document.getElementById(fieldname))){
                    $(document).scrollTop($("#" + fieldname).parent().offset().top);
            }
            $(".menu_img_child").click(function(clickEvt){
                return createSuggestions(clickEvt, fieldname);
            }); 
        }      
    });

    return false;
}

function createAutoComplete( fieldname ) {
    $("#" + fieldname + "_menu_img").click(function(evt){
        return createSuggestions(evt, fieldname);
    });

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
				    success:  function(completions) {
						successHandler(completions);
			            $(".menu_img_child").click(function(clickEvt){
			               return createSuggestions(clickEvt, fieldname);
			            }); 
					}
				});
            },
            renderItem: function (item, search) {

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

                var itemTitle = item.title.replace(re, "<b>$1</b>");
                var itemIMG;

                if(item.child_count>0){
                    itemIMG = "<img src='" + document.getElementById("menuDownIMG").src + "' class='menu_img_child' alt='menu'>";
                }
                else{
                    itemIMG = "";
                }

                return '<div class="autocomplete-suggestion" data-title="' + item.title 
                    + '" data-id="' + item.id 
                    + '" data-path"' + item.path
                    + '" data-type="' + item.type
                    + '" data-val="' + search + '">'
                    + "<span id='outputtitle'>" + itemTitle + "</span>" 
                    + item.type + "<br> "
                    + "<span class='outputpath'>" + item.path + "</span>"
                    + itemIMG
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
                document.getElementById(fieldname + "_menu_img").style.display = "none";

                if(!isElementInViewport(document.getElementById(fieldname))){
                    $(document).scrollTop($("#" + fieldname).parent().offset().top);
                }

                if(e.which==13){
                    e.preventDefault();
                }
            }

        });
}