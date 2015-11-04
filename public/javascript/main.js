//validation
$(function() {
  function appendError(msg) {
    $('.errors-container').append("<div class='errors'><div class='item'>" + msg + "</div></div>");
  }
  $('.login-box').submit(function(e) {
    $('.errors-container').empty();
    var nationName = $('#nation-input').val().trim();
    if (nationName === '') {
      appendError('Please enter a nation name.');
      return false;
    } else if (nationName.match(/[^a-zA-Z0-9]/)) {
      appendError("Nation names should only use alphanumeric characters.");
      return false;
    } else if (nationName.length >= 100) {
      appendError("Nation names should be less than 100 characters.");
      return false;
    }
  });
});
