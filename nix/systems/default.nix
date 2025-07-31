{pkgs, ...}: {
  system.stateVersion = "24.11";
  boot.loader.grub.device = "/dev/vda";

  virtualisation = {
    memorySize = 2048;
    cores = 2;
    diskSize = 8192;
    forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };

  networking.hostName = "simple-vm";
  networking.firewall.enable = false;

  users.users.playground = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    password = "sbee";
  };

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  environment.systemPackages = with pkgs; [vim curl git];
}
