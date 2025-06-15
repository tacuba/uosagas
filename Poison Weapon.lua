targetWeapon = 0x0F52 -- Currently set as a dagger

-- Function to check if your target weapon(s) is poisoned
local function checkPoison()
	local propertiesText = string.lower(examineWeapon.Properties)
	
	if string.find(propertiesText, "poison") then
        Messages.Overhead("The weapon is poisoned!", 68, Player.Serial) -- green
    else
        Messages.Overhead("The weapon is NOT poisoned.", 45, Player.Serial) -- red
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
		--if <------ Keep equipped if poisoned; unequip if not. 
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
	
	local weaponFilter = {onground = false, 
						  graphics = targetWeapon,
						  }
						  
    local weaponList = Items.FindByFilter(weaponFilter)
    
    local weaponCount = #weaponList
    local weaponName = weaponList[1].Name
    
    if weaponList and weaponCount-1 > 0 then
        Messages.Overhead("You have "..(weaponCount-1).." "..weaponName.."(s) available.", 55, Player.Serial)
        Pause(1000)
    else
    	Messages.Overhead("Warning: No more weapons in backpack!", 45, Player.Serial)
    end
end



findTargetWeapon()
countWeapons()
