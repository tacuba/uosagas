-- List of fish
local BigFish = {
    0x09CC, -- Green Fish
    0x09CD, -- Red/Brown Fish
    0x09CE, -- Purple Fish
    0x09CF  -- Yellow Fish
	}

-- Map each graphic to a color name and hue
local FishColors = {
    [0x09CC] = { name = "Green", hue = 72 },
    [0x09CD] = { name = "Red/Brown", hue = 34 },
    [0x09CE] = { name = "Purple", hue = 15 },
    [0x09CF] = { name = "Yellow", hue = 55 }
	}

-- List of bladed weapons (for Fish Steaks)
local bladedWeapons = {
    0x0F52, -- Dagger
    0x13FF, -- Katana
    0x1401, -- Kryss
    0x143E, -- Viking Sword
    0x1441, -- Cutlass
    0x13B6, -- Butcher Knife
    0xFEA9, -- Skinning Knife
    0x0F43, -- Hatchet
	}

-- Check to see if you have a Fishing Pole
local function findFishingPole()
	--First check your hands
	local equippedItem = Items.FindByLayer(2)
	if equippedItem and string.find(string.lower(equippedItem.Name or ""), "fishing") then
		Messages.Overhead("Fishing pole is equipped!", 72, Player.Serial)
		Pause(800)
		return equippedItem
	end

	--Next check your backpack
	local fishingPole = Items.FindByType(0x0DC0)
	if fishingPole and fishingPole.RootContainer == Player.Serial then
		Messages.Overhead("Fishing pole found in backpack!", 72, Player.Serial)
		Pause(800)
		return fishingPole
	else
		Messages.Overhead("No fishing pole!", 33, Player.Serial)
		Pause(600)
		return nil
	end
end

-- Equip Fishing Pole, if needed 
local function equipFishingPole()
    local equipped = Items.FindByLayer(2)
    if equipped and string.find(string.lower(equipped.Name or ""), "fishing") then
        Messages.Overhead("Fishing pole is equipped!", 72, Player.Serial)
        Pause(800)
        return equipped
    end
    
    local pole = findFishingPole()
    
    if pole then
    	Player.ClearHands("both")
    	Messages.Overhead("Equipping fishing pole.", 60, Player.Serial)
    	Pause(1200)
    	Player.Equip(pole.Serial)
    	Pause(1200)
    	return pole
    else
    	Messages.Overhead("Exiting script!", 33, Player.Serial)
    	return nil
    end
end

-- Iterate through your fish
local function gettingHeavy()
	Messages.Overhead("Your backpack is heavy!", 44, Player.Serial)
	Pause(800)
	
	--Find fish in your backpack
	local fishFilter = {onground = false, graphics = BigFish}
    local fishList = Items.FindByFilter(fishFilter)

    if not fishList or #fishList == 0 then
        Messages.Overhead("No fish found in backpack!", 33, Player.Serial)
        Pause(1400)
        return
    end
    
    --Find a bladed weapon in your backpack
	local bladeFilter = {onground = false, graphics = bladedWeapons}
    local blades = Items.FindByFilter(bladeFilter)
    
    if not fishList or #fishList == 0 then
        Messages.Overhead("No blade to cut fish!", 33, Player.Serial)
        Pause(1000)
        return
    end    
    
    --Use the first blade located	
	if blades[1].Name ~= nil and blades[1].RootContainer == Player.Serial then
		blade = blades[1]
	else
		blade = blades[2]
	end

    if blade.RootContainer == Player.Serial then
    	Messages.Overhead("Found a "..blade.Name..".", 72, Player.Serial)
    end
    
    Pause(1200)
    
    if blade.RootContainer ~= Player.Serial then
    	Messages.Overhead("No blade found in backpack!", 33, Player.Serial)  
    		--Note: Error message thrown if blade leaves backpack; edge case to fix later.
    	return
    end
            
    --Cut each fish
    for _, item in ipairs(fishList) do
        if item.RootContainer == Player.Serial then
            local colorInfo = FishColors[item.Graphic] or { name = "Unknown", hue = 1150 }
            Messages.Overhead("Cut "..item.Amount.." "..colorInfo.name.." fish into steaks.", colorInfo.hue, Player.Serial)
            Pause(1000)
            Player.UseObject(blade.Serial)
            Targeting.WaitForTarget(600)
            Targeting.Target(item.Serial)
            Pause(1600)
        end
    end
