app.controller("AuthenticationController", ['$scope', '$api', function($scope, $api) {
    $scope.login = function(user) {
	console.log("wat");
	$api.login( user.username, user.password )
    };
}]);

