app.controller("ProjectsController", ['$scope', '$projects', '$pools', '$alerts', function($scope, $projects, $pools, $alerts) {

  var initSplit = function() {
    $scope.split = {percent: 0};
  }

  var loadProjects = function() {
    $projects.all().then(function(data) {
      $scope.projects = data;
    });
  }

  var init = function() {
    loadProjects();
    initSplit();
  
    $scope.currentIdx = -1;
    $scope.splits = [];
    $scope.pool_id = -1;
    $scope.project = {};
  }

  init();

  var splitTotal = function() {
    var total = 0;
    if (!$scope.isEditing()) {
      total = parseInt($scope.split.percent);
    }
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
        $alerts.addDanger("Please enter a valid values");
        return false;
    }

    var total = splitTotal();
    if (total > 100) {
      $alerts.addInfo("Please adjust percentages to equal 100%. Currently " + total + "%");
      return false;
    }

    return split;
  }

  var parseSplits = function(splits) {
    var splits = angular.copy($scope.splits);
    var parsed = {}
    angular.forEach(splits, function(split) {
      split.percent = parseInt(split.percent) / 100.0;
      parsed[split.email] = split.percent;
    });

    return parsed;
  }


  $scope.createProject = function() {
    if ($scope.pool_id === -1) {
      $alerts.addDanger("You need to create Pool first.");
      return;
    }

    var project = $scope.project;
    project.pool_id = $scope.pool_id;

    $projects.create(project)
      .then(function(data) {
        init();
        $alerts.addSuccess('Project is successfully created!');
        loadProjects();
        $state.go('project.index');
      })
      .catch(function(data) {
        $alerts.addErrors(data.errors);
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
      $alerts.addInfo("Please adjust percentages to equal 100%. Currently " + total + "%");
      return;
    }

    var splits = parseSplits($scope.splits);

    $pools.create(splits)
      .then(function(data) {
        $scope.pool_id = data.pool_id;
        $alerts.addSuccess('Pool is successfully created!');
      })
      .catch(function(data) {
        $alerts.addErrors(data.errors);
      });
  }
}]);
