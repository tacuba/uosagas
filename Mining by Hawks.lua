-- Authored by Hawks; minor tweaks by Tacuba
--Mining

--Phase 1
function oreProcessin()
    local itemIdSmallOrePile = {0x19B9, 0x19B8, 0x19BA, 0x19B7}
    local didCombine = false

    local itemList1 = Items.FindByFilter({})
    for index, item1 in ipairs(itemList1) do
        if item1 ~= nil then
            if item1.RootContainer ~= Player.Serial then goto continue end

            if item1.Graphic == itemIdSmallOrePile[1]
            or item1.Graphic == itemIdSmallOrePile[2]
            or item1.Graphic == itemIdSmallOrePile[3] then

                Messages.Overhead("That's a lotta ore...", 66, Player.Serial)

                local itemList2 = Items.FindByFilter({})
                for index, item2 in ipairs(itemList2) do
                    if item2 ~= nil then
                        if item2.RootContainer ~= Player.Serial then goto continue end
                        if item1.Hue ~= item2.Hue then goto continue end

                        if item2.Graphic == itemIdSmallOrePile[4] then
                            Player.UseObject(item1.Serial)
                            if Targeting.WaitForTarget(1000) then
                                Messages.Overhead("Let's put this here, that there...", 446, Player.Serial)
                                Targeting.Target(item2.Serial)
                                Pause(1000)
                                didCombine = true
                                break
                            end
                        end
                        ::continue::
                    end
                end
            end
            ::continue::
        end
    end

    if didCombine then
        Messages.Overhead("That looks perfect. Ending script.", 16, Player.Serial)
        return true
    end

    return false
end

local function equipPickAxe()
    for _, layer in ipairs({1, 2}) do
        local checkAxe = Items.FindByLayer(layer)
        if checkAxe and string.find(string.lower(checkAxe.Name or ""), "pickaxe") then
            axe = checkAxe
            break
        end
    end

    local equipaxe = Items.FindByName("Pickaxe")

    if axe == nil and equipaxe ~= nil then
        Player.Equip(equipaxe.Serial)
        Pause(1000)
        for _, layer in ipairs({1, 2}) do
            local checkAxe = Items.FindByLayer(layer)
            if checkAxe and string.find(string.lower(checkAxe.Name or ""), "pickaxe") then
                axe = checkAxe
                break
            end
        end
    end
end

function Main()
    local axe = nil
    for _, layer in ipairs({1, 2}) do
        local checkAxe = Items.FindByLayer(layer)
        if checkAxe and string.find(string.lower(checkAxe.Name or ""), "pickaxe") then
            axe = checkAxe
            break
        end
    end

    local equipaxe = Items.FindByName("Pickaxe")

    if axe == nil and equipaxe ~= nil then
        Player.Equip(equipaxe.Serial)
        Pause(1000)
        for _, layer in ipairs({1, 2}) do
            local checkAxe = Items.FindByLayer(layer)
            if checkAxe and string.find(string.lower(checkAxe.Name or ""), "pickaxe") then
                axe = checkAxe
                break
            end
        end
    end

    if axe == nil then
        Messages.Overhead("I need to equip the Pickaxe.", 446, Player.Serial)
        return
    end

 -- Phase 2
 -- Main loop for the mining script
    while true do
        Messages.Overhead("Start of Phase 2 (L.83).", 11, Player.Serial)
        Journal.Clear() -- Clear journal at the start of each new spot attempt
        
        -- PROMPT FOR NEW MINING SPOT AND ACTIVATE CURSOR
        Messages.Overhead("Where shall we mine avatar?", 66, Player.Serial)
        
        -- CRITICAL: Ensure the pickaxe is used *here* to get the targeting cursor
        Player.UseObject(axe.Serial) 
        
        -- Wait for player to select a target. Use a very large number for "indefinite".
        if not Targeting.WaitForTarget(300000) then -- 5 minutes timeout
            Messages.Overhead("Script stopped: No target selected within timeout.", Player.Serial)
            return -- Exit the script if no target is selected within the timeout
        end
        -- Player has selected a target, now we can proceed with mining that spot
        Pause(1000) -- Small pause after a target is selected (gives client time to register)

        -- Inner loop for mining the current selected spot
        while true do
            -- Ensure journal is cleared before each mining attempt to reliably check messages
            Journal.Clear()

            if Player.Weight > 389 then
                Messages.Overhead("This ore is too heavy avatar! Please unburden yourself.", 66, Player.Serial)
                local combined = oreProcessin()
                if combined then
                    Pause(500) -- Small pause after combining
                    Messages.Overhead("Weight adjusted. Please select a new mining spot.", Player.Serial)
                    break -- This breaks out of the INNER while loop, returning to the OUTER loop.
                else
                    Messages.Overhead("I'm still overburdened avatar. Ending script.", 77, Player.Serial)
                    return -- Exit the script if still overweight and can't combine
                end
            end

            -- Use the pickaxe to mine the last targeted spot
            Player.UseObject(axe.Serial)
            -- This WaitForTarget is for the *auto-targeting* of the last spot
            if Targeting.WaitForTarget(1000) then 
                Targeting.TargetLast() -- Target the last selected spot
            else
                -- If somehow the last target was lost or can't be auto-targeted
                Messages.Overhead("Lost target during mining. Please re-target.", Player.Serial)
                break -- Break inner loop to prompt for new target in outer loop
            end

            Pause(1000) -- Pause after attempting to mine

-- Phase 3
 -- CHECK JOURNAL ENTRIES *AFTER* THE MINING ATTEMPT
            if Journal.Contains("You can't mine there.") then
                Messages.Overhead("Cannot mine that spot. Asking for a new location.", Player.Serial)
                break -- Break inner loop to prompt for new target in outer loop
            end

            if Journal.Contains("There is no metal here to mine.") then
                Messages.Overhead("I'm sorry avatar this spot is empty. Please find a new area.", 446, Player.Serial)
                break -- Break out of the inner loop to ask for a new target
            end

            if Journal.Contains("too far") or Journal.Contains("cannot be seen") then
                Messages.Overhead("Lost target or too far! Please re-target.", Player.Serial)
                break -- Break out of the inner loop to ask for a new target
            end
            
            if Journal.Contains("You have worn out") then
                Messages.Overhead("Having equipment issues, trying to re-equip", Player.Serial)
                if equipaxe ~= nil then
                    Player.Equip(equipaxe.Serial)
                    Pause(1000)
                    axe = nil
                    for _, layer in ipairs({1, 2}) do
                        local checkAxe = Items.FindByLayer(layer)
                        if checkAxe and string.find(string.lower(checkAxe.Name or ""), "pickaxe") then
                            axe = checkAxe
                            break
                        end
                    end
                    if axe == nil then
                        Messages.Overhead("Failed to equip pickaxe properly", Player.Serial)
                        return
                    end
                else
                    Messages.Overhead("Cannot find Pickaxe in backpack", Player.Serial)
                    return
                end
                -- Don't clear journal here, let the loop continue and re-attempt to mine.
            end
        end
        -- After breaking the inner loop, the outer loop will restart, which
        -- will then execute the "PROMPT FOR NEW MINING SPOT AND ACTIVATE CURSOR" section again.
        Pause(2000) -- Short pause before prompting for a new spot
    end
end



Main()           
