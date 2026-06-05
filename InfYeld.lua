local Players = game:GetService(string.char(80, 108, 97, 121, 101, 114, 115))
local lp = Players.LocalPlayer
local function getChar()
return lp.Character
end
local function getHumanoid()
local char = getChar()
if char then return char:FindFirstChildOfClass(string.char(72, 117, 109, 97, 110, 111, 105, 100)) end
end
local function getRootPart()
local char = getChar()
if char then return char:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116)) end
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
notify(msg, title or string.char(73, 89, 32, 77, 97, 116, 99, 104, 97), duration or 3)
end
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
local commands = {}
local HUM_WALKSPEED = 468
local HUM_JUMPPOWER = 432
local HUM_HEALTH    = 404
local HUM_MAXHEALTH = 436
local function humWrite(offset, val)
local hum = getHumanoid()
if not hum then sendNotify(string.char(72, 117, 109, 97, 110, 111, 105, 100, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100)) return false end
local addr = tonumber(hum.Address)
if not addr or addr <= 4096 then sendNotify(string.char(73, 110, 118, 97, 108, 105, 100, 32, 97, 100, 100, 114, 101, 115, 115)) return false end
local ok, err = pcall(memory_write, string.char(102, 108, 111, 97, 116), addr + offset, val)
if not ok then sendNotify(string.char(109, 101, 109, 111, 114, 121, 95, 119, 114, 105, 116, 101, 32, 101, 114, 114, 111, 114, 58, 32) .. tostring(err), string.char(73, 89, 32, 69, 114, 114, 111, 114), 3) return false end
return true
end
local speedValue = 16
local speedConn  = nil
commands[string.char(115, 112, 101, 101, 100)] = function(args)
local val = tonumber(args[1])
if not val then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 115, 112, 101, 101, 100, 32, 91, 118, 97, 108, 93)) return end
speedValue = val
if speedConn then speedConn:Disconnect(); speedConn = nil end
local RS = game:GetService(string.char(82, 117, 110, 83, 101, 114, 118, 105, 99, 101))
speedConn = RS.Heartbeat:Connect(function()
local hum = getHumanoid()
if hum then
pcall(function() hum.WalkSpeed = speedValue end)
humWrite(HUM_WALKSPEED, speedValue)
end
end)
sendNotify(string.char(83, 112, 101, 101, 100, 32, 45, 62, 32) .. val)
end
commands[string.char(106, 117, 109, 112)] = function(args)
local val = tonumber(args[1])
if not val then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 106, 117, 109, 112, 32, 91, 118, 97, 108, 101, 117, 114, 93)) return end
if humWrite(HUM_JUMPPOWER, val) then sendNotify(string.char(74, 117, 109, 112, 32, 45, 62, 32) .. val) end
end
local heart = game:GetService(string.char(82, 117, 110, 83, 101, 114, 118, 105, 99, 101)).Heartbeat
local godConnection = nil
commands[string.char(103, 111, 100)] = function()
if godConnection then sendNotify(string.char(71, 111, 100, 32, 97, 108, 114, 101, 97, 100, 121, 32, 97, 99, 116, 105, 118, 101, 33)) return end
godConnection = heart:Connect(function()
local hum = getHumanoid()
if hum then
local addr = tonumber(hum.Address)
if addr and addr > 4096 then
pcall(memory_write, string.char(102, 108, 111, 97, 116), addr + HUM_MAXHEALTH, 99999)
pcall(memory_write, string.char(102, 108, 111, 97, 116), addr + HUM_HEALTH,    99999)
end
end
end)
sendNotify(string.char(71, 111, 100, 32, 79, 78))
end
commands[string.char(117, 110, 103, 111, 100)] = function()
if godConnection then
godConnection:Disconnect()
godConnection = nil
sendNotify(string.char(77, 111, 100, 101, 32, 68, 105, 101, 117, 32, 100, 233, 115, 97, 99, 116, 105, 118, 233))
end
end
commands[string.char(102, 108, 121)] = function()
if flyEnabled then sendNotify(string.char(70, 108, 121, 32, 100, 233, 106, 224, 32, 97, 99, 116, 105, 102, 32, 33)) return end
flyEnabled = true
sendNotify(string.char(70, 108, 121, 32, 97, 99, 116, 105, 118, 233, 32, 10003))
flyThread = task.spawn(function()
local SPEED = 50
while flyEnabled do
local root = getRootPart()
local hum = getHumanoid()
if root and hum then
local vel = Vector3.new(0, 0, 0)
if iskeypressed(0x57) then
vel = vel + root.CFrame.LookVector * SPEED
end
if iskeypressed(0x53) then
vel = vel - root.CFrame.LookVector * SPEED
end
if iskeypressed(0x41) then
vel = vel - root.CFrame.RightVector * SPEED
end
if iskeypressed(0x44) then
vel = vel + root.CFrame.RightVector * SPEED
end
if iskeypressed(0x20) then
vel = vel + Vector3.new(0, SPEED, 0)
end
if iskeypressed(0x10) then
vel = vel - Vector3.new(0, SPEED, 0)
end
root.AssemblyLinearVelocity = vel
end
task.wait(0.03)
end
end)
end
commands[string.char(117, 110, 102, 108, 121)] = function()
flyEnabled = false
sendNotify(string.char(70, 108, 121, 32, 100, 233, 115, 97, 99, 116, 105, 118, 233))
end
commands[string.char(110, 111, 99, 108, 105, 112)] = function()
if noclipEnabled then sendNotify(string.char(78, 111, 99, 108, 105, 112, 32, 105, 115, 32, 97, 108, 114, 101, 97, 100, 121, 32, 97, 99, 116, 105, 118, 101, 33)) return end
noclipEnabled = true
sendNotify(string.char(78, 111, 99, 108, 105, 112, 32, 97, 99, 116, 105, 118, 97, 116, 101, 100, 32))
noclipThread = task.spawn(function()
while noclipEnabled do
local char = getChar()
if char then
for _, part in ipairs(char:GetDescendants()) do
if part:IsA(string.char(66, 97, 115, 101, 80, 97, 114, 116)) then
part.CanCollide = false
end
end
end
task.wait(0.1)
end
end)
end
commands[string.char(99, 108, 105, 112)] = function()
noclipEnabled = false
local char = getChar()
if char then
for _, part in ipairs(char:GetDescendants()) do
if part:IsA(string.char(66, 97, 115, 101, 80, 97, 114, 116)) then
part.CanCollide = true
end
end
end
sendNotify(string.char(78, 111, 99, 108, 105, 112, 32, 100, 105, 115, 97, 98, 108, 101, 100))
end
commands[string.char(116, 112)] = function(args)
local name = args[1]
if not name then
sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 59, 116, 112, 32, 91, 112, 108, 97, 121, 101, 114, 93, 32, 111, 114, 32, 59, 116, 112, 32, 114, 97, 110, 100, 111, 109))
return
end
local target = nil
if name:lower() == string.char(114, 97, 110, 100, 111, 109) then
local players = Players:GetPlayers()
if #players == 0 then
sendNotify(string.char(78, 111, 32, 112, 108, 97, 121, 101, 114, 115, 32, 102, 111, 117, 110, 100))
return
end
local others = {}
for _, p in ipairs(players) do
if p ~= lp then table.insert(others, p) end
end
if #others == 0 then others = players end
target = others[math.random(1, #others)]
sendNotify(string.char(82, 97, 110, 100, 111, 109, 32, 116, 97, 114, 103, 101, 116, 58, 32) .. target.Name)
else
target = findPlayer(name)
if not target then
sendNotify(string.char(80, 108, 97, 121, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100, 58, 32) .. name)
return
end
end
local targetChar = target.Character
local root = getRootPart()
if targetChar and root then
local targetRoot = targetChar:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116))
if targetRoot then
root.CFrame = CFrame.new(targetRoot.Position.X, targetRoot.Position.Y + 3, targetRoot.Position.Z)
sendNotify(string.char(84, 233, 108, 233, 112, 111, 114, 116, 233, 32, 118, 101, 114, 115, 32) .. target.Name)
else
sendNotify(string.char(84, 97, 114, 103, 101, 116, 32, 82, 111, 111, 116, 80, 97, 114, 116, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100))
end
else
sendNotify(string.char(84, 97, 114, 103, 101, 116, 32, 99, 104, 97, 114, 97, 99, 116, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100))
end
end
commands[string.char(98, 114, 105, 110, 103)] = function(args)
local name = args[1]
if not name then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 59, 98, 114, 105, 110, 103, 32, 91, 112, 108, 97, 121, 101, 114, 93)) return end
local target = findPlayer(name)
if not target then sendNotify(string.char(80, 108, 97, 121, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100, 58, 32) .. name) return end
local targetChar = target.Character
local root = getRootPart()
if targetChar and root then
local targetRoot = targetChar:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116))
if targetRoot then
targetRoot.CFrame = CFrame.new(root.Position.X + 3, root.Position.Y, root.Position.Z)
sendNotify(string.char(66, 114, 111, 117, 103, 104, 116, 32) .. target.Name)
end
end
end
commands[string.char(110, 111, 116, 105, 102, 121)] = function(args)
local msg = table.concat(args, string.char(32))
if msg == "" then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 110, 111, 116, 105, 102, 121, 32, 91, 109, 101, 115, 115, 97, 103, 101, 93)) return end
sendNotify(msg, string.char(78, 111, 116, 105, 102, 105, 99, 97, 116, 105, 111, 110), 5)
end
commands[string.char(114, 101, 115, 101, 116)] = function()
local root = getRootPart()
if root then
root.CFrame = CFrame.new(root.Position.X, -10000, root.Position.Z)
sendNotify(string.char(67, 104, 97, 114, 97, 99, 116, 101, 114, 32, 114, 101, 115, 101, 116))
else
sendNotify(string.char(67, 104, 97, 114, 97, 99, 116, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100), string.char(73, 89, 32, 69, 114, 114, 111, 114), 3)
end
end
commands[string.char(103, 97, 109, 101)] = function()
local success, name = pcall(function()
local marketplace = game:GetService(string.char(77, 97, 114, 107, 101, 116, 112, 108, 97, 99, 101, 83, 101, 114, 118, 105, 99, 101))
local info = marketplace:GetProductInfo(game.PlaceId)
return info.Name
end)
if success and name then
sendNotify(name, string.char(67, 117, 114, 114, 101, 110, 116, 32, 103, 97, 109, 101), 4)
else
local placeName = game.Name or string.char(73, 110, 99, 111, 110, 110, 117)
local placeId = game.PlaceId or string.char(63)
sendNotify(placeName .. string.char(32, 40, 73, 68, 58, 32) .. placeId .. string.char(41), string.char(67, 117, 114, 114, 101, 110, 116, 32, 103, 97, 109, 101), 4)
end
end
commands[string.char(119, 115)] = function(args)
commands[string.char(115, 112, 101, 101, 100)](args)
end
commands[string.char(106, 104)] = function(args)
local val = tonumber(args[1])
if not val then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 106, 104, 32, 91, 118, 97, 108, 93)) return end
if humWrite(HUM_JUMPPOWER, val) then sendNotify(string.char(74, 117, 109, 112, 32, 45, 62, 32) .. val) end
end
commands[string.char(116, 105, 109, 101)] = function()
local t = math.floor(os.time())
local h = math.floor(t / 3600) % 24
local m = math.floor(t / 60) % 60
local s = t % 60
sendNotify(string.format(string.char(37, 48, 50, 100, 58, 37, 48, 50, 100, 58, 37, 48, 50, 100), h, m, s), string.char(83, 101, 114, 118, 101, 114, 32, 116, 105, 109, 101), 4)
end
commands[string.char(99, 111, 111, 114, 100, 115)] = function()
local root = getRootPart()
if root then
local p = root.Position
sendNotify(string.format(string.char(88, 58, 37, 46, 49, 102, 32, 89, 58, 37, 46, 49, 102, 32, 90, 58, 37, 46, 49, 102), p.X, p.Y, p.Z), string.char(67, 111, 111, 114, 100, 105, 110, 97, 116, 101, 115), 5)
end
end
commands[string.char(102, 108, 105, 110, 103)] = function(args)
local name = args[1]
if not name then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 59, 102, 108, 105, 110, 103, 32, 91, 112, 108, 97, 121, 101, 114, 93)) return end
local target = findPlayer(name)
if not target then sendNotify(string.char(80, 108, 97, 121, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100)) return end
local targetChar = target.Character
if not targetChar then sendNotify(string.char(84, 97, 114, 103, 101, 116, 32, 99, 104, 97, 114, 97, 99, 116, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100)) return end
local targetRoot = targetChar:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116))
if not targetRoot then return end
local myRoot = getRootPart()
if not myRoot then return end
local originalCF = myRoot.CFrame
local wasNoclip = noclipEnabled
sendNotify(string.char(70, 76, 73, 78, 71, 32, 115, 117, 114, 32) .. target.Name, string.char(73, 89, 32, 77, 97, 116, 99, 104, 97), 3)
if not noclipEnabled then commands[string.char(110, 111, 99, 108, 105, 112)]() end
task.wait(0.05)
myRoot.CFrame = targetRoot.CFrame * CFrame.Angles(math.pi/2, 0, 0)
task.wait(0.05)
if not wasNoclip then commands[string.char(99, 108, 105, 112)]() end
task.wait(0.05)
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
task.wait(0.2)
if targetRoot.AssemblyLinearVelocity.Magnitude > 100 then
sendNotify(string.char(83, 117, 99, 99, 101, 115, 115, 32, 33, 32) .. target.Name .. string.char(32, 119, 97, 115, 32, 112, 114, 111, 106, 101, 99, 116, 101, 100), string.char(70, 76, 73, 78, 71), 3)
else
sendNotify(string.char(70, 97, 105, 108, 117, 114, 101, 58, 32, 115, 116, 97, 116, 105, 111, 110, 97, 114, 121, 32, 116, 97, 114, 103, 101, 116), string.char(70, 76, 73, 78, 71), 3)
end
myRoot.CFrame = originalCF
myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
if wasNoclip == false then
commands[string.char(99, 108, 105, 112)]()
end
end
local antiFlingEnabled = false
local antiFlingThread  = nil
commands[string.char(97, 110, 116, 105, 102, 108, 105, 110, 103)] = function()
if antiFlingEnabled then sendNotify(string.char(65, 110, 116, 105, 70, 108, 105, 110, 103, 32, 97, 108, 114, 101, 97, 100, 121, 32, 97, 99, 116, 105, 118, 101, 33)) return end
antiFlingEnabled = true
sendNotify(string.char(65, 110, 116, 105, 70, 108, 105, 110, 103, 32, 79, 78))
antiFlingThread = task.spawn(function()
while antiFlingEnabled do
local root = getRootPart()
if root then
local vel = root.AssemblyLinearVelocity
if vel.Magnitude > 200 then
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
end
end
task.wait(0.05)
end
end)
end
commands[string.char(110, 111, 97, 110, 116, 105, 102, 108, 105, 110, 103)] = function()
antiFlingEnabled = false
sendNotify(string.char(65, 110, 116, 105, 70, 108, 105, 110, 103, 32, 79, 70, 70))
end
local looptpEnabled = false
local looptpThread  = nil
commands[string.char(108, 111, 111, 112, 116, 112)] = function(args)
local name = args[1]
if not name then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 108, 111, 111, 112, 116, 112, 32, 91, 112, 108, 97, 121, 101, 114, 93)) return end
local target = findPlayer(name)
if not target then sendNotify(string.char(80, 108, 97, 121, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100, 58, 32) .. name) return end
if looptpEnabled then
looptpEnabled = false
task.wait(0.1)
end
looptpEnabled = true
sendNotify(string.char(76, 111, 111, 112, 84, 80, 32, 45, 62, 32) .. target.Name .. string.char(32, 40, 115, 116, 111, 112, 108, 111, 111, 112, 116, 112, 32, 116, 111, 32, 115, 116, 111, 112, 41))
looptpThread = task.spawn(function()
while looptpEnabled do
local root = getRootPart()
local tc   = target.Character
if root and tc then
local tr = tc:FindFirstChild(string.char(72, 117, 109, 97, 110, 111, 105, 100, 82, 111, 111, 116, 80, 97, 114, 116))
if tr then
root.CFrame = CFrame.new(tr.Position.X, tr.Position.Y + 3, tr.Position.Z)
end
end
task.wait(0.1)
end
end)
end
commands[string.char(115, 116, 111, 112, 108, 111, 111, 112, 116, 112)] = function()
looptpEnabled = false
sendNotify(string.char(76, 111, 111, 112, 84, 80, 32, 115, 116, 111, 112, 112, 101, 100))
end
commands[string.char(97, 100, 100, 119, 112)] = function(args)
local name = args[1]
if not name then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 59, 97, 100, 100, 119, 112, 32, 91, 110, 97, 109, 101, 93)) return end
local root = getRootPart()
if not root then sendNotify(string.char(67, 104, 97, 114, 97, 99, 116, 101, 114, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100)) return end
waypoints[name] = {
CFrame = root.CFrame,
Position = root.Position,
Name = name
}
sendNotify(string.char(87, 97, 121, 112, 111, 105, 110, 116, 32, 39) .. name .. string.char(39, 32, 97, 100, 100, 101, 100))
end
commands[string.char(100, 101, 108, 119, 112)] = function(args)
local name = args[1]
if not name then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 59, 100, 101, 108, 119, 112, 32, 91, 110, 97, 109, 101, 93)) return end
if waypoints[name] then
waypoints[name] = nil
sendNotify(string.char(87, 97, 121, 112, 111, 105, 110, 116, 32, 39) .. name .. string.char(39, 32, 100, 101, 108, 101, 116, 101, 100))
else
sendNotify(string.char(87, 97, 121, 112, 111, 105, 110, 116, 32, 39) .. name .. string.char(39, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100))
end
end
commands[string.char(116, 112, 119, 112)] = function(args)
local name = args[1]
if not name then sendNotify(string.char(85, 115, 97, 103, 101, 58, 32, 59, 116, 112, 119, 112, 32, 91, 110, 111, 109, 93)) return end
local wp = waypoints[name]
if wp then
local root = getRootPart()
if root then
root.CFrame = wp.CFrame
sendNotify(string.char(84, 101, 108, 101, 112, 111, 114, 116, 101, 100, 32, 116, 111, 32, 39) .. name .. string.char(39))
end
else
sendNotify(string.char(87, 97, 121, 112, 111, 105, 110, 116, 32, 39) .. name .. string.char(39, 32, 110, 111, 116, 32, 102, 111, 117, 110, 100))
end
end
commands[string.char(119, 112)] = function()
local list = {}
for name in pairs(waypoints) do table.insert(list, name) end
if #list == 0 then
sendNotify(string.char(65, 117, 99, 117, 110, 32, 119, 97, 121, 112, 111, 105, 110, 116, 46, 32, 84, 97, 112, 101, 122, 32, 59, 97, 100, 100, 119, 112, 32, 91, 110, 111, 109, 93))
else
sendNotify(string.char(87, 97, 121, 112, 111, 105, 110, 116, 115, 32, 58, 32) .. table.concat(list, string.char(44, 32)))
end
end
local spinEnabled = false
local spinConn    = nil
local spinSpeed   = 15
commands[string.char(115, 112, 105, 110)] = function(args)
local spd = tonumber(args[1])
if spd then spinSpeed = spd end
if spinEnabled then
sendNotify(string.char(83, 112, 105, 110, 32, 115, 112, 101, 101, 100, 32, 45, 62, 32) .. spinSpeed)
return
end
spinEnabled = true
sendNotify(string.char(83, 112, 105, 110, 32, 79, 78, 32, 40, 115, 112, 101, 101, 100, 58, 32) .. spinSpeed .. string.char(41))
local RS = game:GetService(string.char(82, 117, 110, 83, 101, 114, 118, 105, 99, 101))
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
local pos = root.Position
root.CFrame = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(0, rad, 0)
local vel = root.AssemblyLinearVelocity
root.AssemblyLinearVelocity = vel
end
end)
end
commands[string.char(117, 110, 115, 112, 105, 110)] = function()
spinEnabled = false
sendNotify(string.char(83, 112, 105, 110, 32, 79, 70, 70))
end
local infJumpEnabled = false
local infJumpConn    = nil
commands[string.char(105, 110, 102, 106, 117, 109, 112)] = function()
if infJumpEnabled then
sendNotify(string.char(73, 110, 102, 32, 74, 117, 109, 112, 32, 97, 108, 114, 101, 97, 100, 121, 32, 97, 99, 116, 105, 118, 101, 33, 32, 85, 115, 101, 32, 110, 111, 105, 110, 102, 106, 117, 109, 112, 32, 116, 111, 32, 115, 116, 111, 112))
return
end
infJumpEnabled = true
sendNotify(string.char(73, 110, 102, 32, 74, 117, 109, 112, 32, 79, 78, 32, 45, 32, 104, 111, 108, 100, 32, 83, 112, 97, 99, 101))
local RS = game:GetService(string.char(82, 117, 110, 83, 101, 114, 118, 105, 99, 101))
infJumpConn = RS.Heartbeat:Connect(function()
if not infJumpEnabled then return end
if iskeypressed(0x20) then
local root = getRootPart()
if root then
local vel = root.AssemblyLinearVelocity
if vel.Y < 50 then
root.AssemblyLinearVelocity = Vector3.new(vel.X, 80, vel.Z)
end
end
end
end)
end
commands[string.char(110, 111, 105, 110, 102, 106, 117, 109, 112)] = function()
infJumpEnabled = false
if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
sendNotify(string.char(73, 110, 102, 32, 74, 117, 109, 112, 32, 79, 70, 70))
end
commands[string.char(97, 110, 116, 105, 97, 102, 107)] = function()
if antiAFKEnabled then
sendNotify(string.char(65, 110, 116, 105, 45, 65, 70, 75, 32, 97, 108, 114, 101, 97, 100, 121, 32, 97, 99, 116, 105, 118, 101))
return
end
antiAFKEnabled = true
sendNotify(string.char(65, 110, 116, 105, 45, 65, 70, 75, 32, 97, 99, 116, 105, 118, 97, 116, 101, 100), string.char(73, 89, 32, 77, 97, 116, 99, 104, 97), 3)
antiAFKThread = task.spawn(function()
while antiAFKEnabled do
task.wait(45)
local root = getRootPart()
if root then
local pos = root.Position
root.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(2), 0)
end
end
end)
end
commands[string.char(110, 111, 97, 110, 116, 105, 97, 102, 107)] = function()
if not antiAFKEnabled then
sendNotify(string.char(65, 110, 116, 105, 45, 65, 70, 75, 32, 110, 111, 116, 32, 97, 99, 116, 105, 118, 101))
return
end
antiAFKEnabled = false
if antiAFKThread then
task.cancel(antiAFKThread)
antiAFKThread = nil
end
sendNotify(string.char(65, 110, 116, 105, 45, 65, 70, 75, 32, 100, 105, 115, 97, 98, 108, 101, 100))
end
commands[string.char(97, 117, 116, 111, 99, 108, 105, 99, 107)] = function(args)
local delay = tonumber(args[1]) or 0.05
if autoclickEnabled then
autoclickEnabled = false
if autoclickThread then task.cancel(autoclickThread) end
sendNotify(string.char(65, 117, 116, 111, 45, 99, 108, 105, 99, 107, 32, 100, 105, 115, 97, 98, 108, 101, 100))
return
end
autoclickEnabled = true
sendNotify(string.char(65, 117, 116, 111, 45, 99, 108, 105, 99, 107, 32, 101, 110, 97, 98, 108, 101, 100, 32, 40) .. delay .. string.char(115, 41), string.char(73, 89, 32, 77, 97, 116, 99, 104, 97), 2)
autoclickThread = task.spawn(function()
while autoclickEnabled do
mouse1click()
task.wait(delay)
end
end)
end
local commandOrder = {
{ name=string.char(115, 112, 101, 101, 100, 32, 40, 119, 115, 41),  desc=string.char(67, 104, 97, 110, 103, 101, 32, 119, 97, 108, 107, 115, 112, 101, 101, 100, 32, 91, 118, 97, 108, 93) },
{ name=string.char(106, 117, 109, 112, 32, 32, 40, 106, 104, 41),  desc=string.char(67, 104, 97, 110, 103, 101, 32, 106, 117, 109, 112, 32, 112, 111, 119, 101, 114, 32, 91, 118, 97, 108, 93) },
{ name=string.char(102, 108, 121),         desc=string.char(70, 108, 121, 32, 40, 87, 65, 83, 68, 43, 83, 112, 97, 99, 101, 47, 83, 104, 105, 102, 116, 41) },
{ name=string.char(117, 110, 102, 108, 121),       desc=string.char(83, 116, 111, 112, 32, 102, 108, 121, 105, 110, 103) },
{ name=string.char(110, 111, 99, 108, 105, 112),      desc=string.char(87, 97, 108, 107, 32, 116, 104, 114, 111, 117, 103, 104, 32, 119, 97, 108, 108, 115) },
{ name=string.char(99, 108, 105, 112),        desc=string.char(82, 101, 45, 101, 110, 97, 98, 108, 101, 32, 99, 111, 108, 108, 105, 115, 105, 111, 110, 115) },
{ name=string.char(103, 111, 100),         desc=string.char(71, 111, 100, 32, 109, 111, 100, 101, 32, 79, 78) },
{ name=string.char(117, 110, 103, 111, 100),       desc=string.char(71, 111, 100, 32, 109, 111, 100, 101, 32, 79, 70, 70) },
{ name=string.char(105, 110, 102, 106, 117, 109, 112),     desc=string.char(73, 110, 102, 105, 110, 105, 116, 101, 32, 106, 117, 109, 112, 32, 40, 104, 111, 108, 100, 32, 83, 112, 97, 99, 101, 41) },
{ name=string.char(110, 111, 105, 110, 102, 106, 117, 109, 112),   desc=string.char(68, 105, 115, 97, 98, 108, 101, 32, 105, 110, 102, 105, 110, 105, 116, 101, 32, 106, 117, 109, 112) },
{ name=string.char(115, 112, 105, 110),        desc=string.char(83, 112, 105, 110, 32, 121, 111, 117, 114, 32, 99, 104, 97, 114, 97, 99, 116, 101, 114, 32, 91, 115, 112, 101, 101, 100, 93) },
{ name=string.char(117, 110, 115, 112, 105, 110),      desc=string.char(83, 116, 111, 112, 32, 115, 112, 105, 110, 110, 105, 110, 103) },
{ name=string.char(102, 108, 105, 110, 103),       desc=string.char(70, 108, 105, 110, 103, 32, 97, 32, 112, 108, 97, 121, 101, 114) },
{ name=string.char(97, 110, 116, 105, 102, 108, 105, 110, 103),   desc=string.char(65, 110, 116, 105, 45, 102, 108, 105, 110, 103, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110) },
{ name=string.char(110, 111, 97, 110, 116, 105, 102, 108, 105, 110, 103), desc=string.char(68, 105, 115, 97, 98, 108, 101, 32, 97, 110, 116, 105, 45, 102, 108, 105, 110, 103) },
{ name=string.char(116, 112),          desc=string.char(84, 101, 108, 101, 112, 111, 114, 116, 32, 116, 111, 32, 112, 108, 97, 121, 101, 114, 32, 91, 110, 97, 109, 101, 32, 111, 114, 32, 114, 97, 110, 100, 111, 109, 93) },
{ name=string.char(108, 111, 111, 112, 116, 112),      desc=string.char(76, 111, 111, 112, 32, 116, 101, 108, 101, 112, 111, 114, 116, 32, 116, 111, 32, 112, 108, 97, 121, 101, 114) },
{ name=string.char(115, 116, 111, 112, 108, 111, 111, 112, 116, 112),  desc=string.char(83, 116, 111, 112, 32, 108, 111, 111, 112, 32, 116, 101, 108, 101, 112, 111, 114, 116) },
{ name=string.char(97, 100, 100, 119, 112),       desc=string.char(65, 100, 100, 32, 97, 32, 119, 97, 121, 112, 111, 105, 110, 116, 32, 91, 110, 97, 109, 101, 93) },
{ name=string.char(100, 101, 108, 119, 112),       desc=string.char(68, 101, 108, 101, 116, 101, 32, 119, 97, 121, 112, 111, 105, 110, 116, 32, 91, 110, 97, 109, 101, 93) },
{ name=string.char(116, 112, 119, 112),        desc=string.char(84, 101, 108, 101, 112, 111, 114, 116, 32, 116, 111, 32, 119, 97, 121, 112, 111, 105, 110, 116, 32, 91, 110, 97, 109, 101, 93) },
{ name=string.char(119, 112),          desc=string.char(83, 104, 111, 119, 47, 104, 105, 100, 101, 32, 116, 104, 101, 32, 108, 105, 115, 116, 32, 111, 102, 32, 119, 97, 121, 112, 111, 105, 110, 116, 115) },
{ name=string.char(98, 114, 105, 110, 103),       desc=string.char(66, 114, 105, 110, 103, 32, 97, 32, 112, 108, 97, 121, 101, 114) },
{ name=string.char(97, 110, 116, 105, 97, 102, 107),     desc=string.char(65, 118, 111, 105, 100, 32, 116, 104, 101, 32, 105, 110, 97, 99, 116, 105, 118, 105, 116, 121, 32, 107, 105, 99, 107) },
{ name=string.char(110, 111, 97, 110, 116, 105, 97, 102, 107),   desc=string.char(68, 105, 115, 97, 98, 108, 101, 32, 65, 70, 75, 32, 112, 114, 111, 116, 101, 99, 116, 105, 111, 110) },
{ name=string.char(97, 117, 116, 111, 99, 108, 105, 99, 107),   desc=string.char(65, 117, 116, 111, 109, 97, 116, 105, 99, 32, 99, 108, 105, 99, 107, 32, 91, 100, 101, 108, 97, 121, 61, 48, 46, 48, 53, 93) },
{ name=string.char(114, 101, 115, 101, 116),       desc=string.char(82, 101, 115, 101, 116, 32, 99, 104, 97, 114, 97, 99, 116, 101, 114) },
{ name=string.char(99, 111, 111, 114, 100, 115),      desc=string.char(83, 104, 111, 119, 32, 99, 111, 111, 114, 100, 105, 110, 97, 116, 101, 115) },
{ name=string.char(116, 105, 109, 101),        desc=string.char(83, 101, 114, 118, 101, 114, 32, 116, 105, 109, 101) },
{ name=string.char(110, 111, 116, 105, 102, 121),      desc=string.char(83, 101, 110, 100, 32, 97, 32, 110, 111, 116, 105, 102, 105, 99, 97, 116, 105, 111, 110) },
{ name=string.char(103, 97, 109, 101),        desc=string.char(67, 117, 114, 114, 101, 110, 116, 32, 103, 97, 109, 101, 32, 110, 97, 109, 101) },
}
local barBg = Drawing.new(string.char(83, 113, 117, 97, 114, 101))
barBg.Size         = Vector2.new(440, 36)
barBg.Position     = Vector2.new(20, 548)
barBg.Color        = Color3.fromRGB(10, 10, 16)
barBg.Filled       = true
barBg.Transparency = 0.1
barBg.Visible      = false
barBg.ZIndex       = 50
local barAccent = Drawing.new(string.char(83, 113, 117, 97, 114, 101))
barAccent.Size         = Vector2.new(3, 36)
barAccent.Position     = Vector2.new(20, 548)
barAccent.Color        = Color3.fromRGB(80, 160, 255)
barAccent.Filled       = true
barAccent.Transparency = 0
barAccent.Visible      = false
barAccent.ZIndex       = 51
local barText = Drawing.new(string.char(84, 101, 120, 116))
barText.Text     = string.char(62, 32, 95)
barText.Position = Vector2.new(32, 557)
barText.Color    = Color3.fromRGB(180, 255, 180)
barText.Size     = 14
barText.Outline  = true
barText.Visible  = false
barText.ZIndex   = 52
local helpLabel = Drawing.new(string.char(84, 101, 120, 116))
helpLabel.Text     = string.char(91, 70, 54, 93, 32, 99, 111, 109, 109, 97, 110, 100, 32, 32, 32, 91, 77, 93, 32, 108, 105, 115, 116)
helpLabel.Position = Vector2.new(20, 532)
helpLabel.Color    = Color3.fromRGB(255, 0, 180)
helpLabel.Size     = 13
helpLabel.Outline  = true
helpLabel.Visible  = true
helpLabel.ZIndex   = 9
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
local function mkSq(x,y,w,h, r,g,b, tr, zi)
local s = Drawing.new(string.char(83, 113, 117, 97, 114, 101))
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
local t = Drawing.new(string.char(84, 101, 120, 116))
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
local pBg       = mkSq(0,0,0,0,  12,13,22,  0.08, 30)
local pBrdT     = mkSq(0,0,0,0,  60,130,255, 0,   32)
local pBrdB     = mkSq(0,0,0,0,  60,130,255, 0,   32)
local pBrdL     = mkSq(0,0,0,0,  60,130,255, 0,   32)
local pBrdR     = mkSq(0,0,0,0,  60,130,255, 0,   32)
local pHdrBg    = mkSq(0,0,0,0,  18,70,170,  0,   31)
local pHdrGlow  = mkSq(0,0,0,0,  70,160,255, 0,   32)
local pTitlePfx = mkTxt(string.char(62, 62), 0,0, 90,190,255, 13, 33)
local pTitleLbl = mkTxt(string.char(73, 89, 32, 77, 97, 116, 99, 104, 97), 0,0, 240,240,255, 14, 33)
local pVerBg    = mkSq(0,0,48,18, 40,90,200, 0, 33)
local pVerTxt   = mkTxt(string.char(118, 49, 46, 48), 0,0, 170,215,255, 11, 34)
local pHdrSep   = mkSq(0,0,0,0,  50,120,230, 0, 32)
local pListBg   = mkSq(0,0,0,0,  8,8,14,  0.05, 30)
local pSbTrack  = mkSq(0,0,5,0,  22,22,35, 0, 31)
local pSbThumb  = mkSq(0,0,5,30, 65,135,255, 0, 33)
local pFtrBg    = mkSq(0,0,0,0,  14,14,24, 0, 31)
local pFtrSep   = mkSq(0,0,0,0,  40,90,180, 0, 32)
local pFtrTxt   = mkTxt(string.char(91, 94, 93, 91, 118, 93, 32, 115, 99, 114, 111, 108, 108, 32, 32, 91, 77, 93, 32, 99, 108, 111, 115, 101, 32, 32, 91, 70, 54, 93, 32, 99, 109, 100), 0,0, 85,105,155, 11, 32)
local pFtrCount = mkTxt(string.char(48, 47, 48), 0,0, 65,135,255, 11, 33)
local pResizeDot= mkSq(0,0,8,8,  80,150,255, 0, 34)
local rowPool = {}
local function buildRowPool()
for _, row in ipairs(rowPool) do
row.bg:Remove();  row.acc:Remove()
row.name:Remove(); row.desc:Remove()
end
rowPool = {}
local VISIBLE = math.floor((PH - HDR_H - FOOT_H - PAD*2) / ROW_H)
for i = 1, VISIBLE do
local ry = PY + HDR_H + PAD + (i-1)*ROW_H
local rbg  = Drawing.new(string.char(83, 113, 117, 97, 114, 101))
rbg.Position     = Vector2.new(PX+1, ry)
rbg.Size         = Vector2.new(PW-8, ROW_H-1)
rbg.Color        = i%2==0 and Color3.fromRGB(22,22,34) or Color3.fromRGB(16,16,26)
rbg.Filled       = true
rbg.Transparency = 0
rbg.ZIndex       = 30
rbg.Visible      = false
table.insert(allObjs, rbg)
local racc = Drawing.new(string.char(83, 113, 117, 97, 114, 101))
racc.Position     = Vector2.new(PX+1, ry)
racc.Size         = Vector2.new(2, ROW_H-1)
racc.Color        = Color3.fromRGB(65,135,255)
racc.Filled       = true
racc.Transparency = 0
racc.ZIndex       = 31
racc.Visible      = false
table.insert(allObjs, racc)
local rname = Drawing.new(string.char(84, 101, 120, 116))
rname.Text     = ""
rname.Position = Vector2.new(PX+10, ry+4)
rname.Color    = Color3.fromRGB(255,255,255)
rname.Size     = 12
rname.Outline  = true
rname.ZIndex   = 32
rname.Visible  = false
table.insert(allObjs, rname)
local rdesc = Drawing.new(string.char(84, 101, 120, 116))
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
local function layoutPanel()
local VISIBLE = #rowPool
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
pListBg.Position  = Vector2.new(PX, PY+HDR_H+1)
pListBg.Size      = Vector2.new(PW, PH-HDR_H-FOOT_H-1)
local trackH = PH - HDR_H - FOOT_H - 4
pSbTrack.Position = Vector2.new(PX+PW-6, PY+HDR_H+2)
pSbTrack.Size     = Vector2.new(5, trackH)
pSbThumb.Position = Vector2.new(PX+PW-6, PY+HDR_H+2)
pFtrBg.Position   = Vector2.new(PX, PY+PH-FOOT_H)
pFtrBg.Size       = Vector2.new(PW, FOOT_H)
pFtrSep.Position  = Vector2.new(PX, PY+PH-FOOT_H)
pFtrSep.Size      = Vector2.new(PW, 1)
pFtrTxt.Position  = Vector2.new(PX+8, PY+PH-FOOT_H+7)
pFtrCount.Position= Vector2.new(PX+PW-38, PY+PH-FOOT_H+7)
pResizeDot.Position = Vector2.new(PX+PW-10, PY+PH-10)
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
local from = scrollOffset + 1
local to   = math.min(scrollOffset + VISIBLE, total)
pFtrCount.Text = from..string.char(45)..to..string.char(47)..total
end
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
buildRowPool()
layoutPanel()
local inputBuffer = ""
local isTyping    = false
local dragging    = false
local dragOffX    = 0
local dragOffY    = 0
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
local KC_PGUP   = 0x21
local KC_PGDN   = 0x22
local charMap = {
[0x41]=string.char(97),[0x42]=string.char(98),[0x43]=string.char(99),[0x44]=string.char(100),[0x45]=string.char(101),
[0x46]=string.char(102),[0x47]=string.char(103),[0x48]=string.char(104),[0x49]=string.char(105),[0x4A]=string.char(106),
[0x4B]=string.char(107),[0x4C]=string.char(108),[0x4D]=string.char(109),[0x4E]=string.char(110),[0x4F]=string.char(111),
[0x50]=string.char(112),[0x51]=string.char(113),[0x52]=string.char(114),[0x53]=string.char(115),[0x54]=string.char(116),
[0x55]=string.char(117),[0x56]=string.char(118),[0x57]=string.char(119),[0x58]=string.char(120),[0x59]=string.char(121),
[0x5A]=string.char(122),[0x20]=string.char(32)
}
local numMap = {
[0x30]=string.char(48),[0x31]=string.char(49),[0x32]=string.char(50),[0x33]=string.char(51),[0x34]=string.char(52),
[0x35]=string.char(53),[0x36]=string.char(54),[0x37]=string.char(55),[0x38]=string.char(56),[0x39]=string.char(57)
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
input = input:lower():match(string.char(94, 37, 115, 42, 40, 46, 45, 41, 37, 115, 42, 36))
if input == "" then return end
local parts = {}
for w in input:gmatch(string.char(37, 83, 43)) do table.insert(parts,w) end
local cmd  = parts[1]
local args = {}
for i=2,#parts do table.insert(args,parts[i]) end
if commands[cmd] then
local ok,err = pcall(commands[cmd], args)
if not ok then sendNotify(string.char(69, 114, 114, 101, 117, 114, 58, 32)..tostring(err),string.char(73, 89, 32, 69, 114, 114, 111, 114),4) end
else
sendNotify(string.char(85, 110, 107, 110, 111, 119, 110, 58, 32)..cmd,string.char(73, 89, 32, 77, 97, 116, 99, 104, 97),3)
end
end
sendNotify(string.char(73, 89, 32, 77, 97, 116, 99, 104, 97, 32, 32, 91, 70, 54, 93, 32, 99, 109, 100, 32, 32, 91, 77, 93, 32, 108, 105, 115, 116), string.char(73, 89, 32, 77, 97, 116, 99, 104, 97), 4)
local scrollCD = 0
local mouse = game:GetService(string.char(80, 108, 97, 121, 101, 114, 115)).LocalPlayer:GetMouse()
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
local ring = Drawing.new(string.char(67, 105, 114, 99, 108, 101))
ring.Position = Vector2.new(x, y)
ring.Radius = radius
ring.Color = Color3.fromRGB(0, 180, 240)
ring.Thickness = 2
ring.Filled = false
ring.Transparency = 0.2
ring.Visible = true
ring.ZIndex = 100
table.insert(wpMarkers, ring)
local dot = Drawing.new(string.char(67, 105, 114, 99, 108, 101))
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
local bg = Drawing.new(string.char(83, 113, 117, 97, 114, 101))
bg.Position = Vector2.new(bgX, y - 20)
bg.Size = Vector2.new(bgWidth, 16)
bg.Color = Color3.fromRGB(0, 0, 0)
bg.Filled = true
bg.Transparency = 0.5
bg.Visible = true
bg.ZIndex = 99
table.insert(wpMarkers, bg)
local txt = Drawing.new(string.char(84, 101, 120, 116))
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
task.spawn(function()
while true do
updateMarkers()
task.wait(0.05)
end
end)
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
if panelOpen then
if m1down and not resizing then
if inRect(mx,my, PX, PY, PW, HDR_H) then
dragging = true
dragOffX = mx - PX
dragOffY = my - PY
end
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
if panelOpen then
if inRect(mx, my, PX, PY, PW, PH) then
setrobloxinput(false)
else
setrobloxinput(true)
end
end
if not isTyping and justPressed(KC_M) then
if panelOpen then
closePanel()
setrobloxinput(true)
else
openPanel()
end
end
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
if not isTyping and justPressed(KC_F6) then
isTyping    = true
inputBuffer = ""
barBg.Visible     = true
barAccent.Visible = true
barText.Visible   = true
helpLabel.Visible = false
barText.Text      = string.char(62, 32, 95)
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
barText.Text = string.char(62, 32)..inputBuffer..string.char(95)
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
barText.Text = string.char(62, 32)..inputBuffer..string.char(95)
end
end
end
prevKeys[KC_F6]=iskeypressed(KC_F6); prevKeys[KC_M]=iskeypressed(KC_M)
prevKeys[KC_ENTER]=iskeypressed(KC_ENTER); prevKeys[KC_BACK]=iskeypressed(KC_BACK)
prevKeys[KC_ESC]=iskeypressed(KC_ESC); prevKeys[KC_UP]=iskeypressed(KC_UP)
prevKeys[KC_DOWN]=iskeypressed(KC_DOWN); prevKeys[KC_PGUP]=iskeypressed(KC_PGUP)
prevKeys[KC_PGDN]=iskeypressed(KC_PGDN)
for kc in pairs(charMap) do prevKeys[kc]=iskeypressed(kc) end
for kc in pairs(numMap) do prevKeys[kc]=iskeypressed(kc) end
end
end)
