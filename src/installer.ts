import * as exec from '@actions/exec';
import * as path from 'path';
import * as semver from 'semver';
import fetch from 'node-fetch';

jest.setTimeout(10000);
const PHP_RELEASES_URL = 'https://www.php.net/releases/index.php?json=true';

export async function installPhp(version: string) {
  const installVersion = convertInstallVersion(version);
  if (process.platform === 'linux') {
    if (!hasPatchVersion(version) && hasAptVersion(version)) {
      await exec.exec(path.join(__dirname, 'apt-install-php-ubuntu.sh'), [
        new Number(version).toFixed(1)
      ]);
    } else {
      await exec.exec(path.join(__dirname, 'phpenv-install-php-ubuntu.sh'), [
        await installVersion
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
  return semver.satisfies(Semver.version, '5.6 || <=7.4 || <= 8.1');
}
export function hasPatchVersion(version: string): boolean {
  const Semver = semver.coerce(version);
  if (Semver === null) return false;
  return Semver.version === version;
}
type PHPReleaseJson = {
  announcement: boolean,
  date: string;
  source: any;
  version: string;
};

export async function convertInstallVersion(version: string): Promise<string> {
  switch (version) {
    case '5':
    case '7':
    case '8':
      return version;
    default:
      const json = await fetch(`${PHP_RELEASES_URL}&version=${version}`)
          .then(response => response.json()) as PHPReleaseJson;
      return json.version;
  }
}
