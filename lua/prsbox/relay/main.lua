if SERVER then 
	include("sv_config.lua")
	include("sv_msgSend.lua")
	include("sv_msgGet.lua")

	-- commands
	local files, _ = file.Find( 'commands/' .. "*", "LUA" )

	for num, fl in ipairs(files) do
		include("commands/" .. fl)
		print('[Discord] module ' .. fl .. ' added!')
	end
	--

	AddCSLuaFile('cl_config.lua')
	AddCSLuaFile('cl_msgReceive.lua')

	print( "----------------------\n" )
	print( "Prostir relay has been activated successfully!\n" )
	print( "----------------------" )
end

if CLIENT then 
	include('cl_config.lua')
	include('cl_msgReceive.lua')
end