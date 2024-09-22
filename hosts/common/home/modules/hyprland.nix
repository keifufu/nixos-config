{ config, lib, pkgs, host, vars, inputs, ... }:

let
  monitors = with host;
    if hostName == "desktop" then ''
      monitor = HDMI-A-1, 1920x1080@144, 0x0, 1
      monitor = DP-1, 2560x1440@165, 1920x0, 1
      monitor = DP-3, 1920x1080@60, 4480x0, 1
    '' else if hostName == "laptop" then ''
      monitor = eDP-1, 1920x1080@144, 0x0, 1
    '' else "";
  workspaces = with host;
    if hostName == "desktop" then ''
      workspace = 1, monitor:DP-1, default:true
      workspace = 2, monitor:DP-1, default:false
      workspace = 3, monitor:DP-1, default:false
      workspace = 4, monitor:HDMI-A-1, default:true
      workspace = 5, monitor:HDMI-A-1, default:false
      workspace = 6, monitor:HDMI-A-1, default:false
      workspace = 7, monitor:DP-3, default:true
      workspace = 8, monitor:DP-3, default:false
      workspace = 9, monitor:DP-3, default:false
    '' else if hostName == "laptop" then ''
      workspace = 1, monitor:eDP-1, default:true
      workspace = 2, monitor:eDP-1, default:false
      workspace = 3, monitor:eDP-1, default:false
    '' else "";
  execonce = with host;
    if hostName == "desktop" then ''
      exec-once = openrgb.sh
    '' else if hostName == "laptop" then ''
      exec-once = nm-applet
    '' else "";
  sensitivity = with host;
    if hostName == "desktop" then "0.5"
    else "0.25";
