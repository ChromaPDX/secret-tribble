var app = angular.module('chromaApp', [], function($httpProvider) {
    // fucking angular POSTs as JSON encoded data! This is a hack to clean it up, ala http://victorblog.com/2012/12/20/make-angularjs-http-service-behave-like-jquery-ajax/
    
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

app.factory('$api', ['$http', '$window', '$log', function($http, $window, $log) {
    var api = {};

    api.setToken = function( token ) { $window.sessionStorage.token_id = token; };
    api.token = function() { return $window.sessionStorage.token_id; };
    
    api.login = function(user, pass) {
	$http.post('/v1/users.json', { username: user, password: pass } )
	    .success( function( data, status, headers, config ) {
		$log.info("Successfully logged in as " + user);
		api.setToken(data.token_id);
	    })
	    .error( function( data, status, headers, config ) {
		api.setToken( undefined );
	    })
    };

    api.logout = function() {
	console.log('$api.logout()');
	api.setToken(undefined);
	location.reload();
    };

    return api;
}]);

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

app.controller("AuthenticationController", ['$scope', '$api', function($scope, $api) {
    $scope.login = function(user) {
	console.log("wat");
	$api.login( user.username, user.password )
    };
}]);

app.controller("WalletController", ['$scope', '$http', '$window', function($scope, $http, $window) {

    $scope.token = function() { return $window.sessionStorage.token_id; }
    $scope.wallets = [];
    $scope.wallet = false;
    $scope.ledger = [];
    $scope.wallet_revenue = 0.0;

    $scope.updateRevenue = function() {
	$scope.wallet_revenue = 0.0;
	for ( i = 0; i < $scope.ledger.length; i++ ) {
	    l = $scope.ledger[i];
	    $scope.wallet_revenue += parseFloat( l.amount );
	}
    }
    
    $scope.loadWallet = function( wallet_id ) {
	$scope.wallet = false;
	$http({ method: 'GET',
		url: '/v1/wallets.json',
		params: { token_id: $scope.token(), wallet_id: wallet_id } })
	    .success( function(data, status, headers, config) {
		$scope.wallet = data;
		$scope.loadLedger();
	    })	
    }

    $scope.loadRelationWallet = function( relation_id ) {
	$scope.wallet = false;
	$http({ method: 'GET',
		url: '/v1/wallets.json',
		params: { token_id: $scope.token(), relation_id: relation_id } })
	    .success( function(data, status, headers, config) {
		$scope.wallet = data;
	    })	
    }
    
    $scope.loadWallets = function() {
	$scope.wallets = [];
	$scope.wallet = false;
	
	$http({ method: 'GET',
		url: '/v1/wallets.json',
		params: { token_id: $scope.token() } })
	    .success( function(data, status, headers, config) {
		$scope.wallets = data;
	    });
    }

    $scope.loadLedger = function() {
	$scope.ledger = [];
	$http({ method: 'GET',
		url: '/v1/ledger.json',
		params: { token_id: $scope.token(), to_wallet_id: $scope.wallet.wallet_id } })
	    .success( function(data, status, headers, config) {
		$scope.ledger = data;
		$scope.updateRevenue();
	    })	
    }


    $scope.init = function() {
	if ($scope.token() && !$scope.wallets.length) {
	    $scope.wallet = false;
	    $scope.loadWallets();
	}

	return true;
    }

    $scope.init();

}]);

app.controller("ProjectController", ['$scope', '$http', '$window', function($scope, $http, $window) {
    
    $scope.token = function() { return $window.sessionStorage.token_id; }
    $scope.projects = [];
    $scope.project = false;
    $scope.project_wallet;
    $scope.project_ledger;
    $scope.project_revenue = 0.0;

    $scope.updateRevenue = function() {
	$scope.project_revenue = 0.0;
	for ( i = 0; i < $scope.project_ledger.length; i++ ) {
	    l = $scope.project_ledger[i];
	    $scope.project_revenue += parseFloat( l.amount );
	}
    }
    
    $scope.loadProject = function( project_id ) {
	$scope.project = false;
	$scope.project_wallet = false;
	$scope.pool = false;
	$scope.users = [];
	
	$http({ method: 'GET',
		url: '/v1/projects.json',
		params: { token_id: $scope.token(), project_id: project_id } })
	    .success( function(data, status, headers, config) {
		$scope.project = data;
		$scope.loadProjectWallet( data.project_id );
		$scope.loadPool( data.pool_id );
		return true;
	    })

	return false;
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

    
    $scope.loadProjectWallet = function() {
	$scope.project_wallet = false;
	$http({ method: 'GET',
		url: '/v1/wallets.json',
		params: { token_id: $scope.token(), relation_id: $scope.project.project_id } })
	    .success( function(data, status, headers, config) {
		$scope.project_wallet = data;
		$scope.loadProjectLedger();
	    })	
    }

    $scope.loadProjectLedger = function() {
	$scope.project_ledger = [];
	$http({ method: 'GET',
		url: '/v1/ledger.json',
		params: { token_id: $scope.token(), to_wallet_id: $scope.project_wallet.wallet_id } })
	    .success( function(data, status, headers, config) {
		$scope.project_ledger = data;
		$scope.updateRevenue();
	    })	
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
	if ($scope.token() && !$scope.projects.length) {
	    $scope.projects = false;
	    $scope.pool = false;
	    $scope.users = [];
	    
	    $scope.loadProjects();
	}
    }

    $scope.init()
    
}]);
