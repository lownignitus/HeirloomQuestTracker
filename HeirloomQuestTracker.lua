-- Title: Heirloom Quest Tracker
-- Author: LownIgnitus
-- Version: 1.1.4
-- Desc: Addon to track Misprinted Coins, Quest completions for free heiloom upgrades, and 1st heroic end boss kill of the day.

-- Globals
--local L = LibStub("AceLocale-3.0"):GetLocale("HeirloomQuestTracker")
HeirloomQuestTracker = LibStub("AceAddon-3.0"):NewAddon("HeirloomQuestTracker", "AceConsole-3.0", "AceEvent-3.0");

local ran = 0
local coinID = 122618
local coinIcon = 237282

local eventCoins = {
	{ id = 33226, name = "Tricky Treat", texture = 236546}, -- All Hallows End Candy
	{ id = 37829, name = "Brewfest Prize Tokens", texture = 133784}, -- Brewfest Prize Tokens
	{ id = 21100, name = "Coin of Ancestry", texture = 133858}, -- Elder Coins
	{ id = 23247, name = "Burning Blossom", texture = 135263}, -- Midsummer Fire Fest Blossoms
}

local eventCurrency = {
	{ id = 241}, -- Argent Tourny Seals
	{ id = 515}, -- DMF Tickets
--	{ id = 392}, -- Honor
	{ id = 1166}, -- TW Badges
}

for k, v in pairs(eventCurrency) do
	local info = C_CurrencyInfo.GetCurrencyInfo(v.id)
	v.name = info.name
	v.amount = info.quantity
	v.texture = info.iconFileID
--	print(v.name .. " " .. v.amount .. " " .. v.texture)
end

for k, v in pairs(eventCoins) do
	local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(v.id)
	if name ~= nil then
		v.name = name
	elseif texture ~= nil then
		v.texture = texture
	end
	v.amount = GetItemCount(v.id)
--	print(v.name .. " " .. v.amount .. " " .. v.texture)
end

local textures = {}
textures.alliance = "|T2565243:18|t"
textures.horde = "|T2565244:18|t"
textures.incomplete = "|T3532316:18|t"
textures.armorOne = "|T1097737:18|t"
textures.armorTwo = "|T1097738:18|t"
textures.weaponOne = "|T1097739:18|t"
textures.weaponTwo = "|T1097740:18|t"

--SLASH_HEIRLOOMQUESTTRACKER1 = '/HQT' or '/hqt'

local addonName = "HeirloomQuestTracker";
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
local LibQTip = LibStub('LibQTip-1.0')

local red = { r = 1.0, g = 0.2, b = 0.2 }
local blue = { r = 0.4, g = 0.4, b = 1.0 }
local green = { r = 0.2, g = 1.0, b = 0.2 }
local yellow = { r = 1.0, g = 1.0, b = 0.2 }
local gray = { r = 0.5, g = 0.5, b = 0.5 }
local black = { r = 0.0, g = 0.0, b = 0.0 }
local white = { r = 1.0, g = 1.0, b = 1.0 }
local frame

local HeirloomQuestTrackerLauncher = LDB:NewDataObject(addonName, {
	type = "data source",
	text = "Heirloom Quest Tracker",
	label = "HeirloomQuestTracker",
	tocname = "HeirloomQuestTracker",
	icon = coinIcon,
	OnClick = function(clickedframe, button)
		HeirloomQuestTracker:ShowOptions()
	end,
	OnEnter = function(self)
		frame = self
		HeirloomQuestTracker:ShowToolTip()
	end,
})

local defaults = {
	realm = {
		characters = {
		},
	},
	global = {
		realms = {
			},
		MinimapButton = {
			hide = false,
		},
		displayOptions = {
			showMinimapButton = true,
		},
		toonOptions = {
			useClass = true,
			levelRestriction = true,
			minimumLevel = 50,
			removeInactive = true,
			inactivityThreshold = 28,
			include = 3,
		},
		eventCurrencyOptions = {
			trackedCurrencies = {},
			trackedCoins = {},
		},
	},
};

