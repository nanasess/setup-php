import * as installer from '../src/installer';

jest.setTimeout(10000);
describe('example tests', () => {
  it('testing', () => {
    expect(true).toBe(true);
  });
  it('hasPatchVersion tests', () => {
    expect(installer.hasPatchVersion('5')).toBe(false);
    expect(installer.hasPatchVersion('5.5')).toBe(false);
    expect(installer.hasPatchVersion('5.5.5')).toBe(true);
  });
  it('hasAptVersion tests', () => {
    expect(installer.hasAptVersion('5')).toBe(false);
    expect(installer.hasAptVersion('5.5')).toBe(false);
    expect(installer.hasAptVersion('5.5.5')).toBe(false);
    expect(installer.hasAptVersion('5.6.40')).toBe(false);
    expect(installer.hasAptVersion('5.6')).toBe(true);
    expect(installer.hasAptVersion('5.7')).toBe(false);
    expect(installer.hasAptVersion('7.0')).toBe(true);
    expect(installer.hasAptVersion('7.1')).toBe(true);
    expect(installer.hasAptVersion('7.2')).toBe(true);
    expect(installer.hasAptVersion('7.3')).toBe(true);
    expect(installer.hasAptVersion('7.4')).toBe(true);
    expect(installer.hasAptVersion('8.0')).toBe(true);
    expect(installer.hasAptVersion('8.1')).toBe(true);
    expect(installer.hasAptVersion(new Number('8').toFixed(1))).toBe(true);
  });
  it('convertInstallVersion tests', async () => {
    expect(await installer.convertInstallVersion('5')).toBe('5');
    expect(await installer.convertInstallVersion('5.4')).toBe('5.4.45');
    expect(await installer.convertInstallVersion('5.5')).toBe('5.5.38');
    expect(await installer.convertInstallVersion('5.6')).toBe('5.6.40');
    expect(await installer.convertInstallVersion('7')).toBe('7');
    expect(await installer.convertInstallVersion('7.1')).toBe('7.1.33');
    expect(await installer.convertInstallVersion('7.2')).toBe('7.2.34');
    // expect(await installer.convertInstallVersion('7.3')).toBe('7.3.28');
    // expect(await installer.convertInstallVersion('7.4')).toBe('7.4.19');
    // expect(await installer.convertInstallVersion('8.0')).toBe('8.0.6');
    // expect(await installer.convertInstallVersion('8.1')).toBe('8.1.2');
    expect(await installer.convertInstallVersion('7.3.8')).toBe('7.3.8');
  });
});
