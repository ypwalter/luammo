--LuaMMO client by Polarity

--Say what we're doing, loading the socket library
print("LuaMMO: Loading socket library.")

--Load the socket library
require("socket")

--Create the connection object
client,err = socket.tcp()
if client == nil then
	print("LuaMMO: Couldn't create TCP object. Error was \"".. err .."\"")
	os.exit()
end

--Say what we're doing, connecting to the master server.
print("LuaMMO: Connecting to masterserver.")

--Connect to the masterserver
err = client:connect("127.0.0.1",2220)
if err == 1 then
	print("LuaMMO: Connected to masterserver.")
else
 	print("LuaMMO: Couldn't connect to masterserver.")
	os.exit()
end

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

--Say what we're doing, setting up clientdata
print("LuaMMO: Setting up client data.")

--Add default commands
AddCommand("QUIT","LuaMMO: Shutting down.",os.exit)

function Receive()
	while true do
		local message, err = client:receive("*l")
		if err == nil then
			print(message)
		else
			print("LuaMMO: Lost connection to server.")
			exit()
		end
	end
end

--Say what we're doing, initiating session with server.
print("LuaMMO: Initiating session with server.")

--Start our coroutine to process incoming data
coroutine.create(Receive)

while true do
	--Get input
	local input = io.read()
	if ParseCommand(input) == nil then
		--Send input
		client:send(input.."\n")	
	else
		--Show output of the clientside command
		print(ParseCommand(input))
	end
end
