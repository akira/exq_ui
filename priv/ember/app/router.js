import Ember from 'ember'
import config from './config/environment'

let Router = Ember.Router.extend({
  location: config.locationType
});


Router.map(function() {
  this.route('index', {path: '/'});

  this.route('queues', {resetNamespace: true }, function() {
    this.route('show', {path: '/:id'});
  });

  this.route('processes', {resetNamespace: true }, function() {
    this.route('index', {path: '/'});
  });

  this.route('scheduled', {resetNamespace: true }, function() {
    this.route('index', {path: '/'});
  });

  this.route('retries', {resetNamespace: true }, function() {
    this.route('index', {path: '/'});
  });

  this.route('failures', {resetNamespace: true }, function() {
    this.route('index', {path: '/'});
  });
});

export default Router