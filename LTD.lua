repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Variables
local flying = false
local bv = nil
local flySpeed = 420
local noclip = false
local antiFling = true
local espObjects = {}
local noclipConnection = nil
local heartbeatConn = nil

-- AIMBOT
local aimbotEnabled = false
local aimPart = "Head"
local aimSmoothness = 0.15
local aimFOV = 300

-- INFINITE AMMO + RAPID FIRE
local infiniteAmmoEnabled = false
local rapidFireEnabled = false

-- RAYFIELD V2.5
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "LTD v2.5 ULTIME",
    LoadingTitle = "LTD v2.5",
    LoadingSubtitle = "by zelchevt - Rouen 10/11/2025 20:55",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = true, Invite = "rvwaUjzNmK", RememberJoins = false},
    KeySystem = false
})

local FlyTab = Window:CreateTab("Fly", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ToolsTab = Window:CreateTab("Outils", 4483362458)
local CreditsTab = Window:CreateTab("Crédits", 4483362458)

-- CRÉDITS MIS À JOUR COMME TU VEUX
CreditsTab:CreateParagraph({
    Title = "LTD v2.5 - Édition ULTIME",
    Content = "Créé par zelchevt\n\nPseudo Roblox : zelchevt\nUserID : "..plr.UserId.."\n\nCréé le 08 Novembre 2025 - 20:23\nRouen, FR\nMis à jour le 10 Novembre 2025 - 20:55\nRouen, FR\n\nVersion 100% CLEAN - NO CHAT"
})

CreditsTab:CreateButton({
    Name = "Copier zelchevt",
    Callback = function()
        setclipboard("zelchevt")
        Rayfield:Notify({Title="Copié !", Content="zelchevt dans le presse-papier", Duration=3})
    end
})

-- ESP VIOLET
local function clearESP()
    for _, v in pairs(espObjects) do if v and v.Parent then v:Destroy() end end
    espObjects = {}
end

local function createESP(p)
    if p == plr or not p.Character or not p.Character:FindFirstChild("Head") then return end
    local head = p.Character.Head

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4,6,4)
    box.Color3 = Color3.fromRGB(180,0,255)
    box.Transparency = 0.3
    box.AlwaysOnTop = true
    box.Adornee = p.Character
    box.Parent = p.Character
    table.insert(espObjects, box)

    local bill = Instance.new("BillboardGui", head)
    bill.Size = UDim2.new(0,200,0,50)
    bill.Adornee = head
    bill.AlwaysOnTop = true

    local name = Instance.new("TextLabel", bill)
    name.Size = UDim2.new(1,0,1,0)
    name.BackgroundTransparency = 1
    name.Text = p.DisplayName
    name.TextColor3 = Color3.fromRGB(200,0,255)
    name.Font = Enum.Font.GothamBold
    name.TextStrokeTransparency = 0
    name.TextSize = 18
    table.insert(espObjects, bill)
end

ESPTab:CreateToggle({
    Name = "ESP Violet",
    CurrentValue = false,
    Callback = function(v)
        if v then
            clearESP()
            for _, p in Players:GetPlayers() do createESP(p) end
            Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function() task.wait(1) createESP(p) end)
            end)
            Rayfield:Notify({Title="ESP ON", Content="Tous les joueurs visibles !", Duration=4})
        else
            clearESP()
            Rayfield:Notify({Title="ESP OFF", Content="ESP désactivé", Duration=3})
        end
    end
})

-- AIMBOT
local function getClosest()
    local closest = nil
    local dist = aimFOV
    for _, p in Players:GetPlayers() do
        if p ~= plr and p.Character and p.Character:FindFirstChild(aimPart) then
            local pos, onScreen = cam:WorldToViewportPoint(p.Character[aimPart].Position)
            local screenDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
            if screenDist < dist and onScreen then
                dist = screenDist
                closest = p
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild(aimPart) then
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, target.Character[aimPart].Position), aimSmoothness)
        end
    end
end)

AimbotTab:CreateToggle({
    Name = "Aimbot Silencieux",
    CurrentValue = false,
    Callback = function(v)
        aimbotEnabled = v
        Rayfield:Notify({Title = v and "AIMBOT ON" or "AIMBOT OFF", Content = v and "Lock ennemi instant !" or "Aimbot désactivé", Duration = 4})
    end
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = 0.15,
    Callback = function(v) aimSmoothness = v end
})

-- INFINIE BALLES
local function infAmmo()
    if not infiniteAmmoEnabled then return end
    if plr.Character then
        for _, v in plr.Character:GetDescendants() do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                if string.find(v.Name:lower(), "ammo") or string.find(v.Name:lower(), "clip") or string.find(v.Name:lower(), "mag") then
                    v.Value = math.huge
                end
            end
        end
    end
