import * as core from '@actions/core';
import {installPhp} from './installer';

async function run() {
  try {
    const phpSpec = core.getInput('php-version', {required: true});
    console.log(`##Installing PHP ${phpSpec}`);
    await installPhp(phpSpec);
  } catch (error) {
    if (error instanceof Error) {
      core.setFailed(error.message);
    } else {
      throw error;
    }
  }
}

run();
