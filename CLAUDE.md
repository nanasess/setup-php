# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Action called `setup-php` that sets up PHP environments in GitHub Actions workflows. It supports installing various PHP versions (5.4-8.3) on Ubuntu and Windows platforms using different installation methods (apt, phpenv, chocolatey).

## Development Commands

### Building and Testing
- `npm run build` - Compile TypeScript to JavaScript in lib/
- `npm run test` - Run Jest tests
- `npm run package` - Bundle with ncc for distribution (creates dist/index.js)
- `npm run format` - Format code with Prettier
- `npm run format-check` - Check code formatting

### Development Workflow
The project uses Husky pre-commit hooks that automatically:
1. Run `npm run build` and `npm run format`
2. Prune devDependencies with `npm prune --production`
3. Stage the pruned node_modules for commit

## Architecture

### Core Components
- **src/setup-php.ts** - Main entry point that reads GitHub Actions input and calls installer
- **src/installer.ts** - Core installation logic with platform-specific PHP installation methods
- **lib/** - Shell scripts for different installation methods:
  - `apt-install-php-ubuntu.sh` - APT-based installation for Ubuntu
  - `phpenv-install-php-ubuntu.sh` - phpenv-based installation for Ubuntu  
  - `choco-install-php-windows.ps1` - Chocolatey-based installation for Windows

### Installation Strategy
The installer chooses installation method based on:
1. **Platform detection** (Linux vs Windows)
2. **Version format** (patch version vs major.minor)
3. **APT availability** for specific PHP versions

For Linux:
- Uses APT for major.minor versions (5.6, 7.0-7.4, 8.0-8.3) when no patch version specified
- Falls back to phpenv for patch versions or unsupported APT versions

### Version Handling
- **convertInstallVersion()** fetches latest patch versions from php.net API
- Falls back to hardcoded versions if API fails
- Special handling for Windows chocolatey version limitations

## Build Output Structure

This project follows GitHub Actions conventions:
- **src/** - TypeScript source files
- **lib/** - Compiled JavaScript (checked into git)
- **dist/** - Bundled distribution (checked into git)
- **node_modules/** - Production dependencies only (checked into git, devDependencies pruned by Husky)

## Testing

Tests are in `__tests__/run.test.ts` and cover:
- Version parsing logic (`hasPatchVersion`, `hasAptVersion`)
- Version conversion functionality (`convertInstallVersion`)
- Uses Jest with 10-second timeout for API calls