local options = {
	handler = HeirloomQuestTracker,
	type = "group",
	args = {
		generalOptions = {
			handler = HeirloomQuestTracker,
			type = "group",
			name = "General Options",
			desc = "",
			order = 10,
			args = {
				about = {
					type = "group",
					inline = true,
					name = "|Cff00ff00Heirloom Quest Tracker|r",
					order = 1,
					args = {
						notes = {
							type = "description",
							name = GetAddOnMetadata(addonName, "Notes"),
							order = 1,
						},
						space1 = {
							type = "description",
							name = " ",
							order = 2,
						},
						version = {
							type = "description",
							name = "|cffffff00Version: |r" .. GetAddOnMetadata(addonName, "Version"),
							order = 3,
						},
						date= {
							type = "description",
							name = "|cffffff00Build Date: |r" .. GetAddOnMetadata(addonName, "X-Date"),
							order = 4,
						},
						author = {
							type = "description",
							name = "|cffffff00Author: |r" .. GetAddOnMetadata(addonName, "Author") .. " on " .. GetAddOnMetadata(addonName, "X-Author-Server"),
							order = 5,
						},
						category = {
							type = "description",
							name = "|cffffff00Category: |r" .. GetAddOnMetadata(addonName, "X-Category"),
							order = 6,
						},
						website = {
							type = "description",
							name = "|cffffff00Website: |r" .. GetAddOnMetadata(addonName, "X-Website"),
							order = 7,
						},
					},
				},
				displayOptions = {
					type = "group",
					inline = true,
					name = "Display Options",
					desc = "",
					order = 2,
					args = {
						showMinimapButton = {
							type = "toggle",
							name = "Minimap Button",
							desc = "Toggles the display of the minimap button.",
							get = "IsShowMinimapButton",
							set = "ToggleMinimapButton",
							order = 1,
						},
					},
				},
			},
		},
		toonOptions = {
			handler = HeirloomQuestTracker,
			type = "group",
			name = "Toon Options",
			desc = "",
			order = 20,
			args = {
				includeclassOptions = {
					type = "group",
					inline = true,
					name = "Show Class",
					desc = "",
					order = 1,
					args = {
						serverOptions = {
							type = "toggle",
							name = "Show Class Name",
							desc = "Show toon class name.",
							get = function(info)
								return HeirloomQuestTracker.db.global.toonOptions.useClass
							end,
							set = function(info, v)
								HeirloomQuestTracker.db.global.toonOptions.useClass = v
							end,
							order = 1,
						},
					},
				},
				includetoonOptions = {
					type = "group",
					inline = true,
					name = "Show Toons",
					desc = "",
					order = 2,
					args = {
						serverOptions = {
							type = "toggle",
							name = "On this Server",
							desc = "Show toons on this server.",
							get = function(info)
								return HeirloomQuestTracker.db.global.toonOptions.include == 2
							end,
							set = function(info, v)
								if v then
									HeirloomQuestTracker.db.global.toonOptions.include = 2
								else
									HeirloomQuestTracker.db.global.toonOptions.include = 1
								end
							end,
							order = 1,
						},
						accountOptions = {
							type = "toggle",
							name = "On this Account",
							desc = "Show Toons on this WoW account.",
							get = function(info)
								return HeirloomQuestTracker.db.global.toonOptions.include == 3
							end,
							set = function(info, v)
								if v then
									HeirloomQuestTracker.db.global.toonOptions.include = 3
								else
									HeirloomQuestTracker.db.global.toonOptions.include = 1
								end
							end,
							order = 2,
						},
					},
				},
				toonLevelOptions = {
					type = "group",
					inline = true,
					name = "Level Restriction",
					desc = "",
					order = 5,
					args = {
						enableLevelRestriction = {
							type = "toggle",
							name = "Enable",
							desc = "Enable Level Restriction",
							get = function(info)
								return HeirloomQuestTracker.db.global.toonOptions.levelRestriction
							end,
							set = function(info, v)
								HeirloomQuestTracker.db.global.toonOptions.levelRestriction = v
							end,
							order = 1,
						},
						minimumLevelOption = {
							type = "range",
							name = "Minimum Level",
							desc = "Show Toons this level and higher.",
							step = 1, min = 1, max = 60,
							get = function(info)
								return HeirloomQuestTracker.db.global.toonOptions.minimumLevel
							end,
							set = function(info, v)
								HeirloomQuestTracker.db.global.toonOptions.minimumLevel = v
							end,
							disabled = function()
								return not HeirloomQuestTracker.db.global.toonOptions.levelRestriction
							end,
							order = 2,
						},
					},
				},
				hideInactiveOptions = {
					type = "group",
					inline = true,
					name = "Hide Inactive Toons",
					desc = "",
					order = 6,
					args = {
						removeInactiveToons = {
							type = "toggle",
							name = "Enable",
							desc = "Enable hiding of inactive Toons.",
							get = function(info)
								return HeirloomQuestTracker.db.global.toonOptions.removeInactive
							end,
							set = function(info, v)
								HeirloomQuestTracker.db.global.toonOptions.removeInactive = v
							end,
							order = 1,
						},
						inactivityThresholdOption = {
							type = "range",
							name = "Iactivity Threshold in days",
							desc = "Hide a Toon after it has been inactive for X days.",
							step = 1, min = 7, max = 48,
							get = function(info)
								return HeirloomQuestTracker.db.global.toonOptions.inactivityThreshold
							end,
							set = function(info, v)
								HeirloomQuestTracker.db.global.toonOptions.inactivityThreshold = v
							end,
							disabled = function()
								return not HeirloomQuestTracker.db.global.toonOptions.removeInactive
							end,
							order = 2,
						},
					},
				},
				trackedToonOptions = {
					type = "group",
					inline = true,
					name = "Remove Tracked Toon",
					desc = "",
					order = 7,
					args = {
						serverSelect = {
							type = "select",
							name = "Server",
							desc = "Select Server to remove tracked Toon from.",
							values = function()
								local realmList = {}

								for realm in pairs(HeirloomQuestTracker.db.global.realms) do
									realmList[realm] = realm
								end

								return realmList
							end,
							get = function(info)
								return selectedRealm
							end,
							set = function(info, v)
								selectedRealm = v
								selectedToon = nil
							end,
							order = 1,
						},
						toonSelect = {
							type = "select",
							name = "Toon",
							desc = "Select tracked Toon to remove.",
							disabled = function()
								return selectedRealm == nil
							end,
							values = function()
								local list = {}
								local realmInfo = HeirloomQuestTracker.db.global.realms[selectedRealm]
								if realmInfo then
									local  toons = realmInfo.toons

									for k, v in pairs(toons) do
										list[k] = k
									end
								end
								return list
							end,
							get = function(info)
								return selectedToon
							end,
							set = function(info, v)
								selectedToon = v
							end,
							order = 2,
						},
						removeAction = {
							type = "execute",
							name = "Remove",
							desc = "Click to execute removal.",
							disabled = function()
								return selectedRealm == nil or selectedToon == nil
							end,
							func = function ()
								local realmInfo = HeirloomQuestTracker.db.global.realms[selectedRealm]
								local toonInfo = realmInfo.toons[selectedToon]
								local count = 0

								if not realmInfo then
									return
								end

								if toonInfo then
									realmInfo.toons[selectedToon] = nil
								end

								for k, v in pairs(realmInfo.toons) do
									count = count + 1
								end

								if count == 0 then
									HeirloomQuestTracker.db.global.realms[selectedRealm] = nil
								end
							end,
							order = 3,
						},
					},
				},
			},
		},
		eventCurrencyTracking = {
			type = "group",
			handler = HeirloomQuestTracker,
			name = "Event Currency Options",
			desc = "Set options for varions event coins and currencies",
			order = 40,
			args = {
				trackedCurrencies = {
					type = "multiselect",
					name = "Tracked Event Currencies",
					desc = "Select the optional Event currencies to track.",
					width = "full",
					values = "GetCurrencyOptions",
					order = 2,
					get = function(info, k)
						return HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCurrencies[eventCurrency[k].id]
					end,
					set = function(info, k, v)
						HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCurrencies[eventCurrency[k].id] = v
					end,
				},
				trackedCoins = {
					type = "multiselect",
					name = "Tracked Event Coins",
					desc = "Select the optional Event coins/items to track.",
					width = "full",
					values = "GetCoinOptions",
					order = 3,
					get = function(info, k)
						return HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCoins[eventCoins[k].id]
					end, 
					set = function(info, k, v)
						HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCoins[eventCoins[k].id] = v
					end,
				},
			},
		},
	},	
}

