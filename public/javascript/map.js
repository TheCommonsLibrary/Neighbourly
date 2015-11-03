var draw_map = function(x, y) {
  var map = L.map('map').setView([x, y], 4);

  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  var style = function(feature) {
    return {
      weight: 2,
      opacity: 1,
      color: 'white',
      dashArray: '3',
      //fillColor: '#DDA0DD',
      fillColor: '#E6FF00',
      fillOpacity: 0.5,
    }
  }

  $.get("https://gist.githubusercontent.com/tjmcewan/ce917fb3af63a4700426/raw/70828859b4493f241e32ae2beb9beaa3f691252a/response.json", function(body) {
    var parsed_body = $.parseJSON(body);
    for(var i = 0; i < parsed_body.hits.hits.length; i++) {
      var polygon = L.geoJson(parsed_body.hits.hits[i]._source.location, { style: style }).addTo(map);
    }

    L.marker([-28.5381470905, 150.286818304]).addTo(map)
        .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
        .openPopup();
//L.multipolygon(body["hits"]["hits"][0]
  })

  /*
  L.marker([-29.8650, 131.2094]).addTo(map)
      .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
      .openPopup();
      */

}

$('#map').height($(window).height());
$('#map').width($(window).width());
draw_map(-29.8650, 131.2094);

