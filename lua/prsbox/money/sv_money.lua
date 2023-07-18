local MONEYCVAR = CreateConVar("prsbox_economy", "1", FCVAR_ARCHIVE)
if !MONEYCVAR:GetBool() then print("Server economy disabled!!!") return end

print("Hello World from server money!!!")

util.AddNetworkString("PRSTR.Net.KillMoney")
util.AddNetworkString("PRSTR.Net.SendByTable")

local PLAYER = FindMetaTable("Player")

COSTTABLE = {
    -- CW 2.0
    ["cw_ak74"]             = 170,
    ["cw_akm_official"]     = 160,
    ["cw_ar15"]             = 165,
    ["cw_famasg2_official"] = 124,
    ["cw_scarh"]            = 129,
    ["cw_g3a3"]             = 128,
    ["cw_g36c"]             = 120,
    ["cw_mp5"]              = 100,
    ["cw_mp7_official"]     = 125,
    ["cw_deagle"]           = 70,
    ["cw_l115"]             = 200,
    ["cw_l85a2"]            = 115,
    ["cw_m249_official"]    = 200,
    ["cw_m3super90"]        = 130,
    ["cw_xm1014_official"]  = 150,
    ["cw_mr96"]             = 50,
    ["cw_toz34"]            = 80,
    ["cw_rpg7"]             = 300,
    ["cw_saiga12k_official"] = 96,
    ["cw_svd_official"]     = 210,
    ["cw_vss"]              = 115,
    ["cw_mac11"]            = 125,
    ["cw_shorty"]           = 40,
    ["cw_mp9_official"]     = 100,
    ["cw_m14"]              = 110,
    ["cw_ump45"]            = 75,

    ["cw_k98k"]             = 95,
    ["cw_enfield"]          = 89,
    ["cw_m1garand"]         = 94,
    ["cw_m1918a2"]          = 102, --BAR
    ["cw_m1919a6"]          = 203,
    ["cw_m1928a1"]          = 99,
    ["cw_mg42"]             = 260,
    ["cw_mp40"]             = 72,

    ["cw_acr"]              = 120,
    ["cw_hk416"]            = 110,
    ["cw_swat556"]          = 70,
    ["cw_b196"]             = 230,

    ["cw_tr09_mk18"]        = 140,
    ["cw_tr09_tar21"]       = 125,
    ["cw_tr09_qbz97"]       = 135,
    ["cw_tr09_auga3"]       = 130,

    ["cw_ammo_40mm"] = 120,
    ["cw_ammo_fraggrenades"] = 40,

    ["npc_manned_emplacement"] = 20,
/*
    ["tfa_ins2_thanez_cobra"] = 50,
    ["tfa_ins2_deagle"] = 80,
    ["tfa_ins2_ump45"] = 100,
    ["tfa_ins2_mp5k"] = 110,
    ["tfa_ins2_mp7"] = 120,
    ["tfa_ins2_m500"] = 150,
    ["tfa_ins2_l85a2"] = 135,
    ["tfa_ins2_moe_akm"] = 160,
    ["tfa_ins2_mk18"] = 140,
    ["tfa_ins2_famas"] = 170,
    ["tfa_ins2_sks"] = 180,
    ["tfa_ins2_remington_m24_sws"] = 210,
    ["tfa_ins2_rpg7_scoped"] = 500,
*/
    ["weapon_lfsmissilelauncher"] = 310,
    ["weapon_medkit"] = 70,
    ["weapon_simmines"] = 60,

    ["weapon_slam"] = 30,
    ["weapon_frag"] = 25,
    ["weapon_357"] = 50,
    ["weapon_smg1"] = 60,

    ["parachute_box"] = 30,

    -- LFS
    ["lunasflightschool_bf109"] = 325,
    ["lunasflightschool_spitfire"] = 310,
    ["lunasflightschool_combineheli"] = 290,
    ["lunasflightschool_p47d"] = 280,

    -- LVS
    ["lvs_plane_bf109"] = 220,
    ["lvs_plane_zero"] = 220,

    ["lvs_plane_p47"] = 250,
    ["lvs_plane_p51"] = 135,

    ["lvs_plane_spitfire"] = 100,
    ["lvs_plane_stuka"] = 120,

    ["lvs_helicopter_combine"] = 820,
    ["lvs_helicopter_combinegunship"] = 740,
    ["lvs_helicopter_cod_ah6"] = 780,

    -- Транспорт
    ["sim_fphys_chaos126p"] = 680,
    ["sim_fphys_hedgehog"] = 700,
    ["sim_fphys_ratmobile"] = 690,

    ["sim_fphys_conscriptapc"] = 80,

    ["sim_fphys_tank4"] = 1500,
    ["sim_fphys_tank3"] = 1200,
    ["sim_fphys_conscriptapc_armed"] = 500,
    ["sim_fphys_combineapc_armed"] = 300,
    ["sim_fphys_tank"] = 950,
    ["sim_fphys_tank2"] = 900,
    --[[
    ["sim_fphys_valentine_at"] = 900,
    ["sim_fphys_valentine_at_rp"] = 700,
    ["sim_fphys_valentine_mk_i"] = 950,
    ["sim_fphys_valentine_mk_i_rp"] = 750,
    ["sim_fphys_tank_churchill_mk_vii"] = 1100,
    ["sim_fphys_tank_churchill_mk_vii_rp"] = 900,
    ]]--

    ["sim_fphys_jeep_armed2"] = 120,
    ["sim_fphys_v8elite_armed2"] = 120,

    ["sim_fphys_jeep_armed"] = 100,
    ["sim_fphys_v8elite_armed"] = 100,
    ["avx_technical_mlrs"]      = 350,

    ["lunasflightschool_bayraktartb2"] = 700,
    ["merydianlfs_ah1z"] = 300 * 3,
    ["merydianlfs_z10w"] = 350 * 3,
    ["merydianlfs_fa18f"] = 500 * 3,
    ["merydianlfs_mi28n"] = 400 * 3,
    ["merydianlfs_su35"] = 550 * 1.5,

    -- gaysrich tanks
    ["gred_simfphys_flammpanzeriii"] = 700,
    ["gred_simfphys_m56"] = 450,
    ["gred_simfphys_panzeriiim"] = 500,
    ["gred_simfphys_panzerivd"] = 500,
    ["gred_simfphys_panzerivf1"] = 470,
    ["gred_simfphys_panzerivf2"] = 600,
    ["gred_simfphys_flakpanzeriv_wirbelwind"] = 220,
    ["gred_simfphys_flakpanzeriv_ostwind_2"] = 250,
    ["gred_simfphys_flakpanzeriv_ostwind"] = 230,
    ["gred_simfphys_flakpanzer38t"] = 150
}

