var extend = require('config-extend'),
    _ = require('underscore'),
    standardOptions = require('./opts');

_.mixin(require('safe-obj'));

var Varity = exports.Varity = function Varity () {
  this.options = extend({}, standardOptions, Varity._globalOptions, {
    operations: {
      before: Varity._before,
      after: Varity._after
    }
  });
  Varity._before = {};
  Varity._after = {};
  this.letters = _(this.options.letters).keys().join('');
  this.symbols = _(this.options.symbols).keys().join('');
  this.expectations = [];
  this.fnArgs = [];
  this.buildExpressions();
};

Varity._globalOptions = {};
Varity._before = {};
Varity._after = {};

Varity.configure = function(opts) {
  Varity._globalOptions = opts;
};

Varity.before = function(symbol, operation) {
  if (Varity._before[symbol]) {
    Varity._before[symbol].push(operation);
  } else {
    Varity._before[symbol] = [operation];
  }
};

Varity.after = function(symbol, operation) {
  if (Varity._after[symbol]) {
    Varity._after[symbol].push(operation);
  } else {
    Varity._after[symbol] = [operation];
  }
};

Varity.reset = function() {
  Varity._globalOptions = {};
  Varity._instanceOptions = {};
};

Varity.prototype.buildExpressions = function() {
  var letters = '[' + this.letters + ']';
  var symbols = '[' + this.symbols + ']*';
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
    self.parseSpecialSymbols(context);
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
    context.nextArg = next;
    var res = _(context.symbols).reduce(function(memo, symbol) {
      memo = self.options.symbols[symbol].call(self, memo, context);
      return memo;
    }, self.getMatch(arg, context.types));
    self.fnArgs.push(res);
  });
};

Varity.prototype.getOperations = function(context) {
  var self = this;
  return _(context.symbols).reduce(function(memo, symbol) {
    if (_(self).safe('options.operations.before.' + symbol)) {
      memo = memo.concat(self.options.operations.before[symbol]);
    }
    memo.push(self.options.symbols[symbol]);
    if (_(self).safe('options.operations.after.' + symbol)) {
      memo = memo.concat(self.options.operations.after[symbol]);
    }
    return memo;
  }, []);
};

Varity.prototype.thingOrDefault = function(actual, expected) {
  return ~expected.indexOf(_(actual).stringify()) ? actual : undefined;
};

Varity.prototype.parseSpecialSymbols = function(context) {
  if (/\[.*\]\|\[.*\]/.test(context.types)) {
    context.arrayType = 'array or array';
  } else if (/\[.*\|.*\]/.test(context.types)) {
    context.arrayType = 'or inside array';
  } else if (/\[.*\]\|.*/.test(context.types)) {
    context.arrayType = 'array or type';
  } else if (/.*\|\[.*\]/.test(context.types)) {
    context.arrayType = 'type or array';
  } else if (/.*\|.*/.test(context.types)) {
    context.arrayType = 'type or type';
  } else if (/\[.*\]/.test(context.types)) {
    context.arrayType = 'array';
  } else {
    context.arrayType = '';
  }
  context.types = context.types.replace(/[\[\]]/g, '').split('|');
};

Varity.prototype.getMatch = function(context, arg) {
  switch(context.arrayType) {
  case 'array or array':
  case 'or inside array':
  case 'array':
    return [this.thingOrDefault(arg, context.types)];
  case 'array or type':
    var thing = this.thingOrDefault(arg, context.types[0]);
    return thing ? [thing] : this.thingOrDefault(arg, context.types[1]);
  case 'type or array':
    var thing = this.thingOrDefault(arg, context.types[0]);
    return thing ? thing : [this.thingOrDefault(arg, context.types[1])];
  default:
    return this.thingOrDefault(arg, context.types);
  }
};

Varity.prototype.buildParams = function() {

};
