[![Build Status](https://travis-ci.org/tandrewnichols/varity.png)](https://travis-ci.org/tandrewnichols/varity)

# Varity

Javascript arity simplified.

## Why?

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

## Install

`npm install varity`

## Basic Use

When you `require('varity')`, you'll get a wrapper function back. Call this function as many times as you need as it instantiates new objects and therefore doesn't lead to object pollution. Basically, you tell this function what you're expecting to receive in your function and pass that function as the last parameter. There are several ways to tell varity what you're expecting.

### With strings

Pass stringified types as separate parameters:

```javascript
var $ = require('varity');
var wrapped = $('String', 'Object', function(url, options) {
  // . . .
});
```

Now, if you call `wrapped` with a string and an object, it will pass them on to your function (nothing fantastic about that part). However, if you call `wrapped` with only a string, varity will pass the string and `undefined` to your function. I know you're thinking "Javascript does that by default. Why should I add this extra layer of abstraction?" Here's where it's useful: if you pass only an object to the wrapped function, varity will pass `undefined` as the first parameter and the object as the second parameter. No need to test `if (typeof url === 'object')`!

Varity recognizes (out of the box) the following types:

* String
* Function
* Object
* Array
* Number
* Boolean
* RegExp
* Date
* NaN
* Null
* Undefined
* Arguments
* Infinity
* Error
* Element (a DOM element)
* jQuery

Additionally, you can pass custom types as strings. Varity will build a simple _ mixin method to test objects you pass it for your object type. For instance:

```javascript
var wrapped = $('Foo', function(foo) {
  // Creates an _ mixin method called 'isFoo'
});
```

### With actual types

```javascript
var wrapped = $(Array, Function, function(list, callback) {
  // . . .
});
```

You can pass any of the string types that are recognized javascript types (so not arguments or element). Use `null` for Null and `undefined` for Undefined (though there's not much value in expecting these in functions).

### With string abbreviations

To keep calls to varity short, all built in types have one character analogs that can be passed collectively as a single string:

```javascript
var wrapped = $('ssf', function(fname, lname, callback) {
  // . . . 
});
```

The following abbreviations are recognized by varity:

* s: String
* f: Function
* o: Object
* A: Array
* 1: Number
* b: Boolean
* r: RegExp
* d: Date
* N: NaN
* n: Null
* u: Undefined
* a: Arguments
* i: Infinity
* e: Error
* E: Element
* $: jQuery

One note about using abbreviations: since javascript objects typically begin with capital letters, Varity checks for initial capital letters when determining if a parameter is a custom type. Some of the type abbreviations are capitals. That means that doing the following won't work:

```javascript
var wrapped = $('Ao', function(list, obj) {
  // . . .
});
```

Both `A` and `o` are valid type abbreviations, but Varity will think you are trying to pass a custom type called `Ao`. To get around this, prefix initial capital abbreviations with a space.

```javascript
var wrapped = $(' Ao', function(list, obj) {
  // Now we'll have an array and an object
});
```

### With an array

```javascript
var wrapped = $(['String', 'Function'], function(name, callback) {
  // . . .
});
```

The elements of the array can be strings or types or even other arrays (nested arrays are flattened). You can even mix types:

```javascript
var wrapped = $('sf', Array, 'String' ['Function', 'Object'], function(/* . . . */) {
  // So we're expecting a string, a function, an array, another
  // string, another function, and an object. Time to refactor...
});
```

### With objects
```javascript
var wrapped = $({ type: 'String' }, { type: 'Array' }, function(name, hobbies) {
  // . . .
});
```

There are some additional parameters that can be passed when using the object format, but to understand those, we need to talk about some of the flags you can pass with parameters.

## Flags

You can pass the following flags to tell Varity how to deal with the arguments it receives. Note that you have to use string types or string abbreviations for this to work (since, for example, `-String` will be a problem for the javascript compiler).

### Optional: -

Normally, if you pass two of the same type next to each other, Varity will assign the first parameter that matches that type to the first argument and leave the second undefined.

```javascript
var wrapped = $('soof', function(id, services, options, callback) {
  // . . .
});
```

If you call this with a string, an object, and a function, `services` will be the object and `options` will be undefined. If you want to reverse this behavior, prefix the first 'o' with `-` (which tells varity that it is optional).

```javascript
var wrapped = $('s-oof', function(id, services, options, callback) {
  // Now if only one object is passed, it'll be set to options.
});
```

Or

```javascript
var wrapped = $('String', '-Object', 'Object', 'Function', function(id, services, options, callback) {
  // . . .
});
```

### Populate: +

Normally, varity returns `undefined` for missing parameters, but that's not always useful because it means that type-specific methods on that parameter have to be wrapped in an `if`. For example, the following fails if `list` is undefined.

```javascript
var wrapped $('Array', function(list) {
  list.push('something else');
});
```

We'd normally do

```javascript
var wrapped $('Array', function(list) {
  if (list) {
    list.push('something else');
  }
});
```

to get around that. Instead, you can tell varity to return something that makes sense (given the type) by prefixing it with `+`. The built in defaults are as follows (though you can override them - more on that later).

* String

```javascript
''
```

* Function

```javascript
function(){}
```

* Object

```javascript
{}
```

* Array

```javascript
[]
```

* Number

```javascript
0
```

* Boolean

```javascript
false
```

* RegExp

```javascript
/.*/
```

* Date

```javascript
function() {
  return new Date();
}
```

* NaN

```javascript
NaN
```

* Null

```javascript
null
```

* Undefined

```javascript
undefined
```

* Arguments: 

```javascript
(function(){
  return arguments;
})(undefined)
```

* Infinity

```javascript
2/0
```

* Error: 

```javascript
function() {
  return new Error();
}
```

* Element:

```javascript
function() {
  if (typeof window !== 'undefined') {
    return window.document;
  } else {
    return '<div></div>';
  }
}
```

* jQuery:

```javascript
function() {
  if (typeof $ !== 'undefined') {
    return $(document);
  } else {
    return [];
  }
}
```

The Element and jQuery defaults when NOT in the browser aren't perfect, but you probably aren't using either one in node so it doesn't really matter.

You can also combine `populate` with `optional`:

```javascript
var wrapped = $('s-+oo', function(str, obj1, obj2) {
  // If passed only 'string' and {one: 1}, arguments will be
  // 'string', {}, {one: 1}
});
```

### Non-empty: _

The non-empty flag tells varity to treat "empty" parameters as if they were undefined. This isn't that useful except in conjunction with the populate option below. If you tell varity to populate a type with some other default and use the _ flag, varity will replace an empty type (e.g. `{}`, `[]`, `function() {}`, etc.) with the default of that type.

```javascript
var options = {
  dataType: 'json',
  method: 'put'
};

var wrapped = $('s_o', { defaults: { 'Object': options } }, function(url, opts) {
  // see below for more about options
});
wrapped('something.com', {}); // Varity will use the default options defined above
```

### Required: *

Mark a parameter as required. If that parameter is not passed, Varity will throw an exception.

```javascript
var wrapped = $(' *so', function(name, options) {
  // . . .
});
wrapped({ async: true }); // throws
```

Note that you if your first argument (using abbreviations) uses a flag,  you need to prefix it with a space (as with initial capital letters).

### Flags with objects

Passing flags with objects means passing the corresponding keys: "optional," "populate," "required," and "nonEmpty". Additionally, you can pass a "default" to tell varity what to populate empty arguments with.

```javascript
var wrapped = $(
  { type: Object, optional: true },
  { type: Object, populate: true },
  { type: String, required: true },
  { type: Array, nonEmpty: true, default: ['one', 'two'] },
  function(obj1, obj2, str, arr) {
    // Do stuff
  }
);
```

## Configuration

There are a couple ways to configure varity (besides passing objects, as above):

### varity.configure

Use `varity.configure` for one time, initial setup. All calls to `varity()` after that will use whatever options you pass. You can pass the following options to `varity.configure`:

* letters - add custom abbreviations or override default ones
* defaults - override built in defaults or provide defaults for custom types
* populate - turn on `populate` for all types (with `true`) or a set of types (with an array) so that you don't have to use the `+` flag
 
```javascript
var $ = require('varity');
$.configure({
  letters: {
    '~': 'Foo',
    'a': 'Array',
    'A': 'Arguments' // If, for example, you don't like that array is capital A by default
  },
  defaults: {
    'Object': {
      jsonp: true,
      method: 'get',
      data: {
        user: localStorage.get('user')
      }
    },
    'Foo': function() {
      return new Foo('my foo param');
    }
  },
  populate: true // Always populate ALL types

  /*
   * OR
   *
   * populate: ['Object', 'Array', 'Foo']
   *
   * to always populate ONLY these types
   */
});
```

Note that these options will be used for EVERY call to varity. If you need to undo these options, you can call `varity.reset()`, which will restore the defaults. However, any already wrapped functions will still have the custom options. If you want to provide options for a SINGLE wrapper, you can either use the object parameter format above or the following method.

### As the second to last parameter to varity

The last parameter to varity has to be the actual function to wrap, but if you use strings to define the expected arguments, you can also pass an object of one-time options. The available options are the same as above.

```javascript
var wrapped = $('soo~', {
  populate: ['Object'],
  defaults: {
    'Object': {
      name: localStorage.get('name')
    }
  },
  letters:{
    '~': 'Foo'
  }
}, function(str, obj1, obj2, foo) {
  // . . .
});
```
