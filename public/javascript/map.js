var makeMap = function(states, stateColors) {
  var map = L.map('map');

  var showAustralia = function() {
    var australia_coord = [-29.8650, 131.2094];
    map.setView(australia_coord, 4);
    $('.map-blocker').removeClass('hidden')
  };

  showAustralia();

  var tileLayer = L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  var legend = L.control({position: 'bottomright'});
  legend.onAdd = function(map) {
    var div = L.DomUtil.create('div', 'legend');
    div.innerHTML = [
      '<b>This block will be walked by</b>',
      '<i style="background:' + stateColors.selected + '"></i><div>Me</div>',
      '<i style="background:' + stateColors.claimed + '"></i><div>Someone else</div>',
      '<i style="background:' + stateColors.unclaimed + '"></i><div>No one</div>'
    ].join('');
    return div;
  }
  legend.addTo(map);

  var instruct = L.control();
  instruct.onAdd = function(map) {
    this._div = L.DomUtil.create('div', 'instruct hidden'); // create a div with a class "instruct"
    this.update();
    return this._div;
  }

  instruct.update = function(properties) {
    if (properties) {
      var hoverText = '<span class="text hover-slug">Block ID: <strong>' + properties.slug + '</strong></span>';
      if(properties.state === states.unclaimed) {
        hoverText += '<div class="text"><b>No one</b> will door knock this area.<br/><b>Click</b> if you want to door knock it.</div>';
      } else if(properties.state === states.selected && properties.db_state !== states.claimed) {
        hoverText += '<div class="text"><b>You</b> will door knock this area.<br/><b>Click</b> if you no longer want to door knock the area.</div>';
      } else {
        hoverText += '<div class="text"><b>' + properties.claimedBy.organisation + '</b> will door knock this area.<br/>'
          + '<br>Contact Details:<br>' + properties.claimedBy.name + '<br>' + properties.claimedBy.email + '<br>' + properties.claimedBy.phone
          + '<br><br>Click if you just want to download the walk list.</div>';
      }
      this._div.innerHTML = hoverText;
    } else {
      this._div.innerHTML = "Hover over an area to see details";
    }
  }
  instruct.addTo(map);

  var styleFor = function(feature) {
    var color = stateColors.unclaimed
    if (feature.properties.state === states.selected) {
      color = stateColors.selected
    } else if (feature.properties.state === states.claimed) {
      color = stateColors.claimed
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
    var stored_selections = localStorage.getItem('slug_selections');
    if (stored_selections) {
      selections = JSON.parse(stored_selections);
    }

    var highlightStyle = {
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
        instruct.update(e.target.feature.properties);
      	e.target.setStyle(highlightStyle);
      },
      mouseout: function(e) {
        instruct.update();
        e.target.setStyle(styleFor(e.target.feature));
      },
      click: function(e) {
        var mesh = e.target;
        var properties = e.target.feature.properties;
        if (properties.state === states.selected) {
          properties.state = properties.db_state;
          selections[properties.slug] = false;
        } else {
          properties.db_state = properties.state;
          properties.state = states.selected;
          selections[properties.slug] = true;
        }
        e.target.setStyle(styleFor(mesh.feature));
      },
      blocks: {
	      newlySelected: newlySelected,
        save: function() {
          localStorage.setItem('slug_selections', JSON.stringify(selections));
        },
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
        feature.properties.db_state = feature.properties.state;
        feature.properties.state = states.selected;
      } else if (cleared.indexOf(feature.properties.slug) > -1) {
        if(feature.properties.state === states.selected) {
          feature.properties.state = states.unclaimed;
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
          if (layer != tileLayer && layer != legend && layer != instruct) {
            map.removeLayer(layer)
          }
        });
    },
    showAustralia: showAustralia,
    blocks: meshInteractions.blocks
  };
}



var windowHeight = function(){
    if(window.innerHeight != undefined){
        return window.innerHeight;
    }
    else{
        var B= document.body, D= document.documentElement;
        return Math.max(D.clientHeight, B.clientHeight);
    }
}



$('#map').height(windowHeight() - $('.header').height());
$('#map').width("100%");

var stateColors =  {
  selected: '#DDA0DD', //Purple
  unclaimed: '#E6FF00', //Green
  claimed: '#F0054C', //Pink
};

var states = {
  selected: 'selected',
  unclaimed: 'unclaimed',
  claimed: 'claimed'
}

var map = makeMap(states, stateColors);
$('.electorate-picker select').change(function() {
    var electorateId = $(this).val();
    if (electorateId !== "") {
      $('.map-blocker').addClass('hidden')
      $('#load').removeClass('hidden');
      $.getJSON('/electorate/' + electorateId + '/meshblocks', function(json) {
        map.clear();
        if (json.length > 0) {
          map.render(json);
        } else {
          $('.no-data').show();
          $('.map-blocker').removeClass("hidden");
        }
        $('#load').addClass('hidden');
      });
      $(".instruct").removeClass("hidden");
    } else {
      $('.no-data').hide();
      map.clear();
      map.showAustralia();
      $(".instruct").addClass("hidden");
    }    
});

$('.electorate-picker select').trigger('change');
window.onunload = function() {
  $('.electorate-picker select').val("");
};

$('.download').click(function() {
  map.blocks.save();
  var form = '<form action="/download" method="POST"><select name="slugs[]" multiple>';
  form += map.blocks.newlySelected().map(function(x) { return '<option value="' + x + '"selected></option>'; }).join("");
  form += '</select></form>';
  $(form).appendTo('body').submit();
});
