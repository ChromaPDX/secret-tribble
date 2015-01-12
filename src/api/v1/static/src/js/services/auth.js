app.factory('$auth', ['$window', '$state', 'Restangular', '$alerts', function($window, $state, Restangular, $alerts) {
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
          auth.setToken(data.token_id);
          $state.go('dashboard');
          $alerts.addSuccess('Successfully signed in!');
        })
        .catch(function(data) {
          auth.setToken( undefined );
          $alerts.addDanger('Invalid credentials!');
        });
    };

    auth.logout = function() {
      auth.setToken(undefined);
      $state.go('landing');
      $alerts.addSuccess('Successfully logged out!');
    };

    return auth;
}]);
