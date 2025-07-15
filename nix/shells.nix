{
  pkgs ? import <nixpkgs> {},
  outputs,
  ...
}: let
  pcChecks = outputs.checks.${pkgs.system}.pre-commit-check;

  # Base dependencies shared across all development shells
  commonDeps = with pkgs; [
    # base
    nix
    git
    just
    pre-commit
    bashInteractive
    coreutils
    direnv

    # security
    mkpasswd
    sops
    rage
    ssh-to-age
    gnupg
    openssh
  ];

  # Reusable shell builder function
  mkDevShell = {
    name,
    extraNativeBuildInputs ? [],
    extraBuildInputs ? [],
    usePreCommitHook ? true,
    extraShellHook ? "",
  }:
    pkgs.mkShell {
      inherit name;
      NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";

      buildInputs =
        (
          if usePreCommitHook
          then pcChecks.enabledPackages
          else []
        )
        ++ extraBuildInputs;
      nativeBuildInputs = commonDeps ++ extraNativeBuildInputs;

      shellHook = ''
        echo "🚀 Entering ${name} development shell..."
        ${
          if usePreCommitHook
          then pcChecks.shellHook
          else ""
        }
        ${extraShellHook}
        echo "✅ Development environment ready!"
      '';
    };
in
  with pkgs; {
    # Documentation environment (optional example)
    default = mkDevShell {
      name = "documentation";
      extraNativeBuildInputs = [
        mdbook
      ];

      extraShellHook = ''
        echo "📚 Documentation tools ready"
        # show availabel commands
        echo "==========================="
        just
        echo "==========================="
      '';
    };
  }
