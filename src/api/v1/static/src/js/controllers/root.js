app.controller("RootController", ['$auth', '$scope', function($auth, $scope) {

  $scope.loggedIn = function() {
    if ( $auth.token() && $auth.token() != "undefined" ) {
      return true;
    }
  
    return false;
  };

  $scope.logout = function() {
    $auth.logout();
  }

}]);
