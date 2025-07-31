{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) pre-commit-hooks;
in {
  pre-commit-check = pre-commit-hooks.lib.${pkgs.system}.run {
    src = ../.;
    default_stages = ["pre-commit"];
    hooks = {
      sops-encryption = {
        enable = true;
        name = "sops-encryption";
        entry = "${pkgs.pre-commit-hook-ensure-sops}/bin/pre-commit-hook-ensure-sops";
        language = "system";
        files = "secrets.*\\.ya?ml$";
        pass_filenames = true;
      };

      # global settings
      alejandra.enable = true;
      check-case-conflicts.enable = true;
      check-executables-have-shebangs.enable = true;
      check-merge-conflicts.enable = true;
      detect-private-keys.enable = true;
      fix-byte-order-marker.enable = true;
      mixed-line-endings.enable = true;
      trim-trailing-whitespace.enable = true;
      end-of-file-fixer.enable = true;
      check-yaml.enable = true;
      check-json.enable = true;

      markdownlint = {
        enable = true;
        settings.configuration = {
          MD013.line_length = 200;
          MD033.allowed_elements = ["br"];
          MD024 = false;
          MD029 = false;
          MD036 = false;
        };
        excludes = ["COMMIT_CONVENTION.md"];
      };

      build-docs = {
        enable = true;
        name = "Build documentation";
        entry = "${pkgs.mdbook}/bin/mdbook build docs/";
        pass_filenames = false;
        files = "docs/.*";
      };

      clean-docs = {
        enable = true;
        name = "Clean cached local documentation";
        entry = "${pkgs.mdbook}/bin/mdbook clean docs/";
        pass_filenames = false;
        files = "docs/.*";
      };
    };
  };
}
