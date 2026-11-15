{
  description = "Linux From Nothing 2.0: staged, idempotent build driver for a from-scratch Linux guest";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      # Host tools checked by scripts/stages/00-host-check.sh.
      hostTools = pkgs: with pkgs; [
        gcc gnumake binutils git curl gnutar xz gzip bzip2 patch gnused gawk perl python3
        bison flex bc rsync cpio fakeroot e2fsprogs util-linux qemu pkg-config
      ];
    in
    {
      packages = forAllSystems (pkgs: rec {
        lfn = pkgs.stdenvNoCC.mkDerivation {
          pname = "lfn";
          version = "0-unstable-${self.shortRev or self.dirtyShortRev or "dirty"}";
          src = ./.;
          nativeBuildInputs = [ pkgs.makeWrapper ];
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/lfn $out/bin
            cp -r lfn lfn.conf scripts tests $out/share/lfn/
            patchShebangs $out/share/lfn
            makeWrapper $out/share/lfn/lfn $out/bin/lfn \
              --run 'export LFN_WORK="''${LFN_WORK:-''${XDG_DATA_HOME:-$HOME/.local/share}/lfn}"' \
              --suffix PATH : ${pkgs.lib.makeBinPath (hostTools pkgs)}
            install -Dm644 README.md LFN-2.md -t $out/share/doc/lfn
            runHook postInstall
          '';
          meta = {
            description = "Linux From Nothing 2.0: staged, idempotent build driver for a from-scratch Linux guest";
            homepage = "https://github.com/Szmelc-INC/Linux-From-Something";
            license = pkgs.lib.licenses.mit;
            mainProgram = "lfn";
            platforms = pkgs.lib.platforms.linux;
          };
        };
        default = lfn;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/lfn";
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell { packages = hostTools pkgs ++ [ pkgs.shellcheck ]; };
      });
    };
}
