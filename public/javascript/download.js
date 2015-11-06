$('.download-all').click(function() {
  $.each($(this).parent().find('.pdf'), function(index, link) {
    link.click();
  });
})

var claim_slugs = function(slugs, onClaim) {
  var move_to_claimed = function(slugs) {
    var stored_selections = localStorage.getItem('slug_selections');
    if (stored_selections)
      stored_selections = JSON.parse(stored_selections);
    for(var i = 0; i < slugs.length; i++) {
      var claimable = $('#' + slugs[i] + '.claimable');
      if (onClaim)
        onClaim(claimable);
      $('#all-claimed ul').append(claimable);
      if (stored_selections)
        delete stored_selections[slugs[i]];
      claimable.find('.claim').remove();
    }
    localStorage.setItem('slug_selections', JSON.stringify(stored_selections));
  }

  $.post("/claim", { 'slugs[]': slugs}).always(function(claimed) {
    move_to_claimed(claimed['claimed']);
  });
}


$('.claim-all').click(function() {
  var slugs = $.map($('.claimable'), function(slug) { return slug.id });
  claim_slugs(slugs, function(claimable) { $.each($(claimable).find('.pdf'), function(index, link) { link.click() }); });
});

$('.claim').click(function(e) {
  e.preventDefault();
  claim_slugs([this.parentNode.id]);
});
