-- Settings Tab - Credits

return function(Tab)
    Tab:AddSection({Name = "Credits"})
    
    Tab:AddLabel({
        Name = "Nyrox Hub - General Script",
        TextColor = Color3.fromRGB(100, 200, 255)
    })
    
    Tab:AddLabel({
        Name = "Version 1.0.0",
        TextColor = Color3.fromRGB(150, 150, 150)
    })
    
    Tab:AddLabel({
        Name = "Universal Script for All Games",
        TextColor = Color3.fromRGB(150, 150, 150)
    })
    
    Tab:AddSection({Name = "Info"})
    
    Tab:AddLabel({
        Name = "PlaceId: " .. game.PlaceId,
        TextColor = Color3.fromRGB(200, 200, 200)
    })
    
    Tab:AddButton({
        Name = "Copy PlaceId",
        Description = "Copy PlaceId to clipboard",
        Callback = function()
            setclipboard(tostring(game.PlaceId))
            if getgenv().CoreFunctions then
                getgenv().CoreFunctions.Notify("Info", "PlaceId copied!", 2)
            end
        end
    })
end
