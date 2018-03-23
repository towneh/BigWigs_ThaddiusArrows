--[[
--
-- BigWigs Strategy Module for Thaddius in Naxxramas.
--
-- Adds graphical, textual and sound warnings for what direction
-- you should move in when you get a polarity debuff in phase 2.
--
-- See readme.txt for more info
-- Many thanks to rabbit for all the help.
--
-- TODO
--  - Fix strategy broadcasting across multiple locales.
--
--]]

------------------------------
--      Are you local?      --
------------------------------

local myname = "Thaddius Arrows"
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..myname)
local BZ = AceLibrary("Babble-Zone-2.2")
local boss = AceLibrary("Babble-Boss-2.2")["Thaddius"]
local TL = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)
local feugen = AceLibrary("Babble-Boss-2.2")["Feugen"]
local stalagg = AceLibrary("Babble-Boss-2.2")["Stalagg"]

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "ThaddiusArrows",

	graphic_cmd = "garrows",
	graphic_name = "Graphical Arrows",
	graphic_desc = "Display Graphical Arrows",

	text_cmd = "tarrows",
	text_name = "Text Arrows",
	text_desc = "Display Text Arrows",

	sound_cmd = "sarrows",
	sound_name = "Sound Effects",
	sound_desc = "Play Direction Sound Effects",

	soundleft = "Interface\\AddOns\\BigWigs_ThaddiusArrows\\sounds\\GoLeftUS.wav",
	soundright = "Interface\\AddOns\\BigWigs_ThaddiusArrows\\sounds\\GoRightUS.wav",

	warnleft = "<----  GO LEFT  <---- GO LEFT <----",
	warnright = "---->  GO RIGHT  ----> GO RIGHT ---->",
	
} end )

L:RegisterTranslations("koKR", function() return {
	graphic_name = "시각적인 화살표",
	graphic_desc = "시각적인 화살표를 표시합니다.",

	text_name = "텍스트 방향",
	text_desc = "텍스트로 방향을 표시합니다.",

	sound_name = "효과음",
	sound_desc = "방향 음향 효과를 재생합니다.",

	warnleft = "<----  왼쪽으로  <---- 왼쪽으로 <----",
	warnright = "---->  오른쪽으로  ----> 오른쪽으로 ---->",
	
} end )

L:RegisterTranslations("deDE", function() return {
	graphic_name = "Grafiksymbole",
	graphic_desc = "Anzeigen der Grafiksymbole",

	text_name = "Textausgabe",
	text_desc = "Anzeige der Textausgabe",

	sound_name = "Soundausgabe",
	sound_desc = "Abspielen einer Soundausgabe",

	soundleft = "Interface\\AddOns\\BigWigs_ThaddiusArrows\\sounds\\GoLeftDE.wav",
	soundright = "Interface\\AddOns\\BigWigs_ThaddiusArrows\\sounds\\GoRightDE.wav",

	warnleft   = "<----  Geh Links  <---- Geh Links <----",
	warnright  = "---->  Geh Rechts  ----> Geh Rechts ---->",

} end )


----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsThaddiusArrows = BigWigs:NewModule(myname, "AceConsole-2.0")
BigWigsThaddiusArrows.synctoken = myname
BigWigsThaddiusArrows.zonename = BZ["Naxxramas"]
BigWigsThaddiusArrows.enabletrigger = { boss, feugen, stalagg }
BigWigsThaddiusArrows.toggleoptions = { "graphic", "text", "sound" }
BigWigsThaddiusArrows.revision = tonumber(string.sub("$Revision: 23229 $", 12, -3))
BigWigsThaddiusArrows.external = true

------------------------------
--      Initialization      --
------------------------------

function BigWigsThaddiusArrows:OnRegister()
	self.frameArrow = CreateFrame("Frame", nil, UIParent)
	self.texArrow = self.frameArrow:CreateTexture(nil, "BACKGROUND")
	-- Create the frame we will be using for the Arrow
	self.frameArrow:SetFrameStrata("MEDIUM")
	self.frameArrow:SetWidth(200)  -- Set These to whatever height/width is needed 
	self.frameArrow:SetHeight(200) -- for your Texture
	-- Apply Texture
	self.texArrow:SetTexture("Interface\\AddOns\\BigWigs_ThaddiusArrows\\textures\\arrow")	
	self.texArrow:SetAllPoints(self.frameArrow)
	self.frameArrow:SetAlpha(0.6)
	self.frameArrow:Hide()
end

function BigWigsThaddiusArrows:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("BigWigs_Message")
end

function BigWigsThaddiusArrows:OnSetup()
	self.previousCharge = nil
end
	
function BigWigsThaddiusArrows:OnDisable()
	if self.frameArrow then self.frameArrow:Hide() end
end

------------------------------
--      Event Handlers      --
------------------------------

function BigWigsThaddiusArrows:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, boss) then
		self.core:ToggleModuleActive(self, false)
	end
end

function BigWigsThaddiusArrows:PLAYER_REGEN_ENABLED()
	local go = BigWigsThaddius:Scan()
	local running = self:IsEventScheduled("ThaddiusArrows_CheckWipe")
	if not go then
		self:TriggerEvent("BigWigs_RebootModule", self)
	elseif not running then
		self:ScheduleRepeatingEvent("ThaddiusArrows_CheckWipe", self.PLAYER_REGEN_ENABLED, 2, self)
	end
end

function BigWigsThaddiusArrows:Direction( direction )
	if direction == "Left" then -- Left Arrow
		if self.db.profile.graphic then
			self.frameArrow.texture = self.texArrow
			self.texArrow:SetTexCoord(0, 1, 0, 1)
			self.frameArrow:SetPoint("CENTER", -250, 100)
			self.frameArrow:Show()
			self:ScheduleEvent(function() self.frameArrow:Hide() end, 4)
		end
		if self.db.profile.sound then
			PlaySoundFile(L["soundleft"])
		end
		if self.db.profile.text then
			self:TriggerEvent("BigWigs_Message", L["warnleft"], "Red", true)
		end
	elseif direction == "Right" then -- Right Arrow
		if self.db.profile.graphic then
			self.frameArrow.texture = self.texArrow
			self.texArrow:SetTexCoord(1, 0, 0, 1)
			self.frameArrow:SetPoint("CENTER", 250, 100)
			self.frameArrow:Show()
			self:ScheduleEvent(function() self.frameArrow:Hide() end, 4)
		end
		if self.db.profile.sound then
			PlaySoundFile(L["soundright"])
		end
		if self.db.profile.text then
			self:TriggerEvent("BigWigs_Message", L["warnright"], "Red", true)
		end
	end
end
	
function BigWigsThaddiusArrows:BigWigs_Message( msg )
	if msg == TL["nochange"] then
		self:Direction("Right")
		self.previousCharge = msg
	elseif msg == TL["poswarn"] or msg == TL["negwarn"] then
		if self.previousCharge then
			self:Direction("Left")
		else
			-- First charge
			if msg == TL["poswarn"] then
				self:Direction("Right")
			elseif msg == TL["negwarn"] then
				self:Direction("Left")
			end
		end
		self.previousCharge = msg
	end
end

