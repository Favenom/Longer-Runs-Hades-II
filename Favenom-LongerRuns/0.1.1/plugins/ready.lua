---@meta _
---@diagnostic disable: lowercase-global

-- The function is defined in reload.lua; we just call it.
if public.apply_changes then
	public.apply_changes()
else
	-- fallback: in case reload.lua hasn't been loaded yet (should not happen)
	import 'reload.lua'
	public.apply_changes()
end