{ pkgs, ... }:

# Sehr primitives Modul.  Siehe https://nixos.wiki/wiki/Module oder
# mein "dotfiles"-Repository für Beispiele für Module mit Optionen.
# Über Optionen können beispielsweise Unterschiede zwischen
# verschiedenen Systemen, die sich die home-manager-Konfiguration
# teilen, abgebildet und gehändelt werden.
{
  home = {
    packages = [ pkgs.bat ];
    file = { ".config/bat/config".source = ./config; };
  };
}
