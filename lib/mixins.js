var _ = require('underscore');

module.exports = {
  capitalize: function(thing) {
    return thing.charAt(0).toUpperCase() + thing.slice(1).toLowerCase();
  },
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
    try {
      return /function (.+)\(\)/.exec(thing.toString())[1];
    } catch (e) {
      return this.capitalize(typeof thing);
    }
  }
};
