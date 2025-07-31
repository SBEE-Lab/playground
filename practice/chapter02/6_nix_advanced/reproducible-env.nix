{
  pkgs ?
    import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
      sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
    }) {},
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38 # 정확히 Python 3.8.16
    git # 정확히 Git 2.38.1
  ];
}
