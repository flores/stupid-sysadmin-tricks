#!/usr/bin/env ruby
# quick and dirty.
# using http://gmaps-utility-library.googlecode.com/svn/trunk/markerclusterer/1.0/ to cluster data points
# (prevents slow page loads and timeouts from google)

# i could do this file opens nicer.  later.
File.open('/tmp/maps.json','w') {|f| f.write("var data = {maps:[") }

# this too
dataset=`mysql -umyuser mydatabase -e 'SELECT CONCAT(CONCAT("{\'id\':",id,","),CONCAT("\'latitude\':",lat,","),CONCAT("\'longitude\':",\`long\`,"}")) FROM mytable where lat is not NULL' |grep -v CONCAT`

dataset.each do |line| 
		File.open('/tmp/maps.json', 'a') {|f| f.write("#{line},") }
end

File.open('/tmp/maps.json','a') {|f| f.write("]}")}

puts "
<html xmlns='http://www.w3.org/1999/xhtml'>
  <head> 
    <meta http-equiv='content-type' content='text/html; charset=utf-8' /> 
    <title>Some clever title</title> 
    <script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=MYAWESOMEKEY&sensor=false' type='text/javascript'></script> 
    <script type='text/javascript' src='maps.json'></script> 
    <script type='text/javascript' src='src/markerclusterer'></script>
    <script type='text/javascript'> 
      function initialize() {
        if(GBrowserIsCompatible()) {
          var map = new GMap2(document.getElementById('map'));
	  map.setCenter(new GLatLng(0, 0), 2);
          map.addControl(new GLargeMapControl());
          var icon = new GIcon(G_DEFAULT_ICON);
//        cool marker icon
          icon.image = 'http://chart.apis.google.com/chart?cht=mm&chs=24x32&chco=FFFFFF,008CFF,000000&ext=.png';
          var markers = [];
          for (var i = 0; i < #{dataset.size}; ++i) {
            var latlng = new GLatLng(data.maps[i].latitude, data.maps[i].longitude);
            var marker = new GMarker(latlng, {icon: icon});
            markers.push(marker);
          }
          var markerCluster = new MarkerClusterer(map, markers);
        }
      }
    </script> 
  </head> 
  <body onload='initialize()' onunload='GUnload()'> 
    <div id='map' style='width:1024px;height:768px;'></div> 
  </body> 
</html> 
"

