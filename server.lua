--LuaMMO server by Polarity
--Connect to this on port 2220 using telnet to play the game.

--Create our info function. Does formatting for us automatically.
function info(message)
	print("LuaMMO: "..message)
end

--string.explode, just like in PHP
function string.explode(d,p)
	local t,ll,l
	t={}
	ll=0
	while true do
		l=string.find(p,d,ll+1,true) -- find the next d in the string
		if l~=nil then -- if "not not" found then..
			table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
			ll=l+1 -- save just after where we found it for searching next time.
		else
			table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
			break -- Break at end, as it should be, according to the lua manual.
		end
	end
	return t
end

--Say what we're doing, loading the threading library
info("Loading threading library.")

--Load copas
require("copas")

--Say what we're doing, loading the socket library
info("Loading socket library.")

--Load the socket library
require("socket")

--Create the user table
users = {}

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

--Shortcut to giving the user a command prompt style thing
function shellPrefix(connection)
	connection:send("LuaMMO:")
end

--Can you say connection coroutine?
function NewConnection(connection)
	conn = copas.wrap(conn)
	local servertime = os.date("%I:%M%p")
	conn:send("Welcome to LuaMMO.\r\n")
	conn:send("Server time is "..servertime.."\r\n")
	conn:send("Please enter your login details for LuaMMO\r\n")
	shellPrefix(conn)
	info("New client connected.")
    -- continue reading from client and writing to client here
end
copas.addserver(socket.bind("127.0.0.1", 2220), NewConnection)
copas.loop()

--Loop forever
while true do
	local reading,writing,err = socket.select(recvt,nil)
	for _, server in ipairs(reading) do
		local message = copas.receieve(server,"*l")
		if message == "QUIT" then
			info("Client disconnected.")
			server:close()
		elseif message == "LOGIN" then
			local args = string.explode(" ",message)
			if args[2] and args[3] then
				local username = args[2]
				local password = args[3]
				if users[username] then
					if users[username].password == password then
						server:send("LuaMMO: Logged in! Welcome.\r\n")
						info("User "..username.." has logged in.")
					else
						server:send("LuaMMO: Incorrect password.\r\n")
						info("Failed login attempt on username "..username.." from "..server:getpeername()..".")
					end
				else
					server:send("LuaMMO: Incorrect username.\r\n")
					info("User tried to login with the non-existant username "..username..".")
				end
			else
				server:send("LuaMMO: Incorrect syntax. USAGE: LOGIN Username Password\r\n")
			end
		else
			local response = ParseCommand(message)
			if response == nil then response = "LuaMMO: Invalid command." end
			server:send(response.."\r\n")
		end
		shellPrefix(server)
	end
end
