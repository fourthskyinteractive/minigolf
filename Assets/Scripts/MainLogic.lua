function OnAfterSceneLoaded(self)
	self.hitImpulse = 80
	self.ball = Game:GetEntity("ball")
	self.clicks = Input:CreateMap("clickSpots")
	G.strokes = 0
	G.resetHole = false
	G.reshoot = false
	self.par = 4
	self.ballStartPosition = self.ball:GetPosition()
	self.ballPicked = false
	self.canHitBall = true
	self.camCloseDist = 200
	self.camOffsetYDist = 75
	self.camOffsetYDistFar = 600
	self.camFarDist = 1000
	self.resetBallTime = .5
	self.resetBallTimeLeft = .5
	self.FontPath = "Fonts/fixedsys80"
	
	Debug:Enable(true)
    
    w, h = Screen:GetViewportSize()
    hGrid = h*.15
	
    if Application:GetPlatformName() == "WIN32DX9" or 
	Application:GetPlatformName() == "WIN32DX11" then
	
      self.clicks:MapTrigger("X", "MOUSE", "CT_MOUSE_ABS_X")
      self.clicks:MapTrigger("Y", "MOUSE", "CT_MOUSE_ABS_Y")
	  self.clicks:MapTrigger("ZOOM", "KEYBOARD", "CT_KB_Z")
      self.clicks:MapTrigger("Press", "MOUSE", "CT_MOUSE_LEFT_BUTTON", {once = true, onpress= true})
	  self.clicks:MapTrigger("Active", "MOUSE", "CT_MOUSE_LEFT_BUTTON")
      self.clicks:MapTrigger("Release", "MOUSE", "CT_MOUSE_LEFT_BUTTON", {once = true, onpress= false, onrelease = true})
	  
    else
	
      self.clicks:MapTrigger("X", {0,0, w, h}, "CT_TOUCH_ABS_X")
      self.clicks:MapTrigger("Y", {0,0, w, h}, "CT_TOUCH_ABS_Y")
	  self.clicks:MapTrigger("ZOOM", {w - hGrid,0, w, hGrid}, "CT_TOUCH_ANY")
      self.clicks:MapTrigger("Press", {0,0, w, h}, "CT_TOUCH_ANY", {once = true, onpress= true})
	  self.clicks:MapTrigger("Active", {0,0, w, h}, "CT_TOUCH_ANY")
      self.clicks:MapTrigger("Release", {0,0, w, h}, "CT_TOUCH_ANY", {once = true, onpress= false, onrelease = true})
	  
	  --RenderIcons
	  self.iconZoom = Game:CreateScreenMask(64, 64, "Textures\\icon_zoomOut.tga")
      self.iconZoom:SetBlending(Vision.BLEND_ALPHA)
      self.iconZoom:SetTargetSize(hGrid, hGrid)
      self.iconZoom:SetPos(w - hGrid, 0)
    end
end

