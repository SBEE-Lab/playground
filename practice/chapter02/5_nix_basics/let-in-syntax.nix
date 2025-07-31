let
  version = "3.8";
  packages = ["requests" "flask"];

  mkEnv = packages: {
    python = version;
    dependencies = packages;
  };
in
  mkEnv packages