end

ToolsTab:CreateToggle({
    Name = "Infinie Balles",
    CurrentValue = false,
    Callback = function(v)
        infiniteAmmoEnabled = v
        if v then RunService.Heartbeat:Connect(infAmmo) end
        Rayfield:Notify({Title = v and "INFINIE BALLES ON" or "INFINIE BALLES OFF", Content = v and "Jamais à court de balles !" or "Mode normal", Duration = 4})
    end
})

-- RAPID FIRE
local function rapidFire()
    if not rapidFireEnabled or not plr.Character then return end
    local tool = plr.Character:FindFirstChildOfClass("Tool")
    if tool then
        for _, r in tool:GetDescendants() do
            if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end
        end
    end
end

ToolsTab:CreateToggle({
    Name = "Tir Infini",
    CurrentValue = false,
    Callback = function(v)
        rapidFireEnabled = v
        if v then RunService.Heartbeat:Connect(rapidFire) end
        Rayfield:Notify({Title = v and "TIR INFINI ON" or "TIR INFINI OFF", Content = v and "BRRRRRRRRRR !" or "Tir normal", Duration = 4})
    end
})

-- NOCLIP
ToolsTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclip = v
        if v then
            noclipConnection = RunService.Stepped:Connect(function()
                if plr.Character then
                    for _, p in plr.Character:GetDescendants() do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect() end
        end
    end
})

-- FLY + JOYSTICK
local joystickGui, bg, knob
local moveVec = Vector2.new(0,0)

local function createJoystick()
    joystickGui = Instance.new("ScreenGui", game.CoreGui)
    bg = Instance.new("Frame", joystickGui)
    bg.Size = UDim2.new(0,160,0,160)
    bg.Position = UDim2.new(0,30,1,-190)
    bg.BackgroundTransparency = 0.6
    bg.BackgroundColor3 = Color3.new(0,0,0)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

    knob = Instance.new("Frame", bg)
    knob.Size = UDim2.new(0,60,0,60)
    knob.Position = UDim2.new(0.5,-30,0.5,-30)
    knob.BackgroundColor3 = Color3.fromRGB(180,0,255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    knob.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            moveVec = Vector2.new(0,0)
            knob.Position = UDim2.new(0.5,-30,0.5,-30)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(i.Position.X, i.Position.Y) - bg.AbsolutePosition - bg.AbsoluteSize/2
            local mag = math.min(delta.Magnitude, 50)
            moveVec = delta.Unit * (mag/50)
            knob.Position = UDim2.new(0.5,-30 + delta.X, 0.5,-30 + delta.Y)
        end
    end)
end

local function updateFly()
    if not flying or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = plr.Character.HumanoidRootPart
    local dir = Vector3.new(0,0,0)
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += look end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= look end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

    dir = dir + Vector3.new(moveVec.X, 0, -moveVec.Y)
    bv.Velocity = dir.Unit * flySpeed
end

FlyTab:CreateToggle({
    Name = "Fly (ZQSD + Joystick Mobile)",
    CurrentValue = false,
    Callback = function(v)
        flying = v
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character.Humanoid.PlatformStand = v
        end
        if v then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = plr.Character.HumanoidRootPart
            createJoystick()
            heartbeatConn = RunService.Heartbeat:Connect(updateFly)
            Rayfield:Notify({Title="FLY ON", Content="Envole-toi mon reuf !", Duration=5})
        else
            if bv then bv:Destroy() end
            if joystickGui then joystickGui:Destroy() end
            if heartbeatConn then heartbeatConn:Disconnect() end
        end
    end
})

FlyTab:CreateSlider({
    Name = "Vitesse Fly",
    Range = {100, 3000},
    Increment = 50,
    CurrentValue = 420,
    Callback = function(v) flySpeed = v end
})

-- ANTI-FLING
RunService.Stepped:Connect(function()
    if antiFling and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        if hrp.Velocity.Magnitude > 500 then
            hrp.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- NOTIF FINALE
Rayfield:Notify({
    Title = "LTD v2.5 ULTIME CHARGÉ",
    Content = "Infinie balles\nTir infini\nAimbot silencieux\nESP violet\nFly + joystick\nNoclip\nAnti-fling\n\n100% CLEAN - NO CHAT\nCréé le 08/11/2025 20:23\nMis à jour le 10/11/2025 20:55\nRouen, FR",
    Duration = 18,
    Image = 4483362458
})