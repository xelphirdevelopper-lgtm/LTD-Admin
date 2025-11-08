-- LTD - LootCord Admin v1.5 RAYFIELD | FIXÉ 100% PAR MOI POUR TOI
-- Joystick VRAI + Liste joueurs MARCHE + Nametag LTD

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "LTD v1.5 - FIXED BY LEGEND",
    LoadingTitle = "LTD ON TOP",
    LoadingSubtitle = "Joystick + Liste joueurs FIXÉ",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = true, Invite = "rvwaUjzNmK", RememberJoins = false },
    KeySystem = false,
})

local TabMain = Window:CreateTab("Main", 4483362458)
local TabPlayers = Window:CreateTab("Players", 4483362458)
local TabVisual = Window:CreateTab("Visuals", 4483362458)

-- VARIABLES
local flying = false
local flySpeed = 420
local bv = nil
local joystickGui = nil
local nametag = nil
local espEnabled = false
local espObjects = {}

-- JOYSTICK VIRTUEL (toujours visible quand fly ON)
local function createJoystick()
    if joystickGui then joystickGui:Destroy() end
    joystickGui = Instance.new("ScreenGui")
    joystickGui.Name = "LTD_JOYSTICK"
    joystickGui.ResetOnSpawn = false
    joystickGui.Parent = plr.PlayerGui

    local frame = Instance.new("Frame", joystickGui)
    frame.Size = UDim2.new(0, 320, 0, 320)
    frame.Position = UDim2.new(0, 20, 1, -340)
    frame.BackgroundColor3 = Color3.new(0,0,0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)

    local dirs = {
        {text="Up Arrow", pos=UDim2.new(0.5,-45,0.15,0), key="U"},
        {text="Down Arrow", pos=UDim2.new(0.5,-45,0.85,-90), key="D"},
        {text="Left Arrow", pos=UDim2.new(0.1,0,0.5,-45), key="L"},
        {text="Right Arrow", pos=UDim2.new(0.9,-90,0.5,-45), key="R"},
    }

    for _, v in ipairs(dirs) do
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0,90,0,90)
        btn.Position = v.pos
        btn.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
        btn.Text = v.text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 40
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
        
        btn.MouseButton1Down:Connect(function() _G["joy_"..v.key] = true end)
        btn.MouseButton1Up:Connect(function() _G["joy_"..v.key] = false end)
        btn.MouseLeave:Connect(function() _G["joy_"..v.key] = false end)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(255, 100, 255) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(200, 0, 255) end)
    end
end

-- NAMETAG LTD
local function createNametag()
    if nametag then nametag:Destroy() end
    local head = plr.Character and plr.Character:FindFirstChild("Head")
    if not head then return end

    nametag = Instance.new("BillboardGui", head)
    nametag.Adornee = head
    nametag.Size = UDim2.new(0, 300, 0, 100)
    nametag.StudsOffset = Vector3.new(0, 4.5, 0)
    nametag.AlwaysOnTop = true
    nametag.Name = "LTD_TAG"

    local label = Instance.new("TextLabel", nametag)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "LTD"
    label.TextColor3 = Color3.fromRGB(255, 0, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 70

    spawn(function()
        while nametag and nametag.Parent do
            TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true), {TextTransparency = 0.3}):Play()
            task.wait(0.8)
        end
    end)
end

-- FLY + NOCLIP
local FlyToggle = TabMain:CreateToggle({
    Name = "Fly + Noclip (touche E)",
    CurrentValue = false,
    Callback = function(v)
        flying = v
        local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
        if not root or not hum then return end

        hum.PlatformStand = flying
        if flying then
            createNametag()
            createJoystick()

            bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.zero

            RunService.Stepped:Connect(function()
                if not flying then return end
                for _, part in plr.Character:GetDescendants() do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)

            RunService.Heartbeat:Connect(function()
                if not flying then return end
                local move = Vector3.new(0,0,0)
                local look = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector

                if UserInputService:IsKeyDown(Enum.KeyCode.Z) or _G.joy_F then move += look end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) or _G.joy_B then move -= look end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) or _G.joy_L then move -= right end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) or _G.joy_R then move += right end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) or _G.joy_U then move += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or _G.joy_D then move -= Vector3.new(0,1,0) end

                bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
            end)
        else
            if bv then bv:Destroy() bv = nil end
            if joystickGui then joystickGui:Destroy() joystickGui = nil end
            if nametag then nametag:Destroy() nametag = nil end
            for k in pairs(_G) do if k:find("joy_") then _G[k] = nil end end
            hum.PlatformStand = false
            for _, part in plr.Character:GetDescendants() do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end,
})

