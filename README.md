# Varity

Javascript arity simplified.

### Why?

The ability to pass a variable number of parameters to functions is a nice feature of javascript, but it can sometimes lead to boilerplate code at the top of a method to determine which parameters you're actual working with. Something like

```javascript
function (url, params, options, callback) {
  if (typeof params === 'function') {
    callback = params, params = {}, options = {};
  } else if (typeof options === 'function') {
    callback = options, options = {};
  }
  // . . . now for actual function logic
}
```

Varity ("variable-arity") handles this for you. And it can do some other handy things to.
