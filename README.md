after nixos installation, do:
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nixos-rebuild switch --upgrade
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --update
```
then add `imports = [ <home-manager/nixos> ];` to `/etc/nixos/configuration.nix` and then do `sudo nixos-rebuild switch`
```
nix-shell -p git wl-clipboard vim
```
```
git clone https://github.com/Gxnum/dot-nix-amoled.git
```
```
cat ~/dot-nix-amoled/nixos/configuration.nix | wl-copy
```
```
mkdir ~/.config/hypr
cat ~/dot-nix-amoled/hypr/hyprland.conf | wl-copy
```
```
cat ~/dot-nix-amoled/hypr/clipboard.sh | wl-copy
```
after `sudo nixos-rebuild switch`
```
cat ~/dot-nix-amoled/chrome/userChrome.css | wl-copy
```
apply gtk theme
```
gradience-cli apply -p ~/dot-nix-amoled/gtktheme.json --gtk both
```
```
mv ~/dot-nix-amoled/Downloads/jord.jpg ~/Downloads
```

btw,
Downloads -> wallpapers

chrome -> firefox

hypr -> hyprland

nixos -> nixos

gtktheme.json -> gtk theme for gradience