local UNREFUNDABLE = {
    ["cw_ammo_fraggrenades"] = true,
    ["cw_ammo_40mm"] = true
}

for class, val in pairs(COSTTABLE) do
    COSTTABLE[class] = math.ceil( val )
end

local JSONCOSTTABLE = util.TableToJSON(COSTTABLE)
local COMPRESSEDJSON = util.Compress( JSONCOSTTABLE )
local COMPRESSEDJSON_BYTES = #COMPRESSEDJSON 
//print("COMPRESSEDJSON_BYTES: ", COMPRESSEDJSON_BYTES) //COMPRESSEDJSON_BYTES:    362 (9-bit)

util.AddNetworkString("PRSTR.Net.ClMoneySync")
util.AddNetworkString("PRSBOX.SendMoney")
util.AddNetworkString("PRSBOX.DropMoney")

function PLAYER:MoneyNotify(count)
    net.Start("PRSTR.Net.KillMoney")
        net.WriteInt(count, 19)
    net.Send(self)
end

local FolderDir = "prsbox_money"
local MoneyLogFile = FolderDir .. "/%s.txt"
local FormatString = "%s    %s <%s>    %s -> %s"
local HoursFormat = "%H:%M:%S"
local DateFormat = "%m-%d-%y"

local osdate = os.date
local ostime = os.time
local stringformat = string.format
local Append = file.Append
local Exist = file.Exists


local DataDir = "DATA"
local function LogMoneyChange( Str )
    local LogFile = stringformat( MoneyLogFile, osdate( DateFormat, ostime() ) )

    if not Exist(FolderDir, DataDir) then
        file.CreateDir(FolderDir)
    end
    if not Exist( LogFile, DataDir ) then
        file.Write( LogFile, "" )
    end
    Append(LogFile, Str .. "\n")
end

