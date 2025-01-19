{
  description = "aloshy.🅰🅸 | Raspberry Pi 4 NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
  };

  outputs = { self, nixpkgs, ... }@inputs: rec {

    # here goes the other flake outputs, if you have any

    nixosConfigurations."etherpi" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
