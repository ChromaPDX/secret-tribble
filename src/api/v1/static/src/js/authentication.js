app.controller("AuthenticationController", ['$scope', '$api', function($scope, $api) {
    $scope.login = function(user) {
	$api.login( user.username, user.password )
    };
}]);

