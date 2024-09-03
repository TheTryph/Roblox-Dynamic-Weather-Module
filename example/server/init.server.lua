local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeatherCreator = require(ReplicatedStorage["WeatherModule"])

local WeatherTimeScaleDivisor = 10


local cloudTypes = {
	Clouds = 6,
	Storm = 2,
	HugeCloud = 5,
	SmallCloud = 5,
	--Fog = 1,
}

local CloudyDay = {
	Clouds = 6,
	Storm = 0,
	HugeCloud = 5,
	SmallCloud = 5,
	--Fog = 1,
}
local StormyDay = {
	Clouds = 6,
	Storm = 1,
	HugeCloud = 5,
	SmallCloud = 5,
	--Fog = 1,
}
local RainyDay = {
	Clouds = 0,
	Storm = 7,
	HugeCloud = 0,
	SmallCloud = 0,
	--Fog = 1,
}
local ClearDay = {
	Clouds = 1,
	Storm = 0,
	HugeCloud = 0,
	SmallCloud = 0,
	--Fog = 1,
}

local specificCloudType = nil

local function chooseIndex(multipliersArray)
	local weightedSum = 0
	for i,v in pairs(multipliersArray) do
		weightedSum += v
	end
	local random = Random.new()
	local rnd = random:NextNumber(0,weightedSum)
	for i,v in pairs(multipliersArray) do
		if rnd < v then
			return i
		end
		rnd -= v
	end
end

function getCloudType()
	return chooseIndex(cloudTypes)
end

task.spawn(function()
	while true do
		cloudTypes = ClearDay
		task.wait(150)
		cloudTypes = CloudyDay
		task.wait(20)
		cloudTypes = StormyDay
		task.wait(40)
		cloudTypes = RainyDay
		task.wait(50)
		cloudTypes = CloudyDay
		task.wait(30)
	end

end)



if not specificCloudType then
	while true do
		game.ReplicatedStorage.CloudEvent:FireAllClients(getCloudType(), Vector2.new(math.random(-2500,2500), math.random(-2500, 2500))-(Vector2.new(workspace.GlobalWind.X, workspace.GlobalWind.Z)))
		wait(1/WeatherTimeScaleDivisor)
	end
end
