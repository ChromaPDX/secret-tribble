var app = angular.module('chromaApp', [], function($httpProvider) {
    /* WTF IS ALL THIS?
       That's right.
       AngularJS decided to JSON encode all information sent to the server, instead of normal form data ... unlike EVERYTHING ELSE EVER BUILT ON THE INTERNET.
       Sigh.
       So, we're telling AngularJS how to do it for real.
       Stolen directly from: http://victorblog.com/2012/12/20/make-angularjs-http-service-behave-like-jquery-ajax/
    */

    // Use x-www-form-urlencoded Content-Type
    $httpProvider.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8';
    
    /**
     * The workhorse; converts an object to x-www-form-urlencoded serialization.
     * @param {Object} obj
     * @return {String}
     */ 
    var param = function(obj) {
	var query = '', name, value, fullSubName, subName, subValue, innerObj, i;
	
	for(name in obj) {
	    value = obj[name];
            
	    if(value instanceof Array) {
		for(i=0; i<value.length; ++i) {
		    subValue = value[i];
		    fullSubName = name + '[' + i + ']';
		    innerObj = {};
		    innerObj[fullSubName] = subValue;
		    query += param(innerObj) + '&';
		}
	    }
	    else if(value instanceof Object) {
		for(subName in value) {
		    subValue = value[subName];
		    fullSubName = name + '[' + subName + ']';
		    innerObj = {};
		    innerObj[fullSubName] = subValue;
		    query += param(innerObj) + '&';
		}
	    }
	    else if(value !== undefined && value !== null)
		query += encodeURIComponent(name) + '=' + encodeURIComponent(value) + '&';
	}
	
	return query.length ? query.substr(0, query.length - 1) : query;
    };
    
    // Override $http service's default transformRequest
    $httpProvider.defaults.transformRequest = [function(data) {
	return angular.isObject(data) && String(data) !== '[object File]' ? param(data) : data;
    }];
});


app.controller("AuthenticationController", ['$scope', '$http', '$window', function($scope, $http, $window) {

    setToken = function(tid) { $window.sessionStorage.token_id = tid; }
    $scope.token = function() { return $window.sessionStorage.token_id; }

    $scope.login = function(user) {
	$http.post('/v1/users.json', user )
	    .success( function(data, status, headers, config) {
		// console.log("SUCCESS");
		// console.log(data);
		setToken(data.token_id);
	    })
	    .error( function(data, status, headers, config) {
		// console.log("ERROR");
		// console.log(data);
		setToken(false);
	    });
    };

    $scope.logout = function() {
	// console.log("Attemping logout");
	setToken(false);
    }

}]);

app.controller("ProjectController", ['$scope', '$http', '$window', function($scope, $http, $window) {

    $scope.token = function() { return $window.sessionStorage.token_id; }

    $scope.loadProject = function( project_id ) {
	$scope.project = false;
	$scope.pool = false;
	$scope.users = [];
	
	$http({ method: 'GET',
		url: '/v1/projects.json',
		params: { token_id: $scope.token(), project_id: project_id } })
	    .success( function(data, status, headers, config) {
		$scope.project = data;
		$scope.loadPool( data.pool_id );
	    })
    }

    $scope.loadProjects = function() {
	$scope.projects = [];
	
	$http({ method: 'GET',
		url: '/v1/projects.json',
		params: { token_id: $scope.token() } })
	    .success( function(data, status, headers, config) {
		$scope.projects = data;
	    });
    }

    $scope.loadPool = function( pool_id ) {
	$scope.pool = false;
	$scope.users = [];
	
	$http({ method: 'GET',
		url: '/v1/pools.json',
		params: { token_id: $scope.token(), pool_id: pool_id } })
	    .success( function(data, status, headers, config) {
		$scope.pool = data;
		$scope.loadUsers( Object.keys( data.splits ) );
	    });
    }

    $scope.loadUsers = function(user_ids) {
	$scope.users = [];
	
	user_ids.forEach( function(user_id) {
	    $http({ method: 'GET',
		    url: '/v1/users.json',
		    params: { token_id: $scope.token(), user_id: user_id } })
		.success( function(data, status, headers, config) {
		    $scope.users.push( data );
		});
	})
    }

    $scope.init = function() {
	$scope.projects = false;
	$scope.pool = false;
	$scope.users = [];
	$scope.projects = [];

	$scope.loadProjects();
    }

    $scope.init()
    
}]);
