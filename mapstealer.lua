--[[
    cvAI4 MAP RIPPER V3.2 - ULTIMATE FIXED EDITION 👾
    Fitur: ALL FORMATS + TERRAIN + SCRIPTS + EVERYTHING
    By: cvAI4 (for Tuan Gigs) - ALL ERRORS FIXED
    GitHub: https://github.com/cvAI4/MapStealer
]]

local MapStealer = {}
MapStealer.__index = MapStealer

-- ==================================================
-- KONFIGURASI SUPER LENGKAP
-- ==================================================
MapStealer.Config = {
    -- Format & Save Options
    AutoSave = true,
    SaveFormat = "json", -- "json", "rbxm", "rbxl", "hybrid"
    Compression = true,
    
    -- What to include
    IncludeTerrain = true,
    IncludeSpawns = true,
    IncludeLighting = true,
    IncludeAttachments = true,
    IncludeParticles = true,
    IncludeBeams = true,
    IncludeSounds = true,
    IncludeScripts = true,
    IncludeAnimations = true,
    IncludeHumanoids = true,
    IncludeConstraints = true,
    IncludeCSG = true,
    IncludeGUI = true,
    IncludeValues = true,
    
    -- Filters & Optimization
    FilterDuplicates = true,
    MinObjectSize = 10,
    MaxDepth = 50,
    BatchSize = 1000,
    
    -- Ignore list
    IgnoreList = {
        "Workspace.CurrentCamera",
        "Workspace.Terrain",
        "Players",
        "CoreGui",
        "StarterGui",
        "Debris",
        "JointsService",
        "InsertService",
        "NetworkClient",
        "RunService",
        "Stats",
        "TeleportService",
        "UserInputService",
        "VirtualUser",
        "VirtualInputManager"
    },
    
    -- Discord Webhook
    Webhook = {
        Enabled = false,
        Url = "",
        AutoUpload = false,
        SplitSize = 8 * 1024 * 1024
    },
    
    -- Advanced
    DebugMode = false,
    LogToFile = true,
    BackupOnSave = true
}

-- ==================================================
-- MEMORY VAULT
-- ==================================================
MapStealer.Vault = {
    CapturedMaps = {},
    LastCapture = nil,
    TotalObjects = 0,
    TotalSize = 0,
    History = {},
    Favorites = {}
}

-- ==================================================
-- EXECUTOR DETECTION
-- ==================================================
function MapStealer:DetectExecutor()
    local exec = {
        name = "Unknown",
        write = false,
        read = false,
        list = false,
        load = false,
        http = false,
        supports = {}
    }
    
    -- Synapse X
    if syn and syn.write then
        exec.name = "Synapse X"
        exec.write = syn.write
        exec.read = syn.read
        exec.list = syn.list
        exec.load = syn.load
        exec.http = syn.request
        exec.supports = {"writefile", "readfile", "listfiles", "http", "secure"}
    end
    
    -- Krnl
    if is_krnl and is_krnl() then
        exec.name = "Krnl"
        exec.write = writefile
        exec.read = readfile
        exec.list = listfiles
        exec.load = loadfile
        exec.http = http_request or request
        exec.supports = {"writefile", "readfile", "listfiles", "http"}
    end
    
    -- ScriptWare
    if is_scriptware and is_scriptware() then
        exec.name = "ScriptWare"
        exec.write = writefile
        exec.read = readfile
        exec.list = listfiles
        exec.load = loadfile
        exec.http = http_request
        exec.supports = {"writefile", "readfile", "listfiles", "http"}
    end
    
    -- Fluxus
    if is_fluxus and is_fluxus() then
        exec.name = "Fluxus"
        exec.write = writefile
        exec.read = readfile
        exec.list = listfiles
        exec.load = loadfile
        exec.http = request
        exec.supports = {"writefile", "readfile", "listfiles", "http"}
    end
    
    -- Delta
    if is_delta and is_delta() then
        exec.name = "Delta"
        exec.write = writefile
        exec.read = readfile
        exec.list = listfiles
        exec.load = loadfile
        exec.http = request
        exec.supports = {"writefile", "readfile", "listfiles", "http"}
    end
    
    -- Fallback
    if not exec.write and writefile then
        exec.write = writefile
        exec.read = readfile
        exec.list = listfiles
        exec.supports = {"writefile", "readfile", "listfiles"}
    end
    
    self.Executor = exec
    return exec
end

