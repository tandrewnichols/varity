module.exports = {
  symbols: '-+_*|'.split(''),
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
