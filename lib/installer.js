"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const exec = __importStar(require("@actions/exec"));
const path = __importStar(require("path"));
const semver = __importStar(require("semver"));
function installPhp(version) {
    return __awaiter(this, void 0, void 0, function* () {
        const installVersion = convertInstallVersion(version);
        if (process.platform === 'linux') {
            if (!hasPatchVersion(version) && hasAptVersion(version)) {
                yield exec.exec(path.join(__dirname, 'apt-install-php-ubuntu.sh'), [
                    version
                ]);
            }
            else {
                yield exec.exec(path.join(__dirname, 'phpenv-install-php-ubuntu.sh'), [
                    installVersion
                ]);
            }
        }
        else if (process.platform === 'win32') {
            yield exec.exec('powershell -File ' +
                path.join(__dirname, 'choco-install-php-windows.ps1 -version ' + installVersion));
        }
    });
}
exports.installPhp = installPhp;
function hasAptVersion(version) {
    if (hasPatchVersion(version))
        return false;
    const Semver = semver.coerce(version);
    if (Semver === null)
        return false;
    if (Semver.major == 5) {
        if (Semver.minor != 6) {
            return false;
        }
    }
    return semver.satisfies(Semver.version, '5.6 || <=7.3');
}
exports.hasAptVersion = hasAptVersion;
function hasPatchVersion(version) {
    const Semver = semver.coerce(version);
    if (Semver === null)
        return false;
    return Semver.version === version;
}
exports.hasPatchVersion = hasPatchVersion;
function convertInstallVersion(version) {
    switch (version) {
        case '5.4':
            return '5.4.45';
        case '5.5':
            return '5.5.38';
        case '5.6':
            return '5.6.40';
        case '7.0':
            return '7.0.33';
        case '7.1':
            return '7.1.32';
        case '7.2':
            return '7.2.23';
        case '7.3':
            return '7.3.10';
    }
    return version;
}
exports.convertInstallVersion = convertInstallVersion;
