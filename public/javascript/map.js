var meshColors =  {
  selected: '#DDA0DD', //Purple
  unclaimed: '#E6FF00', //Green
  claimed: '#F0054C', //Pink
};

var makeMap = function(style) {
  var australia_coord = [-29.8650, 131.2094];
  var map = L.map('map').setView(australia_coord, 4);

  var tileLayer = L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  var styleFor = function(feature) {
    var color = style.unclaimed
    if (feature.properties.selected) {
      color = style.selected
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

  var meshInteractions = function() {
    var reStyle = function(mesh, style) {
      mesh.setStyle(style);
      if (!L.Browser.ie && !L.Browser.opera) {
        mesh.bringToFront();
      }
    };

    var selections = {};
    var highlightStyle = {
        weight: 3,
        color: '#666',
        dashArray: '',
        fillOpacity: 0.9,
    };

    return {
      selections: selections,
      mouseover: function(e) {
        reStyle(e.target, highlightStyle);
      },
      mouseout: function(e) {
        reStyle(e.target, styleFor(e.target.feature));
      },
      click: function(e) {
        var mesh = e.target;
        if (e.target.feature.properties.selected) {
          e.target.feature.properties.selected = false;
          selections[e.target.feature.properties.slug] = false;
        } else {
          e.target.feature.properties.selected = true;
          selections[e.target.feature.properties.slug] = true;
        }
        reStyle(mesh, styleFor(mesh.feature));
      },
    };
  }();


  return {
    render: function(features) {
      var onEachFeatureCB = function(feature, layer) {
        layer.on(meshInteractions)
      }

      var mesh_boxes = L.geoJson(
                      {"type": 'FeatureCollection', "features": features},
                      { style: styleFor, onEachFeature: onEachFeatureCB }
                    ).addTo(map);

      map.fitBounds(mesh_boxes.getBounds());
    },
    clear: function() {
        map.eachLayer(function(layer) {
          if (layer != tileLayer) {
            map.removeLayer(layer)
          }
        });
    },
    blocks: {
      newlySelected: function() {
        var newlySelected = []
        for(var meshId in meshInteractions.selections) {
          if(meshInteractions.selections[meshId]) {
            newlySelected.push(meshId);
          }
        }

        return newlySelected;
      },
      cleared: function() {
        var cleared = []
        for(var meshId in meshInteractions.selections) {
          if(meshInteractions.selections[meshId] === false) {
            cleared.push(meshId);
          }
        }

        return cleared;
      }
    }
  };
}

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
}

$('#map').height($(window).height() - $('.header').height() - 190);
$('#map').width($(window).width());
var map = makeMap(meshColors);
var electorateId = getUrlParameter('electorate');
if (electorateId) {
  $.getJSON('/electorate/' + getUrlParameter('electorate') + '/meshblocks', map.render);
}
