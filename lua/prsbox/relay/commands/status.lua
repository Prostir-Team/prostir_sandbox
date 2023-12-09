Discord.commands['status'] = function()
    local plys = player.GetCount() .. '/' .. game.MaxPlayers()
    local plyList = ''
    local plysTable = player.GetAll()

    if #plysTable > 0 then
        for num, ply in ipairs(plysTable) do
            plyList = plyList .. ply:Nick() .. '\n'
        end
    else plyList = 'Нікого ¯\\_(ツ)_/¯' end

    local form = {
        ['embeds'] = {{
            ['color'] = 5793266,
            ['title'] = GetHostName(),
            ['description'] = [[
**Підʼєднатися**: steam://connect/]] .. game.GetIPAddress() .. [[

**Карта зараз** - ]] .. game.GetMap() .. [[

**Гравців** - ]] .. plys .. [[
            ]],
            ['fields'] = {{
                ['name'] = 'Список гравців',
                ['value'] = plyList
            }}
        }}
    }

    Discord.send(form)
end

Discord.commands['ping'] = function()
    local form = {
        ['content'] = ':ping_pong: pong'
    }

    Discord.send(form)
end