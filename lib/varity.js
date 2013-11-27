var _ = require('underscore');
_.mixin({
  isError: function(thing) {
    try {
      return thing.constructor.name === 'Error';
    } catch (e) {
      return false;
    }
  }
});
var expectations;

module.exports = function() {
  if (arguments.length < 1) {
    throw new Error('No function passed to varity');
  } else {
    var args = Array.prototype.slice.call(arguments);
    var fn = args.pop();
    if (typeof fn !== 'function') {
      throw new Error('Last argument is not a function');
    } else {
      expectations = [];
      args.forEach(checkArg);
      return function() {
        var innerArgs = Array.prototype.slice.call(arguments);
        var params = [];
        for (var i = 0; i < innerArgs.length; i++) {
          if (expectations[i] === 'Finite' && !_.isFinite(innerArgs[i])) {
            params.push(innerArgs[i]);
          } else if (_['is' + expectations[i]](innerArgs[i])) {
            params.push(innerArgs[i]);
          } else {
            params.push(undefined);
          }
        }
        fn.apply(fn, params);
      };
    }
  }
};

function standardize (thing) {
  var arg = thing.charAt(0).toUpperCase() + thing.slice(1).toLowerCase();
  if (_['is' + arg]) {
    return arg;
  } else if (/regexp/i.test(arg)) {
    return 'RegExp';
  } else if (/nan/i.test(arg)) {
    return 'NaN';
  } else if (/infinity/i.test(arg)) {
    return 'Finite';
  } else if (/error/i.test(arg)) {
    return 'Error';
  } else if (/[sfoA1brdNnuaie]/.test(thing)) {
    thing.split('').map(convert).forEach(checkArg);
  }
}

function checkArg (arg) {
  if (_.isString(arg)) {
    expectations.push(standardize(arg));
  } else if (_.isFunction(arg)) {
    var stringify = {}.toString;
    var strType = stringify.call(new (arg)).replace(/\[|\]/g, '').split(' ')[1];
    expectations.push(standardize(strType));
  } else if (_.isArray(arg)) {
    var arr = _.flatten(arg);
    arr.forEach(checkArg);
  } else if (_.isNull(arg)) {
    expectations.push('Null');
  } else if (_.isUndefined(arg)) {
    expectations.push('Undefined');
  }
}

function convert (letter) {
  switch (letter) {
  case's':
    return 'String';
  case 'f':
    return 'Function';
  case 'o':
    return 'Object';
  case 'A':
    return 'Array';
  case '1':
    return 'Number';
  case 'b':
    return 'Boolean';
  case 'r':
    return 'RegExp';
  case 'd':
    return 'Date';
  case 'N':
    return 'NaN';
  case 'n':
    return 'Null';
  case 'u':
    return 'Undefined';
  case 'a':
    return 'Arguments';
  case 'i':
    return 'Infinity';
  case 'e':
    return 'Error';
  default:
    throw new Error('Unrecognized type: ' + letter);
  }
}
