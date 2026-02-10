-- ========================================
-- MAXIMUM FRUIT VALUE SLIDER
-- ========================================
-- Sets the maximum value for fruits to keep/use in raids

return function(RaidTab)
    -- Initialize default value
    getgenv().MaxFruitValue = getgenv().MaxFruitValue or 950000
    
    RaidTab:CreateValidSlider({
        Title = "Maximum Fruit Value",
        Tooltip = "Only store fruits below this value (in Beli)",
        Min = 100000,
        Max = 5000000,
        Default = getgenv().MaxFruitValue,
        Callback = function(Value)
            getgenv().MaxFruitValue = Value
        end
    })
end
