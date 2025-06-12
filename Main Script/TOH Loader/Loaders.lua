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

    loadstring(game:HttpGet("https://raw.githubusercontent.com/AlvaroScript/TOHSCRIPT/refs/heads/main/Main%20Script/Key/Tower%20Of%20Hell%20Key.lua"))()
else
    game.Players.LocalPlayer:Kick("wrong game❌")
end
