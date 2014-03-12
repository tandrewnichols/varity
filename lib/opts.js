var _ = require('underscore');

module.exports = {
  symbols: {
    '-': function(arg, context) {
      this.args = this.args || [];
      if (_(arg).isDefined() && !this.thingOrDefault([this.args[0]], context.types)) {
        this.args.unshift(arg);
        return undefined;
      } else {
        return arg;
      }
    },
    '+': function(arg, context) {
      return arg || this.options.defaults[context.types[0]];
    },
    '_': function(arg, context) {
      return _(arg).isEmpty() ? this.options.defaults[context.types[0]] : arg;
    },
    '*': function(arg, context) {
      if (_(arg).isDefined()) {
        return arg;
      } else {
        throw new Error('A parameter of type ' + context.types.join(' or ') + ' is required.');
      }
    }
  },
  letters: {
    's':'String',
    'f':'Function',
    'o':'Object',
    'a':'Array',
    '1':'Number',
    'b':'Boolean',
    'r':'RegExp',
    'd':'Date',
    'N':'NaN',
    'n':'Null',
    'u':'Undefined',
    'A':'Arguments',
    'i':'Infinity',
    'e':'Error',
    'E':'Element',
    '$':'jQuery',
  },
  defaults: {
    'String': '',
    'Function': function(){},
    'Object': {},
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
