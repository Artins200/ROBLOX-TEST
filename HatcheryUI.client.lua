-- LocalScript in StarterPlayer > StarterPlayerScripts. No external assets required.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local remote = ReplicatedStorage:WaitForChild("BlockyHatchRemote")
local gui = Instance.new("ScreenGui")
gui.Name = "PetHatchUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local C = Color3.fromRGB
local function tween(obj, duration, props, easing)
    local t = TweenService:Create(obj, TweenInfo.new(duration, easing or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play(); return t
end
local function round(obj, n)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,n); c.Parent = obj
end
local function text(parent, value, size, position, z)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1; l.Size = size; l.Position = position
    l.Font = Enum.Font.GothamBlack; l.Text = value; l.TextColor3 = C(255,245,226)
    l.TextScaled = true; l.TextStrokeTransparency = 0.25; l.ZIndex = z or 3; l.Parent = parent
    return l
end
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(200,58); button.Position = UDim2.new(1,-220,1,-88)
button.BackgroundColor3 = C(255,177,70); button.Text = "✦ КРУТИТЬ ЯЙЦО"; button.TextColor3 = C(39,26,40)
button.Font = Enum.Font.GothamBlack; button.TextScaled = true; button.Parent = gui; round(button,18)
local panel = Instance.new("Frame"); panel.Size = UDim2.fromScale(1,1); panel.BackgroundColor3 = C(12,15,27)
panel.Visible = false; panel.BorderSizePixel = 0; panel.Parent = gui
local title = text(panel,"КАРУСЕЛЬ ЯИЦ",UDim2.fromScale(0.8,0.08),UDim2.fromScale(0.1,0.07))
local subtitle = text(panel,"",UDim2.fromScale(0.9,0.06),UDim2.fromScale(0.05,0.83))
local strip = Instance.new("Frame"); strip.Position = UDim2.fromScale(0.02,0.27); strip.Size = UDim2.fromScale(0.96,0.45)
strip.BackgroundColor3 = C(25,30,47); strip.BorderSizePixel = 0; strip.ClipsDescendants = true; strip.Parent = panel; round(strip,20)
local pointer = text(panel,"▼",UDim2.fromScale(0.06,0.05),UDim2.fromScale(0.47,0.215),5)
pointer.TextColor3 = C(255,210,100)
local reel = Instance.new("Frame"); reel.BackgroundTransparency = 1; reel.Size = UDim2.fromScale(1,1); reel.Parent = strip
local overlay = Instance.new("Frame"); overlay.Size = UDim2.fromScale(1,1); overlay.BackgroundColor3 = C(0,0,0)
overlay.BackgroundTransparency = 1; overlay.BorderSizePixel = 0; overlay.ZIndex = 20; overlay.Parent = panel
local star = text(panel,"✦",UDim2.fromOffset(1,1),UDim2.fromScale(0.5,0.5),21)
star.AnchorPoint = Vector2.new(0.5,0.5); star.TextColor3 = C(255,236,174); star.Visible = false
local scene = Instance.new("ViewportFrame"); scene.Size = UDim2.fromScale(1,1); scene.BackgroundColor3 = C(21,11,19)
scene.BorderSizePixel = 0; scene.Visible = false; scene.ZIndex = 10; scene.Ambient = C(110,79,74); scene.LightColor = C(255,183,120)
scene.LightDirection = Vector3.new(-1,-1,-1); scene.Parent = panel
local sceneText = text(panel,"",UDim2.fromScale(0.9,0.09),UDim2.fromScale(0.05,0.08),12)
local sceneSub = text(panel,"",UDim2.fromScale(0.9,0.07),UDim2.fromScale(0.05,0.83),12)
sceneText.Visible = false; sceneSub.Visible = false
local types = {"ОБЫЧНОЕ", "СНЕЖНОЕ", "ЗОЛОТОЕ", "ОГНЕННОЕ"}
local palettes = {
    ["ОБЫЧНОЕ"] = {C(232,231,224), C(142,104,79), C(255,110,189)},
    ["СНЕЖНОЕ"] = {C(38,117,177), C(21,49,101), C(126,229,255)},
    ["ЗОЛОТОЕ"] = {C(245,186,67), C(255,231,147), C(255,251,215)},
    ["ОГНЕННОЕ"] = {C(48,34,39), C(99,40,35), C(255,103,24)},
}
local function piece(parent, name, size, cf, color, material, shape)
    local p = Instance.new("Part"); p.Name = name; p.Anchored = true; p.CanCollide = false
    p.Size = size; p.CFrame = cf; p.Color = color; p.Material = material or Enum.Material.SmoothPlastic
    if shape then p.Shape = shape end
    p.Parent = parent; return p
end
-- 3D eggs: faceted shell, bright inset gems and themed crowns/cracks.
local function makeEgg(parent, kind, at)
    local model = Instance.new("Model"); model.Name = kind; model.Parent = parent
    local colors = palettes[kind]
    local function p(name, size, cf, color, mat, shape)
        return piece(model, name, size, at * cf, color, mat, shape)
    end
    local core = p("Shell",Vector3.new(3.1,4.2,2.6),CFrame.new(),colors[1],Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    model.PrimaryPart = core
    -- Rings of small plates make the spherical base read as a detailed voxel egg.
    for row = -2,2 do
        local y = row*0.65
        local radius = 1.27 * math.sqrt(1-(y/2.2)^2)
        for i = 0,7 do
            local a = i*math.pi/4
            local pos = Vector3.new(math.sin(a)*radius,y,math.cos(a)*radius*0.84)
            local plate = p("Plate",Vector3.new(0.58,0.55,0.18),CFrame.new(pos)*CFrame.Angles(0,a,0),colors[(i+row)%3 == 0 and 2 or 1],Enum.Material.SmoothPlastic)
            if kind == "ОГНЕННОЕ" and (i+row)%3 == 0 then plate.Color = colors[3]; plate.Material = Enum.Material.Neon; plate.Size = Vector3.new(0.13,0.55,0.21) end
        end
    end
    for i = 0,3 do
        local a = i*math.pi/2
        p("Gem",Vector3.new(0.48,0.48,0.24),CFrame.new(math.sin(a)*1.35,0,math.cos(a)*1.15)*CFrame.Angles(0,a,math.pi/4),colors[3],Enum.Material.Neon)
    end
    if kind == "СНЕЖНОЕ" or kind == "ОГНЕННОЕ" then
        for i = 0,5 do
            local a = i*math.pi/3
            p("CrownSpike",Vector3.new(0.35,1.15,0.35),CFrame.new(math.sin(a)*0.8,1.95,math.cos(a)*0.7)*CFrame.Angles(math.sin(a)*0.35,0,math.cos(a)*-0.35),colors[3],Enum.Material.Neon)
        end
    elseif kind == "ЗОЛОТОЕ" then
        for _, side in ipairs({-1,1}) do
            for i=1,3 do p("Wing",Vector3.new(0.3,0.28,1.1),CFrame.new(side*(1.5+i*0.23),0.4-i*0.28,0)*CFrame.Angles(0,0,side*0.3),colors[2],Enum.Material.Neon) end
        end
    end
    return model
end
local function viewport(parent)
    local v = Instance.new("ViewportFrame"); v.BackgroundTransparency = 1; v.Size = UDim2.fromScale(1,0.8)
    v.Ambient = C(160,160,170); v.LightColor = C(255,238,219); v.LightDirection = Vector3.new(-1,-1,-1); v.Parent = parent
    local camera = Instance.new("Camera"); camera.CFrame = CFrame.lookAt(Vector3.new(7,4,9),Vector3.new(0,0,0)); camera.FieldOfView = 35; camera.Parent = v; v.CurrentCamera = camera
    return v
end
-- Repeated cells, with the chosen cell exactly at the selection pointer when tween finishes.
local function spin(result)
    reel:ClearAllChildren()
    local selected = table.find(types,result.eggType) or 1
    local stopIndex = 12 + selected
    local cellWidth = 0.25
    for i=1,stopIndex+3 do
        local kind = types[(i-1)%4+1]
        local card = Instance.new("Frame"); card.BackgroundTransparency = 1; card.Size = UDim2.fromScale(cellWidth,1)
        card.Position = UDim2.fromScale((i-1)*cellWidth,0); card.Parent = reel
        local v = viewport(card); makeEgg(v,kind,CFrame.new())
        local caption = text(card,kind,UDim2.fromScale(0.96,0.15),UDim2.fromScale(0.02,0.82),2)
        caption.TextColor3 = palettes[kind][3]
    end
    reel.Position = UDim2.fromScale(0.5-cellWidth/2,0)
    subtitle.Text = "СТРЕЛКА ПОКАЖЕТ ВЫПАВШЕЕ ЯЙЦО"
    tween(reel,4,{Position=UDim2.fromScale(0.5-(stopIndex-0.5)*cellWidth,0)},Enum.EasingStyle.Quint).Completed:Wait()
    subtitle.Text = result.eggRarity .. " • " .. result.eggType .. " ЯЙЦО"; task.wait(0.7)
end
local function starTransition()
    star.Visible = true; star.Size = UDim2.fromOffset(30,30)
    tween(star,1.1,{Size=UDim2.fromOffset(1200,1200)},Enum.EasingStyle.Quint)
    task.wait(0.75); tween(overlay,0.65,{BackgroundTransparency=0}); task.wait(0.7)
    star.Visible = false; strip.Visible = false; pointer.Visible = false; title.Visible = false; subtitle.Visible = false
end
local function setupScene()
    scene:ClearAllChildren()
    local camera = Instance.new("Camera"); camera.FieldOfView = 50; camera.Parent = scene; scene.CurrentCamera = camera
    scene.Visible = true; sceneText.Visible = true; sceneSub.Visible = true
    return camera
end
local function revealFire(result)
    local camera = setupScene()
    scene.BackgroundColor3 = C(33,15,19)
    sceneText.Text = "ВУЛКАНИЧЕСКОЕ ЯЙЦО"; sceneSub.Text = "В глубине вулкана рождается магма..."
    -- A stylized volcano, crater and lava lake are local to this cinematic viewport.
    local mountain = Instance.new("Model"); mountain.Parent = scene
    piece(mountain,"Ground",Vector3.new(90,1,90),CFrame.new(0,-1,0),C(35,29,33),Enum.Material.Slate)
    for layer=0,8 do
        local width = 46-layer*4
        piece(mountain,"RockStratum",Vector3.new(width,2.2,width),CFrame.new(0,layer*2,0)*CFrame.Angles(0,math.rad(layer*8),0),C(52+layer*2,40,43),Enum.Material.Slate)
    end
    piece(mountain,"LavaLake",Vector3.new(13,0.3,13),CFrame.new(0,18.2,0),C(255,84,13),Enum.Material.Neon)
    for i=1,8 do
        local a=i*math.pi/4
        piece(mountain,"LavaVein",Vector3.new(0.4,14,0.4),CFrame.new(math.sin(a)*14,8,math.cos(a)*14)*CFrame.Angles(math.cos(a)*0.8,0,-math.sin(a)*0.8),C(255,92,20),Enum.Material.Neon)
    end
    camera.CFrame = CFrame.lookAt(Vector3.new(39,27,48),Vector3.new(0,12,0))
    tween(overlay,0.6,{BackgroundTransparency=1});
    tween(camera,3,{CFrame=CFrame.lookAt(Vector3.new(10,25,13),Vector3.new(0,18,0))},Enum.EasingStyle.Sine).Completed:Wait()
    sceneSub.Text = "Погружаемся в кратер..."
    tween(camera,2,{CFrame=CFrame.lookAt(Vector3.new(0,21,6),Vector3.new(0,14,0))},Enum.EasingStyle.Sine).Completed:Wait()
    -- Build the inside separately so the camera can actually fly beneath the lava surface.
    mountain:Destroy()
    piece(scene,"ChamberFloor",Vector3.new(30,0.5,30),CFrame.new(0,0,0),C(255,75,5),Enum.Material.Neon)
    for i=0,7 do
        local a=i*math.pi/4
        piece(scene,"CavernWall",Vector3.new(12,20,2),CFrame.new(math.sin(a)*13,9,math.cos(a)*13)*CFrame.Angles(0,a,0),C(57,37,40),Enum.Material.Slate)
    end
    camera.CFrame = CFrame.lookAt(Vector3.new(0,9,13),Vector3.new(0,3,0))
    sceneSub.Text = "Яйцо формируется в лаве"
    local egg = makeEgg(scene,"ОГНЕННОЕ",CFrame.new(0,2,0))
    local column = piece(scene,"LavaColumn",Vector3.new(3,0.2,3),CFrame.new(0,0.1,0),C(255,85,10),Enum.Material.Neon,Enum.PartType.Cylinder)
    column.Transparency = 0.5 -- Keep the rising egg visible through the lava.
    -- A vertical neon column: cylinder axis is X, so rotate it upright.
    column.CFrame = CFrame.new(0,0.1,0)*CFrame.Angles(0,0,math.pi/2); column.Size = Vector3.new(0.2,3,3)
    tween(column,2,{Size=Vector3.new(16,3,3),CFrame=CFrame.new(0,8,0)*CFrame.Angles(0,0,math.pi/2)})
    local start = egg:GetPivot(); local rising = Instance.new("NumberValue"); rising.Value = 0
    local connection = rising.Changed:Connect(function(v) if egg.Parent then egg:PivotTo(start*CFrame.new(0,v,0)*CFrame.Angles(0,v*0.2,0)) end end)
    tween(rising,2,{Value=9}).Completed:Wait(); connection:Disconnect(); rising:Destroy()
    tween(camera,1.2,{CFrame=CFrame.lookAt(Vector3.new(7,13,10),Vector3.new(0,10,0))}).Completed:Wait()
    sceneText.Text = "МИФИЧЕСКОЕ МАГМОВОЕ ЯЙЦО"
    sceneSub.Text = result.name .. " • " .. result.rarity
    task.wait(2)
end
local function revealOther(result)
    local camera = setupScene(); scene.BackgroundColor3 = C(20,26,45)
    makeEgg(scene,result.eggType,CFrame.new())
    camera.CFrame = CFrame.lookAt(Vector3.new(8,3,11),Vector3.new(0,0,0))
    sceneText.Text = result.eggRarity .. " • " .. result.eggType .. " ЯЙЦО"; sceneSub.Text = result.name .. " • " .. result.rarity
    tween(overlay,0.6,{BackgroundTransparency=1})
    tween(camera,2,{CFrame=CFrame.lookAt(Vector3.new(5,2,8),Vector3.new(0,0,0))},Enum.EasingStyle.Sine).Completed:Wait()
    task.wait(1.5)
end
local pending = false
button.Activated:Connect(function()
    if pending then return end
    pending = true; button.Text = "ОЖИДАНИЕ..."; remote:FireServer("hatch")
    task.delay(8,function() if pending and not panel.Visible then pending=false; button.Text="✦ КРУТИТЬ ЯЙЦО" end end)
end)
remote.OnClientEvent:Connect(function(action,result)
    if action == "busy" then
        if panel.Visible then return end
        pending = false; button.Text = "ЯЙЦЕМАТ ЗАНЯТ"
        task.delay(2,function() if not pending then button.Text="✦ КРУТИТЬ ЯЙЦО" end end); return
    end
    if action ~= "start" or not result or not palettes[result.eggType] or panel.Visible then return end
    pending = true; button.Visible = false; panel.Visible = true
    strip.Visible = true; pointer.Visible = true; title.Visible = true; subtitle.Visible = true
    overlay.BackgroundTransparency = 1; scene.Visible = false; sceneText.Visible = false; sceneSub.Visible = false
    spin(result); starTransition()
    if result.eggType == "ОГНЕННОЕ" then revealFire(result) else revealOther(result) end
    tween(overlay,0.5,{BackgroundTransparency=0}).Completed:Wait()
    scene.Visible = false; scene:ClearAllChildren(); sceneText.Visible = false; sceneSub.Visible = false
    panel.Visible = false; button.Visible = true; button.Text = "✦ КРУТИТЬ ЯЙЦО"; pending = false
end)
