{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "split_lock_detect=off" "intel-iommu=on" ];
    kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    postBootCommands = ''
      DEVS="2188:0f:00.0 1aeb:0f:00.1"

      for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
      done
      modprobe -i vfio-pci
    '';
  };

  networking.hostName = "vostro"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable VMs
  virtualisation = {
    waydroid.enable = false;
    libvirtd.enable = true;
    libvirtd.qemu.ovmf.enable = true;
  };

  # Optimise storage
  nix.optimise.automatic = true;

  # Configure how nix works
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "el_GR.UTF-8";
    LC_IDENTIFICATION = "el_GR.UTF-8";
    LC_MEASUREMENT = "el_GR.UTF-8";
    LC_MONETARY = "el_GR.UTF-8";
    LC_NAME = "el_GR.UTF-8";
    LC_NUMERIC = "el_GR.UTF-8";
    LC_PAPER = "el_GR.UTF-8";

    LC_TELEPHONE = "el_GR.UTF-8";
    #LC_TIME = "el_GR.UTF-8";
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.xpra.pulseaudio = true;
      videoDrivers = [ "nvidia" ];
      windowManager.i3 = {
	enable = false;
	extraPackages = with pkgs; [
	  dmenu
	  i3status
	  i3blocks
	];
      };
      config = ''
        Section "Device"
            Identifier "nvidia"
            Driver "nvidia"
            BusID "PCI:1:0:0"
            Option "AllowEmptyInitialConfiguration"
        EndSection
      '';
      screenSection = ''
        Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
        Option         "TripleBuffer" "on"
      '';
    };
    flatpak.enable = true;
    gvfs.enable = true;
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.fish;
  users.users.b = {
    isNormalUser = true;
    description = "b";
    extraGroups = [ "networkmanager" "wheel" ];
    useDefaultShell = true;
    packages = with pkgs; [
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  # Run gpu-screen-recorder without root privilages.
  environment.etc."polkit-1/rules.d/99-no-password.rules".text = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.policykit.exec" && subject.isInGroup("b")) {
            return polkit.Result.YES;
        }
    });
  '';

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "b";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # List fonts installed in system profile
  fonts.packages = with pkgs; [
    fantasque-sans-mono #i love it
    material-design-icons
    hack-font
    font-awesome
    jetbrains-mono
    victor-mono
    roboto
    noto-fonts-cjk-sans
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
  # apps
    mako
    zulu24
    unzip
    ryubing
    tofi
    google-chrome
    kickoff
    clipse
    gpu-screen-recorder
    unipicker
    zoom-us
    xautoclick
    gpu-screen-recorder
    shotwell
    swappy
    webcamoid
    papers
    ytfzf
    nnn
    ffmpeg
    popsicle
    rm-improved
    nautilus
    font-manager
    gnome-font-viewer
    prismlauncher
    hyprpicker
    firefox
    alsa-utils
    libqalculate
    docker
    wget
    git
    hyprshot
    pavucontrol
    pamixer
    xdg-desktop-portal-hyprland
    waybar
    swaybg
    grim
    slurp
    libnotify
    flatpak
    btop
    wl-clipboard
    fzf
    eza
    steam
    vesktop
    r2modman
    fastfetch
    kdePackages.xwaylandvideobridge
    mpv
    meslo-lgs-nf
    cava
    xarchiver
    starship
    blesh
    killall
    gimp
    fuzzel 
    wlogout
    flatpak
    pulsemixer
    wl-color-picker
    libjpeg
    loupe
    gnome-tweaks
    xaos
    tty-clock
    libadwaita
    adw-gtk3
    fragments
    graphs
    gradience
    wpsoffice 
    cliphist
    virt-manager
    vim
  ];

  # Programs
  programs = {
    firefox.package = pkgs.latest.firefox-nightly-bin;
    hyprland.enable = true;
    steam.enable = true;
    fish = {
      enable = true;
      useBabelfish = true;
      shellAbbrs = {
        v="vim";
	vhypr="vim ~/.config/hypr/hyprland.conf";
	vnix="sudo vim /etc/nixos/configuration.nix";
	vnixh="sudo vim /etc/nixos/hardware-configuration.nix";
	nixr="sudo nixos-rebuild switch";
	rst="sudo alsactl restore && sudo alsactl store";
        hypr="Hyprland";
      };
      shellAliases = {
        grep = "grep --color=auto";
	ls="eza -s size -a --icons=always --hyperlink";
        mv="mv -v";
	cp="cp -vr";
	rm="rip"; 
        unipicker="unipicker | wl-copy";
      };
      shellInit = ''
        starship init fish | source
        function fish_greeting
          echo ""
	  fastfetch
	end
      '';
    };
    starship = {
      enable = true;
      presets = [ "nerd-font-symbols" "pure-preset" ];
    };
    bash = {
      interactiveShellInit = ''
	fish
      '';
    };
  };


  # Home Manager
  home-manager.users.b = { pkgs, ... }: {
    home.packages = [
    ]; # Color accent = #F5FFFF

    services = {
      mako = {
	enable = true;
	settings = {
  	  font = "Fantasque Sans Mono";
  	  width = 400;
  	  height = 80;
  	  margin = "15";
  	  padding = "15";
  	  border-size = 1;
  	  border-radius = 15;
  	  max-visible = 10;
  	  layer = "overlay";
  	  anchor = "top-right";
  	  background-color = "#000000";
  	  text-color = "#d8dee9";
  	  border-color = "#55555580";
          default-timeout = 4000;
  	  progress-color = "over #433E4A";	
        };
      }; 
    };

    programs.tofi = {
      enable = true;
      settings = {
	font = "Fantasque Sans Mono";
	font-size = 12;

	horizontal = true;
	anchor = "top";
	width = "70%";
	height = 48;
	outline-width = 0;
	border-width = 0;
	result-spacing = 30;
	padding-top = 12;
	padding-bottom = 8;
	padding-left = 600;
	padding-right = 0;
	prompt-text = "drun: ";
	prompt-padding = 10;

	prompt-color = "#be95ff";
	background-color = "#00000000";
	text-color = "#d8dee9";
	input-color = "#33b1ff";
	selection-color = "#ff7eb6";
	selection-match-color = "#42be65";
      };
    };

    programs.kitty = {
      enable = true;
      environment = { };
      keybindings = { };
      font.name = "Fantasque Sans Mono";
      font.size = 13;
      settings = {
        background_opacity = "1.7";
        enable_audio_bell = false;
        confirm_os_window_close  = 0;
      };
      extraConfig = ''
	foreground #d8dee9
	background #000000
	selection_foreground #f2f4f8
	selection_background #525252
	
	cursor #f2f4f8
	cursor_text_color #393939
	
	url_color #ee5396
	url_style single
	
	active_border_color #ee5396
	inactive_border_color #ff7eb6
	
	bell_border_color #ee5396
	
	wayland_titlebar_color system
	macos_titlebar_color system
	
	active_tab_foreground #161616
	active_tab_background #ee5396
	inactive_tab_foreground #dde1e6
	inactive_tab_background #393939
	tab_bar_background #161616
	
	#black
	color0 #262626
	color8 #393939
	#pink
	color1 #ff7eb6
	color9 #ff7eb6
	#green
	color2  #42be65
	color10 #42be65
	#cyan
	color3  #82cfff
	color11 #82cfff
	#blue
	color4  #33b1ff
	color12 #33b1ff
	#purple
	color5  #be95ff
	color13 #be95ff
	#cyan
	color6  #82cfff
	color14 #82cfff
	#white
	color7  #d8dee9
	color15 #ffffff
      '';
     };

    programs.wlogout = {
      enable = true;
      layout = [
	{
	  label = "shutdown";
	  action = "shutdown +0";
	  text = "Touch Grass";
	  keybind = "s";
	  circular = true;
	}
	{
	  label = "reboot";
	  action = "reboot";
	  text = "Restart?";
	  keybind = "r";
	  circular = true;
	}
	{
	  label = "suspend";
	  action = "sudo pm-suspend";
	  text = "A Mimir";
	  keybind = "h";
	  circular = true;
        }
      ]; 
    };

    programs.waybar = {
      enable = true;
      # Styling Waybar
      style = ''
	* {
	    font-family: Fantasque Sans Mono;
	    font-size: 16px;
	    border-radius: 15px;
	}
	window#waybar {
	    background-color: rgba(43, 48, 59, 0.0);
	    border-bottom: 0px solid rgba(100, 114, 125, 0.0);
	    color: #d8dee9;
	    transition-property: background-color;
	    transition-duration: .5s;
	}
	window#waybar.hidden {
	    opacity: 0.2;
	}
	button {
	    box-shadow: inset 0 -3px transparent;
	    border: #D8DEE9;
	    border-radius: 4px;
	}
	button:hover {
	    background: inherit;
	    box-shadow: inset 0 -3px transparent;
	}
	#workspaces button {
	    padding: 0 5px;
	    background-color: transparent;
	    color: #D8DEE9;
	}
	#workspaces button:hover {
	    background: rgba(0, 0, 0, 0.2);
	}
	#workspaces button.focused {
	    background-color: #64727D;
	    box-shadow: inset 0 -3px #d8dee9;
	}
	#workspaces button.urgent {
	    background-color: #eb4d4b;
	}
	#clock,
	#battery,
	#cpu,
	#memory,
	#disk,
	#temperature,
	#backlight,
	#network,
	#pulseaudio,
	#wireplumber,
	#custom-media,
	#tray,
	#mode,
	#idle_inhibitor,
	#scratchpad,
	#pulseaudio-slider,
	#language,
	#cava,
	#mpd {
	    padding: 0 10px;
	    color: #d8dee9;
 	    border: 1px solid #555555;
	    background-color: #000000;
	}
	#window,
	#workspaces {
	    margin: 0 4px;
	}
	.modules-right > widget:last-child > #workspaces {
	    margin-right: 0;
	}
	#tray > .needs-attention {
	    -gtk-icon-effect: highlight;
	    background-color: #d8dee9;
	    color: #000000;
	}
	#pulseaudio-slider slider {
	    min-height: 0px;
	    min-width: 0px;
	    opacity: 1;
	    background-color: transparent;
	    background-image: none;
	    box-shadow: none;
 	    border: 0px solid #555555;
	}
	#pulseaudio-slider trough {
	    min-height: 10px;
	    min-width: 80px;
	    border-radius: 5px;
	    background-color: #000000;
	}
	#pulseaudio-slider highlight {
	    min-width: 0px;
	    border-radius: 5px;
	    background-color: #d8dee9;
	}
	#language {
            font-size: 23px;
	}
      '';
      # Configuring Waybar
      settings = [{
        "layer" = "top";
        "position" = "top";
	"height" = 26;
	"margin-top" = 8;
	"margin-left" = 15;
	"margin-right" = 15;
	"spacing" = 7;
        modules-left = [
          "clock"
	  "memory"
	  "disk"
	  "pulseaudio"
	  "pulseaudio/slider"
	  "hyprland/language"
        ];
        modules-center = [
        ];
        modules-right = [
	  "hyprland/workspaces"
          "tray"
        ];
	"tray" = {
	  "icon-size" = 16;
	  "spacing" = 10;
	};
	"clock" = {
	  "format" = "{:%I:%M %p 󰸗  %b %d}";
          "tooltip" = true;
          "tooltip-format"= "<tt>{calendar}</tt>";
	};
	"pulseaudio" = {
          "scroll-step" = 1;
          "format" = "<span color='#ff7eb6' >{icon}</span> {volume}% {format_source}";
          "format-bluetooth" = "<span color='#ff7eb6' >{icon}󰂯</span> {volume}% {format_source}";
          "format-bluetooth-muted" = "<span color='#ff7eb6' >󰖁</span> {format_source}";
          "format-muted" = "<span color='#ff7eb6' >󰖁</span> {format_source}";
          "format-source" = "<span color='#be95ff' ></span> {volume}%";
          "format-source-muted" = "<span color='#be95ff' ></span>";
          "format-icons" = {
              "headphone" = "󰋋";
              "hands-free" = "";
              "headset" = "";
              "phone" = "";
              "default" = [ "" "" "" ];
          };
          "on-click" = "pavucontrol";
	  "on-click-right" = "amixer -q sset Master toggle";
	};
	"pulseaudio/slider" = {
    	  "min" = 0;
    	  "max" = 100;
    	  "orientation" = "horizontal";
	};
        "memory" = {
          "interval" = 1;
          "format" = "<span color='#42be65' >󰐿</span> {percentage}%";
          "states" = {
          "warning" = 85;
          };
        };
	"disk" = {
	  "format" = "<span color='#33b1ff' >󰋊</span> {used}";
	};
	"hyprland/workspaces" = {
	  "all-outputs" = true;
	  "on-click" = "activate";
	  "format" = "{icon}";
    	  "on-scroll-up" = "hyprctl dispatch workspace e+1";
    	  "on-scroll-down" = "hyprctl dispatch workspace e-1";
	  "format-icons" = {
	    "default" = "";
	    "active" = "";
	    "urgent" = "";
	  };
	};
	"hyprland/language" = {
	  "format-en" = "<span color='#82cfff' >e</span>";
	  "format-gr" = "<span color='#82cfff' >ε</span>";
	};
      }];
    };

    gtk = {
      enable = true;
      cursorTheme.package = pkgs.bibata-cursors;
      cursorTheme.name = "Bibata-Modern-Classic";
      cursorTheme.size = 21;
      iconTheme.package = pkgs.morewaita-icon-theme;
      iconTheme.name = "MoreWaita";
      gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    };

