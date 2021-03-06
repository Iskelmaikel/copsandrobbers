local M = {}

obj:queueGameEngineLua('if not copsandrobbers then registerCoreModule("copsandrobbers"); loadCoreExtensions() end')

return M