#!/bin/bash

# Install Roboto Mono Fonts from Google Fonts Repo
git clone git@github.com:googlefonts/RobotoMono.git ~/

mkdir -p ~/.local/share/fonts && cp ~/RobotoMono/fonts/ttf/*.ttf ~/.local/share/fonts

# Install Open Sans Fonts from Google Fonts Repo
git clone git@github.com:googlefonts/opensans.git ~/

cp ~/opensans/fonts/ttf/*.ttf ~/.local/share/fonts

# Refresh Fonts cache
if sudo fc-cache -f -v | tail -n 3 | grep -q "fc-cache: succeeded"; then
    echo "Fonts were installed and Fonts cache was refreshed."
    exit 0
else
    echo "Fonts were not installed properly"
    exit 1
fi
