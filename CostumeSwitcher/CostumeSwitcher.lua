-----------------------------------------------------------------------------------------------
-- Client Lua Script for CostumeSwitcher
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
require "Window"
require "MatchingGame"
require "Apollo"
require "ChatSystemLib"
require "AbilityBook"
require "GameLib"
require "Unit"
require "Spell"
require "GroupLib"
require "CostumesLib"
-----------------------------------------------------------------------------------------------
-- CostumeSwitcher Module Definition
-----------------------------------------------------------------------------------------------
local CostumeSwitcher = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

local cost = 1
-- temp global

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function CostumeSwitcher:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
	
    self.bActive = false
	self.bFulltimeMode = false
	self.bRandomMode = false
	self.tActiveCostumes = {}
	self.tCostumeCheckList = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
	}
	
    return o
end

function CostumeSwitcher:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- CostumeSwitcher OnLoad
-----------------------------------------------------------------------------------------------
function CostumeSwitcher:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("CostumeSwitcher.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- CostumeSwitcher OnDocLoaded
-----------------------------------------------------------------------------------------------
function CostumeSwitcher:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "CostumeSwitcherForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
	
		Apollo.RegisterTimerHandler("CostumeSwitcherTimer", "OnCostumeSwitcherTimer", self)
	
		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
		Apollo.RegisterEventHandler("SystemKeyDown","OnSystemKeyDown", self)
		
		Apollo.RegisterSlashCommand("costumeswitcher", "OnCostumeSwitcherOn", self)
		Apollo.RegisterSlashCommand("cswitch", "OnCostumeSwitcherOn", self)
		Apollo.RegisterSlashCommand("csw", "OnCostumeSwitcherOn", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- CostumeSwitcher Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

function CostumeSwitcher:OnWindowManagementReady()
	for i, val in ipairs(self.tCostumeCheckList) do
		self.wndMain:FindChild("Costume" .. i):SetCheck(val)
	end
	self.wndMain:FindChild("FulltimeMode"):SetCheck(self.bFulltimeMode)
	self.wndMain:FindChild("RandomMode"):SetCheck(self.bRandomMode)
end

function CostumeSwitcher:OnSave(eType)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end

	tSave = {
		tSavedCostumes = self.tCostumeCheckList,
		bSavedFulltimeMode = self.bFulltimeMode,
		bSavedRandomMode = self.bRandomMode
	}
	
	return tSave
end

function CostumeSwitcher:OnRestore(eType, tSave)
	if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end

	if tSave.tSavedCostumes ~= nil then
		self.tCostumeCheckList = tSave.tSavedCostumes
		self.bFulltimeMode =  tSave.bSavedFulltimeMode
		self.bRandomMode = tSave.bSavedRandomMode
		self:SetActiveCostumes()
	end
end

-- on SlashCommand "/costumeswitcher"
function CostumeSwitcher:OnCostumeSwitcherOn(strSlash, strMessage)
	if strMessage == "" then
		self:SendSystemMessage("CostumeSwitcher Commands:")
		self:SendSystemMessage("/csw show 	- Shows the Menu")
		self:SendSystemMessage("/csw hide 	- Hides the Menu")
		self:SendSystemMessage("/csw start 	- Starts the Costume Switcher")
		self:SendSystemMessage("/csw stop 	- Stops the Costume Switcher")
		self:SendSystemMessage("/csw author 	- Author/Editor Info")
	elseif strMessage == "show" then
		self.wndMain:Invoke()
	elseif strMessage == "hide" then
		self.wndMain:Close()
	elseif strMessage == "start" then
		self:Activate()
		sendSystemMessage("Costume Switcher is now activated")
	elseif strMessage == "stop" then
		self:Deactivate()
		self:SendSystemMessage("Costume Switcher is now deactivated")
	elseif strMessage == "author" then
		self:SendSystemMessage("Author: Turquoise Color")
		self:SendSystemMessage("Realm : Entity")
		self:SendSystemMessage("Edited: Doctor House")
		self:SendSystemMessage("Realm : Entity")
	else 
		self:SendSystemMessage("Invalid Command")
	end
end

function CostumeSwitcher:OnOK()
	self:SetActiveCostumes()
	self.wndMain:Close()
	self:Activate()
	self:SendSystemMessage("Costume Switcher is now activated")
end

function CostumeSwitcher:SetActiveCostumes()
	self.tActiveCostumes = {}
	local j = 1
	for i, costume in ipairs(self.tCostumeCheckList) do
		if costume then
			self.tActiveCostumes[j] = i;
			j = j + 1
		end
	end
end

function CostumeSwitcher:OnCancel()
	self.wndMain:Close()
end

function CostumeSwitcher:OnSystemKeyDown(nKey)
	if self.bActive and not self.bFulltimeMode then
		if nKey == 87 or nKey == 16 or nKey == 65 or nKey == 68 or nKey == 83 then 
			if self.bRandomMode == false then
				CostumesLib.SetCostumeIndex(self.tActiveCostumes[cost])
				cost = cost+1
				if cost > #self.tActiveCostumes then
					cost = 1
				end
			elseif self.bRandomMode then
				CostumesLib.SetCostumeIndex(self.tActiveCostumes[math.random(#self.tActiveCostumes)])
			end
		end
	end
end

function CostumeSwitcher:OnCostumeSwitcherTimer()
	if #self.tActiveCostumes ~= 0 and self.bFulltimeMode then
		--CostumesLib.SetCostumeIndex(self.tActiveCostumes[math.random(#self.tActiveCostumes)])
		if self.bRandomMode == false then
			CostumesLib.SetCostumeIndex(self.tActiveCostumes[cost])
			cost = cost+1
			if cost > #self.tActiveCostumes then
				cost = 1
			end
		elseif self.bRandomMode then
			CostumesLib.SetCostumeIndex(self.tActiveCostumes[math.random(#self.tActiveCostumes)])
		end	
	end
end

function CostumeSwitcher:Activate()
	self.bActive = true
	Apollo.CreateTimer("CostumeSwitcherTimer", 0.60, true);
end

function CostumeSwitcher:Deactivate()
	self.bActive = false
	Apollo.StopTimer("CostumeSwitcherTimer")
end

function CostumeSwitcher:SendSystemMessage(strMessage)
	ChatSystemLib.PostOnChannel(2,"[CostumeSwitcher] " .. strMessage)
end

-----------------------------------------------------------------------------------------------
-- CostumeSwitcherForm Functions
-----------------------------------------------------------------------------------------------

function CostumeSwitcher:costumeCheck1()
	self.tCostumeCheckList[1] = true
end

function CostumeSwitcher:costumeUnCheck1()
	self.tCostumeCheckList[1] = false
end

function CostumeSwitcher:costumeCheck2()
	self.tCostumeCheckList[2] = true	
end

function CostumeSwitcher:costumeUnCheck2()
	self.tCostumeCheckList[2] = false
end

function CostumeSwitcher:costumeCheck3()
	self.tCostumeCheckList[3] = true
end

function CostumeSwitcher:costumeUnCheck3()
	self.tCostumeCheckList[3] = false
end

function CostumeSwitcher:costumeCheck4()
	self.tCostumeCheckList[4] = true
end

function CostumeSwitcher:costumeUnCheck4()
	self.tCostumeCheckList[4] = false
end

function CostumeSwitcher:costumeCheck5()
	self.tCostumeCheckList[5] = true
end

function CostumeSwitcher:costumeUnCheck5()
	self.tCostumeCheckList[5] = false
end

function CostumeSwitcher:costumeCheck6()
	self.tCostumeCheckList[6] = true
end

function CostumeSwitcher:costumeUnCheck6()
	self.tCostumeCheckList[6] = false
end

function CostumeSwitcher:FulltimeModeCheck()
	self.bFulltimeMode = true 
end

function CostumeSwitcher:FulltimeModeUncheck()
	self.bFulltimeMode = false
end

function CostumeSwitcher:RandomModeCheck()
	self.bRandomMode = true
end

function CostumeSwitcher:RandomModeUnCheck()
	self.bRandomMode = false
end

-----------------------------------------------------------------------------------------------
-- CostumeSwitcher Instance
-----------------------------------------------------------------------------------------------

local CostumeSwitcherInst = CostumeSwitcher:new()
CostumeSwitcherInst:Init()
