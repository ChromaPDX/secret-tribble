app.factory('$auth', ['$window', '$state', 'Restangular', function($window, $log, $state, Restangular) {
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
        })
        .catch(function() {
          auth.setToken( undefined );
        });
    };

    auth.logout = function() {
      auth.setToken(undefined);
      $state.go('landing');
    };

    return auth;
}]);
