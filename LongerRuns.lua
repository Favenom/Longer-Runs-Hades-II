--[[
    LongerRuns_HadesII
    Author: Favenom based on raisins' LongerRuns for Hades, adapted for Hades II

    Increases the number of chambers in Erebus and Oceanus.
    Uses ModUtil framework.
]]


-- ============================================================
-- CONFIGURATION – edit these values to your liking
-- ============================================================
local config = {
    Enabled = true,                 -- set to true to activate

    -- Global extra chambers added to every biome
    ExtraChambers = 8,

    -- Per‑biome fine‑tuning (added on top of ExtraChambers)
    ErebusExtraChambers = 0,
    OceanusExtraChambers = 0,

    -- Fountain rooms: maximum per biome (default is 1)
    Fountains = 2,

    -- Allow multiple minibosses in the same biome
    MultiMiniboss = true,

    -- Boss skipping (cheat) – not recommended for normal play
    NoBoss = false,                 -- if true, boss room becomes a normal transition
}

LongerRuns_config = config

if not config.Enabled then
    return
end

-- Helper: get all room keys that match a prefix
local function getRoomKeysByPrefix(data, prefix)
    local keys = {}
    for key, _ in pairs(data) do
        if string.sub(key, 1, string.len(prefix)) == prefix then
            table.insert(keys, key)
        end
    end
    return keys
end

-- Helper: apply changes to a single biome
local function applyBiomeChanges(biomeKey, basePreBossDepth, extraPerBiome)
    local roomSet = RoomSetData[biomeKey]
    if not roomSet then
        print("LongerRuns: Could not find RoomSetData." .. biomeKey)
        return
    end

    local totalExtra = config.ExtraChambers + (extraPerBiome or 0)
    if totalExtra == 0 then
        return  -- nothing to change
    end

    local newPreBossDepth = basePreBossDepth + totalExtra

    -- 1. Adjust pre‑boss room depth
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

    -- 3. Miniboss handling (if MultiMiniboss enabled)
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

    -- 4. Extend mid‑shop availability
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
        -- Adjust depth range: original constraints varied per biome; we'll extend upper bound
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

    print(string.format("LongerRuns: Applied %d extra chambers to %s", totalExtra, biomeKey))
end

-- ============================================================
-- Apply changes to Erebus (biome F)
-- Base pre‑boss depth in F_PreBoss01 = 10
-- ============================================================
applyBiomeChanges("F", 10, config.ErebusExtraChambers)

-- ============================================================
-- Apply changes to Oceanus (biome G)
-- Base pre‑boss depth in G_PreBoss01 = 8
-- ============================================================
applyBiomeChanges("G", 8, config.OceanusExtraChambers)