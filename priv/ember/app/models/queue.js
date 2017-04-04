import DS from 'ember-data';

var Queue = DS.Model.extend({
  size: DS.attr('number'),
  jobs: DS.hasMany('job'),
  partial: true
});

export default Queue;
