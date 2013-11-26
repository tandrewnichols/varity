module.exports = function() {
  if (arguments.length < 1) {
    throw 'No function passed to varity';
  } else {
    var args = Array.prototype.slice.call(arguments);
    var fn = args.pop();
    if (typeof fn !== 'function') {
      throw 'Last argument is not a function';
    } else {
      fn();
    }
  }
};
