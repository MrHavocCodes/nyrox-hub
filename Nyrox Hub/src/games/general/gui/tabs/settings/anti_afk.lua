-- Settings Tab - Anti AFK

return function(Tab)
    Tab:AddSection({Name = "Anti AFK"})
    
    Tab:AddToggle({
        Name = "Anti AFK",
        Description = "Prevent AFK kick",
        Default = false,
        Callback = function(value)
            getgenv().AntiAFKEnabled = value
            
            if value and not getgenv().AntiAFKLoop then
                getgenv().AntiAFKLoop = true
                
                spawn(function()
                    while getgenv().AntiAFKLoop and getgenv().AntiAFKEnabled do
                        wait(60)
                        if getgenv().AntiAFKEnabled then
                            local VirtualUser = game:GetService("VirtualUser")
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new())
                        end
                    end
                end)
            elseif not value then
                getgenv().AntiAFKLoop = false
            end
        end
    })
end
