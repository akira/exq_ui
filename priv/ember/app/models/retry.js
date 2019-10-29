import DS from 'ember-data';
import Ember from 'ember';

var Retry = DS.Model.extend({
  queue: DS.attr('string'),
  "class": DS.attr('string'),
  args: DS.attr(),
  failed_at: DS.attr('date'),
  error_message: DS.attr('string'),
  retry: DS.attr('boolean'),
  retry_count: DS.attr('number'),
  parsed_args: Ember.computed('args', function() {
    return JSON.stringify(this.get('args'));
  })
});

export default Retry;
