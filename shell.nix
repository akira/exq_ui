{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  nativeBuildInputs =
    [ pkgs.nodejs-18_x pkgs.beam.packages.erlangR25.elixir_1_14 ];
}
