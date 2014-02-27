var _ = require('underscore');

module.exports = {
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
};
