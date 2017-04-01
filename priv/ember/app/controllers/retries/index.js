import request from 'ic-ajax';
var IndexController;

IndexController = Ember.Controller.extend({
  actions: {
    clearRetries: function() {
      var self;
      self = this;
      return request({
        url: "api/retries",
        type: "DELETE"
      }).then(function() {
        console.log("clearRetries request finished");
        self.store.unloadAll('retry');
        return self.send('reloadStats');
      });
    },
    removeRetry: function(retry) {
      var self;
      self = this;
      retry.deleteRecord();
      return retry.save().then(function(f) {
        return self.send('reloadStats');
      });
    },
    requeueRetry: function(retry) {
      var self;
      self = this;
      return retry.save().then(function(f) {
        self.send('reloadStats');
        return self.store.unloadRecord(retry);
      });
    }
  }
});

export default IndexController;
