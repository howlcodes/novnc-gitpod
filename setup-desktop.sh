#!/bin/bash
set -e

# Install desktop + VNC + noVNC if not already
sudo apt-get update
sudo apt-get install -y xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify

# Configure VNC xstartup
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup <<'EOF'
#!/bin/sh
xrdb $HOME/.Xresources
xsetroot -solid grey
export XDG_SESSION_TYPE=x11
export DISPLAY=:1
startxfce4 &
EOF
chmod +x ~/.vnc/xstartup

# Kill leftovers
vncserver -kill :1 || true
pkill Xtigervnc || true
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# Start VNC
vncserver :1 -geometry 1920x1080 -SecurityTypes None

# Start noVNC proxy
websockify --web=/usr/share/novnc/ 6901 localhost:5901
