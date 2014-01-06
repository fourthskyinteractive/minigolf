function OnAfterSceneLoaded(self)
	self.waterSpin = self:AddComponentOfType("VAnimationComponent")
    self.waterSpin:Play("rotorSpin", true)
	self.waterSpin:SetSpeed(-.05)
end