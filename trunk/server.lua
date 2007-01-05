--LuaMMO server by Polarity
--Connect to this on port 2220 using telnet to play the game.

--Create our info function. Does formatting for us automatically.
function info(message)
	print("LuaMMO: "..message)
end

--Say what we're doing, loading the socket library
info("Loading socket library.")

--Load the socket library
require("socket")

--Create our client object
listening = socket.tcp()

--Set the client to listen
listening:bind("127.0.0.1",2220)
listening:listen()

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

function AddCommand(command, response, callback, arg1, args2, arg3, arg4)
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
			info("Error adding command. No callback or response specified when adding function "..command..".")
		end
	else
		info("Not enough args to AddCommand request")
	end
end

--Create default commands
AddCommand("HELLO","Hey there!")

--Can you say connection coroutine?
function NewConnection(connection)
	local servertime = os.date("%I:%M%p")
	local connection = listening:accept()
	table.insert(recvt,connection)
	connection:send("Welcome to LuaMMO.\r\n")
	connection:send("Server time is "..servertime.."\r\n")
	connection:send("Please enter your login details for LuaMMO\r\n")
	connection:send("Login: ")
	info("New client connected.")
end

function createConnectionRoutine(connection)
    local handler = coroutine.create(NewConnection)
    coroutine.resume(handler, connection)
    return handler
end

function getData()

end

function setData()

end

--Loop forever
while true do

	local reading,writing,err = socket.select(recvt,nil)
	
	if reading[listening] then
		recvt[listening] = {}
		recvt[listening].handler = createConnectionRoutine(listening)
	else
		for _, server in ipairs(reading) do
			local message = server:receive("*l")
			if message == "QUIT" then
				info("Client disconnected.")
				server:close()
			else
				local response = ParseCommand(message)
				if response == nil then response = "LuaMMO: Invalid command." end
				server:send(response.."\r\n")
			end
		end
	end
	
end
