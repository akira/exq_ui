import request from 'ic-ajax';

var IndexController = Ember.Controller.extend({
  actions: {
    clearFailures: function() {
      var self;
      self = this;
      return request({
        url: "api/failures",
        type: "DELETE"
      }).then(function() {
        console.log("clearFailures request finished");
        self.store.unloadAll('failure');
        return self.send('reloadStats');
      });
    },
    retryFailure: function(failure) {},
    removeFailure: function(failure) {
      var self;
      self = this;
      failure.deleteRecord();
      return failure.save().then(function(f) {
        return self.send('reloadStats');
      });
    }
  }
});

export default IndexController;
