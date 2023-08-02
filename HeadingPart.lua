local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "World of Shitty anti-exploit", HidePremium = false, IntroEnabled = true, Intro = true, IntroText = "World of Aincrad", SaveConfig = true, ConfigFolder = "OrionTest"})

-- Tabs
local TabAutofarm = Window:MakeTab({
    Name = "Autofarm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SectionAutofarm = TabAutofarm:AddSection({
    Name = "Autofarm"
})

local KillAura = false
local TweenTP = false
local TweenSpeed = 80
local SpecificName = false
local MobName = ""

local tweens = {}
local locationtweens = {}
local Attackable = game.Workspace.Attackable
local LocalPlayer = game.Players.LocalPlayer

-- Toggles
SectionAutofarm:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(Value)
        KillAura = Value
    end
})

SectionAutofarm:AddToggle({
    Name = "Tween To Mob",
    Default = false,
    Callback = function(Value)
        TweenTP = Value
    end
})

SectionAutofarm:AddToggle({
    Name = "Is the tween to mob specific?",
    Default = false,
    Callback = function(Value)
        SpecificName = Value
        if tweens[1] ~= nil then
            pcall(function()
                tweens[1]:Pause() 
                table.remove(tweens,1)
            end)
        end
    end
})

-- Functions
SectionAutofarm:AddSlider({
    Name = "Tween Speed",
    Min = 30,
    Max = 80,
    Default = 80,
    Callback = function(Value)
        TweenSpeed = Value
    end
})

if (game.PlaceId == 9682845902) then -- if floor 1
    SectionAutofarm:AddDropdown({
        Name = "Mob Name",
        Options = {"Boar", "Wolf", "Nepenthes", "Alpha Nepenthes", "Kobold", "King Kobold"},
        Default = "Boar",
        Callback = function(option)
            MobName = option
        end
    })
elseif (game.PlaceId == 9866224500) then -- if floor 2
    SectionAutofarm:AddDropdown({
        Name = "Mob Name",
        Options = {"Stag Beetle", "Hornet", "Rock Golem", "Queen Hornet", "Guardian", "Sentinel"},
        Default = "Stag Beetle",
        Callback = function(option)
            MobName = option
        end
    })
end

-- Main loop to handle the autofarm functionality
while wait() do
    local EXP = LocalPlayer.Stats.Exp

    EXP:GetPropertyChangedSignal("Value"):Connect(function()
        if tweens[1] ~= nil then
            pcall(function()
                tweens[1]:Pause() 
                table.remove(tweens,1)
            end)
        end
    end)

    if KillAura then
        for i,v in pairs(Attackable:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0 and v:FindFirstChildOfClass("MeshPart") then
                pcall(function()
                    if game.Players.LocalPlayer:DistanceFromCharacter(v.HumanoidRootPart.Position) < 30 then
                        local args = {
                            [1] = "Attack",
                            [2] = {
                                [1] = v.Mob
                            }
                        }
                        game:GetService("ReplicatedStorage").RemoteEvents.Hit:FireServer(unpack(args))
						game:GetService("ReplicatedStorage").RemoteEvents.Hit:FireServer(unpack(args))
                    end
                end)
            end
        end
    end

    if TweenTP then

        local function MobTweenCreate(target,distance)
            pcall(function()

                    local tweenInfo = TweenInfo.new(
                        distance/TweenSpeed, -- duration in seconds

                        Enum.EasingStyle.Linear
                    )

                    local tween = game:GetService("TweenService"):Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {
                        CFrame = CFrame.new(target.HumanoidRootPart.CFrame.X,target.HumanoidRootPart.CFrame.Y+10,target.HumanoidRootPart.CFrame.Z)
                    })

                    table.insert(tweens,tween)

                    if #tweens == 0 then MobTweenCreate(target,distance) end
                    tweens[1]:Play()

            end)

        end

        local function LocationTweenCreate(location,distance)
            pcall(function()

                    local tweenInfo = TweenInfo.new(
                        distance/TweenSpeed, -- duration in seconds

                        Enum.EasingStyle.Linear
                    )

                    local tween = game:GetService("TweenService"):Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {
                        CFrame = CFrame.new(location.X,location.Y,location.Z)
                    })

                    table.insert(locationtweens,tween)

                    if #locationtweens == 0 then LocationTweenCreate(target,distance) end
                    locationtweens[1]:Play()

            end)

        end

        local function GenerateLocationToTP(mobtype) 
            local location = nil
            if mobtype == "Rock Golem" or mobtype == "Hornet" then
                location = Vector3.new(-2411.12964, -565.450989, 71.7269745) -- a place where a lot of rock golems and hornets are
            end
            if location == nil then print("mob not added in this list yet, issue being that it's too far") 
            else
                local distance = LocalPlayer:DistanceFromCharacter(location)
                LocationTweenCreate(location,distance)
            end
        end


        local function getClosestObject()
            wait(1)
            local closestDistance = math.huge
            local closestObject = nil
            for _, mob in pairs(Attackable:GetChildren()) do
                pcall(function()
                    if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Mob") then
                        local distance = LocalPlayer:DistanceFromCharacter(mob.HumanoidRootPart.Position)
                        if distance < closestDistance then
                            closestDistance = distance
                            closestObject = mob
                        end
                    else
                        if tweens[1] ~= nil then
                            pcall(function()
                                tweens[1]:Pause() table.remove(tweens,1)
                            end)
                        end
                    end
                end)
            end
            MobTweenCreate(closestObject,closestDistance)
        end

        local function getClosestSpecificObject()
            wait(1)
            local closestDistance = math.huge
            local closestObject = nil
            for _, mob in pairs(Attackable:GetChildren()) do
                if string.lower(mob.Name):match(string.lower(MobName)) then
                    pcall(function()
                        if mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Mob") then
                            local distance = LocalPlayer:DistanceFromCharacter(mob.HumanoidRootPart.Position)
                            if distance < closestDistance then
                                closestDistance = distance
                                closestObject = mob
                            end
                        else
                            if tweens[1] ~= nil then
                                pcall(function()
                                    tweens[1]:Pause() table.remove(tweens,1)
                                end)
                            end
                        end
                    end)
                end
            end
            if closestObject == nil then
                GenerateLocationToTP(MobName) -- this is so "functional" to the point this shouldn't be used... I really want to improve this and overall the tweening, I don't know what's going on in this game with it.
            end
            MobTweenCreate(closestObject,closestDistance)
        end

        if SpecificName == false then
            getClosestObject()
        else
            getClosestSpecificObject()
        end


    end

    if TweenTP == false and ( tweens[1] ~= nil or locationtweens[1] ~= nil ) then
        pcall(function()
            tweens[1]:Pause() table.remove(tweens,1)
            locationtweens[1]:Pause() table.remove(locationtweens,1)
        end)
    end

end