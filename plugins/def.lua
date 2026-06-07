---@meta Favenom_LongerRuns
local public = {}

---@class Favenom_LongerRuns_Config
---@field enabled boolean
---@field ExtraChambers number
---@field ErebusExtraChambers number
---@field OceanusExtraChambers number
---@field Fountains number
---@field MultiMiniboss boolean
---@field NoBoss boolean
public.config = nil  -- will be set in main.lua

---Applies the current configuration to RoomSetData (Erebus and Oceanus).
---Can be called again after config changes to update biome lengths.
public.apply_changes = nil

return public
