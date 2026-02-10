local function AddUpdateBox(tab, version, date, lines)
    local box = tab:CreateSection(version .. " (" .. date .. ")")
    for _, line in ipairs(lines) do
        tab:CreateLabel(line)
    end
end

return function(UpdatesTab)
    AddUpdateBox(UpdatesTab, "v2.1.1", "2026-02-07", {
        "- Added Low Graphics module: toggleable, restores previous lighting/terrain settings, and removes fog/particles/animations for better performance.",
        "- Remove Fog simplified: now only removes fog/atmosphere and brightens the world (less intrusive and reversible).",
        "- Anti-AFK module: toggleable, starts after 10 minutes of inactivity and simulates periodic input to prevent AFK kick.",
        "- Animation handling: Low Graphics and Remove Fog now stop most animation tracks to reduce load; Low Graphics attempts to restore animations on disable.",
        "- Fixed: Missing file that caused 404 for Low Graphics (now added as an independent module).",
    })

    AddUpdateBox(UpdatesTab, "v2.1.0", "2026-02-06", {
        "- Bring Fruit: Now uses firetouchinterest for instant pickup!",
        "- Auto Store Fruit: Now strictly only stores physical fruits, never abilities.",
        "- Grab Fruit: Insane bypass and speed improvements.",
        "- UI: Fruit tab reworked, bugfixes, and more toggles.",
        "- Submerged Island: Improved NPC interaction reliability.",
        "- General: Many bugfixes and stability improvements."
    })
    AddUpdateBox(UpdatesTab, "v2.0.0", "2026-01-30", {
        "- Fruit Notify toggle added.",
        "- Submerged Island teleport: Super interaction and anti-reset logic.",
        "- UI: Improved tab sorting and tooltips.",
        "- Bugfix: Land detection now 5000 studs for anti-cheat safety."
    })
    AddUpdateBox(UpdatesTab, "v1.9.0", "2026-01-20", {
        "- Auto Farm: Improved mob magnet and stat upgrades.",
        "- PvP: New auto-activate V3/V4 toggles.",
        "- Misc: Walk on Water and FOV slider."
    })
    AddUpdateBox(UpdatesTab, "v1.8.0", "2026-01-10", {
        "- UI: New visuals tab, chest ESP, and more.",
        "- General: Performance and stability improvements."
    })
end
