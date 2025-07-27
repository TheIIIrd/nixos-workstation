{ pkgs, ... }: {
  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      lua-language-server
      python313Packages.python-lsp-server
      nixd
    ];
  };
}
