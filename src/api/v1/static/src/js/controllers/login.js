app.controller("LoginController", ['$scope', '$auth', function($scope, $auth) {
  $scope.user = {};
  
  $scope.login = function(user) {
    $auth.login( user.username, user.password );
  };
}]);
