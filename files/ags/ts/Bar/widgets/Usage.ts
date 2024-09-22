const divide = ([total, free]: [any, any]) => free / total;

const cpu = Variable(0, {
  poll: [
    2000,
    `top -bn1`,
    (out) =>
      divide([
        100,
        100 -
          parseInt(
            out
              .split("\n")
              .find((line) => line.includes("Cpu(s)"))
              ?.match(/.*, *([0-9.]+)%* id.*/)?.[1] ?? "100"
          ),
      ]),
  ],
});

const ram = Variable(0, {
  poll: [
    2000,
    "free",
    (out) =>
      divide(
        out
          .split("\n")
          .find((line) => line.includes("Mem:"))
          ?.split(/\s+/)
          .splice(1, 2) as [any, any]
      ),
  ],
});

export function Usage() {
  const cpuProgress = Widget.Label({
    label: cpu.bind().as((value) => `${Math.round(value * 100)}%`),
  });

  const ramProgress = Widget.Label({
    label: ram.bind().as((value) => `${Math.round(value * 100)}%`),
  });

  return Widget.Box({
    spacing: 8,
    children: [cpuProgress, ramProgress],
  });
}
