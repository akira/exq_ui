import ActiveModelAdapter from 'active-model-adapter';

var ApplicationAdapter = ActiveModelAdapter.extend({
  namespace: window.exqNamespace + "api"
});

export default ApplicationAdapter;
