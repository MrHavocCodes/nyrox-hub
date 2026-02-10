local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Seas = {}

local function Travel(arg)
    local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if CommF then
        CommF:InvokeServer(arg)
    end
end

function Seas.TeleportToSea1()
    if game.PlaceId == 2753915549 or game.PlaceId == 85211729168715 then return end
    Travel("TravelMain")
end

function Seas.TeleportToSea2()
    if game.PlaceId == 4442272183 or game.PlaceId == 79091703265657 then return end
    Travel("TravelDressrosa")
end

function Seas.TeleportToSea3()
    if game.PlaceId == 7449423635 then return end
    Travel("TravelZou")
end

return Seas