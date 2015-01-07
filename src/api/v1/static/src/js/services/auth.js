app.factory('$auth', ['$window', '$log', '$state', 'Restangular', function($window, $log, $state, Restangular) {
    var auth = {};

    auth.setToken = function( token ) {
      $window.sessionStorage.token_id = token;
    };

    auth.token = function() {
      return $window.sessionStorage.token_id;
    };
    
    auth.login = function(user, pass) {
      var users = Restangular.all('users');

      users.post({ username: user, password: pass })
        .then(function(data) {
          $log.info("Successfully logged in as " + user);
          auth.setToken(data.token_id);
          $state.go('dashboard');
        })
        .catch(function() {
          auth.setToken( undefined );
        });
    };

    auth.logout = function() {
      console.log('$auth.logout()');
      auth.setToken(undefined);
      $state.go('landing');
    };

    return auth;
}]);
