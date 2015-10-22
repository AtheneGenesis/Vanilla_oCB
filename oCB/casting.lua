local BS = AceLibrary("Babble-Spell-2.2")
local elapsed = 0

-- dIsInSeconds is passed by custom clients if they want to save on maths
-- dontRegister is passed by custom clients if they need to call Stop/Failed/Delayed manually
function oCB:SpellStart(s, d, dIsInSeconds, dontRegister)
	self:Debug(string.format("SpellStart - %s | %s (%s)%s", s, d, dIsInSeconds and "s" or "ms", dontRegister and " | Not Registering" or ""))
    
	if s == "" then
		s = (getglobal("GameTooltipTextLeft1"):GetText() or "")
	end
	
    if not dontRegister then
        self:RegisterEvent("SPELLCAST_STOP", "SpellStop")
        self:RegisterEvent("SPELLCAST_INTERRUPTED","SpellFailed")
        self:RegisterEvent("SPELLCAST_FAILED", "SpellFailed")
        self:RegisterEvent("SPELLCAST_DELAYED", "SpellDelayed")
    end
	
	local c = self.db.profile.Colors.Casting
		
	self.startTime = GetTime()
    
    if not dIsInSeconds then
        d = d/1000
    end
	self.maxValue = self.startTime + d
	
	self.frames.CastingBar.Bar:SetStatusBarColor(c.r, c.g, c.b)
	self.frames.CastingBar.Bar:SetMinMaxValues(self.startTime, self.maxValue )
	self.frames.CastingBar.Bar:SetValue(0)
	self.frames.CastingBar.Spell:SetText(s)
	self.frames.CastingBar:SetAlpha(1)
	self.frames.CastingBar.Time:SetText("")
	self.frames.CastingBar.Delay:SetText("")
	
	if oCBCastSent then
		local mylatency = math.floor((GetTime()-oCBCastSent)*1000)
		local w = math.floor(self.frames.CastingBar.Bar:GetWidth())
		mylatency = mylatency
		self.frames.CastingBar.Latency:SetText(mylatency.."ms")
		self.frames.CastingBar.LagBar:SetStatusBarColor(1, 0, 0, 0.5)
		self.frames.CastingBar.LagBar:SetMinMaxValues(0, 100)
		self.frames.CastingBar.LagBar:SetValue(100)
		local lagw = w - (w*(self.maxValue-self.startTime-(mylatency/1000))/(self.maxValue-self.startTime))
		if lagw >= w then lagw = w end
		self.frames.CastingBar.LagBar:SetWidth(lagw)
	else
		self.frames.CastingBar.Latency:SetText("")
		self.frames.CastingBar.LagBar:SetValue(0)
	end
	
	self.SpellIcon = BS:GetSpellIcon(s)
	self.ItemIcon = self:FindItemIcon(s)
	if not self.ItemIcon then self.ItemIcon = self:FindItemIcon(getglobal("GameTooltipTextLeft1"):GetText()) end
	if self.SpellIcon then
		self.frames.CastingBar.Texture:SetTexture(self.SpellIcon)
		self.frames.CastingBar.Icon:Show()
	elseif string.find(s, "^Recette") or string.find(s, "^Plans :") or string.find(s, "^Patron :") or string.find(s, "^Formule :") then
		self.frames.CastingBar.Texture:SetTexture("Interface\\AddOns\\oCB\\Icons\\Spell_Arcane_MindMastery")
		self.frames.CastingBar.Icon:Show()
		self.frames.CastingBar.Latency:SetText("")
		self.frames.CastingBar.LagBar:SetWidth(0)
	elseif string.find(s, "Fonte") then
		self.frames.CastingBar.Texture:SetTexture("Interface/Icons/spell_fire_flameblades")
		self.frames.CastingBar.Icon:Show()
		self.frames.CastingBar.Latency:SetText("")
		self.frames.CastingBar.LagBar:SetValue(0)
	elseif self.ItemIcon then
		self.frames.CastingBar.Texture:SetTexture(self.ItemIcon)
		self.frames.CastingBar.Icon:Show()
		self.frames.CastingBar.Latency:SetText("")
		self.frames.CastingBar.LagBar:SetValue(0)
	elseif s == "Invocation d'un char d'assaut qiraji jaune" then
		self.frames.CastingBar.Texture:SetTexture("Interface/Icons/INV_Misc_QirajiCrystal_01")
		self.frames.CastingBar.Icon:Show()
		self.frames.CastingBar.Latency:SetText("")
		self.frames.CastingBar.LagBar:SetValue(0)
	else
		self.frames.CastingBar.Icon:Hide()
	end
	
	self.holdTime 	= 0
	self.delay 		= 0
	self.casting 		= 1
	self.fadeOut 	= nil
	
	self.frames.CastingBar:Show()
	self.frames.CastingBar.Spark:Show()
