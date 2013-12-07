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
  },
  stringify: function(thing) {
    var stringify = {}.toString;
    return stringify.call(new (thing)).replace(/\[|\]/g, '').split(' ')[1];
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
  defaults: {
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
  populate: []
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
  options = extend({}, _options, Varity.standardizeOpts(opts));
};
wrap.reset = function() {
  options = undefined;
};
module.exports = wrap;

var Varity = function Varity () {
  var self = this;
  self.options = extend({}, (options || _options));
  self.expected = []; 
  _.chain(Varity.prototype).keys().each(function(method) {
    self[method] = Varity.prototype[method].bind(self);
  });
};

Varity.standardizeOpts = function(opts) {
  if (opts.defaults) {
    opts.defaults = _(_.keys(opts.defaults)).reduce(function(memo, key) {
      memo[(standard[key.toLowerCase()] || key)] = opts.defaults[key];
      return memo;
    }, {});
  }      
  if (opts.populate === true) {
    opts.populate = _(_options.defaults).keys();
  } else if (_(opts.populate).isArray()) {
    opts.populate = _(opts.populate).reduce(function(memo, type) {
      memo.push(standard[type.toLowerCase()]);
      return memo;
    }, []);
  }
  return opts;
};

Varity.prototype.wrap = function() {
  var self = this;
  if (arguments.length < 1) {
    throw new Error('No function passed to varity');
  } else {
    var args = Array.prototype.slice.call(arguments);
    var fn = args.pop();
    if (!_(fn).isFunction()) {
      throw new Error('Last argument is not a function');
    } else {
      if (_(args[args.length - 1]).isAnonObject() && _(args[0]).isString()) {
        extend(self.options, Varity.standardizeOpts(args.pop()));
      }
      _(args).each(self.checkArg);
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
  var optional = false, populate = false, nonEmpty = false, required = false;
  if (_.isString(arg) && /^[-+_*]+/.exec(arg)) {
    if (~arg.indexOf('-')) optional = true;
    if (~arg.indexOf('+')) populate = true;
    if (~arg.indexOf('_')) nonEmpty = true, populate = true;
    if (~arg.indexOf('*')) required = true;
    arg = arg.replace(/[-+_*]+/g, '');
  }

  var push = function(expectation) {
    self.expected.push({
      type: expectation,
      optional: optional,
      nonEmpty: nonEmpty,
      required: required,
      populate: populate
    });
  };

  if (_.isString(arg)) {
    var expectation = self.standardize(arg);
    if (expectation) push(expectation);
  } else if (_.isFunction(arg)) {
    push(self.standardize(_(arg).stringify()));
  } else if (_.isArray(arg)) {
    _(arg).flatten().forEach(self.checkArg);
  } else if (_.isNull(arg)) {
    push('Null');
  } else if (_.isUndefined(arg)) {
    push('Undefined');
  } else if (_.isAnonObject(arg)) {
    var type = _.isString(arg.type) ? arg.type : _(arg.type).stringify();
    arg.populate = typeof arg.populate !== 'undefined' ? arg.populate : (arg.default || arg.nonEmpty ? true : false);
    arg.type = self.standardize(type);
    self.expected.push(arg);
  }
};

Varity.prototype.convert = function (memo, l) {
  var self = this;
  if (!self.options.letters[l]) {
    throw new Error('Unrecognized type: ' + l);
  } else {
    if (/^[-+_*]+$/.test(_(memo).last())) {
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
        memo.push(self.makeArg(e));
        actual.unshift(a);
      } else if (e.nonEmpty && _(a).isEmpty()) {
        memo.push(self.makeArg(e));
      } else {
        memo.push(a);
      }
    } else if (e.required) {
      throw new Error('A required parameter was missing from the wrapped function');
    } else {
      memo.push(self.makeArg(e));
      actual.unshift(a);
    }
    return memo;
  }, []);
};

Varity.prototype.makeArg = function(e) {
  var self = this;
  var p = self.options.defaults[e.type];
  if (e.populate || ~self.options.populate.indexOf(e.type)) {
    if (e.default) {
      return _(e.default).isFunction() ? e.default() : e.default;
    } else {
      return _(p).isFunction() && e.type !== 'Function' ? p() : p;
    }
  } else {
    return undefined;
  }
};
