var makeMap = function(states, stateColors) {
  var map = L.map('map');

  var mesh_layer; //Rendered map
  var last_update_bounds;

  var tileLayer = L.tileLayer('http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  $('#postcode-button').click(function() {
    FitPcode($('#postcode-input').val());
  });

  var FitPcode = function(pcode) {
    $.getJSON('/pcode_get_bounds?pcode=' + pcode, function(json) {
      map.fitBounds([[json.swlat,json.swlng],[json.nelat,json.nelng]])
    });
  };

  var FindLocation = function() {
    var lat = Cookies.get("lat");
    var lng = Cookies.get("lng");
    var pcode = Cookies.get("postcode");
    if (lat && lng) {
      map.setView([lat,lng],15)
    }
    else if (pcode) {
      FitPcode(pcode)
    }
    else {
      var australia_coord = [-29.8650, 131.2094];
      map.setView(australia_coord, 5);
    }
    $(".instruct").removeClass("hidden");
  };

  FindLocation();

  function addGeoJsonProperties(json) {


    var layer = L.geoJson(json,{
      style: function(feature) {
          switch (feature.properties.claim_status) {
          case 'claimed_by_you': return {color: "#DDA0DD"}
          case 'claimed': return {color: "#F0054C"}
          case 'quarantined': return {color: "#DDA0DD"}
          default: return {"fillColor": "#E6FF00", "color": "#111111",
            "weight": 1, "opacity": 0.65}
        }
      },
    onEachFeature: function(feature, featureLayer) {
      featureLayer._leaflet_id = feature.properties.slug;

      this.btnClaim = function (featureLayer) {
        var leaflet_id = this._leaflet_id;
        $.post("/claim_meshblock/" + leaflet_id);
        this.setStyle({fillColor: "#DDA0DD"})
        $('#load').removeClass('hidden');

        var base64str = $.get("/mesh_pdf/" + leaflet_id, function(base64str) {
          //TODO - potentially hit the AWS endpoint directly

          // decode base64 string, remove space for IE compatibility
          var binary = atob(base64str.replace(/\s/g, ''));

          // get binary length
          var len = binary.length;

          // create ArrayBuffer with binary length
          var buffer = new ArrayBuffer(len);

          // create 8-bit Array
          var view = new Uint8Array(buffer);

          // save unicode of binary data into 8-bit Array
          for (var i = 0; i < len; i++) {
            view[i] = binary.charCodeAt(i);
          }

          // create the blob object with content-type "application/pdf"
          var blob = new Blob( [view], { type: "image/png" });

          var url = window.URL.createObjectURL(blob);
          var a = document.createElement('a');
          //window.location = url;
          a.href = url;
          a.download = leaflet_id + '.png';
          a.click();
          //window.URL.revokeObjectURL(url);
          $('#load').addClass('hidden');
        });
        // decode base64 string, remove space for IE compatibility
        //var binary = atob(base64str.replace(/\s/g, ''));

        // get binary length
        //var len = binary.length;

        // create ArrayBuffer with binary length
        //var buffer = new ArrayBuffer(len);

        // create 8-bit Array
        //var view = new Uint8Array(buffer);

        // save unicode of binary data into 8-bit Array
        //for (var i = 0; i < len; i++) {
        //  view[i] = binary.charCodeAt(i);
        //}

        // create the blob object with content-type "application/pdf"
        //var blob = new Blob( [view], { type: "image/png" });

        //var url = window.URL.createObjectURL(blob);

        //a.href = url;
        //a.download = $(this).data('meshblock') + '.png';
        //a.click();
        //window.URL.revokeObjectURL(url);
      }

      this.btnUnclaim = function (featureLayer) {
        $.post("/unclaim_meshblock/" + this._leaflet_id);
        this.setStyle({"fillColor": "#E6FF00", "color": "#111111",
          "weight": 1, "opacity": 0.65})
      }

      var container = L.DomUtil.create('div')
      var btn = L.DomUtil.create('button', '', container)
      btn.setAttribute('type', 'button')

      var btndom = L.DomEvent
          .addListener(btn, 'click', L.DomEvent.stopPropagation)
          .addListener(btn, 'click', L.DomEvent.preventDefault)

      if (feature.properties.claim_status === 'claimed_by_you') {
        btn.innerHTML = 'Unclaim'
        btndom.addListener(btn, 'click', this.btnUnclaim, featureLayer);
        var popup = L.popup({},featureLayer).setContent(btn);
      }
      else if (feature.properties.claim_status === 'claimed') {
        var popup = L.popup({},featureLayer).setContent('Someone else got it.');
      }
      else {
        btn.innerHTML = 'Download + Claim'
        btndom.addListener(btn, 'click', this.btnClaim, featureLayer);
        var popup = L.popup({},featureLayer).setContent(btn);
      }
      featureLayer.bindPopup(popup)

    }});

    return layer;
  };

  function getMeshblockCallback(json) {
    if (mesh_layer) {map.removeLayer(mesh_layer)};
    mesh_layer = addGeoJsonProperties(json);
    mesh_layer.addTo(map);
    $('#load').addClass('hidden');
  };

  map.on('moveend', function() {
    var lat_lng_bnd = map.getBounds();
    var zoom = map.getZoom();
    var swlat = lat_lng_bnd.getSouthWest().lat;
    var swlng = lat_lng_bnd.getSouthWest().lng;
    var nelat = lat_lng_bnd.getNorthEast().lat;
    var nelng = lat_lng_bnd.getNorthEast().lng;
    //Reload map if zoom not too high
    //and
    //there is no last_update or the current map bounds are not within the last update's
    if(zoom > 14 && (!last_update_bounds || !last_update_bounds.contains(lat_lng_bnd))) {
      $('#load').removeClass('hidden');
      var url = '/meshblocks_bounds?swlat=' + swlat + '&swlng=' + swlng
      + '&nelat=' + nelat + '&nelng=' + nelng;
      $.getJSON(url, function(json) {
        getMeshblockCallback(json);
        last_update_bounds = map.getBounds();
      });
    instruct.update();
  }
  });

  var legend = L.control({position: 'bottomright'});
  legend.onAdd = function(map) {
    var div = L.DomUtil.create('div', 'legend');
    div.innerHTML = [
      '<b>This block will be walked by</b>',
      '<i style="background:' + stateColors.claimed_by_you + '"></i><div>Me</div>',
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
    var zoom = map.getZoom()
    if (properties) {
      var hoverText = '<span class="text hover-slug">Block ID: <strong>' + properties.slug + '</strong></span>';
      if(properties.state === states.unclaimed) {
        hoverText += '<div class="text"><b>No one</b> will door knock this area.<br/><b>Click</b> if you want to door knock it.</div>';
      } else if(properties.state === states.selected && properties.db_state !== states.claimed) {
        hoverText += '<div class="text"><b>You</b> will door knock this area.<br/><b>Click</b> if you no longer want to door knock the area.</div>';
      } else {
        hoverText += '<div class="text"><b>Someone Else</b> will door knock this area.'
          + '<br><br>Click if you just want to download the walk list.</div>';
      }
      this._div.innerHTML = hoverText;
    } else if (zoom > 14) {this._div.innerHTML = "Zoom in further to load more areas.";
      } else {
      this._div.innerHTML = "Hover over an area to see details";
    }
  }
  instruct.addTo(map);
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
  claimed_by_you: '#DDA0DD', //Purple
  unclaimed: '#E6FF00', //Green
  claimed: '#F0054C', //Pink
};

var states = {
  selected: 'selected',
  unclaimed: 'unclaimed',
  claimed: 'claimed'
}

var map = makeMap(states, stateColors);
