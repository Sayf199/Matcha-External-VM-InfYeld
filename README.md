--   Infinity Yield Matcha Edition
--            ( ;cmds system )

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ================================================
-- Utilitaires
-- ================================================

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

-- ================================================
-- États
-- ================================================

local flyEnabled = false
local noclipEnabled = false
local flyThread = nil
local noclipThread = nil

-- ================================================
-- Commandes
-- ================================================

local commands = {}

-- SPEED
commands["speed"] = function(args)
    local val = tonumber(args[1])
    if not val then sendNotify("Usage: ;speed [valeur]") return end
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = val
        sendNotify("Speed → " .. val)
    end
end

-- JUMP
commands["jump"] = function(args)
    local val = tonumber(args[1])
    if not val then sendNotify("Usage: ;jump [valeur]") return end
    local hum = getHumanoid()
    if hum then
        hum.JumpPower = val
        sendNotify("JumpPower → " .. val)
    end
end

local heart = game:GetService("RunService").Heartbeat
local godConnection = nil

commands["god"] = function()
    if godConnection then return end
    godConnection = heart:Connect(function()
        local char = getChar()
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            -- tentative d'écriture de Health via pcall pour éviter erreur
            pcall(function() hum.Health = 9e9 end)
        end
    end)
    sendNotify("Mode Dieu activé (tentative via RunService)")
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
                -- Supprimé : hum.PlatformStand = true

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

        -- Supprimé : hum.PlatformStand = false
    end)
end

-- UNFLY
commands["unfly"] = function()
    flyEnabled = false
    -- Plus besoin de remettre PlatformStand à false
    sendNotify("Fly désactivé")
end

-- NOCLIP
commands["noclip"] = function()
    if noclipEnabled then sendNotify("Noclip déjà actif !") return end
    noclipEnabled = true
    sendNotify("Noclip activé ✓")

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
    sendNotify("Noclip désactivé")
end

