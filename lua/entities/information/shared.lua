ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Information Board"
ENT.Category = "Induction Networks"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local PageCount = 3

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Page" )
end

function ENT:Initialize()
    self.Pages = PageCount
end

function ENT:OnRemove()
    timer.Destroy(self.PrintName)
end

if SERVER then
    net.Receive( "nextbtn_information", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "information" then
            if ply:GetPos():DistToSqr(ent:GetPos()) > 38000 then
                ply:ChatPrint("Not close enough to activate button!")
                return
            end
            ent:SetPage(ent:GetPage() + 1)
            if ent:GetPage() > PageCount then
                ent:SetPage(1)
            end
        end
    end )

    net.Receive( "prevbtn_information", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "information" then
            if ply:GetPos():DistToSqr(ent:GetPos()) > 38000 then
                ply:ChatPrint("Not close enough to activate button!")
                return
            end
            ent:SetPage(ent:GetPage() - 1)
            if ent:GetPage() < 1 then
                ent:SetPage(PageCount)
            end
        end
    end )
end

if CLIENT then
    local imgui = include("imgui.lua")
    function draw.Circle( x, y, radius, seg )
        local cir = {}

        table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
        for i = 0, seg do
            local a = math.rad( ( i / seg ) * -360 )
            table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
        end

        local a = math.rad( 0 ) -- This is needed for non absolute segment counts
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

        surface.DrawPoly( cir )
    end

    function draw.RotatedBox( x, y, w, h, ang, color )
        draw.NoTexture()
        surface.SetDrawColor( color or color_white )
        surface.DrawTexturedRectRotated( x, y, w, h, ang )
    end

    local start = SysTime()
    function ENT:DrawTranslucent()
        if imgui.Entity3D2D(self, Vector(-50, 0, 3), Angle(0, 90, 0), 0.15, 600, 450) then

            local boardwidth = 1024
            local boardheight = 650
            local page = self:GetPage()

            --[[Header]]--
            draw.RoundedBox(25, -boardwidth / 2, -35, boardwidth, 70, Color(0, 191, 255))
            draw.SimpleText(self.PrintName, imgui.xFont("!Roboto@40"), 0, -35, Color(255,255,255), TEXT_ALIGN_CENTER)

            --[[Main Body]]--
            draw.RoundedBox(25, -boardwidth / 2, 50, boardwidth, 650, Color(100, 100, 100, 255))
            draw.SimpleText(page .. "/" .. self.Pages, imgui.xFont("!Roboto@20"), 0, 670, Color(255,255,255), TEXT_ALIGN_CENTER)

            --[[Page Timeout]]--
            function PageTimeout()
                timer.Create(self.PrintName, 90, 1, function()
                    self:SetPage(1)
                end)
                if self:GetPage() == 1 then
                    timer.Destroy(self.PrintName)
                end
            end
                            
            --[[Page Controls]]--        
            if imgui.xTextButton("Next", "!Roboto@24", boardwidth / 2 - 230, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("nextbtn_information")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                -- PageTimeout()
            end

            if imgui.xTextButton("Previous", "!Roboto@24", -482, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("prevbtn_information")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                -- PageTimeout()
            end

            --[[ Set The Page Title ]]--
            function SetTitle(title)
                draw.SimpleText(title, imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
            end

            --[[ A Function to Add Certain Lines ]]--
            function Add(title, posX, posY, color, size, type, colorhover, url, page)
                local txtWide, txtHeight = surface.GetTextSize(title)
                if type == TEXT then
                    draw.SimpleText(title, imgui.xFont("!DermaDefaultBold@"..size), posX - (boardwidth / 2) + 20, 50 + posY, color, TEXT_ALIGN_CENTER)
                elseif type == URL then
                    if imgui.xTextButton(title, imgui.xFont("!DermaDefaultBold@"..size), posX - (boardwidth / 2) + 20, 50 + posY, surface.GetTextSize(name), 40, 0, color, colorhover, Color(0, 0, 255)) then
                        gui.OpenURL(url)
                        surface.PlaySound("buttons/button24.wav")
                    end
                elseif type == PAGE then
                    if imgui.xTextButton(title, imgui.xFont("!DermaDefaultBold@"..size), posX - (boardwidth / 2) + 20, 50 + posY, surface.GetTextSize(name), 40, 0, color, colorhover, Color(0, 0, 255)) then
                        self:SetPage(page)
                        surface.PlaySound("buttons/button24.wav")
                        PageTimeout()
                    end
                end
            end
                            
             --[[Pages]]--
             if page == 1 then
                SetTitle("Server Links")

                draw.SimpleText("MI Discord Server", imgui.xFont("!DermaDefaultBold@50"), 0, 75, Color(255,255,255), TEXT_ALIGN_CENTER)
                if imgui.xTextButton("discord.gg/efes9Yk", imgui.xFont("!DermaDefaultBold@40"), -150, 125, 300, 40, 0, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://discord.gg/efes9Yk" )
                end

                -- TA DISCORD
                draw.SimpleText("TA Discord Server", imgui.xFont("!DermaDefaultBold@50"), 0, 175, Color(255,255,255), TEXT_ALIGN_CENTER)
                if imgui.xTextButton("discord.gg/wUAMWpa", imgui.xFont("!DermaDefaultBold@40"), -150, 225, 325, 40, 0, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://discord.gg/wUAMWpa" )
                end

                -- FORUMS
                draw.SimpleText("Our Forums", imgui.xFont("!DermaDefaultBold@50"), 0, 275, Color(255,255,255), TEXT_ALIGN_CENTER)
                if imgui.xTextButton("inductionnetworks.com/forums", imgui.xFont("!DermaDefaultBold@40"), -225, 325, 450, 40, 0, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://inductionnetworks.com/forums" )
                end

                -- STORE
                draw.SimpleText("Our Store", imgui.xFont("!DermaDefaultBold@50"), 0, 375, Color(255,255,255), TEXT_ALIGN_CENTER)
                if imgui.xTextButton("inductionnetworks.com/store", imgui.xFont("!DermaDefaultBold@40"), -212, 425, 425, 40, 0, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://inductionnetworks.com/store" )
                end

                -- WORKSHOP COLLECTION
                draw.SimpleText("Our Workshop Collection", imgui.xFont("!DermaDefaultBold@50"), 0, 475, Color(255,255,255), TEXT_ALIGN_CENTER)
                if imgui.xTextButton("steamcommunity.com/sharedfiles/filedetails/?id=934795414", imgui.xFont("!DermaDefaultBold@40"), -525, 525, surface.GetTextSize("steamcommunity.com/sharedfiles/filedetails/?id=934795414"), 40, 0, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=934795414" )
                end

            end

            if page == 2 then
                SetTitle("Useful Binds")
                Add("This section contains some binds that you will need for your time on this server.", 512, 50, Color(255, 255, 255), 25, TEXT)
                Add("Replace '<key>' with the key you desire it to be bound to.", 512, 75, Color(255, 255, 255), 25, TEXT)
                -- Salute
                Add("Salute", 25, 175, Color(255, 255, 255), 30, TEXT)
                Add('bind <key> "say /me salutes"', 95, 205, Color(255, 255, 255), 20, TEXT)
                Add("  - This is for saluting in formations and saluting Commanding Officers (CO) around the base.", 390, 182.5, Color(255, 255, 255), 20, TEXT)
                -- Shows ID
                Add("Show ID", 30, 300, Color(255, 255, 255), 30, TEXT)
                Add('bind <key> "say /me shows ID"', 100, 335, Color(255, 255, 255), 20, TEXT)
                Add("  - This is for showing your ID to people, mainly when leaving base to RMP.", 345, 305.5, Color(255, 255, 255), 20, TEXT)
                -- How To
                if imgui.xTextButton("Bind Guide", imgui.xFont("!DermaDefaultBold@25"), -110, 620, 225, 40, 1, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=770442692" )
                    surface.PlaySound("buttons/button24.wav")
                end            
            end

            if page == 3 then
                -- Add(title, posX, posY, color, size, type, colorhover, url, page)
                SetTitle("Useful Commands")
                Add("This is a small section about the commands you can do on the server.", 512, 50, Color(255, 255, 255), 25, TEXT)
                -- Advert
                Add("Advert", 25, 125-25, Color(255, 255, 255), 30, TEXT)
                Add("/ad (your message)", 60, 160-25, Color(255, 255, 255), 20, TEXT)
                Add("  - These are open for all people to see, sometimes refered to as Open Comms.", 340, 132.5-25, Color(255, 255, 255), 20, TEXT)
                -- MI Comms
                Add("Military Comms", 70, 200-25, Color(255, 255, 255), 30, TEXT)
                Add("/mi (your message)", 60, 235-25, Color(255, 255, 255), 20, TEXT)
                Add("  - These are only seen by MI personnel and are used for main person-to-person communication.", 495, 207.5-25, Color(255, 255, 255), 20, TEXT)
                -- TA Comms
                Add("Taliban Comms", 70, 200 + 75-25, Color(255, 255, 255), 30, TEXT)
                Add("/ta (your message)", 60, 235 + 75-25, Color(255, 255, 255), 20, TEXT)
                Add("  - These are only seen by TA and are used for communicating to other TAs communication.", 480, 207.5 + 75-25, Color(255, 255, 255), 20, TEXT)
                -- ATC
                Add("ATC (Air Traffic Control) Comms", 165, 125 + 75 + 75 + 75-25, Color(255, 255, 255), 30, TEXT)
                Add("/atc (your message)", 60, 160 + 75 + 75 + 75-25, Color(255, 255, 255), 20, TEXT)
                Add("  - These are open for all people to see, used for handling aircrafts when ATC is online", 650, 132.5 + 75 + 75 + 75-25, Color(255, 255, 255), 20, TEXT)
                -- LOOC
                Add("Local Out of Character", 110, 125 + 75 + 75 + 75 + 75-25, Color(255, 255, 255), 30, TEXT)
                Add("/looc (your message)", 65, 160 + 75 + 75 + 75 + 75-25, Color(255, 255, 255), 20, TEXT)
                -- OOC
                Add("Out of Character", 80, 125 + 75 + 75 + 75 + 75 + 75-25, Color(255, 255, 255), 30, TEXT)
                Add("/ooc (your message)", 65, 160 + 75 + 75 + 75 + 75 + 75-25, Color(255, 255, 255), 20, TEXT)
            end

            
            imgui.End3D2D()
        end
    end

end