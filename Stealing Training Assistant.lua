--[[
================================================================================
 Stealing Training Script - All-in-One v3
 Authors: Coolskin, Tacuba
 Last Modified: 07/14/2025
--------------------------------------------------------------------------------

 VERSION SUMMARY:
 This script trains the Stealing skill up to 100.0 using a single stack of
 items (e.g., bandages). This method simplifies training as you don't need
 to manage items of different weights or types.

 HOW IT WORKS:
 1. Automated Setup: You can start with the training container in your main
    backpack. The script will automatically place it on the ground before
    starting the training loop.

 2. Auto-Restock: After every successful steal, the stolen item is immediately
    placed back into the container, allowing for continuous, uninterrupted
    training.

 3. Anti-Decay System: To prevent the container from decaying on the ground,
    an optional periodic action is included. When enabled, it will pick up
    the container and drop it back down, resetting its decay timer. This
    interval is fully customizable.

 RECOMMENDATION:
 For high-level gains (90.0+), it is recommended to steal items weighing
 10 stones. A stack of 100 bandages is perfect for this.

================================================================================
]]

-- ### CONFIGURATION ###
local targetContainerSerial = 0x41BE6BC7
local itemIDToSteal = 0x0E21 -- Default: Bandages (0x0E21 or 3617)
local messagePause = 500
 -- 0.50 seconds

-- Set to 'true' to enable the periodic anti-decay action, 'false' to disable it.
local periodicActionEnabled = true
-- Interval in SECONDS for the periodic action.
local periodicActionInterval = 300 -- Default: 600 5 minutes
-- ### END CONFIGURATION ###
local pauseMoveItem = 300 -- try it 300 or 400 depending on ping

-- ########## PERIODIC ACTION FUNCTION ##########
function ExecutePeriodicAction(containerSerial)
    Messages.Print("--- EXECUTING PERIODIC ACTION (ANTI-DECAY) ---", 100)
    Pause(messagePause)

    local bagToAction = Items.FindBySerial(containerSerial)
    
    if bagToAction ~= nil and bagToAction.OnGround then
        -- This is a full cycle (Ground -> Backpack -> Ground) to simulate complex interaction.
        -- Messages.Print("Action Step 1: Moving container to backpack...", 68)
        Player.PickUp(bagToAction.Serial, 1)
        Pause(pauseMoveItem)
        Player.DropInBackpack()
        Pause(pauseMoveItem)

        local bagInBackpack = Items.FindBySerial(targetContainerSerial)
        if bagInBackpack ~= nil then
            -- Messages.Print("Action Step 2: Moving container back to the ground...", 68)
            Player.PickUp(bagInBackpack.Serial, 1)
            Pause(pauseMoveItem)
            Player.DropOnGround()
            Pause(pauseMoveItem)
            Messages.Print("Periodic action finished. Container timer has been reset.", 68)
            Pause(messagePause)
        else
            Messages.Print("ACTION ERROR: Container moved to backpack, but could not be found to be moved back.", 34)
            Pause(messagePause)
        end
    else
        Messages.Print("Periodic action canceled: Container not on ground or not found.", 5)
        Pause(messagePause)
    end
    Messages.Print("----------------------------------------------------", 100)
    Pause(messagePause)
end
-- ##############################################

local function stealCooldown()
    for i = 9, 1, -1 do
        Messages.Overhead("Skill Cooldown " .. i .. "...", 55, Player.Serial)
        Pause(1000) -- 1 second pause
    end
end

-- ##############################################

-- --- SCRIPT START ---
Messages.Print(">> Starting Stealing Script  <<", 88)
Pause(messagePause)

-- 1. Find the player's backpack
-- Messages.Print("Finding player's backpack...", 6)
local playerBackpack = Items.FindByLayer(21)
if playerBackpack == nil then
    Messages.Print("FATAL ERROR: Could not find backpack (Layer 21). Stopping.", 34)
    Pause(messagePause)
    return
end
local playerBackpackSerial = playerBackpack.Serial
-- Messages.Print("Backpack found! Serial: " .. playerBackpackSerial, 68)

-- 2. Initialize the timer for the periodic action
local nextActionCycle = os.time() + periodicActionInterval
if periodicActionEnabled then
    Messages.Print("Periodic anti-decay action enabled. Interval: " .. periodicActionInterval .. " seconds.", 6)
    Pause(messagePause)
end

-- 3. Set up the stealing container on the ground
Messages.Print("--- Initializing container setup ---", 100)
Pause(messagePause)

