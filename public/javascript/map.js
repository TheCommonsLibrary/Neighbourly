var draw_map = function(x, y) {
  var map = L.map('map').setView([-29.8650, 131.2094], 4);

  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  /*
  L.marker([-29.8650, 131.2094]).addTo(map)
      .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
      .openPopup();
      */

}

$('#map').height($(window).height());
$('#map').width($(window).width());
draw_map(-29.8650, 131.2094);