function PLAYER:SetMoney(count, noClSync)
    count = math.Clamp(count, 0, 400000)
    local sid = self:SteamID()

    if !PRSBOXPLAYERMONEY[sid] then
        PRSBOXPLAYERMONEY[sid] = GetSavedMoneyFileSid( sid ) or 0
    else
        LogMoneyChange( stringformat(FormatString, osdate(HoursFormat, ostime()), self:Nick(), sid, PRSBOXPLAYERMONEY[sid], count) )
        PRSBOXPLAYERMONEY[sid] = tonumber(count)
    end

    util.PRSBOX:SaveMoneyFile(self, count)

    if noClSync then return end

    net.Start("PRSTR.Net.ClMoneySync")
        net.WriteEntity( self )
        net.WriteString( self:SteamID() )
        net.WriteUInt( count, 19 )
    net.Broadcast()
end

function PLAYER:AddMoney(count)
    local money = self:GetMoney()
    self:SetMoney(money + count)
end

function PLAYER:SubstractMoney(count)
    local money = self:GetMoney()
    self:SetMoney(money - count)
end

function PLAYER:TransferTo( ply, amount )
    if !IsValid(ply) then return end
    if amount > self:GetMoney() then return end
    if amount < 1 then return end
    self:SubstractMoney(amount)
    ply:AddMoney(amount)
    return true
end
local MONEYTRANSFERCD, PlaySoundTimes = {}, {}

net.Receive("PRSBOX.SendMoney", function( len, plya )
    local plyb = net.ReadEntity()
    local amount = net.ReadUInt( 19 )

    local t = MONEYTRANSFERCD[plya]
    if t then 
        if t > CurTime() then
            plya:ChatPrint( "Зачекайте секунду" )
            plya:PlayCLSound("buttons/combine_button7.wav")
            return
        end
    end

    if plya:TransferTo( plyb, amount ) then
        plya:ChatPrint( string.format("Ви передали %s %s ₴", plyb:Nick(), string.Comma(amount)) )
        plya:PlayCLSound("buttons/button24.wav")

        plyb:ChatPrint( string.format("Ви отримали %s ₴ від %s", string.Comma(amount), plya:Nick() ) )
        if ( (PlaySoundTimes[plyb] or 0) < CurTime() ) then
            plyb:PlayCLSound("buttons/button24.wav")
            PlaySoundTimes[plyb] = CurTime() + 60
        end
    else
        plya:ChatPrint( "ПОМИЛКА ПЕРЕДАЧІ" )
        plya:PlayCLSound("buttons/combine_button7.wav")
    end
    MONEYTRANSFERCD[plya] = CurTime() + 1
end)

local angoff = Angle( -90, 0, -180 )

local function CreateDropedMoney( amn, owner )
    local ent = ents.Create( "prsbox_moneydrop" )

    local trace = util.TraceLine( {
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 180,
        filter = owner
    } )

    ent:SetPos( trace.HitPos + (trace.HitNormal * 8) )
    local ang = trace.HitNormal:Angle()
    ang:Add( angoff )
    ent:SetAngles( ang )
    ent:SetOwner( owner )
    ent:SetNWString( "Owner", "World" )
    ent:Spawn()

    ent:SetMoneyAmount( amn )
    owner:SubstractMoney( amn )

    return IsValid( ent )
end

net.Receive( "PRSBOX.DropMoney", function( len, ply )
    local amount = net.ReadUInt( 19 )
    local t = MONEYTRANSFERCD[ply]

    if t then 
        if t > CurTime() then
            ply:ChatPrint( "Зачекайте секунду" )
            ply:PlayCLSound("buttons/combine_button7.wav")
            return
        end
    end

    if ( CreateDropedMoney( amount, ply ) ) then
        ply:ChatPrint( string.format("Ви виклали %s ₴", string.Comma(amount)) )
        ply:PlayCLSound( "prsbox/inv_throw.wav" )
    else
        plya:ChatPrint( "Відбулася помилка..." )
        plya:PlayCLSound("buttons/combine_button7.wav")
    end

    MONEYTRANSFERCD[ply] = CurTime() + 1
end)

function CreateTable()
    sql.Query( "CREATE TABLE IF NOT EXISTS player_data ( SteamID TEXT, Money INTEGER );" )
end

CreateTable()

function SaveMoneyFileSID( sid, Money )
    local data = sql.Query( "SELECT * FROM player_data WHERE SteamID = " .. sql.SQLStr( sid ) .. ";")
    if ( data ) then
        sql.Query( "UPDATE player_data SET Money = " .. Money .. " WHERE SteamID = " .. sql.SQLStr( sid ) .. ";" )
    else
        sql.Query( "INSERT INTO player_data ( SteamID, Money ) VALUES( " .. sql.SQLStr( sid ) .. ", " .. Money .. " );" )
    end
