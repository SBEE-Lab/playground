{
  self,
  pkgs,
}: {
  release = {
    type = "app";
    program = "${self.packages.${pkgs.system}.release}/bin/release";
  };
  preview = {
    type = "app";
    program = "${self.packages.${pkgs.system}.preview}/bin/preview";
  };
}
