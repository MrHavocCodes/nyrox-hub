-- Visuals Tab - Graphics

return function(Tab)
    Tab:AddSection({Name = "Graphics"})
    
    Tab:AddToggle({
        Name = "Remove Textures",
        Description = "Remove all textures (FPS Boost)",
        Default = false,
        Callback = function(value)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") then
                    if value then
                        obj.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end
    })
    
    Tab:AddToggle({
        Name = "Low Graphics",
        Description = "Set graphics to low (FPS Boost)",
        Default = false,
        Callback = function(value)
            local Lighting = game:GetService("Lighting")
            
            if value then
                -- Save original settings
                getgenv().OriginalGraphics = {
                    GlobalShadows = Lighting.GlobalShadows,
                    Brightness = Lighting.Brightness,
                    Technology = Lighting.Technology
                }
                
                -- Set low graphics
                Lighting.GlobalShadows = false
                Lighting.Brightness = 2
                Lighting.Technology = Enum.Technology.Legacy
            else
                -- Restore original settings
                if getgenv().OriginalGraphics then
                    Lighting.GlobalShadows = getgenv().OriginalGraphics.GlobalShadows
                    Lighting.Brightness = getgenv().OriginalGraphics.Brightness
                    Lighting.Technology = getgenv().OriginalGraphics.Technology
                end
            end
        end
    })
end
