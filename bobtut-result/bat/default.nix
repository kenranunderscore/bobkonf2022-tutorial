{ pkgs, ... }:

{
  home = {
    packages = [ pkgs.bat ];
    file = { ".config/bat/config".source = ./config; };
  };
}
