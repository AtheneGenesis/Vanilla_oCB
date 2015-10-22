function oCB:CreateFramework(b, n, s)
	self.frames[b] = CreateFrame("Frame", n, UIParent)
	self.frames[b]:Hide()
	self.frames[b].name = b
	
	if(s =="MirrorBar") then
		self.frames[b]:SetScript("OnUpdate", self.OnMirror)
	else
		self.frames[b]:SetScript("OnUpdate", self.OnCasting)
	end
	self.frames[b]:SetMovable(true)
	self.frames[b]:EnableMouse(true)
	self.frames[b]:RegisterForDrag("LeftButton")
	self.frames[b]:SetScript("OnDragStart", function() if not self.db.profile.lock then this:StartMoving() end end)
	self.frames[b]:SetScript("OnDragStop", function() this:StopMovingOrSizing() self:savePosition() end)
	
	self.frames[b].Bar = CreateFrame("StatusBar", nil, self.frames[b])
	if(s ~="MirrorBar") then
		self.frames[b].LagBar = CreateFrame("StatusBar", nil, self.frames[b])
		self.frames[b].Delay = self.frames[b].Bar:CreateFontString(nil, "OVERLAY")
		self.frames[b].Latency = self.frames[b].Bar:CreateFontString(nil, "OVERLAY")
	end
	self.frames[b].Spark = self.frames[b].Bar:CreateTexture(nil, "OVERLAY")
	self.frames[b].Time = self.frames[b].Bar:CreateFontString(nil, "OVERLAY")
	self.frames[b].Spell = self.frames[b].Bar:CreateFontString(nil, "OVERLAY")
	self.frames[b].Icon = CreateFrame("Frame", nil, self.frames[b])
	self.frames[b].Texture = self.frames[b].Icon:CreateTexture(nil, "OVERLAY")
	self.frames[b].Icon:Hide()
	
	self:Layout(b, s)
end

