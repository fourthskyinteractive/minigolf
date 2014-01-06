--[[
Initializes the watermill animation.
--]]

function OnAfterSceneLoaded(self)
	self.waterSpin = self:AddComponentOfType("VAnimationComponent")
    self.waterSpin:Play("waterSpin", true)
	self.waterSpin:SetSpeed(.15)
end
