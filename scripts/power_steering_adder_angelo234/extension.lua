local jbeam_io = require('jbeam/io')

local M = {}

local settings_file_path = "settings/power_steering_adder_angelo234/settings.json";

local add_power_steering = false
local wait_to_add = false
local respawn_vehicle_flag = false

local function addPowerSteering()
  local veh_data = extensions.core_vehicle_manager.getPlayerVehicleData()
  if not veh_data then return end

  local all_slots = jbeam_io.getAvailableSlotMap(veh_data.ioCtx)
  if not all_slots then return end

  local chosen_parts = veh_data.chosenParts

  -- Find power steering slot and try to add power steering (adaptive steering first)
  local added_part = false

  for slot_name, curr_part in pairs(chosen_parts) do
    local parts_for_slot = all_slots[slot_name]

    if parts_for_slot then
      local added_power_steering = false

      if slot_name:match("power_steering") then
        -- If power steering not equiped, find parts to equip
        if not curr_part or curr_part == "" or curr_part == "none" then

          -- Priortize adaptive power steering over regular power steering
          for _, part_name in pairs(parts_for_slot) do
            if part_name:match("power_steering_adaptive") then
              chosen_parts[slot_name] = part_name
              added_part = true
              added_power_steering = true

            elseif part_name:match("power_steering") then
              if not added_power_steering then
                chosen_parts[slot_name] = part_name

                added_part = true
                added_power_steering = true
              end
            end
          end
        end
      end
    end
  end

  -- If power steering slot found then add it (resets vehicle to actually add it)
  if added_part then
    respawn_vehicle_flag = true
    extensions.core_vehicle_partmgmt.setPartsConfig(chosen_parts, true)
  end
end

local function onVehicleSpawned(vid)
  -- be:getPlayerVehicle(0) may not be ready yet
  -- so just enable flag that its ready to check
  -- if its not nil
  if add_power_steering and not respawn_vehicle_flag then
    wait_to_add = true
  end

  respawn_vehicle_flag = false
end

local function setAddPowerSteeringAutomatically(add)
  add_power_steering = add
end

local function onUpdate(dt)
  -- Check to see if be:getPlayerVehicle(0) is not nil
  -- and then add part
  if wait_to_add then
    local veh = be:getPlayerVehicle(0)

    if veh then
      wait_to_add = false
      addPowerSteering()
    end
  end
end

local function onExtensionLoaded()
  -- Load in current settings

  local json_data = readFile(settings_file_path)

  -- If settings file doesn't exist, create it
  if not json_data then
    local data = {}
    data["add_power_steering"] = true
    json_data = jsonEncode(data)

    writeFile(settings_file_path, json_data)
  end

  local data = jsonDecode(json_data)
  add_power_steering = data["add_power_steering"]
end

M.addPowerSteering = addPowerSteering
M.onVehicleSpawned = onVehicleSpawned
M.setAddPowerSteeringAutomatically = setAddPowerSteeringAutomatically
M.onUpdate = onUpdate
M.onExtensionLoaded = onExtensionLoaded

return M