local stamina = 1

net.Receive("PRSBOX.Net.StaminaSend", function()
    stamina = math.Clamp(net.ReadUInt(8) / 150, 0, 1)
    --print(stamina)
end)