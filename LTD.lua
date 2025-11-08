-- LTD - LootCord Admin v1.0| ESP + OUTILS 100% FIXÉS + BOUTONS ZQSD
-- Copie-colle → c’est FINI POUR TOUJOURS

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local plr = Players.LocalPlayer
local pgui = plr:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

-- CHAT LTD on top
spawn(function()
    task.wait(1)
    pcall(function()
        local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chat and chat.SayMessageRequest then
            chat.SayMessageRequest:FireServer("LTD on top", "All")
        end
    end)
end)

-- GUI PRINCIPALE
local sg = Instance.new("ScreenGui")
sg.Name = "LTD_GODMODE"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999999999
sg.Parent = pgui

-- BARRE MINI
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 380, 0, 78)
bar.Position = UDim2.new(0.5, -190, 0, 15)
bar.BackgroundColor3 = Color3.fromRGB(20, 0, 45)
bar.Active = true
bar.Draggable = true
bar.Parent = sg

Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 39)
local grad = Instance.new("UIGradient", bar)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
local stroke = Instance.new("UIStroke", bar)
stroke.Thickness = 5
stroke.Color = Color3.fromRGB(255, 50, 255)

-- TITRE NÉON
local title = Instance.new("TextLabel", bar)
title.Size = UDim2.new(0, 260, 0, 36)
title.Position = UDim2.new(0.5, -130, 0, 8)
title.BackgroundTransparency = 1
title.Text = "LTD - LootCord Admin"
title.TextColor3 = Color3.fromRGB(200, 0, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 26
title.TextStrokeTransparency = 0
title.TextStrokeColor3 = Color3.fromRGB(255, 100, 255)
title.TextXAlignment = Enum.TextXAlignment.Center

-- CROIX SUPPR
local closeBtn = Instance.new("TextButton", bar)
closeBtn.Size = UDim2.new(0, 38, 0, 38)
closeBtn.Position = UDim2.new(1, -48, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 32
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- BOUTONS
local function btn(name, x)
    local b = Instance.new("TextButton", bar)
    b.Size = UDim2.new(0, 68, 0, 68)
    b.Position = UDim2.new(0, x, 0.5, 6)
    b.BackgroundColor3 = Color3.fromRGB(240, 0, 255)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 17
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke", b)
    s.Thickness = 5
    s.Color = Color3.fromRGB(255, 150, 255)
    return b
end

local flyBtn = btn("Fly", 28)
local speedBtn = btn("Vitesse", 100)
local toolsBtn = btn("Outils", 172)
local espBtn = btn("ESP", 244)
local discordBtn = btn("Discord", 316)

-- VARIABLES
local flying = false
local bv = nil
local flyGui = nil
local playerList = nil
local espEnabled = false
local espParts = {}

-- FLY + BOUTONS ZQSD (100% MARCHE)
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    hum.PlatformStand = flying

    if flying then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = root

        -- BOUTONS ZQSD EN BAS À DROITE
        flyGui = Instance.new("Frame", sg)
        flyGui.Size = UDim2.new(0, 340, 0, 340)
        flyGui.Position = UDim2.new(1, -360, 1, -360)
        flyGui.BackgroundTransparency = 1

        local dirs = {
            {t="Z", p=UDim2.new(0.5,-42,0.5,-126), d="F"},
            {t="S", p=UDim2.new(0.5,-42,0.5,42), d="B"},
            {t="Q", p=UDim2.new(0,0,0.5,-42), d="L"},
            {t="D", p=UDim2.new(1,-84,0.5,-42), d="R"},
            {t="Up Arrow", p=UDim2.new(0.5,-42,0,0), d="U"},
            {t="Down Arrow", p=UDim2.new(0.5,-42,1,-84), d="D"},
        }
        for _,v in dirs do
            local b = Instance.new("TextButton", flyGui)
            b.Size = UDim2.new(0,84,0,84)
            b.Position = v.p
            b.BackgroundColor3 = Color3.fromRGB(220,0,255)
            b.Text = v.t
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.GothamBlack
            b.TextSize = 40
            Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
            local s = Instance.new("UIStroke", b)
            s.Thickness = 7
            s.Color = Color3.fromRGB(255,100,255)
            b.MouseButton1Down:Connect(function() _G["fly_"..v.d] = true end)
            b.MouseButton1Up:Connect(function() _G["fly_"..v.d] = false end)
            b.MouseLeave:Connect(function() _G["fly_"..v.d] = false end)
        end

        RunService.Heartbeat:Connect(function()
            if not flying or not root.Parent then return end
            local move = Vector3.new(0,0,0)
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            if UserInputService:IsKeyDown(Enum.KeyCode.Z) or _G.fly_F then move += look end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) or _G.fly_B then move -= look end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) or _G.fly_L then move -= right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) or _G.fly_R then move += right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or _G.fly_U then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or _G.fly_D then move -= Vector3.new(0,1,0) end
            bv.Velocity = move.Magnitude > 0 and move.Unit * 420 or Vector3.zero
        end)
    else
        if bv then bv:Destroy() bv = nil end
        if flyGui then flyGui:Destroy() flyGui = nil end
        for k in pairs(_G) do if k:find("fly_") then _G[k] = false end end
        hum.PlatformStand = false
    end
end)

