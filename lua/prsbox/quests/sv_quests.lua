util.AddNetworkString("PRSBOX_QUESTS_requestUpdate")
util.AddNetworkString("PRSBOX_QUESTS_Update")

local SqlTableName_SessionQuests = "prsbox_quests_playerData"

local function InitSql()

end

local function sendQuestsUpdate( ply )
    net.Start("PRSBOX_QUESTS_Update", false)

    net.WriteString("")
    net.WriteString("")
    net.WriteString("")

    net.WriteBool(false)
    net.WriteBool(false)
    net.WriteBool(false)

    net.Send( ply )
end

function doesPlayerHaveQuests( ply )

end

net.Receive("PRSBOX_QUESTS_requestUpdate", updateQuests)

hook.Add( "PlayerConnect", "PRSBOX_QUESTS_SV_PlayerConnect", function( name, ip )
	
end )

