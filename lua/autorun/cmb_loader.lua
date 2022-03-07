local dir = "cmb/"
if SERVER then
    local files = file.Find(dir .. "*", "LUA")
    for k, v in pairs(files) do
        if string.StartWith(v, "sv_") then
            include(dir .. v)
        elseif string.StartWith(v, "sh_") then
            AddCSLuaFile(dir .. v)
            include(dir .. v)
        elseif string.StartWith(v, "cl_") then
            AddCSLuaFile(dir .. v)
        end
    end

    -- resource.AddSingleFile("materials/map.png")
    AddCSLuaFile("imgui.lua")

    util.AddNetworkString("nextbtn_faces")
    util.AddNetworkString("prevbtn_faces")
    util.AddNetworkString("nextbtn_formations")
    util.AddNetworkString("prevbtn_formations")
    util.AddNetworkString("nextbtn_information")
    util.AddNetworkString("prevbtn_information")
    util.AddNetworkString("nextbtn_reginformation")
    util.AddNetworkString("prevbtn_reginformation")
    util.AddNetworkString("nextbtn_reginformation_ta")
    util.AddNetworkString("prevbtn_reginformation_ta")
    util.AddNetworkString("nextbtn_phrases")
    util.AddNetworkString("prevbtn_phrases")
    util.AddNetworkString("nextbtn")
    util.AddNetworkString("prevbtn")

elseif CLIENT then
    local files = file.Find(dir .. "*", "LUA")
    for k, v in pairs(files) do
        if string.StartWith(v, "sh_") || string.StartWith(v, "cl_") then
            include(dir .. v)
        end
    end
    print("[CMB] Clientside Loaded.")
end
print("[CMB] Loading complete.")