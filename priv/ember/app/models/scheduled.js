import DS from 'ember-data';
import Job from './job';
var Scheduled = Job.extend({
  scheduled_at: DS.attr('date')
});

export default Scheduled;
