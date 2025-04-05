-- Segway control script
-- By Q_Q
-- Updated 12/28/17
wait(0.1)
local Player = game.Players.LocalPlayer
local Humanoid = nil
local Character = nil
local Filtering = game.Workspace.FilteringEnabled
local Camera = game.Workspace.CurrentCamera

-- Variables for objects and vehicle settings
local SettingsFolder = script.Parent.Parent:WaitForChild("Configuration")
local ToolStatus = script.Parent.Parent:WaitForChild("ToolStatus")
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local SeaterObject = ToolStatus:WaitForChild("SeaterScript")
local SegwayObject = ToolStatus:WaitForChild("Segway")
local WeldObject = ToolStatus:WaitForChild("PlayersWeld")
local MaxSpeed = SettingsFolder:WaitForChild("MaxSpeed")
local TurnSpeed = SettingsFolder:WaitForChild("TurnSpeed")
local UseGyroSteering = SettingsFolder:WaitForChild("UseGyroSteering")
local VRUseHeadsetControls = SettingsFolder:WaitForChild("VRUseHeadsetControls")
local Thruster = ToolStatus:WaitForChild("Thruster")
local TiltMotor = ToolStatus:WaitForChild("TiltMotor")
local PlayerGui = nil
local Lights = nil
local Notifiers = nil
local RayTest = nil

-- Remote variables
local RemoteFolder = script.Parent.Parent:WaitForChild("RemoteEvents")
local TiltRemote = RemoteFolder:WaitForChild("TiltRemote")
local PlaySound = RemoteFolder:WaitForChild("PlaySound")
local StopSound = RemoteFolder:WaitForChild("StopSound")
local ChangeSound = RemoteFolder:WaitForChild("ChangeSound")
local AnchorSegway = RemoteFolder:WaitForChild("AnchorSegway")
local UndoTags = RemoteFolder:WaitForChild("UndoTags")
local UndoHasWelded = RemoteFolder:WaitForChild("UndoHasWelded")
local DeleteWelds = RemoteFolder:WaitForChild("DeleteWelds")
local ConfigHumanoid = RemoteFolder:WaitForChild("ConfigHumanoid")
local ConfigLights = RemoteFolder:WaitForChild("ConfigLights")

-- Sound variables
local RunSoundVol = 0.5
local RunSoundPitchLimit = 1.25

-- GuiControls variables
local PressedColor = Color3.new(79/255,185/255,255/255)
local LiftedColor = Color3.new(255/255,255/255,255/255)
local GuiControls = script.Parent:WaitForChild("GuiControls")
local Accelerate = GuiControls:WaitForChild("Accelerate")
local Steer = GuiControls:WaitForChild("Steer")
local UpButton = Accelerate:WaitForChild("Up")
local DownButton = Accelerate:WaitForChild("Down")
local RightButton = Steer:WaitForChild("Right")
local LeftButton = Steer:WaitForChild("Left")
local OffButton = GuiControls:WaitForChild("OffButton")
	
-- Directional tags
local Direction = 0
local Steer = 0

-- Other
local IsGettingOff = false
local IsOnSegway = false
local Vector3new, CFramenew, Mathrad, Mathpi, CFrameangles, Raynew = Vector3.new, CFrame.new, math.rad, math.pi, CFrame.Angles, Ray.new

local function Get_des(instance, func)
	func(instance)
	for _, child in next, instance:GetChildren() do
		Get_des(child, func)
	end
end

