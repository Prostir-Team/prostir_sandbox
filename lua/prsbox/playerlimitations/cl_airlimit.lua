local airlimit = 1

net.Receive("PRSBOX.Net.AirlimitSend", function()
    airlimit = math.Clamp(net.ReadUInt(8) / 50, 0, 1)
    --print(airlimit)
end)