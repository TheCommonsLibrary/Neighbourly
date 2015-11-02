var client_id ='3ac32481380cdeafd2a3cfe4f8c021ef357499dbc85b8fbf99c9ea88ded83071'
var redirect_uri = 'http://localhost:4567/oauth_callback'

$('.login-button').on('click', function(){
	var nationslug = $('#nation-input').val();

	window.location = 'https://' + 
						nationslug + 
						'.nationbuilder.com/oauth/authorize?response_type=code&client_id=' + 
						client_id + '&redirect_uri=' + redirect_uri;

})