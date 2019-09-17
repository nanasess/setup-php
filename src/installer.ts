import * as exec from '@actions/exec';
import * as path from 'path';
import * as semver from 'semver';

export async function installPhp(version: string) {
  if (process.platform === 'linux') {
    if (Number(version) >= 5.6) {
      await exec.exec(path.join(__dirname, 'install-php-ubuntu.sh'), [version]);
    } else {
      await exec.exec(path.join(__dirname, 'install-old-php-ubuntu.sh'), [
        version
      ]);
    }
  }
}
