let
  basePackages = ["git" "curl"];
  devPackages = ["vim" "tmux"];

  baseConfig = {
    timeout = 30;
    retries = 3;
  };
  prodConfig = {
    ssl = true;
    cache = true;
  };
in {
  # 리스트 병합
  allPackages = basePackages ++ devPackages;

  # 속성집합 병합
  config = baseConfig // prodConfig;

  # 조건부 확장
  packages =
    basePackages
    ++ (
      if true
      then devPackages
      else []
    );
}
