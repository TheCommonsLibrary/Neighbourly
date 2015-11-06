$('.download-all').click(function() {
  console.log($(this).parent().find('.pdf'));
  $.each($(this).parent().find('.pdf'), function(index, link) {
    link.click();
  });
})

var claim_slugs = function(slugs, onClaim) {
  var move_to_claimed = function(slugs) {
    for(var i = 0; i < slugs.length; i++) {
      var claimable = $('#' + slugs[i] + '.claimable');
      if (onClaim)
        onClaim(claimable);
      $('#all-claimed ul').append(claimable);
      claimable.find('.claim').remove();
    }
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