local stealBag = Items.FindBySerial(targetContainerSerial)
if stealBag == nil then
    Messages.Print("FATAL ERROR: The container (" .. targetContainerSerial .. ") was not found. Stopping.", 34)
    Pause(messagePause)
    return
end
if stealBag.OnGround == false then
    Messages.Print("Container is in inventory. Placing it on the ground...", 6)
    Pause(messagePause)
    Player.PickUp(stealBag.Serial, 1)
    Pause(pauseMoveItem)
    Player.DropOnGround()
    Pause(pauseMoveItem)
end
Messages.Print("Container is ready and on the ground.", 68)
Pause(messagePause)

-- ########## MAIN STEALING LOOP ##########
while Skills.GetValue('Stealing') < 100 do
    
    -- If enabled, check the timer and execute the periodic action
    if periodicActionEnabled and os.time() >= nextActionCycle then
        ExecutePeriodicAction(targetContainerSerial)
        nextActionCycle = os.time() + periodicActionInterval -- Reset the timer
    end

    -- Messages.Print("-------------------------------------------------", 100)
    -- Messages.Print("Stealing Skill: " .. string.format("%.1f", Skills.GetValue('Stealing')))
    
    -- Reliable 2-step find method for the item to steal
    local itemToSteal = nil
    local allItemsToFind = Items.FindByFilter({ graphics = {itemIDToSteal} })
    for _, item in ipairs(allItemsToFind) do
        if item.RootContainer == targetContainerSerial then
            itemToSteal = item
            break
        end
    end
    
    if itemToSteal ~= nil then
        -- Stealing Logic
        Journal.Clear()
        Skills.Use('Stealing')
        if Targeting.WaitForTarget(1000) then
            Targeting.Target(itemToSteal.Serial)
            Pause(500)    
    -- If enabled, check the timer and execute the periodic action
    if periodicActionEnabled and os.time() >= nextActionCycle then
        ExecutePeriodicAction(targetContainerSerial)
        nextActionCycle = os.time() + periodicActionInterval -- Reset the timer
    end          
            if Journal.Contains("successfully steal") then
                Messages.Print("SUCCESS! Returning item...", 68)
                Journal.Clear()
                
                -- Reliable search for the item to return from inventory
                local itemToReturn = nil
                local allItemsInInventory = Items.FindByFilter({ graphics = {itemIDToSteal} })
                for _, item in ipairs(allItemsInInventory) do
                    if item.RootContainer ~= targetContainerSerial then
                        itemToReturn = item
                        break
                    end
                end
                
                if itemToReturn ~= nil then
                    Player.PickUp(itemToReturn.Serial, itemToReturn.Amount)
                    Pause(pauseMoveItem)
                    Player.DropInContainer(targetContainerSerial, itemToReturn.Amount)
                    Pause(pauseMoveItem)
                end
            elseif Journal.Contains("fail to steal") then
                Messages.Print("FAILURE detected.", 34)
                Pause(messagePause)
                Journal.Clear()
            end
        else
            Messages.Print("Targeting cursor did not appear.", 34)
            Pause(messagePause)
        end
            stealCooldown()

    else
        -- Replenishing Logic
        Messages.Print("Container empty. Replenishing items...", 5)
        Pause(messagePause)
        
        -- Reliable search for the restock item in the backpack
        local allItems = Items.FindByFilter({ graphics = { itemIDToSteal } })
        local itemToReplenish = nil

        for _, item in ipairs(allItems) do
            -- Look for item in backpack ONLY
            if item.RootContainer == Player.Serial then
                itemToReplenish = item
                break
            end
        end

        if itemToReplenish ~= nil then
            -- Move it to the target container
            Player.PickUp(itemToReplenish.Serial, itemToReplenish.Amount)
            Pause(pauseMoveItem)
            Player.DropInContainer(targetContainerSerial, itemToReplenish.Amount)
            Pause(pauseMoveItem)

            Messages.Overhead("Moved item to container.", 65, Player.Serial)
            Pause(messagePause)

            -- Optional: verify it's now in container
            local verify = Items.FindByID(itemIDToSteal)
            if verify and verify.RootContainer == targetContainerSerial then
                Messages.Overhead("Item confirmed in container.", 55, Player.Serial)
                Pause(messagePause)
            else
                Messages.Overhead("WARNING: Could not confirm item in container.", 34, Player.Serial)
                Pause(messagePause)
            end

        else
            Messages.Print("ERROR: No items found in backpack to replenish. Stopping.", 34)
            break
        end
    end
end

Messages.Print(">> GOAL REACHED! Stealing skill is 100. Script finished. <<", 88)
Pause(messagePause)
