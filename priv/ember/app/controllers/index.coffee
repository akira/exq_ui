IndexController = Ember.Controller.extend
  date: null,
  chartOptions: {
    bezierCurve : false,
    animation: false,
    scaleShowLabels: true,
    showTooltips: true,
    responsive: true,
    pointDot : false,
    pointHitDetectionRadius : 2
  }

  graph_dashboard_data: {
    labels: [],
    datasets: [data:[]]
  }

  dashboard_data: {}

  compareDates: (a, b) ->
    a1 = moment(a).utc().format()
    b1 = moment(b).utc().format()
    a1 == b1

  set_graph_dashboard_data: (->
    if @get('date') != null
      # Get the last 60 seconds
      d = moment.utc(@get('date'))
      labels = []
      mydates = []
      for t in [0...60]
        labels.push("")
        mydates.push(moment.utc(d.valueOf() - (t*1000)))

      @store.findAll('realtime').then( (rtdata) =>
        success_set = []
        failure_set = []

        for dt in mydates
          successes = rtdata.filter((d) => d.id.startsWith("s") && @compareDates(dt, d.get('timestamp')))
          failures  = rtdata.filter((d) => d.id.startsWith("f") && @compareDates(dt, d.get('timestamp')))

          # TODO: aggregate count
          s = successes.length # s = successes[0].get('count') if successes.length > 0
          f = failures.length # f = failures[0].get('count') if failures.length > 0

          success_set.push(s)
          failure_set.push(f)

        _data = {
          labels: labels,
          datasets: [
            {
              label: "Failures",
              fillColor: "rgba(255,255,255,0)",
              strokeColor: "rgba(151,187,205,1)",
              pointColor: "rgba(151,187,205,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#fff",
              pointHighlightStroke: "rgba(151,187,205,1)",
              data: success_set.reverse()
            },
            {
              label: "Sucesses",
              fillColor: "rgba(255,255,255,0)",
              strokeColor: "rgba(238,77,77,1)",
              pointColor: "rgba(238,77,77,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#fff",
              pointHighlightStroke: "rgba(238,77,77,1)",
              data: failure_set.reverse()
            }
          ]
        }

        @set("graph_dashboard_data", _data);
      )
  ).observes('dashboard_data', 'date')

`export default IndexController`
