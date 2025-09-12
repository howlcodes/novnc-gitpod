#!/usr/bin/env bash
set -e

echo "==== Setting up XFCE desktop with VNC and Chrome ===="

# Make installs non-interactive
export DEBIAN_FRONTEND=noninteractive

# ✅ Preconfigure keyboard to US (no more prompts!)
sudo debconf-set-selections <<< 'keyboard-configuration  keyboard-configuration/layoutcode  select  us'
sudo debconf-set-selections <<< 'keyboard-configuration  keyboard-configuration/modelcode   select  pc105'
sudo debconf-set-selections <<< 'keyboard-configuration  keyboard-configuration/variant     select  '

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install desktop + VNC + extras
sudo apt-get install -y xfce4 xfce4-goodies \
    tigervnc-standalone-server tigervnc-common \
    x11-xserver-utils dbus-x11 xauth

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo apt-get install -y /tmp/chrome.deb || sudo apt-get -f install -y

# Add Chrome to Applications menu
cat <<EOF | sudo tee /usr/share/applications/google-chrome.desktop
[Desktop Entry]
Version=1.0
Name=Google Chrome
Exec=/usr/bin/google-chrome-stable %U
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=google-chrome
Categories=Network;WebBrowser;
StartupNotify=true
EOF

# Create VNC xstartup config
mkdir -p ~/.vnc
cat <<EOF > ~/.vnc/xstartup
#!/bin/sh
xrdb \$HOME/.Xresources
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

# Start VNC server (1920x1080 resolution, no password)
vncserver -kill :1 || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 || true
vncserver :1 -geometry 1920x1080 -SecurityTypes None

echo "==== Setup complete! Connect via noVNC at port 6080 or 6901 ===="