function oCB:Layout(b, s)
	local db = self.db.profile[s or b]
	local f, _ = GameFontHighlightSmall:GetFont()
	
	self.frames[b]:SetWidth(db.width+9)
	self.frames[b]:SetHeight(db.height+10)
	self.frames[b]:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = self.Borders[db.edgeFile], edgeSize = 16,
		insets = {left = 4, right = 3, top = 4, bottom = 4},
	})
	self.frames[b]:SetBackdropBorderColor(0, 0, 0)
	self.frames[b]:SetBackdropColor(0, 0, 0, 0.9)
	
	self.frames[b].Bar:ClearAllPoints()
	self.frames[b].Bar:SetPoint("CENTER", self.frames[b], "CENTER", 0, 0)
	self.frames[b].Bar:SetWidth(db.width)
	self.frames[b].Bar:SetHeight(db.height)
	self.frames[b].Bar:SetFrameLevel(2)
	self.frames[b].Bar:SetStatusBarTexture(self.Textures[db.texture])
	
	if(s ~="MirrorBar") then
		self.frames[b].LagBar:ClearAllPoints()
		self.frames[b].LagBar:SetPoint("RIGHT", self.frames[b], "LEFT", db.width+5, 0)
		self.frames[b].LagBar:SetWidth(0)
		self.frames[b].LagBar:SetHeight(db.height)
		self.frames[b].LagBar:SetFrameLevel(1)
		self.frames[b].LagBar:SetStatusBarTexture(self.Textures[db.texture])
	end
	
	self.frames[b].Icon:ClearAllPoints()
	self.frames[b].Icon:SetPoint("CENTER", self.frames[b], "LEFT", -db.height/2+2, 0)
	self.frames[b].Icon:SetWidth(db.height+2)
	self.frames[b].Icon:SetHeight(db.height+2)
	self.frames[b].Icon:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 8,
		edgeFile = "Interface\\AddOns\\oCB\\Backdrop\\PlainBackdrop", edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	self.frames[b].Icon:SetBackdropBorderColor(0, 0, 0, 0.7)
	self.frames[b].Icon:SetBackdropColor(0, 0, 0, 0)
	-- self.frames[b].Icon:SetBlendMode("BLEND")
	self.frames[b].Texture:SetTexture("Interface\\Icons\\Spell_Holy_FlashHeal")
	self.frames[b].Texture:SetAlpha(0.9)
	self.frames[b].Texture:SetWidth(db.height)
	self.frames[b].Texture:SetHeight(db.height)
	self.frames[b].Texture:SetTexCoord(0.08,0.92,0.08,0.92)
	self.frames[b].Texture:ClearAllPoints()
	self.frames[b].Texture:SetPoint("CENTER", self.frames[b].Icon, "CENTER", 0, 0)
	
	
	self.frames[b].Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	self.frames[b].Spark:SetWidth(16)
	self.frames[b].Spark:SetHeight(db.height*2.44)
	self.frames[b].Spark:SetBlendMode("ADD")
	
	self.frames[b].Time:SetJustifyH("RIGHT")
	self.frames[b].Time:SetFont("Interface\\AddOns\\oCB\\fonts\\visitor1.ttf",db.timeSize, "MONOCHROME")
	self.frames[b].Time:SetShadowColor( 0, 0, 0, 1)
	self.frames[b].Time:SetShadowOffset( 0.8, -0.8 )
	self.frames[b].Time:SetText("Xxx.Y / Xxx.Y")
	self.frames[b].Time:ClearAllPoints()
	self.frames[b].Time:SetPoint("RIGHT", self.frames[b].Bar, "RIGHT",-8,2)
	
	self.frames[b].Spell:SetJustifyH("LEFT")
	self.frames[b].Spell:SetWidth(db.width-self.frames[b].Time:GetWidth())
	self.frames[b].Spell:SetFont("Interface\\AddOns\\oCB\\fonts\\visitor2.ttf",db.spellSize, "MONOCHROME")
	self.frames[b].Spell:SetShadowColor( 0, 0, 0, 1)
	self.frames[b].Spell:SetShadowOffset( 0.8, -0.8 )
	self.frames[b].Spell:ClearAllPoints()
	self.frames[b].Spell:SetPoint("LEFT", self.frames[b], "LEFT", 15,1)
	
	if(s ~="MirrorBar") then
		self.frames[b].Delay:SetTextColor(1,0,0,1)
		self.frames[b].Delay:SetJustifyH("RIGHT")
		self.frames[b].Delay:SetFont("Interface\\AddOns\\oCB\\fonts\\visitor1.ttf",db.delaySize, "MONOCHROME")
		self.frames[b].Delay:SetShadowColor( 0, 0, 0, 1)
		self.frames[b].Delay:SetShadowOffset( 0.8, -0.8 )
		self.frames[b].Delay:SetText("X.Y")
		self.frames[b].Delay:ClearAllPoints()
		self.frames[b].Delay:SetPoint("RIGHT", self.frames[b], "RIGHT",-(db.width*0.34),2)
		
		self.frames[b].Latency:SetTextColor(0.36,0.36,0.36,1)
		self.frames[b].Latency:SetJustifyH("RIGHT")
		self.frames[b].Latency:SetFont("Interface\\AddOns\\oCB\\fonts\\visitor2.ttf",db.spellSize, "MONOCHROME")
		self.frames[b].Latency:SetShadowColor( 0, 0, 0, 1)
		self.frames[b].Latency:SetShadowOffset( 0.8, -0.8 )
		self.frames[b].Latency:SetText("64ms")
		self.frames[b].Latency:ClearAllPoints()
		self.frames[b].Latency:SetPoint("BOTTOMRIGHT", self.frames[b], "BOTTOMRIGHT", -3, 4)
	end
	
	self:updatePositions(b)
end

function oCB:ShowBlizzCB()
	CastingBarFrame:RegisterEvent("SPELLCAST_START")
	CastingBarFrame:RegisterEvent("SPELLCAST_STOP")
	CastingBarFrame:RegisterEvent("SPELLCAST_INTERRUPTED")
	CastingBarFrame:RegisterEvent("SPELLCAST_FAILED")
	CastingBarFrame:RegisterEvent("SPELLCAST_DELAYED")
	CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_START")
	CastingBarFrame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
end

function oCB:HideBlizzCB()
	CastingBarFrame:UnregisterEvent("SPELLCAST_START")
	CastingBarFrame:UnregisterEvent("SPELLCAST_STOP")
	CastingBarFrame:UnregisterEvent("SPELLCAST_INTERRUPTED")
	CastingBarFrame:UnregisterEvent("SPELLCAST_FAILED")
	CastingBarFrame:UnregisterEvent("SPELLCAST_DELAYED")
	CastingBarFrame:UnregisterEvent("SPELLCAST_CHANNEL_START")
	CastingBarFrame:UnregisterEvent("SPELLCAST_CHANNEL_STOP")
end