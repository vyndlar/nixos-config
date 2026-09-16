# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# { config, pkgs, ... }:

{ config, inputs, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      inputs.spicetify-nix.nixosModules.default

      # ./alacritty-mocha.nix
    ];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";

    options = "caps:swapescape,compose:ralt"; # swap esc and caps, ralt used to type special chars
  };

  i18n.inputMethod = { # ALLOWS ME TO TYPE MULTIPLE LANGS
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons # CHINESE SUPPORT

	fcitx5-gtk
	qt6Packages.fcitx5-qt
	qt6Packages.fcitx5-configtool
      ];
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # Use the WirePlumber session manager
    #wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."vyndlar" = {
    isNormalUser = true;
    description = "Dane";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  kdePackages.kate
    #  thunderbird
    ];

  };

  users.defaultUserShell = pkgs.zsh;


  ################
  ### PROGRAMS ###
  ################

  # Install firefox.
  programs.firefox.enable = true;
  programs.nix-index.enable = true;
  programs.gamemode.enable = true;
  programs.git.enable = true;
  programs.zoxide.enable = true;
  programs.steam.enable = true;
  programs.xwayland.enable = true;

  programs.zsh = {	# zsh setup
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 1000;
    histFile = "$HOME/.histfile";

    shellAliases = {
      emacs = "emacs -nw";
    };

    ohMyZsh = {
      enable = true;
      # theme = "";
      plugins = [ "git" "sudo" ];
    };
  };

  environment.extraInit = ''
    export PATH="$HOME/.config/emacs/bin:$PATH"
  '';


  programs.starship = {

    enable = true;

    settings = {
      add_newline = false;
      format = "$username@$hostname$directory$character";
      right_format = "$git_branch$time";
      time = {
        disabled = false;
	format = ''[\[ $time \]](blue)'';
      };
      username = {
        disabled = false;
	show_always=true;
	style_user = "green bold";
	style_root = "red bold";
	format = "[$user]($style)";
      };
      hostname = {
        ssh_only = true;
	format = "[$hostname](green)";
      };
      git_branch = {
        disabled = false;
	symbol = " ";
	format = "[$symbol](blue)[$branch](blue) ";
      };
    };
  };

  programs.tmux = {
    enable = true;
    # shell = "${pkgs.bash}/bin/bash";
    shortcut = "a";
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    secureSocket = false;
    clock24 = true;
    historyLimit = 1000;

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.yank
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.catppuccin
    ];
    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set-option -sa terminal-overrides ",xterm*:Tc"

      # window splits
      bind | split-window -h -c "#{pane_current_path}"
      bind - split window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # shift + alt + H/L for prev/next window
      bind -n M-H previous-window;
      bind -n M-L next-window;

      # mouse on (duh)
      set -g mouse on
      '';
  };

  programs.spicetify =
  let 
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in
  {

    ### https://wiki.nixos.org/wiki/Spicetify-Nix

    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      ### https://gerg-l.github.io/spicetify-nix/extensions.html
      loopyLoop # specific portion of a track to loop over
      popupLyrics # name
      playlistIcons # give playlists icons in the left sidebar
      fullAlbumDate # name
      playlistIntersection # compare two playlists and make new playlists
      betterGenres # read it bru
      copyLyrics # lets you... copy lyrics
      savePlaylists # so you don't have to make a new playlist and copy all the songs
      queueTime # remaining time in queue
      allOfArtist # create a playlist w/ all songs of an artist
      aiBandBlocker # no more ai bands
      sessionStats # do i need to explain this..
    ];

    enabledCustomApps = with spicePkgs.apps; [
      ### https://gerg-l.github.io/spicetify-nix/custom-apps.html
    ];

    enabledSnippets = with spicePkgs.snippets; [
      ### https://github.com/spicetify/marketplace/blob/main/resources/snippets.json
      ### to get package names, run:
      ### nix eval --impure --json --expr 'builtins.attrNames ((builtins.getFlake "github:Gerg-L/spicetify-nix").legacyPackages.x86_64-linux.snippets)'


      ### MORE INFO:
      ### https://gerg-l.github.io/spicetify-nix/snippets.html


      hideMadeForYou
      darkLyrics
      disableRecommendations
      hideWhatsNewButton
      roundedNowPlaying
    ];
    
    ### https://gerg-l.github.io/spicetify-nix/themes.html
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };



  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # terminal tools (CLI)
    git
    curl
    fastfetch
    python315
    gcc
    man-pages

    # apps, terminal (TUI)
    neovim
    emacs # D: // :D
    htop
    btop

    # apps, productivity
    anki
    todoist-electron
    whatsapp-electron
    alacritty
    goldendict-ng
    onlyoffice-desktopeditors
    kicad
    gimp
    vscodium

    # apps, games
    prismlauncher # MINECRAFT

    # apps, entertainment
    # spotify ### COMMENTED OUT BC SPICETIFY AUTO-INSTALLS. 

    # apps, system health
    kdePackages.filelight

    # apps, other
    qbittorrent
    kdePackages.kdeconnect-kde
    solaar
    
  ];
    
    ################
    ### SERVICES ###
    ################

    services.openssh.enable = true;

    services.flatpak.enable = true;
    services.flatpak.packages = [
      # discord, proton mail, stremio, sober
      { appId = "com.discordapp.Discord"; origin = "flathub"; }
     #{ appId = "me.proton.Mail"; origin = "flathub"; } //// no subscription so..
     #{ appId = "com.stremio.Stremio"; origin = "flathub"; } //// not working idk why...
      { appId = "org.vinegarhq.Sober"; origin = "flathub"; }
    ];

    
    nixpkgs.config.allowUnfree = true;

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      wqy_zenhei
      noto-fonts-cjk-sans
    ];
    fonts.fontconfig.enable = true;
    fonts.fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];

    environment.sessionVariables = {
      # GOLDENDICT_FORCE_XCB = "1";
    };

    
    ##################
    ### NETWORKING ###
    ##################

    services.tailscale.enable = true;
    networking.nftables.enable = true;
    networking.firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    systemd.services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    systemd.network.wait-online.enable = false;
    boot.initrd.systemd.network.wait-online.enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
