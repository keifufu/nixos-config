import { globalState } from "ts/main";
const audio = await Service.import("audio");

export function Microphone() {
  function toggleMic() {
    const muted = !audio.microphone.is_muted;
    audio.microphone.is_muted = muted;
    const sound_file = muted ? "$SNOWFLAKE_FILES/sound/mute.mp3" : "$SNOWFLAKE_FILES/sound/unmute.mp3";
    Utils.execAsync(["bash", "-c", `pw-play ${sound_file} --volume 0.5`]);
  }

  globalState.onEvent("mic-toggle", (data) => {
    toggleMic();
  });

  function getIcon() {
    return audio.microphone.is_muted ? "microphone-disabled-symbolic" : "audio-input-microphone-symbolic";
  }

  const icon = Widget.Icon({
    icon: Utils.watch(getIcon(), audio.microphone, getIcon),
  });

  return Widget.Button({
    class_name: "microphone",
    child: icon,
    onPrimaryClickRelease: toggleMic,
  });
}
