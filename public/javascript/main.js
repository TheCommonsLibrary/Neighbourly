$(function() {
  function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
  }

  var electorate = getParameterByName('electorate');
  $('.electorate-picker select option[value="' + electorate + '"]').prop('selected', true);

  $('.electorate-picker select').change(function() {
    if ($('.electorate-picker select').val() === "") {
      return;
    }
    window.location.href = '/map?electorate=' + $('.electorate-picker select').val();
  });
});
