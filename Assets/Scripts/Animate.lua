
function OnExpose(self)
	self.animationSpeed = -.05
	self.animationName = "rotorSpin"
end


function OnAfterSceneLoaded(self)
	self.animate = self:AddComponentOfType("VAnimationComponent")
    self.animate:Play(self.animationName, true)
	self.animate:SetSpeed(self.animationSpeed)
end
