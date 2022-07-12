#!/bin/bash

# clean $HOME/.vnc if RESET_VNC=true
[[ -v RESET_VNC ]] && [[ $RESET_VNC == "true" ]] && rm -r $HOME/.vnc/ 2> /dev/null

# setup correct xstartup for xfce4 environment in vnc
if [[ ! -f $HOME/.vnc/xstartup ]]; then
    mkdir -p $HOME/.vnc
    cat > $HOME/.vnc/xstartup << EOL
#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &
EOL
    chmod +x $HOME/.vnc/xstartup
fi

# set vnc password
if [[ ! -v VNC_PASSWORD ]]; then
    echo "VNC_PASSWORD is not set!"
else
    mkdir -p $HOME/.vnc
    # newer vncpasswd
    #echo "$VNC_PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd
    printf "$VNC_PASSWORD\n$VNC_PASSWORD\n\n" | vncpasswd 2> /dev/null > /dev/null

    ## older vncpasswd
    #printf "$VNC_PASSWORD\n$VNC_PASSWORD\n\n" | vncpasswd > /dev/null
    #chmod 600 $HOME/.vnc/passwd

    echo "VNC password set by ENV variable VNC_PASSWORD: $VNC_PASSWORD"
fi

# newer vncserver
vncserver $DISPLAY -localhost no -geometry $GEOMETRY -depth $DEPTH

# older vncserver
#vncserver $DISPLAY -geometry $GEOMETRY -depth $DEPTH

# persist session with shell
bash
