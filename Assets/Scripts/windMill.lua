--[[
Initializes the windmill animation.
--]]

function OnAfterSceneLoaded(self)
	self.windSpin = self:AddComponentOfType("VAnimationComponent")
    self.windSpin:Play("rotorSpin", true)
	self.windSpin:SetSpeed(-.05)
end