-- TP (téléport vers un joueur)
commands["tp"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;tp [joueur]") return end
    local target = findPlayer(name)
    if not target then sendNotify("Joueur introuvable : " .. name) return end
    local targetChar = target.Character
    local root = getRootPart()
    if targetChar and root then
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            root.Position = targetRoot.Position + Vector3.new(0, 3, 0)
            sendNotify("Téléporté vers " .. target.Name)
        end
    end
end

-- BRING (amener un joueur)
commands["bring"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;bring [joueur]") return end
    local target = findPlayer(name)
    if not target then sendNotify("Joueur introuvable : " .. name) return end
    local targetChar = target.Character
    local root = getRootPart()
    if targetChar and root then
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            targetRoot.Position = root.Position + Vector3.new(3, 0, 0)
            sendNotify("Brought " .. target.Name)
        end
    end
end

-- KILL (tuer un joueur)
commands["kill"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;kill [joueur]") return end
    local target = findPlayer(name)
    if not target then sendNotify("Joueur introuvable : " .. name) return end
    local targetChar = target.Character
    if targetChar then
        local success, err = pcall(function()
            targetChar:BreakJoints()
        end)
        if success then
            sendNotify("Kill envoyé sur " .. target.Name)
        else
            sendNotify("Échec du kill : " .. tostring(err))
            -- Fallback : tentative de téléportation sous la map
            local root = targetChar:FindFirstChild("HumanoidRootPart")
            if root then
                root.Position = Vector3.new(root.Position.X, -10000, root.Position.Z)
                sendNotify("Tentative de téléportation sous la carte (peu fiable)")
            end
        end
    else
        sendNotify("Personnage de la cible introuvable")
    end
end

commands["jail"] = function(args)
    local name = args[1]
    if not name then sendNotify("Usage: ;jail [joueur]") return end
    local target = findPlayer(name)
    if not target then sendNotify("Joueur introuvable") return end
    local targetChar = target.Character
    local root = getRootPart()
    if targetChar and root then
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            -- Téléporte le joueur juste devant toi, dans le sol à moitié
            targetRoot.Position = root.Position + root.CFrame.LookVector * 5
            task.wait(0.1)
            -- Enfonce le joueur dans le sol (y -5)
            targetRoot.Position = targetRoot.Position + Vector3.new(0, -5, 0)
            sendNotify(target.Name .. " est bloqué dans le sol (alternative à kill)")
        end
    end
end

-- NOTIFY
commands["notify"] = function(args)
    local msg = table.concat(args, " ")
    if msg == "" then sendNotify("Usage: ;notify [message]") return end
    sendNotify(msg, "Notification", 5)
end

-- RESET
commands["reset"] = function()
    local hum = getHumanoid()
    if hum then
        hum.Health = 0
        sendNotify("Reset effectué")
    end
end

-- EXECUTOR
commands["exec"] = function()
    local name, version = identifyexecutor()
    sendNotify(name .. " " .. (version or ""), "Executor", 4)
end


-- Game
commands["game"] = function()
    local success, name = pcall(function()
        -- Méthode 1 : essayer d'obtenir le nom via MarketplaceService (nécessite un appel HTTP)
        local marketplace = game:GetService("MarketplaceService")
        local info = marketplace:GetProductInfo(game.PlaceId)
        return info.Name
    end)
    
    if success and name then
        sendNotify(name, "Jeu actuel", 4)
    else
        -- Fallback : utiliser l'ID du jeu ou le nom de l'endroit
        local placeName = game.Name or "Inconnu"
        local placeId = game.PlaceId or "?"
        sendNotify(placeName .. " (ID: " .. placeId .. ")", "Jeu actuel", 4)
    end
end

-- CMDS (liste des commandes)
commands["cmds"] = function()
    local list = {}
    for k in pairs(commands) do
        table.insert(list, ";" .. k)
    end
    table.sort(list)

    -- Affiche via Drawing pendant 8 secondes
    local lines = {}
    local startY = 60
    local x = 20

    -- Titre
    local title = Drawing.new("Text")
    title.Text = "== IY Matcha - Commandes =="
    title.Position = Vector2.new(x, startY - 22)
    title.Color = Color3.fromRGB(100, 220, 255)
    title.Size = 16
    title.Outline = true
    title.Visible = true
    table.insert(lines, title)

    for i, cmd in ipairs(list) do
        local t = Drawing.new("Text")
        t.Text = cmd
        t.Position = Vector2.new(x + ((i - 1) % 3) * 130, startY + math.floor((i - 1) / 3) * 18)
        t.Color = Color3.fromRGB(255, 255, 255)
        t.Size = 14
        t.Outline = true
        t.Visible = true
        table.insert(lines, t)
    end

    task.spawn(function()
        task.wait(8)
        for _, obj in ipairs(lines) do
            obj:Remove()
        end
    end)
end

-- ================================================
-- UI : Chatbox visuelle (Drawing)
-- ================================================

-- Barre de commande affichée en bas de l'écran
local barBg = Drawing.new("Square")
barBg.Size = Vector2.new(400, 30)
barBg.Position = Vector2.new(20, 550)
barBg.Color = Color3.fromRGB(15, 15, 15)
barBg.Filled = true
barBg.Transparency = 0.35
barBg.Visible = false
barBg.ZIndex = 10

local barText = Drawing.new("Text")
barText.Text = ";"
barText.Position = Vector2.new(28, 556)
barText.Color = Color3.fromRGB(180, 255, 180)
barText.Size = 15
barText.Outline = true
barText.Visible = false
barText.ZIndex = 11

local helpLabel = Drawing.new("Text")
helpLabel.Text = "Appuie sur F6 pour ouvrir | ;cmds pour la liste"
helpLabel.Position = Vector2.new(20, 530)
helpLabel.Color = Color3.fromRGB(150, 150, 150)
helpLabel.Size = 13
helpLabel.Outline = true
helpLabel.Visible = true
helpLabel.ZIndex = 9

-- ================================================
-- Lecture clavier / Input loop
-- ================================================

local inputBuffer = ""
local isTyping = false

-- Keycodes utiles
local KC_SEMICOLON = 0x75  -- F6 (préfixe pour ouvrir la barre)
local KC_ENTER     = 0x0D
local KC_BACK      = 0x08  -- Backspace
local KC_ESCAPE    = 0x1B

-- Alphabet + chiffres + espace
local charMap = {
    [0x41]="a",[0x42]="b",[0x43]="c",[0x44]="d",[0x45]="e",
    [0x46]="f",[0x47]="g",[0x48]="h",[0x49]="i",[0x4A]="j",
    [0x4B]="k",[0x4C]="l",[0x4D]="m",[0x4E]="n",[0x4F]="o",
    [0x50]="p",[0x51]="q",[0x52]="r",[0x53]="s",[0x54]="t",
    [0x55]="u",[0x56]="v",[0x57]="w",[0x58]="x",[0x59]="y",
    [0x5A]="z",[0x30]="0",[0x31]="1",[0x32]="2",[0x33]="3",
    [0x34]="4",[0x35]="5",[0x36]="6",[0x37]="7",[0x38]="8",
    [0x39]="9",[0x20]=" "
}

local prevKeys = {}

local function wasJustPressed(kc)
    local now = iskeypressed(kc)
    local was = prevKeys[kc] or false
    prevKeys[kc] = now
    return now and not was
end

-- ================================================
-- Exécution d'une commande
-- ================================================

local function executeCommand(input)
    input = input:lower():match("^%s*(.-)%s*$")
    if input == "" then return end

    local parts = {}
    for word in input:gmatch("%S+") do
        table.insert(parts, word)
    end

    local cmd = parts[1]
    local args = {}
    for i = 2, #parts do table.insert(args, parts[i]) end

    if commands[cmd] then
        local ok, err = pcall(commands[cmd], args)
        if not ok then
            sendNotify("Erreur: " .. tostring(err), "IY Error", 4)
        end
    else
        sendNotify("Commande inconnue: ;" .. cmd, "IY Matcha", 3)
    end
end

-- ================================================
-- Boucle principale
-- ================================================

sendNotify("IY Matcha chargé ! Appuie sur F6 pour ouvrir", "IY Matcha", 5)

task.spawn(function()
    while true do
        task.wait(0.05)

        -- Ouvrir avec ;
        if not isTyping and wasJustPressed(KC_SEMICOLON) then
            isTyping = true
            inputBuffer = ""
            barBg.Visible = true
            barText.Visible = true
            helpLabel.Visible = false
            barText.Text = ";"
            setrobloxinput(false)
        end

        if isTyping then
            -- Escape = fermer
            if wasJustPressed(KC_ESCAPE) then
                isTyping = false
                inputBuffer = ""
                barBg.Visible = false
                barText.Visible = false
                helpLabel.Visible = true
                setrobloxinput(true)

            -- Entrée = exécuter
            elseif wasJustPressed(KC_ENTER) then
                isTyping = false
                barBg.Visible = false
                barText.Visible = false
                helpLabel.Visible = true
                setrobloxinput(true)
                local cmd = inputBuffer
                inputBuffer = ""
                executeCommand(cmd)

            -- Backspace
            elseif wasJustPressed(KC_BACK) then
                if #inputBuffer > 0 then
                    inputBuffer = inputBuffer:sub(1, -2)
                end
                barText.Text = ";" .. inputBuffer

            -- Frappe de caractère
            else
                for kc, char in pairs(charMap) do
                    if wasJustPressed(kc) then
                        inputBuffer = inputBuffer .. char
                        barText.Text = ";" .. inputBuffer
                        break
                    end
                end
            end
        end

        -- Mettre à jour les prevKeys pour les touches non tracées
        for kc in pairs(charMap) do
            prevKeys[kc] = iskeypressed(kc)
        end
        prevKeys[KC_SEMICOLON] = iskeypressed(KC_SEMICOLON)
        prevKeys[KC_ENTER] = iskeypressed(KC_ENTER)
        prevKeys[KC_BACK] = iskeypressed(KC_BACK)
        prevKeys[KC_ESCAPE] = iskeypressed(KC_ESCAPE)
    end
end)
