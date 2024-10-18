# setup-php

<p align="left">
  <a href="https://github.com/nanasess/setup-php"><img alt="GitHub Actions status" src="https://github.com/nanasess/setup-php/workflows/Main%20workflow/badge.svg"></a>
  <a href="https://github.com/nanasess/setup-php/blob/master/LICENSE"><img alt="LICENSE" src="https://img.shields.io/badge/license-MIT-428f7e.svg"></a>
  <a href="#php-version-support"><img alt="PHP Versions Supported" src="https://img.shields.io/badge/php-%3E%3D%205.4-8892BF.svg"></a>
</p>

This action sets up a PHP environment for use in actions by:

- optionally installing a version of PHP and adding to PATH.
- registering problem matchers for error output

## PHP version support

- 5.4(ubuntu-22.04 or ubuntu-20.04 only)
- 5.5(ubuntu-22.04 or ubuntu-20.04 only)
- 5.6
- 7.0
- 7.1
- 7.2
- 7.3
- 7.4
- 8.0
- 8.1
- 8.2
- 8.3

*Patch version can also be set. e.g. 7.2.11*

## OS/Platform support

- ubuntu-latest, ubuntu-24.04, ubuntu-22.04 or ubuntu-20.04
- windows-latest, windows-2022 or windows-2019

# Usage

See [action.yml](action.yml)

Basic:
```yaml
steps:
- uses: actions/checkout@v3
- uses: nanasess/setup-php@v4
  with:
    php-version: '8.2'
- run: php my_script.php
```

Matrix Testing:
```yaml
jobs:
  build:
    runs-on: ${{ matrix.operating-system }}
    strategy:
      matrix:
        operating-system: [ ubuntu-latest, windows-latest ]
        php: [ '5.6', '7.1', '7.2', '7.3', '7.4', '7.3.3' ]
    name: PHP ${{ matrix.php }} sample
    steps:
      - uses: actions/checkout@v3
      - name: Setup PHP
        uses: nanasess/setup-php@v4
        with:
          php-version: ${{ matrix.php }}
      - run: php my_script.php
```

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)

# Contributions

Contributions are welcome!  See [Contributor's Guide](docs/contributors.md)
