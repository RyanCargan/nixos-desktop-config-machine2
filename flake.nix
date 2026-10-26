{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    firefox.url = "github:nix-community/flake-firefox-nightly";
    zed-fork.url = "github:RyanCargan/zed";
    claude-fork.url = "github:RyanCargan/nix-claude-code";
    # Pinned to the release branch matching nixos-26.05 (same nixpkgs
    # major/minor); follows drops HM's own nixpkgs pin so one rev serves all.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        # Home Manager as a NixOS module: user profiles rebuild together
        # with the system on nixos-rebuild. useGlobalPkgs reuses the
        # system's pkgs (no second nixpkgs evaluation); useUserPackages
        # puts HM packages into the user profile.
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = ".hmbak";
          home-manager.users.ryan = ./home.nix;
        }
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
