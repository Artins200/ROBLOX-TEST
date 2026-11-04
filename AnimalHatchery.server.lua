-- BLOCKY PET HATCHERY | place this Script in ServerScriptService, then press Play.
-- Everything is generated at runtime; no models, plugins or asset IDs required.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:FindFirstChild("BlockyHatchRemote")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "BlockyHatchRemote"
    remote.Parent = ReplicatedStorage
end

local old = workspace:FindFirstChild("BlockyPetHatchery")
if old then old:Destroy() end
local world = Instance.new("Folder")
world.Name = "BlockyPetHatchery"
world.Parent = workspace

local function part(parent, name, size, cf, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end
local function tween(obj, time, properties, style, direction)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties)
    t:Play()
    return t
end
local function label(parent, text, size, offset, color)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(size, 75)
    gui.StudsOffset = offset
    gui.AlwaysOnTop = true
    gui.MaxDistance = 100
    gui.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBlack
    l.Text = text
    l.TextColor3 = color or Color3.new(1, 1, 1)
    l.TextStrokeTransparency = 0.25
    l.TextScaled = true
    l.Parent = gui
    return l
end
local C = Color3.fromRGB
local dark = C(40, 43, 51)
local white = C(231, 234, 230)
local pets = {
    {name="ЕНОТИК", weight=32, rarity="ОБЫЧНЫЙ", body=C(150,156,157), accent=C(76,80,86), ears="round", tail="stripe"},
    {name="КОТИК", weight=24, rarity="ОБЫЧНЫЙ", body=C(209,196,180), accent=C(148,129,119), ears="point", tail="long"},
    {name="ЗАЙЧИК", weight=18, rarity="РЕДКИЙ", body=C(227,222,215), accent=C(235,163,180), ears="long", tail="puff"},
    {name="ЛИСЁНОК", weight=13, rarity="РЕДКИЙ", body=C(227,137,77), accent=C(151,81,58), ears="point", tail="fox"},
    {name="ЗОЛОТОЙ КОТИК", weight=5, rarity="ЭПИЧЕСКИЙ", body=C(244,196,85), accent=C(190,127,47), ears="point", tail="long"},
    {name="ВОЛЧОНОК", weight=8, rarity="ЭПИЧЕСКИЙ", body=C(142,159,179), accent=C(77,93,115), ears="point", tail="fox", element="ice"},
    {name="ЛЕДЯНОЙ ДРАКОНЧИК", weight=3, rarity="ЛЕГЕНДАРНЫЙ", body=C(119,213,237), accent=C(55,142,193), ears="point", tail="long", element="ice", dragon=true},
    {name="ЛАВОВЫЙ ДРАКОНЧИК", weight=2, rarity="МИФИЧЕСКИЙ", body=C(100,73,75), accent=C(255,106,45), ears="point", tail="long", element="fire", dragon=true},
}
local function choosePet()
    local total = 0
    for _, data in ipairs(pets) do total += data.weight end
    local roll = Random.new():NextNumber(0, total)
    for _, data in ipairs(pets) do
        roll -= data.weight
        if roll <= 0 then return data end
    end
    return pets[1]
end

