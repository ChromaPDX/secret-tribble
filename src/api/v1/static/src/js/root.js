app.controller("RootController", ['$api', '$scope', function($api, $scope) {

    // initial state for navigation
    $scope.currentNav = "/dashboard.html";
    
    $scope.nav = function( newNav ) { $scope.currentNav = newNav; };

    $scope.ifNav = function( n ) {
	console.log("currentNav == " + n);
	if ($scope.currentNav == n) {
	    return true;
	}

	return false;
    }
    
    $scope.loggedIn = function() {
	console.log( $api.token() );
	if ( $api.token() && $api.token() != "undefined" ) {
	    return true;
	}
	
	return false;
    };

    $scope.logout = function() {
	$api.logout();
    }

}]);

