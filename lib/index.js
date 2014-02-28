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

module.exports = wrap;