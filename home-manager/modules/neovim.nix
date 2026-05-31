{ pkgs, ... }: {
  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      lua-language-server
      python314Packages.python-lsp-server
      nixd
    ];
  };
}