end

function WipeMoneySID()
    local data = sql.Query( "SELECT * FROM player_data")
    for _,t in ipairs(data) do
        local ply = player.GetBySteamID( t.SteamID )
        if IsValid(ply) then
            ply:SetMoney(0)
        else
            sql.Query( "UPDATE player_data SET Money = 0 WHERE SteamID = " .. sql.SQLStr( t.SteamID ) .. ";" )
        end
    end
end

function SaveMoneyFile( ply, Money )
    SaveMoneyFileSID( ply:SteamID(), Money )
end

function GetSavedMoneyFileSid( sid )
    local val = sql.QueryValue( "SELECT Money FROM player_data WHERE SteamID = " .. sql.SQLStr( sid ) .. ";" )
    if !val then SaveMoneyFileSID( sid, 0 ) return 0 end
    return tonumber(val) or 0
end


function GetSavedMoneyFile( ply )
    local val = GetSavedMoneyFileSid( ply:SteamID() )
    return tonumber(val)
end

util.PRSBOX = util.PRSBOX or {}
function util.PRSBOX:SaveMoneyFile(ply, Amount) SaveMoneyFile(ply, Amount) end
function util.PRSBOX:GetSavedMoneyFile(ply) GetSavedMoneyFile(ply) end

local function SendCostTable(ply)
    if ply:IsBot() then return end

    local JSONMONEYTABLE = util.TableToJSON(PRSBOXPLAYERMONEY)
    local MONEYCOMPRESSEDJSON = util.Compress( JSONMONEYTABLE )
    local MONEYCOMPRESSEDJSON_BYTES = #MONEYCOMPRESSEDJSON  

    ply:SetMoney(GetSavedMoneyFile(ply))

    net.Start( "PRSTR.Net.SendByTable" )
        net.WriteUInt( COMPRESSEDJSON_BYTES, 16 )
        net.WriteData( COMPRESSEDJSON, COMPRESSEDJSON_BYTES )

        net.WriteUInt( MONEYCOMPRESSEDJSON_BYTES, 16 ) 
        net.WriteData( MONEYCOMPRESSEDJSON, MONEYCOMPRESSEDJSON_BYTES )
    net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "PRSTR.GM.PlayerInitialSpawn", SendCostTable) //Кастомний хук!!!

hook.Remove("CanTool", "PRSBOX.BlockCreatorTool")

function GetCost(class)
    return COSTTABLE[class] or nil
end

local function Buyfunc( ply, class, catr )
    if ( catr and ply.PRSBOXENTCATEGORYCD and ply.PRSBOXENTCATEGORYCD[catr] and (ply.PRSBOXENTCATEGORYCD[catr] > CurTime()) ) then
        return false 
    end

    local cost = GetCost(class)
    if cost then
        local money = ply:GetMoney()
        if cost <= money then
            ply:SubstractMoney(cost)
            -- ply:PlayCLSound('buttons/weapon_confirm.wav')
            return true
        else
            return false 
        end
    end
    return true
end

local function PlayerSpawnSENT( ply, ent )
    local e = scripted_ents.Get( ent )
    if !Buyfunc( ply, ent, e and e.Category or nil ) then return false end
end

-- xy. то щоб воно останім запускалось

hook.Add("PlayerSpawnSENT", "xy.PRSBOX.BuyHook", PlayerSpawnSENT)

local function playerhaveweapon(ply, class)
    local tbl = ply:GetWeapons()
    for i,v in ipairs(tbl) do
        if v:GetClass() == class then
            return true
        end
    end
    return false
end

local function PlayerGiveSWEP(ply, class, swep)
    if playerhaveweapon(ply, class) then return end
    if !Buyfunc( ply, class ) then return false end
end

hook.Add("PlayerGiveSWEP", "xy.PRSBOX.BuyHook", PlayerGiveSWEP)

local function PlayerSpawnVehicle(ply, model, name, table)
    if !ply:Alive() then return false end
    if ply.PRSBOXVEHST then
        local t = ply.PRSBOXVEHST[name]
        if t then
            if t > CurTime() then 
                return false 
            end
        end
    end
    if !Buyfunc( ply, name ) then return false end
end

hook.Remove("PlayerSpawnVehicle", "xy.PRSBOX.BuyHook" )

hook.Add("PlayerSpawnVehicle", "PRSBOX.BuyHook", PlayerSpawnVehicle)

