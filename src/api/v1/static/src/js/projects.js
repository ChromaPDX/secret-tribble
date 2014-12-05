app.controller("ProjectController", ['$scope', '$http', '$window', function($scope, $http, $window) {

    console.log("loading ProjectsController");
    
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
	    });

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
