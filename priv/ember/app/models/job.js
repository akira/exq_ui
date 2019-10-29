import DS from 'ember-data';
import Ember from 'ember';

var Job = DS.Model.extend({
  queue: DS.attr('string'),
  "class": DS.attr('string'),
  args: DS.attr(),
  enqueued_at: DS.attr('date'),
  started_at: DS.attr('date'),
  parsed_args: Ember.computed('args', function() {
    return JSON.stringify(this.get('args'));
  })
});

export default Job;
