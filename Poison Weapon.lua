-- Step 1: Make sure you have access to your target weapon
-- Change the graphic ID to the weapon of your choice
-- Currently set as a dagger
local targetWeapon = Items.FindByType(0x0F52)
equippedWeapon = nil

-- Check if the target weapon is equipped or in backpack
local function findTargetWeapon()
    if not targetWeapon then
        Messages.Overhead("Target weapon not found!", 33, Player.Serial)
        Pause(600)
        return nil
    end

    -- Check if it's equipped (Layer 1 = One-handed weapon)
    local equippedItem = Items.FindByLayer(1)
    if equippedItem and equippedItem.Serial == targetWeapon.Serial then
        Messages.Overhead("Target weapon is equipped!", 70, Player.Serial)
        Pause(800)
        equippedWeapon = equippedItem
        return equippeItem
    end

    -- If not equipped, check if it's in backpack
    if targetWeapon.RootContainer == Player.Serial then
        Messages.Overhead("Target weapon found in backpack!", 70, Player.Serial)
        Pause(800)
        return targetWeapon
    else
        Messages.Overhead("Target weapon not equipped or in backpack!", 33, Player.Serial)
        Pause(600)
        return nil
    end
end

findTargetWeapon()

-- Step 2: If equipped; check if poisoned.
local function poisonCheckEquipped()
	Messages.Print('Found '..equippedWeapon.Name..'.')
	Messages.Overhead(equippedWeapon.Properties, 11, Player.Serial)
end

poisonCheckEquipped()