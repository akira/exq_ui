var ShowRoute;
import Ember from "ember";

ShowRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.findRecord('queue', params.id).then(function(myModel) {
      if (myModel.get('partial')) {
        return myModel.reload();
      }
    });
  }
});

export default ShowRoute;
