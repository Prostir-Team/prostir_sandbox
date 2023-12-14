local cfg = {}
cfg.doc_path = "data/infopanel_docs/"

util.AddNetworkString("PRSBOX.SendDocs")
util.AddNetworkString("PRSBOX.ReceiveDocs")

local documents = {}

local function loadDocs()
    MsgN("[INFOPANEL] Preloading infopanel documents to server...")
    local docfiles = file.Find(cfg.doc_path .. "*.md", "GAME")
    for _, v in ipairs(docfiles) do
        MsgN("[INFOPANEL] Reading ", v)
        documents[v] = file.Read(cfg.doc_path .. v, "GAME")
    end
    MsgN("[INFOPANEL] Done.")
end

local function receiveNet(len, ply)
    if (!IsValid(ply) or !ply:IsPlayer()) then return end

    local docname = net.ReadString()
    net.Start("PRSBOX.SendDocs")
    net.WriteString(documents[docname .. ".md"])
    net.Send(ply)
    MsgN("[INFOPANEL] Sent ", docname, " to player ", ply:Nick(), "(", ply:SteamID(), ")")
end

hook.Add("Initialize", "PRSBOX.Infopanel.LoadDocs", loadDocs)

net.Receive("PRSBOX.ReceiveDocs", receiveNet)
