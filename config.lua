---@meta Favenom_LongerRuns-config
local config = {
	enabled = true,                     -- set to false to disable the mod
	ExtraChambers = 8,                  -- extra rooms added before the boss in every biome
	ErebusExtraChambers = 0,            -- extra rooms only for Erebus (adds to ExtraChambers)
	OceanusExtraChambers = 0,           -- extra rooms only for Oceanus
	Fountains = 2,                      -- maximum fountain rooms per biome (default 1)
	MultiMiniboss = true,               -- allow multiple minibosses in the same biome
	NoBoss = false,                     -- skip the boss room entirely (cheat)
  RescaleMetaRewards = false,         -- activate "no fun allowed" mode in which the total number of major rewards stays the same as vanilla
}

local description = {
	enabled = "Set to true to enable the mod, false to disable it.",
	ExtraChambers = "Number of extra rooms added before the boss in every biome.",
	ErebusExtraChambers = "Additional extra rooms only for Erebus (added to ExtraChambers).",
	OceanusExtraChambers = "Additional extra rooms only for Oceanus.",
	Fountains = "Maximum number of fountain rooms that can appear in a single biome (original is 1).",
	MultiMiniboss = "If true, allows the same miniboss to appear multiple times in a single run.",
	NoBoss = "If true, the boss room is replaced by a transition directly to the post‑boss room (cheat).",
  RescaleMetaRewards = "If true, reduces the chance of major rewards proportionally to the increased run length, keeping the total number of major rewards roughly the same as vanilla.",
}

return config, description