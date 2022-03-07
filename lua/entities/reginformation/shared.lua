ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Military Information Board"
ENT.Category = "Induction Networks"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local PageCount = 6

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
    net.Receive( "nextbtn_reginformation", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "reginformation" then
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

    net.Receive( "prevbtn_reginformation", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "reginformation" then
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
            draw.RoundedBox(25, -boardwidth / 2, -35, boardwidth, 70, Color(42, 42, 42))
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
                            
            --[[Page Controls]]--        
            if imgui.xTextButton("Next", "!Roboto@24", boardwidth / 2 - 230, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("nextbtn_reginformation")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end

            if imgui.xTextButton("Previous", "!Roboto@24", -482, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("prevbtn_reginformation")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end
                            
            --[[Pages]]--
            if page == 1 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("Military Regiments", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                AddButton("Royal Military Police - RMP", -200, 125, Color(204, 204, 204), Color(150, 150, 150), 2)
                AddButton("The Royal Marines - TRM", -175, 175, Color(78, 122, 215), Color(105, 150, 250), 3)
                AddButton("Royal Air Force - RAF", -150, 225, Color(107, 192, 208), Color(72, 167, 160), 4)
                AddButton("Royal Armoured Corps - RAC", -200, 275, Color(255, 0, 0), Color(150, 0, 0), 2)
                AddButton("Special Air Service - SAS", -175, 325, Color(0, 0, 0), Color(55, 55, 55), 5)
                AddButton("Special Reconnaissance Regiment - SRR", -275, 375, Color(107, 171, 79), Color(127, 181, 99), 2)
                AddButton("Ground Command - GC", -175, 425, Color(0, 25, 128), Color(0, 75, 170), 6)
                -- Server Rules
                if imgui.xTextButton("Server Rules", imgui.xFont("!DermaDefaultBold@25"), 20, 620, 225, 40, 1, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://inductionnetworks.com/forums/thread/4" )
                    surface.PlaySound("buttons/button24.wav")
                end
                -- Discord Link
                if imgui.xTextButton("Join Discord", imgui.xFont("!DermaDefaultBold@25"), -250, 620, 225, 40, 1, Color(66, 135, 245), Color(33, 100, 220), Color(0, 0, 255)) then
                    gui.OpenURL( "https://discord.gg/efes9Yk" )
                    surface.PlaySound("buttons/button24.wav")
                end
            end

            if page == 2 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("Military Ranks", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                -- Enlisted
                AddLine("Private [PTE]", 100, Color(255, 255, 255))
                AddLine("Lance Corporal [LCPL]", 125, Color(255, 255, 255))
                AddLine("Corporal [CPL]", 150, Color(255, 255, 255))
                -- NCO
                AddLine("Sergeant [SGT]", 200, Color(150, 150, 150))
                AddLine("Colour Sergeant [CSGT]", 225, Color(150, 150, 150))
                AddLine("Warrant Officer 2 [WO2]", 250, Color(150, 150, 150))
                AddLine("Warrant Officer 1 [WO1]", 275, Color(150, 150, 150))
                -- CO
                AddLine("Second Lieutenant [2LT]", 325, Color(107, 191, 207))
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

            if page == 3 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("The Royal Marines Ranks", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                -- Enlisted
                AddLine("Marine [MRN - PTE]", 100, Color(255, 255, 255))
                AddLine("Lance Corporal [LCPL]", 125, Color(255, 255, 255))
                AddLine("Corporal [CPL]", 150, Color(255, 255, 255))
                -- NCO
                AddLine("Sergeant [SGT]", 200, Color(150, 150, 150))
                AddLine("Colour Sergeant [CSGT]", 225, Color(150, 150, 150))
                AddLine("Warrant Officer Class 2 [WOC2 - WO2]", 250, Color(150, 150, 150))
                AddLine("Warrant Officer Class 1 [WOC1 - WO1]", 275, Color(150, 150, 150))
                -- CO
                AddLine("Second Lieutenant [2LT]", 325, Color(107, 191, 207))
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

            if page == 4 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("Royal Air Force Ranks", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                -- Enlisted
                AddLine("Leading Aircraftman [LAC - PTE]", 100, Color(255, 255, 255))
                AddLine("Senior Aircraftman [SAC - PTE]", 125, Color(255, 255, 255))
                AddLine("Lance Corporal [LCPL]", 150, Color(255, 255, 255))
                AddLine("Corporal [CPL]", 175, Color(255, 255, 255))
                -- NCO
                AddLine("Sergeant [SGT]", 225, Color(150, 150, 150))
                AddLine("Flight Sergeant [FS - CSGT]", 250, Color(150, 150, 150))
                AddLine("Master Aircrew [MACR - WO1]", 275, Color(150, 150, 150))
                -- CO
                AddLine("Pilot Officer [PLT OFF - 2LT]", 325, Color(107, 191, 207))
                AddLine("Flying Officer [FG OFF - LT]", 350, Color(107, 191, 207))
                AddLine("Flight Lieutenant [FLT LT - CPT]", 375, Color(107, 191, 207))
                -- SCO
                AddLine("Squadron Leader [SQN LDR - MJR]", 425, Color(28, 113, 224))
                AddLine("Wing Commander [WG CDR - LT COL]", 450, Color(28, 113, 224))
                AddLine("Group Captain [GP CAPT - COL]", 475, Color(28, 113, 224))
                AddLine("Air Commodore [AIR CDRE - BRIG]", 500, Color(255, 223, 0))
                -- GEN
                AddLine("Air Vice Marshal [AVM - MAJ GEN]", 550, Color(255, 223, 0))
                AddLine("Air Marshal [AM - LT GEN]", 575, Color(255, 223, 0))
                AddLine("Air Chief Marshal [ACM - GEN]", 600, Color(255, 223, 0))
            end

            if page == 5 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("Special Air Service Ranks", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                -- Enlisted
                AddLine("Corporal [CPL]", 100, Color(255, 255, 255))
                -- NCO
                AddLine("Sergeant [SGT]", 150, Color(150, 150, 150))
                AddLine("Staff Sergeant [SSGT - CSGT]", 175, Color(150, 150, 150))
                AddLine("Squadron Sergeant Major [SSM - WO2]", 200, Color(150, 150, 150))
                AddLine("Squadron Quarter Master Sergeant [SQMS - WO2]", 225, Color(150, 150, 150))
                AddLine("Regimental Sergeant Major [RSM - WO1]", 250, Color(150, 150, 150))
                -- CO
                AddLine("Second Lieutenant [2LT]", 300, Color(107, 191, 207))
                AddLine("Lieutenant [LT]", 325, Color(107, 191, 207))
                AddLine("Captain [CPT]", 350, Color(107, 191, 207))
                -- SCO
                AddLine("Major [MAJ]", 400, Color(28, 113, 224))
                AddLine("Lieutenant Colonel [LT COL]", 425, Color(28, 113, 224))
                AddLine("Colonel [COL]", 450, Color(28, 113, 224))
                AddLine("Brigadier [BRIG]", 475, Color(255, 223, 0))
                -- GEN
                AddLine("Major General [MAJ GEN]", 525, Color(255, 223, 0))
                AddLine("Lieutenant General [LT GEN]", 550, Color(255, 223, 0))
                AddLine("General [GEN]", 575, Color(255, 223, 0))
            end

            if page == 6 then
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.SimpleText("Ground Command Ranks", imgui.xFont("!Roboto@40"), 0, -5, Color(255,255,255), TEXT_ALIGN_CENTER)
                AddLine("Junior Commanding Officer III [JCO III - BRIG]", 150, Color(255,255,255))
                AddLine("Junior Commanding Officer II [JCO II - MAJ GEN]", 200, Color(255,255,255))
                AddLine("Junior Commanding Officer I [JCO I - GEN]", 250, Color(255,255,255))
                AddLine("Senior Commanding Officer [SCO]", 300, Color(150,150,150))
                AddLine("Chief of the General Staff [CGS]", 350, Color(107, 191, 207))
                AddLine("Vice Chief of the Defence Staff [VCDS]", 400, Color(28, 113, 224))
                AddLine("Chief of the Defence Staff [CDS]", 450, Color(255, 223, 0))
            end

            
            imgui.End3D2D()
        end
    end

end