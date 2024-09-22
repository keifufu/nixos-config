import { VpnConnection } from "types/service/network";
import { Bar } from "./Bar/Bar";
import { createBrightnessState, getBrightnessFile } from "./Bar/widgets/Brightness";
import { Launcher } from "./Launcher/Launcher";

// TODO:
// - bar popout
// - launcher
// - wallpaper switcher
// - theme switcher
// - wlogout replacement, probably in bar?

type MpscdEvents = "mic-toggle" | "volume-up" | "volume-down" | "speaker-toggle" | "launcher-toggle";
type MpscdCallback = (data: string) => any;

type GlobalState = {
  onEvent: (event: MpscdEvents, callback: MpscdCallback) => any;
  brightness: ReturnType<typeof createBrightnessState>;
};

const callbacks: { event: MpscdEvents; callback: MpscdCallback }[] = [];
export const globalState: GlobalState = {
  onEvent: (event, callback) => callbacks.push({ event, callback }),
  brightness: createBrightnessState(),
};

const mpscd = Variable("", { listen: "mpscd consume ags" });
mpscd.connect("changed", ({ value }) => {
  const args = value.split(" ");
  if (args.length < 2) return;
  const event = args[1];
  const data = args.length > 2 ? args.splice(2, args.length).join(" ") : "";
  const cb = callbacks.find((e) => e.event === event);
  if (cb) {
    cb.callback(data);
  }
});

App.config({
  style: "./style.css",
  windows: [Bar("HDMI-A-1"), Bar("DP-1", true), Bar("DP-3"), Launcher()],
});
