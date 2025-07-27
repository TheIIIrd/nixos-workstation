{ pkgs, ... }: {
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment = {
    gnome.excludePackages = with pkgs; [
      decibels
      geary
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-shell-extensions
      gnome-tour
      seahorse
      snapshot
      totem
    ];

    systemPackages = (with pkgs; [
      clapper
      dconf-editor
      eyedropper
      fragments
      gapless
      gnome-tweaks
      helvum
      mission-center
      ptyxis
      rnote
    ]) ++ (with pkgs.gnomeExtensions; [
      appindicator
      arcmenu
      blur-my-shell
      caffeine
      clipboard-indicator
      dash-to-panel
      just-perfection
      vitals
    ]);
  };
}