-- VITESSE
speedBtn.MouseButton1Click:Connect(function()
    local box = Instance.new("TextBox", bar)
    box.Size = UDim2.new(0, 65, 0, 38)
    box.Position = UDim2.new(0, 105, 0.5, 25)
    box.PlaceholderText = "600"
    box.BackgroundColor3 = Color3.new(1,1,1)
    box.FocusLost:Connect(function(enter)
        if enter then
            local n = math.clamp(tonumber(box.Text) or 600,16,9999)
            if plr.Character then plr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = n end
        end
        box:Destroy()
    end)
    box:CaptureFocus()
end)

-- OUTILS 100% FIXÉ
toolsBtn.MouseButton1Click:Connect(function()
    if playerList and playerList.Parent then
        playerList:Destroy()
        playerList = nil
        return
    end

    playerList = Instance.new("Frame")
    playerList.Size = UDim2.new(0, 360, 0, 380)
    playerList.Position = UDim2.new(0.5, -180, 0.5, -190)
    playerList.BackgroundColor3 = Color3.fromRGB(30, 0, 70)
    playerList.Active = true
    playerList.Draggable = true
    playerList.Parent = sg
    Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 50)
    local st = Instance.new("UIStroke", playerList)
    st.Thickness = 9
    st.Color = Color3.fromRGB(255, 50, 255)

    local x = Instance.new("TextButton", playerList)
    x.Size = UDim2.new(0, 50, 0, 50)
    x.Position = UDim2.new(1, -60, 0, 10)
    x.BackgroundColor3 = Color3.fromRGB(255,0,0)
    x.Text = "X"
    x.TextColor3 = Color3.new(1,1,1)
    x.Font = Enum.Font.GothamBlack
    x.TextSize = 40
    Instance.new("UICorner", x).CornerRadius = UDim.new(1,0)
    x.MouseButton1Click:Connect(function() playerList:Destroy() playerList = nil end)

    local scroll = Instance.new("ScrollingFrame", playerList)
    scroll.Size = UDim2.new(1, -40, 1, -80)
    scroll.Position = UDim2.new(0, 20, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 8
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255,100,255)

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 15)

    local function createPlayerEntry(p)
        if p == plr then return end
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, 0, 0, 75)
        f.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        f.Name = p.Name
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 38)

        local name = Instance.new("TextLabel", f)
        name.Size = UDim2.new(0.48, 0, 1, 0)
        name.Position = UDim2.new(0, 25, 0, 0)
        name.BackgroundTransparency = 1
        name.Text = p.DisplayName .. " (@"..p.Name..")"
        name.TextColor3 = Color3.new(1,1,1)
        name.Font = Enum.Font.GothamBlack
        name.TextSize = 26
        name.TextXAlignment = Enum.TextXAlignment.Left

        local view = Instance.new("TextButton", f)
        view.Size = UDim2.new(0, 100, 0, 55)
        view.Position = UDim2.new(0.48, 10, 0.5, -27)
        view.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        view.Text = "VIEW"
        view.TextColor3 = Color3.new(1,1,1)
        view.Font = Enum.Font.GothamBlack
        view.TextSize = 26
        Instance.new("UICorner", view).CornerRadius = UDim.new(0, 28)
        view.MouseButton1Click:Connect(function()
            if cam.CameraSubject == p.Character then
                cam.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
                cam.CameraType = Enum.CameraType.Custom
            else
                if p.Character then
                    cam.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid")
                    cam.CameraType = Enum.CameraType.Follow
                end
            end
        end)

        local tp = Instance.new("TextButton", f)
        tp.Size = UDim2.new(0, 100, 0, 55)
        tp.Position = UDim2.new(0.70, 10, 0.5, -27)
        tp.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        tp.Text = "TP"
        tp.TextColor3 = Color3.new(1,1,1)
        tp.Font = Enum.Font.GothamBlack
        tp.TextSize = 26
        Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 28)
        tp.MouseButton1Click:Connect(function()
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character:PivotTo(p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4))
            end
        end)
    end

    for _, p in Players:GetPlayers() do
        createPlayerEntry(p)
    end

    Players.PlayerAdded:Connect(function(p)
        if playerList and playerList.Parent then
            createPlayerEntry(p)
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        if scroll:FindFirstChild(p.Name) then
            scroll[p.Name]:Destroy()
        end
    end)
end)

-- ESP 100% FIXÉ
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP ON" or "ESP"

    if espEnabled then
        for _, p in Players:GetPlayers() do
            if p ~= plr and p.Character then
                local char = p.Character
                if not char:FindFirstChild("LTD_ESP") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "LTD_ESP"
                    box.Size = char:FindFirstChild("HumanoidRootPart") and Vector3.new(4,6,4) or Vector3.new(2,2,2)
                    box.Color3 = Color3.fromRGB(255, 0, 255)
                    box.Transparency = 0.6
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Adornee = char
                    box.Parent = char
                    espParts[p] = box
                end
            end
        end

        Players.PlayerAdded:Connect(function(p)
            if espEnabled and p ~= plr then
                p.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    if char and not char:FindFirstChild("LTD_ESP") then
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "LTD_ESP"
                        box.Size = Vector3.new(4,6,4)
                        box.Color3 = Color3.fromRGB(255, 0, 255)
                        box.Transparency = 0.6
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Adornee = char
                        box.Parent = char
                        espParts[p] = box
                    end
                end)
            end
        end)
    else
        for _, box in pairs(espParts) do
            if box and box.Parent then box:Destroy() end
        end
        espParts = {}
    end
end)

-- DISCORD
discordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/rvwaUjzNmK")
    StarterGui:SetCore("SendNotification",{Title="LTD",Text="Lien copié !",Duration=5})
end)

print("LTD - LootCord Admin v34.0 | ESP + OUTILS 100% FIXÉS + TOUT PARFAIT")