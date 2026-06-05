--   Infinity Yield Matcha Edition

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Utilities
local function getChar()
    return lp.Character
end

local function getHumanoid()
    local char = getChar()
    if char then return char:FindFirstChildOfClass("Humanoid") end
end

local function getRootPart()
    local char = getChar()
    if char then return char:FindFirstChild("HumanoidRootPart") end
end

local function findPlayer(name)
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) then
            return p
        end
    end
end

local function sendNotify(msg, title, duration)
    notify(msg, title or "IY Matcha", duration or 3)
end


-- States
local flyEnabled = false
local noclipEnabled = false
local flyThread = nil
local noclipThread = nil
local antiAFKEnabled = false
local antiAFKThread = nil
local autoclickEnabled = false
local autoclickThread = nil
local waypoints = {}   
local wpMarkers = {}       

-- Commands
local commands = {}

-- Offsets Humanoid for memory_write
local HUM_WALKSPEED = 468
local HUM_JUMPPOWER = 432
local HUM_HEALTH    = 404
local HUM_MAXHEALTH = 436

local function humWrite(offset, val)
    local hum = getHumanoid()
    if not hum then sendNotify("Humanoid not found") return false end
    local addr = tonumber(hum.Address)
    if not addr or addr <= 4096 then sendNotify("Invalid address") return false end
    local ok, err = pcall(memory_write, "float", addr + offset, val)
    if not ok then sendNotify("memory_write error: " .. tostring(err), "IY Error", 3) return false end
    return true
end

-- SPEED
local speedValue = 16
local speedConn  = nil
commands["speed"] = function(args)
    local val = tonumber(args[1])
    if not val then sendNotify("Usage: speed [val]") return end
    speedValue = val
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    local RS = game:GetService("RunService")
    speedConn = RS.Heartbeat:Connect(function()
        local hum = getHumanoid()
        if hum then
            -- Essayer les deux méthodes
            pcall(function() hum.WalkSpeed = speedValue end)
            humWrite(HUM_WALKSPEED, speedValue)
        end
    end)
    sendNotify("Speed -> " .. val)
end

-- JUMP
commands["jump"] = function(args)
    local val = tonumber(args[1])
    if not val then sendNotify("Usage: jump [valeur]") return end
    if humWrite(HUM_JUMPPOWER, val) then sendNotify("Jump -> " .. val) end
end

local heart = game:GetService("RunService").Heartbeat
local godConnection = nil

commands["god"] = function()
    if godConnection then sendNotify("God already active!") return end
    godConnection = heart:Connect(function()
        local hum = getHumanoid()
        if hum then
            local addr = tonumber(hum.Address)
            if addr and addr > 4096 then
                pcall(memory_write, "float", addr + HUM_MAXHEALTH, 99999)
                pcall(memory_write, "float", addr + HUM_HEALTH,    99999)
            end
        end
    end)
    sendNotify("God ON")
end

commands["ungod"] = function()
    if godConnection then
        godConnection:Disconnect()
        godConnection = nil
        sendNotify("Mode Dieu désactivé")
    end
end

-- FLY
commands["fly"] = function()
    if flyEnabled then sendNotify("Fly déjà actif !") return end
    flyEnabled = true
    sendNotify("Fly activé ✓")

    flyThread = task.spawn(function()
        local SPEED = 50
        while flyEnabled do
            local root = getRootPart()
            local hum = getHumanoid()
            if root and hum then

                local vel = Vector3.new(0, 0, 0)

                if iskeypressed(0x57) then -- W
                    vel = vel + root.CFrame.LookVector * SPEED
                end
                if iskeypressed(0x53) then -- S
                    vel = vel - root.CFrame.LookVector * SPEED
                end
                if iskeypressed(0x41) then -- A
                    vel = vel - root.CFrame.RightVector * SPEED
                end
                if iskeypressed(0x44) then -- D
                    vel = vel + root.CFrame.RightVector * SPEED
                end
                if iskeypressed(0x20) then -- SPACE
                    vel = vel + Vector3.new(0, SPEED, 0)
                end
                if iskeypressed(0x10) then -- SHIFT
                    vel = vel - Vector3.new(0, SPEED, 0)
                end

                root.AssemblyLinearVelocity = vel
            end
            task.wait(0.03)
        end

    end)
end

-- UNFLY
commands["unfly"] = function()
    flyEnabled = false
    sendNotify("Fly désactivé")
end

