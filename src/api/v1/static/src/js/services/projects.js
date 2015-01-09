app.factory("$projects", ["$auth", "$state", "Restangular", function($auth, $state, Restangular) {
    var project = {};
    var token = $auth.token();

    project.get = function(id) {
      return Restangular.all("projects").getList({
        token_id: token,
        project_id: id
      });
    };

    project.all = function() {
      return Restangular.all("projects").getList({
        token_id: token
      });
    };

    project.create = function(attrs) {
      var restangular = Restangular.all("projects");
      attrs.token_id = token;
      return restangular.post(attrs);
    };

    return project;
  }
]);
