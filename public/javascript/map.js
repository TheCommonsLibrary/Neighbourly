var makeMap = function(style, onSelect) {
  var australia_coord = [-29.8650, 131.2094];
  var map = L.map('map').setView(australia_coord, 4);

  var tileLayer = L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  var legend = L.control({position: 'bottomright'});
  legend.onAdd = function(map) {
    var div = L.DomUtil.create('div', 'info legend');
     div.innerHTML += '<i style="background:' + style.selected + '"></i><div>Selected</div>';
     div.innerHTML += '<i style="background:' + style.claimed + '"></i><div>Claimed</div>';
     div.innerHTML += '<i style="background:' + style.unclaimed + '"></i><div>Unclaimed</div>';
     return div;
  }
  legend.addTo(map);

  var info = L.control();
  info.onAdd = function(map) {
    this._div = L.DomUtil.create('div', 'info'); // create a div with a class "info"
    this.update();
    return this._div;
  }

  info.update = function(properties) {
    if (properties) {
      //this._div.innerHTML = '<div class="text"> Walkpath is <b>' + properties.state + '</b> and is currently walked by <b>' + properties.claimedBy + '</b></div>';
      if(properties.state === 'unclaimed') {
        this._div.innerHTML = '<div class="text"><b>No one</b> will door knock this area.<br/><b>Click</b> if you want to walk it.</div>';
      } else if(properties.state === 'selected') {
        this._div.innerHTML = '<div class="text"><b>You</b> will door knock this area.<br/><b>Click</b> if you no longer want to door knock the area.</div>';
      } else {
        this._div.innerHTML = '<div class="text"><b>' + properties.claimedBy + '</b> will door knock this area.<br/><b>Click</b> if you want to walk it/download the walk survey.</div>';
      }
    } else {
      this._div.innerHTML = "Hover over a area to see details";
    }
  }
  info.addTo(map);

  var styleFor = function(feature) {
    var color = style.unclaimed
    if (feature.properties.state === 'selected') {
      color = style.selected
    } else if (feature.properties.state === 'claimed') {
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
        info.update(e.target.feature.properties);
      	e.target.setStyle(highlightStyle);
      },
      mouseout: function(e) {
        info.update();
        e.target.setStyle(styleFor(e.target.feature));
      },
      click: function(e) {
        var mesh = e.target;
        var properties = e.target.feature.properties;
        if (properties.state === 'selected') {
          properties.state = properties.previous_state;
          selections[properties.slug] = false;
        } else {
          properties.previous_state = properties.state;
          properties.state = 'selected';
          selections[properties.slug] = true;
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

  var mergeModelsAndStyle = function(selected, cleared) {
    return function(feature) {
      var initState = feature.properties.state;
      if (selected.indexOf(feature.properties.slug) > -1) {
        feature.properties.previous_state = feature.properties.state;
        feature.properties.state = 'selected';
      } else if (cleared.indexOf(feature.properties.slug) > -1) {
        if(feature.properties.state === 'selected') {
          feature.properties.state = 'unclaimed';
        }
      }
      return styleFor(feature);
    }
  }



  return {
    render: function(features) {
      var onEachFeatureCB = function(feature, layer) {
        layer.on(meshInteractions)
      }

      var mesh_boxes = L.geoJson(
                      {"type": 'FeatureCollection', "features": features},
                      { style: mergeModelsAndStyle(meshInteractions.blocks.newlySelected(), meshInteractions.blocks.cleared()), onEachFeature: onEachFeatureCB }
                    ).addTo(map);

      map.fitBounds(mesh_boxes.getBounds());
    },
    clear: function() {
        map.eachLayer(function(layer) {
          if (layer != tileLayer && layer != legend && layer != info) {
            map.removeLayer(layer)
          }
        });
    },
    blocks: meshInteractions.blocks
  };
}

$('#map').height($(window).height() - $('.header').height() - 290);
$('#map').width($(window).width());

var meshColors =  {
  selected: '#DDA0DD', //Purple
  unclaimed: '#E6FF00', //Green
  claimed: '#F0054C', //Pink
};

var map = makeMap(meshColors);
$('.electorate-picker select').change(function() {
    var electorateId = $(this).val();
    if (electorateId !== "") {
      $('#load').removeClass('hidden');
      $.getJSON('/electorate/' + electorateId + '/meshblocks', function(json) {
        map.clear();
        map.render(json);
        $('#load').addClass('hidden');
      });
    }    
});


$('.electorate-picker select').trigger('change');
$('.download').click(function() {
  var url = "/download?";
  url += map.blocks.newlySelected().map(function(x) { return "slugs[]=" + x }).join("&");
  window.location = url;
});



