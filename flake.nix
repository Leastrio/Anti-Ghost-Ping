{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };
  outputs = {
    self,
    nixpkgs,
    devenv
  } @ inputs: 
  let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in
  {
    devShell.x86_64-linux = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        ({ pkgs, ... }: {
          packages = [pkgs.gnumake pkgs.gcc];
          languages.elixir.enable = true;
          languages.erlang.enable = true;
          services.postgres.enable = true;
          services.postgres.listen_addresses = "127.0.0.1";
          services.postgres.initialScript = ''
            CREATE USER agp SUPERUSER;
            ALTER USER agp PASSWORD 'password';
            CREATE DATABASE agp OWNER agp
          '';
        })
      ];
    };
  };
}
