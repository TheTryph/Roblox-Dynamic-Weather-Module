local Weather = {}
Weather.__index = Weather
local Configuration = require(script.Config)
Weather.timeScaleDivisor = Configuration.timeScaleDivisor

local Tween = TweenInfo.new(100/Weather.timeScaleDivisor, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local CloudsHeight = Configuration.CloudsHeight

type CloudDescription = {	
}

type GroupCloudDescription = {
	Clouds : {{any}},
	Duration : number
}

export type cloudTypes = "SmallCloud" | "Storm" | "Clouds" | "Fog" | "HugeCloud" | "SuperCell"

export type Weather = {
	Cloud: (Weather, CloudType : cloudTypes, v2p: Vector2) -> nil
}

local CloudTypes : {GroupCloudDescription} = {
	SmallCloud = {
		Clouds = {
			{Vector2.new(0,0), 0, Vector3.new(100,100,100), .1, 1}
		},
		Duration = 190
	},
	Storm = {
		Clouds = {
			{Vector2.new(0,25), 50, Vector3.new(200,100,200), .1, 1},
			{Vector2.new(0,25), 125, Vector3.new(1000,500,1000), .1, 1},
			{Vector2.new(0,50), 800, Vector3.new(1500,2000,1500), .4, 1},
			{Vector2.new(0,0), 0, Vector3.new(900,50,900), 0, 1, "RainCloud"},
		},
		Duration = 450
		
	},
	Clouds = {
		Clouds = {
			{Vector2.new(math.random(-500, 500), math.random(-500, 500)), 0, Vector3.new(100, 100, 100), .1, 1},
			{Vector2.new(math.random(-500, 500), math.random(-500, 500)), 0, Vector3.new(100, 100, 100), .1, 1},
			{Vector2.new(math.random(-500, 500), math.random(-500, 500)), 0, Vector3.new(100, 100, 100), .1, 1},
			{Vector2.new(math.random(-500, 500), math.random(-500, 500)), 0, Vector3.new(100, 100, 100), .1, 1},
			{Vector2.new(math.random(-500, 500), math.random(-500, 500)), 0, Vector3.new(100, 100, 100), .1, 1},
		},
		Duration = 70
		
	},
	Fog = {
		Clouds = {
			{Vector2.new(0,0), -150, Vector3.new(500,250,500), 0, 1, "FogCloud"}
		},
		Duration = 250
		
	},
	HugeCloud = {
		Clouds = {
			{Vector2.new(0,25), 50, Vector3.new(200,100,200), .1, 1},
			{Vector2.new(0,25), 125, Vector3.new(1000,500,1000), .1, 1},
			{Vector2.new(0,50), 800, Vector3.new(1500,2000,1500), .4, 1},
			{Vector2.new(0,0), 0, Vector3.new(900,50,900), 0, .5},
		},
		Duration = 900,
	},
	SuperCell = {
		Clouds = {
			{Vector2.new(0,25), 50, Vector3.new(200,100,200), .1, 1},
			{Vector2.new(0,25), 125, Vector3.new(1000,500,1000), .1, 1},
			{Vector2.new(0,50), 800, Vector3.new(1500,2000,1500), .4, 1},
		},
		Duration = 900,
	}
}



local CloudDescription = {
	["NormalCloud"] = function(cloud)

	end,
	["RainCloud"] = function(cloud)
		cloud.Color = Color3.new(0.67451, 0.67451, 0.67451)
		local rainParticle = script:FindFirstChild("Assets").RainParticle:Clone()
		rainParticle.Parent = cloud
		TweenService:Create(rainParticle, Tween, {
			ExtentsOffset = Vector3.new(0, -100, 0)
		}):Play()
	end,
}

function checkIfPartInBounds(part)
	local parts = workspace:GetPartBoundsInBox(CFrame.new(0,0,0), Vector3.new(7000, 5000, 7000))
	for i,v in pairs(parts) do
		if v == part then
			return true
		end
	end
	return false
end
-- Creation
function Weather.new()
	local self = setmetatable({}, Weather)
	self.CloudsFolder = Instance.new('Folder', workspace)
	self.CloudsFolder.Name = "Clouds"
	Tween = TweenInfo.new(30/Weather.timeScaleDivisor, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	for i,v in pairs(CloudDescription) do
		CollectionService:GetInstanceAddedSignal(i):Connect(function(instanceAdded)
			v(instanceAdded)
		end)
	end
	game["Run Service"].Heartbeat:Connect(function()
		for i,v in pairs(CollectionService:GetTagged("FloatingObject")) do
			v:PivotTo(CFrame.new(v.WorldPivot.Position + workspace.GlobalWind * Weather.timeScaleDivisor))
			if Configuration.Debug.destroyItemsOutsideBounds then
				if not checkIfPartInBounds(v) then
					v:Destroy()
				end
			end
		end
	end)
	return self
end

function RainPart()
	local rainingPart = Instance.new("Part")
    rainingPart.Parent = workspace
	rainingPart.Transparency = 1
	rainingPart.CanCollide = false
	rainingPart.Anchored = true
	rainingPart.Size = Vector3.new(160, 1, 160)

	local RainingParticle = Instance.new("ParticleEmitter")
    RainingParticle.Parent = rainingPart
	RainingParticle.Acceleration = Vector3.new(0,-94.4, 0)
	RainingParticle.Speed = NumberRange.new(0)
	RainingParticle.Rate = 2000
	RainingParticle.Lifetime = NumberRange.new(20)
	RainingParticle.LockedToPart = true
	RainingParticle.Texture = "rbxassetid://902899241"
	RainingParticle.Size = NumberSequence.new(10)
	RainingParticle.Transparency = NumberSequence.new(.5)
	
	game["Run Service"]:BindToRenderStep("Rain", 100, function()
		rainingPart.Position = workspace.CurrentCamera.CFrame.Position + Vector3.new(0, 50, 0)
	end)
	
	local accessiblity = {
		rainingPart = rainingPart,
		rainingParticle = RainingParticle,
		toggleParticle = function(toggle)
			RainingParticle.Enabled = toggle
		end,
	}
	
	return accessiblity
end

function Weather.ClientInitiate()
	local tweener = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local tweenIn = TweenService:Create(game.Lighting.Atmosphere, tweener, {Density = 0.7, Haze = 10})
	local tweenOut = TweenService:Create(game.Lighting.Atmosphere, tweener, {Density = game.Lighting.Atmosphere.Density, Haze = game.Lighting.Atmosphere.Haze})
	
	local rain = RainPart()
	
	game["Run Service"].RenderStepped:Connect(function()
		local parts = workspace:GetPartBoundsInBox(CFrame.new(game.Workspace.CurrentCamera.CFrame.Position), Vector3.new(900,2000,900))
		
		local raining = false
		for _,v in pairs(parts) do
			if CollectionService:HasTag(v, "RainCloud") then
				raining = true
			end
			if CollectionService:HasTag(v, "FogCloud") then
				raining = true
			end
		end
		if raining then
			rain.toggleParticle(true)
			tweenIn:Play()
			tweenOut:Cancel()
		else
			rain.toggleParticle(false)
			tweenIn:Cancel()
			tweenOut:Play()
		end
	end)
	
end

-- Sets Clouds Properties

-- SetCloudScale
function Weather:SetCloudScale(Cloud, Vector3Scale)
	TweenService:Create(Cloud.Mesh, Tween, {Scale = Vector3Scale}):Play()
end

-- SetBruteCloudPosition
function Weather:SetBruteCloudPosition(Cloud, v2p)
	local Position = Vector3.new(v2p.x, CloudsHeight, v2p.y)
	Cloud.Position = Position
end

-- SetCloudPositionAndHeight
function Weather:SetCloudPositionAndHeight(Cloud, v2p, height)
	local Pos = Vector3.new(v2p.x, height, v2p.y)
	TweenService:Create(Cloud, Tween, {
		Position = Pos,
	}):Play()
end

-- Gets Clouds Properties

-- GetCloudScale
function Weather:GetCloudScale(Cloud)
	return Cloud.Mesh.Scale
end

-- GetCloudPosition
function Weather:GetCloudPosition(Cloud)
	local Position = Vector2.new(Cloud.Position.X, Cloud.Position.Z)
	return Position
end

-- GetCloudHeight
function Weather:GetCloudHeight(Cloud)
	return Cloud.Position.Y
end

-- Cloud Creation Methods

function Weather:CreateCloud(dur)
	local Cloud = script:FindFirstChild("Assets").Cloud:Clone()
	TweenService:Create(Cloud, Tween, {Transparency = 0}):Play()
	Cloud.Parent = workspace
	spawn(function()
		wait(dur/Weather.timeScaleDivisor)
		TweenService:Create(Cloud, Tween, {Transparency = 1}):Play()
		wait(Tween.Time)
		Cloud:Destroy()
	end)
	return Cloud
end

function Weather:Cloud(CloudTypeName, v2p)
	spawn(function()
		local CloudType = CloudTypes[CloudTypeName]
		if not  CloudType then return end
		local cloudDuration = CloudType.Duration
		local model = Instance.new("Model", self.CloudsFolder)
		model.ChildRemoved:Connect(function()
			if #model:GetChildren() == 0 then
				model:Destroy()
			end
		end)
		model.WorldPivot = CFrame.new(Vector3.new(v2p.x, 100, v2p.y))
		for i,cldsDesc in pairs(CloudType.Clouds) do
			
			local offset = cldsDesc[1]
			local heightoffset = cldsDesc[2]
			local scale = cldsDesc[3]
			local waitValue = cldsDesc[4] * cloudDuration
			local durationperiod = cldsDesc[5] * cloudDuration
			local tag = cldsDesc[6]
			

			local Cloud = Weather:CreateCloud(durationperiod)
			Cloud.Parent = model
			
			-- set the cloud's actual position
			Weather:SetBruteCloudPosition(Cloud, Vector2.new(model.WorldPivot.Position.X, model.WorldPivot.Position.Z))
			
			wait()
			
			-- set the cloud's scale
			Weather:SetCloudScale(Cloud, scale)
			-- set the cloud's offset and height
			Weather:SetCloudPositionAndHeight(Cloud, Vector2.new(model.WorldPivot.Position.X, model.WorldPivot.Position.Z)+offset, Weather:GetCloudHeight(Cloud)+heightoffset)
			
			CollectionService:AddTag(Cloud, tag or "NormalCloud")
			CollectionService:AddTag(model, "FloatingObject")
			
			wait(waitValue/Weather.timeScaleDivisor)
			
		end
	end)
	
end

return Weather