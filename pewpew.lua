tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.chatMessage=print

system = {
	game = {
		started = false,
		ending = false,
		countdown = 0
	},
	maps = {521833,401421,541917,541928,541936,541943,527935,559634,559644,888052,878047,885641,770600,770656,772172,891472,589736,589800,589708,900012,901062,754380,901337,901411,907870,910078,1190467,1252043,1124380,1016258,1252299,1255902,1256808,986790,1285380,1271249,1255944,1255983,1085344,1273114,1276664,1279258,1286824,1280135,1280342,1284861,1287556,1057753,1196679,1288489,1292983,1298164,1298521,1293189,1296949,1308378,1311136,1314419,1314982,1318248,1312411,1312589,1312845,1312933,1313969,1338762,1339474,1349878,1297154,644588,1351237,1354040,1354375,1362386,1283234,1370578,1306592,1360889,1362753,1408124,1407949,1407849,1343986,1408028,1441370,1443416,1389255,1427349,1450527,1424739,869836,1459902,1392993,1426457,1542824,1533474,1561467,1563534,1566991,1587241,1416119,1596270,1601580,1525751,1582146,1558167,1420943,1466487,1642575,1648013,1646094,1393097,1643446,1545219,1583484,1613092,1627981,1633374,1633277,1633251,1585138,1624034,1616785,1625916,1667582,1666996,1675013,1675316,1531316,1665413,1681719,1699880,1688696,623770,1727243,1531329,1683915,1689533,1738601,3756146,912118,3326933,3722005,3566478,1456622,1357994,1985670,1884075,1708065,1700322,2124484,3699046,2965313,4057963,4019126,3335202,2050466},
	players = {},
	respawn = {},
	toDespawn = {},
	keys = { 3, 32 },
	removeImage = {},
	object = 17,
	objectCountdown = 5,
	objectList = {
		{ id = 1, x = 30, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 2, x = 30, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 3, x = 20, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 4, x = 55, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 6, x = 30, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 10, x = 15, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 17, x = 2, xSpeed = 0, angle = { right = 90, left = 270} }, -- drag
		{ id = 23, x = 5, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 28, x = 5, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 34, x = 5, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 35, x = 5, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 39, x = 20, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 40, x = 10, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 45, x = 20, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 46, x = 20, xSpeed = 50, angle = { right = 0, left = 0} },
		{ id = 57, x = 20, xSpeed = 30, angle = { right = 0, left = 0} },
		{ id = 54, x = 10, xSpeed = 30, angle = { right = 0, left = 0} },
		{ id = 61, x = 30, xSpeed = 30, angle = { right = 0, left = 0} }
	},
	bindKeyboard = system.bindKeyboard
}

function eventNewPlayer(playerName)
	system.players[playerName] = {
		timestamp = 0,
		timestampLimit = 1000,
		lives = 0
	}

	for i,key in ipairs(system.keys) do
        system.bindKeyboard(playerName, key, true, true)
    end

	--tfm.exec.chatMessage(getMsg("welcome").."\n<BV>[•] <N>Deathmatch version: <J>1.03", playerName)
	tfm.exec.chatMessage("<VP>Welcome to pewpew, <N>duck <VP>or <N>spacebar <VP>to shoot items!", playerName)
end

function eventNewGame()
	system.game.started = false
	system.game.ending = false
	TIMER = 0
	for i,d in pairs(system.players) do
		system.players[i].lives = 3
		tfm.exec.setPlayerScore(i, 3)
	end
end

