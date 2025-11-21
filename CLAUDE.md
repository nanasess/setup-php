# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Action called `setup-php` that sets up PHP environments in GitHub Actions workflows. It supports installing various PHP versions (5.4-8.5) on Ubuntu and Windows platforms using different installation methods (apt, phpenv, chocolatey).

**Supported Versions:**
- PHP 5.4-5.5 (ubuntu-22.04 only)
- PHP 5.6-8.5
- Patch versions supported (e.g., 7.2.11) except PHP 8.4 and 8.5
- Snapshot versions supported (e.g., 8.2snapshot)

**Supported Platforms:**
- ubuntu-latest, ubuntu-24.04, ubuntu-22.04
- windows-latest, windows-2025, windows-2022

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

The installer (src/installer.ts) chooses installation method based on:

1. **Platform detection** (Linux vs Windows)
2. **Version format** - `hasPatchVersion()` checks if specific patch version requested
3. **APT availability** - `hasAptVersion()` checks if version available via APT

**Linux Installation Logic:**
- APT method: Used for major.minor versions (5.6, 7.0-7.4, 8.0-8.5) without patch version
  - Calls `lib/apt-install-php-ubuntu.sh`
  - Uses ondrej/php PPA for versions not in default repos
  - Installs common extensions (bcmath, curl, gd, mbstring, mysql, etc.)
  - OPcache handling:
    - PHP < 8.5: Installs php${version}-opcache package separately
    - PHP 8.5+: OPcache bundled in core (no separate package)
  - Configures OPcache with JIT for PHP 8.1+
- phpenv method: Used for patch versions or unsupported APT versions
  - Calls `lib/phpenv-install-php-ubuntu.sh`
  - Compiles PHP from source with custom configure options
  - Builds OpenSSL 1.0.2 and PostgreSQL 9.6 from source
  - Handles snapshot versions (e.g., 8.2snapshot from GitHub)

**Windows Installation:**
- Uses Chocolatey via `lib/choco-install-php-windows.ps1`
- Special handling: PHP 7.3 limited to 7.3.30 on Windows

### Version Handling

**convertInstallVersion()** in src/installer.ts:
- Fetches latest patch versions from php.net API (`PHP_RELEASES_URL`)
- Falls back to hardcoded versions if API fails
- Returns major versions (5, 7, 8) as-is for flexibility
- Special case: Windows PHP 7.3 → 7.3.30

**Version Detection Functions:**
- `hasPatchVersion()`: Returns true if version is specific patch (e.g., 7.2.11) or snapshot
- `hasAptVersion()`: Returns true if version is 5.6 or 7.0-8.5 (major.minor only)

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

**Note:** Some tests are commented out because they depend on the latest PHP versions available at php.net, which change over time.

## CI/CD Workflow

The project uses GitHub Actions (`workflow.yml`) to test:
- **Matrix testing** across OS versions (ubuntu-24.04, ubuntu-22.04, windows-2025, windows-2022)
- **PHP versions** from 5.4 to 8.5, including specific patch versions (7.2.11, 7.2.12, 8.1.9)
- **Exclusions** for unsupported combinations (e.g., PHP 5.4 on Windows, PHP 5.4/5.5 on ubuntu-24.04)

Workflow steps:
1. Checkout code
2. Run `npm install` and `npm test` (Ubuntu only)
3. Remove node_modules (to test action in clean state)
4. Run the action itself with matrix PHP version
5. Verify installation with `php -i` and `php -m`

## Important Implementation Details

### Husky Pre-commit Hook
The project commits production dependencies to git:
- Pre-commit: Runs `npm run build` and `npm run format`
- Post-commit: Runs `npm prune --production` and commits pruned node_modules

This is standard for GitHub Actions to avoid requiring npm install during action execution.

### Shell Script Conventions
- All shell scripts use `set -eo pipefail` for strict error handling
- Use `apt-fast` wrapper (links to apt-get if not available) for faster package installation
- Use `update-alternatives` to set PHP version as default

### Key Files to Modify
- **src/installer.ts** - When adding new version logic or installation methods
- **lib/*.sh** or **lib/*.ps1** - When modifying installation scripts
- **action.yml** - When changing action inputs or metadata
- **__tests__/run.test.ts** - When adding new test cases

### Version Support Updates
When adding support for new PHP versions:
1. Update `hasAptVersion()` in src/installer.ts if APT supports the version
2. Add fallback version in `convertInstallVersion()` catch block
3. Update README.md to list the new version
4. Update workflow.yml matrix to test the new version
5. Check if the new version bundles extensions (like opcache in PHP 8.5+)
   - Update `lib/apt-install-php-ubuntu.sh` to exclude bundled extensions
6. Run `npm run build && npm run package` to update dist/index.js
7. Test both APT and phpenv installation methods