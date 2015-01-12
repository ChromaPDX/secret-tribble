app.controller("RootController", ['$auth', '$scope', '$alerts', function($auth, $scope, $alerts) {

  $scope.loggedIn = function() {
    if ( $auth.token() && $auth.token() != "undefined" ) {
      return true;
    }
    return false;
  };

  $scope.logout = function() {
    $auth.logout();
  }

  $scope.closeAlert = function(index) {
    $alerts.remove(index);
  }

}]);
