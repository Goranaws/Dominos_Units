local Addon = _G[...]local modName = ...local title = "Threat"local Widget = Addon:NewWidget(title, 'Frame')Widget.defaults = {	visibility = {		border = {			color = {				a = 0.5,				b = 0,				g = 0,				r = 0,			},			file = "Threat",			thickness = 10,			padL = 6,			padR = 6,			padT = 6,			padB = 6,		},		background = {			enable = true,			file = "Armory",			color = {				a = 0.5,				b = 0,				g = 0,				r = 0,			},			padL = 5,			padR = 5,			padT = 3,			padB = 3,		},	},	fontcolor = {		a = 1,		r = 1,		g = 1,		b = 0,	},	basic = {		position = {			y = 4,			x = -74,			frameLevel = 4,			anchor = "TopRight",			frameStrata = 2,		},		text = {			enable = true,			file = "Friz Quadrata TT",			color = {				a = 1,				b = 0,				g = 1,				r = 1,			},			scale = 100,			size = 9,		},	},}function Widget:New(parent)		local widget = self:Bind(CreateFrame("Frame",nil, parent.box, "BackdropTemplate"))	widget:Show()		widget.text = widget.text or widget:CreateFontString(nil, 'ARTWORK', 'TextStatusBarText')	widget:SetAllPoints(widget.text)	widget.text:SetText("200%")		widget.drop = widget.drop or CreateFrame('Frame', nil, widget, "BackdropTemplate")	widget.drop:SetFrameLevel(widget:GetFrameLevel()-1)	widget.border = widget.border or CreateFrame('Frame', nil, widget, "BackdropTemplate")		widget.owner = parent	widget.title = "threat"	widget.handler = parent.id	return widgetendfunction Widget:Layout()	if self.sets.basic.text.enable ~= true then		self:Hide()		self.noUpdate = true		return	else		self:Show()		self.noUpdate = nil	end	self:Update()	self:Reposition()		self:LayoutText()	self:UpdateBackground()	self:UpdateBorder()	self:Update()endfunction Widget:Reposition()	local sets = self.sets.basic.position	self:SetAllPoints(self.text)	self.text:ClearAllPoints()	self.text:SetPoint(sets.anchor, self:GetParent(), sets.x, sets.y)		local lay = Addon.layers[sets.frameStrata]	self:SetFrameStrata(lay)	self:SetFrameLevel(sets.frameLevel)	endfunction Widget:LayoutText()	local text = self.text	local sets = self.sets.basic.text	self.text:SetFont(self:GetMediaPath("font", sets.file), sets.size or 12)	self.text:SetTextColor(sets.color.r, sets.color.g, sets.color.b, sets.color.a)	sets.scale = sets.scale or 100	self:SetScale(sets.scale/100)endfunction Widget:GetMediaPath(kind, fileName)	if Addon.lib then		return Addon.lib:Fetch(kind, fileName)	endendfunction Widget:UpdateBackground()	local sets = self.sets.visibility.background	local widget = self.drop	local file = self:GetMediaPath("statusbar", sets.file)	if not sets.enable then		file = ""	end		widget:SetBackdrop({ 		bgFile = file,	})	widget:SetBackdropColor(sets.color.r, sets.color.g, sets.color.b, sets.color.a)		sets.padL = sets.padL or 0 		sets.padR = sets.padR or 0 		sets.padT = sets.padT or 0 		sets.padB = sets.padB or 0			local anchor = self.text		widget:ClearAllPoints()	widget:SetPoint("Left", anchor, -sets.padL, 0)	widget:SetPoint("Right", anchor, sets.padR, 0)	widget:SetPoint("Top", anchor, 0, sets.padT)	widget:SetPoint("Bottom", anchor, 0, -sets.padB)endfunction Widget:UpdateBorder()	local sets = self.sets.visibility.border	local widget = self.border	local file = self:GetMediaPath("border", sets.file)	if not sets.enable then		file = ""	end		widget:SetBackdrop({ 		edgeFile = file,		edgeSize = sets.thickness, 	})	widget:SetBackdropBorderColor(sets.color.r, sets.color.g, sets.color.b, sets.color.a)		sets.padL = sets.padL or 0 		sets.padR = sets.padR or 0 		sets.padT = sets.padT or 0 		sets.padB = sets.padB or 0			local anchor = self.text		widget:ClearAllPoints()	widget:SetPoint("Left", anchor, -sets.padL, 0)	widget:SetPoint("Right", anchor, sets.padR, 0)	widget:SetPoint("Top", anchor, 0, sets.padT)	widget:SetPoint("Bottom", anchor, 0, -sets.padB)	endfunction Widget:GetMediaPath(kind, fileName)	if Addon.lib then		return Addon.lib:Fetch(kind, fileName)	endendfunction Widget:Update()	if self.noUpdate then		return	end	local unit = self.owner.id	local threat = self:GetDisplayedText()	self.text:SetText(threat)endfunction Widget:GetDisplayedText()    local feedbackUnit, unit  = 'player', self.owner.id	local threat = ""	if (UnitClassification(unit) ~= "minus") and     ( ShowNumericThreat() and not (UnitClassification(self.owner) == "minus") ) and	 (feedbackUnit and unit) and (UnitName(feedbackUnit) ~= UnitName(unit)) and  (not UnitIsDead(unit)) and (UnitExists(unit)) then        local isTanking, status, percentage, rawPercentage = UnitDetailedThreatSituation(feedbackUnit, unit);        local display = rawPercentage;        if ( isTanking ) then            display = UnitThreatPercentageOfLead(feedbackUnit, unit);        end		if ( display and display ~= 0 ) then			local plus = ""			if display > 250 then				display = 250				plus = " +"			end			threat = format("%1.0f", display).."%"..plus		end	end	if self.TEST then		threat = '200% +'	end		if (not threat) or (threat=="") then		self:Hide()	else		self:Show()	end		return threatendWidget.Options = {	{		name = "Basic",		kind = "Panel",		key = "basic",		panel = "Basic",		options = {			{				name = 'Font',				kind = 'Media',				key = 'file',				mediaType = 'Font',				panel = 'text',			},			{				name = 'Size',				kind = 'Slider',				key = 'size',				min = 1,				max = 25,				panel = 'text',			},			{				name = 'Scale',				kind = 'Slider',				key = 'scale',				min = 50,				max = 250,				panel = 'text',			},			{				name = 'Color',				kind = 'ColorPicker',				key = 'color',				panel = 'text',			},			{				name = 'X Offset',				kind = 'Slider',				key = 'x',				panel = 'position',				min = -400,				max = 400,			},			{				name = 'Y Offset',				kind = 'Slider',				key = 'y',				panel = 'position',				min = -400,				max = 400,			},			{				name = 'Anchor',				kind = 'Menu',				key = 'anchor',				panel = 'position',				table = {					'TopLeft',					'Top',					'TopRight',					'Right',					'BottomRight',					'Bottom',					'BottomLeft',					'Left',					'Center',				},			},			{				name = 'Enable',				kind = 'CheckButton',				key = 'enable',				panel = "text",			},			{				kind = "Button",				name = "Test Mode",				handler = "threat",				func = function(owner)					owner.TEST = not owner.TEST					owner:Layout()				end,				panel = "text",			},		}	},		{		name = "visibility",		kind = "Panel",		key = "visibility",		panel = "visibility",		options = {									{				name = 'Enable',				kind = 'CheckButton',				key = 'enable',				panel = "background",			},			{				name = 'Reaction Colored',				kind = 'CheckButton',				key = 'targetReaction',				panel = "background",			},						{				name = 'Left',				kind = 'Slider',				key = 'padL',				panel = "background",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},			{				name = 'Right',				kind = 'Slider',				key = 'padR',				panel = "background",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},			{				name = 'Top',				kind = 'Slider',				key = 'padT',				panel = "background",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},			{				name = 'Bottom',				kind = 'Slider',				key = 'padB',				panel = "background",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},			{				name = 'Texture',				kind = 'Media',				key = 'file',				mediaType = 'Statusbar',				panel = "background",			},			{				name = 'Color',				kind = 'ColorPicker',				key = 'color',				panel = 'background',			},			{				name = 'Left',				kind = 'Slider',				key = 'padL',				panel = "border",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},			{				name = 'Right',				kind = 'Slider',				key = 'padR',				panel = "border",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},			{				name = 'Top',				kind = 'Slider',				key = 'padT',				panel = "border",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},			{				name = 'Bottom',				kind = 'Slider',				key = 'padB',				panel = "border",				min = -16,				max = 32,				runOnce = function(self)					--self:SetDynamic(3)				end			},									{				name = 'Texture',				kind = 'Media',				key = 'file',				mediaType = 'Border',				panel = "border",			},				{				name = 'Enable',				kind = 'CheckButton',				key = 'enable',				panel = "border",			},			{				name = 'Color',				kind = 'ColorPicker',				key = 'color',				panel = 'border',			},			{				name = 'Thickness',				kind = 'Slider',				key = 'thickness',				panel = "border",				min = 1,				max = 32,				runOnce = function(self)					--self:SetDynamic(2)				end			},		}	},	}