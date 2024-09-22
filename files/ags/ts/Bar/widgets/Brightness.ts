import { globalState } from "ts/main";
import { debounce } from "ts/utils";

export function createBrightnessState() {
  const ddcutilresult = Utils.exec("ddcutil detect");
  const displays: { output: string; i2c: number }[] = [];
  const displaySections = ddcutilresult.split(/Display \d/).slice(1);
  displaySections.forEach((section) => {
    const i2cMatch = section.match(/I2C bus:\s*\/dev\/i2c-(\d+)/);
    const drmMatch = section.match(/DRM connector:\s*card\d+-(\S+)/);
    if (i2cMatch && drmMatch) {
      displays.push({
        output: drmMatch[1],
        i2c: parseInt(i2cMatch[1]),
      });
    }
  });

  return {
    globalBrightness: Variable(parseInt(Utils.readFile(getBrightnessFile("global")) || "0")),
    displays,
  };
}

export function getBrightnessFile(output: string) {
  const cacheDir = Utils.CACHE_DIR + "/BarBrightness/";
  Utils.ensureDirectory(cacheDir);
  return cacheDir + output;
}

export function Brightness(output: string) {
  const globalLink = Variable(true);
  const increase = Variable(10);
  const brightness = Variable(parseInt(Utils.readFile(getBrightnessFile(output)) || "0"));
  const monitorBrightness = Variable(parseInt(Utils.readFile(getBrightnessFile(output + "-monitor")) || "0"));

  const save = debounce((output: string, brightness: number, monitorBrightness: number) => {
    Utils.writeFile(brightness.toString(), getBrightnessFile(output));
    Utils.writeFile(monitorBrightness.toString(), getBrightnessFile(output + "-monitor"));
  }, 1000);

  // const setMonitorBrightness = (device: string, brightness: number) => {
  //   Utils.execAsync(`brightnessctl set ${brightness}% -d ${device}`);
  // };

  const setMonitorBrightness = debounce((device: string, brightness: number) => {
    Utils.execAsync(`ddcutil setvcp 0x10 ${brightness} -b ${device.replace("ddcci", "")}`);
  }, 1000);

  _setBrightness(brightness.getValue(), true);

  globalState.brightness.globalBrightness.connect("changed", ({ value }) => {
    _setBrightness(value);
  });

  function toggleGlobalLink() {
    globalLink.setValue(!globalLink.getValue());
  }

  function getDevice() {
    if (output === "eDP-1") {
      return "amdgpu_bl1";
    } else {
      const display = globalState.brightness.displays.find((display) => display.output === output);
      return `ddcci${display?.i2c}`;
    }
  }

  function setBrightness(newBrightness_: number) {
    const newBrightness = newBrightness_ < -90 ? -90 : newBrightness_ > 100 ? 100 : newBrightness_;

    if (globalLink.getValue()) {
      globalState.brightness.globalBrightness.setValue(newBrightness);
    }

    _setBrightness(newBrightness);
  }

  function _setBrightness(newBrightness: number, justSetIt = false) {
    brightness.setValue(newBrightness);

    if (newBrightness < 0) {
      if (monitorBrightness.getValue() != 0 || justSetIt) {
        setMonitorBrightness(getDevice(), 0);
      }
      Utils.execAsync(`dimland -a ${(newBrightness * -1) / 100} -o ${output}`);
    } else {
      Utils.execAsync(`dimland -a 0 -o ${output}`);
      setMonitorBrightness(getDevice(), newBrightness);
      monitorBrightness.setValue(newBrightness);
    }

    save(output, brightness.getValue(), monitorBrightness.getValue());
  }

  function getIcon() {
    return globalLink.value ? "org.remmina.Remmina-connect-symbolic" : "window-close-symbolic";
  }

  return Widget.Button({
    child: Widget.Box({
      spacing: 4,
      children: [
        Widget.Icon({
          icon: Utils.watch(getIcon(), globalLink, getIcon),
        }),
        Widget.Label({ label: brightness.bind().as((value) => `${value}%`) }),
      ],
    }),
    onPrimaryClickRelease: toggleGlobalLink,
    onMiddleClickRelease: () => (increase.getValue() === 10 ? increase.setValue(1) : increase.setValue(10)),
    onScrollUp: () => setBrightness(brightness.getValue() + increase.getValue()),
    onScrollDown: () => setBrightness(brightness.getValue() - increase.getValue()),
  });
}
