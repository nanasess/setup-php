"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    Object.defineProperty(o, k2, { enumerable: true, get: function() { return m[k]; } });
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertInstallVersion = exports.hasPatchVersion = exports.hasAptVersion = exports.installPhp = void 0;
const exec = __importStar(require("@actions/exec"));
const path = __importStar(require("path"));
const semver = __importStar(require("semver"));
function installPhp(version) {
    return __awaiter(this, void 0, void 0, function* () {
        const installVersion = convertInstallVersion(version);
        if (process.platform === 'linux') {
            if (!hasPatchVersion(version) && hasAptVersion(version)) {
                yield exec.exec(path.join(__dirname, 'apt-install-php-ubuntu.sh'), [
                    new Number(version).toFixed(1)
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
    return semver.satisfies(Semver.version, '5.6 || <=7.4 || <= 8.0');
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
            return '7.1.33';
        case '7.2':
            return '7.2.34';
        case '7.3':
            return '7.3.28';
        case '7.4':
            return '7.4.19';
        case '8.0':
            return '8.0.6';
    }
    return version;
}
exports.convertInstallVersion = convertInstallVersion;