Messages.Overhead("Finished making Fish Steaks.", 85, Player.Serial)
Pause(800)
Messages.Overhead("Let's get back to fishing!", 60, Player.Serial)
Pause(800)
Messages.Overhead("Warning! You must now select a water tile!", 44, Player.Serial)
Pause(800)
Messages.Overhead("Pick a new fishing spot!", 60, Player.Serial)
Pause(800)
Player.UseObject(righthand.Serial)
Pause(6000)
end

local function goneFishing()
	Pause(100)
	Messages.Overhead("Fishing...", 96, Player.Serial)
	Pause(2000)
	Messages.Overhead("Fishing...", 94, Player.Serial)
	Pause(2000)
	Messages.Overhead("Fishing...", 96, Player.Serial)
	Pause(2000)
	Messages.Overhead("Fishing...", 94, Player.Serial)
	Pause(2000)
end  

--Check for a Fishing Pole when one is no longer equipped.
local function checkFishingPole()
    -- Check your backpack
    local fishingPole = Items.FindByType(0x0DC0)

    if fishingPole and fishingPole.RootContainer == Player.Serial then
        Messages.Overhead("Fishing pole found in backpack!", 72, Player.Serial)
        Pause(800)
        Messages.Overhead("Equipping fishing pole.", 60, Player.Serial)
        Pause(1200)
        Player.Equip(fishingPole.Serial)
        Pause(1500)

        -- Check for Fishing Pole
        local newPole = Items.FindByLayer(2)

        if newPole then
            Player.UseObject(newPole.Serial)
            Pause(300)
            Targeting.TargetLast(SavedTargetPosition)
            goneFishing()
            return newPole
        else
            Messages.Overhead("Failed to equip fishing pole!", 33, Player.Serial)
            return nil
        end
    else
        Messages.Overhead("WARNING: You're out of fishing poles!", 33, Player.Serial)
        Pause(1200)
        Messages.Overhead("Exiting script!", 33, Player.Serial)
        return nil
    end
end

--Identify action items based on journal entries.
local function journalEntries()
	for i = 1, 20 do    
	    -- Successful casts
	    if Journal.Contains("You cannot fish here") then
	        Messages.Overhead("Unable to fish here", 34, Player.Serial)
	        Pause(800)
	        break
	    elseif Journal.Contains("You fish a while, but fail to catch anything.") then
	        Messages.Overhead("Failed to catch anything. Let's try again!", 56, Player.Serial)
	        Pause(800)
	        break
	    elseif Journal.Contains("You pull out an item") then
	        Messages.Overhead("Wohoo! Hope it was good!", 77, Player.Serial)
	        Pause(800)
	        break
	    end
	
		-- Unsuccessful subsequent casts
		if Journal.Contains("Target cannot be seen.") 
			or Journal.Contains("You need to be closer to the water to fish!")
			or Journal.Contains("The fish don't seem to be biting here.")
			then
			Messages.Overhead("Invalid fishing spot. Pick again!", 44, Player.Serial)
			Journal.Clear()
			Pause(800)
			righthand = Items.FindByLayer(2) -- In case you re-equipped fishing pole.
			Player.UseObject(righthand.Serial)
			Targeting.WaitForTarget(14000) -- Assumes you have selected a spot to fish!
			Pause(5500)
			goneFishing()
		end
		
		if Journal.Contains("You broke your fishing pole.") or
			Journal.Contains("You have worn") then
			Pause(600)
			checkFishingPole()
			Pause(1200)
		end
		
		if Journal.Contains("The fishing pole must be equipped") then
			Pause(600)
			Messages.Overhead("Where did the fishing pole go?", 44, Player.Serial)
			Pause(1200)
			checkFishingPole()
			Pause(500)
			break
		end
	end
	-- Unable to fish
	if Journal.Contains("The fish don't seem to be biting here.") then
	   Messages.Overhead("Nothing to fish! Pick a new spot.", 30, Player.Serial)
	   Pause(600)
	   Player.UseObject(righthand.Serial)
	   Pause(5000)
	end
end

