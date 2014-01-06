--[[
Attach this to the ball that the user actually interacts with which should
be a slightly larger ball that doesn't have a physics component.
--]]

function OnAfterSceneLoaded(self)
  self:SetTraceAccuracy(Vision.TRACE_AABOX)
end
