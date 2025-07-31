let
  config = {
    host = "localhost";
    port = 8080;
    ssl = false;
  };
in {
  # with 사용으로 간결한 참조
  url = with config; "${host}:${toString port}";
  secure = with config; ssl;
}
