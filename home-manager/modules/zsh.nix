{ config, ... }: {
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "~/.nix";
      in {
        sw = "nh os switch";
        upd = "nh os boot --update";
        hms = "nh home switch";

        t = "tldr";
        v = "nvim";
        se = "sudoedit";
        ff = "fastfetch";
        cls = "clear";

        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gu = "git pull";

        ".." = "cd ..";
      };

    history.size = 1000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    oh-my-zsh = {
      enable  = true;
      plugins = [ "git" "sudo" ];
      theme   = "agnoster";
    };
  };
}
