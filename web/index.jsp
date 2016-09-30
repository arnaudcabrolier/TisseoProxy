<%-- 
    Document   : index
    Created on : 22 mars 2013, 15:42:54
    Author     : mpicciolli
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head> 
        <title>Chargement...</title> 
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1"> 
        <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.2/themes/smoothness/jquery-ui.css">
        <link rel="stylesheet" href="http://code.jquery.com/mobile/1.3.0-beta.1/jquery.mobile-1.3.0-beta.1.min.css" />
        
        <script src="https://github.com/janl/mustache.js/raw/master/mustache.js"></script>
        
        <script src="http://code.jquery.com/jquery-1.8.3.min.js"></script>
        
        <script src="http://code.jquery.com/mobile/1.3.0-beta.1/jquery.mobile-1.3.0-beta.1.min.js"></script>
        <script src="http://code.jquery.com/ui/1.10.2/jquery-ui.js"></script>
        
        <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?sensor=false"></script>
        
        
            <style>
 
            #bus_arrivee table{
                width:99%;
            }
            
            #bus_arrivee th, #bus_arrivee td{
                margin:50px;
                padding:10px;
                border-radius:2px;
                font-weight:none;
                text-decoration:none;
                border:1px solid white;
                color:black;
                
            }
            
            #bus_arrivee th {
                background:#C7C6C6;
            }
 
        
   .ui-autocomplete li.ui-menu-item {
      padding: 1px; 
    }
    .ui-autocomplete a.ui-menu-item-alternate {
      background-color: White;  
    }
    .ui-autocomplete a.ui-state-hover {
      font-weight: normal !important;  
    }
            </style>


