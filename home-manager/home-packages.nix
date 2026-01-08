{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # Desktop apps
    # inkscape
    # kicad
    krita
    # obsidian
    onlyoffice-desktopeditors
    protonplus
    protontricks
    r2modman
    tor-browser
    ungoogled-chromium
    vesktop
    vscodium

    # CLI utils
    fastfetch
    ffmpeg
    file
    fzf
    git-graph
    mediainfo
    ripgrep
    shellcheck
    texliveTeTeX
    tldr
    tree
    unrar-free
    unzip
    zip

    # Coding stuff
    # dotnet-sdk
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
    noto-fonts-color-emoji
    noto-fonts-lgc-plus
    font-awesome
    powerline-fonts
    powerline-symbols

    # Other
    nix-prefetch-scripts
  ];
}