function eventPlayerDied(playerName)
	local data = system.players[playerName]
	system.players[playerName].lives = system.players[playerName].lives - 1
	tfm.exec.setPlayerScore(playerName, system.players[playerName].lives)
	if data.lives > 0 then
		tfm.exec.chatMessage("<ROSE>You have <N>"..system.players[playerName].lives.." <ROSE>lives left. <VI>Respawning in 3...", playerName)
		table.insert(system.respawn, { name = playerName, t=os.time()+3000 })
	elseif data.lives <= 0 then
		tfm.exec.chatMessage("<ROSE>You have lost all your lives!", playerName)
		tfm.exec.setPlayerScore(playerName, 0)
	end

	local i = 0
	local n = nil

	for name,d in pairs(tfm.get.room.playerList) do
		local lives = system.players[name].lives
		if lives > 0 then
			i = i + 1
			n = name
		end
	end

	if i == 0 then tfm.exec.newGame(system.maps[math.random(#system.maps)]) end
	if i == 1 then
		tfm.exec.chatMessage("<ROSE>"..n.." is the sole survivor!")
		tfm.exec.giveCheese(n)
		tfm.exec.playerVictory(n)
		system.game.ending = true
	end
end

function eventPlayerLeft(playerName)
	eventPlayerDied(playerName)
	system.players[playerName].lives = 0
end

function eventKeyboard(playerName,key,down,x,y)
	if (key == 32 or key == 3) and not tfm.get.room.playerList[playerName].isDead and system.game.started then
		if os.time()-system.players[playerName].timestamp > system.players[playerName].timestampLimit then
			--local id = tfm.exec.addShamanObject(system.object, x+(tfm.get.room.playerList[playerName].isFacingRight and 2 or -2), y+8, tfm.get.room.playerList[playerName].isFacingRight and 90 or 270)
			local obj = system.object
			local aci = 0
			if tfm.get.room.playerList[playerName].isFacingRight then
				aci = obj.angle.right
			else
				aci = obj.angle.left
			end
			if obj.id == 10 then y = y+8 end
			local speed = (tfm.get.room.playerList[playerName].isFacingRight and obj.xSpeed or -obj.xSpeed)
			local id = tfm.exec.addShamanObject(obj.id, x+(tfm.get.room.playerList[playerName].isFacingRight and obj.x or -obj.x), y, aci, speed, 0, false)
			table.insert(system.toDespawn,{os.time(),id})
			system.players[playerName].timestamp = os.time()
        end
	end
end

TIMER = 0
function eventLoop(time,remaining)

	system.objectCountdown = system.objectCountdown - 0.5

	if system.objectCountdown <= 0 then
		local obj = system.objectList[math.random(#system.objectList)]
		system.object = obj
		system.objectCountdown = 20
	end

	if system.game.ending then
		tfm.exec.newGame(system.maps[math.random(#system.maps)])
	end
	-- revive
	for i,d in ipairs(system.respawn) do
		if d.t - os.time() < 0 then
			tfm.exec.respawnPlayer(d.name)
			system.respawn[i] = nil
		end
    end

	-- start
	if time >= 6000 and not system.game.started then
        system.game.started = true
    end

    if remaining <= 0 then
    	system.game.started = false
    	tfm.exec.newGame(system.maps[math.random(#system.maps)])
    end

    local r=math.floor(remaining/1000)
    if r==116 and TIMER==0 then
        TIMER=TIMER+1
        tfm.exec.chatMessage("<rose>3..")
    end
    if r==115 and TIMER==1 then
        TIMER=TIMER+1
        tfm.exec.chatMessage("<rose>2..")
    end
    if r==114 and TIMER==2 then
        TIMER=TIMER+1
        tfm.exec.chatMessage("<rose>1..")
    end
    if r==113 and TIMER==3 then
        TIMER=TIMER+1
        tfm.exec.chatMessage("<rose>Go!")
    end

        for i,item in ipairs(system.toDespawn) do
          if item[1] <= os.time()-2000 then
                tfm.exec.removeObject(item[2])
                table.remove(system.toDespawn,i)
          end
        end
end

for name,detail in pairs(tfm.get.room.playerList) do
	eventNewPlayer(name)
end
tfm.exec.newGame(system.maps[math.random(#system.maps)])
