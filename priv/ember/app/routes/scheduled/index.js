var IndexRoute;

IndexRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.findAll('scheduled');
  }
});

export default IndexRoute;
