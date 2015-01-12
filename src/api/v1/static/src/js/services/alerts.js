app.factory('$alerts', ['$rootScope', function($rootScope) {
    var alerts = {};

    var addAlert = function(type, msg, append) {
      if (typeof append === 'undefined') {
        alerts.clearAll();
      }
      $rootScope.alerts.push({
        type: type,
        msg: msg
      });
    }

    alerts.addErrors = function(errors) {
      alerts.clearAll();
      errors.forEach(function(error) {
        alerts.addDanger(error, true);
      });
    }

    alerts.addDanger = function(msg, append) {
      addAlert('alert', msg, append);
    };

    alerts.addInfo = function(msg, append) {
      addAlert('info', msg, append);
    };

    alerts.addSuccess = function(msg, append) {
      addAlert('success', msg, append);
    };

    alerts.addWarning = function(msg, append) {
      addAlert('warning', msg, append);
    };

    alerts.remove = function(index) {
      $rootScope.alerts.splice(index, 1);
    }

    alerts.clearAll = function() {
      $rootScope.alerts.length = 0;
    }

    return alerts;
}]);
