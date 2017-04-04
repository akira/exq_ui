import DS from 'ember-data';
import Job from './job';

var Failure = Job.extend({
  failed_at: DS.attr('date'),
  error_message: DS.attr('string')
});

export default Failure;
