--[[
    Author: Iskelmaikel
    Special thanks to deer boi
]]


local M = {}

--M.dependencies = {"ui_imgui"}

-- local gui_module = require("ge/extensions/editor/api/gui")
-- local gui = {setupEditorGuiTheme = nop}
-- local imgui = ui_imgui

print("Cops and robbers client initializing...")

local pluginAge = 0
local resource
local flagRadius = 3
local flagHeight = 100
local newPositionBase = Point3F(13,160,0)
local newPositionTop = Point3F(13,160,0 + flagHeight)
local playerTeam = nil 
local checkpointReached = false

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

-- Load additional config from json(?). Most settings will be handled serverside 
local function onExtensionLoaded()
    resource = jsonReadFile("settings/resource.json")
    print("Cops and robbers version " .. resource.version .. " loaded")
    --log("I", "Cops and robbers", "version " .. resource.version .. " loaded")
end

local function onExtensionUnloaded()
    --Might need some logic such as unregistering player
end

local function distance(pos1, pos2)
	return math.sqrt(math.pow(pos1.x-pos2.x,2)+math.pow(pos1.y-pos2.y,2))
end

-- Will be moved serverside
local function setNewCheckpoint(data)
    print("Received new checkpoint: " .. data)
    data = data:sub(2)
    local arr = split(data, ",")
    local newX = tonumber(arr[1])
    local newY = tonumber(arr[2])
    newPositionBase = Point3F(newX, newY, 0)
    newPositionTop = Point3F(newX, newY, 0 + flagHeight)
    checkpointReached = false
end

-- Check if player has reached checkpoint
local function hasReachedCheckpoint()
    for i = 0, be:getObjectCount()-1 do
        local veh = be:getObject(i)
        if MPVehicleGE.isOwn(veh:getID()) and distance(veh:getPosition(), newPositionBase) < flagRadius * 1.5
        then
            TriggerServerEvent("CheckpointReached", "Client... reached the checkpoint. Requesting new one")
        end
    end
end

-- Spawn mission marker 
local function drawCheckpoint()
    debugDrawer:drawCylinder(newPositionBase, newPositionTop, flagRadius, ColorF(0,0.6,0.7,0.5)) -- 2 colors? Red forcops and green for robbers to indicate good/bad?
    --guihooks.trigger("ScenarioChange", {name="Capture the flag rules:", description="break them rulez ok", introType="htmlOnly"})
end

-- Main local game loop
local function onUpdate()
    drawCheckpoint()
    hasReachedCheckpoint()
end

local function onPlayerJoinedTeam()
    drawCheckpoint()
    hasReachedCheckpoint()
end
local function onCheckpointReached()
    TriggerServerEvent("CheckpointReached", "Player reached checkpoint. Requesting new one...")
end

local function onNewCheckpointReceived(data)
    setNewCheckpoint(data)
    checkpointReached = false
end


-- Register all event handlers
AddEventHandler("PlayerJoinedTeam", onPlayerJoinedTeam)
AddEventHandler("NewCheckpointReceived", onNewCheckpointReceived)
AddEventHandler("StartGame", onStartGame)
AddEventHandler("EndGame", onEndGame)
AddEventHandler("ResetGame", onResetGame)
AddEventHandler("CheckpointReached", onCheckpointReached)
AddEventHandler("CrashedWithPlayer", onCrashedWithPlayer)
AddEventHandler("ReceiveScores", onReceiveScores)
AddEventHandler("ReceiveCheckpoint", onReceiveCheckpoint)

-- Requires some hooks onto UI
M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded
M.onUpdate = onUpdate

return M
