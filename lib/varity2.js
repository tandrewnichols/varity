var extend = require('config-extend'),
    standardOptions = require('./opts');

var Varity = exports.Varity = function Varity () {
  this.options = extend({}, standardOptions, Varity._globalOptions);
  this.expectations = [];
};

Varity.prototype.wrap = function() {
  var self = this;
  if (arguments.length < 1) throw new Error('No function passed to varity');
};

Varity.configure = function(opts) {
  Varity._globalOptions = opts;
};

Varity.reset = function() {
  Varity._globalOptions = {};
};

Varity._globalOptions = {};
