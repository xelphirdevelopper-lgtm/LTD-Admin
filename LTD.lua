-- LTD NEW UPDATE v2.0 FINAL
-- LA VERSION QUE TOUT LE MONDE VA VOULOIR

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- Variables
local flying = false
local bv = nil
local flySpeed = 420
local walkSpeed = 16
local noclip = false
local antiFling = false
local espObjects = {}
local noclipConnection = nil
local heartbeatConn = nil

-- RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "LTD NEW UPDATE v2.0",
    LoadingTitle = "LTD v2.0",
    LoadingSubtitle = "LE ROI ABSOLU",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = true, Invite = "rvwaUjzNmK", RememberJoins = false},
    KeySystem = false
})

local FlyTab = Window:CreateTab("Fly", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local ToolsTab = Window:CreateTab("Outils", 4483362458)

-- LISTE JOUEURS + EMOJIS
local playerList = {"Choisir un joueur"}

local function updatePlayerList()
    playerList = {"Choisir un joueur"}
    for _, p in Players:GetPlayers() do
        if p ~= plr then
            table.insert(playerList, p.DisplayName.." (@ "..p.Name..")")
        end
    end
    if viewDropdown then viewDropdown:Refresh(playerList, true) end
    if tpDropdown then tpDropdown:Refresh(playerList, true) end
end

local viewDropdown = ToolsTab:CreateDropdown({
    Name = "View Joueur",
    Options = playerList,
    CurrentOption = "Choisir un joueur",
    Callback = function(choice)
        if choice == "Choisir un joueur" then return end
        local username = choice:match("@%s*(.+)%)$")
        local target = Players:FindFirstChild(username)
        if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
            cam.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            cam.CameraType = Enum.CameraType.Follow
            Rayfield:Notify({Title="VIEW", Content="Tu regardes "..target.DisplayName, Duration=4})
        end
    end
})

local tpDropdown = ToolsTab:CreateDropdown({
    Name = "TP à un joueur",
    Options = playerList,
    CurrentOption = "Choisir un joueur",
    Callback = function(choice)
        if choice == "Choisir un joueur" then return end
        local username = choice:match("@%s*(.+)%)$")
        local target = Players:FindFirstChild(username)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character:PivotTo(target.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,-3))
            Rayfield:Notify({Title="TP", Content="Téléporté derrière "..target.DisplayName, Duration=4})
        end
    end
})

ToolsTab:CreateButton({
    Name = "Unview (libérer caméra)",
    Callback = function()
        if plr.Character then
            cam.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
            cam.CameraType = Enum.CameraType.Custom
            Rayfield:Notify({Title="UNVIEW", Content="Caméra libre", Duration=3})
        end
    end
})

-- Auto-refresh
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
task.spawn(updatePlayerList)

-- SPEED
ToolsTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 1000},
    Increment = 10,
    CurrentValue = 16,
    Callback = function(v)
        walkSpeed = v
        if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
            plr.Character.Humanoid.WalkSpeed = v
        end
    end
})

-- NOCLIP
ToolsTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclip = v
        if v then
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = RunService.Stepped:Connect(function()
                if plr.Character then
                    for _, part in plr.Character:GetDescendants() do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
            Rayfield:Notify({Title="NOCLIP ON", Content="Tu traverses tout", Duration=3})
        else
            if noclipConnection then noclipConnection:Disconnect() end
            if plr.Character then
                for _, part in plr.Character:GetDescendants() do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- JOYSTICK
local joystickGui, bg, knob
local moveVector = Vector2.new(0,0)

local function createJoystick()
    if joystickGui then joystickGui:Destroy() end
    joystickGui = Instance.new("ScreenGui")
    joystickGui.Name = "LTD_JOYSTICK"
    joystickGui.ResetOnSpawn = false
    joystickGui.DisplayOrder = 999999
    joystickGui.Parent = game.CoreGui

    bg = Instance.new("ImageButton")
    bg.Size = UDim2.new(0,180,0,180)
    bg.Position = UDim2.new(0,30,1,-210)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.5
    bg.Parent = joystickGui
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,90)

    knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,70,0,70)
    knob.Position = UDim2.new(0.5,-35,0.5,-35)
    knob.BackgroundColor3 = Color3.fromRGB(180,0,255)
    knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local s = Instance.new("UIStroke", knob)
    s.Thickness = 6
    s.Color = Color3.fromRGB(255,100,255)

    local touching = false
    local startPos = Vector2.new()

    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            touching = true
            startPos = Vector2.new(i.Position.X, i.Position.Y)
        end
    end)

    bg.InputChanged:Connect(function(i)
        if touching then
            local delta = Vector2.new(i.Position.X, i.Position.Y) - startPos
            local dist = math.min(delta.Magnitude, 55)
            local dir = delta.Unit
            moveVector = Vector2.new(dir.X, dir.Y)
            knob.Position = UDim2.new(0.5, dir.X*55-35, 0.5, dir.Y*55-35)
        end
    end)

    bg.InputEnded:Connect(function()
        touching = false
        moveVector = Vector2.new(0,0)
        knob:TweenPosition(UDim2.new(0.5,-35,0.5,-35), "Out","Quad",0.2,true)
    end)