local weaponammo = {
    ["weapon_357"] =    {"357", 6},
    ["weapon_pistol"] = {"Pistol", 18},
    ["weapon_frag"] =   {"Grenade", 1},
    ["weapon_slam"] =   {"slam", 3},
    ["weapon_shotgun"] ={"Buckshot", 6},
    ["weapon_smg1"] =   {"SMG1", 45},
    ["weapon_ar2"] =    {"AR2", 30}
}

local weaponsGet = weapons.Get

local function PlayerSpawnSWEP( ply, class, swep )
    if !ply:Alive() then return false end
    local wepc = ply:GetActiveWeapon()

    if wepc:GetClass() == "gmod_tool" then 
        if ply:GetTool().Mode == "creator" then 
            if Buyfunc( ply, class ) then return true end
        end 
    end

    local weptbl = ply:GetWeapons()
    local stored = weaponsGet(class)

    if !stored then
        local ammot = weaponammo[class]
        if !ammot then return end
        for i,wep in ipairs(weptbl) do
            if wep:GetClass() != class then continue end
            ply:GiveAmmo( ammot[2], ammot[1] )
            return false
        end
    end

    for i,wep in ipairs(weptbl) do
        if wep:GetClass() != class then continue end
        ply:GiveAmmo( stored.Primary.DefaultClip, stored.Primary.Ammo )
        return false
    end

    return PlayerGiveSWEP(ply, class, swep)
end

hook.Add("PlayerSpawnSWEP", "xy.PRSBOX.Buy", PlayerSpawnSWEP)

util.AddNetworkString("PRSBOX.KillNotify")

function PLAYER:SendKillNotf( sum, str )
    self:AddMoney(sum)
    net.Start("PRSBOX.KillNotify")
        net.WriteBool( sum < 0 )
        local points = net.WriteUInt( math.abs(sum), 19 )
        local b = false

        if isstring( str ) then
            b = true
        end

        net.WriteBool( b )

        if b then
            str = net.WriteString( str )
        else
            str = net.WriteUInt( str, 4 )
        end

    net.Send(self)
end

/*
local ptbl = {
    [1] = "Ворога вбито",
    [2] = "Хедшот",
    [3] = "Вбито в ближньому бою",
    [4] = "Вбивсто з літаку",
    [5] = "Ворожу техніку знищено",
    [6] = "Останьою кулею",
    [7] = "Вбивсто технікою",
    [8] = "Помста",
    [9] = "Домінація",
    [10] = "Вбивсто пропом",
    [11] = "Вбито беззбройного гравця",
    [12] = "Вбито AKF гравця"
}
//Bit   Num
//4     15
//5     31
*/

local meleewepclass = {
    ["weapon_fists"] = true,
    ["weapon_crowbar"] = true,
    ["weapon_stunstick"] = true
}

local unarm     =   CreateConVar("prsbox_unarm_kill",   "1", FCVAR_ARCHIVE)
local afkkill   =   CreateConVar("prsbox_afk_kill",     "1", FCVAR_ARCHIVE)
local basefragsum = CreateConVar("prsbox_economy_basefragsum", "70", FCVAR_ARCHIVE)

local function Destroyed( Vehicle, Gib )
    local attacker = Vehicle.LastAttacker
    if ( not IsValid(attacker) ) then return end
    if Vehicle.PRSBOXPAID then return end
    Vehicle.PRSBOXPAID = true
    local cost = COSTTABLE[ Vehicle.Class or Vehicle.VehicleName ]
    if ( not cost ) then return end
    attacker:SendKillNotf( math.min( basefragsum:GetInt() * 3, cost ), 5)
end

hook.Add( "simfphysOnDestroyed", "PRSBOX.Destroyed", Destroyed )

local function TakeDmg( ent, dmg, took )
    if not ent.FinalAttacker then return end
    if not ent.FinalAttacker:IsPlayer() then return end
    if ent.PRSBOXPAID then return end
    ent.PRSBOXPAID = true
    local cost = COSTTABLE[ ent.ClassName or ent:GetClass() ]
    if ( not cost ) then return end
    ent.FinalAttacker:SendKillNotf( math.min( basefragsum:GetInt() * 3, cost ), 5)
end

hook.Add("PostEntityTakeDamage", "PRSBOX.Money.DMG", TakeDmg)

