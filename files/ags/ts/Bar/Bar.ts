// at the right of the bar, all the info should be inside of a single button, that when pressed gives you a single big popup with all sliders, info etc in it like gnome?

import { getMonitorIndexFromName } from "ts/utils";
import { Brightness } from "./widgets/Brightness";
import { Clock } from "./widgets/Clock";
import { Media } from "./widgets/Media";
import { Microphone } from "./widgets/Microphone";
import { Notification } from "./widgets/Notification";
import { SystemTray } from "./widgets/SystemTray";
import { Usage } from "./widgets/Usage";
import { Volume } from "./widgets/Volume";
import { Workspaces } from "./widgets/Workspaces";

// TODO: missing:
// record.sh
// vpn.sh
// mic (mic.sh? or builtin audio service? would somehow have to handle hotkeys)
// xremap.sh for laptop

// TODO: rewrite brightness.sh in here, Utils can read and write files to retain state.

// TODO: cant be bothered with it starting a new wnpcli on every reload.
// const track = Variable("No media found");

// TODO: cpu/ram (maybe gpu) usage

// TODO: network service, make wifi thingie (or just use nm-applet ig)
// TODO: network service also has VPNconnection?

import Gio from "gi://Gio";
import { Launcher } from "./widgets/Launcher";

const settings = new Gio.Settings({
  schema: "org.gnome.desktop.interface",
});

function Test() {
  return Widget.Button({
    onPrimaryClick: () => {
      settings.set_string("color-scheme", "prefer-light");
    },
    label: "test",
  });
}

export function Bar(output: string, large = false) {
  return Widget.Window({
    monitor: getMonitorIndexFromName(output),
    name: `bar-${output}`,
    className: large ? "bar-large" : "bar",
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
      start_widget: Widget.Box({
        spacing: 8,
        children: [Launcher(), Workspaces(), Usage() /* , Test() */],
      }),
      center_widget: Widget.Box({
        spacing: 8,
        children: [Media() /* Notification() */],
      }),
      end_widget: Widget.Box({
        hpack: "end",
        spacing: 8,
        children: [Brightness(output), Microphone(), Volume(), Clock(), SystemTray()],
      }),
    }),
  });
}
