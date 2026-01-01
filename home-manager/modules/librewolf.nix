{ pkgs, ... }: {
  programs.librewolf = {
    enable = true;
    package = pkgs.librewolf;

    settings = {
      "browser.bookmarks.defaultLocation" = "toolbar";
      "browser.urlbar.suggest.bookmark" = false;
      "browser.urlbar.suggest.engines" = false;
      "browser.urlbar.suggest.history" = false;
      "browser.urlbar.suggest.openpage" = false;
      "browser.urlbar.suggest.topsites" = false;
      "media.autoplay.blocking_policy" = 2;
      "permissions.default.camera" = 2;
      "permissions.default.desktop-notification" = 2;
      "permissions.default.geo" = 2;
      "permissions.default.microphone" = 2;
      "security.OCSP.require" = false;
      "webgl.disabled" = false;
    };
  };
}
