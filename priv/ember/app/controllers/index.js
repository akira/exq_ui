import moment from 'moment';
import Ember from "ember";

var IndexController = Ember.Controller.extend({
  date: null,
  chartOptions: {
    bezierCurve: false,
    animation: false,
    scaleShowLabels: true,
    showTooltips: true,
    responsive: true,
    pointDot: false,
    pointHitDetectionRadius: 2
  },
  graph_dashboard_data: {
    labels: [],
    datasets: [
      {
        data: []
      }
    ]
  },
  dashboard_data: {},
  compareDates: function(a, b) {
    var a1, b1;
    a1 = moment(a).utc().format();
    b1 = moment(b).utc().format();
    return a1 === b1;
  },
  set_graph_dashboard_data: (function() {
    var d, i, labels, mydates, t;
    if (this.get('date') !== null) {
      d = moment.utc(this.get('date'));
      labels = [];
      mydates = [];
      for (t = i = 0; i < 60; t = ++i) {
        labels.push("");
        mydates.push(moment.utc(d.valueOf() - (t * 1000)));
      }
      return this.store.findAll('realtime').then((function(_this) {
        return function(rtdata) {
          var _data, dt, f, failure_set, failures, j, len, s, success_set, successes;
          success_set = [];
          failure_set = [];
          for (j = 0, len = mydates.length; j < len; j++) {
            dt = mydates[j];
            successes = rtdata.filter(function(d) {
              return d.id.startsWith("s") && _this.compareDates(dt, d.get('timestamp'));
            });
            failures = rtdata.filter(function(d) {
              return d.id.startsWith("f") && _this.compareDates(dt, d.get('timestamp'));
            });
            s = successes.length;
            f = failures.length;
            success_set.push(s);
            failure_set.push(f);
          }
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
              }, {
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
          };
          return _this.set("graph_dashboard_data", _data);
        };
      })(this));
    }
  }).observes('dashboard_data', 'date')
});

export default IndexController;
