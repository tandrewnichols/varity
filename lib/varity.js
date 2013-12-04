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
  },
  isjQuery: function(thing) {
    return typeof thing === 'object' ? !!thing.jquery : false;
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
    'E':'Element',
    '$':'jQuery',
    '-':'-',
    '+':'+',
    '_':'_',
    '*':'*'
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
    },
    'Element': function() {
      if (typeof window !== 'undefined') {
        return window.document;
      } else {
        return '<div></div>';
      }
    },
    'jQuery': function() {
      if (typeof $ !== 'undefined') {
        return $(document);
      } else {
        return [];
      }
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
  'anonobject': 'AnonObject',
  'element': 'Element',
  'jquery': 'jQuery'
};

var wrap = function() {
  var v = new Varity();
  return v.wrap.apply(v, arguments);
};
wrap.configure = function(opts) {
  if (opts.populate) {
    opts.populate = _(_.keys(opts.populate)).reduce(function(memo, key) {
      memo[(standard[key.toLowerCase()] || key)] = opts.populate[key];
      return memo;
    }, {});
  }      
  if (opts.expand === true) {
    opts.expand = _.keys(_options.populate);
  } else if (_.isArray(opts.expand)) {
    opts.expand = _(opts.expand).reduce(function(memo, type) {
      memo.push(standard[type.toLowerCase()]);
      return memo;
    }, []);
  }
  options = extend({}, _options, opts);
};
wrap.reset = function() {
  options = undefined;
};
module.exports = wrap;

var Varity = function Varity () {
  var self = this;
  self.options = options || _options;
  self.expected = []; 
  self.convert = Varity.prototype.convert.bind(self);
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
  var optional = false, expand = false, nonEmpty = false, required = false;
  if (_.isString(arg) && /^[-+_*]+/.exec(arg)) {
    if (~arg.indexOf('-')) optional = true;
    if (~arg.indexOf('+')) expand = true;
    if (~arg.indexOf('_')) nonEmpty = true, expand = true;
    if (~arg.indexOf('*')) required = true;
    arg = arg.replace(/[-+_*]+/g, '');
  }

  var push = function(expectation) {
    self.expected.push({
      type: expectation,
      optional: optional,
      nonEmpty: nonEmpty,
      required: required,
      expand: expand
    });
  };

  if (_.isString(arg)) {
    var expectation = self.standardize(arg);
    if (expectation) push(expectation);
  } else if (_.isFunction(arg)) {
    push(self.standardize(self.stringify(arg)));
  } else if (_.isArray(arg)) {
    _(arg).flatten().forEach(self.checkArg);
  } else if (_.isNull(arg)) {
    push('Null');
  } else if (_.isUndefined(arg)) {
    push('Undefined');
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
    if (/^[-+_]+$/.test(memo[memo.length - 1])) {
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
      } else if (e.nonEmpty && _.isEmpty(a)) {
        memo.push(self.pushArg(e));
      } else {
        memo.push(a);
      }
    } else if (e.required) {
      throw new Error('A required parameter was missing from the wrapped function');
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