function HeirloomQuestTracker:GetDentedCoins() 
	local itemCount = GetItemCount(coinID, true)
--	print("itemCount: " .. itemCount)
	
	if not dentedCoins then
		dentedCoins = {}
		dentedCoins.count = {}
	else
		dentedCoins.count = 0
		dentedCoins.count = itemCount
	end

	return dentedCoins
end

function HeirloomQuestTracker:GetCurrencyOptions()
	itemslist = {}

	for k, v in pairs(eventCurrency) do
		itemslist[k] = "|T" .. v.texture .. ":0|t " .. v.name
	end

	return itemslist
end

function HeirloomQuestTracker:GetCoinOptions()
	itemslist = {}

	for k, v in pairs(eventCoins) do
		itemslist[k] = "|T" .. v.texture .. ":0|t " .. v.name
	end

	return itemslist
end

local function CleanupToons()
	local threshold = HeirloomQuestTracker.db.global.toonOptions.inactivityThreshold * (24 * 60 * 60)

	if not HeirloomQuestTracker.db.global.toonOptions.removeInactive or threshold == 0 then
		return
	end

	for realm in pairs(HeirloomQuestTracker.db.global.realms) do
		local realmInfo = self.db.global.realms[realm]
		local toons = nil

		if realmInfo then
			local toons = realmInfo.toons

			for k, v in pairs(toons) do
				if v.lastUpdate and v.lastUpdate < time() - threshold then
					v = nil
				end
			end
		end
	end
