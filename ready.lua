---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- This file runs only once when the mod is first loaded.
-- All modifications to RoomSetData are done here to ensure they persist for the entire game session
-- and do not interfere with an ongoing run (since runs start after the mod loads).

function getRoomKeysByPrefix(data, prefix)
	local keys = {}
	for key, _ in pairs(data) do
		if string.sub(key, 1, string.len(prefix)) == prefix then
			table.insert(keys, key)
		end
	end
	return keys
end

---@param biomeKey string "F" or "G"
---@param basePreBossDepth number original depth of the pre-boss room
---@param extraPerBiome number extra chambers only for this biome (added to ExtraChambers)
function applyBiomeChanges(biomeKey, basePreBossDepth, extraPerBiome)
	local roomSet = RoomSetData[biomeKey]
	if not roomSet then
		rom.log.warning("[LongerRuns] Could not find RoomSetData." .. biomeKey)
		return
	end

	local totalExtra = config.ExtraChambers + (extraPerBiome or 0)
	if totalExtra == 0 then
		return  -- nothing to change
	end

	local newPreBossDepth = basePreBossDepth + totalExtra

	-- 1. Move the pre-boss room deeper
	local preBossRoom = roomSet[biomeKey .. "_PreBoss01"]
	if preBossRoom then
		preBossRoom.ForceAtBiomeDepthMin = newPreBossDepth
		preBossRoom.ForceAtBiomeDepthMax = newPreBossDepth
	end

	-- 2. Allow combat rooms to repeat
	local combatRooms = getRoomKeysByPrefix(roomSet, biomeKey .. "_Combat")
	local extraCombatCopies = math.max(math.floor(totalExtra / 3), 1)
	for _, roomName in ipairs(combatRooms) do
		local room = roomSet[roomName]
		if room then
			room.MaxAppearancesThisBiome = 1 + extraCombatCopies
		end
	end

	-- 3. Miniboss handling (if MultiMiniboss is true)
	if config.MultiMiniboss then
		local miniBossRooms = getRoomKeysByPrefix(roomSet, biomeKey .. "_MiniBoss")
		for _, roomName in ipairs(miniBossRooms) do
			local room = roomSet[roomName]
			if room then
				room.MaxCreationsThisRun = nil
				if room.ForceAtBiomeDepthMax then
					room.ForceAtBiomeDepthMax = newPreBossDepth - 1
				end
			end
		end
	end

	-- 4. Extend mid-shop availability
	local shopRoom = roomSet[biomeKey .. "_Shop01"]
	if shopRoom then
		local oldMaxDepth = shopRoom.ForceAtBiomeDepthMax or 6
		shopRoom.ForceAtBiomeDepthMax = oldMaxDepth + totalExtra
		local extraShops = math.floor(totalExtra / 5)
		if extraShops > 0 then
			shopRoom.MaxCreationsThisRun = (shopRoom.MaxCreationsThisRun or 1) + extraShops
		end
	end

	-- 5. Increase fountain rooms
	local fountainRoom = roomSet[biomeKey .. "_Reprieve01"]
	if fountainRoom then
		fountainRoom.MaxCreationsThisRun = config.Fountains
		-- Adjust the upper depth bound if the room has depth constraints
		if fountainRoom.GameStateRequirements then
			for _, req in ipairs(fountainRoom.GameStateRequirements) do
				if req.Path and req.Path[1] == "CurrentRun" and req.Path[2] == "BiomeDepthCache" and req.Comparison == "<=" then
					req.Value = newPreBossDepth - 1
				end
			end
		end
	end

	-- 6. Optional boss skip
	if config.NoBoss and preBossRoom then
		local postBossRoom = roomSet[biomeKey .. "_PostBoss01"]
		if postBossRoom then
			preBossRoom.LinkedRooms = { biomeKey .. "_PostBoss01" }
		end
	end

  if config.RescaleMetaRewards then
    -- Scale meta rewards ratio for Erebus (BaseF)
    if biomeKey == "F" then
    local erebusNewMeta = 1 - (0.685 * (basePreBossDepth/newPreBossDepth))
		RoomSetData.F.BaseF.TargetMetaRewardsRatio = erebusNewMeta
		rom.log.info("[LongerRuns] Erebus meta reward ratio adjusted from 0.315 to " .. string.format("%.3f", erebusNewMeta))

	-- Scale meta rewards ratio for Oceanus (BaseG)
    elseif biomeKey == "G" then
      local oceanusNewMeta = 1 - (0.65 * (basePreBossDepth/newPreBossDepth))
      RoomSetData.G.BaseG.TargetMetaRewardsRatio = oceanusNewMeta
      rom.log.info("[LongerRuns] Oceanus meta reward ratio adjusted from 0.35 to " .. string.format("%.3f", oceanusNewMeta))
    end
  end

	rom.log.info(string.format("[LongerRuns] Applied %d extra chambers to %s", totalExtra, biomeKey))
end

-- Apply changes to Erebus (base pre-boss depth = 10) and Oceanus (base depth = 8)
    if config.enabled then
      applyBiomeChanges("F", 10, config.ErebusExtraChambers)
      applyBiomeChanges("G", 8, config.OceanusExtraChambers)
    
  
    end