-- A model of simple, beveled-looking cuboids, inspired by voxel toy animals.
-- Local coordinates face toward -Z; PivotTo moves the entire anchored model.
local function makePet(data, parent)
    local model = Instance.new("Model")
    model.Name = data.name
    local function block(name, size, pos, color, material)
        return part(model, name, size, CFrame.new(pos), color, material)
    end
    local body = block("Body", Vector3.new(2.25,1.65,2.55), Vector3.new(0,1.38,0.25), data.body)
    model.PrimaryPart = body
    block("Head", Vector3.new(2.55,2.05,1.75), Vector3.new(0,2.45,-1.05), data.body)
    block("FaceMask", Vector3.new(2.58,0.82,0.12), Vector3.new(0,2.42,-1.99), data.accent)
    for _, side in ipairs({-1,1}) do
        block("Eye", Vector3.new(0.25,0.38,0.12), Vector3.new(side*0.62,2.52,-2.08), dark)
        block("EyeSparkle", Vector3.new(0.07,0.08,0.04), Vector3.new(side*0.62-0.04,2.62,-2.15), white, Enum.Material.Neon)
        block("Cheek", Vector3.new(0.28,0.17,0.08), Vector3.new(side*0.92,2.12,-2.09), C(241,169,169))
        local earHeight = data.ears == "long" and 1.55 or 0.8
        block("Ear", Vector3.new(0.62,earHeight,0.55), Vector3.new(side*0.87,3.42+earHeight/2-0.25,-0.95), data.body)
        block("InnerEar", Vector3.new(0.34,earHeight*0.62,0.08), Vector3.new(side*0.87,3.42+earHeight/2-0.25,-1.25), data.accent)
        for _, z in ipairs({-0.58,1.05}) do
            block("Leg", Vector3.new(0.56,0.9,0.62), Vector3.new(side*0.79,0.55,z), data.body)
            block("Paw", Vector3.new(0.6,0.33,0.66), Vector3.new(side*0.79,0.23,z-0.05), data.accent)
        end
        -- Little inset squares give the toy a layered, pixel-art coat.
        for _, z in ipairs({-0.3,0.55,1.25}) do
            block("CoatPatch", Vector3.new(0.045,0.37,0.3), Vector3.new(side*1.14,1.7,z), data.accent).Transparency = 0.55
        end
    end
    block("Muzzle", Vector3.new(0.95,0.65,0.3), Vector3.new(0,1.98,-2.14), white)
    block("Nose", Vector3.new(0.34,0.22,0.1), Vector3.new(0,2.12,-2.34), dark)
    block("Mouth", Vector3.new(0.08,0.18,0.1), Vector3.new(0,1.94,-2.34), dark)
    if data.tail == "puff" then
        block("Tail", Vector3.new(0.8,0.8,0.7), Vector3.new(0,1.55,1.85), white)
    else
        local tailLength = data.tail == "fox" and 1.8 or 1.35
        block("Tail", Vector3.new(0.72,0.72,tailLength), Vector3.new(0,1.55,1.5+tailLength/2), data.accent)
        if data.tail == "stripe" or data.tail == "fox" then
            block("TailTip", Vector3.new(0.76,0.76,0.38), Vector3.new(0,1.55,1.5+tailLength), data.tail == "fox" and white or dark)
            if data.tail == "stripe" then block("TailStripe", Vector3.new(0.75,0.75,0.25), Vector3.new(0,1.55,2), data.body) end
        end
    end
    if data.dragon then
        for _, side in ipairs({-1,1}) do
            local wing = block("Wing", Vector3.new(0.18,1.15,1.3), Vector3.new(side*1.25,2.1,0.35), data.accent, Enum.Material.Neon)
            wing.Transparency = 0.25
            block("Horn", Vector3.new(0.3,0.7,0.3), Vector3.new(side*0.45,3.65,-0.8), white)
        end
    end
    model.Parent = parent
    return model
end

