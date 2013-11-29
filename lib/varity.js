var _ = require('underscore');
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

var letters = {
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
};

var expansion = {
  'String': '',
  'Function': function(){},
  'AnonObject': {},
  'Array': [],
  'Number': 0,
  'Boolean': false,
  'RegExp': /.*/,
  'Date': new Date(),
  'NaN': NaN,
  'Null': null,
  'Undefined': undefined,
  'Arguments': (function(){ return arguments; })(undefined),
  'Infinity': 2/0,
  'Error': new Error()
};

var Varity = function Varity () {
  this.expected = []; 
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
      args.forEach(function(){
        self.checkArg.apply(self, arguments);
      });
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
  }
};

Varity.prototype.standardize = function (thing) {
  var self = this;
  var arg = thing.charAt(0).toUpperCase() + thing.slice(1).toLowerCase();
  if (arg === 'Object' || arg === 'Anonobject') {
    return 'AnonObject';
  } else if (_['is' + arg]) {
    return arg;
  } else if (/regexp/i.test(arg)) {
    return 'RegExp';
  } else if (/nan/i.test(arg)) {
    return 'NaN';
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
    _(thing.trim().split('')).reduce(self.convert, []).forEach(function() {
      self.checkArg.apply(self, arguments);
    });
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
    _(arg).flatten().forEach(function() {
      self.checkArg.apply(self, arguments);
    });
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
  if (!letters[l]) {
    throw new Error('Unrecognized type: ' + l);
  } else {
    if (/^[-+]+$/.test(memo[memo.length - 1])) {
      memo[memo.length - 1] += letters[l];
    } else {
      memo.push(letters[l]);
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
        memo.push(e.expand ? (e.default ? e.default() : expansion[e.type]) : undefined);
        actual.unshift(a);
      } else {
        memo.push(a);
      }
    } else {
      memo.push(e.expand ? (e.default ? e.default() : expansion[e.type]) : undefined);
      actual.unshift(a);
    }
    return memo;
  }, []);
};

Varity.prototype.stringify = function(thing) {
  var stringify = {}.toString;
  return stringify.call(new (thing)).replace(/\[|\]/g, '').split(' ')[1];
};
