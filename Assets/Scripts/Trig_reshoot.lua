
function OnExpose(self)
	self.surface = "water"

end

function OnObjectEnter(self, object)
	if object:GetKey() == "ball" then
		if self.surface == "water" then
			local waterFX = Game:CreateEffect(object:GetPosition(),"Particles//ballInWater.xml", "waterSplash")
			waterFX:SetRemoveWhenFinished (true)
		end

		G.reshoot = true
	end
end
