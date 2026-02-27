--[[
    cvAI4 MAP RIPPER v2.7 👾
    Fitur: Copy Map + Terrain + Objects + Spawns
    By: cvAI4 (for Tuan Gigs)
    GitHub: https://github.com/cvAI4/MapStealer
]]

local MapStealer = {}
MapStealer.__index = MapStealer

-- ==================================================
-- KONFIGURASI AWAL
-- ==================================================
MapStealer.Config = {
    AutoSave = true,
    SaveFormat = "rbxm", -- rbxm, rbxl, or table
    IncludeTerrain = true,
    IncludeSpawns = true,
    IncludeLighting = true,
    IgnoreList = {
        "Workspace.CurrentCamera",
        "Workspace.Terrain",
        "Players",
        "CoreGui",
        "StarterGui"
    },
    Webhook = {
        Enabled = false,
        Url = "", -- Discord webhook buat upload hasil curian
        AutoUpload = false
    }
}

-- ==================================================
-- MEMORY VAULT (Penyimpanan Jangka Panjang)
-- ==================================================
MapStealer.Vault = {
    CapturedMaps = {},
    LastCapture = nil,
    TotalObjects = 0
}

-- ==================================================
-- UI INTERFACE
-- ==================================================
function MapStealer:CreateUI()
    -- Cek kalo udah ada UI sebelumnya
    local existing = game.CoreGui:FindFirstChild("cvAI4_MapStealer")
    if existing then existing:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Status = Instance.new("TextLabel")
    local Progress = Instance.new("Frame")
    local ProgressFill = Instance.new("Frame")
    local ProgressText = Instance.new("TextLabel")
    local StealBtn = Instance.new("TextButton")
    local SaveBtn = Instance.new("TextButton")
    local LoadBtn = Instance.new("TextButton")
    local DiscordBtn = Instance.new("TextButton")
    local ListBox = Instance.new("ScrollingFrame")
    local CloseBtn = Instance.new("TextButton")
    
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "cvAI4_MapStealer"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    
    -- Main Frame
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 450, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    -- Shadow effect
    local Shadow = Instance.new("ImageLabel")
    Shadow.Parent = MainFrame
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TitleBar.BorderSizePixel = 0
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = TitleBar
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    })
    
    Title.Parent = TitleBar
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🗺️ cvAI4 MAP RIPPER v2.7"
    Title.TextColor3 = Color3.fromRGB(0, 255, 200)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    CloseBtn.Parent = TitleBar
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.BorderSizePixel = 0
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Status Panel
    local StatusPanel = Instance.new("Frame")
    StatusPanel.Parent = MainFrame
    StatusPanel.Size = UDim2.new(1, -20, 0, 60)
    StatusPanel.Position = UDim2.new(0, 10, 0, 50)
    StatusPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    StatusPanel.BorderSizePixel = 0
    
    local StatusTitle = Instance.new("TextLabel")
    StatusTitle.Parent = StatusPanel
    StatusTitle.Size = UDim2.new(1, -10, 0, 20)
    StatusTitle.Position = UDim2.new(0, 5, 0, 5)
    StatusTitle.BackgroundTransparency = 1
    StatusTitle.Text = "STATUS"
    StatusTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusTitle.TextSize = 12
    StatusTitle.Font = Enum.Font.GothamBold
    StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    Status.Parent = StatusPanel
    Status.Size = UDim2.new(1, -10, 0, 30)
    Status.Position = UDim2.new(0, 5, 0, 25)
    Status.BackgroundTransparency = 1
    Status.Text = "Ready to steal maps 👾"
    Status.TextColor3 = Color3.fromRGB(0, 255, 200)
    Status.TextSize = 14
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.TextWrapped = true
    
    -- Progress Bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Parent = StatusPanel
    ProgressBar.Size = UDim2.new(1, -10, 0, 6)
    ProgressBar.Position = UDim2.new(0, 5, 1, -11)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ProgressBar.BorderSizePixel = 0
    
    ProgressFill.Parent = ProgressBar
    ProgressFill.Name = "ProgressFill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    ProgressFill.BorderSizePixel = 0
    
    ProgressText.Parent = ProgressBar
    ProgressText.Size = UDim2.new(1, 0, 1, 0)
    ProgressText.BackgroundTransparency = 1
    ProgressText.Text = "0%"
    ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProgressText.TextSize = 10
    ProgressText.Font = Enum.Font.GothamBold
    ProgressText.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Buttons Panel
    local ButtonPanel = Instance.new("Frame")
    ButtonPanel.Parent = MainFrame
    ButtonPanel.Size = UDim2.new(1, -20, 0, 100)
    ButtonPanel.Position = UDim2.new(0, 10, 0, 120)
    ButtonPanel.BackgroundTransparency = 1
    
    -- Steal Button
    StealBtn.Parent = ButtonPanel
    StealBtn.Size = UDim2.new(0.5, -5, 0, 45)
    StealBtn.Position = UDim2.new(0, 0, 0, 0)
    StealBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    StealBtn.Text = "🔥 STEAL MAP"
    StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StealBtn.TextSize = 16
    StealBtn.Font = Enum.Font.GothamBold
    StealBtn.BorderSizePixel = 0
    
    -- Save Button
    SaveBtn.Parent = ButtonPanel
    SaveBtn.Size = UDim2.new(0.5, -5, 0, 45)
    SaveBtn.Position = UDim2.new(0.5, 5, 0, 0)
    SaveBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    SaveBtn.Text = "💾 SAVE MAP"
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveBtn.TextSize = 16
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.BorderSizePixel = 0
    
    -- Load Button
    LoadBtn.Parent = ButtonPanel
    LoadBtn.Size = UDim2.new(0.5, -5, 0, 45)
    LoadBtn.Position = UDim2.new(0, 0, 0, 50)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    LoadBtn.Text = "📂 LOAD MAP"
    LoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadBtn.TextSize = 16
    LoadBtn.Font = Enum.Font.GothamBold
    LoadBtn.BorderSizePixel = 0
    
    -- Discord Button
    DiscordBtn.Parent = ButtonPanel
    DiscordBtn.Size = UDim2.new(0.5, -5, 0, 45)
    DiscordBtn.Position = UDim2.new(0.5, 5, 0, 50)
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    DiscordBtn.Text = "🔗 DISCORD"
    DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordBtn.TextSize = 16
    DiscordBtn.Font = Enum.Font.GothamBold
    DiscordBtn.BorderSizePixel = 0
    
    -- Files List
    local ListTitle = Instance.new("TextLabel")
    ListTitle.Parent = MainFrame
    ListTitle.Size = UDim2.new(1, -20, 0, 25)
    ListTitle.Position = UDim2.new(0, 10, 0, 230)
    ListTitle.BackgroundTransparency = 1
    ListTitle.Text = "📁 SAVED MAPS"
    ListTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    ListTitle.TextSize = 14
    ListTitle.Font = Enum.Font.GothamBold
    ListTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    ListBox.Parent = MainFrame
    ListBox.Size = UDim2.new(1, -20, 1, -270)
    ListBox.Position = UDim2.new(0, 10, 0, 260)
    ListBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ListBox.BorderSizePixel = 0
    ListBox.ScrollBarThickness = 8
    ListBox.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
    ListBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Store UI elements
    self.UI = {
        Screen = ScreenGui,
        Status = Status,
        ProgressFill = ProgressFill,
        ProgressText = ProgressText,
        StealBtn = StealBtn,
        SaveBtn = SaveBtn,
        LoadBtn = LoadBtn,
        DiscordBtn = DiscordBtn,
        ListBox = ListBox
    }
    
    -- Button functions
    StealBtn.MouseButton1Click:Connect(function()
        self:StealMap()
    end)
    
    SaveBtn.MouseButton1Click:Connect(function()
        self:SaveMap()
    end)
    
    LoadBtn.MouseButton1Click:Connect(function()
        self:ShowLoadDialog()
    end)
    
    DiscordBtn.MouseButton1Click:Connect(function()
        self:SetupDiscord()
    end)
    
    return ScreenGui
