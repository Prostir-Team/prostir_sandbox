require("chttp")

local tmpAvatars = {}

local IsValid = IsValid
local util_TableToJSON = util.TableToJSON
local http_Fetch = http.Fetch
local coroutine_resume = coroutine.resume
local coroutine_create = coroutine.create

function Discord.send(form) 
	if type( form ) ~= "table" then Error( '[Discord] invalid type!' ) return end

	local json = util_TableToJSON(form)

	CHTTP({
		["failed"] = function( msg )
			print( "[Discord] "..msg )
		end,
		["method"] = "POST",
		["url"] = Discord.webhook,
		["body"] = json,
		["type"] = "application/json"
	})
end



local function getUrl( String )
    local lines = {}

    for line in string.gmatch( String, "[^\r\n]+" ) do
        table.insert(lines, line)
    end

    local urls = {}

    for i, line in ipairs(lines) do
        if ( #urls > 2 ) then
            break
        end
        local startIndex, endIndex, str = string.find( line, "https://avatars.[%w-_%.%?%.:/%+=&]+")
        
        if ( startIndex ) then
            local str = string.sub( line, startIndex, endIndex )
            table.insert(urls, str )
        end
    end

    return urls[2]
end

local profileStr = "https://steamcommunity.com/profiles/%s?xml=1"
local timeMsg = "[Discord] took %s seconds"
local defaultUrl = "https://avatars.cloudflare.steamstatic.com/965ad7e55a47a84e59bdf0f5c19a985ba6c7778f_medium.jpg"

local function getAvatar(id, co)
    local time = SysTime()
    http.Fetch( string.format( profileStr, id ),
    function( body )       
        local url = getUrl( string.sub(body, 1, 600) )

        if ( not url ) then
            Error("[Discord] error getting avatar URL")
            url = defaultUrl
        end

        tmpAvatars[id] = url

        MsgAll( url )
        MsgAll( string.format( timeMsg, SysTime() - time ) )

        coroutine_resume(co)
    end,
    function (msg)
        Error("[Discord] error getting avatar ("..msg..")")
    end)
end

local function formMsg( ply, str )
	local id = tostring( ply:SteamID64() )

	local co = coroutine_create( function() 
		local form = {
			["username"] = ply:Nick(),
			["content"] = str,
			["avatar_url"] = tmpAvatars[id],
			["allowed_mentions"] = {
				["parse"] = {}
			},
		}
		
		Discord.send(form)
	end )

	if tmpAvatars[id] == nil then 
		getAvatar( id, co )
	else 
		coroutine_resume( co )
	end
end

local function playerConnect( ply )
	local form = {
		["username"] = Discord.hookname,
		["embeds"] = {{
			["title"] = "Гравець "..ply.name.." ("..ply.networkid..") підʼєднується...",
			["color"] = 16763979,
		}}
	}

	Discord.send(form)
end

local function plyFrstSpawn(ply)
	if IsValid(ply) then
		local form = {
			["username"] = Discord.hookname,
			["embeds"] = {{
				["title"] = "Гравець "..ply:Nick().." ("..ply:SteamID()..") приєднався!",
				["color"] = 4915018,
			}}
		}

		Discord.send(form)
	end
end

local function plyDisconnect(ply)
	if tmpAvatars[ply.networkid] then tmpAvatars[ply.networkid] = nil end

	local form = {
		["username"] = Discord.hookname,
		["embeds"] = {{
			["title"] = "Гравець "..ply.name.." ("..ply.networkid..") відʼєднався!",
			["color"] = 16730698,
		}}
	}

	Discord.send(form)
end

hook.Add("PlayerSay", "!!discord_sendmsg", formMsg)
gameevent.Listen( "player_connect" )
hook.Add("player_connect", "!!discord_plyConnect", playerConnect)
hook.Add("PlayerInitialSpawn", "!!discordPlyFrstSpawn", plyFrstSpawn)
gameevent.Listen( "player_disconnect" )
hook.Add("player_disconnect", "!!discord_onDisconnect", plyDisconnect)
hook.Add("Initialize", "!!discord_srvStarted", function() 
	local form = {
		["username"] = Discord.hookname,
		["embeds"] = {{
			["title"] = "Сервер запрацював!",
			["description"] = 'Карта зараз "' .. game.GetMap() .. '"',
			["color"] = 5793266
		}}
	}

	Discord.send(form)
	hook.Remove("Initialize", "!!discord_srvStarted")
end)