end

-- Arg is for custom clients
function oCB:SpellStop(dontUnregister)
	self:Debug("SpellStop - Stopping cast")		
	local c = self.db.profile.Colors.Complete
	
	self.frames.CastingBar.Bar:SetValue(self.maxValue)
	
	self.frames.CastingBar.Latency:SetText("")
	self.frames.CastingBar.LagBar:SetValue(0)
	
	if not self.channeling then
		self.frames.CastingBar.Bar:SetStatusBarColor(c.r, c.g, c.b)
		self.frames.CastingBar.Spark:Hide()
	end
	
	self.delay 		= 0
	self.casting 		= nil
	self.fadeOut 	= 1
	
	oCBCastSent = nil
	oCBIcon = nil
	
    if not dontUnregister then
        self:UnregisterEvent("SPELLCAST_STOP")
        self:UnregisterEvent("SPELLCAST_FAILED")
        self:UnregisterEvent("SPELLCAST_INTERRUPTED")
        self:UnregisterEvent("SPELLCAST_DELAYED")
    end
end

function oCB:SpellFailed(dontUnregister)
	local c = self.db.profile.Colors.Failed

	self.frames.CastingBar.Bar:SetValue(self.maxValue)
	self.frames.CastingBar.Bar:SetStatusBarColor(c.r, c.g, c.b)
	self.frames.CastingBar.Spark:Hide()
	
	self.frames.CastingBar.Latency:SetText("")
	self.frames.CastingBar.LagBar:SetValue(0)
	
	if (event == "SPELLCAST_FAILED") then
		self.frames.CastingBar.Spell:SetText(FAILED)
	else
		self.frames.CastingBar.Spell:SetText(INTERRUPTED)
	end
	
	self.casting 		= nil
	self.channeling 	= nil
	self.fadeOut	= 1
	self.holdTime = GetTime() + 1
	
	oCBCastSent = nil
	oCBIcon = nil
    
    if not dontUnregister then
        self:UnregisterEvent("SPELLCAST_STOP")
        self:UnregisterEvent("SPELLCAST_FAILED")
        self:UnregisterEvent("SPELLCAST_INTERRUPTED")
        self:UnregisterEvent("SPELLCAST_DELAYED")
    end
end

function oCB:SpellDelayed(d)
	self:Debug(string.format("SpellDelayed - Spell delayed with %s", d/1000))
	d = d / 1000
	
	if(self.frames.CastingBar:IsShown()) then
		if self.delay == nil then self.delay = 0 end
		
		self.startTime = self.startTime + d
		self.maxValue = self.maxValue + d
		self.delay = self.delay + d
		
		self.frames.CastingBar.Bar:SetMinMaxValues(self.startTime, self.maxValue)
	end
end

function oCB:SpellChannelStart(d)
	self:Debug("SpellChannelStart - Starting channel")
	d = d / 1000
	local c = self.db.profile.Colors.Channel
	
	self.startTime = GetTime()
	self.endTime = self.startTime + d
	self.maxValue = self.endTime
	
	self.frames.CastingBar.Bar:SetStatusBarColor(c.r, c.g, c.b)
	self.frames.CastingBar.Bar:SetMinMaxValues(self.startTime, self.endTime)
	self.frames.CastingBar.Bar:SetValue(self.endTime)
	self.frames.CastingBar.Spell:SetText(arg2)
	self.frames.CastingBar.Time:SetText("")
	self.frames.CastingBar.Delay:SetText("")
	self.frames.CastingBar:SetAlpha(1)
	
	self.frames.CastingBar.Icon:Hide()
	self.frames.CastingBar.Latency:SetText("")
	
	if oCBIcon then
		self:Debug("SpellChannel icon found: "..oCBIcon)
		self.frames.CastingBar.Texture:SetTexture(oCBIcon)
		self.frames.CastingBar.Icon:Show()
	end
	
	self.holdTime 	= 0
	self.casting		= nil
	self.channeling 	= 1
	self.fadeOut 	= nil
	
	self.frames.CastingBar:Show()
	self.frames.CastingBar.Spark:Show()
