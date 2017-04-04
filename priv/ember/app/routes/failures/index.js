var IndexRoute;

IndexRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.findAll('failure');
  }
});

export default IndexRoute;
