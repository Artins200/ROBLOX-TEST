-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("BlockyHatchRemote")
local gui = Instance.new("ScreenGui")
gui.Name = "PetHatchUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
local function tween(obj, duration, props)
    local t = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end
local function corner(obj, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius); c.Parent = obj
end
local function text(parent, value, size, position, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.Size = size; l.Position = position
    l.Font = Enum.Font.GothamBlack; l.Text = value; l.TextColor3 = color or Color3.new(1,1,1)
    l.TextScaled = true; l.TextStrokeTransparency = 0.3; l.Parent = parent
    return l
end
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(200, 58); button.Position = UDim2.new(1,-220,1,-88)
button.BackgroundColor3 = Color3.fromRGB(255,177,70); button.Text = "✦ КРУТИТЬ ЯЙЦО"
button.TextColor3 = Color3.fromRGB(39,26,40); button.Font = Enum.Font.GothamBlack; button.TextScaled = true
button.Parent = gui; corner(button, 18)
local padding = Instance.new("UIPadding"); padding.PaddingLeft = UDim.new(0,10); padding.PaddingRight = UDim.new(0,10); padding.Parent = button
local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(1,1); panel.BackgroundColor3 = Color3.fromRGB(13,17,33); panel.BackgroundTransparency = 0.12
panel.Visible = false; panel.Parent = gui
local title = text(panel, "ПРОКРУТКА ЯЙЦА", UDim2.new(0.8,0,0.09,0), UDim2.new(0.1,0,0.07,0))
local subtitle = text(panel, "", UDim2.new(0.8,0,0.06,0), UDim2.new(0.1,0,0.82,0), Color3.fromRGB(255,220,142))
local egg = Instance.new("Frame")
egg.AnchorPoint = Vector2.new(0.5,0.5); egg.Position = UDim2.fromScale(0.5,0.48); egg.Size = UDim2.fromOffset(160,205)
egg.BorderSizePixel = 0; egg.Parent = panel
local eggCorner = Instance.new("UICorner"); eggCorner.CornerRadius = UDim.new(0.5,0); eggCorner.Parent = egg
local aspect = Instance.new("UIAspectRatioConstraint"); aspect.AspectRatio = 160/205; aspect.Parent = egg
local shine = Instance.new("Frame"); shine.BackgroundColor3 = Color3.new(1,1,1); shine.BackgroundTransparency = 0.55
shine.BorderSizePixel = 0; shine.Size = UDim2.fromScale(0.15,0.32); shine.Position = UDim2.fromScale(0.22,0.19); shine.Rotation = 25; shine.Parent = egg; corner(shine, 30)
local mark = text(egg, "✦", UDim2.fromScale(0.45,0.4), UDim2.fromScale(0.28,0.37), Color3.fromRGB(126,219,235))
local flash = Instance.new("Frame"); flash.BackgroundColor3 = Color3.new(1,1,1); flash.BackgroundTransparency = 1
flash.Size = UDim2.fromScale(1,1); flash.BorderSizePixel = 0; flash.ZIndex = 10; flash.Parent = panel
local styles = {
    ["ОБЫЧНОЕ"] = {Color3.fromRGB(234,240,232), Color3.fromRGB(128,210,227), "✦"},
    ["СНЕЖНОЕ"] = {Color3.fromRGB(180,231,255), Color3.fromRGB(60,155,237), "❄"},
    ["ЗОЛОТОЕ"] = {Color3.fromRGB(255,203,70), Color3.fromRGB(255,243,172), "★"},
    ["ОГНЕННОЕ"] = {Color3.fromRGB(75,50,50), Color3.fromRGB(255,112,31), "✹"},
}
local function style(name)
    local s = styles[name]; egg.BackgroundColor3 = s[1]; mark.TextColor3 = s[2]; mark.Text = s[3]
end
local function explode(color)
    flash.BackgroundColor3 = color; flash.BackgroundTransparency = 0.15
    tween(flash, 0.55, {BackgroundTransparency=1})
    for i = 1, 16 do
        local particle = Instance.new("Frame")
        particle.AnchorPoint = Vector2.new(0.5,0.5); particle.Position = UDim2.fromScale(0.5,0.48)
        particle.Size = UDim2.fromOffset(10,10); particle.BorderSizePixel = 0; particle.BackgroundColor3 = color
        particle.Rotation = i*23; particle.Parent = panel; corner(particle,3)
        local a = i*math.pi*2/16
        tween(particle, 0.65, {Position=UDim2.fromScale(0.5+math.cos(a)*0.34,0.48+math.sin(a)*0.32), BackgroundTransparency=1, Rotation=i*23+160})
        game:GetService("Debris"):AddItem(particle, 0.7)
    end
end
local pending = false
button.Activated:Connect(function()
    if pending then return end
    pending = true; button.Text = "ОЖИДАНИЕ..."
    remote:FireServer("hatch")
    -- Recover if the server is unavailable or rejects the request.
    task.delay(8, function() if pending and not panel.Visible then pending = false; button.Text = "✦ КРУТИТЬ ЯЙЦО" end end)
end)
remote.OnClientEvent:Connect(function(action, result)
    if action == "busy" then
        pending = false; button.Text = "ЯЙЦЕМАТ ЗАНЯТ"
        task.delay(2, function() if not pending then button.Text = "✦ КРУТИТЬ ЯЙЦО" end end)
        return
    end
    if action ~= "start" or not result then return end
    pending = true; panel.Visible = true; button.Visible = false
    title.Text = "ПРОКРУТКА ЯЙЦА"; subtitle.Text = "Какая стихия выпадет?"
    local names = {"ОБЫЧНОЕ", "СНЕЖНОЕ", "ЗОЛОТОЕ", "ОГНЕННОЕ"}
    for i = 1, 16 do
        local name = names[(i-1)%#names+1]
        style(name); subtitle.Text = name .. " ЯЙЦО"; egg.Rotation = (i%2==0 and 12 or -12)
        task.wait(0.055 + i*0.007)
    end
    style("ОБЫЧНОЕ"); egg.Rotation = 0; subtitle.Text = "ЯЙЦО ПРОБУЖДАЕТСЯ..."
    explode(styles["ОБЫЧНОЕ"][2]); task.wait(0.5)
    -- This is a cinematic buildup, not a claim about the actual drop rarity.
    title.Text = "МАГИЯ ПРОБУЖДАЕТСЯ"
    for _, stage in ipairs({{"СВЕРХРЕДКАЯ",Color3.fromRGB(99,207,255)}, {"ЭПИЧЕСКАЯ",Color3.fromRGB(190,110,255)}, {"ЛЕГЕНДАРНАЯ",Color3.fromRGB(255,210,70)}, {"МИФИЧЕСКАЯ",Color3.fromRGB(255,90,45)}}) do
        if stage[1] == "МИФИЧЕСКАЯ" then style(result.eggType) end
        subtitle.Text = stage[1] .. " ЭНЕРГИЯ!"; subtitle.TextColor3 = stage[2]
        egg.Rotation = egg.Rotation == 0 and 12 or -egg.Rotation
        explode(stage[2]); task.wait(0.3)
    end
    title.Text = result.rarity .. " ПИТОМЕЦ!"; subtitle.Text = result.name .. " • " .. result.eggType .. " ЯЙЦО"
    subtitle.TextColor3 = Color3.fromRGB(255,220,142); egg.Rotation = 0
    explode(styles[result.eggType][2]); task.wait(2)
    panel.Visible = false; button.Visible = true; button.Text = "✦ КРУТИТЬ ЯЙЦО"; pending = false
end)