end

function HeirloomQuestTracker:DisplayToonInTooltip(toonName, toonInfo)
	local tooltip = HeirloomQuestTracker.tooltip
	local line = tooltip:AddLine()
	local factionIcon = ""
	local coins = 0
	local quest1 = ""
	local quest2 = ""
	local quest3 = ""
	local quest4 = ""

	if toonInfo.faction and toonInfo.faction == "Alliance" then
		factionIcon = textures.alliance
	elseif
		toonInfo.faction and toonInfo.faction == "Horde" then
		factionIcon = textures.horde
	end

	if HeirloomQuestTracker.db.global.toonOptions.useClass == true then
		tooltip:SetCell(line, 2, factionIcon .. " " .. toonName .. " (" .. toonInfo.class .. ")")
	else
		tooltip:SetCell(line, 2, factionIcon .. " " .. toonName)
	end

	if (toonInfo.dentedCoins) then
		coins = toonInfo.dentedCoins.count
	end

	tooltip:SetCell(line, 3, coins)

	column = 3

	for k, currency in pairs(eventCurrency) do
		if HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCurrencies[currency.id] then
			column = column + 1
			if (toonInfo.eventCurrencies and toonInfo.eventCurrencies.currency and toonInfo.eventCurrencies.currency[currency.id]) then
				if toonInfo.eventCurrencies.currency[currency.id] == nil then
					toonInfo.eventCurrencies.currency[currency.id] = 0
				end
				tooltip:SetCell(line, column, toonInfo.eventCurrencies.currency[currency.id], nil, "RIGHT")
			end
		end
	end

	for k, ecoins in pairs(eventCoins) do
		if HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCoins[ecoins.id] then
			column = column + 1
			if (toonInfo.eventCoin and toonInfo.eventCoin.ecoins and toonInfo.eventCoin.ecoins[ecoins.id]) then
				if toonInfo.eventCoin.ecoins[ecoins.id] == nil then
					toonInfo.eventCoin.ecoins[ecoins.id] = 0
				end
				tooltip:SetCell(line, column, toonInfo.eventCoin.ecoins[ecoins.id], nil, "RIGHT")
			end
		end
	end

	if (toonInfo.loomQuests) then
		quest1 = toonInfo.loomQuests.armorOne
		quest2 = toonInfo.loomQuests.armorTwo
		quest3 = toonInfo.loomQuests.weaponOne
		quest4 = toonInfo.loomQuests.weaponTwo
	end

	column = column + 1
	if quest1 == true then
		tooltip:SetCell(line, column, textures.armorOne)
	else
		tooltip:SetCell(line, column, textures.incomplete)
	end

	column = column + 1
	if quest2 == true then
		tooltip:SetCell(line, column, textures.armorTwo)
	else
		tooltip:SetCell(line, column, textures.incomplete)
	end

	column = column + 1
	if quest3 == true then
		tooltip:SetCell(line, column, textures.weaponOne)
	else
		tooltip:SetCell(line, column, textures.incomplete)
	end

	column = column + 1
	if quest4 == true then
		tooltip:SetCell(line, column, textures.weaponTwo)
	else
		tooltip:SetCell(line, column, textures.incomplete)
	end

	if toonInfo.class then
		local color = RAID_CLASS_COLORS[toonInfo.class]
		tooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	end
