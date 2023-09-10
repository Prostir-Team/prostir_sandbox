print("SV teams")

---
--- Global team table
---

TEAMS = {}
TEAMS.Teams = {}

function TEAMS:TeamExists(ownerid)
    if not isstring(ownerid) then return end
    if table.IsEmpty(TEAM) then return end

    return table.HasValue(table.GetKeys(TEAM), ownerid)
end

function TEAMS:AddTeam(ownerid)
    if self:TeamExists() then return end

    local t = {}
    t.Money = 0
    t.Players = {}
    t.Level = 0

    self.Teams[ownerid] = t
end

function TEAMS:GetMembers(ownerid)
    if not self.TeamExists(ownerid) then return end

    return self.Teams[ownerid]
end

function TEAMS:RemoveTeam(ownerid)

end