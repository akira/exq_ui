var ApplicationRoute;

ApplicationRoute = Ember.Route.extend({
  model: function(params) {
    return this.get('store').findRecord('stat', 'all');
  },
  actions: {
    reloadStats: function() {
      return this.get('store').findRecord('stat', 'all').then(function(stats) {
        return stats.reload();
      });
    }
  }
});

export default ApplicationRoute;
