# Use Gitpod’s Ubuntu base image
FROM gitpod/workspace-full:latest

USER root

# Make installs non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# ✅ Preconfigure keyboard so no prompts
RUN apt-get update && \
    echo "keyboard-configuration keyboard-configuration/layoutcode string us" | debconf-set-selections && \
    echo "keyboard-configuration keyboard-configuration/modelcode string pc105" | debconf-set-selections && \
    echo "keyboard-configuration keyboard-configuration/variant select " | debconf-set-selections && \
    apt-get install -y \
        xfce4 xfce4-goodies \
        tigervnc-standalone-server tigervnc-common \
        novnc websockify \
        x11-xserver-utils dbus-x11 xauth \
        flatpak gnome-software-plugin-flatpak && \
    rm -rf /var/lib/apt/lists/*

# ✅ Install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb && \
    apt-get install -y /tmp/chrome.deb || apt-get -f install -y && \
    rm /tmp/chrome.deb

# ✅ Add Chrome to Applications menu
RUN cat <<EOF > /usr/share/applications/google-chrome.desktop
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

# ✅ Enable Flathub
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ✅ Setup VNC startup
RUN mkdir -p /home/gitpod/.vnc && \
    echo '#!/bin/sh\nxrdb $HOME/.Xresources\nstartxfce4 &' > /home/gitpod/.vnc/xstartup && \
    chmod +x /home/gitpod/.vnc/xstartup && \
    chown -R gitpod:gitpod /home/gitpod/.vnc

# Ports: 5901 = VNC, 6080 = noVNC
EXPOSE 5901 6080

USER gitpod

# ✅ Start script
CMD vncserver -kill :1 || true && \
    rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 || true && \
    vncserver :1 -geometry 1920x1080 -SecurityTypes None && \
    websockify --web=/usr/share/novnc/ 6080 localhost:5901
