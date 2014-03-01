var extend = require('config-extend'),
    _ = require('underscore'),
    standardOptions = require('./opts');

var Varity = exports.Varity = function Varity () {
  this.options = extend({}, standardOptions, Varity._globalOptions);
  var letters = _(this.options.letters).keys().join('');
  var symbols = _(this.options.symbols).keys().join('');
  this.options.expressions = [
    new RegExp('^' + letters)
  ];
  this.expectations = [];
  this.applyArgs = [];
};

Varity._globalOptions = {};

Varity.configure = function(opts) {
  Varity._globalOptions = opts;
};

Varity.reset = function() {
  Varity._globalOptions = {};
};

Varity.prototype.wrap = function() {
  var self = this;
  if (arguments.length < 1) throw new Error('No function passed to varity');
  var args = [].slice.call(arguments);
  var fn = args.pop();
  if (!_(fn).isFunction()) throw new Error('Last argument is not a function');
  _(args).each(self.buildExpectations);
  return function() {
    return fn.apply(fn, self.buildParams([].slice.call(arguments)));
  };
};

Varity.prototype.buildExpectations = function(expectation) {
  var self = this;
  switch ((expectation || {}).constructor.name) {
  case 'Function':
    self.expectations.push(function(arg) {
      return arg.constructor.name === _(expectation).stringify();
    });
    break;
  case 'Array':
    _(expectation).each(function(exp) {
      self.handleArray(exp);
    });
    break;
  case 'String':
    self.tokenize(expectation);
    break;
  default:
    throw new Error('Arguments to varity must be of type function, array, or string');
    break;
  }
};

Varity.prototype.handleArray = function(expectation) {
  this.expectations.push(function(arg) {
    return arg.constructor.name === _(expectation).capitalize();
  });
};


Varity.prototype.buildParams = function() {

};

Varity.prototype.tokenize = function(str) {
  var self = this;
  for (var i = 0; i < this.options.expressions.length; i++) {
    var captures;
    if (captures = this.options.expressions[i].exec(str)) {
      str = str.substr(captures[0].length);
      self.expectations.push(function(arg, next) {
        if (arg.constructor.name === self.options.letters[captures[0]]) {
          self.applyArgs.push(arg);
        }
      });
      break;
    } else {
      return;
    }
  }
  if (str) {
    self.tokenize(str);
  } else {
    return;
  }
};