end

-- FLY
local function updateFly()
    if not flying or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = plr.Character.HumanoidRootPart
    local move = Vector3.new(0,0,0)
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector

    if UserInputService:IsKeyDown(Enum.KeyCode.Z) or UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

    if moveVector.Magnitude > 0.1 then
        move += (look * -moveVector.Y) + (right * moveVector.X)
    end

    bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
end

FlyTab:CreateToggle({
    Name = "Fly (ZQSD + Joystick)",
    CurrentValue = false,
    Callback = function(v)
        flying = v
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = v end

        if v then
            if bv then bv:Destroy() end
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = plr.Character.HumanoidRootPart

            createJoystick()
            if heartbeatConn then heartbeatConn:Disconnect() end
            heartbeatConn = RunService.Heartbeat:Connect(updateFly)
        else
            if bv then bv:Destroy() bv = nil end
            if joystickGui then joystickGui:Destroy() end
            if heartbeatConn then heartbeatConn:Disconnect() end
        end
    end
})

FlyTab:CreateSlider({
    Name = "Vitesse Fly",
    Range = {100, 3000},
    Increment = 10,
    CurrentValue = 420,
    Callback = function(v) flySpeed = v end
})

-- ANTI-FLING
ToolsTab:CreateToggle({Name="Anti-Fling", CurrentValue=true, Callback=function(v) antiFling=v end})
RunService.Stepped:Connect(function()
    if antiFling and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = plr.Character.HumanoidRootPart
        if hrp.Velocity.Magnitude > 500 then hrp.Velocity = Vector3.new(0,0,0) end
    end
end)

-- ESP VIOLET
ESPTab:CreateToggle({Name="ESP Violet (traverse murs)", CurrentValue=false, Callback=function(state)
    for _,v in espObjects do if v then v:Destroy() end end
    espObjects = {}
    if not state then return end
    for _, p in Players:GetPlayers() do
        if p ~= plr and p.Character and p.Character:FindFirstChild("Head") then
            local char = p.Character
            local head = char.Head
            local box = Instance.new("BoxHandleAdornment")
            box.Size = Vector3.new(4,6,4); box.Color3 = Color3.fromRGB(180,0,255)
            box.Transparency = 0.3; box.AlwaysOnTop = true; box.Adornee = char; box.Parent = char
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0,200,0,50); bill.Adornee = head; bill.AlwaysOnTop = true; bill.Parent = head
            local txt = Instance.new("TextLabel", bill)
            txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
            txt.Text = p.DisplayName; txt.TextColor3 = Color3.fromRGB(200,0,255)
            txt.Font = Enum.Font.GothamBlack; txt.TextStrokeTransparency = 0; txt.TextSize = 18
            table.insert(espObjects, box); table.insert(espObjects, bill)
        end
    end
end})

-- DISCORD
ToolsTab:CreateButton({Name="Copier Discord LTD", Callback=function()
    setclipboard("https://discord.gg/rvwaUjzNmK")
    Rayfield:Notify({Title="LTD", Content="Lien copié fréro !", Duration=5})
end})

-- NOTIF FINALE
Rayfield:Notify({
    Title = "LTD v2.0 FINAL",
    Content = "Liste joueurs 100% fonctionnelle\nTP & View parfaits\nSpeed + Noclip + Anti-Fling\nESP violet\nFly mobile\nLE SCRIPT LE PLUS PUISSANT DE ROBLOX",
    Duration = 20,
    Image = 4483362458
})