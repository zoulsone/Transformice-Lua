tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAutoShaman(true)


system = {
	game = {
		started = false,
		ending = false,
		countdown = 0
	},
	maps = { 24017, 24018, 24019, 22500, 22499, 22497, 22496, 22495, 22494, 22493, 22492, 22491, 22490, 22489, 22488, 22487, 22486, 22485, 22483, 22128, 21371, 20031, 20030, 20029, 20028, 20027, 20026, 20025, 20024, 20023, 20022, 20021, 20020, 20019, 19985, 11884, 11885, 11886, 11961, 11964, 12240, 12241, 12242, 12243, 12413, 12427, 12428, 12429, 12430, 12431, 12432, 12433, 12434, 12435, 12436, 12437, 12438} ,
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
	for i,d in pairs(system.respawn) do
		if d.t - os.time() < 0 then
			tfm.exec.respawnPlayer(d.name)
			system.respawn[i] = nil
		end
    end
	-- removeImage
	for img,t in pairs(system.removeImage) do
 
        local T=t["t"]
        if T- os.time()<0 then
 
            tfm.exec.removeImage(img,t["n"])
            system.removeImage[img]=nil
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
        system.removeImage[tfm.exec.addImage("149af14bccc.png", "&1001", 300, 240)]={t=os.time()+1000}
    end
    if r==115 and TIMER==1 then
        TIMER=TIMER+1
        system.removeImage[tfm.exec.addImage("149af0f217c.png", "&1001", 300, 240)]={t=os.time()+1000}
    end
    if r==114 and TIMER==2 then
        TIMER=TIMER+1
        system.removeImage[tfm.exec.addImage("149af14e1ba.png", "&1001", 300, 240)]={t=os.time()+1000}
    end
    if r==113 and TIMER==3 then
        TIMER=TIMER+1
        system.removeImage[tfm.exec.addImage("149aeabbb5e.png", "&1001", 300, 240)]={t=os.time()+1000}
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
