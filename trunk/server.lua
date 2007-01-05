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

--Create our commands table
commands = {}

--Setup command handlers
function ParseCommand(command)
	if commands[command] then
		if commands[command].callback then
			commands[command].callback()
		end
		if commands[command].response then
			return commands[command].response
		end
	else
		return nil
	end
end

function AddCommand(command, response, callback)
	if command then
		commands[command] = {}
		if response or callback then
			if callback then
					commands[command].callback = callback
			end
			if response then
				commands[command].response = response
			end
		else
			print("LuaMMO: Error adding command. No callback or response specified when adding function "..command..".")
		end
	else
		print("LuaMMO: Not enough args to AddCommand request")
	end
end

--Create default commands
AddCommand("HELLO","Hey there!")

--Loop forever
while true do

	local reading,writing,err = socket.select(recvt,nil)
	
	if reading[listening] then
		local servertime = os.date("%I:%M%p")
		local connected = listening:accept()
		table.insert(recvt,connected)
		connected:send("Welcome to LuaMMO.\r\n")
		connected:send("Server time is "..servertime.."\r\n")
		connected:send("Please enter your login details for LuaMMO\r\n")
		connected:send("Login: ")
		print("LuaMMO: New client connected.")
	else
		for _, server in ipairs(reading) do
			local message = server:receive("*l")
			if message == "QUIT" then
				server:close()
			else
				local response = ParseCommand(message)
				if response == nil then response = "LuaSQL: Invalid command." end
				server:send(response.."\r\n")
			end
		end
	end
	
end
