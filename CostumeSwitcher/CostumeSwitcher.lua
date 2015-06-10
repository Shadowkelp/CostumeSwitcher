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
-- e.g. local kiExampleVariableMax = 999

local costumes = {};

local switchActive = false

local cost1 = false
local cost2 = false
local cost3 = false
local cost4 = false
local cost5 = false
local cost6 = false
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function CostumeSwitcher:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

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
	Apollo.RegisterEventHandler("SystemKeyDown","OnSystemKeyDown", self)
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

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("costumeswitcher", "OnCostumeSwitcherOn", self)
		Apollo.RegisterSlashCommand("Costumeswitcher", "OnCostumeSwitcherOn", self)
		Apollo.RegisterSlashCommand("CostumeSwitcher", "OnCostumeSwitcherOn", self)
		Apollo.RegisterSlashCommand("costumeSwitcher", "OnCostumeSwitcherOn", self)
		Apollo.RegisterSlashCommand("cs", "OnCostumeSwitcherOn", self)
		Apollo.RegisterSlashCommand("csstart", "Activate", self)
		Apollo.RegisterSlashCommand("csstop", "Deactivate", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- CostumeSwitcher Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/costumeswitcher"
function CostumeSwitcher:OnCostumeSwitcherOn(slash, message)
	--self.wndMain:Invoke() -- show the window
	
	if message == "show" then
		self.wndMain:Invoke()
		return
	end
	if message == "hide" then
		self.wndMain:Close()
		return
	end
	if message == "start" then
		CostumeSwitcher:Activate()
		sendSystemMessage("Costume Switcher is now active")
		return
	end
	if message == "stop" then
		CostumeSwitcher:Deactivate()
		sendSystemMessage("Costume Switcher deactivated")
		return
	end
	if message == "author" then
		sendSystemMessage("Author: Turquoise Color :: Realm : Entity")
		return
	end
	
	sendSystemMessage("CostumeSwitcher Commands:")
	sendSystemMessage("/cs show 	- shows the menu")
	sendSystemMessage("/cs hide 	- hides the menu")
	sendSystemMessage("/cs start 	- starts the costume switch")
	sendSystemMessage("/cs stop 	- stops the costume switch")
	sendSystemMessage("/cs author 	- shows the addon author")
end


-----------------------------------------------------------------------------------------------
-- CostumeSwitcherForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function CostumeSwitcher:OnOK()
	CostumeSwitcher:applyChecks()
	switchActive = true
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function CostumeSwitcher:OnCancel()

	self.wndMain:Close() -- hide the window
end

function CostumeSwitcher:OnSystemKeyDown(iKey)
	
	if switchActive then
		if iKey == 87 or iKey == 16 or iKey == 65 or iKey == 68 or iKey == 83 then 
		--CostumesLib.SetCostumeIndex(randomColor) 
		--randomColor = math.random(#costumes)
			if next(costumes) ~= nil then
			CostumesLib.SetCostumeIndex(costumes[ math.random( #costumes ) ] )
			end
		end
	end
end

function CostumeSwitcher:applyChecks()
	local tempCostumes = {}
	if cost1 == true then
		table.insert(tempCostumes, 1)
	end
	if cost2 == true then
		table.insert(tempCostumes, 2)
	end
	if cost3 == true then
		table.insert(tempCostumes, 3)
	end
	if cost4 == true then
		table.insert(tempCostumes, 4)
	end
	if cost5 == true then
		table.insert(tempCostumes, 5)
	end
	if cost6 == true then
		table.insert(tempCostumes, 6)
	end
	
	
	costumes = tempCostumes
end

function CostumeSwitcher:costumeCheck1()
	cost1 = true
end

function CostumeSwitcher:costumeUnCheck1()
	cost1 = false
	
end

function CostumeSwitcher:costumeCheck2()
	cost2 = true
	
end

function CostumeSwitcher:costumeUnCheck2()
	cost2 = false
	
end

function CostumeSwitcher:costumeCheck3()
	cost3 = true
	
end

function CostumeSwitcher:costumeUnCheck3()
	cost3 = false
	
end

function CostumeSwitcher:costumeCheck4()
	cost4 = true
	
end

function CostumeSwitcher:costumeUnCheck4()
	cost4 = false
	
end

function CostumeSwitcher:costumeCheck5()
	cost5 = true
	
end

function CostumeSwitcher:costumeUnCheck5()
	cost5 = false
	
end

function CostumeSwitcher:costumeCheck6()
	cost6 = true
	
end

function CostumeSwitcher:costumeUnCheck6()
	cost6 = false
	
end


function CostumeSwitcher:Activate()
	switchActive = true
end

function CostumeSwitcher:Deactivate()
	switchActive = false
end

function sendSystemMessage(message)
	ChatSystemLib.PostOnChannel(2,"[CostumeSwitcher] " .. message)
end
-----------------------------------------------------------------------------------------------
-- CostumeSwitcher Instance
-----------------------------------------------------------------------------------------------
local CostumeSwitcherInst = CostumeSwitcher:new()
CostumeSwitcherInst:Init()
