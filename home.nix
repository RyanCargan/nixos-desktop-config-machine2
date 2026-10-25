{ config, pkgs, inputs, ... }:

{
  # Set once to current release branch; never change. Upgrading this
  # value triggers migration logic; bump only when reading release notes
  # and intentionally migrating config.
  home.stateVersion = "26.05";

  # Your user; must match the username on the live system.
  home.username = "ryan";

  # Standard Linux home directory.
  home.homeDirectory = "/home/ryan";

  # Intentionally empty for the dry run: zero programs.*, zero home.packages.
  # This proves the NixOS module wiring works without changing the system.
  # Next step: populate programs.neovim, programs.zsh, home.packages, etc.
}