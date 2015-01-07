app.controller("NewProjectController", ['$scope', '$http', '$api', function($scope, $http, $api) {
    $scope.newProject = {}
    
    $scope.currentIdx = 0
    $scope.nextIdx = function() { return $scope.currentIdx++ }
    
    $scope.resetCurrentSplit = function() {
	$scope.currentSplit = { split_id : $scope.nextIdx(), email : '', percent : 0 }
    }

    $scope.resetSplits = function() {
	$scope.splits = [ { split_id : $scope.nextIdx(), email : 'peat@test.com', percent : 100 } ]
    }

    $scope.resetCurrentSplit()
    $scope.resetSplits()
    $scope.newSplitDBID = false
    $scope.error = false

    $scope.validateSplit = function( split ) {
	var pct = parseInt( split.percent )
	var email = split.email
	var id = split.split_id || $scope.nextIdx()

	if ( pct == NaN ) {
	    $scope.error = "Please enter a valid percent"
	    return false
	}

	return { split_id : id, email : email, percent : pct }
    }
    
    $scope.addSplit = function() {
	var split = $scope.validateSplit( $scope.currentSplit )
	if (! split) { return }

	// check split total
	var total = $scope.splitTotal()
	if (total != 100) {
	    $scope.error = "Please adjust percentages to equal 100%. Currently " + total + "%"
	    return
	}

	// success!
	$scope.error = false
	$scope.splits.push( split )
	$scope.resetCurrentSplit()

	console.log( $scope.splits )
    }

    $scope.splitTotal = function() {
	var total = parseInt( $scope.currentSplit.percent )
	for (i = 0; i < $scope.splits.length; i++) {
	    var pct = $scope.splits[i].percent
	    total = total + pct
	}
	return total;
    }

    $scope.createProject = function() {
	console.log( $scope.splits )
	console.log( $scope.newProject )
	// create splits first

	// create project
	
    }
}])
