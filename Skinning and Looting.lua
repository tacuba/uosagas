-- Title: Skinning and Looting
-- Last Updated: 06/23/2025
-- Original Author: RealMonero (https://github.com/RealMonero/UOSagas)
-- Adapted by: Tacuba (https://github.com/tacuba/uosagas)
-- Description: This script will skin corpses, loot the corpse, and cut hides into leather.
-- Update Notes: Adjusted timers; added Overhead messages; refined loot logic.

local lastSkinnedSerial = -1

while true do
    Pause(1200)

    local knife = Items.FindByType(0xFEA9) -- Skinning knife
    if knife then
        local filter = {
            onground = true,
            rangemax = 1,
            graphics = {0x2006, 0x2007, 0x2008} -- Corpse graphics
        }
        local corpses = Items.FindByFilter(filter)

        if corpses and #corpses > 0 then
            local corpse = corpses[1]

            if corpse.Serial ~= lastSkinnedSerial then
                Pause(300)
                Messages.Overhead("Skinning " .. (corpse.Name or "corpse") .. "...", 55, Player.Serial)

                Journal.Clear()

                Pause(1800)  -- wait longer before skinning to avoid system error

                Player.UseObject(knife.Serial)
                if Targeting.WaitForTarget(2000) then
                    Targeting.Target(corpse.Serial)
                    Pause(800)  -- brief pause after targeting
                end

                lastSkinnedSerial = corpse.Serial

                Pause(600) -- Wait for skinning animation and journal update

                local successMsg = "You skin it, and the hides are now in the corpse."
                if Journal.Contains(successMsg) then
                    Messages.Overhead("Skinning successful!", 65, Player.Serial)
                else
                    Messages.Overhead("Skinning failed.", 45, Player.Serial)
                end

                -- Loot items from corpse
                local lootFilter = { RootContainer = corpse.Serial }
                local items = Items.FindByFilter(lootFilter)

                if not items or #items == 0 then
                    Pause(800)
                    items = Items.FindByFilter(lootFilter)
                end

                if items then
                    for _, item in ipairs(items) do
                        if item.RootContainer == corpse.Serial then
                            local amt = item.Amount or 1
                            Player.PickUp(item.Serial, amt)
                            Pause(400)
                            Player.DropInBackpack()
                            Messages.Overhead("Looted: " .. (item.Name or "item"), 88, Player.Serial)
                            Pause(500)
                        end
                    end
                end

                -- Cut hides using scissors
                local scissors = Items.FindByType(0x0F9F) -- Scissors
                if scissors then
                    local hideFilter = {
                        RootContainer = Player.Serial,
                        graphics = {0x1078, 0x1079}
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
            end
        end
    end
    Pause(500)
end
