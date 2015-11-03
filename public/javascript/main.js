$(function() {
  $('.electorate-picker select').change(function() {
    window.location.href = '/map?electorate=' + $('.electorate-picker select').val();
  });
});
