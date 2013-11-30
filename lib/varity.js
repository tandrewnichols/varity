var _ = require('underscore'),
    extend = require('config-extend');

_.mixin({
  isError: function(thing) {
    try {
      return thing.constructor.name === 'Error';
    } catch (e) {
      return false;
    }
  },
  isAnonObject: function(thing) {
    try {
      return thing.constructor.name === 'Object';
    } catch (e) {
      return false;
    }
  },
  isInfinity: function(thing) {
    return typeof thing === 'number' && !_.isNaN(thing) && !_.isFinite(thing);
  }
});

var options, _options = {
  letters: {
    's':'String',
    'f':'Function',
    'o':'AnonObject',
    'A':'Array',
    '1':'Number',
    'b':'Boolean',
    'r':'RegExp',
    'd':'Date',
    'N':'NaN',
    'n':'Null',
    'u':'Undefined',
    'a':'Arguments',
    'i':'Infinity',
    'e':'Error',
    '-':'-',
    '+':'+'
  },
  populate: {
    'String': '',
    'Function': function(){},
    'AnonObject': {},
    'Array': [],
    'Number': 0,
    'Boolean': false,
    'RegExp': /.*/,
    'Date': function() {
      return new Date();
    },
    'NaN': NaN,
    'Null': null,
    'Undefined': undefined,
    'Arguments': (function(){ return arguments; })(undefined),
    'Infinity': 2/0,
    'Error': function() {
      return new Error();
    }
  },
  expand: []
};

var standard = {
  'string': 'String',
  'function': 'Function',
  'object': 'AnonObject',
  'array': 'Array',
  'number': 'Number',
  'boolean': 'Boolean',
  'regexp': 'RegExp',
  'date': 'Date',
  'nan': 'NaN',
  'null': 'Null',
  'undefined': 'Undefined',
  'arguments': 'Arguments',
  'infinity': 'Infinity',
  'error': 'Error',
  'anonobject': 'AnonObject'
};

var Varity = function Varity () {
  var self = this;
  self.options = options || _options;
  if (self.options.expand === true) {
    self.options.expand = _.keys(self.options.populate);
  } else if (_.isArray(self.options.expand)) {
    self.options.expand = _(self.options.expand).reduce(function(memo, type) {
      memo.push(standard[type.toLowerCase()]);
      return memo;
    }, []);
  }
    
  self.expected = []; 
  self.convert = Varity.prototype.convert.bind(this);
  self.standardize = Varity.prototype.standardize.bind(self);
  self.checkArg = Varity.prototype.checkArg.bind(self);
  self.buildParams = Varity.prototype.buildParams.bind(self);
  self.stringify = Varity.prototype.stringify.bind(self);
  self.pushArg = Varity.prototype.pushArg.bind(self);
};

Varity.prototype.wrap = function() {
  var self = this;
  if (arguments.length < 1) {
    throw new Error('No function passed to varity');
  } else {
    var args = Array.prototype.slice.call(arguments);
    var fn = args.pop();
    if (typeof fn !== 'function') {
      throw new Error('Last argument is not a function');
    } else {
      args.forEach(self.checkArg);
      return function() {
        fn.apply(fn, self.buildParams(Array.prototype.slice.call(arguments)));
      };
    }
  }
};

module.exports = {
  wrap: function() {
    var v = new Varity();
    return v.wrap.apply(v, arguments);
  },
  configure: function(opts) {
    options = extend({}, _options, opts);
  },
  reset: function() {
    options = undefined;
  }
};

Varity.prototype.standardize = function (thing) {
  var self = this;
  var arg = thing.toLowerCase();
  if (standard[arg]) {
    return standard[arg];
  } else if (/^[A-Z]/.test(thing)) {
    // Custom type
    var mixin = {};
    mixin['is' + thing] = function(customThing) {
      try {
        return customThing.constructor.name === thing;
      } catch (e) {
        return false;
      }
    };
    _.mixin(mixin);
    return thing;
  } else {
    _(thing.trim().split('')).reduce(self.convert, []).forEach(self.checkArg);
    return '';
  }
};

Varity.prototype.checkArg = function (arg) {
  var self = this;
  var optional = false, expand = false;
  if (_.isString(arg) && /^[-+]+/.exec(arg)) {
    if (arg.indexOf('-') !== -1) {
      optional = true;
    }
    if (arg.indexOf('+') !== -1) {
      expand = true;
    }
    arg = arg.replace(/[-+]+/g, '');
  }

  if (_.isString(arg)) {
    var expectation = self.standardize(arg);
    if (expectation) {
      self.expected.push({
        type: expectation,
        optional: optional,
        expand: expand
      });
    }
  } else if (_.isFunction(arg)) {
    self.expected.push({
      type: self.standardize(self.stringify(arg)),
      optional: optional,
      expand: expand
    });
  } else if (_.isArray(arg)) {
    _(arg).flatten().forEach(self.checkArg);
  } else if (_.isNull(arg)) {
    self.expected.push({
      type: 'Null',
      optional: optional,
      expand: expand
    });
  } else if (_.isUndefined(arg)) {
    self.expected.push({
      type: 'Undefined',
      optional: optional,
      expand: expand
    });
  } else if (_.isAnonObject(arg)) {
    var type = _.isString(arg.type) ? arg.type : self.stringify(arg.type);
    arg.type = self.standardize(type);
    self.expected.push(arg);
  }
};

Varity.prototype.convert = function (memo, l) {
  var self = this;
  if (!self.options.letters[l]) {
    throw new Error('Unrecognized type: ' + l);
  } else {
    if (/^[-+]+$/.test(memo[memo.length - 1])) {
      memo[memo.length - 1] += self.options.letters[l];
    } else {
      memo.push(self.options.letters[l]);
    }
    return memo;
  }
};

Varity.prototype.buildParams = function (actual) {
  var self = this;
  return _(self.expected).reduce(function(memo, e) {
    var a = actual.shift();
    if (_(a)['is' + e.type]()) {
      if (e.optional && (!actual[0] || !_(actual[0])['is' + e.type]())) {
        memo.push(self.pushArg(e));
        actual.unshift(a);
      } else {
        memo.push(a);
      }
    } else {
      memo.push(self.pushArg(e));
      actual.unshift(a);
    }
    return memo;
  }, []);
};

Varity.prototype.stringify = function(thing) {
  var stringify = {}.toString;
  return stringify.call(new (thing)).replace(/\[|\]/g, '').split(' ')[1];
};

Varity.prototype.pushArg = function(e) {
  var self = this;
  var p = self.options.populate[e.type];
  if (e.expand || ~self.options.expand.indexOf(e.type)) {
    if (e.default) {
      return e.default();
    } else if (_.isFunction(p) && e.type !== 'Function') {
      return p();
    } else {
      return p;
    }
  } else {
    return undefined;
  }
};
