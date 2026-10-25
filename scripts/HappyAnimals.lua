HappyAnimals = {
    modName = g_currentModName,
    modDirectory = g_currentModDirectory,
    enabled = false,
    fillStraw = true,
    isDebug = false,
    startHour = 9,
    missionActive = false
}

local LOG_PREFIX = "[HappyAnimals]"
local SETTINGS_ROOT = "happyAnimals"
local SETTINGS_FILENAME = "happyAnimals.xml"
local SETTINGS_DIALOG_NAME = "HappyAnimalsSettingsDialog"
local HORSE_CARE_COST_PER_PERCENT = 10

local settingsSchema = XMLSchema.new("HappyAnimalsSettings")
settingsSchema:register(XMLValueType.BOOL, SETTINGS_ROOT .. "#enabled", "Whether the animal helpers are enabled", false)
settingsSchema:register(XMLValueType.BOOL, SETTINGS_ROOT .. "#fillStraw", "Whether helpers supply straw", true)
settingsSchema:register(XMLValueType.BOOL, SETTINGS_ROOT .. "#debug", "Whether debug mode is enabled", false)
settingsSchema:register(XMLValueType.INT, SETTINGS_ROOT .. "#startHour", "Hour at which helpers work", 9)

local function getSettingsFilename(missionInfo)
    if missionInfo == nil or missionInfo.savegameDirectory == nil or missionInfo.savegameDirectory == "" then
        return nil
    end

    return missionInfo.savegameDirectory .. "/" .. SETTINGS_FILENAME
end

local function debugLog(message, ...)
    if HappyAnimals.isDebug then
        Logging.info(LOG_PREFIX .. " " .. message, ...)
    end
end

function HappyAnimals:loadMap()
    self.missionActive = true

    if g_server ~= nil then
        self:loadSettings(g_currentMission.missionInfo)
        g_messageCenter:subscribe(MessageType.HOUR_CHANGED, self.hourChanged, self)

        addConsoleCommand("haRunHelpers", "Runs the HappyAnimals helpers immediately while debug mode is enabled", "consoleCommandRunHelpers", self)
        self.consoleCommandRegistered = true
    end

    if g_client ~= nil and not self.dialogLoaded then
        local dialog = HappyAnimalsSettingsDialog.new()
        g_gui:loadGui(Utils.getFilename("gui/HappyAnimalsSettingsDialog.xml", self.modDirectory), SETTINGS_DIALOG_NAME, dialog)
        self.dialogLoaded = true
    end

    Logging.info(LOG_PREFIX .. " Loaded")
end

function HappyAnimals:deleteMap()
    g_messageCenter:unsubscribeAll(self)
    g_inputBinding:removeActionEventsByTarget(self)

    if self.consoleCommandRegistered then
        removeConsoleCommand("haRunHelpers")
        self.consoleCommandRegistered = false
    end

    self.missionActive = false
end

function HappyAnimals:loadSettings(missionInfo)
    self.enabled = false
    self.fillStraw = true
    self.isDebug = false
    self.startHour = 9

    local filename = getSettingsFilename(missionInfo)
    if filename == nil then
        Logging.warning(LOG_PREFIX .. " Cannot load settings without a savegame directory")
        return
    end

    local xmlFile = XMLFile.loadIfExists("HappyAnimalsSettings", filename, settingsSchema)
    if xmlFile == nil then
        return
    end

    self.enabled = xmlFile:getBool(SETTINGS_ROOT .. "#enabled", self.enabled)
    self.fillStraw = xmlFile:getBool(SETTINGS_ROOT .. "#fillStraw", self.fillStraw)
    self.isDebug = xmlFile:getBool(SETTINGS_ROOT .. "#debug", self.isDebug)
    self.startHour = math.clamp(xmlFile:getInt(SETTINGS_ROOT .. "#startHour", self.startHour), 8, 23)
    xmlFile:delete()
end

function HappyAnimals:saveSettings(missionInfo)
    if not self.missionActive or g_server == nil then
        return
    end

    local filename = getSettingsFilename(missionInfo)
    if filename == nil then
        Logging.warning(LOG_PREFIX .. " Cannot save settings without a savegame directory")
        return
    end

    local xmlFile = XMLFile.create("HappyAnimalsSettings", filename, SETTINGS_ROOT, settingsSchema)
    if xmlFile == nil then
        Logging.error(LOG_PREFIX .. " Failed to create settings file '%s'", filename)
        return
    end

    xmlFile:setBool(SETTINGS_ROOT .. "#enabled", self.enabled)
    xmlFile:setBool(SETTINGS_ROOT .. "#fillStraw", self.fillStraw)
    xmlFile:setBool(SETTINGS_ROOT .. "#debug", self.isDebug)
    xmlFile:setInt(SETTINGS_ROOT .. "#startHour", self.startHour)
    xmlFile:save()
    xmlFile:delete()
