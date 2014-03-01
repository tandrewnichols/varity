var extend = require('config-extend'),
    _ = require('underscore'),
    standardOptions = require('./opts');

var Varity = exports.Varity = function Varity () {
  this.options = extend({}, standardOptions, Varity._globalOptions);
  this.expectations = [];
  this.fnArgs = [];
  this.buildExpressions();
};

Varity._globalOptions = {};

Varity.configure = function(opts) {
  Varity._globalOptions = opts;
};

Varity.reset = function() {
  Varity._globalOptions = {};
};

Varity.prototype.buildExpressions = function() {
  var symbols = _(this.options.symbols).keys().join('');
  var letters = _(this.options.letters).keys().join('');
  letters = '[' + letters + ']';
  symbols = '[' + symbols.replace(/\[\]/, '');
  var array = '\\[' + letters + '\\]';
  var or = '\\|';
  this.options.expressions = [
    new RegExp('^' + letters + or + array),
    new RegExp('^' + array + or + array),
    new RegExp('^' + array + or + letters),
    new RegExp('^\\[' + letters + or + letters + '\\]'),
    new RegExp('^' + array),
    new RegExp('^' + letters + or + letters),
    new RegExp('^' + letters)
  ];
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
    self.buildEvaluator({
      type: [_(expectation).stringify()]
    });
    break;
  case 'Array':
    _(expectation).each(function(exp) {
      self.buildEvaluator({
        type: [_(exp).capitalize()]
      });
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

Varity.prototype.tokenize = function(str) {
  var self = this;
  for (var i = 0; i < this.options.expressions.length; i++) {
    var captures = this.options.expressions[i].exec(str);
    if (captures) {
      str = str.substr(captures[0].length);
      self.parse(captures[0]);
      break;
    } else if (i === this.options.expressions.length - 1) {
      return;
    }
  }
  if (str) {
    self.tokenize(str);
  } else {
    return;
  }
};

Varity.prototype.parse = function(capture) {
  var self = this;
  var context = {
    operations: new RegExp('[^' + _(this.options.letters).keys().join('') + ']', 'g').exec(capture)
  };
  this.buildEvaluator(context);
};

Varity.prototype.buildEvaluator = function(context) {
  this.expectations.push(function(arg, next) {
    if (arg.constructor.name === type) {
      this.fnArgs.push(arg);
    }
  });
}

Varity.prototype.buildParams = function() {

};
