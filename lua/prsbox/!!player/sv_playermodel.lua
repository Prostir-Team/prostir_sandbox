
function CreateTable()
    sql.Query("CREATE DATABASE IF NOT EXISTS player_data")
	sql.Query("CREATE TABLE IF NOT EXISTS player_models (SteamID TEXT, ModelName INTEGER)")
end 

function RegistSkin(ply)

end

function ExistPlayerModel(ply)

end

function GetAllSkins()
    return {}
end