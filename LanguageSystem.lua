system = {
	translation = {
		["EN"] = {
			["Hello"] = "<ROSE>Hello there."
		}
	}
}

system.community = tfm.get.room.community
if not system.translation[system.community] then
    system.community = "EN"
end

function getMsg(msgName)
    return system.translation[system.community][msgName]
end

function eventNewPlayer(name)
	print(getMsg("Hello"), name)
end