-- ==================================================
-- PROPERTY LISTS SUPER LENGKAP (FIXED)
-- ==================================================
MapStealer.PropertyLists = {
    -- Base Classes
    Instance = {"Name", "Parent", "Archivable", "ClassName"},
    
    -- Parts & Physical Objects
    BasePart = {"Position", "Size", "CFrame", "Color", "Material", "Transparency", 
                "Reflectance", "BrickColor", "Shape", "Orientation", "Rotation",
                "Anchored", "CanCollide", "Locked", "Massless", "RotVelocity", 
                "Velocity", "CustomPhysicalProperties", "CollisionGroupId",
                "CastShadow", "ReceiveRemoves", "RootPriority"},
    
    MeshPart = {"Position", "Size", "CFrame", "Color", "Material", "MeshId", 
                "TextureID", "RenderFidelity", "DoubleSided", "CollisionFidelity",
                "UsePartColor", "VertexColor"},
    
    Part = {"Position", "Size", "CFrame", "Color", "Material", "Shape", "BrickColor"},
    
    UnionOperation = {"Position", "Size", "CFrame", "Color", "Material", "MeshId", 
                      "UsePartColor", "ChildData", "PhysicsData"},
    
    -- TERRAIN FIXED - HAPUS SMOOTHING
    Terrain = {"WaterColor", "WaterReflectance", "WaterTransparency",
               "WaterWaveSize", "WaterWaveSpeed", "MaterialColors", 
               "Cells", "Materials"},
    
    -- Decals & Textures
    Decal = {"Face", "Texture", "Color3", "Transparency", "Shiny", "Specular",
             "TopSurface", "BottomSurface", "LeftSurface", "RightSurface"},
    
    Texture = {"Face", "Texture", "Color3", "Transparency", "OffsetStudsU", 
               "OffsetStudsV", "StudsPerTileU", "StudsPerTileV"},
    
    -- Models & Groups
    Model = {"PrimaryPart", "LevelOfDetail", "ModelStreamingMode", "WorldPivot",
             "Scale", "Rotation", "Position", "WorldPivotData"},
    
    Folder = {"Name", "Parent"},
    
    -- Scripts & Logic
    Script = {"Source", "Enabled", "RunContext", "LinkedSource"},
    LocalScript = {"Source", "Enabled", "RunContext", "LinkedSource"},
    ModuleScript = {"Source", "LinkedSource"},
    
    -- Lighting & Lights
    PointLight = {"Brightness", "Color", "Range", "Shadows", "Enabled"},
    SpotLight = {"Brightness", "Color", "Range", "Angle", "Face", "Shadows", "Enabled"},
    SurfaceLight = {"Brightness", "Color", "Range", "Angle", "Face", "Shiny", 
                    "Specular", "Enabled"},
    
    -- Audio
    Sound = {"SoundId", "Volume", "Pitch", "Looped", "Playing", "PlaybackSpeed", 
             "PlayOnRemove", "RollOffMode", "EmitterSize", "TimePosition",
             "SoundGroup", "MaxDistance", "MinDistance"},
    
    SoundGroup = {"Name", "Parent", "Volume"},
    
    -- Constraints
    Weld = {"Part0", "Part1", "C0", "C1", "Enabled"},
    Motor6D = {"Part0", "Part1", "C0", "C1", "MaxVelocity", "CurrentAngle", "Enabled"},
    Snap = {"Part0", "Part1", "C0", "C1", "Enabled"},
    HingeConstraint = {"Attachment0", "Attachment1", "Angle", "AngularVelocity", 
                       "Enabled", "LimitsEnabled", "UpperAngle", "LowerAngle",
                       "MotorMaxAcceleration", "MotorMaxTorque", "AngularSpeed"},
    
    -- Attachments
    Attachment = {"Position", "Rotation", "Axis", "SecondaryAxis", "Visible", 
                  "WorldCFrame", "Name", "Parent"},
    
    -- Particle Emitters
    ParticleEmitter = {"Rate", "Speed", "Lifetime", "SpreadAngle", "Drag", 
                       "Acceleration", "Rotation", "RotSpeed", "Transparency", 
                       "Color", "Size", "Texture", "VelocityInheritance", 
                       "VelocitySpread", "EmissionDirection", "Enabled", 
                       "LightEmission", "LightInfluence", "ZOffset", "FlipbookLayout"},
    
    -- Beams
    Beam = {"Texture", "TextureSpeed", "TextureLength", "Width0", "Width1", 
            "Transparency", "Color", "CurveSize0", "CurveSize1", "FaceCamera", 
            "Enabled", "LightEmission", "Segments", "ZOffset"},
    
    -- Humanoids & Characters
    Humanoid = {"DisplayName", "Health", "MaxHealth", "WalkSpeed", "JumpPower", 
                "HipHeight", "AutoRotate", "FloorMaterial", "MoveDirection", 
                "RigType", "UseJumpPower", "CameraOffset", "HealthDisplayDistance",
                "HealthDisplayType", "MaxSlopeAngle", "NameDisplayDistance",
                "NameOcclusion", "RequiresNeck", "AutomaticScalingEnabled"},
    
    BodyColors = {"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", 
                  "LeftLegColor", "RightLegColor"},
    
    -- Values
    StringValue = {"Value"},
    NumberValue = {"Value"},
    IntValue = {"Value"},
    BoolValue = {"Value"},
    Vector3Value = {"Value"},
    CFrameValue = {"Value"},
    Color3Value = {"Value"},
    BrickColorValue = {"Value"},
    ObjectValue = {"Value"},
    
    -- GUI Elements
    BillboardGui = {"Adornee", "Size", "StudsOffset", "Enabled", "Active", 
                    "AlwaysOnTop", "LightInfluence", "Brightness", "MaxDistance",
                    "ClipsDescendants", "ResetOnSpawn", "ZIndexBehavior"},
    
    SurfaceGui = {"Adornee", "Face", "SizingMode", "PixelsPerStud", "Enabled", 
                  "Active", "ClipsDescendants", "ZIndexBehavior"},
    
    TextLabel = {"Text", "TextColor3", "TextSize", "Font", "BackgroundColor3", 
                 "BackgroundTransparency", "BorderSizePixel", "Position", "Size", 
                 "Visible", "ZIndex", "TextScaled", "TextWrapped", "TextXAlignment",
                 "TextYAlignment", "RichText", "LineHeight", "FontFace"},
    
    ImageLabel = {"Image", "ImageColor3", "ImageTransparency", "BackgroundColor3",
                  "BackgroundTransparency", "Position", "Size", "Visible",
                  "ScaleType", "SliceCenter", "TileSize"},
    
    TextButton = {"Text", "TextColor3", "TextSize", "Font", "BackgroundColor3",
                  "BackgroundTransparency", "Position", "Size", "Visible", 
                  "AutoButtonColor", "Modal", "Selected", "Style"},
    
    ImageButton = {"Image", "ImageColor3", "ImageTransparency", "BackgroundColor3",
                   "BackgroundTransparency", "Position", "Size", "Visible", 
                   "AutoButtonColor", "Modal", "Selected", "Style"},
    
    Frame = {"BackgroundColor3", "BackgroundTransparency", "BorderSizePixel",
             "Position", "Size", "Visible", "ZIndex", "Active", "Draggable",
             "Selectable", "ClipsDescendants"},
    
    ScrollingFrame = {"BackgroundColor3", "BackgroundTransparency", "BorderSizePixel",
                      "Position", "Size", "Visible", "ScrollBarThickness", 
                      "ScrollingEnabled", "CanvasSize", "CanvasPosition",
                      "ScrollBarImageColor3", "ElasticBehavior", "ScrollingDirection"},
    
    -- Effects
    SelectionBox = {"Adornee", "Color3", "LineThickness", "SurfaceTransparency", "Visible"},
    SelectionSphere = {"Adornee", "Color3", "SurfaceTransparency", "Visible"},
    
    -- Camera
    Camera = {"CFrame", "Focus", "FieldOfView", "CameraType", "CameraSubject", 
              "HeadScale", "FieldOfViewMode", "DiagonalFieldOfView"},
    
    -- Animation
    Animation = {"AnimationId", "Name"},
    Animator = {"Name", "Parent"},
    AnimationTrack = {"Name", "Animation", "Looped", "Priority", "Speed", "TimePosition"},
    
    -- Lighting Service
    Lighting = {"Ambient", "Brightness", "ColorShift_Top", "ColorShift_Bottom",
                "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GlobalShadows",
                "OutdoorAmbient", "ShadowSoftness", "ClockTime", "GeographicLatitude",
                "ExposureCompensation", "FogEnd", "FogStart", "FogColor",
                "Technology", "AmbientOcclusion", "Blur", "Outlines"},
    
    -- Workspace
    Workspace = {"Gravity", "FallenPartsDestroyHeight", "StreamingEnabled",
                 "StreamingMinRadius", "StreamingTargetRadius", "CollisionGroups"},
    
    -- Spawn Locations
    SpawnLocation = {"Position", "CFrame", "TeamColor", "Duration", "Neutral",
                     "AllowTeamChangeOnTouch", "Enabled"},
    
    -- CFrame
    CFrameValue = {"Value"},
    
    -- Joints
    JointInstance = {"Part0", "Part1", "C0", "C1"},
    
    -- Mesh
    SpecialMesh = {"MeshId", "TextureId", "MeshType", "Scale", "Offset", "VertexColor"},
    BlockMesh = {"Scale", "Offset", "Bevel", "MeshType"},
    CylinderMesh = {"Scale", "Offset", "Bevel", "MeshType"},
    
    -- SurfaceAppearance
    SurfaceAppearance = {"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap",
                         "MaskMap", "BlendMode", "TexturePack"}
}

-- Fallback properties
MapStealer.FallbackProperties = {"Name", "Parent"}