function Hopoff()
	if SegwayObject.Value ~= nil and IsGettingOff == false and SegwayObject.Value.PrimaryPart and SeaterObject.Value ~= nil then
	IsGettingOff = true
	IsOnSegway = false
	local PrimaryPart = SegwayObject.Value.PrimaryPart 
	local px,py,pz,xx,yx,zx,xy,yy,zy,xz,yz,zz=PrimaryPart.CFrame:components()
	
	-- Delete welds
	if SeaterObject.Value ~= nil then
		repeat wait() until DeleteWelds:InvokeServer(SeaterObject.Value.Parent) == true or SeaterObject.Value == nil
	end
	
	-- Resets camera's behavior
	Camera.CameraType = "Custom"
	
	-- Set gyro to have power
	if Thruster.Value then
		Thruster.Value.BodyGyro.MaxTorque = Vector3new(400000, 0, 400000)
	end
	
	-- Stops sounds
	if SeaterObject.Value and SeaterObject.Value.Parent:FindFirstChild("Run") then
		StopSound:FireServer(SeaterObject.Value.Parent.Run,0)
		PlaySound:FireServer(SeaterObject.Value.Parent.Off,SeaterObject.Value.Parent.Off.Pitch,SeaterObject.Value.Parent.Off.Volume)
	end
	
	-- Flips segway if fell over
	if SegwayObject.Value then
		SegwayObject.Value:SetPrimaryPartCFrame(CFramenew(px,py+0.1,pz,1,yx,zx,xy,1,zy,xz,yz,1))
	end	
	
	-- Turn off lights
	ConfigLights:FireServer(0.3,"Bright bluish green",false,"SmoothPlastic",Lights,Notifiers)
	
	-- Re-parents mobile gui and reshows mobile controls
	GuiControls.Parent = script.Parent
	UserInputService.ModalEnabled = false
	OffButton.ImageColor3 = LiftedColor
	
	-- Shows tool UI via use with VR
	if UserInputService.VREnabled then
		if PlayerGui and PlayerGui:FindFirstChild("DisplayGui") and PlayerGui:FindFirstChild("ColorGui") then
			PlayerGui:FindFirstChild("DisplayGui").Enabled = true
			PlayerGui:FindFirstChild("ColorGui").Enabled = true
		end
		
		UpdateCharTrans(0,0)
	end
	
	-- Disconnect events
	SitListener:disconnect()
	JumpListener:disconnect()
	
	-- Resets the tilt motor angle
	TiltRemote:FireServer(TiltMotor.Value,0)
	
	-- Makes the thruster's velocity still
	AnchorSegway:FireServer(PrimaryPart,true)
	
	-- Makes object values nil
	UndoTags:FireServer(SegwayObject,WeldObject,TiltMotor)
	
	-- Configures humanoid
	ConfigHumanoid:FireServer(Humanoid,false,true,true)
	
	-- Unanchors segway
	wait(1)
	AnchorSegway:FireServer(PrimaryPart,false)
	UndoHasWelded:FireServer(SeaterObject)
	
	-- Reset direction and steer tags
	Direction = 0
	Steer = 0
	IsGettingOff = false
	end
end

function UpdateCharTrans(BodyTrans,SegwayTrans)	
	-- Changes character's body while VR
	Get_des(Character,function(d)
		if d and d:IsA("BasePart") then
			if (d.Parent:FindFirstChild("Humanoid") or d.Parent:IsA("Accessory")) then
				d.LocalTransparencyModifier = BodyTrans
			else 
				d.LocalTransparencyModifier = SegwayTrans
			end
		elseif d and d:IsA("Decal") and d.Name == "face" then
			d.Transparency = BodyTrans
		end
	end)
end

function UpdateVRPos()
	if UserInputService.VREnabled and Character and Character.Parent and Character:FindFirstChild("Head") then
		local hpx,hpy,hpz,hxx,hxy,hxz,hyx,hyy,hyz,hzx,hzy,hzz = Character.Head.CFrame:components()
		
		Camera.CFrame = CFramenew(hpx,hpy,hpz,
			hxx,0,hxz,
			0,1,0,
			hzx,0,hzz
		) + (Vector3new(hxy,hyy,hzy)*2.5) --Height in studs above character's head
	end
end

function Accelerate()
	if IsOnSegway then
		
		local v = Direction*Thruster.Value.CFrame.lookVector*MaxSpeed.Value
		local NewVelocity = Thruster.Value.Velocity:Lerp(v, 0.05) -- Thrust
		local NewRotVelocity = Vector3new(0,-Steer*TurnSpeed.Value/10,0) -- Steering
		local px,py,pz,xx,xy,xz,yx,yy,yz,zx,zy,zz = Thruster.Value.CFrame:components()
		
			if yy > 0.7 then -- If segway is upsided
				Thruster.Value.BodyGyro.MaxTorque = Vector3new(400000, 0, 400000)
				Thruster.Value.Velocity = NewVelocity
				Thruster.Value.RotVelocity = NewRotVelocity
			else
				Thruster.Value.BodyGyro.MaxTorque = Vector3new(0,0,0)
			end
			
	end
