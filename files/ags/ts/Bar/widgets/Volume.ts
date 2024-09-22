import { globalState } from "ts/main";
const audio = await Service.import("audio");

export function Volume() {
  function toggleSpeaker() {
    audio.speaker.is_muted = !audio.speaker.is_muted;
  }

  globalState.onEvent("speaker-toggle", (data) => {
    toggleSpeaker();
  });

  const icons = {
    101: "overamplified",
    67: "high",
    34: "medium",
    1: "low",
    0: "muted",
  };

  function getIcon() {
    const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find((threshold) => threshold <= audio.speaker.volume * 100);

    return `audio-volume-${icons[icon as any]}-symbolic`;
  }

  const icon = Widget.Icon({
    icon: Utils.watch(getIcon(), audio.speaker, getIcon),
  });

  const text = Widget.Label({
    marginRight: 8,
    setup: (self) =>
      self.hook(audio.speaker, () => {
        self.label = `${Math.round(audio.speaker.volume * 100)}%`;
      }),
  });

  return Widget.Button({
    class_name: "volume",
    child: Widget.Box({ children: [text, icon] }),
    onScrollUp: () => (audio.speaker.volume += 0.05),
    onScrollDown: () => (audio.speaker.volume -= 0.05),
    onPrimaryClickRelease: toggleSpeaker,
  });
}
