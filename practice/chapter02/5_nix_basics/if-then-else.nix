let
  environment = "production";
  useSSL = true;
in {
  debug =
    if environment == "development"
    then true
    else false;
  protocol =
    if useSSL
    then "https"
    else "http";

  resources =
    if environment == "production"
    then {
      memory = "4GB";
      cpu = 4;
    }
    else {
      memory = "1GB";
      cpu = 1;
    };
}