#    xsession.windowManager.i3 = {
#      enable = false;
#      package = pkgs.i3-gaps;
#      config = rec {
#        modifier = "Mod4";
#        window.border = 0;
#        gaps = {
#          inner = 0;
#          outer = 0;
#        };
#        keybindings = {
#          "XF86AudioLowerVolume" = "exec kitty -e alsamixer";
#          "XF86AudioRaiseVolume" = "exec kitty -e alsamixer";
#          "${modifier}+Return" = "exec kitty";
#          "${modifier}+w" = "exec google-chrome-stable";
#          "${modifier}+z" = "kill";
#          "${modifier}+q" = "exec --no-startup-id dmenu_run";
#          "${modifier}+f" = "fullscreen";
#          "${modifier}+m" = "exit i3";
#          "${modifier}+s" = "exec escrotum -C && notify-send screenie!";
#          "${modifier}+k" = "exec killall vinegar";
#
#          "${modifier}+1" = "workspace 1";
#          "${modifier}+2" = "workspace 2";
#          "${modifier}+3" = "workspace 3";
#          "${modifier}+4" = "workspace 4";
#          "${modifier}+5" = "workspace 5";
#          "${modifier}+6" = "workspace 6";
#          "${modifier}+7" = "workspace 7";
#          "${modifier}+8" = "workspace 8";
#          "${modifier}+9" = "workspace 9";
#          "${modifier}+0" = "workspace 10";
#          "${modifier}+Shift+1" = "move container to workspace 1";
#          "${modifier}+Shift+2" = "move container to workspace 2";
#          "${modifier}+Shift+3" = "move container to workspace 3";
#          "${modifier}+Shift+4" = "move container to workspace 4";
#          "${modifier}+Shift+5" = "move container to workspace 5";
#          "${modifier}+Shift+6" = "move container to workspace 6";
#          "${modifier}+Shift+7" = "move container to workspace 7";
#          "${modifier}+Shift+8" = "move container to workspace 8";
#          "${modifier}+Shift+9" = "move container to workspace 9";
#          "${modifier}+Shift+0" = "move container to workspace 10";
#        };
#	startup = [
#          {
#            command = "xinit set-prop 10 296 -0.4";
#            always = true;
#            notification = false;
#          }
#        ];
#      };
#    };

    home.stateVersion = "23.11";
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
