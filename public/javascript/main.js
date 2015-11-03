$(function() {
  $('.electorate-picker select').change(function() {
    if ($('.electorate-picker select').val() === "") {
      return;
    }
    window.location.href = '/map?electorate=' + $('.electorate-picker select').val();
  });
});
