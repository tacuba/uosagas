-- Title: Skinning and Looting
-- Last Updated: 06/28/2025
-- Author: Tacuba (https://github.com/tacuba/uosagas)
-- Description: This script will skin corpses, loot the corpse, and cut hides into leather.
-- Update Notes: Refined function logic; incorporated option to skip items; started testing skipping of blue corpses.

-- === CONFIGURATION ===

local CONFIG = {
    skinningKnifeID = 0xFEA9,
    scissorsID = 0x0F9F,
    corpseGraphics = {0x2006, 0x2007, 0x2008},
    hideGraphics = {0x1078, 0x1079},
    skipLootGraphics = {0x09F1}, -- Graphics to skip looting
    range = 1,
    skipBlueCorpses = true,
    openCorpseTimeout = 2000,
    skinningDelay = 400,
    targetingDelay = 800,
    lootPause = 650,
    mainLoopPause = 1200,
    finalLoopPause = 500,
    overheadColors = {
        info = 55,
        success = 65,
        fail = 45,
        loot = 88,
        error = 33,
        skip = 24,
    },
    skinningSuccessMsg = "You skin it, and the hides are now in the corpse."
}

local lastSkinnedSerial = -1

-- === HELPERS ===

local function findKnife()
    return Items.FindByType(CONFIG.skinningKnifeID)
end

local function findScissors()
    return Items.FindByType(CONFIG.scissorsID)
end

local function findNearbyCorpse()
    local filter = {
        onground = true,
        rangemax = CONFIG.range,
        graphics = CONFIG.corpseGraphics
    }
    local corpses = Items.FindByFilter(filter)
    if corpses then
        for _, corpse in ipairs(corpses) do
            if CONFIG.skipBlueCorpses and corpse.Notoriety == 1 then
                Messages.Overhead("Skipping blue corpse!", CONFIG.overheadColors.skip, Player.Serial)
            else
                return corpse
            end
        end
    end
    return nil
end

local function isGraphicSkipped(graphic)
    for _, skipID in ipairs(CONFIG.skipLootGraphics) do
        if graphic == skipID then
            return true
        end
    end
    return false
end

local function openCorpse(corpse)
    Messages.Overhead("Opening corpse...", CONFIG.overheadColors.info, Player.Serial)
    Player.UseObject(corpse.Serial)
    if Gumps.WaitForGump(0, CONFIG.openCorpseTimeout) then
        Pause(1000)
        return true
    else
        Messages.Overhead("Failed to open corpse.", CONFIG.overheadColors.error, Player.Serial)
        return false
    end
end

Pause(200)

local function lootCorpse(corpse)
    local lootFilter = { RootContainer = corpse.Serial }
    local items = Items.FindByFilter(lootFilter)

    if not items or #items == 0 then
        Pause(300)
        items = Items.FindByFilter(lootFilter)
    end

    if items then
        for _, item in ipairs(items) do
            if item.RootContainer == corpse.Serial then
                if isGraphicSkipped(item.Graphic) then
                    local skipName = item.Name or string.format("0x%X", item.Graphic)
                    Messages.Overhead("Skipping item: " .. skipName, CONFIG.overheadColors.skip, Player.Serial)
                    Pause(300)
                else
                    local amt = item.Amount or 1
                    Player.PickUp(item.Serial, amt)
                    Pause(50)
                    Player.DropInBackpack()
                    Messages.Overhead("Looting: " .. (item.Name or "item"), CONFIG.overheadColors.loot, Player.Serial)
                    Pause(600)
                end
            end
        end
    end
end

local function cutHides()
    local scissors = findScissors()
    if not scissors then return end

    local hideFilter = {
        RootContainer = Player.Serial,
        graphics = CONFIG.hideGraphics
    }
    local hides = Items.FindByFilter(hideFilter)

    if hides then
        for _, hide in ipairs(hides) do
            Player.UseObject(scissors.Serial)
            if Targeting.WaitForTarget(2000) then
                Targeting.Target(hide.Serial)
            end
            Pause(1200)
        end
    end
end

local function skinCorpse(corpse, knife)
    Journal.Clear()
    Messages.Overhead("Skinning " .. (corpse.Name or "corpse") .. "...", CONFIG.overheadColors.info, Player.Serial)

    Pause(CONFIG.skinningDelay)
    Player.UseObject(knife.Serial)
    if Targeting.WaitForTarget(2000) then
        Targeting.Target(corpse.Serial)
        Pause(CONFIG.targetingDelay)
    end

    Pause(600)

    if Journal.Contains(CONFIG.skinningSuccessMsg) then
        Messages.Overhead("Skinning successful!", CONFIG.overheadColors.success, Player.Serial)
        Pause(800)
    else
        Messages.Overhead("Skinning failed.", CONFIG.overheadColors.fail, Player.Serial)
        Pause(800)
    end
end

-- === MAIN LOOP ===

while true do
    Pause(CONFIG.mainLoopPause)

    local knife = findKnife()
    if knife then
        local corpse = findNearbyCorpse()
        if corpse and corpse.Serial ~= lastSkinnedSerial then
            Pause(300)
            skinCorpse(corpse, knife)
            lastSkinnedSerial = corpse.Serial

            if openCorpse(corpse) then
                lootCorpse(corpse)
            end

            cutHides()
        end
    end

    Pause(CONFIG.finalLoopPause)
end
