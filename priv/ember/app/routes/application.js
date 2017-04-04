var ApplicationRoute;
import Ember from "ember";

ApplicationRoute = Ember.Route.extend({
  model: function(_params) {
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
