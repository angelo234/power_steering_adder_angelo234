local jbeamIO = require('jbeam/io')

local M = {}

local settingsFilePath = "settings/power_steering_adder_angelo234/settings.json";

local addPowerSteeringFlag = false
local waitToAdd = false
local respawnVehicleFlag = false

local function addPowerSteeringRec(slotEntry)
  local slotId = slotEntry.id
  local chosenPartName = slotEntry.chosenPartName
  local addedPowerSteering = false

  if slotId:match("power_steering") then
    -- If power steering not equiped, find parts to equip
    if not chosenPartName or chosenPartName == "" or chosenPartName == "none" then

      -- Priortize adaptive power steering over regular power steering
      for _, partName in ipairs(slotEntry.suitablePartNames) do
        if partName:match("power_steering_adaptive") then
          slotEntry.chosenPartName = partName
          addedPowerSteering = true

        elseif partName:match("power_steering") then
          if not addedPowerSteering then
            slotEntry.chosenPartName = partName
            addedPowerSteering = true
          end
        end
      end
    end
  end

  if addedPowerSteering then
    return true
  end

  for _, child in pairs(slotEntry.children or {}) do
    local res = addPowerSteeringRec(child)
    if res then
      return true
    end
  end

  return false
end

local function addPowerSteering()
  local vehData = core_vehicle_manager.getPlayerVehicleData()
  if not vehData then return end

  local addedPowerSteering = addPowerSteeringRec(vehData.config.partsTree)

  -- If power steering slot found then add it (resets vehicle to actually add it)
  if addedPowerSteering then
    respawnVehicleFlag = true
    core_vehicle_partmgmt.setPartsTreeConfig(vehData.config.partsTree, true)
    log('D', 'addPowerSteering', 'Added power steering to vehicle')
  end
end

local function onVehicleSpawned(vid)
  -- be:getPlayerVehicle(0) may not be ready yet
  -- so just enable flag that its ready to check
  -- if its not nil
  if addPowerSteeringFlag and not respawnVehicleFlag then
    waitToAdd = true
  end

  respawnVehicleFlag = false
end

local function setAddPowerSteeringAutomatically(add)
  addPowerSteeringFlag = add
end

local function onUpdate(dt)
  -- Check to see if be:getPlayerVehicle(0) is not nil
  -- and then add part
  if waitToAdd then
    local veh = be:getPlayerVehicle(0)

    if veh then
      waitToAdd = false
      addPowerSteering()
    end
  end
end

local function onExtensionLoaded()
  -- Load in current settings

  local jsonData = readFile(settingsFilePath)

  -- If settings file doesn't exist, create it
  if not jsonData then
    local data = {}
    data["add_power_steering"] = true
    jsonData = jsonEncode(data)

    writeFile(settingsFilePath, jsonData)
  end

  local data = jsonDecode(jsonData)
  addPowerSteeringFlag = data["add_power_steering"]
end

local function onInit()
  setExtensionUnloadMode(M, "manual")
end

M.addPowerSteering = addPowerSteering
M.onVehicleSpawned = onVehicleSpawned
M.setAddPowerSteeringAutomatically = setAddPowerSteeringAutomatically
M.onUpdate = onUpdate
M.onExtensionLoaded = onExtensionLoaded
M.onInit = onInit

return M