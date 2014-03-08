var Varity = require('./varity2'),
    _ = require('underscore');

_.mixin(require('./mixins'));

var wrap = function() {
  var v = new Varity();
  return v.wrap.apply(v, arguments);
};

wrap.configure = function(opts) {
  Varity.configure(opts);
};

wrap.reset = function() {
  Varity.reset();
};

wrap.letters = function(letter, value) {
  Varity.extend('letters.' + letter, value);
};

wrap.symbols = function(symbol, value) {
  Varity.extend('symbols.' + symbol, value);
};

wrap.defaults = function(def, value) {
  Varity.extend('defaults.' + def, value);
};

module.exports = wrap;
