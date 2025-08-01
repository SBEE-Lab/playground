{
  self,
  pkgs,
  outputs,
  ...
}: let
  pcChecks = outputs.checks.${pkgs.system}.pre-commit-check;

  # Base dependencies shared across all development shells
  commonDeps = with pkgs; [
    nix
    git
    just
    bashInteractive
    uutils-coreutils
  ];
  mkChapterShell = {
    chapter,
    extraNativeBuildInputs ? [],
    extraBuildInputs ? [],
    usePreCommitHook ? false,
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
        cd $REPO_ROOT/practice/${chapter};
        echo "Current path: $(pwd)"
      '';
    };
in {
  default = pkgs.mkShell {
    name = "documentation";
    nativeBuildInputs = with pkgs; [
      nix
      git
      just
      ripgrep
      sd
      fd

      mdbook
      mdbook-mermaid
      mdbook-admonish
      pre-commit
      git-cliff

      self.packages.${pkgs.system}.preview
      self.packages.${pkgs.system}.release
    ];

    NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    shellHook = ''
      export REPO_ROOT=$(git rev-parse --show-toplevel)
      git config --local commit.template $REPO_ROOT/.gitmessage
      ${pcChecks.shellHook}
      echo "📚 Documentation tools ready"
    '';
  };
  chapter01 = import ./chapter01 {inherit pkgs mkChapterShell;};
}
