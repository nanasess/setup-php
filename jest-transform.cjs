// Jest transformer: zero-dependency TypeScript type stripping.
//
// TypeScript 7.0 (the Go-native compiler) does not ship the programmatic API,
// so ts-jest (which depends on ts.transpileModule()) no longer works. This
// transformer converts .ts to JS using only Node's built-in
// `node:module.stripTypeScriptTypes()` (Node 22.18+/24), independent of the
// TypeScript version. Type-checking is done by `npm run build` (tsc), so the
// test transform only needs to erase types.
//
// `mode: "strip"` replaces type annotations with whitespace and keeps
// line/column positions, so stack traces map to the original source without
// a sourcemap. Syntax that requires code generation (enum / namespace /
// parameter properties) is not supported in strip mode; src/ and __tests__/
// do not use it.
//
// The output keeps the ES module syntax, so jest runs the tests as ES modules
// (`extensionsToTreatAsEsm` in jest.config.js and `--experimental-vm-modules`
// in the test script), while the build output (lib/, dist/) stays CommonJS.
// see also nanasess/setup-chromedriver#501

const {stripTypeScriptTypes} = require('node:module');

module.exports = {
  process(sourceText, sourcePath) {
    const code = stripTypeScriptTypes(sourceText, {
      mode: 'strip',
      sourceUrl: sourcePath
    });
    return {code};
  }
};
