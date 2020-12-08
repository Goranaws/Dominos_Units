local addonName = ...
local master = LibStub('AceAddon-3.0'):GetAddon("Dominos")
local Addon = master:CreateClass('Frame', master.Frame)
Addon.master = master
_G[addonName] = Addon

Addon.Config = "Dominos-Config"
Addon.lib = LibStub('LibSharedMedia-3.0', true)
Addon.NAME = addonName
Addon.frames = {}

function Addon:New(name)
	local name = string.lower(name)
	local f = self:Bind(self.proto.New(self, name))
	f.container = f:CreateTexture(nil, 'ARTWORK')
	f.container:SetPoint("Center", f)
	f:Reload()
	Addon.frames[name] = f
	return f
end

function Addon:GetDefaults()
	local def
	if self and self.id and self.defaults[self.id] then 
		def = Addon.Copy(Addon.defaults[self.id])
	else
		def = Addon.Copy(Addon.baseDefaults)
		def.x = 0
		def.y = 0
		def.point = "Center"
	end
	return def
end

function Addon:Reload()
	if self.Load then
		self:Load()
	end
	self:SetParent(self.parent or self:GetParent())
	self:Layout()
	self:Rescale()
	self:Reposition()
	self:Reanchor()
	if self.UpdateWidgets then
		self:UpdateWidgets()
	end
end

function Addon:Delete()
	Addon.master.db.profile.frames[self.id] = nil
	self:Free()
end

function Addon:Layout()
	if self.UpdateWidgets then
		self:UpdateWidgets()
	else
		local pad = self:GetPadding()
		local w, h = self.sets.width, self.sets.height
		self:SetSize(w + pad, h + pad)
		self.container:SetPoint("Center", self)
		self.container:SetSize(w,h)
		self.sets.frameStrata = self.sets.frameStrata or 1
		self.sets.frameLayer = self.sets.frameLayer or 1
		local lay = Addon.layers[self.sets.frameStrata]
		self:SetFrameStrata(lay)
		self:SetFrameLevel(self.sets.frameLayer)
	end
end
Ghf
