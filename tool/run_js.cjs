// Runs a dart2js-compiled command-line program under node. dart2js output
// expects a browser-like `self`; node has `globalThis`. An uncaught Dart
// error surfaces as an uncaught JS error, so node exits non-zero.
globalThis.self = globalThis;
process.on('uncaughtException', (e) => {
  console.error(e && e.message ? e.message : e);
  process.exit(1);
});
require(require('path').resolve(process.argv[2]));
