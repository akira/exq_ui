var IndexRoute;
import Ember from "ember";

IndexRoute = Ember.Route.extend({
  timeout: null,
  setupController: function(controller, model) {
    var self, updater;
    this._super(controller, model);
    self = this;
    updater = window.setInterval(function() {
      return self.store.findAll('realtime').then(function(data) {
        controller.set('dashboard_data', data);
        return controller.set('date', new Date());
      });
    }, 2000);
    return this.set('timeout', updater);
  },
  deactivate: function() {
    clearInterval(this.get('timeout'));
    return this.set('timeout', null);
  }
});

export default IndexRoute;
