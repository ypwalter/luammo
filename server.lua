--LuaMMO server by Polarity
--Connect to this on port 2220 using telnet to play the game.

--Load the socket library
require("socket")

--Create our client object
listening = socket.tcp()

--Set the client to listen
assert(listening:bind("127.0.0.1",2220))
assert(listening:listen())

--Create connections table
recvt = {}

--Add our initial connection to the table
table.insert(recvt,listening)

--Loop forever
while true do

	local reading,writing,err = socket.select(recvt,nil)
	
	if reading[listening] then
		local connected = listening:accept()
		table.insert(recvt,connected)
		connected:send("Welcome to LuaMMO.")
		print("LuaMMO: New client connected.")
	else
		for _, server in ipairs(reading) do
			local message = server:receive("*l")
			server:send(ParseCommand(message))
		end
	end
	
end

--Parse command from a client. (Got this ready for later)
function ParseCommand(command)

	if command == "HELLO" then return "HELLO" end
	
end
