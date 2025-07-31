{
  description = "SBEE playground CI/CD flake";
  outputs = inputs @ {self, ...}: let
    inherit (self) outputs;
    inherit (inputs.nixpkgs) lib;
    # ======== Helper Functions ========
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    pkgsFor = lib.genAttrs systems (
      system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowUnsupportedSystem = true;
          overlays = builtins.attrValues self.overlays;
        }
    );
    forEachSystem = f: lib.genAttrs systems (system: f (pkgsFor.${system}));
  in {
    devShells = forEachSystem (pkgs: import ./nix/shells {inherit pkgs outputs;});
    formatter = forEachSystem (pkgs: import ./nix/formatter.nix {inherit pkgs;});
    checks = forEachSystem (pkgs: import ./nix/checks.nix {inherit inputs pkgs;});
    packages = forEachSystem (pkgs: import ./nix/packages {inherit pkgs;});
    overlays = import ./nix/overlays.nix {inherit inputs;};
  };

  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [
      "https://cachix.cachix.org"
      "https://nixpkgs.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
