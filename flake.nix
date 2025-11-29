{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: {
    packages = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [];
          config = {};
        };
      in
        nixCats.utils.mkAllWithDefault (import ./. (inputs // {inherit pkgs;}))
    );
    homeModule = self.packages.x86_64-linux.default.homeModule;
    nixosModule = self.packages.x86_64-linux.default.nixosModule;
  };
}