<script>
            // LANCEUR de page // affiche le html de la page avec transition
            function launch(url, fonction) {
                $.mobile.changePage(url + '.html', {
                    transition: 'slide',
                    reverse: false,
                    changeHash: true,
                });
                executeBreakPoint(url, fonction);
            }

            // EXECUTEUR de fonction // appelle la fonction d'entrée du programme
            function executeBreakPoint(url, fonction) {
                $('#' + url).live('pageshow', function(event, ui) {
                    window[fonction]();
                });
            }

            function displayError(XMLHttpRequest, textStatus, errorThrown) {
                alert("error: " + XMLHttpRequest.responseText);
            }
            
            function getAllStops() {
                $.getJSON('DerbySample/SelectStop',showAllStops).error( displayError );
            }
            
            function showAllStops(jsonResult) {
                for(i=0;i<jsonResult.records.length;i++){
                    markup1="<div data-role='controlgroup'>";
                    $('#resultArea').append(markup1).trigger("create");
                    markup2="<a data-role='button' style='text-align:justify;padding-left:0%' data-theme='c' onclick='test("+jsonResult.records[i].ID+")'>\n\
                    <img src='http://www.tableonline.fr/images/restaurants/star_full_20.png' style='margin-top:-3px'/>  "+jsonResult.records[i].NAME+"</a>";
                    $('#resultArea').append(markup2).trigger("create");
                    markup3="</div>";
                    $('#resultArea').append(markup3).trigger("create");
                }
            }
            function test(id) {
                 url = 'tisseo/departureBoard?stopPointId=' + id + '&format=json&displayRealTime=1';
                $.getJSON(url, DeparturesResult).error(displayError);
            }
            
            function DeparturesResult(jsonResult){
                var LineName = new Array();
                var LineNumber = new Array();
                var Time = new Array();
                var BusDirection = new Array();
                var LineColor= new Array();

                var data = new Array();

                for (i = 0; i < jsonResult.departures.departure.length - 1; i++) {
                    LineName[i] = jsonResult.departures.departure[i].line.name;
                    LineNumber[i] = jsonResult.departures.departure[i].line.shortName;
                    hourTime = jsonResult.departures.departure[i].dateTime.split(" ");
                    Time[i] = hourTime[1];
                    LineColor[i]=jsonResult.departures.departure[i].line.color
                    BusDirection[i] = jsonResult.departures.departure[i].destination[0].name;
                    data[i] = Time[i] + "#" + LineNumber[i] + "#" + LineName[i] + "#" + BusDirection[i]+"#"+LineColor[i];
                }
                
                //Triage du tableau
                data.sort();

                //Supression des doublons
                var i, j, len = data.length, dataclean = [], obj = {};
                for (i = 0; i < len; i++) {
                    obj[data[i]] = 0;
                }
                for (j in obj) {
                    dataclean.push(j);
                }
                
                //Heure courante
                d = new Date();   
            
                var t=$("#zs_station").val();
                $("h3").append("Lignes qui déservent "+t+" :");
                
                //Affichage du tableau propre
                var contenu="<table data-role='table' style='margin:10px' width='98%'><th align='left'>N°</th><th align='left'>Nom de ligne</th><th align='left'>Direction</th><th align='left'>Arrivée</th><th align='left'>Temps d'attente</th>"
                for(i=0;i<dataclean.length;i++){
                    table=dataclean[i].split("#")
                    horaire=table[0].split(":")
                    
                    //Heure courante
                    var Reel =  new Date();
                    //Heure d'arrivée du bus
                    var Bus=    new Date();
                    Bus.setHours(horaire[0]);
                    Bus.setMinutes(horaire[1]);
                    Bus.setSeconds(horaire[2]);
                    //Délais en milisecondes
                    délais=Bus-Reel;
                    //délais en heures
                    heure=Math.floor(délais/3600000)%60;
                    //délais en minutes
                    minute=Math.floor(délais/60000)%60;
                    //délais en secondes
                    seconde=Math.floor(délais/1000)%60;
                    
                    //Gestion de l'affichage
                    if(Math.floor(délais/3600000)%60==0){
                        if(minute==1){
                            délais= minute+" minute, "+seconde+" secondes "
                        }
                        else{
                            délais= minute+" minutes, "+seconde+" secondes "
                        }
                    }
                    else if(heure==1){
                        délais= heure+" heure, "+minute+" minutes"
                    }
                    else{
                        délais=heure+" heures, "+minute+" minutes"
                    }
                    
                    //Affichage des colonnes du tableau
                    contenu+="<tr><td align='center' width='5px' bgcolor="+table[4]+" style='border-radius:10px;padding:3px;color:white;width:60px;'>"+table[1]+"</td><td align='left' style='margin:3px;'>"+table[2]+"</td><td align='left'>"+table[3]+"</td><td align='left'>"+table[0]+"</td><td align='left'><b>"+délais+"</b></td></tr>"
                }
                contenu+="</table>"
                $("#resultat2").html(contenu)
            }
            
            function showRslt(){
                $('#resultArea').show();
            }
		
            $(document).bind('pageinit',
            function() {
                $("#resultArea").hide();
                getAllStops();
                $("#addDiscountForm").on("submit", addNewDiscount );
                $("#addDiscountForm").on("submit", showRslt ); 
                $("#addDiscountForm").on("submit", getAllDiscounts );   
                 $("#showStops").click(function(){
                   $("#resultArea").toggle();  
                 }); 

                $("#showForm").click(function(){$("#addDiscountForm").show();});
            }
        );	
                            
            function addNewDiscount() {
                var parameters = $(this).serialize();
                var url=index.jsp;
                getAllStops();
                alert('DerbySample/InsertStop?' + parameters)
                $.getJSON('DerbySample/InsertStop?' + parameters, getAllDiscounts).error( displayError );
                return false;
                                
            }
			

            function getAllDiscounts() {
                $.getJSON('DerbySample/SelectStop').error( displayError );
            }
                        
                
                       
        </script>
        <style>
            table tr{
                margin:5px;
            }
        </style>
        
    </head>
    <body>

        <div data-role="page" id="index" style="background:url('map.png');background-repeat:no-repeat;background-position:right top;">

            <div data-role="header">
                <h1>Bienvenue</h1>     
                <a href="#popupBasic" data-rel="popup">Infos</a>

                <div data-role="popup" id="popupBasic" style="text-align:center;padding:10px;width:400px;">
                    <p><h4>Crédits</h4>
                    Cette application est basée sur l'API Tisséo Temps réel<br/>
                    Les informations routières (noms de rues, numéros de rues, …) fournies par l’API TISSEO proviennent du projet OpenStreetMap (http://www.openstreetmap.org/).<br/>
                    Les données accessibles via notre API sont sous licence <b>ODBL</b> (https://data.grandtoulouse.fr/la-licence)<p></div>
                <a href="http://www.tisseo.fr/" data-icon="check">Tisséo.fr</a></div>
            
            <!-- module de météo -->
            <div id="m-booked-small-t4-23410" style="position:absolute;float:left;margin:10px 0px 0px 15px;"><div class="booked-weather-120-100s" style=";background-color:#ffffff; color:#000000; border-radius:4px; -moz-border-radius:4px;"> <a style="background-color:#ffffff; color:#1c1b18;" href="http://ibooked.fr/weather/toulouse-927" class="booked-weather-120-100s-city">Toulouse</a> <div class="booked-weather-120-100s-degree w120x100s-03"><span class="plus">+</span>20&deg;<span>C</span></div> <div class="booked-weather-120-100s-text">Éclaircies</div> </div> </div><script type="text/javascript"> var css_file=document.createElement("link"); css_file.setAttribute("rel","stylesheet"); css_file.setAttribute("type","text/css"); css_file.setAttribute("href",'http://s.bookcdn.com/css/w/bw-120-100s.css?v=0.0.1'); document.getElementsByTagName("head")[0].appendChild(css_file); function setWidgetData(data) { if(typeof(data) != 'undefined' && data.results.length > 0) { for(var i = 0; i < data.results.length; ++i) { var objMainBlock = document.getElementById('m-booked-small-t4-23410'); if(objMainBlock !== null) { var copyBlock = document.getElementById('m-bookew-weather-copy-'+data.results[i].widget_type); objMainBlock.innerHTML = data.results[i].html_code; if(copyBlock !== null) objMainBlock.appendChild(copyBlock); } } } else { alert('data=undefined||data.results is empty'); } } </script> <script type="text/javascript" charset="UTF-8" src="http://www.booked.net/?page=get_weather_info&action=get_weather_info&ver=3&cityID=927&type=14&scode=124&ltid=3457&domid=581&cmetric=1&wlangID=3&color=ffffff&wwidth=118&header_color=ffffff&text_color=000000&link_color=1c1b18&border_form=0&footer_color=ffffff&footer_text_color=000000&transparent=0"></script>

            <div align="center">
                <img src="logobus.png" style="" align="center" id="logob" />
            </div>



            <div data-role="content">
                
                <ul data-role="listview" data-inset="true">
                    <li><a href="" onclick="launch('bus_arrivee', 'nouvelle_recherche')">
                    <img src="http://www.blancco.com/files/images/icon-80/icon-clock.gif">
                    <h2>Quand arrive mon bus ?</h2>
                    <p>Connaitre l'arrêt que vient juste de quitter le bus que j'attends.</p></a>
                    </li>
                    <li><a href="" onclick="launch('carte', 'liste_arret')">
                    <img src="http://www.cpib.ac.uk/media/images/icons/map_foot.png">
                    <h2>Lignes de bus/métro</h2>
                    <p>Visualiser sur la carte le tracé des différentes lignes avec leurs arrêts</p></a>
                    </li>
                    <li><a href="" onclick="launch('arret_plus_proche', 'liste_arret')">
                    <img src="http://www.cheapstreetsigns.com/road_signs/image/cache/data/school/S3-1S_BusStopAhead-80x80.jpg">
                    <h2>Trouver mon arrêt de bus</h2>
                    <p>Trouver l’arrêt le plus proche pour avoir mon bus (ligne) ? Indiquer sur une carte le chemin le plus court pour y aller.</p></a>
                    </li> 
                    <li><a href="lieu.html" data-ajax="false">
                   <img src="http://www.mls4mexico.info/1-images/property-icons/icon-city.gif">
                   <h2>Comment me rendre à un lieu ?</h2>
                   <p>Trouver les arrêts qui sont déservis par les bus qui vont à l'endroit que je veux</p></a>
                    </li> 
                </ul>
                    <table>
                        <td>
                        <button type="button" id="showStops">
                        <img src="http://www.myrapid.com.my/dev/images/bus.png" style="margin-right:5px;"/>
                        Mes Arrêts</button><br/><br/>
                        <!-- rafraîchir la page avant de cliquer mes arrêts -->
                        </td>
                    </table>
                    <fieldset id="fs">
                    <div id="resultArea"></div>			
                    </fieldset>
                
                    <div id="resultat2"></div>  
            </div>

            <!-- Footer -->
            <br/><div data-role="footer" style="width:100%;font-size:10px;text-align:center;position:absolute;bottom:0px;overflow:fixed">            
             <p>Copyright - MAG</p></div>

    </body>
</html>
