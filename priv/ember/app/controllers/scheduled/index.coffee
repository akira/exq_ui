`import request from 'ic-ajax'`

IndexController = Ember.Controller.extend

  actions:
    clearScheduled: ->
      self = this
      # jQuery.ajax({url: "#{window.exqNamespace}api/failures", type: "DELETE"}).done(->
      request({url: "api/scheduled", type: "DELETE"}).then ->
        console.log("clearScheduled request finished")
        self.store.unloadAll('scheduled')
        self.send('reloadStats')
    removeScheduled: (scheduled) ->
      self = this
      scheduled.deleteRecord()
      scheduled.save().then((f) ->
        self.send('reloadStats')
      )



`export default IndexController`
