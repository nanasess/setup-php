import * as core from '@actions/core';
import * as exec from '@actions/exec';
import * as path from 'path';
import * as semver from 'semver';
import superagent from 'superagent';

const PHP_RELEASES_URL = 'https://www.php.net/releases/index.php?json=true';

export async function installPhp(version: string): Promise<number> {
  const installVersion = await convertInstallVersion(version);

  core.info(`Installing PHP ${installVersion}`);
  if (process.platform === 'linux') {
    const hasPatch = hasPatchVersion(version);
    core.info(`hasPatchVersion(${version}): ${hasPatch}`);
    const hasApt = hasAptVersion(version);
    core.info(`hasAptVersion(${version}): ${hasApt}`);
    if (!hasPatchVersion(version) && hasAptVersion(version)) {
      core.info(`Installing PHP ${version} via apt`);
      return await exec.exec(
        path.join(__dirname, '../lib', 'apt-install-php-ubuntu.sh'),
        [new Number(version).toFixed(1)]
      );
    } else {
      core.info(`Installing PHP ${installVersion} via phpenv`);
      return await exec.exec(
        path.join(__dirname, '../lib', 'phpenv-install-php-ubuntu.sh'),
        [installVersion]
      );
    }
  } else if (process.platform === 'win32') {
    return await exec.exec(
      'powershell -File ' +
        path.join(
          __dirname,
          '../lib',
          'choco-install-php-windows.ps1 -version ' + installVersion
        )
    );
  }

  // Illegal process.platform
  return -1;
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
  return semver.satisfies(Semver.version, '5.6 || <=7.4 || <= 8.3');
}
export function hasPatchVersion(version: string): boolean {
  const Semver = semver.coerce(version);
  if (Semver === null) return false;
  if (version.endsWith('snapshot')) {
    return true;
  }
  return Semver.version === version;
}
type PHPReleaseJson = {
  announcement: boolean;
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
      // The last version of PHP7.3.x series in chocolatey is 7.3.30
      // see https://community.chocolatey.org/packages/php/7.3.30
      if (process.platform === 'win32' && version === '7.3') {
        return '7.3.30';
      }
      try {
        const json = (await superagent
          .get(`${PHP_RELEASES_URL}&version=${version}`)
          .then(response => response.body)) as PHPReleaseJson;

        if (json.version === undefined) {
          throw new Error('version is undefined');
        }

        return json.version;
      } catch (error) {
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
            return '7.3.33';
          case '7.4':
            return '7.4.28';
          case '8.0':
            return '8.0.16';
          case '8.1':
            return '8.1.3';
          case '8.2':
            return '8.2.0';
          case '8.3':
            return '8.3.0';
          default:
            return version;
        }
      }
  }
}
