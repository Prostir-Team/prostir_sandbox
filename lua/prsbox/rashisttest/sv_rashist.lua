util.AddNetworkString("PRSBOX.Net.StartTester")
util.AddNetworkString("PRSBOX.Net.ConfirmTester")
util.AddNetworkString("PRSBOX.Net.CheckTester")
util.AddNetworkString("PRSBOX.Net.EndTester")
util.AddNetworkString("PRSBOX.Net.EndBadTester")
util.AddNetworkString("PRSBOX.Client.Rahist.Start")

local defaultFilename = "cfg/uk_tester.json"

local canDoMistakes = 1

local function checkPlayer(ply)
    local steamid = ply:SteamID()

	local f = file.Open("complete_test.dat", "r", "DATA")
	if not f then return end
    if file.Size("complete_test.dat", "DATA") == 0 then return end

	local data = f:Read()
	if not isstring(data) then return false end
	data = string.Split(data, "\n")

	return table.HasValue(data, steamid)
end

local function getTest()
	local filename = "cfg/test.json"
	if not file.Exists(filename, "GAME") then return end

	local f = file.Open(filename, "r", "GAME")
	if not f then return end

	local data = f:Read()

	return util.JSONToTable(data)
end

local function convertForClient(data)
	if not istable(data) then return end
	
	local dataToClient = data

	print(dataToClient)

	for _, question in ipairs(table.GetKeys(dataToClient)) do
		for k, answer in ipairs(table.GetKeys(dataToClient[question])) do
			dataToClient[question][answer] = false
		end
	end

	return dataToClient	
end

local function addPlayerToFile(ply)
	if not IsValid(ply) then return end
	local steamid = ply:SteamID()

	file.Append("complete_test.dat", steamid .. "\n")
end

---
--- Hooks 
---

hook.Add("Initialize", "PRSBOX.Tester.CreateFile", function ()
	if file.Exists("complete_test.dat", "DATA") then return end

	file.Write("complete_test.dat", "")
end)

hook.Add("PlayerInitialSpawn", "PRSBOX.Rashist.SetPlayer", function (ply, tr)
	local completeRashist = checkPlayer(ply)
	
	ply:SetNWBool("PRSBOX.Net.CompleteRashist", completeRashist)
end)


---
--- Net methods 
---

net.Receive("PRSBOX.Net.ConfirmTester", function (len, ply)
	if not IsValid(ply) then return end
	
	timer.Simple(101, function ()
		if not ply:GetNWBool("PRSBOX.Net.Tester") then return end
		
		ply:Kick("Ви не встигли пройти тестування")
	end)
end)

net.Receive("PRSBOX.Net.CheckTester", function (len, ply)
	local data = net.ReadTable()

	local originalData = getTest()
	local questions = table.GetKeys(data)

	local rightAnswers = 0

	for _, question in ipairs(questions) do
		local answers = table.GetKeys(data[question])

		for _, answer in ipairs(answers) do
			if data[question][answer] == originalData[question][answer] and originalData[question][answer] then
				rightAnswers = rightAnswers + 1
			end
		end
	end

	if rightAnswers >= #questions - canDoMistakes then
		addPlayerToFile(ply)
		
		ply:SetNWBool("PRSBOX.Net.CompleteRashist", true)
		net.Start("PRSBOX.Net.EndTester")
		net.Send(ply)
	else
		local steamId = ply:SteamID()
		
		net.Start("PRSBOX.Net.EndBadTester")
		net.Send(ply)

		timer.Simple(10, function ()
			RunConsoleCommand("ulx", "banid", steamId, "На жаль ви не пройшли тестування!\nЯкщо ви з чимось не згодні, будь ласка, завітайте до діскорд серверу, та поставте запитання модераторам або Сванчіку.\nhttps://discord.gg/stV4JswQ9Q")
		end)
	end
end)

net.Receive("PRSBOX.Client.Rahist.Start", function (len, ply)
	if not IsValid(ply) then return end
	if checkPlayer(ply) then return end

	local data = getTest()

	data = convertForClient(data)

	net.Start("PRSBOX.Net.StartTester")
		net.WriteTable(data)
	net.Send(ply)
end)