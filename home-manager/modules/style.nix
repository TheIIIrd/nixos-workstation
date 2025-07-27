{ pkgs, ... }: {
  home.packages = with pkgs; [
    adw-gtk3
    morewaita-icon-theme
    tela-circle-icon-theme
  ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      name = "Tela-circle-dark";
    };
  };
}
