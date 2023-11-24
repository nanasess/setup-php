import * as core from '@actions/core';
import {installPhp} from './installer';

async function run() {
  try {
    const phpSpec = core.getInput('php-version', {required: true});
    core.info(`Installing PHP ${phpSpec}`);
    const exitCode = await installPhp(phpSpec);
    if (exitCode !== 0) {
      throw new Error(
        `An error occurred while installing PHP(Code: ${exitCode}`
      );
    }
  } catch (error) {
    if (error instanceof Error) {
      core.setFailed(error.message);
    } else {
      throw error;
    }
  }
}

run();
