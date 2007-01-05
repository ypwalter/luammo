--LuaMMO client by Polarity

--Load the socket library
require("socket")

--Create the connection object
client = socket.tcp()

--Connect to the masterserver
client:connect("127.0.0.1",2220)

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

--Start our coroutine to process incoming data
coroutine.create(Receive)

while true do
	--Get input
	local input = io.read()
	if ParseCommand(input) == nil then
		--Send input
		client:send(input)	
	else
		--Show output of the clientside command
		print(ParseCommand(input))
	end
end
