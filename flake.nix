{
  description = "Jekyll development environment for m7u.net";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          ruby = pkgs.ruby_3_3;
        in
        {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                ruby
                bundler
                libffi
                libyaml
                pkg-config
                zlib
                gnumake
              ]
              ++ lib.optionals stdenv.isLinux [
                gcc
              ]
              ++ lib.optionals stdenv.isDarwin [
                darwin.apple_sdk.frameworks.CoreServices
                darwin.apple_sdk.frameworks.Foundation
              ];

            shellHook = ''
              export BUNDLE_PATH="$PWD/vendor/bundle"
              export BUNDLE_APP_CONFIG="$PWD/.bundle"
              export PATH="$PWD/vendor/bundle/bin:$PATH"

              echo "Run: bundle install"
              echo "Then: bundle exec jekyll serve --livereload"
            '';
          };
        }
      );
    };
}
