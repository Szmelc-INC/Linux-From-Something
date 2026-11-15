# Maintainer: SilverX <serainox@gmail.com>
pkgname=lfn-git
_repo=Linux-From-Something
pkgver=r0.0000000
pkgrel=1
pkgdesc="Linux From Nothing 2.0: staged, idempotent build driver for a from-scratch Linux guest (Arch host edition)"
arch=('any')
url="https://github.com/Szmelc-INC/Linux-From-Something"
license=('MIT')
depends=('bash' 'base-devel' 'git' 'curl' 'tar' 'xz' 'gzip' 'bzip2' 'perl' 'python' 'bison' 'flex' 'bc'
         'rsync' 'cpio' 'fakeroot' 'e2fsprogs' 'util-linux' 'qemu-system-x86' 'qemu-img' 'binutils' 'pkgconf')
makedepends=('git')
optdepends=('pahole: CONFIG_DEBUG_INFO_BTF kernels'
            'texinfo: GNU docs (the build skips them by default)'
            'grub: Phase 5 BIOS bootloader stage')
provides=('lfn')
conflicts=('lfn')
source=("git+$url.git")
sha256sums=('SKIP')

pkgver() {
  cd "$_repo"
  ( set -o pipefail
    git describe --long --tags --abbrev=7 2>/dev/null | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g' ||
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=7 HEAD)" )
}

package() {
  cd "$_repo"
  install -d "$pkgdir/usr/share/lfn"
  cp -r lfn lfn.conf scripts tests "$pkgdir/usr/share/lfn/"
  # The tree is read-only once installed: keep the heavy work dir per user.
  install -Dm755 /dev/stdin "$pkgdir/usr/bin/lfn" <<'SH'
#!/usr/bin/env bash
export LFN_WORK="${LFN_WORK:-${XDG_DATA_HOME:-$HOME/.local/share}/lfn}"
exec /usr/share/lfn/lfn "$@"
SH
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 README.md LFN-2.md -t "$pkgdir/usr/share/doc/$pkgname/"
}
