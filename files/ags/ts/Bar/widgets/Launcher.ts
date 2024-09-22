export function Launcher() {
  return Widget.Button({
    class_name: "microphone",
    child: Widget.Icon({ icon: "nix-snowflake" }),
    onPrimaryClickRelease: () => Utils.execAsync("launcher.sh"),
  });
}
