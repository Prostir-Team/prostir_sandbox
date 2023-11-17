util.AddNetworkString("PRSBOX.RusFilter")

local rus_pattern = "^[ыЫЪъЭэЁё]"

hook.Add("PlayerSay", "PRSBOX.RusFilter", function(sender, text)
    local res_start, res_end, res_str = string.find(text, rus_pattern, 0)
    --print(res_start, res_end, res_str)
    if not (res_start == nil or res_end == nil or res_str == nil) then return end
    net.Start("PRSBOX.RusFilter", true)
    net.Send(sender)
    MsgN(sender:GetName(), " used russian letters.")
    return false
end)