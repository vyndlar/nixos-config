{
  description = "Nix-Flatpak + Index Database + Spicetify flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
      # inputs.nixpkgs.follows = "nixpkgs"; # idk if needed
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-flatpak, nix-index-database, spicetify-nix, ... }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # supposed to make spicetify work tbh idk what this does
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

	# spicetify-nix.nixosModules.default

      ];
    };
  };
}
