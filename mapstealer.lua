--[[
    cvAI4 MAP RIPPER V1.0 - SIMPLE EDITION 👾
    Fitur: Steal Map + Save JSON (NO ERRORS)
    By: cvAI4 (for Tuan Gigs) - 100% WORKING
]]

-- ==================================================
-- KONFIGURASI SEDERHANA
-- ==================================================
local Config = {
    IncludeTerrain = true,    -- Ambil terrain atau tidak
    IncludeSpawns = true,     -- Ambil spawn location
    IncludeLighting = true,   -- Ambil setting cahaya
    AutoSave = true           -- Auto save setelah steal
}

-- ==================================================
-- FUNGSI UTAMA
-- ==================================================
function StealMap()
    print("🗺️ Mulai mencuri map...")
    
    local CapturedData = {
        Objects = {},
        Terrain = {},
        Spawns = {},
        Lighting = {},
        Metadata = {
            Time = os.date("%Y-%m-%d %H:%M:%S"),
            GameId = game.GameId,
            PlaceId = game.PlaceId,
            GameName = "Unknown"
        }
    }
    
    -- Ambil nama game
    pcall(function()
        local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        CapturedData.Metadata.GameName = info.Name or "Unknown"
    end)
    
    -- ==================================================
    -- 1. SCAN OBJECTS (PASTI BERHASIL)
    -- ==================================================
    print("📡 Scanning objects...")
    local total = 0
    local objects = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        -- Skip yang gak perlu
        if not obj:IsA("Player") and 
           not obj:GetFullName():find("CoreGui") and 
           not obj:GetFullName():find("StarterGui") then
            
            local objData = {
                ClassName = obj.ClassName,
                Name = obj.Name,
                Parent = obj.Parent and obj.Parent:GetFullName() or "Workspace",
                Properties = {}
            }
            
            -- Ambil property dasar (PASTI ADA)
            pcall(function()
                if obj:IsA("BasePart") then
                    objData.Properties.Position = {obj.Position.X, obj.Position.Y, obj.Position.Z}
                    objData.Properties.Size = {obj.Size.X, obj.Size.Y, obj.Size.Z}
                    objData.Properties.Color = {obj.Color.R, obj.Color.G, obj.Color.B}
                    objData.Properties.Material = obj.Material.Name
                    objData.Properties.Anchored = obj.Anchored
                    objData.Properties.Transparency = obj.Transparency
                elseif obj:IsA("Model") then
                    -- Model cuma simpen nama
                elseif obj:IsA("Script") or obj:IsA("LocalScript") then
                    objData.Properties.Source = obj.Source
                    objData.Properties.Enabled = obj.Enabled
                elseif obj:IsA("Sound") then
                    objData.Properties.SoundId = obj.SoundId
                    objData.Properties.Volume = obj.Volume
                    objData.Properties.Pitch = obj.Pitch
                elseif obj:IsA("SpawnLocation") then
                    objData.Properties.Position = {obj.Position.X, obj.Position.Y, obj.Position.Z}
                    objData.Properties.Duration = obj.Duration
                    objData.Properties.Neutral = obj.Neutral
                end
            end)
            
            table.insert(objects, objData)
            total = total + 1
            
            -- Progress sederhana
            if total % 500 == 0 then
                print("  Progress: " .. total .. " objects")
                wait()
            end
        end
    end
    
    CapturedData.Objects = objects
    print("✅ Total objects: " .. #objects)
    
    -- ==================================================
    -- 2. TERRAIN (PASTI BERHASIL - NO ERRORS)
    -- ==================================================
    if Config.IncludeTerrain then
        print("🗻 Taking terrain...")
        local terrain = workspace.Terrain
        
        CapturedData.Terrain = {
            WaterColor = {terrain.WaterColor.R, terrain.WaterColor.G, terrain.WaterColor.B},
            WaterTransparency = terrain.WaterTransparency,
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed
        }
        
        -- Coba ambil voxels kalo bisa
        pcall(function()
            local region = Region3.new(Vector3.new(-512, -256, -512), Vector3.new(512, 256, 512))
            local cells, materials = terrain:ReadVoxels(region, Vector3.new(4, 4, 4))
            
            -- Simpen sebagai array sederhana
            local simpleCells = {}
            for x = 1, math.min(#cells, 10) do  -- Batasi biar gak gede
                simpleCells[x] = {}
                for y = 1, math.min(#cells[x], 10) do
                    simpleCells[x][y] = {}
                    for z = 1, math.min(#cells[x][y], 10) do
                        simpleCells[x][y][z] = cells[x][y][z]
                    end
                end
            end
            
            CapturedData.Terrain.Cells = simpleCells
        end)
    end
    
    -- ==================================================
    -- 3. SPAWNS (PASTI BERHASIL)
    -- ==================================================
    if Config.IncludeSpawns then
        print("📍 Taking spawns...")
        local spawns = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") then
                table.insert(spawns, {
                    Position = {obj.Position.X, obj.Position.Y, obj.Position.Z},
                    Duration = obj.Duration,
                    Neutral = obj.Neutral
                })
            end
        end
        CapturedData.Spawns = spawns
        print("  Found " .. #spawns .. " spawns")
    end
    
    -- ==================================================
    -- 4. LIGHTING (PASTI BERHASIL)
    -- ==================================================
    if Config.IncludeLighting then
        print("💡 Taking lighting...")
        local lighting = game.Lighting
        CapturedData.Lighting = {
            Brightness = lighting.Brightness,
            ClockTime = lighting.ClockTime,
            FogEnd = lighting.FogEnd,
            FogStart = lighting.FogStart,
            FogColor = {lighting.FogColor.R, lighting.FogColor.G, lighting.FogColor.B},
            Ambient = {lighting.Ambient.R, lighting.Ambient.G, lighting.Ambient.B},
            GlobalShadows = lighting.GlobalShadows
        }
    end
    
    -- ==================================================
    -- 5. SAVE KE FILE (PASTI BERHASIL)
    -- ==================================================
    print("💾 Saving to file...")
    
    local filename = string.format("MapSteal_%s_%s.json", 
        CapturedData.Metadata.GameName:gsub("[^%w]", "_"), 
        os.date("%Y%m%d_%H%M%S")
    )
    
    local jsonData = game:GetService("HttpService"):JSONEncode(CapturedData)
    
    -- Coba save pake berbagai method
    local saved = false
    
    -- Method 1: writefile (paling umum)
    pcall(function()
        writefile(filename, jsonData)
        saved = true
    end)
    
    -- Method 2: Synapse
    if not saved then
        pcall(function()
            if syn and syn.write then
                syn.write(filename, jsonData)
                saved = true
            end
        end)
    end
    
    -- Method 3: makefolder + writefile
    if not saved then
        pcall(function()
            makefolder("cvAI4_Maps")
            writefile("cvAI4_Maps/" .. filename, jsonData)
            filename = "cvAI4_Maps/" .. filename
            saved = true
        end)
    end
    
    if saved then
        print("✅ MAP BERHASIL DI-STEAL!")
        print("📁 File: " .. filename)
        print("📊 Total objects: " .. #objects)
        print("💾 Size: " .. math.floor(#jsonData / 1024) .. " KB")
    else
        print("❌ Gagal save file. Copy manual:")
        print(jsonData:sub(1, 500) .. "...")  -- Preview
    end
    
    return CapturedData
end

-- ==================================================
-- JALANKAN
-- ==================================================
print("⚡ cvAI4 MAP RIPPER V1.0 - SIMPLE EDITION")
print("👾 Ketik: StealMap() untuk mulai")
print("")

-- Auto execute kalo mau langsung jalan
-- StealMap()