-- ==================================================
-- UI INTERFACE (DISINGKAT KARENA PANJANG)
-- ==================================================
function MapStealer:CreateUI()
    -- Cek kalo udah ada UI sebelumnya
    local existing = game.CoreGui:FindFirstChild("cvAI4_MapStealer_V3")
    if existing then existing:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseBtn = Instance.new("TextButton")
    local MinimizeBtn = Instance.new("TextButton")
    
    -- Status Panel
    local StatusPanel = Instance.new("Frame")
    local Status = Instance.new("TextLabel")
    local ProgressBar = Instance.new("Frame")
    local ProgressFill = Instance.new("Frame")
    local ProgressText = Instance.new("TextLabel")
    local ETA = Instance.new("TextLabel")
    
    -- Stats Panel
    local StatsPanel = Instance.new("Frame")
    local ObjectsValue = Instance.new("TextLabel")
    local SizeValue = Instance.new("TextLabel")
    local TimeValue = Instance.new("TextLabel")
    
    -- Tab Control
    local TabControl = Instance.new("Frame")
    local MainTab = Instance.new("TextButton")
    local ExportTab = Instance.new("TextButton")
    local FilesTab = Instance.new("TextButton")
    local SettingsTab = Instance.new("TextButton")
    local TabIndicator = Instance.new("Frame")
    
    -- Content Pages
    local MainPage = Instance.new("Frame")
    local ExportPage = Instance.new("Frame")
    local FilesPage = Instance.new("Frame")
    local SettingsPage = Instance.new("Frame")
    
    -- Main Page Buttons
    local StealBtn = Instance.new("TextButton")
    local StopBtn = Instance.new("TextButton")
    
    -- Export Page
    local JsonBtn = Instance.new("TextButton")
    local RbxmBtn = Instance.new("TextButton")
    local RbxlBtn = Instance.new("TextButton")
    local HybridBtn = Instance.new("TextButton")
    local ExportBtn = Instance.new("TextButton")
    local DiscordBtn = Instance.new("TextButton")
    
    -- Files Page
    local RefreshBtn = Instance.new("TextButton")
    local FileList = Instance.new("ScrollingFrame")
    
    -- Settings Page
    local TerrainToggle = Instance.new("TextButton")
    local WebhookInput = Instance.new("TextBox")
    local SaveSettingsBtn = Instance.new("TextButton")
    
    -- Setup ScreenGui
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "cvAI4_MapStealer_V3"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 800, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Parent = MainFrame
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    
    -- Title Bar
    TitleBar.Parent = MainFrame
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TitleBar.BorderSizePixel = 0
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = TitleBar
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    })
    
    -- Title
    Title.Parent = TitleBar
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🗺️ cvAI4 MAP RIPPER V3.2 - ULTIMATE FIXED"
    Title.TextColor3 = Color3.fromRGB(0, 255, 200)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Version Badge
    local VersionBadge = Instance.new("Frame")
    VersionBadge.Parent = TitleBar
    VersionBadge.Size = UDim2.new(0, 60, 0, 20)
    VersionBadge.Position = UDim2.new(1, -150, 0, 10)
    VersionBadge.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    VersionBadge.BorderSizePixel = 0
    VersionBadge.BackgroundTransparency = 0.2
    
    local VersionText = Instance.new("TextLabel")
    VersionText.Parent = VersionBadge
    VersionText.Size = UDim2.new(1, 0, 1, 0)
    VersionText.BackgroundTransparency = 1
    VersionText.Text = "FIXED"
    VersionText.TextColor3 = Color3.fromRGB(255, 255, 255)
    VersionText.TextSize = 12
    VersionText.Font = Enum.Font.GothamBold
    
    -- Window Controls
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    MinimizeBtn.Text = "─"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 20
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        wait(0.1)
        MainFrame.Visible = true
    end)
    
    CloseBtn.Parent = TitleBar
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.BorderSizePixel = 0
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Control
    TabControl.Parent = MainFrame
    TabControl.Size = UDim2.new(1, 0, 0, 40)
    TabControl.Position = UDim2.new(0, 0, 0, 40)
    TabControl.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabControl.BorderSizePixel = 0
    
    -- Tabs
    MainTab.Parent = TabControl
    MainTab.Size = UDim2.new(0.25, 0, 1, 0)
    MainTab.Position = UDim2.new(0, 0, 0, 0)
    MainTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    MainTab.Text = "📊 MAIN"
    MainTab.TextColor3 = Color3.fromRGB(0, 255, 200)
    MainTab.TextSize = 16
    MainTab.Font = Enum.Font.GothamBold
    MainTab.BorderSizePixel = 0
    
    ExportTab.Parent = TabControl
    ExportTab.Size = UDim2.new(0.25, 0, 1, 0)
    ExportTab.Position = UDim2.new(0.25, 0, 0, 0)
    ExportTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ExportTab.Text = "📦 EXPORT"
    ExportTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    ExportTab.TextSize = 16
    ExportTab.Font = Enum.Font.GothamBold
    ExportTab.BorderSizePixel = 0
    
    FilesTab.Parent = TabControl
    FilesTab.Size = UDim2.new(0.25, 0, 1, 0)
    FilesTab.Position = UDim2.new(0.5, 0, 0, 0)
    FilesTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    FilesTab.Text = "📁 FILES"
    FilesTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    FilesTab.TextSize = 16
    FilesTab.Font = Enum.Font.GothamBold
    FilesTab.BorderSizePixel = 0
    
    SettingsTab.Parent = TabControl
    SettingsTab.Size = UDim2.new(0.25, 0, 1, 0)
    SettingsTab.Position = UDim2.new(0.75, 0, 0, 0)
    SettingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    SettingsTab.Text = "⚙️ SETTINGS"
    SettingsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    SettingsTab.TextSize = 16
    SettingsTab.Font = Enum.Font.GothamBold
    SettingsTab.BorderSizePixel = 0
    
    -- Tab Indicator
    TabIndicator.Parent = TabControl
    TabIndicator.Size = UDim2.new(0.25, 0, 0, 2)
    TabIndicator.Position = UDim2.new(0, 0, 1, -2)
    TabIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    TabIndicator.BorderSizePixel = 0
    
    -- Content Pages
    MainPage.Parent = MainFrame
    MainPage.Size = UDim2.new(1, -20, 1, -100)
    MainPage.Position = UDim2.new(0, 10, 0, 90)
    MainPage.BackgroundTransparency = 1
    MainPage.Visible = true
    
    ExportPage.Parent = MainFrame
    ExportPage.Size = UDim2.new(1, -20, 1, -100)
    ExportPage.Position = UDim2.new(0, 10, 0, 90)
    ExportPage.BackgroundTransparency = 1
    ExportPage.Visible = false
    
    FilesPage.Parent = MainFrame
    FilesPage.Size = UDim2.new(1, -20, 1, -100)
    FilesPage.Position = UDim2.new(0, 10, 0, 90)
    FilesPage.BackgroundTransparency = 1
    FilesPage.Visible = false
    
    SettingsPage.Parent = MainFrame
    SettingsPage.Size = UDim2.new(1, -20, 1, -100)
    SettingsPage.Position = UDim2.new(0, 10, 0, 90)
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Visible = false
    
    -- Tab switching
    MainTab.MouseButton1Click:Connect(function()
        MainPage.Visible = true
        ExportPage.Visible = false
        FilesPage.Visible = false
        SettingsPage.Visible = false
        TabIndicator:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2, true)
        MainTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        ExportTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        FilesTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SettingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        MainTab.TextColor3 = Color3.fromRGB(0, 255, 200)
        ExportTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        FilesTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        SettingsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)
    
    ExportTab.MouseButton1Click:Connect(function()
        MainPage.Visible = false
        ExportPage.Visible = true
        FilesPage.Visible = false
        SettingsPage.Visible = false
        TabIndicator:TweenPosition(UDim2.new(0.25, 0, 0, 0), "Out", "Quad", 0.2, true)
        ExportTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        MainTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        FilesTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SettingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        ExportTab.TextColor3 = Color3.fromRGB(0, 255, 200)
        MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        FilesTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        SettingsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)
    
    FilesTab.MouseButton1Click:Connect(function()
        MainPage.Visible = false
        ExportPage.Visible = false
        FilesPage.Visible = true
        SettingsPage.Visible = false
        TabIndicator:TweenPosition(UDim2.new(0.5, 0, 0, 0), "Out", "Quad", 0.2, true)
        FilesTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        MainTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        ExportTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SettingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        FilesTab.TextColor3 = Color3.fromRGB(0, 255, 200)
        MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        ExportTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        SettingsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        self:RefreshFileList()
    end)
    
    SettingsTab.MouseButton1Click:Connect(function()
        MainPage.Visible = false
        ExportPage.Visible = false
        FilesPage.Visible = false
        SettingsPage.Visible = true
        TabIndicator:TweenPosition(UDim2.new(0.75, 0, 0, 0), "Out", "Quad", 0.2, true)
        SettingsTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        MainTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        ExportTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        FilesTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SettingsTab.TextColor3 = Color3.fromRGB(0, 255, 200)
        MainTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        ExportTab.TextColor3 = Color3.fromRGB(150, 150, 150)
        FilesTab.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)
    
    -- Status Panel
    StatusPanel.Parent = MainPage
    StatusPanel.Size = UDim2.new(1, 0, 0, 80)
    StatusPanel.Position = UDim2.new(0, 0, 0, 0)
    StatusPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    StatusPanel.BorderSizePixel = 0
    
    local StatusTitle = Instance.new("TextLabel")
    StatusTitle.Parent = StatusPanel
    StatusTitle.Size = UDim2.new(1, -20, 0, 20)
    StatusTitle.Position = UDim2.new(0, 10, 0, 5)
    StatusTitle.BackgroundTransparency = 1
    StatusTitle.Text = "SYSTEM STATUS"
    StatusTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusTitle.TextSize = 12
    StatusTitle.Font = Enum.Font.GothamBold
    StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    Status.Parent = StatusPanel
    Status.Size = UDim2.new(1, -20, 0, 25)
    Status.Position = UDim2.new(0, 10, 0, 25)
    Status.BackgroundTransparency = 1
    Status.Text = "🟢 READY - Click STEAL to begin"
    Status.TextColor3 = Color3.fromRGB(0, 255, 200)
    Status.TextSize = 16
    Status.Font = Enum.Font.GothamBold
    Status.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Progress Bar
    local ProgressBg = Instance.new("Frame")
    ProgressBg.Parent = StatusPanel
    ProgressBg.Size = UDim2.new(0.7, -20, 0, 20)
    ProgressBg.Position = UDim2.new(0, 10, 0, 55)
    ProgressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ProgressBg.BorderSizePixel = 0
    
    ProgressFill.Parent = ProgressBg
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    ProgressFill.BorderSizePixel = 0
    
    ProgressText.Parent = ProgressBg
    ProgressText.Size = UDim2.new(1, 0, 1, 0)
    ProgressText.BackgroundTransparency = 1
    ProgressText.Text = "0%"
    ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProgressText.TextSize = 12
    ProgressText.Font = Enum.Font.GothamBold
    ProgressText.TextXAlignment = Enum.TextXAlignment.Center
    
    ETA.Parent = StatusPanel
    ETA.Size = UDim2.new(0.3, -20, 0, 20)
    ETA.Position = UDim2.new(0.7, 10, 0, 55)
    ETA.BackgroundTransparency = 1
    ETA.Text = "ETA: --:--"
    ETA.TextColor3 = Color3.fromRGB(200, 200, 200)
    ETA.TextSize = 12
    ETA.Font = Enum.Font.Gotham
    ETA.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Stats Panel
    StatsPanel.Parent = MainPage
    StatsPanel.Size = UDim2.new(1, 0, 0, 50)
    StatsPanel.Position = UDim2.new(0, 0, 0, 90)
    StatsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    StatsPanel.BorderSizePixel = 0
    
    local ObjectsLabel = Instance.new("TextLabel")
    ObjectsLabel.Parent = StatsPanel
    ObjectsLabel.Size = UDim2.new(0.33, 0, 0, 20)
    ObjectsLabel.Position = UDim2.new(0, 10, 0, 5)
    ObjectsLabel.BackgroundTransparency = 1
    ObjectsLabel.Text = "OBJECTS"
    ObjectsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ObjectsLabel.TextSize = 10
    ObjectsLabel.Font = Enum.Font.GothamBold
    ObjectsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ObjectsValue.Parent = StatsPanel
    ObjectsValue.Size = UDim2.new(0.33, 0, 0, 20)
    ObjectsValue.Position = UDim2.new(0, 10, 0, 25)
    ObjectsValue.BackgroundTransparency = 1
    ObjectsValue.Text = "0"
    ObjectsValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    ObjectsValue.TextSize = 14
    ObjectsValue.Font = Enum.Font.GothamBold
    ObjectsValue.TextXAlignment = Enum.TextXAlignment.Left
    
    local SizeLabel = Instance.new("TextLabel")
    SizeLabel.Parent = StatsPanel
    SizeLabel.Size = UDim2.new(0.33, 0, 0, 20)
    SizeLabel.Position = UDim2.new(0.33, 10, 0, 5)
    SizeLabel.BackgroundTransparency = 1
    SizeLabel.Text = "SIZE"
    SizeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    SizeLabel.TextSize = 10
    SizeLabel.Font = Enum.Font.GothamBold
    SizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    SizeValue.Parent = StatsPanel
    SizeValue.Size = UDim2.new(0.33, 0, 0, 20)
    SizeValue.Position = UDim2.new(0.33, 10, 0, 25)
    SizeValue.BackgroundTransparency = 1
    SizeValue.Text = "0 KB"
    SizeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    SizeValue.TextSize = 14
    SizeValue.Font = Enum.Font.GothamBold
    SizeValue.TextXAlignment = Enum.TextXAlignment.Left
    
    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Parent = StatsPanel
    TimeLabel.Size = UDim2.new(0.33, 0, 0, 20)
    TimeLabel.Position = UDim2.new(0.66, 10, 0, 5)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Text = "TIME"
    TimeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    TimeLabel.TextSize = 10
    TimeLabel.Font = Enum.Font.GothamBold
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    TimeValue.Parent = StatsPanel
    TimeValue.Size = UDim2.new(0.33, 0, 0, 20)
    TimeValue.Position = UDim2.new(0.66, 10, 0, 25)
    TimeValue.BackgroundTransparency = 1
    TimeValue.Text = "--:--"
    TimeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeValue.TextSize = 14
    TimeValue.Font = Enum.Font.GothamBold
    TimeValue.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Main Page Buttons
    StealBtn.Parent = MainPage
    StealBtn.Size = UDim2.new(0.5, -5, 0, 60)
    StealBtn.Position = UDim2.new(0, 0, 0, 150)
    StealBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    StealBtn.Text = "🔥 STEAL MAP"
    StealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StealBtn.TextSize = 24
    StealBtn.Font = Enum.Font.GothamBold
    StealBtn.BorderSizePixel = 0
    
    StopBtn.Parent = MainPage
    StopBtn.Size = UDim2.new(0.5, -5, 0, 60)
    StopBtn.Position = UDim2.new(0.5, 5, 0, 150)
    StopBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    StopBtn.Text = "⏹️ STOP"
    StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopBtn.TextSize = 24
    StopBtn.Font = Enum.Font.GothamBold
    StopBtn.BorderSizePixel = 0
    
    -- Export Page
    local FormatLabel = Instance.new("TextLabel")
    FormatLabel.Parent = ExportPage
    FormatLabel.Size = UDim2.new(1, 0, 0, 30)
    FormatLabel.Position = UDim2.new(0, 0, 0, 10)
    FormatLabel.BackgroundTransparency = 1
    FormatLabel.Text = "📦 EXPORT FORMAT"
    FormatLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
    FormatLabel.TextSize = 18
    FormatLabel.Font = Enum.Font.GothamBold
    
    JsonBtn.Parent = ExportPage
    JsonBtn.Size = UDim2.new(0.5, -5, 0, 50)
    JsonBtn.Position = UDim2.new(0, 0, 0, 50)
    JsonBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    JsonBtn.Text = "📄 JSON"
    JsonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    JsonBtn.TextSize = 16
    JsonBtn.Font = Enum.Font.GothamBold
    JsonBtn.BorderSizePixel = 0
    
    RbxmBtn.Parent = ExportPage
    RbxmBtn.Size = UDim2.new(0.5, -5, 0, 50)
    RbxmBtn.Position = UDim2.new(0.5, 5, 0, 50)
    RbxmBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
    RbxmBtn.Text = "📦 RBXM"
    RbxmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RbxmBtn.TextSize = 16
    RbxmBtn.Font = Enum.Font.GothamBold
    RbxmBtn.BorderSizePixel = 0
    
    RbxlBtn.Parent = ExportPage
    RbxlBtn.Size = UDim2.new(0.5, -5, 0, 50)
    RbxlBtn.Position = UDim2.new(0, 0, 0, 110)
    RbxlBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 150)
    RbxlBtn.Text = "🗂️ RBXL"
    RbxlBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RbxlBtn.TextSize = 16
    RbxlBtn.Font = Enum.Font.GothamBold
    RbxlBtn.BorderSizePixel = 0
    
    HybridBtn.Parent = ExportPage
    HybridBtn.Size = UDim2.new(0.5, -5, 0, 50)
    HybridBtn.Position = UDim2.new(0.5, 5, 0, 110)
    HybridBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    HybridBtn.Text = "🔄 HYBRID"
    HybridBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HybridBtn.TextSize = 16
    HybridBtn.Font = Enum.Font.GothamBold
    HybridBtn.BorderSizePixel = 0
    
    ExportBtn.Parent = ExportPage
    ExportBtn.Size = UDim2.new(1, 0, 0, 60)
    ExportBtn.Position = UDim2.new(0, 0, 0, 180)
    ExportBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    ExportBtn.Text = "🚀 EXPORT NOW"
    ExportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExportBtn.TextSize = 24
    ExportBtn.Font = Enum.Font.GothamBold
    ExportBtn.BorderSizePixel = 0
    
    DiscordBtn.Parent = ExportPage
    DiscordBtn.Size = UDim2.new(1, 0, 0, 50)
    DiscordBtn.Position = UDim2.new(0, 0, 0, 250)
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
    DiscordBtn.Text = "🔗 DISCORD WEBHOOK"
    DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordBtn.TextSize = 16
    DiscordBtn.Font = Enum.Font.GothamBold
    DiscordBtn.BorderSizePixel = 0
    
    -- Files Page
    RefreshBtn.Parent = FilesPage
    RefreshBtn.Size = UDim2.new(1, 0, 0, 40)
    RefreshBtn.Position = UDim2.new(0, 0, 0, 0)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    RefreshBtn.Text = "🔄 REFRESH FILE LIST"
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.TextSize = 14
    RefreshBtn.Font = Enum.Font.GothamBold
    RefreshBtn.BorderSizePixel = 0
    
    FileList.Parent = FilesPage
    FileList.Size = UDim2.new(1, 0, 1, -50)
    FileList.Position = UDim2.new(0, 0, 0, 50)
    FileList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    FileList.BorderSizePixel = 0
    FileList.ScrollBarThickness = 8
    FileList.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
    FileList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Settings Page
    local SettingsTitle = Instance.new("TextLabel")
    SettingsTitle.Parent = SettingsPage
    SettingsTitle.Size = UDim2.new(1, 0, 0, 30)
    SettingsTitle.Position = UDim2.new(0, 0, 0, 10)
    SettingsTitle.BackgroundTransparency = 1
    SettingsTitle.Text = "⚙️ CONFIGURATION"
    SettingsTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    SettingsTitle.TextSize = 18
    SettingsTitle.Font = Enum.Font.GothamBold
    
    TerrainToggle.Parent = SettingsPage
    TerrainToggle.Size = UDim2.new(1, 0, 0, 40)
    TerrainToggle.Position = UDim2.new(0, 0, 0, 50)
    TerrainToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    TerrainToggle.Text = "🗻 TERRAIN CAPTURE: ON"
    TerrainToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TerrainToggle.TextSize = 14
    TerrainToggle.Font = Enum.Font.GothamBold
    TerrainToggle.BorderSizePixel = 0
    
    local WebhookLabel = Instance.new("TextLabel")
    WebhookLabel.Parent = SettingsPage
    WebhookLabel.Size = UDim2.new(1, 0, 0, 25)
    WebhookLabel.Position = UDim2.new(0, 0, 0, 110)
    WebhookLabel.BackgroundTransparency = 1
    WebhookLabel.Text = "DISCORD WEBHOOK URL"
    WebhookLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    WebhookLabel.TextSize = 12
    WebhookLabel.Font = Enum.Font.GothamBold
    WebhookLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    WebhookInput.Parent = SettingsPage
    WebhookInput.Size = UDim2.new(1, 0, 0, 35)
    WebhookInput.Position = UDim2.new(0, 0, 0, 140)
    WebhookInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    WebhookInput.BorderSizePixel = 0
    WebhookInput.Text = ""
    WebhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    WebhookInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    WebhookInput.TextSize = 14
    WebhookInput.Font = Enum.Font.Gotham
    
    SaveSettingsBtn.Parent = SettingsPage
    SaveSettingsBtn.Size = UDim2.new(1, 0, 0, 50)
    SaveSettingsBtn.Position = UDim2.new(0, 0, 0, 190)
    SaveSettingsBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
    SaveSettingsBtn.Text = "💾 SAVE SETTINGS"
    SaveSettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveSettingsBtn.TextSize = 16
    SaveSettingsBtn.Font = Enum.Font.GothamBold
    SaveSettingsBtn.BorderSizePixel = 0
    
    -- Store UI elements
    self.UI = {
        Screen = ScreenGui,
        Status = Status,
        ProgressFill = ProgressFill,
        ProgressText = ProgressText,
        ETA = ETA,
        ObjectsValue = ObjectsValue,
        SizeValue = SizeValue,
        TimeValue = TimeValue,
        StealBtn = StealBtn,
        StopBtn = StopBtn,
        JsonBtn = JsonBtn,
        RbxmBtn = RbxmBtn,
        RbxlBtn = RbxlBtn,
        HybridBtn = HybridBtn,
        ExportBtn = ExportBtn,
        DiscordBtn = DiscordBtn,
        RefreshBtn = RefreshBtn,
        FileList = FileList,
        TerrainToggle = TerrainToggle,
        WebhookInput = WebhookInput,
        SaveSettingsBtn = SaveSettingsBtn
    }
    
    -- Button functions
    StealBtn.MouseButton1Click:Connect(function()
        self:StealMap()
    end)
    
    StopBtn.MouseButton1Click:Connect(function()
        self:StopCapture()
    end)
    
    JsonBtn.MouseButton1Click:Connect(function()
        self:SetFormat("json")
    end)
    
    RbxmBtn.MouseButton1Click:Connect(function()
        self:SetFormat("rbxm")
    end)
    
    RbxlBtn.MouseButton1Click:Connect(function()
        self:SetFormat("rbxl")
    end)
    
    HybridBtn.MouseButton1Click:Connect(function()
        self:SetFormat("hybrid")
    end)
    
    ExportBtn.MouseButton1Click:Connect(function()
        self:ExportMap()
    end)
    
    DiscordBtn.MouseButton1Click:Connect(function()
        self:SetupDiscord()
    end)
    
    RefreshBtn.MouseButton1Click:Connect(function()
        self:RefreshFileList()
    end)
    
    SaveSettingsBtn.MouseButton1Click:Connect(function()
        self:SaveSettings()
    end)
    
    -- Toggle buttons
    TerrainToggle.MouseButton1Click:Connect(function()
        self.Config.IncludeTerrain = not self.Config.IncludeTerrain
        TerrainToggle.Text = "🗻 TERRAIN CAPTURE: " .. (self.Config.IncludeTerrain and "ON" or "OFF")
        TerrainToggle.BackgroundColor3 = self.Config.IncludeTerrain and Color3.fromRGB(0, 200, 150) or Color3.fromRGB(100, 100, 100)
    end)
    
    return ScreenGui
