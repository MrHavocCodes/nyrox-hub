-- Loader script to run the environment
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Main = require(script.Parent.main)
Main.run()
