app.controller("ProjectsController", ['$scope', '$projects', '$pools', function($scope, $projects, $pools) {
  
  $scope.splits = [];
  $scope.pool_id = -1;

  var init = function() {
    $projects.all().then(function(data) {
      $scope.projects = data;
    });

    initSplit();
    $scope.currentIdx = -1;
  }

  var initSplit = function() {
    $scope.split = {percent: 0};
    $scope.errors = false;
    $scope.project_errors = false;
  }

  var splitTotal = function() {
    var total = parseInt( $scope.split.percent );
    for (i = 0; i < $scope.splits.length; i++) {
        var pct = parseInt($scope.splits[i].percent);
        total = total + pct;
    }
    return total;
  }

  var validateSplit = function(split) {
    var pct = parseInt( split.percent );
    var email = split.email;

    if ( pct == 0 || email === '' ) {
        $scope.errors = "Please enter a valid values";
        return false;
    }

    var total = splitTotal();
    if (total > 100) {
      $scope.errors = "Please adjust percentages to equal 100%. Currently " + total + "%";
      return false;
    }

    return split;
  }

  init();

  $scope.createProject = function() {
    if ($scope.pool_id === -1) {
      $scope.project_errors = "You need to create Pool first.";
      return;
    }

    var project = $scope.project;
    project.pool_id = $scope.pool_id;

    $projects.create(project).then(function(data) {
      console.log(data);
    });
  }

  $scope.addSplit = function() {
    var split = validateSplit($scope.split);
    if (!split) { return; }
    $scope.splits.push(split);
    initSplit();
  }

  $scope.editSplit = function(index) {
    $scope.split = angular.copy($scope.splits[index]);
    $scope.currentIdx = index;
  }

  $scope.removeSplit = function(index) {
    $scope.splits.splice(index, 1);
  }

  $scope.isEditing = function(index) {
    return $scope.currentIdx !== -1;
  }

  $scope.cancelEditing = function() {
    $scope.currentIdx = -1;
    initSplit();
  }

  $scope.updateSplit = function(index) {
    var split = validateSplit($scope.split);
    if (!split) { return; }
    $scope.splits[$scope.currentIdx] = split;
    $scope.cancelEditing();
  }

  $scope.createPool = function() {
    var total = splitTotal();
    if (total != 100) {
      $scope.errors = "Please adjust percentages to equal 100%. Currently " + total + "%";
      return;
    }

    $pools.create($scope.splits).then(function(data) {
      $scope.pool_id = data.pool_id;
    });
  }
}]);
