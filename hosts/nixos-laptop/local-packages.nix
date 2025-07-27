{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # Desktop apps
    alacritty
    easyeffects
    gparted
    kdePackages.kdenlive
    librewolf
    mangohud
    mcontrolcenter

    # CLI utils
    aria2
    bind
    curl
    htop
    ipset
    lshw
    libva-utils
    libva
    wget

    # GStreamer
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    gst_all_1.gst-vaapi

    # Coding stuff
    android-tools
    cargo
    clang
    clang-tools
    cmake
    gcc
    gnumake
    ninja
    rustc
    zulu
  ];
}
