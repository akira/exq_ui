import request from 'ic-ajax';
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
        console.log("clearScheduled request finished");
        self.store.unloadAll('scheduled');
        return self.send('reloadStats');
      });
    },
    removeScheduled: function(scheduled) {
      var self;
      self = this;
      scheduled.deleteRecord();
      return scheduled.save().then(function(f) {
        return self.send('reloadStats');
      });
    }
  }
});

export default IndexController;
