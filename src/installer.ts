import * as exec from '@actions/exec';
import * as path from 'path';
import * as semver from 'semver';

export async function installPhp(version: string) {
  if (process.platform === 'linux') {
    await exec(path.join(__dirname, 'install-php-ubuntu.sh'), [version]);
  }
}
