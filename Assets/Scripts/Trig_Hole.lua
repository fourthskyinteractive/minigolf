
function OnObjectEnter(self, object)
	if object:GetKey() == "ball" then
		G.resetHole = true
	end
end
