{ config, pkgs, lib, ... }:

# Simples pinning von nixpkgs.  Dies zeigt, wie man generall "Dinge"
# mit festem Commit via Git laden und den Hash dazu angeben kann.  Für
# ein "richtiges", produktives Pinning, das auch home-manager selbst
# beinhaltet, empfehle ich im ersten Ansatz `niv`.  Siehe dazu:
#
# - https://eevie.ro/posts/2022-01-24-how-i-nix.html
# - https://github.com/ryantm/home-manager-template
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

    # Liste von Programmen, die installiert sein sollen.
    packages = with pkgs; [ curl fd nixfmt pass emacs ];

    file = {
      ".config/alacritty/alacritty.yml".source = ./alacritty.yml;
      ".ssh/config".source = ./sshconfig;

      # Naiver Ansatz -> readonly Emacs-Konfiguration. Siehe `activation`
      # für "Trick"/"Hack".
      # ".emacs.d" = {
      #   source = ./emacs.d;
      #   recursive = true;
      # };
    };

    # Einhängen in die Aktivierungsphase von home-manager. Hier
    # erstellen wir einen Symlink auf die Datei im Repo, ohne den
    # Umweg über den /nix/store.
    #
    # $DRY_RUN_CMD sorgt dafür, dass bei einem `home-manager`-Aufruf
    # mit dem Flag --dry-run auch hier kein Code läuft.
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
      # Standard: ohne `enable = true;` kein Programm! Kann bspw. auf
      # `false` gesetzt werden, um schnell etwas
      # auszukommentieren/rauszunehmen.
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
      # Cooles fish-Feature (imho)
      shellAbbrs = { hs = "home-manager switch"; };
    };

    git = {
      enable = true;
      # NOTE: Erklären: custom Package + nix repl '<nixpkgs>'!
      # package = pkgs.gitAndTools;
      userName = "Johannes";
      userEmail = "johannes.maier@active-group.de";
      aliases = { pushf = "push --force-with-lease"; };
      # Viele Pakete, die via programs.<xyz> konfiguriert werden
      # können, haben eine `extraConfig`; manchmal im Nix-"Format" wie
      # hier, manchmal aber auch als Multiline-Strings im
      # Originalformat.
      extraConfig = {
        core.askPass = "";
        init.defaultBranch = "main";
        submodule.recurse = true;
        merge.conflictstyle = "diff3";
      };
    };

    # Visual Studio Code mit "eingebauten" Erweiterungen.
    vscode = {
      enable = true;
      mutableExtensionsDir = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        brettm12345.nixfmt-vscode
      ];
    };

    # Muss man leider beides anschalten, da das `enable` weiter unten
    # bei accounts.email.accounts.<name>... nicht das Programm
    # mitbringt.
    mbsync.enable = true;
    msmtp.enable = true;
  };

  # Beeinflusst so nur das Package-Set, das von home-manager genutzt
  # wird.  Siehe `man home-configuration.nix` für Beispielcode, wie
  # man auch das "globale" <nixpkgs> via Konfigurationsdatei
  # mitsteuert.
  nixpkgs.config = { allowUnfree = true; };

  # Deklarative E-Mail-Konfiguration für Maildir-Benutzung (hier
  # GMail).  Erzeugt automatisch Konfigurationsdateien für
  # bspw. mbsync/isync, msmtp, offlineimap, etc.  Für diejenigen
  # interessant, die ihren E-Mail-Verkehr über Maildir und/oder
  # Programme wie notmuch, mu, mutt etc. managen wollen.
  accounts.email = {
    maildirBasePath = ".mail";
    accounts = {
      bobGmail = rec {
        # Magic: setzt IMAP und SMTP
        flavor = "gmail.com";
        # Es muss genau einen Primäraccount geben.
        primary = true;
        address = "bobkonf2022hm@gmail.com";
        userName = address;
        # GNU Pass kann genutzt werden, um ein Passwort für die
        # Anmeldung abzufragen.
        passwordCommand = "pass show mail/bobkonf2022hm@gmail.com";
        # Maildirsynchronisation
        mbsync = {
          enable = true;
          create = "both";
          remove = "both";
          expunge = "both";
        };
        # Zum Versenden von Mails (gibt sich [bei mir] als `sendmail`
        # aus)
        msmtp.enable = true;
      };
    };
  };
}