-- Put the station near the spawn when possible, otherwise near the origin.
local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
local origin = spawn and (spawn.Position + Vector3.new(12, 0, 0)) or Vector3.new(0, 0, 0)
local groundY = spawn and (spawn.Position.Y + spawn.Size.Y/2) or 0
local center = Vector3.new(origin.X, groundY, origin.Z)
local base = part(world, "HatcheryBase", Vector3.new(12,0.6,12), CFrame.new(center + Vector3.new(0,0.3,0)), C(45,49,67), Enum.Material.Slate)
base.CanCollide = true
part(world, "Pedestal", Vector3.new(6,0.6,6), CFrame.new(center+Vector3.new(0,0.9,0)), C(94,103,126), Enum.Material.Metal).CanCollide = true
local ring = part(world, "GlowRing", Vector3.new(6.4,0.12,6.4), CFrame.new(center+Vector3.new(0,1.23,0)), C(133,230,255), Enum.Material.Neon)
ring.Transparency = 0.3
local eggPos = center + Vector3.new(0,3.1,0)
local displayEgg = part(world, "Egg", Vector3.new(2.35,3,2.35), CFrame.new(eggPos), C(228,243,247), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
local spot1 = part(world, "EggSpot", Vector3.new(0.7,0.7,0.18), CFrame.new(eggPos+Vector3.new(0.5,0.15,-1.12)), C(124,221,235), Enum.Material.Neon)
local spot2 = part(world, "EggSpot", Vector3.new(0.45,0.45,0.12), CFrame.new(eggPos+Vector3.new(-0.55,-0.4,-1.1)), C(255,177,213), Enum.Material.Neon)
label(displayEgg, "✦ ЯЙЦО ДРУЖБЫ ✦\nБесплатно • 7 питомцев", 300, Vector3.new(0,3.1,0), C(206,246,255))
local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Открыть яйцо"
prompt.ObjectText = "Яйцемат"
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.HoldDuration = 0.5
prompt.MaxActivationDistance = 12
prompt.RequiresLineOfSight = false
prompt.Parent = base

local activePets = {}
local busy = false
local function burst(parent, position, color, count, radius)
    for i = 1, count do
        local rng = Random.new()
        local shard = part(parent, "Spark", Vector3.new(0.25,0.25,0.25), CFrame.new(position), color, Enum.Material.Neon)
        local delta = Vector3.new(rng:NextNumber(-radius,radius),rng:NextNumber(1,radius),rng:NextNumber(-radius,radius))
        tween(shard, 1, {Position=position+delta, Transparency=1, Size=Vector3.new(0.03,0.03,0.03)})
        Debris:AddItem(shard, 1.1)
    end
end
local function effects(folder, data)
    local color = data.element == "fire" and C(255,100,28) or (data.element == "ice" and C(120,230,255) or C(255,205,109))
    local wave = part(folder, "Shockwave", Vector3.new(1,0.2,1), CFrame.new(center+Vector3.new(0,1.4,0)), color, Enum.Material.Neon)
    tween(wave, 1.2, {Size=Vector3.new(18,0.1,18), Transparency=1})
    burst(folder, eggPos, color, 28, 9)
    if data.element == "fire" then
        -- A ring of stylized, temporary volcanoes erupts around the pedestal.
        for i = 1, 6 do
            local a = i*math.pi*2/6
            local pos = center + Vector3.new(math.cos(a)*8,0,math.sin(a)*8)
            local volcano = part(folder, "Volcano", Vector3.new(3,0.1,3), CFrame.new(pos), C(66,53,56), Enum.Material.Slate)
            tween(volcano, 0.55, {Size=Vector3.new(3,3.5,3), Position=pos+Vector3.new(0,1.75,0)})
            for layer = 1, 3 do
                local width = 3.5 - layer * 0.7
                local rock = part(folder, "VolcanoSlope", Vector3.new(width,0.8,width), CFrame.new(pos+Vector3.new(0,2.8+layer*0.65,0)), C(58,49,51), Enum.Material.Slate)
                rock.Transparency = 0.08
            end
            local lava = part(folder, "Lava", Vector3.new(1.3,0.25,1.3), CFrame.new(pos+Vector3.new(0,5,0)), color, Enum.Material.Neon)
            local smoke = Instance.new("Smoke")
            smoke.Color = C(55,49,49)
            smoke.Size = 5
            smoke.RiseVelocity = 9
            smoke.Opacity = 0.5
            smoke.Parent = lava
            for j = 1, 4 do
                local lavaFlow = part(folder, "LavaFlow", Vector3.new(0.2,2.5,0.2), CFrame.new(pos+Vector3.new((j%2==0 and 1 or -1)*0.6,2.7,(j<3 and 1 or -1)*0.6))*CFrame.Angles(math.rad(12),0,math.rad(12)), color, Enum.Material.Neon)
                lavaFlow.Transparency = 0.1
            end
            task.delay(0.5, function() if lava.Parent then burst(folder, lava.Position, color, 8, 5) end end)
        end
    elseif data.element == "ice" then
        for i = 1, 12 do
            local a = i*math.pi*2/12
            local pos = center + Vector3.new(math.cos(a)*7,0,math.sin(a)*7)
            local crystal = part(folder, "IceCrystal", Vector3.new(0.8,0.1,0.8), CFrame.new(pos), color, Enum.Material.Glass)
            crystal.Transparency = 0.25
            local height = 3 + (i%3)
            tween(crystal, 0.6, {Size=Vector3.new(0.8,height,0.8), CFrame=CFrame.new(pos+Vector3.new(0,height/2,0))*CFrame.Angles(0,0,math.rad((i%2 == 0 and 1 or -1)*15))})
        end
    end
end
local function equip(player, data)
    if activePets[player] then activePets[player]:Destroy() end
    local model = makePet(data, world)
    label(model.PrimaryPart, data.name .. "\n" .. data.rarity, 170, Vector3.new(0,3.8,0), C(255,244,184))
    activePets[player] = model
end
local function hatch(player)
    if busy then
        remote:FireClient(player, "busy")
        return
    end
    busy = true
    prompt.Enabled = false
    local data = choosePet() -- Server decides the result, never the client.
    local eggType = data.element == "fire" and "ОГНЕННОЕ" or (data.element == "ice" and "СНЕЖНОЕ" or (data.rarity == "ЭПИЧЕСКИЙ" and "ЗОЛОТОЕ" or "ОБЫЧНОЕ"))
    local eggRarity = ({["ОБЫЧНОЕ"]="ОБЫЧНОЕ", ["СНЕЖНОЕ"]="РЕДКОЕ", ["ЗОЛОТОЕ"]="ЭПИЧЕСКОЕ", ["ОГНЕННОЕ"]="МИФИЧЕСКОЕ"})[eggType]
    remote:FireClient(player, "start", {name=data.name, rarity=data.rarity, eggType=eggType, eggRarity=eggRarity})
    local fx = Instance.new("Folder")
    fx.Name = "HatchEffects"
    fx.Parent = world
    displayEgg.Transparency = 1
    spot1.Transparency = 1
    spot2.Transparency = 1
    local egg = part(fx, "HatchingEgg", Vector3.new(2.35,3,2.35), CFrame.new(eggPos), C(230,245,255), Enum.Material.Neon, Enum.PartType.Ball)
    local light = Instance.new("PointLight")
    light.Color = data.element == "fire" and C(255,100,30) or C(132,226,255)
    light.Range = 18
    light.Brightness = 2
    light.Parent = egg
    for i = 1, 6 do
        local angle = (i%2 == 0 and 1 or -1) * (8+i*3)
        tween(egg, 0.16, {CFrame=CFrame.new(eggPos+Vector3.new(0,i*0.13,0))*CFrame.Angles(0,0,math.rad(angle)), Size=Vector3.new(2.35,3,2.35)*(1+i*0.045)})
        task.wait(0.17)
    end
    -- Keep the station locked while the client cinematic is playing.
    tween(egg, 0.5, {Transparency=1})
    task.wait(14)
    local reveal = makePet(data, fx)
    reveal:PivotTo(CFrame.new(eggPos+Vector3.new(0,1,0))*CFrame.Angles(0,math.pi,0))
    label(reveal.PrimaryPart, "✦ "..data.rarity.." ✦\n"..data.name, 280, Vector3.new(0,4,0), C(255,232,151))
    task.wait(2.8)
    if player.Parent then equip(player, data) end
    fx:Destroy()
    displayEgg.Transparency = 0
    spot1.Transparency = 0
    spot2.Transparency = 0
    prompt.Enabled = true
    busy = false
end
prompt.Triggered:Connect(hatch)
remote.OnServerEvent:Connect(function(player, action)
    if action == "hatch" then hatch(player) end
end)
Players.PlayerRemoving:Connect(function(player)
    if activePets[player] then activePets[player]:Destroy(); activePets[player] = nil end
end)
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    for player, model in pairs(activePets) do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and model.Parent then
            local target = root.CFrame * CFrame.new(3, -1.5 + math.sin(now*3)*0.18, 3)
            -- Preserve the pet's upright stance, facing the same direction as the player.
            model:PivotTo(model:GetPivot():Lerp(target, 0.12))
        end
    end
end)
