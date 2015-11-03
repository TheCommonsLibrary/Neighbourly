var mesh_colors =  {
  selected: '#DDA0DD', //Purple
  unclaimed: '#E6FF00', //Green
  claimed: '#F0054C', //Pink
};

var mesh_interactions = function(style) {
  var selected_boxes = new Object();
  return {
    mouseover: function(e) {
      var mesh = e.target;

      mesh.setStyle({
        weight: 3,
        color: '#666',
        dashArray: '',
        fillColor: mesh_colors.selected,
        fillOpacity: 0.7,
      });
    },

    mouseout: function(e) {
      var mesh = e.target;
      mesh.setStyle(style(e.target.feature));
    },

    click: function(e) {
      var mesh_properties = e.target.feature.properties;

      if (mesh_properties.selected) {
        mesh_properties.selected = false;
        selected_boxes[mesh_properties.slug] = false;
      } else {
        mesh_properties.selected = true;
        selected_boxes[mesh_properties.slug] = true;
      }

      mesh.setStyle(style(e.target.feature));
    }
  };
}

var draw_map = function(start) {
  var map = L.map('map').setView(start, 4);

  //L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
  L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

//      var polygon = L.geoJson(parsed_body.hits.hits[i]._source.location, { style: style }).addTo(map);
  //$.get('/electorate/' + electorateId + '/meshblocks', function(body) {
  $.get("https://gist.githubusercontent.com/tjmcewan/ccefff4ee4baad9fc555/raw/1924f6bcc4b5e4a2c95790d1b7c207cf784cf1c5/inside_territories.json", function(body) {
    var mesh_boxes;

    var style = function(feature) {
      var color = mesh_colors.unclaimed
      
      if (feature.properties.selected) {
        color = mesh_colors.selected
      }
      
      return {
        weight: 2,
        opacity: 1,
        color: 'white',
        dashArray: '3',
        fillColor: color,
        fillOpacity: 0.5,
      }
    }

    var onEachFeature = function(feature, layer) {
      layer.on(mesh_interactions(style))
    }

    mesh_boxes = L.geoJson(
                    {"type": 'FeatureCollection', "features": $.parseJSON(body)},
                    { style: style, onEachFeature: onEachFeature }
                  ).addTo(map);

    map.fitBounds(mesh_boxes.getBounds());
  })
}

$('#map').height($(window).height() - $('.header').height() - 190);
$('#map').width($(window).width());
draw_map([-29.8650, 131.2094]);