end

function HeirloomQuestTracker:IsShowMinimapButton(info)
	return not self.db.global.MinimapButton.hide
end

function HeirloomQuestTracker:ToggleMinimapButton(info, v)
	self.db.global.MinimapButton.hide = not v

	if self.db.global.MinimapButton.hide then
		LDBIcon:Hide(addonName)
	else
		LDBIcon:Show(addonName)
	end

	LDBIcon:Refresh(addonName)
	LDBIcon:Refresh(addonName)
end

function HeirloomQuestTracker:ShowOptions()
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function HeirloomQuestTracker:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HeirloomQuestTrackerDB", defaults, true)
	if not self.db then
		Print("Error: Database not loaded correctly.  Please exit out of WoW and delete HeirloomQuestTracker.lua found in: \\World of Warcraft\\_retail_\\WTF\\Account\\<<Account Name>>\\SavedVariables\\")
	end

	LDBIcon:Register(addonName, HeirloomQuestTrackerLauncher, self.db.global.MinimapButton)

	local hqtcfg = LibStub("AceConfig-3.0")
	hqtcfg:RegisterOptionsTable("Heirloom Quest Tracker", options)
	hqtcfg:RegisterOptionsTable("Heirloom Quest Tracker General", options.args.generalOptions)
	hqtcfg:RegisterOptionsTable("Heirloom Quest Tracker Toons", options.args.toonOptions)
	hqtcfg:RegisterOptionsTable("Heirloom Quest Tracker Currencies", options.args.eventCurrencyTracking)

	local hqtdia = LibStub("AceConfigDialog-3.0")
	self.optionsFrame = hqtdia:AddToBlizOptions("Heirloom Quest Tracker", "|cff00ff00Heirloom Quest Tracker")
	hqtdia:AddToBlizOptions("Heirloom Quest Tracker General", "General Options", "|cff00ff00Heirloom Quest Tracker")
	hqtdia:AddToBlizOptions("Heirloom Quest Tracker Toons", "Toons", "|cff00ff00Heirloom Quest Tracker")
	hqtdia:AddToBlizOptions("Heirloom Quest Tracker Currencies", "Currencies", "|cff00ff00Heirloom Quest Tracker")
end

local function ShowHeader(tooltip, marker, headerName)
	line = tooltip:AddHeader()

	if (marker) then
		tooltip:SetCell(line, 1, marker)
	end

	tooltip:SetCell(line, 2, headerName, nil, nil, nil, nil, nil, 50)
	tooltip:SetCellTextColor(line, 2, yellow.r, yellow.g, yellow.b)

	column = 2

	column = column + 1
	tooltip:SetCell(line, column, "|T" .. coinIcon .. ":0|t", nil, "CENTER")

	for k, currency in pairs(eventCurrency) do
		if HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCurrencies[currency.id] then
			column = column + 1
			tooltip:SetCell(line, column, "|T" .. currency.texture .. ":0|t", nil, "RIGHT")
		end
	end

	for k, ecoins in pairs(eventCoins) do
		if HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCoins[ecoins.id] then
			column = column + 1
			tooltip:SetCell(line, column, "|T" .. ecoins.texture .. ":0|t", nil, "RIGHT")
		end
	end

	column = column + 1
	tooltip:SetCell(line, column, "5 Coin Quest", "CENTER")
	tooltip:SetCellTextColor(line, column, yellow.r, yellow.g, yellow.b)

	column = column + 1
	tooltip:SetCell(line, column, "10 Coin Quest", "CENTER")
	tooltip:SetCellTextColor(line, column, yellow.r, yellow.g, yellow.b)

	column = column + 1
	tooltip:SetCell(line, column, "25 Coin Quest", "CENTER")
	tooltip:SetCellTextColor(line, column, yellow.r, yellow.g, yellow.b)

	column = column + 1
	tooltip:SetCell(line, column, "50 Coin Quest", "CENTER")
	tooltip:SetCellTextColor(line, column, yellow.r, yellow.g, yellow.b)

	return line
