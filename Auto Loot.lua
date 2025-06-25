-- Title: Looting Only
-- Last Updated: 06/24/2025
-- Author: Tacuba (https://github.com/tacuba/uosagas)
-- Description: This script will loot items from corpses nearby, ensuring the corpse is opened before looting.

local lootedCorpses = {}

while true do
    Pause(1200)

    local filter = {
        onground = true,
        rangemax = 1,
        graphics = {0x2006, 0x2007, 0x2008} -- Corpse graphics
    }

    local corpses = Items.FindByFilter(filter)

    if corpses and #corpses > 0 then
        for _, corpse in ipairs(corpses) do
            if lootedCorpses[corpse.Serial] then
                goto continue
            end

            -- Open the corpse before attempting to loot
            Messages.Overhead("Opening corpse...", 45, Player.Serial)
            Player.UseObject(corpse.Serial)

            if not Gumps.WaitForGump(0, 1500) then
                Messages.Overhead("Corpse gump failed to open.", 33, Player.Serial)
                lootedCorpses[corpse.Serial] = true
                goto continue
            end

            Pause(700) -- Allow items to populate

            local lootFilter = { RootContainer = corpse.Serial }
            local items = Items.FindByFilter(lootFilter)

            -- Retry once if nothing found
            if not items or #items == 0 then
                Pause(800)
                items = Items.FindByFilter(lootFilter)
            end

            if not items or #items == 0 then
                Messages.Overhead("Skipping empty corpse.", 45, Player.Serial)
                lootedCorpses[corpse.Serial] = true
                goto continue
            end

            -- Start looting
            Messages.Overhead("Looting corpse...", 11, Player.Serial)
            local lootedSomething = false

            for _, item in ipairs(items) do
                if item.RootContainer == corpse.Serial then
                    local amt = item.Amount or 1
                    Player.PickUp(item.Serial, amt)
                    Pause(400)
                    Player.DropInBackpack()
                    Messages.Overhead("Looted: " .. (item.Name or "item"), 88, Player.Serial)
                    Pause(500)
                    lootedSomething = true
                end
            end

            if lootedSomething then
                Messages.Overhead("Finished looting corpse.", 60, Player.Serial)
            else
                Messages.Overhead("Nothing lootable left.", 45, Player.Serial)
            end

            lootedCorpses[corpse.Serial] = true

            ::continue::
        end
    end

    Pause(500)
end
