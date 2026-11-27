// .ts files are transformed by jest-transform.cjs (Node's native type
// stripping) instead of ts-jest, which does not support TypeScript 7.
// The stripped output keeps the ES module syntax, so the tests run as ES
// modules (`--experimental-vm-modules` is set in the `test` script).
module.exports = {
  clearMocks: true,
  moduleFileExtensions: ['js', 'ts'],
  testEnvironment: 'node',
  testMatch: ['**/*.test.ts'],
  extensionsToTreatAsEsm: ['.ts'],
  transform: {
    '^.+\\.ts$': '<rootDir>/jest-transform.cjs'
  },
  verbose: true
}
