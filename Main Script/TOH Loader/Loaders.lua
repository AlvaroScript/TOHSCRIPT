if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Allowed Place IDs
local allowedPlaceIds = {
    [1962086868] = true, -- Tower of Hell
    [3582763398] = true, -- Tower of Hell Pro
    [5253186791] = true  -- Tower of Hell Appeals
}

local currentPlaceId = game.PlaceId

if allowedPlaceIds[currentPlaceId] then
    print("✅ Game ID verified. Loading your script...")

    loadstring(game:HttpGet("https://your-host.com/your-script.lua"))()
else
    game.Players.LocalPlayer:Kick("wrong game❌")
end
