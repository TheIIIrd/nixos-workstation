{ pkgs, ... }: {
  services.displayManager = {
    defaultSession = "plasma";
    sddm.enable = true;
    sddm.wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;
  programs.dconf.enable = true;

  environment = {
    systemPackages = (with pkgs; [
      okteta
      transmission_4-qt
      vlc
    ]) ++ (with pkgs.kdePackages; [
      filelight
      isoimagewriter
      kcalc
      kcolorchooser
      kompare
      # merkuro
      partitionmanager
      sddm-kcm
    ]);
  };
}
