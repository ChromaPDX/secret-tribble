var app = angular.module('chromaApp', [
  'ui.router',
  'mm.foundation',
  'restangular'
]);

app.config(['$httpProvider', function($httpProvider) {
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
}
]);

app.config(['$stateProvider', '$urlRouterProvider', function ($stateProvider, $urlRouterProvider) {
  $urlRouterProvider.otherwise('/');
  $stateProvider
    .state('login', {
      url: '/login',
      templateUrl: 'templates/login.html'
    })
    .state('landing', {
      url: '/',
      templateUrl: 'templates/landing.html'
    })
    .state('authenticated', {
      templateUrl: 'templates/main.html'
    })
    .state('dashboard', {
      url: '/dashboard',
      parent: 'authenticated',
      templateUrl: 'templates/dashboard.html'
    })
    .state('projects', {
      abstract: true,
      url: '/projects',
      parent: 'authenticated',
      template: '<ui-view/>'
    })
    .state('projects.index', {
      url: '',
      templateUrl: 'templates/projects/index.html',
      controller: 'ProjectsController'
    })
    .state('projects.new', {
      url: '/new',
      templateUrl: 'templates/projects/new.html',
      controller: 'ProjectsController'
    })
}
]);

app.config(function(RestangularProvider) {
   RestangularProvider.setBaseUrl('/v1');
   RestangularProvider.setRequestSuffix('.json');
});
