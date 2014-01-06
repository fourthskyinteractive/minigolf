function OnExpose(self)
	self.transport = "top"
	self.transportDirX = 0
	self.transportDirY = 1
	self.transportDirZ = 0
end


function OnObjectEnter(self, object)
	if object == Game:GetEntity("ball") then
		local ballRigid = Game:GetEntity("ball"):GetComponentOfType("vHavokRigidBody")
		local topTransportPos = Game:GetEntity("WP_topTransport"):GetPosition()
		local bottomTransportPos = Game:GetEntity("WP_bottomTransport"):GetPosition()
		local trigHitVelocityLength = ballRigid:GetLinearVelocity():getLength()
		ballRigid:SetLinearVelocity(Vision.hkvVec3(0,0,0))
		ballRigid:SetAngularVelocity(Vision.hkvVec3(0,0,0))
		if self.transport == "top" then
			ballRigid:SetPosition(topTransportPos)
		elseif self.transport == "bottom" then
			ballRigid:SetPosition(bottomTransportPos)
		end
		local transportVec = (Vision.hkvVec3(self.transportDirX,self.transportDirY,self.transportDirZ))
		transportVec:normalize()
		local forceApply = transportVec:__mul(trigHitVelocityLength)
		ballRigid:SetLinearVelocity(forceApply)
		
	end
end
