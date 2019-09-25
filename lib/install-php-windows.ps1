Param(
    [string]$version
)
$InstallVersion = "7.3.9"
switch ($version) {
    "5.4" { $InstallVersion = "5.4.45" }
    "5.5" { $InstallVersion = "5.5.38" }
    "5.6" { $InstallVersion = "5.6.40" }
    "7.1" { $InstallVersion = "7.1.32" }
    "7.2" { $InstallVersion = "7.2.22" }
    "7.3" { $InstallVersion = "7.3.9" }
    default { $InstallVersion = $version }
}

choco install -y php --force --version $InstallVersion --package-parameters='"/InstallDir:C:\tools\php"""'

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
