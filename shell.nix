{ pkgs ? import <nixpkgs> {} }:

let
  # Use rust-overlay for more control over Rust versions
  rustOverlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  pkgs-with-overlay = import <nixpkgs> { overlays = [ rustOverlay ]; };

  rust = pkgs-with-overlay.rust-bin.selectLatestNightlyWith(toolchain: toolchain.default.override {
    extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
    
  });

  # rust = pkgs-with-overlay.rust-bin.stable.latest.default.override {
  #   extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
  # };
in

pkgs.mkShell {
  buildInputs = [
    # Use the Rust from overlay
    rust

    pkgs.bacon
    pkgs.tokei
    
    # Additional tools that are commonly used with Rust
    pkgs.pkg-config
    pkgs.openssl.dev
  ];

  # Set environment variables and ensure tools are in PATH
  shellHook = ''
    # Set RUST_SRC_PATH for rust-analyzer
    export RUST_SRC_PATH=${rust}/lib/rustlib/src/rust/library
    
    # Verify rust-analyzer is accessible
    if command -v rust-analyzer >/dev/null 2>&1; then
    else
      echo "WARNING: rust-analyzer is not in PATH!"
    fi

    echo "Rust development environment loaded!"
    echo "rustc --version: $(rustc --version)"
    echo "cargo --version: $(cargo --version)"
  '';
}
