const systemtray = await Service.import("systemtray");

export function SystemTray() {
  const items = systemtray.bind("items").as((items) =>
    items.map((item) =>
      Widget.Button({
        child: Widget.Icon({ icon: item.bind("icon") }),
        onPrimaryClick: (_, e) => item.activate(e),
        onSecondaryClick: (_, e) => item.openMenu(e),
        tooltipMarkup: item.bind("tooltip_markup"),
      })
    )
  );

  return Widget.Box({
    children: items,
  });
}