end

function oCB:SpellChannelStop()
	self:Debug("SpellChannelStop - Stopping channel")
	if not self.channeling then return end
	local c = self.db.profile.Colors.Complete
	
	self.frames.CastingBar.Bar:SetValue(self.endTime)
	self.frames.CastingBar.Bar:SetStatusBarColor(c.r, c.g, c.b)
	self.frames.CastingBar.Spark:Hide()
	
	self.delay = 0
	self.casting = nil
	self.channeling = nil
	self.fadeOut = 1
	
	oCBCastSent = nil
end

function oCB:SpellChannelUpdate(d)
	self:Debug("SpellChannelUpdate - Updating channel")
	d = d / 1000
	
	if(self.frames.CastingBar:IsShown()) then
		local origDuration = self.endTime - self.startTime
		
		if self.delay == nil then self.delay = 0 end
		
		self.delay = self.delay + d
		self.endTime = GetTime() + d
		self.maxValue = self.endTime
		self.startTime = self.endTime - origDuration
		
		self.frames.CastingBar.Bar:SetMinMaxValues(self.startTime, self.endTime)
	end
end

function oCB:OnCasting()
	elapsed= elapsed + arg1
	if(oCB.casting) then
		local delay, n, sp = false, GetTime(), 0
		
		if (n >= oCB.maxValue) then n = oCB.maxValue end
		
		oCB.frames.CastingBar.Time:SetText(string.format( "%.1f", n-oCB.startTime).." / "..string.format("%.1f", oCB.maxValue-oCB.startTime))
		
		if (oCB.delay ~= 0) then delay = 1 end
		if (delay) then
			oCB.frames.CastingBar.Delay:SetText("+"..string.format("%.1f", oCB.delay or "" ))
		else 
			oCB.frames.CastingBar.Delay:SetText("")
		end
		
		if UnitOnTaxi("player") then
			oCB.frames.CastingBar.Texture:SetTexture("Interface/Icons/Ability_Hunter_EagleEye")
			oCB.frames.CastingBar.Icon:Show()
			oCB.frames.CastingBar.Latency:SetText("")
			oCB.frames.CastingBar.LagBar:SetValue(0)
		end
		
		oCB.frames.CastingBar.Bar:SetValue(n)
		
		local w = oCB.frames.CastingBar.Bar:GetWidth()
		sp = ((n - oCB.startTime) / (oCB.maxValue - oCB.startTime)) * w
		if( sp < 0 ) then sp = 0 end
		
		oCB.frames.CastingBar.Spark:SetPoint("CENTER", oCB.frames.CastingBar.Bar, "LEFT", sp, 0)
	elseif (oCB.channeling) then
		local delay, n, sp = false, GetTime(), 0
		
		if (n > oCB.endTime) then n = oCB.endTime end
		if (n == oCB.endTime) then
			oCB.channeling = nil
			oCB.fadeOut = 1
			return
		end

		local b = oCB.startTime + (oCB.endTime - n)
		
		oCB.frames.CastingBar.Time:SetText(string.format( "%.1f", math.max(oCB.maxValue - n, 0.0)))
		
		if (oCB.delay and oCB.delay ~= 0) then delay = 1 end
		if (delay) then
			oCB.frames.CastingBar.Delay:SetText("-"..string.format("%.1f", oCB.delay ))
		else 
			oCB.frames.CastingBar.Delay:SetText("")
		end
		
		oCB.frames.CastingBar.Bar:SetValue(b)
		
		local w = oCB.frames.CastingBar.Bar:GetWidth()
		sp = ((b - oCB.startTime) / (oCB.endTime - oCB.startTime)) * w
		
		oCB.frames.CastingBar.Spark:SetPoint("CENTER", oCB.frames.CastingBar.Bar, "LEFT", sp, 0)
	elseif(GetTime() < oCB.holdTime) then
		return
	elseif(oCB.fadeOut) then
		local a = this:GetAlpha() - .05
		
		if (a > 0) then
			oCB.frames.CastingBar:SetAlpha(a)
		else
			oCB.fadeOut = nil
			oCB.frames.CastingBar:Hide()
			oCB.frames.CastingBar.Time:SetText("")
			oCB.frames.CastingBar.Delay:SetText("")
			oCB.frames.CastingBar:SetAlpha(1)
		end
	end
end