end

function HappyAnimals.registerGlobalPlayerActionEvents(playerInputComponent)
    if not HappyAnimals.missionActive or playerInputComponent.player == nil or not playerInputComponent.player.isOwner then
        return
    end

    local _, toggleEventId = g_inputBinding:registerActionEvent(InputAction.HAPPY_ANIMALS_TOGGLE, HappyAnimals, HappyAnimals.toggleHelpers, false, true, false, true)
    if toggleEventId ~= nil then
        g_inputBinding:setActionEventTextPriority(toggleEventId, GS_PRIO_VERY_LOW)
        g_inputBinding:setActionEventTextVisibility(toggleEventId, true)
    end

    local _, settingsEventId = g_inputBinding:registerActionEvent(InputAction.HAPPY_ANIMALS_SETTINGS, HappyAnimals, HappyAnimals.openSettings, false, true, false, true)
    if settingsEventId ~= nil then
        g_inputBinding:setActionEventTextPriority(settingsEventId, GS_PRIO_VERY_LOW)
        g_inputBinding:setActionEventTextVisibility(settingsEventId, true)
    end
end

function HappyAnimals:toggleHelpers()
    self.enabled = not self.enabled
    self:showNotification(self.enabled and "HAPPY_ANIMALS_ENABLED" or "HAPPY_ANIMALS_DISABLED")
end

function HappyAnimals:openSettings()
    if self.dialogLoaded then
        g_gui:showDialog(SETTINGS_DIALOG_NAME)
    end
end

function HappyAnimals:showNotification(textKey)
    if g_currentMission == nil or g_currentMission.hud == nil then
        return
    end

    g_currentMission.hud:addSideNotification(
        FSBaseMission.INGAME_NOTIFICATION_OK,
        g_i18n:getText(textKey),
        nil,
        GuiSoundPlayer.SOUND_SAMPLES.TRANSACTION
    )
end

function HappyAnimals:hourChanged()
    if not self.enabled or g_server == nil then
        return
    end

    local isSleeping = g_sleepManager ~= nil and g_sleepManager:getIsSleeping()
    local isWorkTime = g_currentMission.environment.currentHour == self.startHour or self.isDebug
    if isWorkTime and not isSleeping then
        self:runHelpers()
    end
end

function HappyAnimals:runHelpers()
    if g_server == nil or g_currentMission == nil then
        return 0
    end

    local farmId = g_currentMission:getFarmId()
    local husbandries = g_currentMission.husbandrySystem.clusterHusbandries
    local totalCosts = 0

    self:showNotification("HAPPY_ANIMALS_STARTED")

    for _, clusterHusbandry in pairs(husbandries) do
        local placeable = clusterHusbandry.placeable
        if placeable ~= nil and placeable:getOwnerFarmId() == farmId then
            local costs = self:careForHusbandry(placeable, farmId)
            if costs > 0 then
                g_currentMission:addMoney(-costs, farmId, MoneyType.ANIMAL_UPKEEP, true, true)
                totalCosts = totalCosts + costs
            end
        end
    end

    self:showNotification("HAPPY_ANIMALS_DONE")
    debugLog("Helpers completed for farm %d at a cost of %.2f", farmId, totalCosts)

    return totalCosts
end

function HappyAnimals:careForHusbandry(placeable, farmId)
    local costs = self:fillFood(placeable, farmId)
    costs = costs + self:fillWater(placeable, farmId)

    if self.fillStraw then
        costs = costs + self:fillStrawForHusbandry(placeable, farmId)
    end

    if placeable.getAnimalTypeIndex ~= nil and placeable:getAnimalTypeIndex() == AnimalType.HORSE then
        costs = costs + self:careForHorses(placeable)
    end

    return costs
end

