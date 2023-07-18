local PLAYER = FindMetaTable("Player")

PRSBOXPLAYERMONEY = PRSBOXPLAYERMONEY or {}

if ( CLIENT ) then
    PRSBOXCOSTS = PRSBOXCOSTS or {}

    local mystid

    net.Receive( "PRSTR.Net.SendByTable", function( len, ply )
        local COMPRESSEDJSON_BYTES = net.ReadUInt( 16 )
        local COMPRESSEDJSON = net.ReadData( COMPRESSEDJSON_BYTES )

        local COMPRESSEDPLYMONEYJSON_BYTES = net.ReadUInt( 16 )
        local COMPRESSEDPLYMONEYJSON = net.ReadData( COMPRESSEDPLYMONEYJSON_BYTES )

        local DECOMPRESSEDJSON = util.Decompress( COMPRESSEDJSON ) // То ціни
        PRSBOXCOSTS = util.JSONToTable(DECOMPRESSEDJSON)
        
        DECOMPRESSEDJSON = util.Decompress( COMPRESSEDPLYMONEYJSON ) // А тут гроші гравців
        local MoneyTbl = util.JSONToTable(DECOMPRESSEDJSON)
        DECOMPRESSEDJSON = nil

        for sid, count in pairs(MoneyTbl) do
            PRSBOXPLAYERMONEY[sid] = tonumber(count)
        end
    end)

    local function OnMoneySumChanged(ply, old, new)
        if !ply then return end
        old = old or 0
    end

    local function SyncMoney()
        local ply = net.ReadEntity()
        local sid = net.ReadString()
        local count = net.ReadUInt( 19 )
        local old = PRSBOXPLAYERMONEY[sid]
        OnMoneySumChanged(ply, old, count)
        PRSBOXPLAYERMONEY[sid] = count

        if ply == LocalPlayer() then PRSBOXLOCALPLAYERMONEY = count hook.Run("PRSBOX.OnMoneyChanged", old, count) end
    end
    net.Receive("PRSTR.Net.ClMoneySync", SyncMoney)

    local function GetMyMoneyAmount()
        if !mystid then mystid = LocalPlayer():SteamID() end
        return PRSBOXPLAYERMONEY[mystid]
    end
    util.PRSBOX = util.PRSBOX or {}
    util.PRSBOX.GetMyMoneyAmount = GetMyMoneyAmount
end

function PLAYER:GetMoney()
    local sid = self:SteamID()
    return PRSBOXPLAYERMONEY[sid] or 0
end

function LoadMoney()
    local f = file.Open("cfg/money.cfg", "r", "GAME")
    if not f then return end

    local data = f:Read(f:Size())
    if data == "" then return end

    local listOfData = string.Split(data, "\n")
    local out = {}

    for k, line in ipairs(listOfData) do
        if string.Left(line, 2) == "//" or line == "" then continue end

        local money = string.Split(line, " ")

        out[money[1]] = money[2]
    end

    return out
end