/**********************************************************
 * GUI boilerplate JS function library
 **********************************************************/

/**********************************************************
 * Polyfills
 **********************************************************/

// Bind polyfill (for IE7), taken from https://developer.mozilla.org/
if (!Function.prototype.bind) {
  Function.prototype.bind = function(oThis) {
    if (typeof this !== "function") {
      throw new TypeError("Function.prototype.bind - subject is not callable");
    }

    var aArgs   = Array.prototype.slice.call(arguments, 1);
    var fToBind = this;
    var fNOP    = function() {};
    var fBound  = function() {
      return fToBind.apply(
        this instanceof fNOP ? this : oThis,
        aArgs.concat(Array.prototype.slice.call(arguments))
      );
    };

    if (this.prototype) {
      fNOP.prototype = this.prototype;
    }
    fBound.prototype = new fNOP();

    return fBound;
  };
}

// String includes polyfill, taken from https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/String/includes
if (!String.prototype.includes) {
  String.prototype.includes = function(search, start) {
    'use strict';
    if (typeof start !== "number") {
      start = 0;
    }

    if (start + search.length > this.length) {
      return false;
    } else {
      return this.indexOf(search, start) !== -1;
    }
  };
}

/**********************************************************
 * Common functions
 **********************************************************/

// Output text to the debug div
function debugOutput(text, dstID) {
  var stdout = document.getElementById(dstID || "debug-output");
  if (stdout) {
    var t = stdout.innerText;
    t += (t && "\n") + text;
    stdout.innerHTML = t;
  }
}

// Create hidden form and submit with sapevent
function submitSapeventForm(params, action, method) {
  var form = document.createElement("form");
  form.setAttribute("method", method || "post");
  form.setAttribute("action", "sapevent:" + action);

  for(var key in params) {
    var hiddenField = document.createElement("input");
    hiddenField.setAttribute("type", "hidden");
    hiddenField.setAttribute("name", key);
    hiddenField.setAttribute("value", params[key]);
    form.appendChild(hiddenField);
  }

  document.body.appendChild(form);
  form.submit();
}

// Set focus to a control
function setInitialFocus(id) {
  document.getElementById(id).focus();
}

// Submit an existing form
function submitFormById(id) {
  document.getElementById(id).submit();
}

// confirm JS initilization
function confirmInitialized() {
  debugOutput("js: OK");
}
