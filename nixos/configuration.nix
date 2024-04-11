{ config, pkgs, ... }:
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

  networking.hostName = "nixos"; # Define your hostname.
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

  # Enable systemd services
  systemd = {
    network.enable = true;
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services = {
    xserver = {
      enable = true;
      layout = "us";
      displayManager.xpra.pulseaudio = true;
      videoDrivers = [ "nvidia" ];
      windowManager.i3 = {
	enable = true;
	extraPackages = with pkgs; [
	  dmenu
	  i3status
	  i3blocks
	];
      };
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      displayManager.startx.enable = true;
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
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = false;
    alsa.support32Bit = false;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.bash;
  users.users.bill = {
    isNormalUser = true;
    description = "bill";
    extraGroups = [ "networkmanager" "wheel" ];
    useDefaultShell = true;
    packages = with pkgs; [
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "bill";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # List fonts installed in system profile
  fonts.packages = with pkgs; [
    nerdfonts
    roboto
    fantasque-sans-mono
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
  # apps
    armcord
    libqalculate
    docker
    gnome.polari
    wget
    lunar-client
    git
    hyprshot
    vim
    google-chrome
    firefox
    pavucontrol
    pamixer
    xdg-desktop-portal-hyprland
    waybar
    swaybg
    grim
    slurp
    satty
    libnotify
    flatpak
    btop
    wl-clipboard
    fzf
    eza
    steam
    qpwgraph
    webcord
    gnome.gnome-session
    xorg.xinit
    xorg.xauth
    r2modman
    neofetch
    xwaylandvideobridge
    mpv
    meslo-lgs-nf
    cava
    xarchiver
    starship
    blesh
    gnome.quadrapassel
    killall
    gimp
    fuzzel 
    wlogout
    pmutils
    molly-guard
    flatpak
    pulsemixer
    skypeforlinux
    wl-color-picker
    libjpeg
    minecraft
    loupe
    gnome.gnome-tweaks
    libadwaita
    bottles
    fragments
    celluloid
    graphs
    escrotum
    gradience
    wpsoffice 
    cliphist
    quickgui
    quickemu
    qemu
    virt-manager
  ];

  # Programs
  programs = {
    hyprland.enable = true;
    bash = {
      blesh.enable = true;
      shellAliases = {
        grep = "grep --color=auto";
	ls="eza -s size -a --icons=always --hyperlink";
        mv="mv -v";
	cp="cp -vr";
	rm="rm -vrf";
        v="vim";
	vhypr="vim ~/.config/hypr/hyprland.conf";
	vnix="sudo vim /etc/nixos/configuration.nix";
	vnixh="sudo vim /etc/nixos/hardware-configuration.nix";
	nixr="sudo nixos-rebuild switch";
	vflake="vim ~/flake.nix";
	rst="sudo alsactl restore && sudo alsactl store";
        #vhome="vim ~/.config/home-manager/home.nix";
        #homer="home-manager switch";
        hypr="Hyprland";
      };
    };

    starship = {
      enable = true;
      presets = [ "nerd-font-symbols" "pure-preset" ];
    };
  };


  # Home Manager
  home-manager.users.bill = { pkgs, ... }: {
    home.packages = [
    ]; # Color accent = #F5FFFF

    services = {
      mako = {
	enable = true;
	font = "JetBrainsMono";
	width = 400;
	height = 80;
	margin = "15";
	padding = "15";
	borderSize = 1;
	borderRadius = 15;
	maxIconSize = 48;
	maxVisible = 10;
	layer = "overlay";
	anchor = "top-right";
	
	backgroundColor = "#000000";
	textColor = "#f5ffff";
	borderColor = "#555555";
        defaultTimeout = 4000;
	progressColor = "over #433E4A";	
      };
    };

    programs.fuzzel = {
      enable = true;
      settings = {
	colors.background = "#000000ff";
	colors.text = "#f5ffffff";
	colors.selection-text = "#000000ff";
	colors.selection-match = "#f5ffffff";
	colors.match = "#f5ffffff";
	colors.selection = "#f5ffffff";
	colors.border = "#555555ff";
	border.radius = 10;
	border.width = 2;
        main.width = 60;
	main.font = "monospace:size=18";
	main.prompt = "❯ ";
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
        foreground              #F5FFFF
        background              #000000
        selection_foreground    #D9E0EE
        selection_background    #262626
        
        cursor                  #F5FFFF
        cursor_text_color       #000000
        
        #: black
        color0 #262626
        color8 #262626
        #: red
        color1 #E97193
        color9 #E97193
        #: green
        color2  #AAC5A0
        color10 #AAC5A0
        #: yellow
        color3  #ECE0A8
        color11 #ECE0A8
        #: blue
        color4  #78afe3
        color12 #78afe3
        #: magenta
        color5  #DFA7E7
        color13 #DFA7E7
        #: cyan
        color6  #A8E5E6
        color14 #A8E5E6
        #: white
        color7  #F5FFFF
        color15 #F5FFFF
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
	    border-radius: 10px;
	}
	window#waybar {
	    background-color: rgba(43, 48, 59, 0.0);
	    border-bottom: 0px solid rgba(100, 114, 125, 0.0);
	    color: #F5FFFF;
	    transition-property: background-color;
	    transition-duration: .5s;
	}
	window#waybar.hidden {
	    opacity: 0.2;
	}
	button {
	    box-shadow: inset 0 -3px transparent;
	    border: #F5FFFF;
	    border-radius: 4px;
	}
	button:hover {
	    background: inherit;
	    box-shadow: inset 0 -3px transparent;
	}
	#workspaces button {
	    padding: 0 5px;
	    background-color: transparent;
	    color: #F5FFFF;
	}
	#workspaces button:hover {
	    background: rgba(0, 0, 0, 0.2);
	}
	#workspaces button.focused {
	    background-color: #64727D;
	    box-shadow: inset 0 -3px #F5FFFF;
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
	#mpd {
	    padding: 0 10px;
	    color: #F5FFFF;
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
	    background-color: #F5FFFF;
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
	    background-color: #F5FFFF;
	}
	#language {
	    font-weight: bold;
	}
      '';
      # Configuring Waybar
      settings = [{
        "layer" = "top";
        "position" = "top";
	"height" = 24;
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
	  "format" = "{:%I:%M 󰸗  %p %b %d}";
          "tooltip" = true;
          "tooltip-format"= "<tt>{calendar}</tt>";
	};
	"pulseaudio" = {
          "scroll-step" = 1;
          "format" = "{volume}% {icon}  {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = "󰖁 {icon} {format_source}";
          "format-muted" = "󰖁 {format_source}";
          "format-source" = "{volume}%  ";
          "format-source-muted" = " ";
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
          "format" = "{percentage}% 󰐿 ";
          "states" = {
            "warning" = 85;
          };
        };
	"disk" = {
	  "format" = "{free} 󰋊 ";
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
	  "format-en" = "e";
	  "format-gr" = "ε";
	};
      }];
    };

    gtk = {
      enable = true;
      cursorTheme.package = pkgs.bibata-cursors;
      cursorTheme.name = "Bibata-Modern-Classic";
      cursorTheme.size = 16;
      iconTheme.package = pkgs.morewaita-icon-theme;
      iconTheme.name = "MoreWaita";
      gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    };

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = rec {
        modifier = "Mod4";
        window.border = 0;
        gaps = {
          inner = 0;
          outer = 0;
        };
        keybindings = {
          "XF86AudioLowerVolume" = "exec kitty -e alsamixer";
          "XF86AudioRaiseVolume" = "exec kitty -e alsamixer";
          "${modifier}+Return" = "exec kitty";
          "${modifier}+w" = "exec google-chrome-stable";
          "${modifier}+z" = "kill";
          "${modifier}+q" = "exec --no-startup-id dmenu_run";
          "${modifier}+f" = "fullscreen";
          "${modifier}+m" = "exit i3";
          "${modifier}+s" = "exec escrotum -C && notify-send screenie!";
          "${modifier}+k" = "exec killall vinegar";

          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";
          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";
        };
	startup = [
          {
            command = "xinit set-prop 10 296 -0.4";
            always = true;
            notification = false;
          }
        ];
      };
    };

    home.stateVersion = "23.11";
  };

  system.stateVersion = "23.11"; # Did you read the comment?
}
