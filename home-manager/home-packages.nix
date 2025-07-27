{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # Desktop apps
    inkscape
    kicad
    krita
    obsidian
    onlyoffice-desktopeditors
    protonplus
    protontricks
    r2modman
    tenacity
    tor-browser
    vesktop
    vscodium

    # CLI utils
    binwalk
    fastfetch
    ffmpeg
    file
    fzf
    git-graph
    mediainfo
    ripgrep
    shellcheck
    silicon
    texliveTeTeX
    tldr
    tree
    unzip
    zip

    # Coding stuff
    dotnet-sdk
    meson
    mono
    python313
    python313Packages.black
    python313Packages.matplotlib
    python313Packages.numpy
    python313Packages.pip

    # Fonts
    corefonts
    jetbrains-mono
    meslo-lgs-nf
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-emoji
    font-awesome
    powerline-fonts
    powerline-symbols

    # Other
    nix-prefetch-scripts
  ];
}
