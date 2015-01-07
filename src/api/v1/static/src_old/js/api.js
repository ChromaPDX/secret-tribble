// Provides access to the Chroma API

app.factory('$api', ['$http', '$window', '$log', function($http, $window, $log) {
    var api = {};

    api.setToken = function( token ) { $window.sessionStorage.token_id = token; };
    api.token = function() { return $window.sessionStorage.token_id; };
    
    api.login = function(user, pass) {
	$http.post('/v1/users.json', { username: user, password: pass } )
	    .success( function( data, status, headers, config ) {
		$log.info("Successfully logged in as " + user);
		api.setToken(data.token_id);
	    })
	    .error( function( data, status, headers, config ) {
		api.setToken( undefined );
	    })
    };

    api.logout = function() {
	console.log('$api.logout()');
	api.setToken(undefined);
	location.reload();
    };

    return api;
}]);