local function checkErrors()
	for i = 1, 20 do
		-- Unsuccessful subsequent casts
		if Journal.Contains("Target cannot be seen.") 
			or Journal.Contains("You need to be closer to the water to fish!")
			--or Journal.Contains("The fish don't seem to be biting here.")
			then
			Messages.Overhead("Invalid fishing spot. Pick again!", 44, Player.Serial)
			Journal.Clear()
			Pause(800)
			Player.UseObject(righthand.Serial)
			Targeting.WaitForTarget(14000) -- Assumes you have selected a spot to fish!
			Pause(5500)
			goneFishing()
		end
		
		if Journal.Contains("The fish don't seem to be biting here.") then
			Messages.Overhead("No more fish here!", 44, Player.Serial)
			Pause(600)
			Messages.Overhead("Pick a new spot to fish.", 34, Player.Serial)
			Player.UseObject(righthand.Serial)
			Targeting.WaitingForTarget(14000) -- Assumes you have selected a spot to fish!
			Pause(5500)
			goneFishing()
		end
		
		if Journal.Contains("You broke your fishing pole.") or
			Journal.Contains("You have worn") then
			Pause(1200)
			checkFishingPole()
			Pause(500)
			break
		end
		
		if Journal.Contains("The fishing pole must be equipped") then
			Pause(600)
			Messages.Overhead("Where did the fishing pole go?", 44, Player.Serial)
			Pause(1200)
			Journal.Clear()
			checkFishingPole()
			Pause(500)
			break
		end
	end
end

local function main()
	righthand = Items.FindByLayer(2)
	if righthand == nil then
	else
		Journal.Clear()
		Messages.Overhead("Let's fish!", 85, Player.Serial)
		Pause(800)
		Messages.Overhead("Pick a spot to fish.", 11, Player.Serial)
		Pause(300)
		Player.UseObject(righthand.Serial)
		Targeting.WaitForTarget(14000) -- Assumes you have selected a spot to fish!
		Pause(5500)
		
		-- Unsuccessful initial cast
		if Journal.Contains("Target cannot be seen.") 
			or Journal.Contains("You need to be closer to the water to fish!")
			or Journal.Contains("The fish don't seem to be biting here.")
			then
			Messages.Overhead("Invalid fishing spot. Pick again!", 44, Player.Serial)
			Journal.Clear()
			Pause(800)
			main()
		
		--Successful initial (or looped) cast
		else
			goneFishing()
			Pause(600)
			while true do
			    local righthand = Items.FindByLayer(2)
			    if righthand ~= nil then
			    	checkErrors()
			        Messages.Overhead("Let's keep fishing!", 85, Player.Serial)
			        Player.UseObject(righthand.Serial)
			        Pause(300)
			        Targeting.TargetLast(SavedTargetPosition)
			        Pause(300)
			        Journal.Clear()
			        
			        -- Check journal to determine next path
			        journalEntries()
			    end
			    
			    -- Check for errors
			    checkErrors()
			    
			    --Reduce weight, if needed
			    if Player.Weight > Player.MaxWeight-10 then    
			    	Pause(800)
			    	gettingHeavy()
			    end
			    
			    --Check for edge case error
			    if Journal.Contains("That is not accessible.") then
			    	Pause(300)
			    	Player.UseObject(righthand.Serial)
			    	Messages.Overhead("Pick where to fish.", 55, Player.Serial)
			    	Pause(4500)
			    break
	
				if Journal.Contains("You broke your fishing pole.") then
					Pause(300)
					Messages.Overhead("Your fishing pole broke!", 44, Player.Serial)
					Pause(1200)
					checkFishingPole()
					Pause(1200)
				end
				
				-- Proceed with fishing
				else
			  		Pause(800)
			  	
			  		local fishingPole = Items.FindByType(0x0DC0)
    				if fishingPole == nil or fishingPole.RootContainer == nil then
        				Messages.Overhead("Fishing pole found in backpack!", 72, Player.Serial)
        				Messages.Overhead("WARNING: You're out of fishing poles!", 33, Player.Serial)
        				Pause(1200)
       					Messages.Overhead("Exiting script!", 33, Player.Serial)
        				return
        				
        			else
			  			checkErrors()
			  			Pause(5500)
			  			righthand = Items.FindByLayer(2)
			   			Pause(600)
			   			Messages.Overhead("Fishing last target position.", 11, Player.Serial)
			   			Pause(1200)
			 			checkErrors()
			 		
				 		-- Not sure why, but on occassion does not check for righthand above			 					 		
				 		righthand = Items.FindByLayer(2)  
			 		
				 		if righthand ~= nil then
				 			Player.UseObject(righthand.Serial)
				 			Pause(600)
				 			Targeting.TargetLast(SavedTargetPosition)
			 				goneFishing()
			 			else
			 				return
			 			end
			 		end
				end
				Pause(800)
				Messages.Overhead("Checking journal.", 311, Player.Serial)
				Pause(800)
				journalEntries()
				Pause(800)
			end
		end
	end
end

equipFishingPole()
main()