Param(
    [string]$version
)

choco install -y php --force --version $version --package-parameters='"/InstallDir:C:\tools\php"""'

Write-Host "`$LASTEXITCODE = $LASTEXITCODE"

cd c:\tools\php
copy php.ini-production php.ini
Write-Output extension_dir='C:/tools/php/ext' | Add-Content php.ini -Encoding Default
Write-Output extension=php_intl.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_fileinfo.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_openssl.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_gd2.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_mbstring.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_sqlite3.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_pgsql.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_mysqli.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_pdo_sqlite.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_pdo_mysql.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_pdo_pgsql.dll | Add-Content php.ini -Encoding Default
Write-Output extension=php_curl.dll | Add-Content php.ini -Encoding Default

Write-Host "`$LASTEXITCODE = $LASTEXITCODE"
exit $LASTEXITCODE