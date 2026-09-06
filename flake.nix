{
  description = "Nix-Flatpak + Index Database flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
      # inputs.nixpkgs.follows = "nixpkgs"; # idk if needed
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-flatpak, nix-index-database, ... }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix

        
	###############
        ### FLATPAK ###
        ###############
        
        nix-flatpak.nixosModules.nix-flatpak


	######################
	### INDEX DATABASE ###
	######################

	nix-index-database.nixosModules.default

	{ programs.nix-index-database.comma.enable = true; } # enable comma for amazingness

      ];
    };
  };
}
