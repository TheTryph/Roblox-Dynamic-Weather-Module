local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeatherCreator = require(ReplicatedStorage.WeatherModule)

local WeatherTimeScaleDivisor = 10

WeatherCreator.timeScaleDivisor = WeatherTimeScaleDivisor

local Weather : WeatherCreator.Weather = WeatherCreator.new()
local dayNightCycle = false

WeatherCreator.ClientInitiate()

game.ReplicatedStorage.CloudEvent.OnClientEvent:Connect(function(CloudType, Vector2Pos)
	Weather:Cloud(CloudType, Vector2Pos)
end)