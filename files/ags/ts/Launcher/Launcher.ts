const { query } = await Service.import("applications");
import Gio from "gi://Gio";
import GLib from "gi://GLib";
import { globalState } from "ts/main";
import { Application } from "types/service/applications";
const WINDOW_NAME = "launcher";

function AppItem(app: Application) {
  return Widget.Button({
    on_clicked: () => {
      App.closeWindow(WINDOW_NAME);
      app.launch();
    },
    attribute: { app },
    child: Widget.Box({
      children: [
        Widget.Icon({
          icon: app.icon_name || "",
          size: 42,
        }),
        Widget.Label({
          class_name: "title",
          label: app.name,
          xalign: 0,
          vpack: "center",
          truncate: "end",
        }),
      ],
    }),
  });
}

function _Launcher({ width = 500, height = 500, spacing = 12 }) {
  let applications = query("").map(AppItem);
  let eval_result = Variable("");

  const list = Widget.Box({
    vertical: true,
    children: applications,
    spacing,
  });

  function repopulate() {
    applications = query("").map(AppItem);
    list.children = applications;
  }

  const entry = Widget.Entry({
    hexpand: true,
    css: `margin-bottom: ${spacing}px;`,
    on_accept: ({ text }) => {
      if (eval_result.getValue().length > 0) {
        Utils.execAsync(`wl-copy ${eval_result.getValue()}`);
        App.closeWindow(WINDOW_NAME);
      } else {
        const results = applications.filter((item) => item.visible);
        if (results[0]) {
          App.closeWindow(WINDOW_NAME);
          results[0].attribute.app.launch();
        }
      }
    },
    on_change: ({ text }) => {
      try {
        const res = eval(text ?? "");
        if (typeof res == "number") {
          eval_result.setValue(String(res));
        } else {
          eval_result.setValue("");
        }
      } catch (e) {}
      applications.forEach((item) => {
        item.visible = item.attribute.app.match(text ?? "");
      });
    },
  });

  return Widget.Box({
    vertical: true,
    css: `margin: ${spacing * 2}px;` + `min-width: ${width}px;`,
    children: [
      entry,
      Widget.Scrollable({
        hscroll: "never",
        css: `min-width: ${width}px;` + `min-height: ${height}px;`,
        child: list,
        visible: eval_result.bind().as((e) => e.length == 0),
      }),
      Widget.Label({
        label: eval_result.bind(),
        visible: eval_result.bind().as((e) => e.length != 0),
      }),
    ],
    setup: (self) => {
      self.hook(App, (_, windowName, visible) => {
        if (windowName !== WINDOW_NAME) {
          return;
        }

        // TODO: actually STEAL focus from games
        // but its a LAYER, ugh.

        if (visible) {
          repopulate();
          eval_result.setValue("");
          entry.text = "";
          entry.grab_focus();
        }
      });
    },
  });
}

export function Launcher() {
  return Widget.Window({
    name: WINDOW_NAME,
    setup: (self) => {
      self.keybind("Escape", () => {
        App.closeWindow(WINDOW_NAME);
      });

      globalState.onEvent("launcher-toggle", () => {
        App.toggleWindow(WINDOW_NAME);
      });
    },
    visible: false,
    keymode: "exclusive",
    layer: "overlay",
    child: _Launcher({
      width: 500,
      height: 500,
      spacing: 12,
    }),
  });
}
