import Gdk from "gi://Gdk?version=3.0";
const hyprland = await Service.import("hyprland");

export function getMonitorIndexFromName(name: string) {
  const display = Gdk.Display.get_default();
  const screen = display?.get_default_screen();
  const screenCount = display?.get_n_monitors() ?? 1;

  for (let i = 0; i < screenCount; ++i) {
    if (screen?.get_monitor_plug_name(i) === name) return i;
  }
  return 0;
}

export function old_getMonitorIndexFromName(name: string) {
  let x = -1;
  let y = -1;
  for (let m of hyprland.monitors)
    if (m.name == name) {
      x = m.x + m.width / 2;
      y = m.y + m.height / 2;
      break;
    }
  if (x == -1) return 0;
  let monitor = Gdk.Display.get_default()?.get_monitor_at_point(x, y);
  for (let i = 0; i < (Gdk.Display.get_default()?.get_n_monitors() ?? 0); i++) {
    const m = Gdk.Display.get_default()?.get_monitor(i);
    if (m === monitor) return i;
  }
  return 0;
}

export function debounce<T extends (...args: any[]) => any>(callback: T, waitMs: number) {
  let timeout: any;
  return (...args: Parameters<T>): ReturnType<T> => {
    let result: any;
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      result = callback(...args);
    }, waitMs);
    return result;
  };
}
