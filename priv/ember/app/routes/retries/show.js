var ShowRoute;
import Ember from "ember";

ShowRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.findRecord('retry', params.id);
  }
});

export default ShowRoute;