end

function HeirloomQuestTracker:DisplayServerInTooltip(realmName)
	local realmInfo = self.db.global.realms[realmName]
	local toons = nil
	local collapsed = false
	local epoch = time() - (HeirloomQuestTracker.db.global.toonOptions.inactivityThreshold * 24 * 60 * 60)

	if realmInfo then
		toons = realmInfo.toons
		collapsed = realmInfo.collapsed
	end

	local toonNames = {}
	local currentToonName = UnitName("player")
	local currentRealmName = GetRealmName()
	local tooltip = HeirloomQuestTracker.tooltip
	local levelRestriction = HeirloomQuestTracker.db.global.toonOptions.levelRestriction or false;

	if HeirloomQuestTracker.db.global.toonOptions.levelRestriction then
		minimumLevel = HeirloomQuestTracker.db.global.toonOptions.minimumLevel
		if not minimumLevel then minimumLevel = 90 end
	end

	if not toons then
		return
	end

	if HeirloomQuestTracker.db.global.toonOptions.levelRestriction == true then
		for k, v in pairs(toons) do
			local include = true
			if (realmName ~= currentRealmName or k ~= currentToonName) and 
			(not HeirloomQuestTracker.db.global.toonOptions.removeInactive or v.lastUpdate > epoch) and 
			(v.level >= minimumLevel) then
				table.insert(toonNames, k);
			end
		end
	else
		for k, v in pairs(toons) do
			local include = true
			if (realmName ~= currentRealmName or k ~= currentToonName) and 
			(not HeirloomQuestTracker.db.global.toonOptions.removeInactive or v.lastUpdate > epoch) then
				table.insert(toonNames, k);
			end
		end
	end

	if (table.getn(toonNames) == 0) then
		return
	end

	table.sort(toonNames)

	tooltip:AddSeparator(2, 0, 0, 0, 0)

	if not collapsed then
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-MinusButton-Up:16|t", realmName)

		tooltip:AddSeparator(3, 0, 0, 0, 0)

		for k, v in pairs(toonNames) do
			HeirloomQuestTracker:DisplayToonInTooltip(v, toons[v])
		end

		tooltip:AddSeparator(1, 1, 1, 1, 1.0)
	else
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-PlusButton-Up:16|t", realmName)
	end

	tooltip:SetCellTextColor(line, 2, yellow.r, yellow.g, yellow.b)
	tooltip:SetCellScript(line, 1, "OnMouseUp", RealmOnClick, realmName)
end

function RealmOnClick(cell, realmName)
	HeirloomQuestTracker.db.global.realms[realmName].collapsed = not HeirloomQuestTracker.db.global.realms[realmName].collapsed
	HeirloomQuestTracker:ShowToolTip()
end

