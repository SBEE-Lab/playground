let
  buildConfig = {
    name,
    version ? "1.0",
    debug ? false,
  }: {
    inherit name version debug;
    buildType =
      if debug
      then "development"
      else "production";
  };
in
  # 사용 예시
  buildConfig {
    name = "myapp";
    debug = true;
  }
