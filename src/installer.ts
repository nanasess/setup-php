import * as exec from '@actions/exec';
import * as path from 'path';
import * as semver from 'semver';

export async function installPhp(version: string) {
  const installVersion = convertInstallVersion(version);
  if (process.platform === 'linux') {
    if (!hasPatchVersion(version) && hasAptVersion(version)) {
      await exec.exec(path.join(__dirname, 'apt-install-php-ubuntu.sh'), [
        new Number(version).toFixed(1)
      ]);
    } else {
      await exec.exec(path.join(__dirname, 'phpenv-install-php-ubuntu.sh'), [
        installVersion
      ]);
    }
  } else if (process.platform === 'win32') {
    await exec.exec(
      'powershell -File ' +
        path.join(
          __dirname,
          'choco-install-php-windows.ps1 -version ' + installVersion
        )
    );
  }
}
export function hasAptVersion(version: string): boolean {
  if (hasPatchVersion(version)) return false;
  const Semver = semver.coerce(version);
  if (Semver === null) return false;
  if (Semver.major == 5) {
    if (Semver.minor != 6) {
      return false;
    }
  }
  return semver.satisfies(Semver.version, '5.6 || <=7.4 || <= 8.0');
}
export function hasPatchVersion(version: string): boolean {
  const Semver = semver.coerce(version);
  if (Semver === null) return false;
  return Semver.version === version;
}
export function convertInstallVersion(version: string): string {
  switch (version) {
    case '5.4':
      return '5.4.45';
    case '5.5':
      return '5.5.38';
    case '5.6':
      return '5.6.40';
    case '7.0':
      return '7.0.33';
    case '7.1':
      return '7.1.33';
    case '7.2':
      return '7.2.34';
    case '7.3':
      return '7.3.27';
    case '7.4':
      return '7.4.16';
    case '8.0':
      return '8.0.3';
  }
  return version;
}
