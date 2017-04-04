import DS from 'ember-data';

var Realtime = DS.Model.extend({
  timestamp: DS.attr('date'),
  count: DS.attr('number')
});

export default Realtime;
