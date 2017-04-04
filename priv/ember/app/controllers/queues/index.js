var IndexController;
import Ember from "ember";

IndexController = Ember.Controller.extend({
  actions: {
    clearAll: function() {
      return alert('clearAll');
    },
    deleteQueue: function(queue) {
      var self;
      if (confirm("Are you sure you want to delete " + queue.id + " and all its jobs?")) {
        self = this;
        queue.deleteRecord();
        return queue.save().then(function(_q) {
          return self.send('reloadStats');
        });
      }
    }
  }
});

export default IndexController;
