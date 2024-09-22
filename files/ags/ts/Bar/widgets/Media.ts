const track = Variable("", {
  listen: "wnpcli metadata -f '{{artist}} - {{title}}{{default:No media found}}' -F",
});

export function Media() {
  const label = Widget.Label({
    label: track.bind(),
  });

  return Widget.Button({
    class_name: "media",
    onMiddleClick: () => Utils.execAsync("wnpcli play-pause"),
    onPrimaryClick: () => Utils.execAsync("wnpcli skip-previous"),
    onSecondaryClick: () => Utils.execAsync("wnpcli skip-next"),
    onScrollUp: () => Utils.execAsync("wnpcli set-volume 2+"),
    onScrollDown: () => Utils.execAsync("wnpcli set-volume 2-"),
    child: label,
  });
}
