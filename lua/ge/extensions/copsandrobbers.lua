
local M = {}

local resource

local function onExtensionLoaded()
    resource = jsonReadFile("settings/resource.json")
    log("I", resource.name,  " | version " .. resource.version .. " loaded")
end

M.onExtensionLoaded = onExtensionLoaded

return M