end

function CastToGround()
	if Thruster.Value and Thruster.Value.Parent then
		
		-- Raycast to face segway towards ground
		local px,py,pz,xx,xy,xz,yx,yy,yz,zx,zy,zz = Thruster.Value.CFrame:components()
		local SegDnVect = -Vector3new(xy,yy,zy)
		local Ray = Raynew(Thruster.Value.CFrame.p, SegDnVect*50)
		local hit, position, normal = workspace:FindPartOnRayWithIgnoreList(Ray,{SegwayObject.Value,RayTest})
		local HitDepth = (Thruster.Value.Position-position).magnitude
		local NextRayAngle = (normal-SegDnVect).magnitude
		
		if hit and hit.CanCollide and NextRayAngle > 1.7 then
			Thruster.Value.BodyGyro.MaxTorque = Vector3new(400000, 0, 400000)
			Thruster.Value.BodyGyro.CFrame = CFramenew(position, position + normal) * CFrameangles(-Mathpi/2, 0, 0)
		end
		
	end
end

function Sound()
	if Thruster.Value and 0.85+Mathrad(Thruster.Value.Velocity.Magnitude/1.8) <= RunSoundPitchLimit then
		if Filtering == true then
			ChangeSound:FireServer(SeaterObject.Value.Parent.Run,0.85+Mathrad(Thruster.Value.Velocity.Magnitude/1.8),SeaterObject.Value.Parent.Run.Volume,true,false)
		else -- locally change if not filtering for maximum performance
			SeaterObject.Value.Parent.Run.Pitch = 0.85+Mathrad(Thruster.Value.Velocity.Magnitude/1.8)
		end
	end
end

function Tilt()
	if Direction ~= 0 then
		
		-- Set tilt motor and change sound
		if Filtering == true then
		TiltRemote:FireServer(TiltMotor.Value,Direction/10)
		ChangeSound:FireServer(SeaterObject.Value.Parent.Run,0,RunSoundVol,false,true)
		else -- locally change if not filtering for maximum performance
			TiltMotor.Value.DesiredAngle = Direction/10
			SeaterObject.Value.Parent.Run.Volume = RunSoundVol
		end
		
	else 
		-- Set tilt motor
		if Filtering == true then
			TiltRemote:FireServer(TiltMotor.Value,0)
		else -- locally change if not filtering for maximum performance
			TiltMotor.Value.DesiredAngle = 0
		end
		
		-- Change sound based on current status
		if Steer == 0 then
			if Filtering == true then
				ChangeSound:FireServer(SeaterObject.Value.Parent.Run,0,0,false,true)
			else -- locally change if not filtering for maximum performance
				SeaterObject.Value.Parent.Run.Volume = 0
			end
		else --Adjusts the run sound when still and just turning
			if Filtering == true then
				ChangeSound:FireServer(SeaterObject.Value.Parent.Run,0.85+Mathrad(Thruster.Value.RotVelocity.Magnitude/1.8),RunSoundVol,true,true)
			else -- locally change if not filtering for maximum performance
				SeaterObject.Value.Parent.Run.Volume = RunSoundVol
				SeaterObject.Value.Parent.Run.Pitch = 0.85+Mathrad(Thruster.Value.RotVelocity.Magnitude/1.8)				
			end
		end
		
	end
end

