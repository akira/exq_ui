{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs =
    [ pkgs.nodejs_20 pkgs.beam.packages.erlang_26.elixir_1_16 ];
}
