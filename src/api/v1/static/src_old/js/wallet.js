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