function SetGuiButtons()
	--Exit button
	OffButton.MouseButton1Down:connect(function() OffButton.ImageColor3 = PressedColor end)
	OffButton.MouseButton1Up:connect(function() OffButton.ImageColor3 = LiftedColor Hopoff(Character)end)
	OffButton.MouseLeave:connect(function()OffButton.ImageColor3 = LiftedColor end)
	
	--Left button pressed/lifted
	LeftButton.MouseButton1Down:connect(function()Steer = -1 LeftButton.ImageColor3 = PressedColor end)
	LeftButton.MouseButton1Up:connect(function()Steer = 0 LeftButton.ImageColor3 = LiftedColor end)
	LeftButton.MouseLeave:connect(function()LeftButton.ImageColor3 = LiftedColor end)
	
	--Right button pressed/lifted
	RightButton.MouseButton1Down:connect(function()Steer = 1 RightButton.ImageColor3 = PressedColor end)
	RightButton.MouseButton1Up:connect(function()Steer = 0 RightButton.ImageColor3 = LiftedColor end)
	RightButton.MouseLeave:connect(function()RightButton.ImageColor3 = LiftedColor end)
	
	--Backward button pressed/lifted
	DownButton.MouseButton1Down:connect(function()Direction = -1 DownButton.ImageColor3 = PressedColor end)
	DownButton.MouseButton1Up:connect(function()Direction = 0 DownButton.ImageColor3 = LiftedColor end)
	DownButton.MouseLeave:connect(function()DownButton.ImageColor3 = LiftedColor end)
	
	--Forward button pressed/lifted
	UpButton.MouseButton1Down:connect(function()Direction = 1 UpButton.ImageColor3 = PressedColor end)
	UpButton.MouseButton1Up:connect(function()Direction = 0 UpButton.ImageColor3 = LiftedColor end)
	UpButton.MouseLeave:connect(function()UpButton.ImageColor3 = LiftedColor end)
end

-- Game controller joystick detection
UserInputService.InputChanged:connect(function(Key)
	if Key.KeyCode == Enum.KeyCode.Thumbstick1 then
		local SteerPos = Key.Position.X*0.9
		
		-- Start steering
		if Steer ~= SteerPos and Key.Position.X ~= 0 then
			Steer = SteerPos
		end
		-- Ends steering
		if Key.Position.X > -0.3 and Key.Position.X < 0.3 then
			Steer = 0
		end
	end
end)

-- Gyroscopic controller for mobile device (if enabled)
if UseGyroSteering.Value == true and UserInputService.TouchEnabled == true and UserInputService.GyroscopeEnabled == true then
-- Find the device's rotation via gyroscope and apply to the segway
	UserInputService.DeviceRotationChanged:connect(function(rotation, rotCFrame)
	local x,y = rotCFrame:toEulerAnglesXYZ()
	local Sensitivity = 1.9
	
		-- Direction
		if -x*Sensitivity > -1 and -x*Sensitivity < 1 then -- Makes sure the device isn't tilted too much
			Direction = -x*Sensitivity+0.4
		elseif -x*Sensitivity > 0 then -- Otherwise we'll go to the max speed
			Direction = 1
		elseif -x*Sensitivity < 0 then -- Otherwise we'll go to the max speed
			Direction = -1
		end
			
		-- Steering
		if -y*Sensitivity > -1 and -y*Sensitivity < 1 then -- Makes sure the device isn't tilted too much
			Steer = -y*Sensitivity
		elseif -y*Sensitivity > 0 then -- Otherwise we'll go to the max speed
			Steer = 1
		elseif -y*Sensitivity < 0 then -- Otherwise we'll go to the max speed
			Steer = -1
		end
	end)
end

-- If using VR
if UserInputService.VREnabled and VRUseHeadsetControls.Value == true then
	VRService.UserCFrameChanged:connect(function(CFrametype,VRSpot)
		local x,y = VRSpot:toEulerAnglesXYZ()
		local Sensitivity = 1.2
		
		if CFrametype == Enum.UserCFrame.Head then
			-- Direction
			if -x*Sensitivity > -1 and -x*Sensitivity < 1 then -- Makes sure the headset isn't tilted too much
				Direction = -x*Sensitivity
			elseif -x*Sensitivity > 0 then -- Otherwise we'll go to the max speed
				Direction = 1
			elseif -x*Sensitivity < 0 then -- Otherwise we'll go to the max speed
				Direction = -1
			end
				
			-- Steering
			if -y > -1 and -y < 1 then -- Makes sure the headset isn't tilted too much
				Steer = -y
			elseif -y > 0 then -- Otherwise we'll go to the max speed
				Steer = 1
			elseif -y < 0 then -- Otherwise we'll go to the max speed
				Steer = -1
			end
		end
	end)
end

