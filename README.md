# setup-php

<p align="left">
  <a href="https://github.com/nanasess/setup-php"><img alt="GitHub Actions status" src="https://github.com/nanasess/setup-php/workflows/Main%20workflow/badge.svg"></a>
</p>

This action sets up a PHP environment for use in actions by:

- optionally installing a version of PHP and adding to PATH. Note that this action only uses versions of PHP already installed in the cache. The action will fail if no matching versions are found.
- registering problem matchers for error output

# Usage

See [action.yml](action.yml)

Basic:
```yaml
steps:
- uses: actions/checkout@master
- uses: nanasess/setup-php@v1
  with:
    php-version: '7.3' # Version range or exact version of a PHP version to use, using semvers version range syntax.
- run: php my_script.php
```

Matrix Testing:
```yaml
jobs:
  build:
    runs-on: ubuntu-16.04
    strategy:
      matrix:
        php: [ '5.6', '7.1', '7.2', '7.3 ]
    name: PHP ${{ matrix.php }} sample
    steps:
      - uses: actions/checkout@master
      - name: Setup PHP
        uses: nanasess/setup-php@v1
        with:
          php-version: ${{ matrix.php }}
      - run: php my_script.py
```

# License

The scripts and documentation in this project are released under the [MIT License](LICENSE)

# Contributions

Contributions are welcome!  See [Contributor's Guide](docs/contributors.md)