function OnThink(self)
    local X = self.clicks:GetTrigger("X")	
    local Y = self.clicks:GetTrigger("Y")
 
	--On Press make sure you click the ball and you are able to click it 
    if self.clicks:GetTrigger("Press")>0 then
		self.ClickVec = Vision.hkvVec3(X, Y, 0)
		self.ReleaseVec = nil
		self.picked = Screen:PickEntity(X,Y, 50000, true)
		if self.picked ~= nil then
			if self.picked:GetKey() == "ballTouchRadius" and
			self.canHitBall == true then 
				self.ballPicked = true
				self.ballAimFX = Game:CreateEffect(self.ball:GetPosition(),"Particles\\aimBall.xml")
				self.ballPathFX = Game:CreateEffect(self.ball:GetPosition(),"Particles\\ballPath.xml")
			  end
		end
	 else
		self.picked = nil
	 end
	
	--Have to track active position as just getting X/Y at release will return 0,0 on mobile as there is no location
	if self.clicks:GetTrigger("Active")>0 then
	  self.ActiveVec = Vision.hkvVec3(X, Y, 0)
	  if self.ballPicked == true and
	  self.canHitBall == true then
	    local ballWorldPos = self.ball:GetPosition() 
	    local cameraWorldPos = self:GetPosition()
		local targetWorldPos = Screen:Project3D(self.ActiveVec.x, self.ActiveVec.y, self.camCloseDist)
		local cameraToTarget = targetWorldPos - cameraWorldPos
		cameraToTarget:normalize()
		--Scale the normal vector so the target position is on the surface of the course (at ball height)
		local scaleFactor = -(cameraWorldPos.z - self.ball:GetPosition().z)/cameraToTarget.z
		local cameraToTarget = cameraToTarget:__mul(scaleFactor)
		local finalPos = cameraWorldPos + cameraToTarget
		self.finalTargetPos  = ballWorldPos + (ballWorldPos - finalPos) 
		
		if self.ballAimFingerFX == nil then
			self.ballAimFingerFX = Game:CreateEffect(finalPos,"Particles\\ballFingerAim.xml")
		else
			self.ballAimFingerFX:SetPosition(finalPos)
		end

		
		-- Toggle for aim/path ball effect
		if self.ballAimFX ~= nil and
		self.ballPathFX ~= nil then
			if toggleTrail == nil then
				local toggleTrail = "start"
			end
			if toggleTrail == "start" then 
				self.ballAimFX:SetPosition(finalPos)
				self.ballPathFX:SetPosition(self.finalTargetPos)
				toggleTrail = "end"
			else
				self.ballAimFX:SetPosition(self.ball:GetPosition())
				self.ballPathFX:SetPosition(self.ball:GetPosition())
				toggleTrail = "start"
			end
		end
	
	  end
	  
	end
    
	-- Preform logic click/touch is releases
    if self.clicks:GetTrigger("Release")>0 then
	  if self.ballPicked == true and
	  self.canHitBall == true  then
			self.BallLastHitPos = self.ball:GetPosition()
			local ImpulseBallX = (self.finalTargetPos.x - self.ball:GetPosition().x) * self.hitImpulse
			local ImpulseBallY = (self.finalTargetPos.y - self.ball:GetPosition().y) * self.hitImpulse
			self.ball:GetComponentOfType("vHavokRigidBody"):ApplyLinearImpulse(Vision.hkvVec3(ImpulseBallX,ImpulseBallY,0))
			self.ballPicked = false
			G.strokes = G.strokes + 1
		end
		
		if self.ballAimFX ~= nil then
			self.ballAimFX:Remove()
			self.ballAimFX = nil
		end
		if self.ballPathFX ~= nil then
			self.ballPathFX:Remove()
			self.ballPathFX = nil
		end
		if self.ballAimFingerFX ~= nil then
			self.ballAimFingerFX:Remove()
			self.ballAimFingerFX = nil
		end
		self.picked = nil
    end
	
	
	if self.clicks:GetTrigger("ZOOM")>0 then
		-- Zoom out camera and cant hit
		self:SetPosition(self.ball:GetPosition().x, (self.ball:GetPosition().y - self.camOffsetYDistFar), self.ball:GetPosition(). z + self.camFarDist)
	else
		-- Move Camera with ball on X,Y
		self:SetPosition(self.ball:GetPosition().x, (self.ball:GetPosition().y - self.camOffsetYDist), self.ball:GetPosition(). z + self.camCloseDist)
	end

	
	
	-- Track Velocity to see if you can hit ball
	if self.ball:GetComponentOfType("vHavokRigidBody"):GetLinearVelocity():getLength() < 20 and
	--make sure you are in zoomed in mode
	self:GetPosition().z == self.ball:GetPosition().z + self.camCloseDist and
	G.resetHole == false and
	G.reshoot == false then
		self.canHitBall = true
	else
		self.canHitBall = false
	end
	
	-- Debug Cursor on windows to show if you can hit the ball or not and see where mouse is
    if (Application:GetPlatformName() == "WIN32DX9" or 
	Application:GetPlatformName() == "WIN32DX11")
	and self.canHitBall == true then
      Debug.Draw:Line2D(X,Y,X+10,Y+5, Vision.V_RGBA_BLUE)
      Debug.Draw:Line2D(X,Y,X+5,Y+10, Vision.V_RGBA_BLUE)
      Debug.Draw:Line2D(X+10,Y+5,X+5,Y+10, Vision.V_RGBA_BLUE)
	elseif (Application:GetPlatformName() == "WIN32DX9" or 
	Application:GetPlatformName() == "WIN32DX11")then
	  Debug.Draw:Line2D(X,Y,X+10,Y+5, Vision.V_RGBA_RED)
      Debug.Draw:Line2D(X,Y,X+5,Y+10, Vision.V_RGBA_RED)
      Debug.Draw:Line2D(X+10,Y+5,X+5,Y+10, Vision.V_RGBA_RED)
    end
	
	-- Display strokes and par
	Debug:PrintAt(w*.02, h*.02,"Strokes:" ..G.strokes , Vision.V_RGBA_WHITE, self.FontPath )
	Debug:PrintAt(w*.45, h*.02,"Par:" ..self.par , Vision.V_RGBA_WHITE, self.FontPath )
	
	
	-- Update Ball touch radius to move with the ball
	Game:GetEntity("ballTouchRadius"):SetPosition(self.ball:GetPosition())
	
	if G.resetHole == true then
		-- Setup time to wait a bit before hole resets
		local dt = Timer:GetTimeDiff()
		self.resetBallTimeLeft = self.resetBallTimeLeft - dt
		if self.resetBallTimeLeft < 0 then
			G.resetHole = false
			resetHole(self)
			self.resetBallTimeLeft = self.resetBallTime
		end
	end
	if G.reshoot == true then
		-- Setup time to wait a bit before hole resets
		self.ball:SetVisible(false)
		self.ball:GetComponentOfType("vHavokRigidBody"):SetActive(false)
		local dt = Timer:GetTimeDiff()
		self.resetBallTimeLeft = self.resetBallTimeLeft - dt
		if self.resetBallTimeLeft < 0 then
			G.reshoot = false
			reshootHole(self)
			self.resetBallTimeLeft = self.resetBallTime
		end
	end

