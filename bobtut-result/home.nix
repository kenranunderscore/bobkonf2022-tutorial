{ config, pkgs, lib, ... }:

# Simples pinning von nixpkgs.
#
# # Statt Zeile 1 Folgendes ('pkgs' nicht mehr als Input):
# { config, lib, ... }:
#
# let
#   # Ausgesuchter Commit:
#   rev = "3e644bd62489b516292c816f70bf0052c693b3c7";
#   nixpkgsSources = builtins.fetchTarball {
#     name = "nixpkgs-unstable-sources-bobkonf2022";
#     url = "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
#     # Entweder sha256 durch '00...' ersetzen und bei Mismatch Ergebnis
#     # hier einfügen; oder:
#     # nix-prefetch-url --unpack https://github.com/nixos/nixpkgs/archive/<rev>.tar.gz
#     sha256 = "1bkqdwcmap2km4dpib0pzgmj66w74xvr8mrvsshp7y569lj40qxi";
#   };
#   pkgs = import nixpkgsSources { };
# in

{
  imports = [ ./bat ];

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "jo";
    homeDirectory = "/home/jo";

    packages = with pkgs; [ curl fd nixfmt pass emacs ];

    file = {
      ".config/alacritty/alacritty.yml".source = ./alacritty.yml;
      ".ssh/config".source = ./sshconfig;
      # ".emacs.d" = {
      #   source = ./emacs.d;
      #   recursive = true;
      # };
    };

    activation = {
      symlinkDotEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e $HOME/.emacs.d ]; then
          $DRY_RUN_CMD ln -snf $HOME/.config/nixpkgs/emacs.d $HOME/.emacs.d
        fi
      '';
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
      # NOTE: Erklären: custom Package! + nix repl '<nixpkgs>'!!!
      # package = pkgs.gitAndTools;
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

    mbsync.enable = true;
    msmtp.enable = true;
  };

  nixpkgs.config = { allowUnfree = true; };

  accounts.email = {
    maildirBasePath = ".mail";
    accounts = {
      bobGmail = rec {
        # Magic: setzt IMAP und SMTP
        flavor = "gmail.com";
        primary = true;
        address = "bobkonf2022hm@gmail.com";
        userName = address;
        passwordCommand = "pass show mail/bobkonf2022hm@gmail.com";
        # Maildir empfangen
        mbsync = {
          enable = true;
          create = "both";
          remove = "both";
          expunge = "both";
        };
        msmtp.enable = true;
      };
    };
  };
}
