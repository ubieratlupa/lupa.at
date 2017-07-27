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

var choices = {
    "fundort" : [
        {id:1, title:"Wien", type:"Bundesland", path:"Österreich"},
        {id:2, title:"Wiener Neustadt", type:"", path:"Wien (Bundesland), Österreich"},
        {id:3, title:"Salzburg", type:"City", path:"Salzburg (Bundesland), Österreich"},
        {id:4, title:"Salzburg", type:"Bundesland", path:"Österreich"},
        {id:5, title:"Graz", type:"Stadt", path:"Steiermark, Österreich"},
        {id:6, title:"Kärnten", type:"Bundesland", path:"Österreich"},
        {id:7, title:"Steiermark", type:"Bundesland", path:"Österreich"},
        {id:8, title:"Linz", type:"Stadt", path:"Oberösterreich, Österreich"},
        {id:9, title:"Kremsmünster", type:"Gemeinde", path:"Kirchdorf an der Krems, Oberösterreich, Österreich"}, 
    ],

    "verwahrort" : [
        {id:1, title:"New York", type:"Stadt", path:"New York (State), USA"},
        {id:2, title:"Seebruck", type:"Gemeinde", path:"Europe, Earth"},
        {id:3, title:"Wien", type:"Stadt", path:"Europe, Earth"},
        {id:4, title:"Kremsmünster", type:"machaka", path:"Markaly, Mars"},
        {id:5, title:"Graz", type:"Stadt", path:"Markaly, Mars"},
        {id:6, title:"Rom", type:"Stadt", path:"Italien"},
        {id:7, title:"Verwahrort", type:"Country", path:"North America, Earth"},
        {id:8, title:"Verwahrort", type:"City", path:"North America, Earth"},
        {id:9, title:"Verwahrort", type:"State", path:"North America, Earth"},
    ],

    "antikerfundort" :  [
        {id:1, title:"Antiker Fundort", type:"Country", path:"Europe, Earth"},
        {id:2, title:"Antiker Fundort", type:"City", path:"Europe, Earth"},
        {id:3, title:"Antiker Fundort", type:"City", path:"Europe, Earth"},
        {id:4, title:"Antiker Fundort", type:"machaka", path:"Markaly, Mars"},
        {id:5, title:"Antiker Fundort", type:"machaka", path:"Markaly, Mars"},
        {id:6, title:"Antiker Fundort", type:"machaka", path:"Sphere, Moon"},
        {id:7, title:"Antiker Fundort", type:"Country", path:"North America, Earth"},
        {id:8, title:"Antiker Fundort", type:"City", path:"North America, Earth"},
        {id:9, title:"Antiker Fundort", type:"State", path:"North America, Earth"}, 
    ]  
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

        // document.getElementById("reset_img_fundort").style.display = "none";
        // document.getElementById("textfield_fundort").removeAttribute("disabled");
        // document.getElementById("reset_img_antikerfundort").style.display = "none";
        // document.getElementById("textfield_antikerfundort").removeAttribute("disabled");
        // document.getElementById("reset_img_verwahrort").style.display = "none";
        // document.getElementById("textfield_verwahrort").removeAttribute("disabled");

        var textfeldFundortValue = document.getElementById("textfield_fundort").value;
        var platzIDFundortValue = document.getElementById("place_id_fundort").value;
        if(platzIDFundortValue=="" && textfeldFundortValue.length>0){
            document.getElementById("textfield_fundort").style.color = "#ff0000";
            document.getElementById("textfield_fundort").select();
            return false;
        }  

        var textfeldAntikerFundortValue = document.getElementById("textfield_antikerfundort").value;
        var platzIDAntikerFundortValue = document.getElementById("place_id_antikerfundort").value;
        if(platzIDAntikerFundortValue=="" && textfeldAntikerFundortValue.length>0){
            document.getElementById("textfield_antikerfundort").style.color = "#ff0000";
            document.getElementById("textfield_antikerfundort").select();
            return false;
        } 

        var textfeldVerwahrortValue = document.getElementById("textfield_verwahrort").value;
        var platzIDVerwahrortValue = document.getElementById("place_id_verwahrort").value;
        if(platzIDVerwahrortValue=="" && textfeldVerwahrortValue.length>0){
            document.getElementById("textfield_verwahrort").style.color = "#ff0000";
            document.getElementById("textfield_verwahrort").select();
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
            source: function(term, returnSuggestionFunction) {
                term = term.toLowerCase();
                var matches = [];
                for (i=0; i<choices[feldname].length; i++)
                    if (~choices[feldname][i].title.toLowerCase().indexOf(term)) matches.push(choices[feldname][i]);

                returnSuggestionFunction(matches);
            },
            renderItem: function (item, search){
                search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
                var re = new RegExp("(" + search.split(' ').join('|') + ")", "gi");

                if(item.type!="" && item.type.includes("(")==false){
                    item.type = " (" + item.type + ")";
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