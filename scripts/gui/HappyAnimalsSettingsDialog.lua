HappyAnimalsSettingsDialog = {}
local HappyAnimalsSettingsDialog_mt = Class(HappyAnimalsSettingsDialog, ScreenElement)

function HappyAnimalsSettingsDialog.new(target, customMt)
    local self = ScreenElement.new(target, customMt or HappyAnimalsSettingsDialog_mt)

    self.startHourTexts = {}
    self.startHourValues = {}
    for hour = 8, 23 do
        self.startHourTexts[#self.startHourTexts + 1] = string.format("%02d:00", hour)
        self.startHourValues[#self.startHourValues + 1] = hour
    end

    return self
end

function HappyAnimalsSettingsDialog:onCreateStartHour(control)
    control:setTexts(self.startHourTexts)
end

function HappyAnimalsSettingsDialog:onOpen()
    HappyAnimalsSettingsDialog:superClass().onOpen(self)

    local selectedState = 1
    for index, hour in ipairs(self.startHourValues) do
        if hour == HappyAnimals.startHour then
            selectedState = index
            break
        end
    end

    self.startHourOption:setState(selectedState, true)
    self.fillStrawOption:setIsChecked(HappyAnimals.fillStraw, true)
    self.debugOption:setIsChecked(HappyAnimals.isDebug, true)
end

function HappyAnimalsSettingsDialog:onClickSave()
    local selectedState = self.startHourOption:getState()
    HappyAnimals.startHour = self.startHourValues[selectedState]
    HappyAnimals.fillStraw = self.fillStrawOption:getIsChecked()
    HappyAnimals.isDebug = self.debugOption:getIsChecked()
    HappyAnimals:saveSettings(g_currentMission.missionInfo)

    g_gui:closeDialogByName("HappyAnimalsSettingsDialog")
end

function HappyAnimalsSettingsDialog:onClickBack()
    g_gui:closeDialogByName("HappyAnimalsSettingsDialog")
end