end

-- ==================================================
-- STOP CAPTURE
-- ==================================================
function MapStealer:StopCapture()
    self.Capturing = false
    self.UI.Status.Text = "⏹️ Capture stopped by user"
    self.UI.ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    self.UI.ProgressText.Text = "0%"
end

-- ==================================================
-- SET FORMAT
-- ==================================================
function MapStealer:SetFormat(format)
    self.Config.SaveFormat = format
    self.UI.Status.Text = "✅ Format set to: " .. format:upper()
    
    -- Highlight selected button
    self.UI.JsonBtn.BackgroundColor3 = format == "json" and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(50, 50, 60)
    self.UI.RbxmBtn.BackgroundColor3 = format == "rbxm" and Color3.fromRGB(150, 100, 200) or Color3.fromRGB(50, 50, 60)
    self.UI.RbxlBtn.BackgroundColor3 = format == "rbxl" and Color3.fromRGB(200, 100, 150) or Color3.fromRGB(50, 50, 60)
    self.UI.HybridBtn.BackgroundColor3 = format == "hybrid" and Color3.fromRGB(200, 150, 50) or Color3.fromRGB(50, 50, 60)
end

-- ==================================================
-- CAPTURE PROPERTIES (FIXED)
-- ==================================================
function MapStealer:CaptureProperties(obj)
    local properties = {}
    
    if not obj then return properties end
    
    local className = obj.ClassName
    
    -- Cari property list
    local propList = self.PropertyLists[className]
    if not propList then
        if obj:IsA("BasePart") then
            propList = self.PropertyLists.BasePart
        elseif obj:IsA("Decal") then
            propList = self.PropertyLists.Decal
        elseif obj:IsA("Light") then
            propList = self.PropertyLists.PointLight
        elseif obj:IsA("Constraint") then
            propList = self.PropertyLists.Weld
        elseif obj:IsA("ValueBase") then
            propList = self.PropertyLists.StringValue
        elseif obj:IsA("GuiObject") then
            propList = self.PropertyLists.Frame
        elseif obj:IsA("GuiBase2d") then
            propList = self.PropertyLists.BillboardGui
        elseif obj:IsA("ParticleEmitter") then
            propList = self.PropertyLists.ParticleEmitter
        elseif obj:IsA("Beam") then
            propList = self.PropertyLists.Beam
        elseif obj:IsA("Humanoid") then
            propList = self.PropertyLists.Humanoid
        elseif obj:IsA("Camera") then
            propList = self.PropertyLists.Camera
        elseif obj:IsA("Animation") then
            propList = self.PropertyLists.Animation
        else
            propList = self.FallbackProperties
        end
    end
    
    -- Capture properties
    for _, propName in ipairs(propList) do
        local success, value = pcall(function()
            return obj[propName]
        end)
        
        if success and value ~= nil then
            if typeof(value) == "CFrame" then
                properties[propName] = {
                    Position = {value.Position.X, value.Position.Y, value.Position.Z},
                    Rotation = {value:ToEulerAnglesXYZ()}
                }
            elseif typeof(value) == "Vector3" then
                properties[propName] = {value.X, value.Y, value.Z}
            elseif typeof(value) == "Color3" then
                properties[propName] = {value.R, value.G, value.B}
            elseif typeof(value) == "BrickColor" then
                properties[propName] = value.Number
            elseif typeof(value) == "UDim2" then
                properties[propName] = {
                    Scale = {value.X.Scale, value.Y.Scale},
                    Offset = {value.X.Offset, value.Y.Offset}
                }
            elseif typeof(value) == "EnumItem" then
                properties[propName] = value.Name
            elseif typeof(value) == "Instance" then
                if value:IsA("Player") then
                    properties[propName] = "Player:" .. value.Name
                else
                    properties[propName] = value:GetFullName()
                end
            else
                properties[propName] = value
            end
        end
    end
    
    return properties
