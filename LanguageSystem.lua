--[[
Coded by Soulzone5257 (aka Soulzone)
Atelier 801 Guide Thread: http://atelier801.com/topic?f=6&t=849616
]]--

system = {
	translation = {
		["en"] = {
			["Hello"] = "<ROSE>Hello there."
		}
	}
}

system.community = tfm.get.room.community
if not system.translation[system.community] then
    system.community = "en"
end

function getMsg(msgName)
    return system.translation[system.community][msgName]
end

function eventNewPlayer(name)
	print(getMsg("Hello"), name)
end
