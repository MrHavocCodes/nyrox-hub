-- Settings Tab - Script Control

return function(Tab)
    Tab:AddSection({Name = "Script Control"})
    
    Tab:AddButton({
        Name = "Rejoin Server",
        Description = "Rejoin the current server",
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
            TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
    })
    
    Tab:AddButton({
        Name = "Server Hop",
        Description = "Switch to a different server",
        Callback = function()
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            
            local success, servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            
            if success and servers and servers.data then
                for _, server in pairs(servers.data) do
                    if server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                        return
                    end
                end
            else
                if getgenv().CoreFunctions then
                    getgenv().CoreFunctions.Notify("Error", "Could not find servers!", 3)
                end
            end
        end
    })
    
    Tab:AddButton({
        Name = "Close Script",
        Description = "Close the script",
        Callback = function()
            -- Clean up tooltips
            if getgenv().currentTooltipText then
                getgenv().currentTooltipText = nil
            end
            if getgenv().NyroxTooltipConnection then
                getgenv().NyroxTooltipConnection:Disconnect()
                getgenv().NyroxTooltipConnection = nil
            end
            
            -- Find and destroy tooltip GUI
            local coreGui = game:GetService("CoreGui")
            local tooltipGui = coreGui:FindFirstChild("NyroxTooltip")
            if tooltipGui then
                tooltipGui:Destroy()
            end
            
            if getgenv().CoreFunctions then
                getgenv().CoreFunctions.Cleanup()
            end
            
            -- Close GUI
            for _, gui in pairs(game.CoreGui:GetChildren()) do
                if gui.Name == "NyroxHub" then
                    gui:Destroy()
                end
            end
        end
    })
end