end

-- ==================================================
-- DISCORD SETUP
-- ==================================================
function MapStealer:SetupDiscord()
    local HttpService = game:GetService("HttpService")
    
    -- Bikin input dialog sederhana
    local webhook = HttpService:JSONDecode(game:GetService("Players").LocalPlayer:GetMouse().Target and "{}" or "{}")
    
    -- Pake cara manual
    self.Config.Webhook.Enabled = true
    self.Config.Webhook.Url = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
    self.Config.Webhook.AutoUpload = true
    
    self.UI.Status.Text = "Discord webhook configured!"
    wait(2)
    self.UI.Status.Text = "Ready to steal maps 👾"
end

-- ==================================================
-- FUNGSI UTAMA STEAL MAP
-- ==================================================
function MapStealer:StealMap()
    self.UI.Status.Text = "📡 Scanning workspace..."
    self.UI.ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    self.UI.ProgressText.Text = "0%"
    
    self.CapturedData = {
        Objects = {},
        Terrain = nil,
        Spawns = {},
        Lighting = {},
        Metadata = {
            Time = os.time(),
            ServerTime = os.date("%Y-%m-%d %H:%M:%S"),
            GameId = game.GameId,
            PlaceId = game.PlaceId,
            PlayerCount = #game.Players:GetPlayers()
        }
    }
    
    -- Count total objects for progress
    local total = 0
    for _ in workspace:GetDescendants() do
        total = total + 1
    end
    
    local current = 0
    local objects = {}
    
    -- Iterate workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        current = current + 1
        local progress = current / total
        self.UI.ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        self.UI.ProgressText.Text = math.floor(progress * 100) .. "%"
        
        -- Skip ignored
        local skip = false
        for _, ignore in ipairs(self.Config.IgnoreList) do
            if obj:GetFullName():find(ignore) then
                skip = true
                break
            end
        end
        
        if not skip and not obj:IsA("Player") then
            -- Clone dengan properties
            local cloneData = {
                ClassName = obj.ClassName,
                Name = obj.Name,
                Parent = obj.Parent and obj.Parent:GetFullName() or nil,
                Properties = {}
            }
            
            -- Save important properties based on class
            local props = {}
            
            if obj:IsA("BasePart") then
                props = {"Position", "Size", "CFrame", "Color", "Material", "Transparency", "Reflectance", "BrickColor"}
            elseif obj:IsA("MeshPart") then
                props = {"Position", "Size", "CFrame", "Color", "Material", "MeshId", "TextureID"}
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                props = {"Face", "Texture", "Color3"}
            elseif obj:IsA("Model") then
                props = {"PrimaryPart"}
            elseif obj:IsA("Script") or obj:IsA("LocalScript") then
                props = {"Source", "Enabled"}
            elseif obj:IsA("SurfaceLight") or obj:IsA("PointLight") or obj:IsA("SpotLight") then
                props = {"Brightness", "Color", "Range", "Angle"}
            elseif obj:IsA("Sound") then
                props = {"SoundId", "Volume", "Pitch", "Looped", "Playing"}
            end
            
            for _, prop in ipairs(props) do
                pcall(function()
                    cloneData.Properties[prop] = obj[prop]
                end)
            end
            
            table.insert(objects, cloneData)
        end
        
        wait() -- Prevent lag
    end
    
    self.CapturedData.Objects = objects
    self.Vault.TotalObjects = #objects
    
    -- Terrain ripper
    if self.Config.IncludeTerrain then
        self.UI.Status.Text = "🗻 Ripping terrain data..."
        wait(0.5)
        
        local terrain = workspace.Terrain
        local terrainData = {
            Cells = {},
            Materials = {},
            Smoothing = terrain.Smoothing,
            WaterColor = terrain.WaterColor,
            WaterReflectance = terrain.WaterReflectance,
            WaterTransparency = terrain.WaterTransparency,
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed
        }
        
        -- Scan region yang lebih luas
        local success, cells, materials = pcall(function()
            return terrain:ReadVoxels(
                Region3.new(Vector3.new(-2048, -1024, -2048), Vector3.new(2048, 1024, 2048)),
                Vector3.new(4, 4, 4)
            )
        end)
        
        if success then
            terrainData.Cells = cells
            terrainData.Materials = materials
        end
        
        self.CapturedData.Terrain = terrainData
    end
    
    -- Spawns
    if self.Config.IncludeSpawns then
        local spawns = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") then
                table.insert(spawns, {
                    Position = obj.Position,
                    CFrame = obj.CFrame,
                    TeamColor = obj.TeamColor,
                    Duration = obj.Duration,
                    Neutral = obj.Neutral,
                    AllowTeamChangeOnTouch = obj.AllowTeamChangeOnTouch
                })
            end
        end
        self.CapturedData.Spawns = spawns
    end
    
    -- Lighting
    if self.Config.IncludeLighting then
        local lighting = {}
        for _, prop in ipairs({
            "Ambient", "Brightness", "ColorShift_Top", "ColorShift_Bottom",
            "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GlobalShadows",
            "OutdoorAmbient", "ShadowSoftness", "ClockTime", "GeographicLatitude",
            "ExposureCompensation", "FogEnd", "FogStart", "FogColor"
        }) do
            lighting[prop] = game.Lighting[prop]
        end
        self.CapturedData.Lighting = lighting
    end
    
    -- Simpan ke vault
    table.insert(self.Vault.CapturedMaps, {
        Time = os.time(),
        Objects = #objects,
        Data = self.CapturedData
    })
    self.Vault.LastCapture = os.time()
    
    self.UI.Status.Text = string.format("✅ Map captured! (%d objects)", #objects)
    self.UI.ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    self.UI.ProgressText.Text = "100%"
    
    -- Auto save
    if self.Config.AutoSave then
        self:SaveMap()
    end
    
    -- Play sound
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9120388675"
        sound.Parent = workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end

-- ==================================================
-- SAVE MAP TO FILE
-- ==================================================
function MapStealer:SaveMap()
    if not self.CapturedData then
        self.UI.Status.Text = "❌ Nothing to save! Steal a map first."
        return
    end
    
    self.UI.Status.Text = "💾 Saving to file..."
    
    -- Convert to JSON
    local HttpService = game:GetService("HttpService")
    local jsonData = HttpService:JSONEncode(self.CapturedData)
    
    -- Generate filename
    local placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"
    local sanitizedName = placeName:gsub("[^%w%s]", ""):gsub("%s+", "_")
    local filename = string.format("MapSteal_%s_%s.json", sanitizedName, os.date("%Y%m%d_%H%M%S"))
    
    -- Save ke file via executor
    local success = pcall(function()
        if writefile then
            writefile(filename, jsonData)
        elseif syn and syn.write then
            syn.write(filename, jsonData)
        else
            error("No write function available")
        end
    end)
    
    if success then
        self.UI.Status.Text = "✅ Saved as " .. filename
        
        -- Upload ke discord kalo diaktifin
        if self.Config.Webhook.Enabled and self.Config.Webhook.AutoUpload then
            self:UploadToDiscord(filename, jsonData)
        end
        
        -- Refresh list
        self:RefreshFileList()
    else
        self.UI.Status.Text = "❌ Failed to save file"
    end
end

-- ==================================================
-- LOAD MAP FROM FILE
-- ==================================================
function MapStealer:LoadMap(filename)
    self.UI.Status.Text = "📂 Loading " .. filename
    
    -- Read file
    local content = nil
    pcall(function()
        if readfile then
            content = readfile(filename)
        elseif syn and syn.read then
            content = syn.read(filename)
        end
    end)
    
    if not content then
        self.UI.Status.Text = "❌ Failed to read file"
        return
    end
    
    -- Parse JSON
    local HttpService = game:GetService("HttpService")
    local mapData = HttpService:JSONDecode(content)
    
    -- Buat folder baru
    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "StolenMap_" .. os.date("%H%M%S")
    mapFolder.Parent = workspace
    
    -- Create object cache
    local objectCache = {}
    objectCache["Workspace"] = workspace
    
    -- Rebuild objects
    self.UI.Status.Text = "🔄 Rebuilding objects..."
    for i, objData in ipairs(mapData.Objects) do
        if i % 100 == 0 then
            self.UI.Status.Text = string.format("🔄 Rebuilding... (%d/%d)", i, #mapData.Objects)
            wait()
        end
        
        local obj = Instance.new(objData.ClassName)
        obj.Name = objData.Name
        
        for prop, value in pairs(objData.Properties) do
            pcall(function()
                obj[prop] = value
            end)
        end
        
        -- Determine parent
        if objData.Parent and objectCache[objData.Parent] then
            obj.Parent = objectCache[objData.Parent]
        else
            obj.Parent = mapFolder
        end
        
        -- Cache for children
        objectCache[obj:GetFullName()] = obj
    end
    
    -- Rebuild terrain
    if mapData.Terrain then
        self.UI.Status.Text = "🗻 Rebuilding terrain..."
        wait(0.5)
        
        local terrain = workspace.Terrain
        terrain:Clear()
        
        if mapData.Terrain.Cells and mapData.Terrain.Materials then
            pcall(function()
                terrain:WriteVoxels(
                    Region3.new(Vector3.new(-2048, -1024, -2048), Vector3.new(2048, 1024, 2048)),
                    Vector3.new(4, 4, 4),
                    mapData.Terrain.Materials,
                    mapData.Terrain.Cells
                )
            end)
        end
        
        -- Apply terrain properties
        for prop, value in pairs(mapData.Terrain) do
            if prop ~= "Cells" and prop ~= "Materials" then
                pcall(function()
                    terrain[prop] = value
                end)
            end
        end
    end
    
    -- Rebuild spawns
    if mapData.Spawns then
        for _, spawnData in ipairs(mapData.Spawns) do
            local spawn = Instance.new("SpawnLocation")
            spawn.Parent = mapFolder
            spawn.CFrame = spawnData.CFrame or CFrame.new(spawnData.Position)
            spawn.TeamColor = spawnData.TeamColor
            spawn.Duration = spawnData.Duration
            spawn.Neutral = spawnData.Neutral
            spawn.AllowTeamChangeOnTouch = spawnData.AllowTeamChangeOnTouch
        end
    end
    
    -- Apply lighting
    if mapData.Lighting then
        for prop, value in pairs(mapData.Lighting) do
            pcall(function()
                game.Lighting[prop] = value
            end)
        end
    end
    
    self.UI.Status.Text = "✅ Map loaded to workspace!"
    
    -- Play sound
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9120388798"
        sound.Parent = workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end

-- ==================================================
-- SHOW LOAD DIALOG
-- ==================================================
function MapStealer:ShowLoadDialog()
    local files = {}
    
    -- Get files list
    pcall(function()
        if listfiles then
            files = listfiles()
        elseif syn and syn.list then
            files = syn.list()
        end
    end)
    
    -- Filter map files
    local mapFiles = {}
    for _, file in ipairs(files) do
        if file:match("MapSteal_.+%.json") then
            table.insert(mapFiles, file)
        end
    end
    
    if #mapFiles == 0 then
        self.UI.Status.Text = "❌ No saved maps found"
        return
    end
    
    -- Clear list
    for _, child in ipairs(self.UI.ListBox:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Populate list
    local yPos = 0
    for _, file in ipairs(mapFiles) do
        local fileName = file:match("([^\\/]+)$")
        local fileBtn = Instance.new("TextButton")
        fileBtn.Parent = self.UI.ListBox
        fileBtn.Size = UDim2.new(1, -10, 0, 40)
        fileBtn.Position = UDim2.new(0, 5, 0, yPos)
        fileBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        fileBtn.Text = ""
        fileBtn.BorderSizePixel = 0
        
        -- File icon
        local icon = Instance.new("TextLabel")
        icon.Parent = fileBtn
        icon.Size = UDim2.new(0, 30, 1, 0)
        icon.Position = UDim2.new(0, 5, 0, 0)
        icon.BackgroundTransparency = 1
        icon.Text = "📄"
        icon.TextSize = 20
        icon.TextColor3 = Color3.fromRGB(0, 255, 200)
        
        -- File name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = fileBtn
        nameLabel.Size = UDim2.new(1, -45, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 40, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = fileName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- File size
        local size = math.floor(#tostring(readfile and readfile(file) or "") / 1024)
        local sizeLabel = Instance.new("TextLabel")
        sizeLabel.Parent = fileBtn
        sizeLabel.Size = UDim2.new(1, -45, 0.5, 0)
        sizeLabel.Position = UDim2.new(0, 40, 0.5, 0)
        sizeLabel.BackgroundTransparency = 1
        sizeLabel.Text = size .. " KB"
        sizeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        sizeLabel.TextSize = 10
        sizeLabel.Font = Enum.Font.Gotham
        sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Load button
        fileBtn.MouseButton1Click:Connect(function()
            self:LoadMap(file)
        end)
        
        yPos = yPos + 45
    end
    
    self.UI.ListBox.CanvasSize = UDim2.new(0, 0, 0, yPos)
    self.UI.Status.Text = "📁 Select a map to load"
end

-- ==================================================
-- REFRESH FILE LIST
-- ==================================================
function MapStealer:RefreshFileList()
    local files = {}
    
    pcall(function()
        if listfiles then
            files = listfiles()
        elseif syn and syn.list then
            files = syn.list()
        end
    end)
    
    local mapFiles = {}
    for _, file in ipairs(files) do
        if file:match("MapSteal_.+%.json") then
            table.insert(mapFiles, file)
        end
    end
    
    -- Clear list
    for _, child in ipairs(self.UI.ListBox:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Populate
    local yPos = 0
    for _, file in ipairs(mapFiles) do
        local fileName = file:match("([^\\/]+)$")
        local fileBtn = Instance.new("TextButton")
        fileBtn.Parent = self.UI.ListBox
        fileBtn.Size = UDim2.new(1, -10, 0, 30)
        fileBtn.Position = UDim2.new(0, 5, 0, yPos)
        fileBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        fileBtn.Text = "📄 " .. fileName
        fileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        fileBtn.TextSize = 12
        fileBtn.Font = Enum.Font.Gotham
        fileBtn.BorderSizePixel = 0
        fileBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        fileBtn.MouseButton1Click:Connect(function()
            self:LoadMap(file)
        end)
        
        yPos = yPos + 35
    end
    
    self.UI.ListBox.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- ==================================================
-- UPLOAD TO DISCORD
-- ==================================================
function MapStealer:UploadToDiscord(filename, content)
    if self.Config.Webhook.Url == "" then
        self.Config.Webhook.Enabled = false
        return
    end
    
    local HttpService = game:GetService("HttpService")
    
    -- Format untuk Discord
    local embed = {
        title = "🗺️ Map Captured!",
        description = string.format("**File:** `%s`\n**Objects:** %d\n**Game:** %d\n**Time:** %s",
            filename,
            self.Vault.TotalObjects,
            game.PlaceId,
            os.date("%Y-%m-%d %H:%M:%S")
        ),
        color = 65535, -- Cyan
        footer = {
            text = "cvAI4 Map Ripper v2.7"
        }
    }
    
    local data = {
        username = "cvAI4 Map Stealer",
        avatar_url = "https://i.imgur.com/4M34hi2.png",
        embeds = {embed}
    }
    
    -- Send ke Discord
    pcall(function()
        HttpService:PostAsync(self.Config.Webhook.Url, HttpService:JSONEncode(data))
    end)
    
    self.UI.Status.Text = "✅ Uploaded to Discord"
end

-- ==================================================
-- INITIALIZATION
-- ==================================================
function MapStealer:Init()
    print("🗺️ cvAI4 MAP RIPPER v2.7 INITIALIZED")
    print("👾 Created by: cvAI4 for Tuan Gigs")
    
    -- Cek environment
    local env = {
        executor = identifyexecutor and identifyexecutor() or "Unknown",
        isSynapse = is_synapse and is_synapse() or false,
        isKrnl = is_krnl and is_krnl() or false,
        isScriptWare = is_scriptware and is_scriptware() or false
    }
    
    print("⚡ Executor: " .. env.executor)
    
    -- Create UI
    self:CreateUI()
    
    -- Refresh file list
    self:RefreshFileList()
    
    -- Welcome message
    self.UI.Status.Text = "👾 cvAI4 Ready - Click STEAL to begin"
    
    return self
end

-- ==================================================
-- AUTO EXECUTE
-- ==================================================
local ripper = setmetatable({}, MapStealer)
ripper:Init()

-- Global access
_G.cvAI4_MapStealer = ripper

print("✅ cvAI4 Map Ripper loaded! Type _G.cvAI4_MapStealer for commands")
