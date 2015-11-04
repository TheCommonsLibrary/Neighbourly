var makeMap = function(style, onSelect) {
  var australia_coord = [-29.8650, 131.2094];
  var map = L.map('map').setView(australia_coord, 4);

  var tileLayer = L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  var styleFor = function(feature) {
    var color = style.unclaimed
    if (feature.properties.claimedBy === 'selected') {
      color = style.selected
    }
    if (feature.properties.claimedBy === 'claimed') {
      color = style.claimed
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
    var selections = {};
    var highlightStyle = {
        weight: 3,
        color: '#666',
        dashArray: '',
        fillOpacity: 0.9,
    };

    var newlySelected = function() {
          var newlySelected = []
          for(var meshId in selections) {
            if(selections[meshId]) {
              newlySelected.push(meshId);
            }
          }

          return newlySelected;
        }

    return {
      mouseover: function(e) {
      	e.target.setStyle(highlightStyle);
      },
      mouseout: function(e) {
        e.target.setStyle(styleFor(e.target.feature));
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
        onSelect(newlySelected().length > 0);
        e.target.setStyle(styleFor(mesh.feature));
      },
      blocks: {
	      newlySelected: newlySelected,
	      cleared: function() {
	        var cleared = []
	        for(var meshId in selections) {
	          if(selections[meshId] === false) {
	            cleared.push(meshId);
	          }
	        }

	        return cleared;
	      }
	    }
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
    blocks: meshInteractions.blocks
  };
}

$('#map').height($(window).height() - $('.header').height() - 190);
$('#map').width($(window).width());

var meshColors =  {
  selected: '#DDA0DD', //Purple
  unclaimed: '#E6FF00', //Green
  claimed: '#F0054C', //Pink
};

var downloadButtonMaker = function(selected) {
  if (selected) {
    $('.download').removeClass('disabled');
  } else {
    $('.download').addClass('disabled');
  }
}

var map = makeMap(meshColors, downloadButtonMaker);
$('.electorate-picker select').change(function() {
    var electorateId = $(this).val();
    if (electorateId !== "") {
      $('#load').removeClass('hidden');
      $.getJSON('/electorate/' + electorateId + '/meshblocks', function(json) {
        map.render(json);
        $('#load').addClass('hidden');
      });
    }    
});