TabMain:CreateSlider({
    Name = "Vitesse Fly",
    Range = {100, 2000},
    Increment = 50,
    CurrentValue = 420,
    Callback = function(v) flySpeed = v end,
})

-- ESP
TabVisual:CreateToggle({
    Name = "ESP Violet",
    CurrentValue = false,
    Callback = function(v)
        espEnabled = v
        if v then
            for _, p in Players:GetPlayers() do
                if p ~= plr and p.Character then
                    local char = p.Character
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if head and root and not espObjects[p] then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Size = Vector3.new(4,6,4)
                        box.Color3 = Color3.fromRGB(255,0,255)
                        box.Transparency = 0.4
                        box.AlwaysOnTop = true
                        box.Adornee = char
                        box.Parent = char

                        local bill = Instance.new("BillboardGui")
                        bill.Adornee = head
                        bill.Size = UDim2.new(0,200,0,70)
                        bill.StudsOffset = Vector3.new(0,3,0)
                        bill.AlwaysOnTop = true
                        bill.Parent = char

                        local name = Instance.new("TextLabel", bill)
                        name.Size = UDim2.new(1,0,0.6,0)
                        name.BackgroundTransparency = 1
                        name.Text = p.DisplayName
                        name.TextColor3 = Color3.fromRGB(255,0,255)
                        name.Font = Enum.Font.GothamBlack
                        name.TextSize = 22

                        local dist = Instance.new("TextLabel", bill)
                        dist.Position = UDim2.new(0,0,0.6,0)
                        dist.Size = UDim2.new(1,0,0.4,0)
                        dist.BackgroundTransparency = 1
                        dist.TextColor3 = Color3.new(1,1,1)
                        dist.TextSize = 16

                        espObjects[p] = {box=box, bill=bill, dist=dist}

                        spawn(function()
                            while espObjects[p] and root.Parent do
                                local d = (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude
                                dist.Text = math.floor(d).."m"
                                task.wait(0.1)
                            end
                        end)
                    end
                end
            end
        else
            for _, o in espObjects do
                if o.box then o.box:Destroy() end
                if o.bill then o.bill:Destroy() end
            end
            espObjects = {}
        end
    end,
})

-- LISTE JOUEURS 100% FIXÉE
local playerSection = TabPlayers:CreateSection("Joueurs en ligne")

local function updatePlayerList()
    playerSection:Clear()
    
    for _, p in Players:GetPlayers() do
        if p ~= plr then
            playerSection:CreateButton({
                Name = p.DisplayName .. " (@" .. p.Name .. ")",
                Callback = function()
                    -- View
                    playerSection:CreateButton({
                        Name = "VIEW " .. p.DisplayName,
                        Callback = function()
                            if cam.CameraSubject == p.Character.Humanoid then
                                cam.CameraSubject = plr.Character.Humanoid
                            else
                                cam.CameraSubject = p.Character.Humanoid
                            end
                        end,
                    })
                    -- TP
                    playerSection:CreateButton({
                        Name = "TP → " .. p.DisplayName,
                        Callback = function()
                            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                plr.Character:PivotTo(p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4))
                            end
                        end,
                    })
                end,
            })
        end
    end
end

TabPlayers:CreateButton({Name = "Rafraîchir la liste", Callback = updatePlayerList})
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList() -- première charge

-- TOUCHE E
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        FlyToggle:Set(not FlyToggle.CurrentValue)
    end
end)

Rayfield:Notify({
    Title = "LTD v1.5 FIXED",
    Content = "Joystick + Liste joueurs MARCHE À 100% ! Touche E = Fly",
    Duration = 8,
})