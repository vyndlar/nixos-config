{
  description = "Nix-Flatpak flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
      # inputs.nixpkgs.follows = "nixpkgs"; # idk if needed
    };
  };

  outputs = { self, nixpkgs, nix-flatpak, ... }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64";
      modules = [
        ./configuration.nix

        
	###############
        ### FLATPAK ###
        ###############
        
        nix-flatpak.nixosModules.nix-flatpak

      ];
    };
  };
}
