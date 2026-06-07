---@meta _
local mods = rom.mods

mods['SGG_Modding-ENVY'].auto()  -- gives us `public` and `import`

rom = rom
_PLUGIN = PLUGIN

game = rom.game

sjson = mods['SGG_Modding-SJSON']
modutil = mods['SGG_Modding-ModUtil']
chalk = mods["SGG_Modding-Chalk"]
reload = mods['SGG_Modding-ReLoad']

---@module 'LongerRuns_HadesII-config'
local config, _ = chalk.auto 'config.lua'
public.config = config  -- make config available to other files

local function on_ready()
	if not public.config.enabled then return end
	import 'ready.lua'
end

local function on_reload()
	if not public.config.enabled then return end
	import 'reload.lua'
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
	loader.load(on_ready, on_reload)
end)