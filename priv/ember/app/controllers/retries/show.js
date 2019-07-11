import request from 'ic-ajax';
import Ember from "ember";
var ShowController;

ShowController = Ember.Controller.extend({
  actions: {
    removeRetry: function(retry) {
      var self;
      self = this;
      retry.deleteRecord();
      return retry.save().then(function(_f) {
        return self.send('reloadStats');
      });
    },
    requeueRetry: function(retry) {
      var self;
      self = this;
      return retry.save().then(function(_f) {
        self.send('reloadStats');
        return self.store.unloadRecord(retry);
      });
    }
  }
});

export default ShowController;