end

-- ==================================================
-- SERIALIZE FUNCTIONS FOR TERRAIN (FIXED)
-- ==================================================
function MapStealer:SerializeVoxels(cells)
    if not cells then return {} end
    
    local result = {}
    for x = 1, #cells do
        result[x] = {}
        for y = 1, #cells[x] do
            result[x][y] = {}
            for z = 1, #cells[x][y] do
                result[x][y][z] = cells[x][y][z]
            end
        end
    end
    return result
end

function MapStealer:SerializeMaterials(materials)
    if not materials then return {} end
    
    local result = {}
    for x = 1, #materials do
        result[x] = {}
        for y = 1, #materials[x] do
            result[x][y] = {}
            for z = 1, #materials[x][y] do
                local mat = materials[x][y][z]
                if type(mat) == "userdata" and mat.ClassName == "EnumItem" then
                    result[x][y][z] = mat.Name
                else
                    result[x][y][z] = tostring(mat)
                end
            end
        end
    end
    return result
end

-- ==================================================
-- FUNGSI UTAMA STEAL MAP (FIXED TERRAIN)
-- ==================================================
function MapStealer:StealMap()
    self.Capturing = true
    self.UI.Status.Text = "📡 Initializing capture..."
    self.UI.ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    self.UI.ProgressText.Text = "0%"
    self.UI.ETA.Text = "ETA: calculating..."
    
    -- Reset data
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
            PlayerCount = #game.Players:GetPlayers(),
            GameName = "Unknown",
            Creator = "Unknown",
            Executor = self.Executor.name
        },
        Stats = {
            ByClass = {},
            TotalSize = 0,
            CaptureTime = 0
        }
    }
    
    -- Get game info
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        self.CapturedData.Metadata.GameName = info.Name or "Unknown"
        self.CapturedData.Metadata.Creator = info.Creator and info.Creator.Name or "Unknown"
    end)
    
    -- Count total objects
    local allDescendants = workspace:GetDescendants()
    local total = #allDescendants
    local current = 0
    local objects = {}
    local seenPaths = {}
    local startTime = tick()
    local lastUpdate = startTime
    
    self.UI.Status.Text = string.format("🔍 Scanning %d objects...", total)
    
    -- Iterate workspace
    for i, obj in ipairs(allDescendants) do
        if not self.Capturing then break end
        
        current = i
        
        -- Update progress
        local now = tick()
        if now - lastUpdate > 0.1 then
            local progress = current / total
            self.UI.ProgressFill:TweenSize(UDim2.new(progress, 0, 1, 0), "Out", "Linear", 0.1, true)
            self.UI.ProgressText.Text = math.floor(progress * 100) .. "%"
            
            -- Calculate ETA
            local elapsed = now - startTime
            local speed = current / elapsed
            if speed > 0 then
                local remaining = (total - current) / speed
                local minutes = math.floor(remaining / 60)
                local seconds = math.floor(remaining % 60)
                self.UI.ETA.Text = string.format("ETA: %d:%02d", minutes, seconds)
            end
            
            self.UI.ObjectsValue.Text = tostring(current) .. " / " .. tostring(total)
            lastUpdate = now
        end
        
        -- Skip ignored
        local skip = false
        for _, ignore in ipairs(self.Config.IgnoreList) do
            if obj:GetFullName():find(ignore) then
                skip = true
                break
            end
        end
        
        if not skip and not obj:IsA("Player") then
            local fullPath = obj:GetFullName()
            if not self.Config.FilterDuplicates or not seenPaths[fullPath] then
                seenPaths[fullPath] = true
                
                local cloneData = {
                    ClassName = obj.ClassName,
                    Name = obj.Name,
                    Parent = obj.Parent and obj.Parent:GetFullName() or nil,
                    Properties = self:CaptureProperties(obj)
                }
                
                table.insert(objects, cloneData)
                self.CapturedData.Stats.ByClass[obj.ClassName] = (self.CapturedData.Stats.ByClass[obj.ClassName] or 0) + 1
            end
        end
        
        -- Prevent lag
        if i % 100 == 0 then
            wait()
        end
    end
    
    if not self.Capturing then
        self.UI.Status.Text = "⏹️ Capture cancelled"
        return
    end
    
    self.CapturedData.Objects = objects
    self.Vault.TotalObjects = #objects
    self.UI.ObjectsValue.Text = #objects .. " objects"
    
    -- TERRAIN RIPPER - FIXED VERSION (NO SMOOTHING, PROPER ENUM)
    if self.Config.IncludeTerrain then
        self.UI.Status.Text = "🗻 Ripping terrain data..."
        wait(0.5)
        
        local terrain = workspace.Terrain
        local terrainData = {
            WaterColor = {terrain.WaterColor.R, terrain.WaterColor.G, terrain.WaterColor.B},
            WaterReflectance = terrain.WaterReflectance,
            WaterTransparency = terrain.WaterTransparency,
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed,
            MaterialColors = {},
            Cells = {},
            Materials = {}
        }
        
        -- FIXED: Proper Enum iteration
        for _, material in ipairs(Enum.Material:GetEnumItems()) do
            local color = terrain:GetMaterialColor(material)
            terrainData.MaterialColors[material.Name] = {color.R, color.G, color.B}
        end
        
        -- Scan region
        local region = Region3.new(Vector3.new(-2048, -1024, -2048), Vector3.new(2048, 1024, 2048))
        local resolution = Vector3.new(4, 4, 4)
        
        local success, cells, materials = pcall(function()
            return terrain:ReadVoxels(region, resolution)
        end)
        
        if success then
            terrainData.Cells = self:SerializeVoxels(cells)
            terrainData.Materials = self:SerializeMaterials(materials)
        end
        
        self.CapturedData.Terrain = terrainData
    end
    
    -- Spawns
    if self.Config.IncludeSpawns then
        self.UI.Status.Text = "📍 Capturing spawn locations..."
        local spawns = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") then
                table.insert(spawns, {
                    Position = {obj.Position.X, obj.Position.Y, obj.Position.Z},
                    CFrame = {
                        Position = {obj.CFrame.Position.X, obj.CFrame.Position.Y, obj.CFrame.Position.Z},
                        Rotation = {obj.CFrame:ToEulerAnglesXYZ()}
                    },
                    TeamColor = obj.TeamColor and obj.TeamColor.Number or nil,
                    Duration = obj.Duration,
                    Neutral = obj.Neutral,
                    AllowTeamChangeOnTouch = obj.AllowTeamChangeOnTouch,
                    Enabled = obj.Enabled
                })
            end
        end
        self.CapturedData.Spawns = spawns
    end
    
    -- Lighting
    if self.Config.IncludeLighting then
        self.UI.Status.Text = "💡 Capturing lighting settings..."
        local lighting = {}
        for _, prop in ipairs(self.PropertyLists.Lighting) do
            pcall(function()
                local value = game.Lighting[prop]
                if typeof(value) == "Color3" then
                    lighting[prop] = {value.R, value.G, value.B}
                elseif typeof(value) == "number" or typeof(value) == "boolean" or typeof(value) == "string" then
                    lighting[prop] = value
                elseif typeof(value) == "EnumItem" then
                    lighting[prop] = value.Name
                end
            end)
        end
        self.CapturedData.Lighting = lighting
    end
    
    -- Calculate stats
    local captureTime = tick() - startTime
    self.CapturedData.Metadata.CaptureTime = captureTime
    self.CapturedData.Stats.TotalSize = self:CalculateDataSize(self.CapturedData)
    
    -- Update UI
    local minutes = math.floor(captureTime / 60)
    local seconds = math.floor(captureTime % 60)
    self.UI.TimeValue.Text = string.format("%d:%02d", minutes, seconds)
    self.UI.SizeValue.Text = self:FormatSize(self.CapturedData.Stats.TotalSize)
    
    -- Save to vault
    table.insert(self.Vault.CapturedMaps, {
        Time = os.time(),
        Objects = #objects,
        Data = self.CapturedData
    })
    self.Vault.LastCapture = os.time()
    
    self.UI.Status.Text = string.format("✅ Map captured! (%d objects in %d:%02d)", #objects, minutes, seconds)
    self.UI.ProgressFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 0.5, true)
    self.UI.ProgressText.Text = "100%"
    self.UI.ETA.Text = "ETA: done!"
    
    -- Auto save
    if self.Config.AutoSave then
        self:ExportMap()
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
-- CALCULATE DATA SIZE
-- ==================================================
function MapStealer:CalculateDataSize(data)
    local json = game:GetService("HttpService"):JSONEncode(data)
    return #json
