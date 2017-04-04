import request from 'ic-ajax';
import Ember from "ember";

var IndexController = Ember.Controller.extend({
  actions: {
    clearFailures: function() {
      var self;
      self = this;
      return request({
        url: "api/failures",
        type: "DELETE"
      }).then(function() {
        self.store.unloadAll('failure');
        return self.send('reloadStats');
      });
    },
    retryFailure: function(_failure) {},
    removeFailure: function(failure) {
      var self;
      self = this;
      failure.deleteRecord();
      return failure.save().then(function(_f) {
        return self.send('reloadStats');
      });
    }
  }
});

export default IndexController;
