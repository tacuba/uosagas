-- Global variables
targetWeapon = 0x0F52 -- Currently set as a dagger

-- Function to check if your target weapon(s) is poisoned
local function checkPoison()
	local propertiesText = string.lower(examineWeapon.Properties)
	
	if string.find(propertiesText, "poison") then
        Messages.Overhead("The weapon is poisoned!", 68, Player.Serial) -- green
        Pause(800)
    else
        Messages.Overhead("The weapon is NOT poisoned.", 45, Player.Serial) -- red
        Pause(800)
        
        -- Unequip weapon if not poisoned
        Messages.Overhead("Unequipping weapon.", 11, Player.Serial)
        Pause(800)
        Player.ClearHands("left")
        Pause(800)
    end
end

-- Check to see if you have your target weapon
local function findTargetWeapon()
	--First check your hands
	local equippedItem = Items.FindByLayer(1)
	if equippedItem and string.find(string.lower(equippedItem.Name or ""), "dagger") then
		Messages.Overhead("Target weapon is equipped!", 72, Player.Serial)
		Pause(800)
		examineWeapon = equippedItem
		checkPoison() 
		return equippedItem
	end

	--Next check your backpack
	local fishingPole = Items.FindByType(targetWeapon)
	if fishingPole and fishingPole.RootContainer == Player.Serial then
		Messages.Overhead("Target weapon found in backpack!", 72, Player.Serial)
		Pause(800)
	else
		Messages.Overhead("No target weapon found!", 33, Player.Serial)
		Pause(600)
		return nil
	end
end

--Count number of target weapons in your backpack
local function countWeapons()
	local weaponList = {}
	
	local weaponFilter = {onground = false, graphics = targetWeapon}
						  
    local weaponList = Items.FindByFilter(weaponFilter)
    
    local weaponCount = #weaponList
    local weaponName = weaponList[1].Name
    
    -- Count based on whether equipped or not
    if Items.FindByLayer(1) == nil then
    	Messages.Overhead("You have "..(weaponCount).." "..weaponName.."(s) available.", 55, Player.Serial)
        Pause(800)
    else
	    if weaponList and weaponCount-1 > 0 then
        	Messages.Overhead("You have "..(weaponCount-1).." "..weaponName.."(s) available.", 55, Player.Serial)
        	Pause(800)
    	else
    		Messages.Overhead("Warning: No more weapons in backpack!", 45, Player.Serial)
    		Pause(800)
    	end
    end
end	

-- Equip poisoned weapon
local function equipPoisonedWeapon()
	local propertiesText = string.lower(examineWeapon.Properties)
	
	if string.find(propertiesText, "poison") then
		Player.Equip(examineWeapon.Serial)
		--Equip(poisonWeapon.Serial, "RightHand")
		Messages.Overhead("Poisoned weapon equipped!", 68, Player.Serial)
	else
		Messages.Overhead("No poisoned weapons found in backpack.", 45, Player.Serial)
	end
end

local function equipFirstPoisonedWeapon()
    -- Add if statement to only do this if no weapon currently equipped.
    
    local filter = { onground = false, graphics = targetWeapon }

    local poisonWeaponList = Items.FindByFilter(filter)

    if not poisonWeaponList or #poisonWeaponList == 0 then
        Messages.Overhead("No weapons found in backpack.", 33, Player.Serial)
        return
    end

    for i = 1, #poisonWeaponList do
        local poisonWeaponMatch = poisonWeaponList[i]

        if poisonWeaponMatch.Properties and string.find(string.lower(poisonWeaponMatch.Properties), "poison") then
            Player.Equip(poisonWeaponMatch.Serial)
            Messages.Overhead("Poisoned weapon equipped!", 68, Player.Serial)
            return
        end
    end

    Messages.Overhead("No poisoned weapons found.", 45, Player.Serial)
end

findTargetWeapon()
countWeapons()
equipFirstPoisonedWeapon()