in
let
  hyprlandConf = with host; ''
    ${monitors}
    monitor = Unknown-1, disabled
    monitor = , highres, auto, auto

    ${workspaces}

    input {
      kb_layout = de
      kb_variant = nodeadkeys
      kb_model = pc105
      kb_options = 
      kb_rules = 
      sensitivity = ${sensitivity}
      accel_profile = flat
      follow_mouse = 1
      touchpad {
        natural_scroll = true
        middle_button_emulation = true
        tap-to-click = true
      }
    }

    gestures {
      workspace_swipe = true
    }

    general {
      gaps_in = 5
      gaps_out = 10
      border_size = 3
      col.active_border = rgba(c6a0f6ff)
      col.inactive_border = rgba(595959aa)
      layout = dwindle
    }

    cursor {
      no_warps = false
      zoom_factor = 1
      zoom_rigid = false
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      enable_swallow = true
      swallow_regex = ^(kitty)$
      middle_click_paste = false
    }

    decoration {
      rounding = 8

      active_opacity = 1
      inactive_opacity = 1
      
      blur {
        enabled = true
        size = 6
        passes = 3
        new_optimizations = true
        xray = true
        ignore_opacity = true
      }

      drop_shadow = false
      shadow_ignore_window = true
      shadow_offset = 1 2
      shadow_range = 10
      shadow_render_power = 5
      col.shadow = 0x66404040
    }

    animations {
      enabled = yes

      bezier = wind, 0.05, 0.9, 0.1, 1.05
      bezier = winIn, 0.1, 1.1, 0.1, 1.1
      bezier = winOut, 0.3, -0.3, 0, 1.
      bezier = linear, 1, 1, 1, 1

      animation = windows, 1, 6, wind, slide
      animation = windowsIn, 1, 6, winIn, slide
      animation = windowsOut, 1, 5, winOut, slide
      animation = windowsMove, 1, 5, wind, slide
      animation = border, 1, 1, linear
      animation = borderangle, 1, 30, linear, loop
      animation = fade, 1, 10, default
      animation = workspaces, 1, 3, wind, slidefadevert
    }

    dwindle {
      no_gaps_when_only = false
      pseudotile = true
      preserve_split = true
    }

    #-- VARIABLES --#

    $scriptsDir = ${vars.location}/files/scripts

    #-- STARTUP --#

    env = HYPRCURSOR_SIZE,${toString config.home.pointerCursor.size}
    env = HYPRCURSOR_THEME,Bibata-Modern-Classic-Hyprcursor

    exec-once = hyprctl setcursor Bibata-Modern-Classic-Hyprcursor ${toString config.home.pointerCursor.size}
    exec-once = ssh-add ${vars.secrets}/git-ssh-key
    exec-once = gpg --import ${vars.secrets}/git-gpg-key
    exec-once = [workspace 4 silent] firefox-developer-edition -P default
    exec-once = wl-paste --type text --watch cliphist store
    exec-once = wl-paste --type image --watch cliphist store
    exec-once = cliphist wipe
    # exec-once = vpn.sh connect
    exec-once = start-ntfy.sh
    ${execonce}

    #-- KEYBINDS --#

    binds {
      scroll_event_delay = 0
    }

    # submap
    submap = reset

    # Audio Control
    bind = , XF86AudioPlay, exec, wnpcli play-pause
    bind = , XF86AudioPrev, exec, wnpcli skip-previous
    bind = , XF86AudioNext, exec, wnpcli skip-next
    bind = , XF86AudioRaiseVolume, exec, wnpcli set-volume 2+
    bind = , XF86AudioLowerVolume, exec, wnpcli set-volume 2-
    bind = , XF86AudioMute, exec, mpscd produce ags speaker-toggle
    bind = SUPER, M, exec, mpscd produce ags mic-toggle
    bind = ALT, M, exec, toggle-mute-active-window.sh

    # Screenshot & Recording
    bind = , Print, exec, screenshot.sh
    bind = SHIFT, Print, exec, screenshot.sh --satty
    bind = CTRL, Print, exec, record.sh
    bind = CTRL_SHIFT, Print, exec, record.sh --audio

    # Misc
    bind = SUPER, W, exec, hyprpaper-picker.sh
    bind = CTRL_SHIFT, R, exec, type-randomchars.sh
    bind = CTRL_SHIFT, SPACE, exec, mpscd produce ags launcher-toggle
    bind = CTRL_SHIFT, Escape, exec, kitty btop
    bind = SUPER, P, exec, hyprpicker.sh
    bind = SUPER, X, exec, kitty
    bind = SUPER, E, exec, kitty yazi
    bind = CTRL_SUPER, E, exec, kitty sudo YAZI_CONFIG_HOME=/home/${vars.user}/.config/yazi yazi
    bind = SUPER, H, exec, cliphist list | wofi --dmenu --normal-window | cliphist decode | wl-copy
    bind = SUPER_ALT, X, exec, xremap-mouse.sh toggle
    bind = SUPER_SHIFT, mouse_down, exec, hyprland-zoom.sh +.1
    bind = SUPER_SHIFT, mouse_up, exec, hyprland-zoom.sh -.1
    bind = SUPER_SHIFT, mouse:274, exec, hyprland-zoom.sh 1 # middle mouse button

    # Window Manager
    bind = SUPER, C, killactive,
    # bind = SUPER_SHIFT, Q, exit,
    bind = SUPER, F, fullscreen,
    bind = SUPER, V, togglefloating,
    bind = SUPER, P, pseudo, # dwindle
    bind = SUPER, S, togglesplit, # dwindle
    bind = SUPER, Tab, cyclenext,
    bind = SUPER, Tab, bringactivetotop,

    # Focus
    bind = SUPER, left, movefocus, l
    bind = SUPER, right, movefocus, r
    bind = SUPER, up, movefocus, u
    bind = SUPER, down, movefocus, d

    # Move
    bind = SUPER_SHIFT, left, movewindow, l
    bind = SUPER_SHIFT, right, movewindow, r
    bind = SUPER_SHIFT, up, movewindow, u
    bind = SUPER_SHIFT, down, movewindow, d

    # Resize
    bind = SUPER_CTRL, left, resizeactive, -20 0
    bind = SUPER_CTRL, right, resizeactive, 20 0
    bind = SUPER_CTRL, up, resizeactive, 0 -20
    bind = SUPER_CTRL, down, resizeactive, 0 20

    # Switch
    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5
    bind = SUPER, 6, workspace, 6
    bind = SUPER, 7, workspace, 7
    bind = SUPER, 8, workspace, 8
    bind = SUPER, 9, workspace, 9
    bind = SUPER, 0, workspace, 10

    # Move
    bind = SUPER SHIFT, 1, movetoworkspace, 1
    bind = SUPER SHIFT, 2, movetoworkspace, 2
    bind = SUPER SHIFT, 3, movetoworkspace, 3
    bind = SUPER SHIFT, 4, movetoworkspace, 4
    bind = SUPER SHIFT, 5, movetoworkspace, 5
    bind = SUPER SHIFT, 6, movetoworkspace, 6
    bind = SUPER SHIFT, 7, movetoworkspace, 7
    bind = SUPER SHIFT, 8, movetoworkspace, 8
    bind = SUPER SHIFT, 9, movetoworkspace, 9
    bind = SUPER SHIFT, 0, movetoworkspace, 10

    # Mouse
    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow

    # reset submap
    submap = none
    bind = SUPER, escape, submap, reset

    #--WINDOW RULES --#

    # render ffxiv in background, fps is determined by misc:render_unfocused_fps which defaults to 15, same as ffxiv's default unfocused fps
    windowrulev2 = renderunfocused,class:^(ffxiv_dx11.exe)$

    # Opacity
    # windowrulev2 = opacity 0.9 0.9,class:^(firefox)$
    # windowrulev2 = opacity 0.9 0.9,class:^(brave)$
    # windowrulev2 = opacity 0.9 0.9,class:^(.*code.*)$
    windowrulev2 = opacity 0.8 0.8,class:^(kitty)$
    # windowrulev2 = opacity 0.8 0.8,class:^(Steam)$
    # windowrulev2 = opacity 0.8 0.8,class:^(steam)$
    # windowrulev2 = opacity 0.8 0.8,class:^(steamwebhelper)$
    # windowrulev2 = opacity 0.8 0.7,class:^(pavucontrol)$

    # polkit
    windowrulev2 = float,class:^(polkit-gnome-authentication-agent-1)$
    windowrulev2 = opacity 0.8 0.7,class:^(polkit-gnome-authentication-agent-1)$
    windowrulev2 = stayfocused,class:^(polkit-gnome-authentication-agent-1)$
    windowrulev2 = dimaround,class:^(polkit-gnome-authentication-agent-1)$

    # Float
    windowrulev2 = float,class:^(pavucontrol)$
    windowrulev2 = float,class:^(swappy)$
    windowrulev2 = float,title:^(Media viewer)$
    windowrulev2 = float,title:^(Volume Control)$
    windowrulev2 = dimaround,title:^(Volume Control)$
    windowrulev2 = float,title:^(Picture-in-Picture)$
    windowrulev2 = float,title:^(DevTools)$
    windowrulev2 = float,class:^(file_progress)$
    windowrulev2 = float,class:^(confirm)$
    windowrulev2 = float,class:^(dialog)$
    windowrulev2 = float,class:^(download)$
    windowrulev2 = float,class:^(notification)$
    windowrulev2 = float,class:^(error)$
    windowrulev2 = float,class:^(confirmreset)$
    windowrulev2 = float,title:^(Open File)$
    windowrulev2 = float,title:^(branchdialog)$
    windowrulev2 = float,title:^(Confirm to replace files)$
    windowrulev2 = float,title:^(File Operation Progress)$

    # Fuck "Sharing Indicator" window
    windowrulev2 = float,title:^(.*Sharing Indicator.*)$
    windowrulev2 = opacity 0,title:^(.*Sharing Indicator.*)$
    windowrulev2 = noblur,title:^(.*Sharing Indicator.*)$
    windowrulev2 = nofocus,title:^(.*Sharing Indicator.*)$
    windowrulev2 = noanim,title:^(.*Sharing Indicator.*)$
    windowrulev2 = noinitialfocus,title:^(.*Sharing Indicator.*)$

    windowrulev2 = stayfocused,class:^(swappy)$
    windowrulev2 = float,class:^(swappy)$
    windowrulev2 = center,class:^(swappy)$

    # Wofi
    windowrulev2 = stayfocused,class:^(wofi)$
    windowrulev2 = size 40%,class:^(wofi)$
    windowrulev2 = float,class:^(wofi)$
    windowrulev2 = center,class:^(wofi)$

    # windowrulev2 = move 50% 44%title:^(Volume Control)$

    # Workspace
    # windowrulev2 = workspace, 2, class:^(firefox)$

    # Size
    windowrulev2 = size 800 600,class:^(download)$
    windowrulev2 = size 800 600,class:^(Open File)$
    windowrulev2 = size 800 600,class:^(Save File)$
    windowrulev2 = size 800 600,class:^(Volume Control)$

    windowrulev2 = idleinhibit focus,class:^(mpv)$
    windowrulev2 = idleinhibit fullscreen,class:^(firefox)$
    windowrulev2 = idleinhibit fullscreen,class:^(brave)$
    windowrulev2 = idleinhibit fullscreen,class:^(.*Minecraft.*)$

    # xwaylandvideobridge
    windowrulev2 = float,class:^(xwaylandvideobridge)$
    windowrulev2 = opacity 0,class:^(xwaylandvideobridge)$
    windowrulev2 = noblur,class:^(xwaylandvideobridge)$
    windowrulev2 = nofocus,class:^(xwaylandvideobridge)$
    windowrulev2 = noanim,class:^(xwaylandvideobridge)$
    windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$

    layerrule = noanim, ^(gtk-layer-shell)$
    layerrule = noanim, ^(hyprpicker)$

    # explorer.exe (wine)
    # windowrulev2 = float,class:^(.*explorer.exe.*)$
    # windowrulev2 = opacity 0,class:^(.*explorer.exe.*)$
    # windowrulev2 = noblur,class:^(.*explorer.exe.*)$
    # windowrulev2 = nofocus,class:^(.*explorer.exe.*)$
  '';
  cursor = "Bibata-Modern-Classic-Hyprcursor";
  cursorPackage = pkgs.callPackage ../../../../pkgs/bibata-hyprcursor {};
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
      extraCommands = [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };
    extraConfig = hyprlandConf;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
    ];
    config.common.default = [ "hyprland" ];
    config.hyprland.default = [ "gtk" "hyprland" ];
    xdgOpenUsePortal = true;
  };
  
  home.packages = with pkgs; [
    # zoom
    bc
    # screenshot
    grim
    slurp
    swappy
    satty
  ];

  services.hyprpaper = {
    enable = true;
    package = inputs.hyprpaper.packages.${pkgs.system}.hyprpaper;
    settings = {
      splash = false;
      preload = [
        "/home/${vars.user}/wall.png"
      ];
      wallpaper = [
        ",/home/${vars.user}/wall.png"
      ];
    };
  };

  home.file.".config/hypr/xdph.conf".text = ''
    screencopy {
      max_fps = 60
      allow_token_by_default = true
    }
  '';

  xdg.dataFile."icons/${cursor}".source = "${cursorPackage}/share/icons/${cursor}";
}
