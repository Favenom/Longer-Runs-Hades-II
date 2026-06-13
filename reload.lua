---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- This file would be reloaded if it changes during gameplay, but our mod modifies RoomSetData
-- which should only be done once at game start. Changing values mid‑run could corrupt the run.
-- Therefore, we do nothing here except issue a warning if the file is accidentally reloaded.

rom.log.warning("[LongerRuns] reload.lua was triggered – biome modifications are reapplied")
   if config.enabled then
      applyBiomeChanges("F", 10, config.ErebusExtraChambers)
      applyBiomeChanges("G", 8, config.OceanusExtraChambers)
    
  
    end