end

-- ==================================================
-- FORMAT SIZE
-- ==================================================
function MapStealer:FormatSize(bytes)
    if bytes < 1024 then
        return bytes .. " B"
    elseif bytes < 1024 * 1024 then
        return string.format("%.1f KB", bytes / 1024)
    else
        return string.format("%.1f MB", bytes / (1024 * 1024))
    end
end

-- ==================================================
-- EXPORT MAP
-- ==================================================
function MapStealer:ExportMap()
    if not self.CapturedData then
        self.UI.Status.Text = "❌ Nothing to export! Steal a map first."
        return
    end
    
    self.UI.Status.Text = "📦 Exporting map..."
    
    local HttpService = game:GetService("HttpService")
    local format = self.Config.SaveFormat
    
    -- Generate filename
    local placeName = self.CapturedData.Metadata.GameName:gsub("[^%w%s]", ""):gsub("%s+", "_")
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local baseName = string.format("%s_%s", placeName, timestamp)
    
    if format == "json" then
        local jsonData = HttpService:JSONEncode(self.CapturedData)
        local filename = baseName .. ".json"
        
        local success = self:WriteFile(filename, jsonData)
        if success then
            self.UI.Status.Text = "✅ Exported as " .. filename
            self.Vault.TotalSize = #jsonData
            self.UI.SizeValue.Text = self:FormatSize(#jsonData)
        end
        
    elseif format == "rbxm" or format == "rbxl" then
        self.UI.Status.Text = "📋 RBXM Export Instructions:"
        wait(2)
        self.UI.Status.Text = "1. Save JSON first (click JSON format)"
        wait(2)
        self.UI.Status.Text = "2. Open Roblox Studio"
        wait(2)
        self.UI.Status.Text = "3. Use plugin 'RBXM Builder' to convert"
        wait(2)
        self.UI.Status.Text = "JSON saved - ready for Studio import"
        
        local jsonData = HttpService:JSONEncode(self.CapturedData)
        local filename = baseName .. ".json"
        self:WriteFile(filename, jsonData)
        
    elseif format == "hybrid" then
        local jsonData = HttpService:JSONEncode(self.CapturedData)
        local jsonFile = baseName .. ".json"
        
        self:WriteFile(jsonFile, jsonData)
        
        local instructions = [[
cvAI4 Map Stealer V3.2 - Hybrid Export Instructions

JSON File: ]] .. jsonFile .. [[

To create working RBXM with terrain:

1. Open Roblox Studio
2. Create new baseplate
3. Use this script in Command Bar to load:

local HttpService = game:GetService("HttpService")
local json = -- Paste your JSON content here
local data = HttpService:JSONDecode(json)

-- Then use a JSON to Model plugin

4. Copy terrain manually from original game
5. Save as RBXM
]]
        
        self:WriteFile(baseName .. "_README.txt", instructions)
        self.UI.Status.Text = "✅ Hybrid export complete! See README"
    end
    
    -- Upload ke Discord
    if self.Config.Webhook.Enabled and self.Config.Webhook.AutoUpload then
        self:UploadToDiscord()
    end
    
    -- Refresh file list
    self:RefreshFileList()
end

-- ==================================================
-- WRITE FILE
-- ==================================================
function MapStealer:WriteFile(filename, content)
    local success = false
    
    pcall(function()
        if self.Executor.write then
            self.Executor.write(filename, content)
            success = true
        elseif writefile then
            writefile(filename, content)
            success = true
        end
    end)
    
    return success
end

-- ==================================================
-- READ FILE
-- ==================================================
function MapStealer:ReadFile(filename)
    local content = nil
    
    pcall(function()
        if self.Executor.read then
            content = self.Executor.read(filename)
        elseif readfile then
            content = readfile(filename)
        end
    end)
    
    return content
end

-- ==================================================
-- LIST FILES
-- ==================================================
function MapStealer:ListFiles()
    local files = {}
    
    pcall(function()
        if self.Executor.list then
            files = self.Executor.list()
        elseif listfiles then
            files = listfiles()
        end
    end)
    
    return files
end

-- ==================================================
-- REFRESH FILE LIST
-- ==================================================
function MapStealer:RefreshFileList()
    local files = self:ListFiles()
    
    -- Filter map files
    local mapFiles = {}
    for _, file in ipairs(files) do
        if file:match(".+_%d+_%d+%.json") then
            table.insert(mapFiles, file)
        end
    end
    
    -- Clear list
    for _, child in ipairs(self.UI.FileList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Sort by date
    table.sort(mapFiles, function(a, b)
        return a > b
    end)
    
    -- Populate
    local yPos = 0
    for _, file in ipairs(mapFiles) do
        local fileName = file:match("([^\\/]+)$")
        local fileBtn = Instance.new("TextButton")
        fileBtn.Parent = self.UI.FileList
        fileBtn.Size = UDim2.new(1, -10, 0, 30)
        fileBtn.Position = UDim2.new(0, 5, 0, yPos)
        fileBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        fileBtn.Text = "📄 " .. fileName
        fileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        fileBtn.TextSize = 12
        fileBtn.Font = Enum.Font.Gotham
        fileBtn.BorderSizePixel = 0
        fileBtn.TextXAlignment = Enum.TextXAlignment.Left
        fileBtn.Name = file
        
        -- Get file size
        local content = self:ReadFile(file)
        local size = content and #content or 0
        local sizeText = self:FormatSize(size)
        
        -- Add size label
        local sizeLabel = Instance.new("TextLabel")
        sizeLabel.Parent = fileBtn
        sizeLabel.Size = UDim2.new(0, 60, 1, 0)
        sizeLabel.Position = UDim2.new(1, -65, 0, 0)
        sizeLabel.BackgroundTransparency = 1
        sizeLabel.Text = sizeText
        sizeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        sizeLabel.TextSize = 10
        sizeLabel.Font = Enum.Font.Gotham
        sizeLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        -- Select function
        fileBtn.MouseButton1Click:Connect(function()
            self:SelectFile(file)
        end)
        
        yPos = yPos + 35
    end
    
    self.UI.FileList.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- ==================================================
-- SELECT FILE
-- ==================================================
function MapStealer:SelectFile(filename)
    self.SelectedFile = filename
    self.UI.Status.Text = "📁 Selected: " .. (filename:match("([^\\/]+)$") or filename)
end

-- ==================================================
-- DISCORD SETUP
-- ==================================================
function MapStealer:SetupDiscord()
    self.Config.Webhook.Enabled = true
    self.Config.Webhook.Url = self.UI.WebhookInput.Text
    self.Config.Webhook.AutoUpload = true
    
    self.UI.Status.Text = "✅ Discord webhook configured!"
end

-- ==================================================
-- UPLOAD TO DISCORD
-- ==================================================
function MapStealer:UploadToDiscord()
    if not self.Config.Webhook.Enabled or self.Config.Webhook.Url == "" then
        return
    end
    
    if not self.CapturedData then
        return
    end
    
    local HttpService = game:GetService("HttpService")
    
    local embed = {
        title = "🗺️ Map Captured!",
        description = string.format("**Game:** %s\n**Objects:** %d\n**Time:** %s\n**Executor:** %s",
            self.CapturedData.Metadata.GameName,
            #self.CapturedData.Objects,
            self.CapturedData.Metadata.ServerTime,
            self.Executor.name
        ),
        color = 65535,
        fields = {
            {
                name = "📊 Statistics",
                value = string.format("Size: %s\nCapture Time: %.1fs",
                    self:FormatSize(self.CapturedData.Stats.TotalSize),
                    self.CapturedData.Metadata.CaptureTime
                ),
                inline = true
            },
            {
                name = "🏷️ Info",
                value = string.format("Place ID: %d\nCreator: %s",
                    self.CapturedData.Metadata.PlaceId,
                    self.CapturedData.Metadata.Creator
                ),
                inline = true
            }
        },
        footer = {
            text = "cvAI4 Map Ripper V3.2 - ULTIMATE FIXED"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    local data = {
        username = "cvAI4 Map Stealer",
        avatar_url = "https://i.imgur.com/4M34hi2.png",
        embeds = {embed}
    }
    
    pcall(function()
        HttpService:PostAsync(self.Config.Webhook.Url, HttpService:JSONEncode(data))
    end)
    
    self.UI.Status.Text = "✅ Uploaded to Discord"
end

-- ==================================================
-- SAVE SETTINGS
-- ==================================================
function MapStealer:SaveSettings()
    self.Config.Webhook.Url = self.UI.WebhookInput.Text
    
    local settingsData = game:GetService("HttpService"):JSONEncode(self.Config)
    self:WriteFile("cvAI4_Settings.json", settingsData)
    
    self.UI.Status.Text = "⚙️ Settings saved!"
end

-- ==================================================
-- LOAD SETTINGS
-- ==================================================
function MapStealer:LoadSettings()
    local content = self:ReadFile("cvAI4_Settings.json")
    if content then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(content)
        end)
        
        if success and data then
            self.Config = data
            self.UI.Status.Text = "⚙️ Settings loaded!"
        end
    end
end

-- ==================================================
-- INITIALIZATION
-- ==================================================
function MapStealer:Init()
    print("🗺️ cvAI4 MAP RIPPER V3.2 - ULTIMATE FIXED EDITION")
    print("👾 Created by: cvAI4 for Tuan Gigs")
    print("✅ ALL ERRORS FIXED: Smoothing removed, Enum iteration fixed")
    
    -- Detect executor
    local exec = self:DetectExecutor()
    print("⚡ Executor: " .. exec.name)
    print("📦 Supported: " .. table.concat(exec.supports, ", "))
    
    -- Create UI
    self:CreateUI()
    
    -- Load settings
    self:LoadSettings()
    
    -- Refresh file list
    self:RefreshFileList()
    
    -- Welcome message
    self.UI.Status.Text = "🟢 cvAI4 V3.2 FIXED - Ready to steal maps!"
    self.UI.ObjectsValue.Text = "0"
    self.UI.SizeValue.Text = "0 KB"
    self.UI.TimeValue.Text = "--:--"
    
    print("✅ cvAI4 V3.2 loaded! No more Smoothing or Enum errors")
    
    return self
end

-- ==================================================
-- AUTO EXECUTE
-- ==================================================
local ripper = setmetatable({}, MapStealer)
ripper:Init()

-- Global access
_G.cvAI4_MapStealer = ripper
_G.MS = ripper

print("✅ Type _G.MS or _G.cvAI4_MapStealer to access")
print("🎯 ALL ERRORS FIXED - Enjoy!")
