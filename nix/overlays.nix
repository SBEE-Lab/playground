{inputs, ...}: {
  # ============================================
  # Nixpkgs Version Overlays
  # ============================================

  # Currently default nixpkgs on the stable (25.05)
  # Adds pkgs.stable == inputs.nixpkgs.legacyPackages.${pkgs.system} (current stable)
  # stable = final: _: {
  #   stable = import inputs.nixpkgs-stable {
  #     inherit (final) system;
  #     config.allowUnfree = true;
  #   };
  # };

  # Adds pkgs.unstable == inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}
  unstable = final: _: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  # Adds pkgs.master == inputs.nixpkgs-master.legacyPackages.${pkgs.system}
  master = final: _: {
    master = import inputs.nixpkgs-master {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  # ============================================
  # Flake Inputs Overlay
  # ============================================

  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages.default
      )
      inputs;
  };

  # ============================================
  # Modifications & Patches
  # ============================================

  modifications = _final: prev: {
    openssh = prev.openssh.override {
      withFIDO = true;
      withSecurityKey = true;
    };
    # Example: Apply custom patch on Git
    # git = addPatches prev.git [
    #   ./patches/git-custom-feature.patch
    # ];

    # Example: Override Firefox configurations
    # firefox = prev.firefox.override {
    #   extraPolicies = {
    #     DisableTelemetry = true;
    #     DisableFirefoxStudies = true;
    #   };
    # };

    # Example: Add VSCode Extension
    # vscode-with-extensions = prev.vscode-with-extensions.override {
    #   vscodeExtensions = with prev.vscode-extensions; [
    #     ms-vscode.cpptools
    #     ms-python.python
    #   ];
    # };
  };

  # ============================================
  # Application-specific Overlays
  # ============================================

  # zjstatus = import ./zjstatus {inherit inputs;};

  # ============================================
  # Development Environment Overlays
  # ============================================
  development = _final: prev: {
    # Python DevEnvs
    pythonDev = prev.python3.withPackages (ps:
      with ps; [
        # requests
        # flask
        # pytest
        # black
        # flake8
      ]);

    # Node.js DevEnvs
    nodeDev =
      prev.nodejs.overrideAttrs (_old: {
      });

    # Rust DevEnvs
    rustDev =
      prev.rustc.overrideAttrs (_old: {
      });
  };
}
