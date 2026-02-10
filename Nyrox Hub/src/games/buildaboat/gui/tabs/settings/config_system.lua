local ConfigSystem = {}
local HttpService = game:GetService("HttpService")

local FolderName = "NyroxHub"
local GameFolder = "BuildABoat"

-- Ensure folders exist
if not isfolder(FolderName) then makefolder(FolderName) end
if not isfolder(FolderName .. "/" .. GameFolder) then makefolder(FolderName .. "/" .. GameFolder) end

function ConfigSystem.SaveConfig(name, data)
    local json = HttpService:JSONEncode(data)
    writefile(FolderName .. "/" .. GameFolder .. "/" .. name .. ".json", json)
end

function ConfigSystem.LoadConfig(name)
    local path = FolderName .. "/" .. GameFolder .. "/" .. name .. ".json"
    if isfile(path) then
        local json = readfile(path)
        return HttpService:JSONDecode(json)
    end
    return nil
end

function ConfigSystem.GetConfigs()
    local files = listfiles(FolderName .. "/" .. GameFolder)
    local configs = {}
    for _, file in pairs(files) do
        -- Extract filename from path (supports both \ and /)
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end
    return configs
end

function ConfigSystem.DeleteConfig(name)
    local path = FolderName .. "/" .. GameFolder .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
    end
end

return ConfigSystem