hook.Add("DoPlayerDeath", "PRSBOX.GM.PlayerDeathMoney", function (ply, attacker, dmginfo)
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if ply == attacker then return end

    if ( ply.jail ) then return end

    local basesum = basefragsum:GetInt()
    local dmg, inflictor, damagetype, hitgroup = dmginfo:GetDamage(), dmginfo:GetInflictor(), dmginfo:GetDamageType(), ply:LastHitGroup()

    if ply:IsAFK() and afkkill:GetBool() then attacker:SendKillNotf( -basesum, 12) attacker:AddFrags( -2 ) return end

    local attackerSid = attacker:SteamID()

    if ply:IsUnarmed() and unarm:GetBool() then 
        if not (dmginfo:IsDamageType(DMG_POISON) or dmginfo:IsDamageType(DMG_RADIATION)) then
            attacker:SendKillNotf( -25, 11 ) --attacker:AddFrags( -2 ) 
            return 
        end  
    end

    if ( dmginfo:IsDamageType(DMG_POISON) or dmginfo:IsDamageType(DMG_RADIATION) ) then
        attacker:SendKillNotf(basesum * .8, 1) return
    end

    local inflictorclass = inflictor:GetClass()

    if( inflictorclass == "player" ) then
        inflictorclass = attacker:GetActiveWeapon():GetClass()
    end

    if meleewepclass[inflictorclass] then
        attacker:SendKillNotf(basesum * 3, 3) return
    end

    if ( inflictorclass == "npc_grenade_bugbait" ) then
        ACHIEVEMENTS:AddScore( attackerSid, "ShitDarter", 1 )
        attacker:SendKillNotf( basesum * 3.4 , 8 ) return
    end

    if dmginfo:IsDamageType(1) and !inflictor.POwner then
        attacker:SendKillNotf(basesum * 1.5, 10) return
    end
    
    if ( ply.CWPhysBulletTraceEnt ) then
        if ( dmginfo:IsDamageType( 1073741824 ) ) then --DMG_SNIPER
            if ( ply.CWPhysBulletTraceEnt != ply ) then
                ACHIEVEMENTS:AddScore( attackerSid, "NeuronActivation", 1 )
            end
        end
        --[[
        local FirstTraceEnt = ply.CWPhysBulletTraceEnt
        local BulletTravelDist = ply.CWPhysBulletDist 
        local BulletTravelTime = math.max( 0, CurTime() - ply.CWPhysBulletTime )

        print( "FirstTraceEnt", FirstTraceEnt )
        print( "BulletTravelDist", BulletTravelDist )
        print( "BulletTravelTime", BulletTravelTime )
        ]]--
    end
    
    if dmginfo:IsBulletDamage() then
        if hitgroup == HITGROUP_HEAD then
            attacker:SendKillNotf(basesum * 2, 2) return
        else
            attacker:SendKillNotf(basesum, 1) return
        end
    end

    attacker:SendKillNotf(basesum, 1) return
end)

local function DoRefund(ply, class, fc)
    fc = fc || false
    if ( UNREFUNDABLE[class] ) then return end
    local cost = GetCost(class)
    if cost then
        if !fc then
            ply:AddMoney(cost * 0.9)
            //print("Refunds: ", ply, COSTTABLE[class] * 0.9)
        else
            ply:AddMoney(cost)
            //print("Refunds: ", ply, COSTTABLE[class])
        end
    end
end

hook.Add("PostUndo", "PRSBOX.Refunds", function(undo, count)
    local ply, Names, entt  = undo.Owner, undo.Name, undo.Entities 
    if !entt then return end
    for i,ent in ipairs(entt) do
        if !IsValid(ent) then continue end
        local class = ent:GetClass()
        if ent.IsSimfphyscar then
            local MaxHealth = ent:GetMaxHealth()
            local Health = ent:GetCurHealth()
            if Health > (MaxHealth * .7) then
                local t = ent:GetTable()
                local cls = t.Class or t.VehicleName
                DoRefund(ply, cls, Health == MaxHealth)
            end
            continue
        elseif ent.LFS then
            local MaxHealth = ent:GetMaxHP()
            local Health = ent:GetHP()
            if Health > (MaxHealth * .7) then
                DoRefund(ply, class, Health == MaxHealth)
            end
            continue
        end
        if ent:IsWeapon() or ent:IsScripted() then
            DoRefund(ply, class)
            continue
        end
    end
end)

concommand.Add( "GetPoor", function( ply, cmd, args )
    if !ply:IsSuperAdmin() then return end
    ply:SetMoney(0)
end )