var IndexController;
import Ember from "ember";

IndexController = Ember.Controller.extend({
  actions: {
    clearProcesses: function() {
      var self;
      self = this;
      return jQuery.ajax({
        url: window.exqNamespace + "api/processes",
        type: "DELETE"
      }).done(function() {
        return self.store.findAll('process').forEach(function(p) {
          p.deleteRecord();
          return self.send('reloadStats');
        });
      });
    }
  }
});

export default IndexController;
