{ config, pkgs, ... }:

{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "jo";
    homeDirectory = "/home/jo";

    packages = [ pkgs.bat pkgs.curl pkgs.fd pkgs.nixfmt ];

    file = {
      ".config/alacritty/alacritty.yml".source = ./alacritty.yml;
      ".config/bat/config".source = ./batconfig;
      ".ssh/config".source = ./sshconfig;
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.05";
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;

    fish = {
      # Standard
      enable = true;
      functions = {
        fish_prompt = ''
          set_color purple
          echo (pwd) '$' (set_color normal)
        '';
        fish_right_prompt = ''
          set_color blue
          echo "BOB 2022"
        '';
      };
      shellAbbrs = { hs = "home-manager switch"; };
    };

    git = {
      enable = true;
      userName = "Johannes";
      userEmail = "johannes.maier@active-group.de";
      aliases = { pushf = "push --force-with-lease"; };
      extraConfig = {
        core.askPass = "";
        init.defaultBranch = "main";
        submodule.recurse = true;
        merge.conflictstyle = "diff3";
      };
    };

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        brettm12345.nixfmt-vscode
      ];
    };
  };

  nixpkgs.config = { allowUnfree = true; };
}