end

function resetHole(self)
	self.ball:GetComponentOfType("vHavokRigidBody"):SetLinearVelocity(Vision.hkvVec3(0,0,0))
	self.ball:GetComponentOfType("vHavokRigidBody"):SetAngularVelocity(Vision.hkvVec3(0,0,0))
	self.ball:GetComponentOfType("vHavokRigidBody"):SetPosition(Vision.hkvVec3(self.ballStartPosition.x, self.ballStartPosition.y, self.ballStartPosition.z +1))
	G.strokes = 0
	self:SetOrientation(90,65,0)
end

function reshootHole(self)
	self.ball:SetVisible(true)
	self.ball:GetComponentOfType("vHavokRigidBody"):SetActive(true)
	self.ball:GetComponentOfType("vHavokRigidBody"):SetLinearVelocity(Vision.hkvVec3(0,0,0))
	self.ball:GetComponentOfType("vHavokRigidBody"):SetAngularVelocity(Vision.hkvVec3(0,0,0))
	self.ball:GetComponentOfType("vHavokRigidBody"):SetPosition(Vision.hkvVec3(self.BallLastHitPos.x,self.BallLastHitPos.y,self.BallLastHitPos.z +1))
end

-- Make sure input map and screen refs are destroyed
function OnBeforeSceneUnloaded(self)
    Game:DeleteAllUnrefScreenMasks()
	Input:DestroyMap(self.clicks)
end