UserInputService.InputBegan:connect(function(Key,ProcessedEvent)
	if WeldObject.Value ~= nil then
		
		-- Hop off segway if press Spacebar, Backspace or controller A button
		if Key.KeyCode == Enum.KeyCode.Space or Key.KeyCode == Enum.KeyCode.Backspace or Key.KeyCode == Enum.KeyCode.ButtonA then	
			Hopoff()
		end
		
		--Forward
		if Key.KeyCode == Enum.KeyCode.W or Key.KeyCode == Enum.KeyCode.Up or Key.KeyCode == Enum.KeyCode.ButtonR2 then
			if Direction ~= 1 then
			Direction = 1
			end
		end
		
		--Backward
		if Key.KeyCode == Enum.KeyCode.S or Key.KeyCode == Enum.KeyCode.Down or Key.KeyCode == Enum.KeyCode.ButtonL2 then
			if Direction ~= -1 then
			Direction = -1
			end
		end
		
		--Left
		if Key.KeyCode == Enum.KeyCode.D or Key.KeyCode == Enum.KeyCode.Right then
			if Steer ~= 1 then
			Steer = 1
			end
		end
		
		--Right
		if Key.KeyCode == Enum.KeyCode.A or Key.KeyCode == Enum.KeyCode.Left then
			if Steer ~= -1 then
			Steer = -1
			end
		end
	end
end)

--Mobile control
function CheckMobile()
	if UserInputService.TouchEnabled == true and UseGyroSteering.Value == false then -- Won't show mobile guis if gyro is enabled
		UserInputService.ModalEnabled = true
		GuiControls.Parent = PlayerGui
	end
end

function CheckVR()
	if UserInputService.VREnabled then
		UpdateVRPos()
		
		-- Hide tool UI using VR
		if PlayerGui and PlayerGui:FindFirstChild("DisplayGui") and PlayerGui:FindFirstChild("ColorGui") then
			PlayerGui:FindFirstChild("DisplayGui").Enabled = false
			PlayerGui:FindFirstChild("ColorGui").Enabled = false
		end
		UpdateCharTrans(1,0)	
	end
end

UserInputService.InputEnded:connect(function(Key)
	if WeldObject.Value ~= nil then
		--Ends Accelerate
		if Key.KeyCode == Enum.KeyCode.W or Key.KeyCode == Enum.KeyCode.Up or Key.KeyCode == Enum.KeyCode.ButtonR2 then
			if Direction == 1 then
			Direction = 0
			end
		end
		if Key.KeyCode == Enum.KeyCode.S or Key.KeyCode == Enum.KeyCode.Down or Key.KeyCode == Enum.KeyCode.ButtonL2 then
			if Direction == -1 then
			Direction = 0
			end
		end
			--Ends Steer
			if Key.KeyCode == Enum.KeyCode.D or Key.KeyCode == Enum.KeyCode.Right then
				if Steer == 1 then
				Steer = 0
				end
			end
			if Key.KeyCode == Enum.KeyCode.A or Key.KeyCode == Enum.KeyCode.Left then
				if Steer == -1 then
				Steer = 0
				end
			end
	end
end)

-- Must have hopped on a segway
SegwayObject.Changed:connect(function()
	if SegwayObject.Value ~= nil and SegwayObject.Value.Parent then
		if UserInputService.VREnabled then
			Camera.CameraType = "Scriptable"
		else
			Camera.CameraType = "Follow"
		end
		Lights = SegwayObject.Value:WaitForChild("Lights")
		Notifiers = SegwayObject.Value:WaitForChild("Notifiers")
		Character = Player.Character
		Humanoid = Character:WaitForChild("Humanoid")
		PlayerGui = Player.PlayerGui
		SitListener = Humanoid.Seated:connect(function()Hopoff(Character)end)
		JumpListener = UserInputService.JumpRequest:connect(function()Hopoff(Character)end)
		ConfigLights:FireServer(0,"Cyan",true,"Neon",Lights,Notifiers)
		CheckMobile()
		CheckVR()
		IsOnSegway = true
	end
end)

SetGuiButtons()

while game:GetService("RunService").RenderStepped:wait() do
	
	-- Update segway's bottom direction
	CastToGround()
	
	if SegwayObject.Value and SegwayObject.Value.Parent and SeaterObject.Value and Thruster.Value and TiltMotor.Value then
	
		-- Move segway
		Accelerate()
			
		-- Change sound of segway
		Sound()
			
		-- Tilts the segway
		Tilt()
		
		UpdateVRPos()
	
	elseif IsOnSegway then
		IsOnSegway = false
		UpdateCharTrans(0,0)
	end
	
end
-- Segway control script
-- By Q_Q