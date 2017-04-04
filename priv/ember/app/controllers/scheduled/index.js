import request from 'ic-ajax';
import Ember from "ember";
var IndexController;

IndexController = Ember.Controller.extend({
  actions: {
    clearScheduled: function() {
      var self;
      self = this;
      return request({
        url: "api/scheduled",
        type: "DELETE"
      }).then(function() {
        self.store.unloadAll('scheduled');
        return self.send('reloadStats');
      });
    },
    removeScheduled: function(scheduled) {
      var self;
      self = this;
      scheduled.deleteRecord();
      return scheduled.save().then(function(_f) {
        return self.send('reloadStats');
      });
    }
  }
});

export default IndexController;
