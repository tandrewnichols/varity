var extend = require('config-extend'),
    _ = require('underscore'),
    standardOptions = require('./opts');

var Varity = exports.Varity = function Varity () {
  this.options = extend({}, standardOptions, Varity._globalOptions);
  this.letters = _(this.options.letters).keys().join('');
  this.symbols = _(this.options.symbols).keys().join('').replace(/[[\]|]/g, '');
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
  var letters = '[' + this.letters + ']';
  var symbols = '[' + this.symbols.replace(/\[\]/, '') + ']?';
  var array = '\\[' + letters + '\\]';
  var or = '\\|';
  this.options.expressions = [
    symbols + letters + or + array,
    symbols + array + or + array,
    symbols + array + or + letters,
    symbols + '\\[' + letters + or + letters + '\\]',
    symbols + array,
    symbols + letters + or + letters,
    symbols + letters
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
  switch (_(expectation || {}).stringify()) {
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
  }
};

Varity.prototype.tokenize = function(str) {
  var matches = str.match(new RegExp(this.options.expressions.join('|'), 'g'));
  this.parse(matches || []);
};

Varity.prototype.parse = function(matches) {
  var self = this;
  matches =_(matches).map(self.expandTypes); 
  contexts = self.mapSymbols(matches);
  _(contexts).each(self.buildEvaluator);
};

Varity.prototype.mapSymbols = function(matches) {
  var self = this;
  return _(matches).reduce(function(memo, match) {
    var symbols = new RegExp('[' + self.symbols + ']', 'g');
    memo.push({
      symbols: match.match(symbols) || [],
      types: match.replace(symbols, '')
    });
    return memo;
  }, []);
};

Varity.prototype.expandTypes = function(match) {
  var self = this;
  return match.replace(new RegExp('[' + this.letters + ']', 'g'), function(m) {
    return self.options.letters[m];
  });
};

Varity.prototype.buildEvaluator = function(context) {
  var self = this;
  this.expectations.push(function(arg, next) {
    var res = self.isTypeMatch(arg, context.types) ? arg : undefined;
    _(context.symbols).each(function(symbol) {
      res = self.options.symbols[symbol](res, next);
    });
    self.fnArgs.push(res);
  });
};

Varity.prototype.isTypeMatch = function(actual, expected) {
  return ~expected.indexOf(_(actual).stringify());
};

Varity.prototype.buildParams = function() {

};
