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
  _(matches).each(function(match) {
    var context = {
      symbols: self.mapSymbols(match),
      types: self.expandTypes(match).replace(new RegExp('[' + self.symbols + ']', 'g'), '')
    };
    context.arrayType = self.parseSpecialSymbols(context.types);
    self.buildEvaluator(context);
  });
};

Varity.prototype.mapSymbols = function(match) {
  return match.match(new RegExp('[' + this.symbols + ']', 'g')) || [];
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
    var res = _(context.symbols).reduce(function(memo, symbol) {
      memo = self.options.symbols[symbol](memo, next);
      return memo;
    }, self.getMatch(arg, context.types));
    self.fnArgs.push(res);
  });
};

Varity.prototype.thingOrDefault = function(actual, expected) {
  return ~expected.indexOf(_(actual).stringify()) ? actual : undefined;
};

Varity.prototype.parseSpecialSymbols = function(types) {
  if (/\[.*\]\|\[.*\]/.test(types)) {
    return 'array or array';
  } else if (/\[.*\|.*\]/.test(types)) {
    return 'or inside array';
  } else if (/\[.*\]\|.*/.test(types)) {
    return 'array or type';
  } else if (/.*\|\[.*\]/.test(types)) {
    return 'type or array';
  } else if (/.*\|.*/.test(types)) {
    return 'type or type';
  } else if (/\[.*\]/.test(types)) {
    return 'array';
  } else {
    return '';
  }
};

Varity.prototype.getMatch = function(context, arg) {
  switch(context.arrayType) {
  case 'array or array':
  case 'or inside array':
  case 'array':
    return [this.thingOrDefault(arg, context.types)];
  case 'array or type':
    var types = context.types.split('|');
    var thing = this.thingOrDefault(arg, types[0]);
    return thing ? [thing] : this.thingOrDefault(arg, types[1]);
  case 'type or array':
    var types = context.types.split('|');
    var thing = this.thingOrDefault(arg, types[0]);
    return thing ? thing : [this.thingOrDefault(arg, types[1])];
  default:
    return this.thingOrDefault(arg, context.types);
  }
};

Varity.prototype.buildParams = function() {

};