-- NOCLIP
commands["noclip"] = function()
    if noclipEnabled then sendNotify("Noclip is already active!") return end
    noclipEnabled = true
    sendNotify("Noclip activated ")

    noclipThread = task.spawn(function()
        while noclipEnabled do
            local char = getChar()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- CLIP
commands["clip"] = function()
    noclipEnabled = false
    local char = getChar()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    sendNotify("Noclip disabled")
end

-- TP 
commands["tp"] = function(args)
    local name = args[1]
    if not name then 
        sendNotify("Usage: ;tp [player] or ;tp random") 
        return 
    end
    
    local target = nil
    if name:lower() == "random" then
        local players = Players:GetPlayers()
        if #players == 0 then 
            sendNotify("No players found") 
            return 
        end
        local others = {}
        for _, p in ipairs(players) do
            if p ~= lp then table.insert(others, p) end
        end
        if #others == 0 then others = players end
        target = others[math.random(1, #others)]
        sendNotify("Random target: " .. target.Name)
    else
        target = findPlayer(name)
        if not target then 
            sendNotify("Player not found: " .. name) 
            return 
        end
    end
    
    local targetChar = target.Character
    local root = getRootPart()
    if targetChar and root then
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            root.CFrame = CFrame.new(targetRoot.Position.X, targetRoot.Position.Y + 3, targetRoot.Position.Z)
            sendNotify("Téléporté vers " .. target.Name)
        else
            sendNotify("Target RootPart not found")
        end
    else
        sendNotify("Target character not found")
    end
end

-- BRING
commands["bring"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;bring [player]") return end
    local target = findPlayer(name)
    if not target then sendNotify("Player not found: " .. name) return end
    local targetChar = target.Character
    local root = getRootPart()
    if targetChar and root then
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            targetRoot.CFrame = CFrame.new(root.Position.X + 3, root.Position.Y, root.Position.Z)
            sendNotify("Brought " .. target.Name)
        end
    end
end



-- NOTIFY
commands["notify"] = function(args)
    local msg = table.concat(args, " ")
    if msg == "" then sendNotify("Usage: notify [message]") return end
    sendNotify(msg, "Notification", 5)
end

-- RESET
commands["reset"] = function()
    local root = getRootPart()
    if root then
        root.CFrame = CFrame.new(root.Position.X, -10000, root.Position.Z)
        sendNotify("Character reset")
    else
        sendNotify("Character not found", "IY Error", 3)
    end
end


commands["game"] = function()
    local success, name = pcall(function()
        local marketplace = game:GetService("MarketplaceService")
        local info = marketplace:GetProductInfo(game.PlaceId)
        return info.Name
    end)
    if success and name then
        sendNotify(name, "Current game", 4)
    else
        local placeName = game.Name or "Inconnu"
        local placeId = game.PlaceId or "?"
        sendNotify(placeName .. " (ID: " .. placeId .. ")", "Current game", 4)
    end
end

-- WS 
commands["ws"] = function(args)
    commands["speed"](args)
end

-- JH 
commands["jh"] = function(args)
    local val = tonumber(args[1])
    if not val then sendNotify("Usage: jh [val]") return end
    if humWrite(HUM_JUMPPOWER, val) then sendNotify("Jump -> " .. val) end
end

-- TIME
commands["time"] = function()
    local t = math.floor(os.time())
    local h = math.floor(t / 3600) % 24
    local m = math.floor(t / 60) % 60
    local s = t % 60
    sendNotify(string.format("%02d:%02d:%02d", h, m, s), "Server time", 4)
end

-- COORDS
commands["coords"] = function()
    local root = getRootPart()
    if root then
        local p = root.Position
        sendNotify(string.format("X:%.1f Y:%.1f Z:%.1f", p.X, p.Y, p.Z), "Coordinates", 5)
    end
end

-- FLING
commands["fling"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;fling [player]") return end
    local target = findPlayer(name)
    if not target then sendNotify("Player not found") return end
    local targetChar = target.Character
    if not targetChar then sendNotify("Target character not found") return end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local myRoot = getRootPart()
    if not myRoot then return end
    
    -- Saves original position/orientation
    local originalCF = myRoot.CFrame
    local wasNoclip = noclipEnabled
    
    sendNotify("FLING sur " .. target.Name, "IY Matcha", 3)
    
    -- Enable noclip to position
    if not noclipEnabled then commands["noclip"]() end
    task.wait(0.05)
    
    -- Position yourself horizontally inside the target
    myRoot.CFrame = targetRoot.CFrame * CFrame.Angles(math.pi/2, 0, 0)
    task.wait(0.05)
    
    -- Disable noclip for collision
    if not wasNoclip then commands["clip"]() end
    task.wait(0.05)
    
    -- Spin and throws
    local duration = 0.8
    local startTime = tick()
    local angle = 0
    local spinSpeed = 300
    
    while tick() - startTime < duration do
        angle = (angle + spinSpeed * 0.03) % 360
        local newCF = targetRoot.CFrame * CFrame.Angles(math.pi/2, math.rad(angle), 0)
        myRoot.CFrame = newCF
        myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        targetRoot.AssemblyLinearVelocity = Vector3.new(
            math.random(-800, 800),
            math.random(1500, 3000),
            math.random(-800, 800)
        )
        task.wait(0.03)
    end
    
    -- Check
    task.wait(0.2)
    if targetRoot.AssemblyLinearVelocity.Magnitude > 100 then
        sendNotify("Success ! " .. target.Name .. " was projected", "FLING", 3)
    else
        sendNotify("Failure: stationary target", "FLING", 3)
    end
    
    -- Restore your original position and orientation
    myRoot.CFrame = originalCF
    myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    
    -- Restore the noclip state
    if wasNoclip == false then
        commands["clip"]()
    end
end

-- ANTIFLING
local antiFlingEnabled = false
local antiFlingThread  = nil
commands["antifling"] = function()
    if antiFlingEnabled then sendNotify("AntiFling already active!") return end
    antiFlingEnabled = true
    sendNotify("AntiFling ON")
    antiFlingThread = task.spawn(function()
        while antiFlingEnabled do
            local root = getRootPart()
            if root then
                local vel = root.AssemblyLinearVelocity
                -- If the velocity is absurd, we reset it
                if vel.Magnitude > 200 then
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
            task.wait(0.05)
        end
    end)
end

commands["noantifling"] = function()
    antiFlingEnabled = false
    sendNotify("AntiFling OFF")
end

-- LOOPTP / STOPLOOPTP
local looptpEnabled = false
local looptpThread  = nil
commands["looptp"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: looptp [player]") return end
    local target = findPlayer(name)
    if not target then sendNotify("Player not found: " .. name) return end
    if looptpEnabled then
        looptpEnabled = false
        task.wait(0.1)
    end
    looptpEnabled = true
    sendNotify("LoopTP -> " .. target.Name .. " (stoplooptp to stop)")
    looptpThread = task.spawn(function()
        while looptpEnabled do
            local root = getRootPart()
            local tc   = target.Character
            if root and tc then
                local tr = tc:FindFirstChild("HumanoidRootPart")
                if tr then
                    root.CFrame = CFrame.new(tr.Position.X, tr.Position.Y + 3, tr.Position.Z)
                end
            end
            task.wait(0.1)
        end
    end)
end

commands["stoplooptp"] = function()
    looptpEnabled = false
    sendNotify("LoopTP stopped")
end

commands["addwp"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;addwp [name]") return end
    local root = getRootPart()
    if not root then sendNotify("Character not found") return end
    waypoints[name] = {
        CFrame = root.CFrame,
        Position = root.Position,
        Name = name
    }
    sendNotify("Waypoint '" .. name .. "' added")
end

commands["delwp"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;delwp [name]") return end
    if waypoints[name] then
        waypoints[name] = nil
        sendNotify("Waypoint '" .. name .. "' deleted")
    else
        sendNotify("Waypoint '" .. name .. "' not found")
    end
end

commands["tpwp"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;tpwp [nom]") return end
    local wp = waypoints[name]
    if wp then
        local root = getRootPart()
        if root then
            root.CFrame = wp.CFrame
            sendNotify("Teleported to '" .. name .. "'")
        end
    else
        sendNotify("Waypoint '" .. name .. "' not found")
    end
end

commands["wp"] = function()
    local list = {}
    for name in pairs(waypoints) do table.insert(list, name) end
    if #list == 0 then
        sendNotify("Aucun waypoint. Tapez ;addwp [nom]")
    else
        sendNotify("Waypoints : " .. table.concat(list, ", "))
    end
end

-- SPIN 
local spinEnabled = false
local spinConn    = nil
local spinSpeed   = 15
commands["spin"] = function(args)
    local spd = tonumber(args[1])
    if spd then spinSpeed = spd end
    if spinEnabled then
        sendNotify("Spin speed -> " .. spinSpeed)
        return
    end
    spinEnabled = true
    sendNotify("Spin ON (speed: " .. spinSpeed .. ")")
    local RS = game:GetService("RunService")
    local angle = 0
    spinConn = RS.Heartbeat:Connect(function()
        if not spinEnabled then
            spinConn:Disconnect()
            spinConn = nil
            return
        end
        local root = getRootPart()
        if root then
            angle = (angle + spinSpeed) % 360
            local rad = math.rad(angle)
            -- Read the position AFTER the game updates it this tick
            local pos = root.Position
            root.CFrame = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(0, rad, 0)
            -- Maintain velocity so that the movement continues
            local vel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = vel
        end
    end)
end

-- UNSPIN
commands["unspin"] = function()
    spinEnabled = false
    sendNotify("Spin OFF")
end

-- INF JUMP
local infJumpEnabled = false
local infJumpConn    = nil
commands["infjump"] = function()
    if infJumpEnabled then
        sendNotify("Inf Jump already active! Use noinfjump to stop")
        return
    end
    infJumpEnabled = true
    sendNotify("Inf Jump ON - hold Space")
    local RS = game:GetService("RunService")
    infJumpConn = RS.Heartbeat:Connect(function()
        if not infJumpEnabled then return end
        -- Ne pas interférer avec speed ou jumppower
        if iskeypressed(0x20) then
            local root = getRootPart()
            if root then
                local vel = root.AssemblyLinearVelocity
                -- Seulement pousser vers le haut si on n'est pas déjà très haut
                if vel.Y < 50 then
                    root.AssemblyLinearVelocity = Vector3.new(vel.X, 80, vel.Z)
                end
            end
        end
    end)
end

commands["noinfjump"] = function()
    infJumpEnabled = false
    if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    sendNotify("Inf Jump OFF")
end

-- ANTI-AFK
commands["antiafk"] = function()
    if antiAFKEnabled then
        sendNotify("Anti-AFK already active")
        return
    end
    antiAFKEnabled = true
    sendNotify("Anti-AFK activated", "IY Matcha", 3)
    antiAFKThread = task.spawn(function()
        while antiAFKEnabled do
            task.wait(45)
            local root = getRootPart()
            if root then
                local pos = root.Position
                -- Petite rotation imperceptible pour rester actif
                root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(2), 0)
            end
        end
    end)
end

commands["noantiafk"] = function()
    if not antiAFKEnabled then
        sendNotify("Anti-AFK not active")
        return
    end
    antiAFKEnabled = false
    if antiAFKThread then
        task.cancel(antiAFKThread)
        antiAFKThread = nil
    end
    sendNotify("Anti-AFK disabled")
end

-- AUTO-CLICK
commands["autoclick"] = function(args)
    local delay = tonumber(args[1]) or 0.05
    if autoclickEnabled then
        autoclickEnabled = false
        if autoclickThread then task.cancel(autoclickThread) end
        sendNotify("Auto-click disabled")
        return
    end
    autoclickEnabled = true
    sendNotify("Auto-click enabled (" .. delay .. "s)", "IY Matcha", 2)
    autoclickThread = task.spawn(function()
        while autoclickEnabled do
            mouse1click()
            task.wait(delay)
        end
    end)
end

local commandOrder = {
    { name="speed (ws)",  desc="Change walkspeed [val]" },
    { name="jump  (jh)",  desc="Change jump power [val]" },
    { name="fly",         desc="Fly (WASD+Space/Shift)" },
    { name="unfly",       desc="Stop flying" },
    { name="noclip",      desc="Walk through walls" },
    { name="clip",        desc="Re-enable collisions" },
    { name="god",         desc="God mode ON" },
    { name="ungod",       desc="God mode OFF" },
    { name="infjump",     desc="Infinite jump (hold Space)" },
	{ name="noinfjump",   desc="Disable infinite jump" },
    { name="spin",        desc="Spin your character [speed]" },
    { name="unspin",      desc="Stop spinning" },
    { name="fling",       desc="Fling a player" },
    { name="antifling",   desc="Anti-fling protection" },
    { name="noantifling", desc="Disable anti-fling" },
	{ name="tp",          desc="Teleport to player [name or random]" },
    { name="looptp",      desc="Loop teleport to player" },
    { name="stoplooptp",  desc="Stop loop teleport" },
	{ name="addwp",       desc="Add a waypoint [name]" },
    { name="delwp",       desc="Delete waypoint [name]" },
    { name="tpwp",        desc="Teleport to waypoint [name]" },
    { name="wp",          desc="Show/hide the list of waypoints" },
    { name="bring",       desc="Bring a player" },
	{ name="antiafk",     desc="Avoid the inactivity kick" },
    { name="noantiafk",   desc="Disable AFK protection" },
	{ name="autoclick",   desc="Automatic click [delay=0.05]" },
    { name="reset",       desc="Reset character" },
    { name="coords",      desc="Show coordinates" },
    { name="time",        desc="Server time" },
    { name="notify",      desc="Send a notification" },
    { name="game",        desc="Current game name" },
}

-- F6 command
local barBg = Drawing.new("Square")
barBg.Size         = Vector2.new(440, 36)
barBg.Position     = Vector2.new(20, 548)
barBg.Color        = Color3.fromRGB(10, 10, 16)
barBg.Filled       = true
barBg.Transparency = 0.1
barBg.Visible      = false
barBg.ZIndex       = 50

local barAccent = Drawing.new("Square")
barAccent.Size         = Vector2.new(3, 36)
barAccent.Position     = Vector2.new(20, 548)
barAccent.Color        = Color3.fromRGB(80, 160, 255)
barAccent.Filled       = true
barAccent.Transparency = 0
barAccent.Visible      = false
barAccent.ZIndex       = 51

local barText = Drawing.new("Text")
barText.Text     = "> _"
barText.Position = Vector2.new(32, 557)
barText.Color    = Color3.fromRGB(180, 255, 180)
barText.Size     = 14
barText.Outline  = true
barText.Visible  = false
barText.ZIndex   = 52

local helpLabel = Drawing.new("Text")
helpLabel.Text     = "[F6] command   [M] list"
helpLabel.Position = Vector2.new(20, 532)
helpLabel.Color    = Color3.fromRGB(255, 0, 180)
helpLabel.Size     = 13
helpLabel.Outline  = true
helpLabel.Visible  = true
helpLabel.ZIndex   = 9

-- UI Resize

local PX = 940
local PY = 280
local PW = 330
local PH = 400

local HDR_H    = 34
local FOOT_H   = 24
local ROW_H    = 21
local PAD      = 6
local RESIZE_Z = 8   

local panelOpen    = false
local scrollOffset = 0
local allObjs      = {}

-- ── Drawing ──

local function mkSq(x,y,w,h, r,g,b, tr, zi)
    local s = Drawing.new("Square")
    s.Position     = Vector2.new(x, y)
    s.Size         = Vector2.new(w, h)
    s.Color        = Color3.fromRGB(r,g,b)
    s.Filled       = true
    s.Transparency = tr or 0
    s.ZIndex       = zi or 30
    s.Visible      = false
    table.insert(allObjs, s)
    return s
end

local function mkTxt(txt,x,y, r,g,b, sz, zi)
    local t = Drawing.new("Text")
    t.Text     = txt
    t.Position = Vector2.new(x, y)
    t.Color    = Color3.fromRGB(r,g,b)
    t.Size     = sz or 13
    t.Outline  = true
    t.ZIndex   = zi or 31
    t.Visible  = false
    table.insert(allObjs, t)
    return t
end

-- Panel

-- Main background
local pBg       = mkSq(0,0,0,0,  12,13,22,  0.08, 30)
-- Border (4 thin strips)
local pBrdT     = mkSq(0,0,0,0,  60,130,255, 0,   32)
local pBrdB     = mkSq(0,0,0,0,  60,130,255, 0,   32)
local pBrdL     = mkSq(0,0,0,0,  60,130,255, 0,   32)
local pBrdR     = mkSq(0,0,0,0,  60,130,255, 0,   32)
-- Header
local pHdrBg    = mkSq(0,0,0,0,  18,70,170,  0,   31)
local pHdrGlow  = mkSq(0,0,0,0,  70,160,255, 0,   32)  -- liseré haut
-- Title header
local pTitlePfx = mkTxt(">>", 0,0, 90,190,255, 13, 33)
local pTitleLbl = mkTxt("IY Matcha", 0,0, 240,240,255, 14, 33)
-- Badge version
local pVerBg    = mkSq(0,0,48,18, 40,90,200, 0, 33)
local pVerTxt   = mkTxt("v1.0", 0,0, 170,215,255, 11, 34)
-- Header/list separator
local pHdrSep   = mkSq(0,0,0,0,  50,120,230, 0, 32)
-- List area
local pListBg   = mkSq(0,0,0,0,  8,8,14,  0.05, 30)
-- Scrollbar track
local pSbTrack  = mkSq(0,0,5,0,  22,22,35, 0, 31)
-- Scrollbar thumb
local pSbThumb  = mkSq(0,0,5,30, 65,135,255, 0, 33)
-- Footer
local pFtrBg    = mkSq(0,0,0,0,  14,14,24, 0, 31)
local pFtrSep   = mkSq(0,0,0,0,  40,90,180, 0, 32)
local pFtrTxt   = mkTxt("[^][v] scroll  [M] close  [F6] cmd", 0,0, 85,105,155, 11, 32)
local pFtrCount = mkTxt("0/0", 0,0, 65,135,255, 11, 33)
-- Coin resize (visual indicator triangle via Square)
local pResizeDot= mkSq(0,0,8,8,  80,150,255, 0, 34)


local rowPool = {}

local function buildRowPool()
    -- Delete old
    for _, row in ipairs(rowPool) do
        row.bg:Remove();  row.acc:Remove()
        row.name:Remove(); row.desc:Remove()
    end
    rowPool = {}

    local VISIBLE = math.floor((PH - HDR_H - FOOT_H - PAD*2) / ROW_H)
    for i = 1, VISIBLE do
        local ry = PY + HDR_H + PAD + (i-1)*ROW_H
        local rbg  = Drawing.new("Square")
        rbg.Position     = Vector2.new(PX+1, ry)
        rbg.Size         = Vector2.new(PW-8, ROW_H-1)
        rbg.Color        = i%2==0 and Color3.fromRGB(22,22,34) or Color3.fromRGB(16,16,26)
        rbg.Filled       = true
        rbg.Transparency = 0
        rbg.ZIndex       = 30
        rbg.Visible      = false
        table.insert(allObjs, rbg)

        local racc = Drawing.new("Square")
        racc.Position     = Vector2.new(PX+1, ry)
        racc.Size         = Vector2.new(2, ROW_H-1)
        racc.Color        = Color3.fromRGB(65,135,255)
        racc.Filled       = true
        racc.Transparency = 0
        racc.ZIndex       = 31
        racc.Visible      = false
        table.insert(allObjs, racc)

        local rname = Drawing.new("Text")
        rname.Text     = ""
        rname.Position = Vector2.new(PX+10, ry+4)
        rname.Color    = Color3.fromRGB(255,255,255)
        rname.Size     = 12
        rname.Outline  = true
        rname.ZIndex   = 32
        rname.Visible  = false
        table.insert(allObjs, rname)

        local rdesc = Drawing.new("Text")
        rdesc.Text     = ""
        rdesc.Position = Vector2.new(PX+82, ry+4)
        rdesc.Color    = Color3.fromRGB(130,155,190)
        rdesc.Size     = 12
        rdesc.Outline  = true
        rdesc.ZIndex   = 32
        rdesc.Visible  = false
        table.insert(allObjs, rdesc)

        table.insert(rowPool, { bg=rbg, acc=racc, name=rname, desc=rdesc })
    end
end

-- Reposition all elements

local function layoutPanel()
    local VISIBLE = #rowPool

    -- Background + borders
    pBg.Position      = Vector2.new(PX, PY)
    pBg.Size          = Vector2.new(PW, PH)

    pBrdT.Position    = Vector2.new(PX, PY)
    pBrdT.Size        = Vector2.new(PW, 1)
    pBrdB.Position    = Vector2.new(PX, PY+PH)
    pBrdB.Size        = Vector2.new(PW, 1)
    pBrdL.Position    = Vector2.new(PX, PY)
    pBrdL.Size        = Vector2.new(1, PH)
    pBrdR.Position    = Vector2.new(PX+PW-1, PY)
    pBrdR.Size        = Vector2.new(1, PH)

    -- Header
    pHdrBg.Position   = Vector2.new(PX, PY)
    pHdrBg.Size       = Vector2.new(PW, HDR_H)
    pHdrGlow.Position = Vector2.new(PX, PY)
    pHdrGlow.Size     = Vector2.new(PW, 2)
    pHdrSep.Position  = Vector2.new(PX, PY+HDR_H)
    pHdrSep.Size      = Vector2.new(PW, 1)

    pTitlePfx.Position= Vector2.new(PX+10, PY+10)
    pTitleLbl.Position= Vector2.new(PX+30, PY+10)
    pVerBg.Position   = Vector2.new(PX+PW-54, PY+9)
    pVerTxt.Position  = Vector2.new(PX+PW-49, PY+12)

    -- List
    pListBg.Position  = Vector2.new(PX, PY+HDR_H+1)
    pListBg.Size      = Vector2.new(PW, PH-HDR_H-FOOT_H-1)

    -- Scrollbar
    local trackH = PH - HDR_H - FOOT_H - 4
    pSbTrack.Position = Vector2.new(PX+PW-6, PY+HDR_H+2)
    pSbTrack.Size     = Vector2.new(5, trackH)
    pSbThumb.Position = Vector2.new(PX+PW-6, PY+HDR_H+2)

    -- Footer
    pFtrBg.Position   = Vector2.new(PX, PY+PH-FOOT_H)
    pFtrBg.Size       = Vector2.new(PW, FOOT_H)
    pFtrSep.Position  = Vector2.new(PX, PY+PH-FOOT_H)
    pFtrSep.Size      = Vector2.new(PW, 1)
    pFtrTxt.Position  = Vector2.new(PX+8, PY+PH-FOOT_H+7)
    pFtrCount.Position= Vector2.new(PX+PW-38, PY+PH-FOOT_H+7)

    -- Corner resize
    pResizeDot.Position = Vector2.new(PX+PW-10, PY+PH-10)

    -- Rows
    for i, row in ipairs(rowPool) do
        local ry = PY + HDR_H + PAD + (i-1)*ROW_H
        row.bg.Position   = Vector2.new(PX+1, ry)
        row.bg.Size       = Vector2.new(PW-8, ROW_H-1)
        row.acc.Position  = Vector2.new(PX+1, ry)
        row.acc.Size      = Vector2.new(2, ROW_H-1)
        row.name.Position = Vector2.new(PX+10, ry+4)
        row.desc.Position = Vector2.new(PX+82, ry+4)
    end
end

-- Refresh content list

local function refreshList()
    local total   = #commandOrder
    local VISIBLE = #rowPool
    local trackH  = PH - HDR_H - FOOT_H - 4

    for i, row in ipairs(rowPool) do
        local idx = i + scrollOffset
        if idx <= total then
            local c = commandOrder[idx]
            row.name.Text    = c.name
            row.desc.Text    = c.desc
            row.name.Visible = true
            row.desc.Visible = true
            row.bg.Visible   = true
            row.acc.Visible  = true
        else
            row.name.Text    = ""
            row.desc.Text    = ""
            row.name.Visible = false
            row.desc.Visible = false
            row.bg.Visible   = false
            row.acc.Visible  = false
        end
    end

    -- Scrollbar thumb
    if total <= VISIBLE then
        pSbThumb.Visible = false
    else
        local maxOff  = total - VISIBLE
        local thumbH  = math.max(18, trackH * VISIBLE / total)
        local thumbY  = PY+HDR_H+2 + (trackH - thumbH) * (scrollOffset / maxOff)
        pSbThumb.Size     = Vector2.new(5, thumbH)
        pSbThumb.Position = Vector2.new(PX+PW-6, thumbY)
        pSbThumb.Visible  = true
    end

    -- Counter
    local from = scrollOffset + 1
    local to   = math.min(scrollOffset + VISIBLE, total)
    pFtrCount.Text = from.."-"..to.."/"..total
end

-- Panel Visibility
local function setPanelVisible(v)
    for _, o in ipairs(allObjs) do o.Visible = v end
    if v then
        pSbThumb.Visible = (#commandOrder > #rowPool)
    end
end

local function openPanel()
    panelOpen = true
    setPanelVisible(true)
    layoutPanel()
    refreshList()
end

local function closePanel()
    panelOpen = false
    setPanelVisible(false)
end

-- Initialisation 
buildRowPool()
layoutPanel()

-- Input
local inputBuffer = ""
local isTyping    = false

-- Drag state
local dragging    = false
local dragOffX    = 0
local dragOffY    = 0

-- Resize state
local resizing    = false
local resizeOrigX = 0
local resizeOrigY = 0
local resizeOrigW = 0
local resizeOrigH = 0

local KC_F6     = 0x75
local KC_M      = 0x4D
local KC_ENTER  = 0x0D
local KC_BACK   = 0x08
local KC_ESC    = 0x1B
local KC_UP     = 0x26
local KC_DOWN   = 0x28
local KC_PGUP   = 0x21  -- Page Up
local KC_PGDN   = 0x22  -- Page Down

-- Letters (A-Z) + space
local charMap = {
    [0x41]="a",[0x42]="b",[0x43]="c",[0x44]="d",[0x45]="e",
    [0x46]="f",[0x47]="g",[0x48]="h",[0x49]="i",[0x4A]="j",
    [0x4B]="k",[0x4C]="l",[0x4D]="m",[0x4E]="n",[0x4F]="o",
    [0x50]="p",[0x51]="q",[0x52]="r",[0x53]="s",[0x54]="t",
    [0x55]="u",[0x56]="v",[0x57]="w",[0x58]="x",[0x59]="y",
    [0x5A]="z",[0x20]=" "
}
-- Top row numbers 
local numMap = {
    [0x30]="0",[0x31]="1",[0x32]="2",[0x33]="3",[0x34]="4",
    [0x35]="5",[0x36]="6",[0x37]="7",[0x38]="8",[0x39]="9"
}

local prevKeys   = {}
local prevMouse1 = false

local function justPressed(kc)
    local now = iskeypressed(kc)
    local was = prevKeys[kc] or false
    prevKeys[kc] = now
    return now and not was
end

local function inRect(mx,my, x,y,w,h)
    return mx>=x and mx<=x+w and my>=y and my<=y+h
end

local function executeCommand(input)
    input = input:lower():match("^%s*(.-)%s*$")
    if input == "" then return end
    local parts = {}
    for w in input:gmatch("%S+") do table.insert(parts,w) end
    local cmd  = parts[1]
    local args = {}
    for i=2,#parts do table.insert(args,parts[i]) end
    if commands[cmd] then
        local ok,err = pcall(commands[cmd], args)
        if not ok then sendNotify("Erreur: "..tostring(err),"IY Error",4) end
    else
        sendNotify("Unknown: "..cmd,"IY Matcha",3)
    end
end

sendNotify("IY Matcha  [F6] cmd  [M] list", "IY Matcha", 4)

local scrollCD = 0
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

local pulse = 0
local function updateMarkers()
    pulse = pulse + 0.06
    local radius = 8 + math.sin(pulse) * 4

    for _, obj in ipairs(wpMarkers) do
        pcall(function() obj:Remove() end)
    end
    wpMarkers = {}

    for name, data in pairs(waypoints) do
        local pos = data.Position
        local screenPos, onScreen = WorldToScreen(pos)
        if onScreen then
            local x, y = screenPos.X, screenPos.Y

            local ring = Drawing.new("Circle")
            ring.Position = Vector2.new(x, y)
            ring.Radius = radius
            ring.Color = Color3.fromRGB(0, 180, 240)
            ring.Thickness = 2
            ring.Filled = false
            ring.Transparency = 0.2
            ring.Visible = true
            ring.ZIndex = 100
            table.insert(wpMarkers, ring)

            local dot = Drawing.new("Circle")
            dot.Position = Vector2.new(x, y)
            dot.Radius = 3
            dot.Color = Color3.fromRGB(255, 80, 80)
            dot.Filled = true
            dot.Visible = true
            dot.ZIndex = 101
            table.insert(wpMarkers, dot)

            local textWidth = #name * 6
            local bgWidth = math.max(textWidth + 12, 40)  
            local bgX = x - bgWidth / 2
            local textX = x - textWidth / 2

            local bg = Drawing.new("Square")
            bg.Position = Vector2.new(bgX, y - 20)
            bg.Size = Vector2.new(bgWidth, 16)
            bg.Color = Color3.fromRGB(0, 0, 0)
            bg.Filled = true
            bg.Transparency = 0.5
            bg.Visible = true
            bg.ZIndex = 99
            table.insert(wpMarkers, bg)

            local txt = Drawing.new("Text")
            txt.Text = name
            txt.Position = Vector2.new(textX, y - 18)
            txt.Color = Color3.fromRGB(255, 255, 200)
            txt.Size = 12
            txt.Outline = true
            txt.Visible = true
            txt.ZIndex = 102
            table.insert(wpMarkers, txt)
        end
    end
end

-- update loop
task.spawn(function()
    while true do
        updateMarkers()
        task.wait(0.05)
    end
end)

-- scroll up down 
task.spawn(function()
    while true do
        task.wait(0.04)
        scrollCD = math.max(0, scrollCD - 0.04)

        local mx = mouse.X
        local my = mouse.Y
        local m1 = ismouse1pressed()
        local m1down  = m1 and not prevMouse1
        local m1up    = not m1 and prevMouse1
        prevMouse1 = m1

        -- ── Drag (header) ──
        if panelOpen then
            if m1down and not resizing then
                if inRect(mx,my, PX, PY, PW, HDR_H) then
                    dragging = true
                    dragOffX = mx - PX
                    dragOffY = my - PY
                end
                -- Resize (bottom right corner 14x14)
                if inRect(mx,my, PX+PW-14, PY+PH-14, 14, 14) then
                    resizing    = true
                    dragging    = false
                    resizeOrigX = mx
                    resizeOrigY = my
                    resizeOrigW = PW
                    resizeOrigH = PH
                end
            end

            if m1up then
                if dragging or resizing then
                    dragging = false
                    resizing = false
                    -- Rebuild rows si resize
                    buildRowPool()
                    layoutPanel()
                    refreshList()
                end
            end

            if dragging and m1 then
                PX = mx - dragOffX
                PY = my - dragOffY
                layoutPanel()
            end

            if resizing and m1 then
                local newW = math.max(260, resizeOrigW + (mx - resizeOrigX))
                local newH = math.max(200, resizeOrigH + (my - resizeOrigY))
                PW = newW
                PH = newH
                layoutPanel()
            end
        end

        -- Block zoom/input in-game if mouse is over the panel
        if panelOpen then
            if inRect(mx, my, PX, PY, PW, PH) then
                setrobloxinput(false)
            else
                setrobloxinput(true)
            end
        end

        -- [M] toggle 
        if not isTyping and justPressed(KC_M) then
            if panelOpen then
                closePanel()
                setrobloxinput(true)
            else
                openPanel()
            end
        end

        -- Scroll arrows + PageUp/PageDown
        if panelOpen and scrollCD <= 0 then
            local maxOff = math.max(0, #commandOrder - #rowPool)
            if iskeypressed(KC_UP) or iskeypressed(KC_PGUP) then
                scrollOffset = math.max(0, scrollOffset - 1)
                refreshList(); scrollCD = 0.09
            elseif iskeypressed(KC_DOWN) or iskeypressed(KC_PGDN) then
                scrollOffset = math.min(maxOff, scrollOffset + 1)
                refreshList(); scrollCD = 0.09
            end
        end

        -- F6 command bar
        if not isTyping and justPressed(KC_F6) then
            isTyping    = true
            inputBuffer = ""
            barBg.Visible     = true
            barAccent.Visible = true
            barText.Visible   = true
            helpLabel.Visible = false
            barText.Text      = "> _"
            setrobloxinput(false)
        end

        if isTyping then
            if justPressed(KC_ESC) then
                isTyping = false; inputBuffer = ""
                barBg.Visible=false; barAccent.Visible=false
                barText.Visible=false; helpLabel.Visible=true
                setrobloxinput(true)

            elseif justPressed(KC_ENTER) then
                isTyping = false
                barBg.Visible=false; barAccent.Visible=false
                barText.Visible=false; helpLabel.Visible=true
                setrobloxinput(true)
                local cmd = inputBuffer; inputBuffer=""
                executeCommand(cmd)

            elseif justPressed(KC_BACK) then
                if #inputBuffer>0 then inputBuffer=inputBuffer:sub(1,-2) end
                barText.Text = "> "..inputBuffer.."_"

            else
                local typed = nil
                for kc,char in pairs(charMap) do
                    if justPressed(kc) then typed = char; break end
                end
                if typed == nil then
                    for kc,char in pairs(numMap) do
                        if justPressed(kc) then typed = char; break end
                    end
                end
                if typed then
                    inputBuffer = inputBuffer..typed
                    barText.Text = "> "..inputBuffer.."_"
                end
            end
        end

        -- Update prevKeys
        prevKeys[KC_F6]=iskeypressed(KC_F6); prevKeys[KC_M]=iskeypressed(KC_M)
        prevKeys[KC_ENTER]=iskeypressed(KC_ENTER); prevKeys[KC_BACK]=iskeypressed(KC_BACK)
        prevKeys[KC_ESC]=iskeypressed(KC_ESC); prevKeys[KC_UP]=iskeypressed(KC_UP)
        prevKeys[KC_DOWN]=iskeypressed(KC_DOWN); prevKeys[KC_PGUP]=iskeypressed(KC_PGUP)
        prevKeys[KC_PGDN]=iskeypressed(KC_PGDN)
        for kc in pairs(charMap) do prevKeys[kc]=iskeypressed(kc) end
        for kc in pairs(numMap) do prevKeys[kc]=iskeypressed(kc) end
    end
end)
