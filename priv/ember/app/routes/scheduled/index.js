var IndexRoute;
import Ember from "ember";

IndexRoute = Ember.Route.extend({
  model: function(_params) {
    return this.store.findAll('scheduled');
  }
});

export default IndexRoute;
