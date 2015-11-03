var draw_map = function(x, y) {
  var map = L.map('map').setView([x, y], 4);

  //L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
  L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);



  //$.get("https://gist.githubusercontent.com/tjmcewan/ce917fb3af63a4700426/raw/70828859b4493f241e32ae2beb9beaa3f691252a/response.json", function(body) {
//      var polygon = L.geoJson(parsed_body.hits.hits[i]._source.location, { style: style }).addTo(map);
  $.get("https://gist.githubusercontent.com/tjmcewan/ccefff4ee4baad9fc555/raw/1924f6bcc4b5e4a2c95790d1b7c207cf784cf1c5/inside_territories.json", function(body) {
    var mesh_boxes;
    var selected_boxes = new Object();

    var style = function(feature) {
      //console.log("Feature " + feature.properties.slug);
      return {
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        //fillColor: '#DDA0DD',
        //fillColor: '#E6FF00',
        fillColor: '#F0054C',
        fillOpacity: 0.5,
      }
    }

    var hightlightMeshBox = function(e) {
      var layer = e.target;

      layer.setStyle({
        weight: 3,
        color: '#666',
        dashArray: '',
        fillColor: '#E6FF00',
      });

      if (!L.Browser.ie && !L.Browser.opera) {
        layer.bringToFront();
      }
    }

    var resetMeshBox = function(e) {
      mesh_boxes.resetStyle(e.target);
    }

    /*
    var selectMeshBox = function(e) {
      puts "
    }
    */

    var onEachFeature = function(feature, layer) {
      layer.on({
        mouseover: hightlightMeshBox,
        mouseout: resetMeshBox,
     //   click: selectMeshBox,
      });
    }

    mesh_boxes = L.geoJson(
                    {"type": 'FeatureCollection', "features": $.parseJSON(body)},
                    { style: style, onEachFeature: onEachFeature }
                  ).addTo(map);

    map.fitBounds(mesh_boxes.getBounds());

  })
}

$('#map').height($(window).height());
$('#map').width($(window).width());
draw_map(-29.8650, 131.2094);

