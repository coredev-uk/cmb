ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Taliban Information Board"
ENT.Category = "Induction Networks"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local PageCount = 2

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
    net.Receive( "nextbtn_reginformation_ta", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "reginformation_ta" then
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

    net.Receive( "prevbtn_reginformation_ta", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "reginformation_ta" then
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
            local page = self:GetPage()

            --[[Header]]--
            draw.RoundedBox(25, -boardwidth / 2, -35, boardwidth, 70, Color(91, 15, 0))
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

            -- imgui.xTextButton(Text, imgui.xFont(font), x, y, width, height, border width, colour, hover colour, press colour)

            --[[ Button Function ]]--
            function AddButton(name, posX, posY, color, colorhover, page)
                if imgui.xTextButton(name, imgui.xFont("!DermaDefaultBold@40"), posX, posY, surface.GetTextSize(name), 40, 0, color, colorhover, Color(0, 0, 255)) then
                    self:SetPage(page)
                    surface.PlaySound("buttons/button24.wav")
                    PageTimeout()
                end
            end

            --[[ Button Function ]]--
            function AddURLButton(name, posX, posY, color, colorhover, url)
                if imgui.xTextButton(name, imgui.xFont("!DermaDefaultBold@40"), posX, posY, surface.GetTextSize(name), 40, 0, color, colorhover, Color(0, 0, 255)) then
                    gui.OpenURL(url)
                    surface.PlaySound("buttons/button24.wav")
                    PageTimeout()
                end
            end

            --[[ AddLine ]]--
            function AddLine(title, pos, col)
                draw.SimpleText(title, imgui.xFont("!DermaDefaultBold@25"), 0, pos, col, TEXT_ALIGN_CENTER)
            end

            --[[ AddLine ]]--
            function AddQuestion(title, pos2, pos, col)
                draw.SimpleText(title, imgui.xFont("!DermaDefaultBold@40"), pos2, pos, col, TEXT_ALIGN_CENTER)
            end

            --[[ AddLine ]]--
            function AddQuestionAns(title, pos2, pos, col)
                draw.SimpleText(title, imgui.xFont("!DermaDefaultBold@25"), pos2, pos, col, TEXT_ALIGN_CENTER)
            end
                            
            --[[Page Controls]]--        
            if imgui.xTextButton("Next", "!Roboto@24", boardwidth / 2 - 230, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("nextbtn_reginformation_ta")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end

            if imgui.xTextButton("Previous", "!Roboto@24", -482, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("prevbtn_reginformation_ta")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end
                            
            --[[Pages]]--
            if page == 1 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("A Small Introduction", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                -- What is the Taliban
                AddQuestion("What is the Taliban?", -350, 100, Color(91, 15, 0))
                AddQuestionAns("The Taliban is a extremist group based in the middle east. They consist of the Russian Army (which you", -10, 150, Color(255, 255, 255))
                AddQuestionAns("can go into once you are trained), ISIS (ISIS Bomber Donator Job) and multiple other custom jobs which", 0, 175, Color(255, 255, 255))
                AddQuestionAns("you can join through asking the owner of the job.", -260, 200, Color(255, 255, 255))
                -- How does it work
                AddQuestion("How does the Taliban work?", -295, 250, Color(91, 15, 0))
                AddQuestionAns("The Taliban can participate in base attacks, missions, hostage taking, executions and more. Check the rules", 0, 300, Color(255, 255, 255))
                AddQuestionAns("to see the limitations of what you can do.", -310, 325, Color(255, 255, 255))
                -- What benefits do you get
                AddQuestion("What benefits do you get as Taliban?", -235, 375, Color(91, 15, 0))
                AddQuestionAns("As a TA (Taliban) you can join the ranks of RA (Russian Army) and you can drive tanks, fly helis, conduct", 0, 425, Color(255, 255, 255))
                AddQuestionAns("trainings and get some great weapons.", -310, 450, Color(255, 255, 255))


                -- Server Rules
                if imgui.xTextButton("Server Rules", imgui.xFont("!DermaDefaultBold@25"), 20, 620, 225, 40, 1, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://inductionnetworks.com/forums/thread/4" )
                    surface.PlaySound("buttons/button24.wav")
                end
                -- Discord Link
                if imgui.xTextButton("Join Discord", imgui.xFont("!DermaDefaultBold@25"), -250, 620, 225, 40, 1, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://discord.gg/wUAMWpa" )
                    surface.PlaySound("buttons/button24.wav")
                end
            end

            if page == 2 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("Russian Army Ranks", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                -- Enlisted
                AddLine("Private [PVT]", 100, Color(255, 255, 255))
                AddLine("Private First Class [PFC]", 125, Color(255, 255, 255))
                AddLine("Junior Sergeant [JSG]", 150, Color(255, 255, 255))
                -- NCO
                AddLine("Sergeant [SGT]", 200, Color(150, 150, 150))
                AddLine("Senior Sergeant [SSG]", 225, Color(150, 150, 150))
                AddLine("Sergeant Major [SGM]", 250, Color(150, 150, 150))
                AddLine("Ensign [ENS]", 275, Color(150, 150, 150))
                -- CO
                AddLine("Junior Lieutenant [JLT]", 325, Color(107, 191, 207))
                AddLine("Lieutenant [LT]", 350, Color(107, 191, 207))
                AddLine("Captain [CPT]", 375, Color(107, 191, 207))
                -- SCO
                AddLine("Major [MAJ]", 425, Color(28, 113, 224))
                AddLine("Lieutenant Colonel [LT COL]", 450, Color(28, 113, 224))
                AddLine("Colonel [COL]", 475, Color(28, 113, 224))
                AddLine("Brigadier [BRIG]", 500, Color(255, 223, 0))
                -- GEN
                AddLine("Major General [MAJ GEN]", 550, Color(255, 223, 0))
                AddLine("Lieutenant General [LT GEN]", 575, Color(255, 223, 0))
                AddLine("General [GEN]", 600, Color(255, 223, 0))
            end
            
            imgui.End3D2D()
        end
    end

end