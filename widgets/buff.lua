local Addon = _G[...]local modName = ...local title = "Buffs"local widget = Addon:NewWidget(title, 'Frame')widget.defaults = {	visibility = {		border = {			color = {				a = 0.5,				b = 0,				g = 0,				r = 0,			},			file = "Blizzard",			thickness = 10,		},		background = {			enable = false,			file = "Raid",			padding = 16,			color = {				a = 0.5,				b = 0,				g = 0,				r = 0,			},		},	},	basic = {		advanced = {			padding = 0,			flipVertical = true,			spacing = 0,			enable = true,			opacity = 30,			isLeftToRight = true,			auraTooltip = true,		},		icons = {			zoom = 11,			columns = 8,			scale = 73,			rows = 2,			sort = "Duration",		},		position = {			y = -68,			x = 0,			frameLevel = 4,			anchor = "TopLeft",			frameStrata = 2,		},	},}	function widget:New(parent)		local name = ('%s_%s_'..title):format(modName, parent.id)--	if _G[name] then return _G[name] end	local opac = CreateFrame('Frame', nil, parent.box)--opacity control	local bar = self:Bind(CreateFrame('StatusBar', nil, opac))	bar:SetAllPoints(opac)	bar.owner = parent	bar.opac = opac	bar.drop = bar.drop or CreateFrame('Frame', nil, bar, "BackdropTemplate")	bar.drop:SetAllPoints(bar)	bar.filter = 'HELPFUL'	bar.kind = 'buff'	return barendfunction widget:Load()	self:SetAttribute('unit', self.owner.id)	self:SetAttribute('filter', self.filter)	self:EnableMouse(false)	self.noMouse = true	self.id = self.owner.id	self.icons = self.icons or {}	self.total = self.total or 0endfunction widget:Layout()	if self.sets.basic.advanced.enable~= true then		self:Hide()		self.noUpdate = true		return	else		self:Show()		self.noUpdate = nil	end	self:Show()	self:Resize()	self:Reposition()		self:SetVisibility()		self:Update()endfunction widget:Resize()	local icons = self.sets.basic.icons	local adv = self.sets.basic.advanced	local rows, columns = icons.rows, icons.columns	local space = adv.spacing	local width, height	local zoom = self.sets.basic.icons.zoom/100	for i = 1, rows * columns do		local icon = self:GetOrCreateIcon(i)				icon:SetTexCoord(zoom,1-zoom,zoom,1-zoom)	end	local width, height = self.icons[1]:GetSize()			width, height =  width + space,  height + space			local newWidth =  width * columns - space	local newHeight = height * rows    - space	self.opac:SetSize(newWidth, newHeight)	local isLeftToRight = adv.isLeftToRight	local isTopToBottom = adv.flipVertical			for i, icon in pairs(self.icons) do		local col, row = (columns-1) - (i-1) % columns, rows - ceil(i / columns)		if isLeftToRight then			col = (i-1) % columns		end		if isTopToBottom then			row = ceil(i / columns) - 1		end		icon:ClearAllPoints()		icon:SetPoint('TOPLEFT', width*col, -(height*row))		icon:Show()	end		self.opac:SetScale(icons.scale/100)	self.opac:SetAlpha(adv.opacity)		self.drop:ClearAllPoints()		local t = adv.padding/2		self.drop:SetPoint("TopLeft", -t, t)	self.drop:SetPoint("BottomRight", t, -t)		endfunction widget:Reposition()	local position = self.sets.basic.position	local scale = self.sets.basic.icons.scale/100	self.opac:ClearAllPoints()	self.opac:SetPoint(position.anchor, self.opac:GetParent(), position.x / scale, position.y / scale)		local lay = Addon.layers[position.frameStrata]	self:SetFrameStrata(lay)	self:SetFrameLevel(position.frameLevel)	endfunction widget:SetIcons()	local icons = self.sets.basic.icons	endfunction widget:SetVisibility()	local visibility = self.sets.visibility	local background = visibility.background	local border = visibility.border	local pad = background.padding		local BG = self:GetMediaPath("statusbar", background.file)	local brd = self:GetMediaPath("border", border.file)		if not background.enable then		BG = ""	end	if not border.enable then		brd = ""	end	self.drop:SetBackdrop({ 		bgFile = BG, 		edgeFile = brd,		tile = false,		edgeSize = border.thickness, 		insets = { left = pad, right = pad, top = pad, bottom = pad }	})	do		local color = background.color		self.drop:SetBackdropBorderColor(color.r, color.g, color.b, color.a)	end	do		local color = background.color		self.drop:SetBackdropColor(color.r, color.g, color.b, color.a)	endendfunction widget:Update()	if self.noUpdate then		return	end	if self.OnUpdate then		self:OnUpdate()	endendfunction widget:GetMediaPath(kind, fileName)	if Addon.lib then		return Addon.lib:Fetch(kind, fileName)	endendfunction widget:OnUpdate(elapsed)	if self.noUpdate then		return	end	self:GetAuras()	self:DisplayOrder(elapsed)	self:UpdateTooltip()endfunction widget:GetAuras()	local icons = self.sets.basic.icons	local filter = self.filter		if UnitInRaid('player') or UnitInParty("player") then		filter = filter.."|PLAYER"		end		local numDisplayed = icons.columns * icons.rows	self.auras = self.auras or {}	wipe(self.auras)	local i = 1	while i do		local name, icon, count, debuffType, remaining, expiration = UnitAura(self.id, i, self.filter)				if name then			tinsert(self.auras, {name, icon, count, expiration, remaining, i,id})			i = i + 1		else			i = nil		end	endendlocal duration = 1.5local function GetAlpha(seconds, low, high)	return math.floor(low + ((math.abs(((seconds - (duration/2))/1) * 100)*(high - low))/100)) / 100endlocal _timelocal pulsing = {}local isPulsinglocal function PulseIcons()	_time = _time or GetTime()	if not Pulsing then --don't pulse if function is already being run.		Pulsing = true		local seconds = GetTime() - _time				if seconds > duration then			_time,Pulsing  = nil, nil			return PulseIcons()		end		local alpha = GetAlpha(seconds, 30, 100)		local swipe = GetAlpha(seconds, 20, 50)		for i, icon in pairs(pulsing) do			icon:SetAlpha(alpha)			icon.cooldown:SetSwipeColor(1,1,1,swipe)--swipeAlpha)			Pulsing = nil		end		Pulsing = nil	end	endlocal function StartPulse(icon)	pulsing[icon:GetParent().id .. icon.index] = pulsing[icon:GetParent().id .. icon.index] or iconendlocal function EndPulse(icon)	if pulsing[icon:GetParent().id .. icon.index] then		pulsing[icon:GetParent().id .. icon.index] = nil		icon:SetAlpha(1)		icon.cooldown:SetSwipeColor(1,1,1,.5)	endendfunction widget:DisplayOrder(update)	local icons = self.sets.basic.icons	for i, icon in pairs(self.icons) do --clear any unused icons.		if i > #self.auras then			self:ClearIcon(icon)		end	end	if icons.sort == 'Duration' then		table.sort(self.auras,	function(a, b)			local A, B = a[5], b[5]			if A == 0 then--durations of 0 are considered 'infinite' for sorting purposes				A = math.huge			end			if B == 0 then				B = math.huge			end			return A < B		end)	elseif icons.sort == 'Alphabetical' then		table.sort(self.auras,	function(a, b)			return a[1] < b[1]		end)	end	if icons.reverse then		local reversedTable = {}		local itemCount = #self.auras		for k, v in ipairs(self.auras) do			reversedTable[itemCount + 1 - k] = v		end		self.auras = reversedTable	end	local numDisplayed = icons.columns * icons.rows		if self.TEST then		for i=1,numDisplayed do			self:SetIcon(i, update, "test", "Interface\\ICONS\\Spell_Misc_EmotionHappy", 0, 0, 0)		end	else			for i, info in pairs(self.auras) do --update displayable auras			if i <= (numDisplayed) then				self:SetIcon(i, update, unpack(info))			end		end	end	PulseIcons()endfunction widget:UpdateTooltip()	local hasMouse	for i, b in pairs(self.icons) do		if self.auras[i] then			if MouseIsOver(b) then				hasMouse = true				GameTooltip:SetOwner(self)				GameTooltip:SetUnitAura(self.id, self.auras[i][6], self.filter)				GameTooltip:ClearAllPoints()				GameTooltip:SetPoint('BottomRight', b, 'TopLeft')				break			end		end	end	if hasMouse ~= true then		if GameTooltip:GetOwner() == self then			GameTooltip:Hide()		end	endendfunction widget:GetOrCreateIcon(i)	local t = self.icons[i] or self:CreateTexture(nil, 'ARTWORK')	if not self.icons[i] then		self.icons[i] = t		t:SetSize(32, 32)		t.cooldown = CreateFrame('Cooldown', nil, self, 'CooldownFrameTemplate')		t.cooldown:SetSwipeTexture("Interface\\FullScreenTextures\\LowHealth")		t.cooldown:SetSwipeColor(1,1,1,.5)		t.cooldown:SetAllPoints(t)		t.count = self:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')		t.count:SetPoint('BottomRight', t)		t.isShown = nil		t.index = i	end	return tendfunction widget:ClearIcons()endfunction widget:SetIcon(i, update, name, image, count, expirationTime, duration)	update = update or 0	local zoom = self.sets.basic.icons.zoom/100		local expirationTime = tonumber(expirationTime) or 0			local icon = self:GetOrCreateIcon(i)	if icon.lastImage ~= image then --only make a change, if there is a change.		icon.lastImage = image		icon:SetTexture(image)		icon:SetTexCoord(zoom,1-zoom,zoom,1-zoom)	end	if (icon.lastExpiration ~= expirationTime) then		icon.lastExpiration = expirationTime		local enabled = expirationTime and expirationTime ~= 0;		if enabled then			local currentTime = GetTime()			icon.cooldown:SetDrawEdge(true);			local remaining = math.ceil(expirationTime - currentTime)			local hours = math.floor(remaining/3600)			local mins = math.floor(remaining/60 - (hours*60))						if (hours > 1) and (mins > 15) then				remaining = remaining + 1800			end			icon.cooldown:SetCooldown(currentTime, remaining)		else			--icon.start = nil			CooldownFrame_Clear(icon.cooldown);		end	end		local t = expirationTime - GetTime()		if (t > 0) and (t < 10) then --pulse		StartPulse(icon)	else		EndPulse(icon)	end	if icon.lastCount ~= count then		icon.lastCount = count		if count == 0 then			count = ''		end		icon.count:SetText(count)	end		if name and icon.lastName ~= name then		icon.lastName = name		icon.name = name	end			icon.empty = nilendfunction widget:ClearIcon(icon)	if not icon.empty then --don't clear if it's already clear.		icon.empty = true		icon.lastImage = nil		icon:SetTexture('')		icon.lastCount = nil		icon.count:SetText('')		icon.lastExpiration = nil		icon.cooldown:Hide()		icon.name = nil	endendwidget.Options = {	{		name = "Basic",		kind = "Panel",		key = "basic",		panel = "Basic",		options = {			{				name = 'Sort',				kind = 'Menu',				key = 'sort',				table = {					'Duration',					'Alphabetical',					'Normal',				},				panel = "icons",			},			{				name = 'Scale',				kind = 'Slider',				key = 'scale',				min = 25,				max = 200,				panel = 'icons',			},			{				name = 'Columns',				kind = 'Slider',				key = 'columns',				min = 1,				max = 30,				panel = 'icons',			},			{				name = 'Rows',				kind = 'Slider',				key = 'rows',				min = 1,				max = 30,				panel = 'icons',			},			{				name = 'Zoom',				kind = 'Slider',				key = 'zoom',				min = 0,				max = 50,				panel = 'icons',			},			{				name = 'X Offset',				kind = 'Slider',				key = 'x',				panel = 'position',				min = -400,				max = 400,			},			{				name = 'Y Offset',				kind = 'Slider',				key = 'y',				panel = 'position',				min = -400,				max = 400,			},			{				name = "Frame Level",				kind = "Slider",				key = "frameLevel",				min = 1,				max = 100,				panel = 'position',			},			{				name = "Frame Strata",				kind = "Slider",				key = "frameStrata",				min = 1,				max = 8,				panel = 'position',			},			{				name = 'Anchor',				kind = 'Menu',				key = 'anchor',				panel = 'position',				table = {					'TopLeft',					'Top',					'TopRight',					'Right',					'BottomRight',					'Bottom',					'BottomLeft',					'Left',					'Center',				},			},			{				name = 'Enable',				kind = 'CheckButton',				key = 'enable',				panel = "advanced",			},			{				name = 'Tooltip',				kind = 'CheckButton',				key = 'auraTooltip',				panel = "advanced",			},			{				name = 'Flip Vertical',				kind = 'CheckButton',				key = 'flipVertical',				panel = "advanced",			},			{				name = 'Flip Horizontal',				kind = 'CheckButton',				key = 'isLeftToRight',				panel = "advanced",			},			{				kind = "Button",				name = "Test Mode",				handler = "buffs",				func = function(owner)					owner.TEST = not owner.TEST					owner:Layout()				end,				panel = "advanced",			},			{				name = 'Spacing',				kind = 'Slider',				key = 'spacing',				min = 0,				max = 30,				panel = 'advanced',			},			{				name = 'Opacity',				kind = 'Slider',				key = 'opacity',				min = 0,				max = 30,				panel = 'advanced',			},			{				name = 'Padding',				kind = 'Slider',				key = 'padding',				panel = "advanced",				min = -13,				max = 32,			},					}	},		{		name = "visibility",		kind = "Panel",		key = "visibility",		panel = "visibility",		options = {						{				name = 'Enable',				kind = 'CheckButton',				key = 'enable',				panel = "background",			},			{				name = 'Texture',				kind = 'Media',				key = 'file',				mediaType = 'Statusbar',				panel = "background",			},			{				name = 'Background Color',				kind = 'ColorPicker',				key = 'color',				panel = 'background',			},			{				name = 'Padding',				kind = 'Slider',				key = 'padding',				panel = "background",				min = -13,				max = 32,			},									{				name = 'Texture',				kind = 'Media',				key = 'file',				mediaType = 'Border',				panel = "border",			},				{				name = 'Enable',				kind = 'CheckButton',				key = 'enable',				panel = "border",			},			{				name = 'Background Color',				kind = 'ColorPicker',				key = 'color',				panel = 'border',			},			{				name = 'Thickness',				kind = 'Slider',				key = 'thickness',				panel = "border",				min = 1,				max = 32,			},		}	},}