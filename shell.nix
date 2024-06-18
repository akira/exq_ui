{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs =
    [ pkgs.nodejs-18_x pkgs.beam.packages.erlangR26.elixir_1_16 ];
}
