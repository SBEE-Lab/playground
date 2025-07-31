{
  pkgs ?
    import (fetchTarball {
      # 특정 nixpkgs 커밋 고정
      url = "https://github.com/NixOS/nixpkgs/archive/22.11.tar.gz";
      sha256 = "11w3wn2yjhaa5pv20gbfbirvjq6i3m7pqrq2msf0g7cv44vijwgw";
    }) {},
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python38 # Python 3.8.16
    python38Packages.biopython # BioPython 1.79
    python38Packages.pandas # Pandas 1.5.3
  ];
}
