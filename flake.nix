{
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        erlangVersion = "erlangR26";
        elixirVersion = "elixir_1_15";

        elixir = pkgs.beam.packages.${erlangVersion}.${elixirVersion};
        erlang = pkgs.beam.interpreters.${erlangVersion};
      in rec {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            elixir
            erlang
          ];
          ERL_AFLAGS = "-kernel shell_history enabled";
        };
      }
    );
}
