{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # Desktop apps
    # inkscape
    # kicad
    krita
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
    mumble
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
    # mono
    python314
    # python314Packages.matplotlib
    # python314Packages.numpy
    python314Packages.pip

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
