local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local ChestOpener = {}
local AutoOpening = false
local SelectedChest = "Common Chest"

-- Usually Remote Function to Buy Item looks like this
local ShoppingRemote = Workspace:WaitForChild("ItemBoughtFromShop", 5) 
-- Or ReplicatedStorage:WaitForChild("BuyItem") depending on game version
-- In BaB, it's often Workspace.ItemBoughtFromShop:InvokeServer(ItemName, Amount)

function ChestOpener.SetChest(chestName)
    SelectedChest = chestName
end

function ChestOpener.ToggleAutoOpen(state)
    AutoOpening = state
    
    if state then
        task.spawn(function()
            while AutoOpening and getgenv().NyroxRunning do
                pcall(function()
                     -- Verify Remote (Try classic first)
                     if ShoppingRemote then
                        ShoppingRemote:InvokeServer(SelectedChest, 1)
                     else
                        warn("Shopping Remote not found in Workspace")
                     end
                end)
                
                -- Check continuously during the wait to stop faster
                for i = 1, 10 do 
                    if not AutoOpening then break end
                    task.wait(0.1)
                end
            end
        end)
    end
end

return ChestOpener
