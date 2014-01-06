
function OnAfterSceneLoaded(self)
  self:SetTraceAccuracy(Vision.TRACE_AABOX)

end


-- info fields: HitPoint, HitNormal, Force, RelativeVelocity,
--              ColliderType, ColliderObject (maybe nil)
function OnCollision(self, info)
	if info.ColliderType == "Mesh" then
		Debug:PrintLine("Hit: " .. info.ColliderObject)
	end
	
end