function HappyAnimals:fillFood(placeable, farmId)
    if placeable.getAnimalTypeIndex == nil or placeable.getFreeFoodCapacity == nil or placeable.addFood == nil then
        return 0
    end

    local animalFood = g_currentMission.animalFoodSystem:getAnimalFood(placeable:getAnimalTypeIndex())
    if animalFood == nil or animalFood.groups == nil then
        return 0
    end

    local freeCapacity = 0
    local totalEatWeight = 0
    for _, foodGroup in pairs(animalFood.groups) do
        local fillTypeIndex = foodGroup.fillTypes ~= nil and foodGroup.fillTypes[1] or nil
        if fillTypeIndex ~= nil then
            freeCapacity = math.max(freeCapacity, placeable:getFreeFoodCapacity(fillTypeIndex))
            totalEatWeight = totalEatWeight + (foodGroup.eatWeight or 0)
        end
    end

    if freeCapacity <= 0 or totalEatWeight <= 0 then
        return 0
    end

    local costs = 0
    for _, foodGroup in pairs(animalFood.groups) do
        local fillTypeIndex = foodGroup.fillTypes ~= nil and foodGroup.fillTypes[1] or nil
        local eatWeight = foodGroup.eatWeight or 0

        if fillTypeIndex ~= nil and eatWeight > 0 then
            local requested = freeCapacity * eatWeight / totalEatWeight
            local applied = placeable:addFood(farmId, requested, fillTypeIndex, nil, nil, nil) or 0
            local pricePerLiter = g_currentMission.economyManager:getPricePerLiter(fillTypeIndex)
            costs = costs + applied * pricePerLiter
            debugLog("Added %.1f l of %s food", applied, g_fillTypeManager:getFillTypeNameByIndex(fillTypeIndex))
        end
    end

    return costs
end

function HappyAnimals:fillWater(placeable, farmId)
    local spec = placeable.spec_husbandryWater
    if spec == nil or spec.automaticWaterSupply then
        return 0
    end

    if spec.fillType == nil then
        Logging.warning(LOG_PREFIX .. " Husbandry '%s' has no configured water fill type", placeable:getName())
        return 0
    end

    local freeCapacity = placeable:getHusbandryFreeCapacity(spec.fillType)
    if freeCapacity > 0 then
        local applied = placeable:addHusbandryFillLevelFromTool(farmId, freeCapacity, spec.fillType, nil, nil, nil) or 0
        debugLog("Added %.1f l of water", applied)
    end

    return 0
end

function HappyAnimals:fillStrawForHusbandry(placeable, farmId)
    local spec = placeable.spec_husbandryStraw
    if spec == nil then
        return 0
    end

    if spec.inputFillType == nil then
        Logging.warning(LOG_PREFIX .. " Husbandry '%s' has no configured straw fill type", placeable:getName())
        return 0
    end

    local freeCapacity = placeable:getHusbandryFreeCapacity(spec.inputFillType)
    if freeCapacity <= 0 then
        return 0
    end

    local applied = placeable:addHusbandryFillLevelFromTool(farmId, freeCapacity, spec.inputFillType, nil, nil, nil) or 0
    local pricePerLiter = g_currentMission.economyManager:getPricePerLiter(spec.inputFillType)
    debugLog("Added %.1f l of straw", applied)

    return applied * pricePerLiter
end

function HappyAnimals:careForHorses(placeable)
    if placeable.getClusters == nil then
        return 0
    end

    local costs = 0
    for _, horse in ipairs(placeable:getClusters()) do
        if horse.riding ~= nil and horse.fitness ~= nil and horse.dirt ~= nil then
            costs = costs + (100 - horse.riding) * HORSE_CARE_COST_PER_PERCENT
            costs = costs + (100 - horse.fitness) * HORSE_CARE_COST_PER_PERCENT
            horse.riding = 100
            horse.fitness = 100
            horse.dirt = 0
        end
    end

    return costs
end

function HappyAnimals:consoleCommandRunHelpers()
    if not self.isDebug then
        return "HappyAnimals debug mode is disabled"
    end

    local costs = self:runHelpers()
    return string.format("HappyAnimals helpers completed; cost %.2f", costs)
end

local function saveSettings(missionInfo)
    HappyAnimals:saveSettings(missionInfo)
end

FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, saveSettings)
PlayerInputComponent.registerGlobalPlayerActionEvents = Utils.appendedFunction(PlayerInputComponent.registerGlobalPlayerActionEvents, HappyAnimals.registerGlobalPlayerActionEvents)

addModEventListener(HappyAnimals)
