const hyprland = await Service.import("hyprland");

export function Workspaces() {
  const activeId = hyprland.active.workspace.bind("id");
  const workspaces = hyprland.bind("workspaces").as((ws) =>
    ws
      .sort((a, b) => a.id - b.id)
      .map(({ id }) =>
        Widget.Button({
          onClicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
          child: Widget.Label(`${id}`),
          class_name: activeId.as((i) => (i === id ? "focused" : "")),
        })
      )
  );

  return Widget.Box({
    className: "workspaces",
    children: workspaces,
  });
}