function HeirloomQuestTracker:ShowToolTip()
	local tooltip = HeirloomQuestTracker.tooltip
	local toonName = UnitName("player")
	local toons = HeirloomQuestTracker.db.realm.toons
	local class, className = UnitClass("player")
	local includeToons = HeirloomQuestTracker.db.global.toonOptions.include or 3

	RequestLFDPlayerLockInfo()

	if LibQTip:IsAcquired("HeirloomQuestTrackerTooltip") and tooltip then
		tooltip:Clear()
	else
		local columnCount = 3

		for key, currency in pairs(eventCurrency) do
			if HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCurrencies[currency.id] then
				columnCount = columnCount + 1
			end
		end

		for key, ecoins in pairs(eventCoins) do
			if HeirloomQuestTracker.db.global.eventCurrencyOptions.trackedCoins[ecoins.id] then
				columnCount = columnCount + 1
			end
		end

		columnCount = columnCount + 4

		tooltip = LibQTip:Acquire("HeirloomQuestTrackerTooltip", columnCount, "CENTER", "LEFT", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER", "CENTER")
		HeirloomQuestTracker.tooltip = tooltip
	end

	line = tooltip:AddHeader(" ")
	tooltip:SetCell(1, 1, "|T" .. coinIcon .. ":16|t" .. "|cff00ff00 Heirloom Quest Tracker|r", nil, "LEFT", tooltip:GetColumnCount())
	tooltip:AddSeparator(6, 0, 0, 0, 0)
	ShowHeader(tooltip, nil, "Toon")
	tooltip:AddSeparator(6, 0, 0, 0, 0)

	local info = HeirloomQuestTracker:GetToonInfo()
	HeirloomQuestTracker:DisplayToonInTooltip(toonName, info)
	tooltip:AddSeparator(6, 0, 0, 0, 0)
	tooltip:AddSeparator(1, 1, 1, 1, 1.0)

	if includeToons > 1 then
		HeirloomQuestTracker:DisplayServerInTooltip(GetRealmName())
	end

	if includeToons == 3 then
		realmNames = {}

		for k, v in pairs(HeirloomQuestTracker.db.global.realms) do
			if (k ~= GetRealmName()) then
				table.insert(realmNames, k);
			end
		end

		for k, v in pairs(realmNames) do
			HeirloomQuestTracker:DisplayServerInTooltip(v)
		end
	end

	line = tooltip:AddLine(" ")
	tooltip:SetCell(tooltip:GetLineCount(), 1, "Click to open options menu", nil, "LEFT", tooltip:GetColumnCount())

	if (frame) then
		tooltip:SetAutoHideDelay(0.01, frame)
		tooltip:SmartAnchorTo(frame)
	end

	tooltip:UpdateScrolling()
	tooltip:Show()
end

function HeirloomQuestTracker:SaveToonInfo()
	local toonName = UnitName("player")
	local realmName = GetRealmName()

	if not self.db.global.realms then
		self.db.global.realms = {}
	end

	local realmInfo = self.db.global.realms[realmName]

	if not realmInfo then
		realmInfo = {}
		realmInfo.toons = {}
	end

	realmInfo.toons[toonName] = HeirloomQuestTracker:GetToonInfo()

	self.db.global.realms[realmName] = realmInfo
end

function HeirloomQuestTracker:GetToonInfo()
	local toonInfo = {}
	local class, className = UnitClass("player")
	local level = UnitLevel("player")
	local englishFaction, localizedFaction = UnitFactionGroup("player")

	toonInfo.lastUpdate = time()
	toonInfo.class = className
	toonInfo.level = level
	toonInfo.faction = englishFaction
	toonInfo.dentedCoins = HeirloomQuestTracker:GetDentedCoins()
	toonInfo.eventCurrencies = HeirloomQuestTracker:GetCurrencyStatus()
	toonInfo.eventCoin = HeirloomQuestTracker:GetEcoinsStatus()
	toonInfo.loomQuests = HeirloomQuestTracker:GetQuestsDone(englishFaction)

	return toonInfo
end

function HeirloomQuestTracker:GetCurrencyStatus()
	for k, v in pairs(eventCurrency) do
		local info = C_CurrencyInfo.GetCurrencyInfo(v.id)
		v.name = info.name
		v.amount = info.quantity
		v.texture = info.iconFileID
	--	print(v.name .. " " .. v.amount .. " " .. v.texture)
	end
	
	local eventCurrencies = {}

	eventCurrencies.currency = {}

	for k, v in pairs(eventCurrency) do
--		_, balance = C_CurrencyInfo.GetCurrencyInfo(v.id)
		eventCurrencies.currency[v.id] = v.amount
	end

	return eventCurrencies
end

function HeirloomQuestTracker:GetEcoinsStatus()
	for k, v in pairs(eventCoins) do
		local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(v.id)
		if name ~= nil then
			v.name = name
		elseif texture ~= nil then
			v.texture = texture
		end
		v.amount = GetItemCount(v.id)
	--	print(v.name .. " " .. v.amount .. " " .. v.texture)
	end
	
	local  eventCoin = {}

	eventCoin.ecoins = {}

	for k, v in pairs(eventCoins) do
		eventCoin.ecoins[v.id] = v.amount
	end

	return eventCoin 
end

function HeirloomQuestTracker:GetQuestsDone(englishFaction)
	local completed1 = ""
	local completed2 = ""
	local completed3 = ""
	local completed4 = ""

	-- QuestIDS
	local allianceQIDs = {
		38345,
		38394,
		38396,
		38402
	}
	local hordeQIDs = {
		38346,
		38395,
		38397,
		38404
	}
	local firstHeroicID = 37333


	if englishFaction == "Horde" then
		completed1 = C_QuestLog.IsQuestFlaggedCompleted(38346) -- 1 or nil edit: true or false
		
		completed2 = C_QuestLog.IsQuestFlaggedCompleted(38395)
		
		completed3 = C_QuestLog.IsQuestFlaggedCompleted(38397)
		
		completed4 = C_QuestLog.IsQuestFlaggedCompleted(38404)
	elseif englishFaction == "Alliance" then
		completed1 = C_QuestLog.IsQuestFlaggedCompleted(38345) -- 1 or nil edit: true or false

		completed2 = C_QuestLog.IsQuestFlaggedCompleted(38394)

		completed3 = C_QuestLog.IsQuestFlaggedCompleted(38396)

		completed4 = C_QuestLog.IsQuestFlaggedCompleted(38402)
	end

--	local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(firstHeroicID)
--	print("isCompleted: " .. isCompleted)
	if not loomQuests then
		loomQuests = {}
		loomQuests.armorOne = ""
		loomQuests.armorTwo = ""
		loomQuests.weaponOne = ""
		loomQuests.weaponTwo = ""
	end

	loomQuests.armorOne = completed1
	loomQuests.armorTwo = completed2
	loomQuests.weaponOne = completed3
	loomQuests.weaponTwo = completed4

	return loomQuests
end

function HeirloomQuestTracker:UPDATE_INSTANCE_INFO()
	HeirloomQuestTracker:SaveToonInfo()
	if LibQTip:IsAcquired("HeirloomQuestTrackerTooltip") and HeirloomQuestTracker.tooltip then
		HeirloomQuestTracker:ShowToolTip()
	end
end

function HeirloomQuestTracker:LFG_UPDATE_RANDOM_INFO()
	HeirloomQuestTracker:SaveToonInfo()
	if LibQTip:IsAcquired("HeirloomQuestTrackerTooltip") and HeirloomQuestTracker.tooltip then
		HeirloomQuestTracker:ShowToolTip()
	end
end

function HeirloomQuestTracker:LFG_COMPLETION_REWARD()
	RequestLFDPlayerLockInfo()
end

function HeirloomQuestTracker:PLAYER_ENTERING_WORLD()
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
end

function HeirloomQuestTracker:GET_ITEM_INFO_RECEIVED()
	if ran < 4 then
		HeirloomQuestTracker:SaveToonInfo()
		if LibQTip:IsAcquired("HeirloomQuestTrackerTooltip") and HeirloomQuestTracker.tooltip then
			HeirloomQuestTracker:ShowToolTip()
		end
		ran = ran +1
	else
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

function HeirloomQuestTracker:OnEnable()
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:RegisterEvent("LFG_COMPLETION_REWARD");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function HeirloomQuestTracker:OnDisable()
	self:UnregisterEvent("UPDATE_INSTANCE_INFO");
	self:UnregisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:UnregisterEvent("LFG_COMPLETION_REWARD");
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
end

--[[function SlashCmdList.HEIRLOOMQUESTTRACKER(msg)
	hqtUpdateData()
end]]