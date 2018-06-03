CallToArmsFu = 		AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceDB-2.0", "AceHook-2.1")
local CallToArmsFu = CallToArmsFu

--Fubar plugin settings
CallToArmsFu.version = "1.0." .. string.sub("$Revision: 4 $", 12, -3)
CallToArmsFu.date = string.sub("$Date: 2018-05-31 18:53:43 -0400 (Thu, 31 May 2018) $", 8, 17)
CallToArmsFu.hasIcon = [[Interface\BattlefieldFrame\UI-Battlefield-Icon]]
CallToArmsFu.canHideText = true
CallToArmsFu.hasNoColor = true
CallToArmsFu.clickableTooltip = false
CallToArmsFu.cannotDetachTooltip = true
CallToArmsFu.hideWithoutStandby = false
CallToArmsFu.profileCode = true

CallToArmsFu.defaultPosition = "RIGHT"
CallToArmsFu.defaultMinimapPosition = 222

-- localization Lib
local L = AceLibrary("AceLocale-2.2"):new("FuBar_CTAFu") 

-- tool tip Lib
local tablet = AceLibrary("Tablet-2.0")

function CallToArmsFu:OnInitialize()
	-- Activate menu options to hide icon/text by activating "AceDB-2.0" DB
	self:RegisterDB("FuBar_CTAFuDB")
end

CallToArmsFu._messageCache = {}
-- Menu Items
CallToArmsFu.OnMenuRequest = {
	type = 'group',
	args = {
		cta = {
			type = "toggle",
			name = L["CallToArms"],
			desc = L["Open CallToArms"],
			get = function() return CTA_MainFrame:IsVisible() end,
			set = function() CTA_ToggleMainFrame() end,
		},
	}
}

function CallToArmsFu:OnTextUpdate()
	self:SetText(L["CTA"])
end

function CallToArmsFu:CacheMessage(message)
	if CTA_SavedVariables.showOnMinimap then
		local size = table.getn(self._messageCache)
		if size > 90 then
			for i=size,90,-1 do
				self._messageCache[i]=nil
			end
			table.setn(self._messageCache,89)
		end
		table.insert(self._messageCache,1,message)
	else
		for i,_ in ipairs(self._messageCache) do
			self._messageCache[i]=nil
		end
		table.setn(self._messageCache,0)
	end
end

-- keep self updated when activated?
function CallToArmsFu:OnEnable()
	self:CTAButton_Hide()
	self:Update()
	self:SecureHook(CTA_MinimapMessageFrame, "AddMessage", function(this, message, r,g,b)
		if string.find(message, "|Hplayer:") then
			CallToArmsFu:CacheMessage(date("%X"))
			CallToArmsFu:CacheMessage(message)
		end
	end)
	self:SecureHook(CTA_MinimapMessageFrame2, "AddMessage", function(this, message, r,g,b)
		if string.find(message, "^|cff") then
			CallToArmsFu:CacheMessage(message)
		end
	end)
end

function CallToArmsFu:CTAButton_Hide()
	if( CTA_MinimapIcon:IsVisible() ) then
		CTA_MinimapIcon:Hide()
	end
end

-- tool tip
function CallToArmsFu:OnTooltipUpdate()
	local messages = tablet:AddCategory(
      "columns", 3,
      "text" , L["Time"], "child_textR", 1, "child_textG", 0.8, "child_textB", 0, "child_justify", "LEFT",
      "text2", L["Player"], "child_text2R", 1, "child_text2G", 0.8, "child_text2B", 0, "child_justify2", "LEFT",
      "text3", L["Message"], "child_text3R", 1, "child_text3G", 0.8, "child_text3B", 0, "child_justify3", "RIGHT",      
      "hideBlankLine", true
  )
	for i=1, table.getn(self._messageCache), 3 do
		messages:AddLine(
			"text", self._messageCache[i+2] or "",
			"text2", self._messageCache[i+1] or "",
			"text3", self._messageCache[i] or ""
		)
	end
	tablet:SetTitle(L["CallToArms"])
	tablet:SetHint(L["Click to Open UI"])
end

-- when Clicked do this
function CallToArmsFu:OnClick()
  CTA_ToggleMainFrame()
end