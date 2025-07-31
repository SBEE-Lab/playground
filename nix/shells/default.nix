{
  pkgs,
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
    uutils-coreutils
    ripgrep
  ];

  # Reusable shell builder function
  mkChapterShell = {
    chapter,
    extraNativeBuildInputs ? [],
    extraBuildInputs ? [],
    usePreCommitHook ? true,
    extraShellHook ? "",
  }:
    pkgs.mkShell {
      name = chapter;
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
        export REPO_ROOT=$(git rev-parse --show-toplevel)
        echo "🚀 Entering ${chapter} development shell..."
        ${
          if usePreCommitHook
          then pcChecks.shellHook
          else ""
        }
        ${extraShellHook}
        echo "✅ Development environment ready!"
      '';
    };
in {
  default = pkgs.mkShell {
    name = "documentation";
    nativeBuildInputs = with pkgs;
      [
        mdbook
        mdbook-mermaid
        mdbook-admonish
        git-cliff
        pandoc
      ]
      ++ commonDeps;

    NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    shellHook = ''
      export REPO_ROOT=$(git rev-parse --show-toplevel)
      ${pcChecks.shellHook}
      echo "📚 Documentation tools ready"
      # show availabel commands
      echo "==========================="
      just
      echo "==========================="
    '';
  };
  chapter1 = import ./chapter1.nix {inherit mkChapterShell pkgs;};
}
