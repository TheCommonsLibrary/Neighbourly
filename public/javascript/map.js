var makeMap = function(style) {
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
     div.innerHTML += '<b>This block is walked by</b>';
     div.innerHTML += '<i style="background:' + style.selected + '"></i><div>Me</div>';
     div.innerHTML += '<i style="background:' + style.claimed + '"></i><div>Someone else</div>';
     div.innerHTML += '<i style="background:' + style.unclaimed + '"></i><div>No one</div>';
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
      //this._div.innerHTML = '<div class="text"> Walkpath is <b>' + properties.state + '</b> and is currently walked by <b>' + properties.claimedBy + '</b></div>';
      if(properties.state === 'unclaimed') {
        this._div.innerHTML = '<div class="text"><b>No one</b> will door knock this area.<br/><b>Click</b> if you want to walk it.</div>';
      } else if(properties.state === 'selected' && properties.db_state !== 'claimed') {
        this._div.innerHTML = '<div class="text"><b>You</b> will door knock this area.<br/><b>Click</b> if you no longer want to door knock the area.</div>';
      } else {
        this._div.innerHTML = '<div class="text"><b>' + properties.claimedBy.organisation + '</b> will door knock this area.<br/>'
          + '<br>Contact Details:<br>' + properties.claimedBy.name + '<br>' + properties.claimedBy.email + '<br>' + properties.claimedBy.phone
          + '<br><br>Click if you just want to download the walk list.</div>';
      }
    } else {
      this._div.innerHTML = "Hover over an area to see details";
    }
  }
  instruct.addTo(map);

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
        if (properties.state === 'selected') {
          properties.state = properties.db_state;
          selections[properties.slug] = false;
        } else {
          properties.db_state = properties.state;
          properties.state = 'selected';
          selections[properties.slug] = true;
        }
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
        feature.properties.db_state = feature.properties.state;
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

var meshColors =  {
  selected: '#DDA0DD', //Purple
  unclaimed: '#E6FF00', //Green
  claimed: '#F0054C', //Pink
};

var map = makeMap(meshColors);
$('.electorate-picker select').change(function() {
    var electorateId = $(this).val();
    if (electorateId !== "") {
      $('.map-blocker').addClass('hidden')
      $('#load').removeClass('hidden');
      $.getJSON('/electorate/' + electorateId + '/meshblocks', function(json) {
        map.clear();
        map.render(json);
        $('#load').addClass('hidden');
      });
      $(".instruct").removeClass("hidden");
    } else {
      map.clear();
      map.showAustralia();
      $(".instruct").addClass("hidden");
    }    
});


$('.electorate-picker select').trigger('change');
$('.download').click(function() {
  var form = '<form action="/download" method="POST"><select name="slugs[]" multiple>';
  form += map.blocks.newlySelected().map(function(x) { return '<option value="' + x + '"selected></option>'; }).join("");
  form += '</select></form>';
  $(form).appendTo('body').submit();
});
