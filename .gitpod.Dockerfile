FROM gitpod/workspace-full:latest

# Install desktop environment + TigerVNC + noVNC + Chrome
RUN sudo apt-get update && sudo apt-get install -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server tigervnc-common \
    novnc websockify \
    wget gnupg2 apt-transport-https software-properties-common \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' && \
    sudo apt-get update && sudo apt-get install -y google-chrome-stable && \
    sudo rm -rf /var/lib/apt/lists/*

# Copy xstartup to fix "cleanly exited too early" bug
RUN echo '#!/bin/bash\n' \
         'xrdb $HOME/.Xresources\n' \
         'startxfce4 &' \
         > /home/gitpod/.vnc/xstartup && \
    chmod +x /home/gitpod/.vnc/xstartup
