app.factory("$pools", ["$auth", "$state", "Restangular", function($auth, $state, Restangular) {
    var pool = {};
    var token = $auth.token();

    pool.get = function(id) {
      return Restangular.all("pools").getList({
        token_id: token,
        pool_id: id
      });
    };

    pool.create = function(splits) {
      var restangular = Restangular.all("pools");
      return restangular.post({
        pool: JSON.stringify({splits: splits}),
        token_id: token
      });
    };

    pool.update = function(attrs) {
      var restangular = Restangular.all("pools");
      attrs.token_id = token;
      return restangular.post(attrs);
    };

    return pool;
  }
]);
