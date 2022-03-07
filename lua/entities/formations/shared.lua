ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Formations Board"
ENT.Category = "Induction Networks"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local PageCount = 8

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
    net.Receive( "nextbtn_formations", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "formations" then
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

    net.Receive( "prevbtn_formations", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "formations" then
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
            draw.RoundedBox(25, -boardwidth / 2, -35, boardwidth, 70, Color(0, 191, 255))
            draw.SimpleText(self.PrintName, imgui.xFont("!Roboto@40"), 0, -20, Color(255,255,255), TEXT_ALIGN_CENTER)

            --[[Main Body]]--
            draw.RoundedBox(25, -boardwidth / 2, 50, boardwidth, 650, Color(100, 100, 100, 255))
            draw.SimpleText(page .. "/" .. self.Pages, imgui.xFont("!Roboto@20"), 0, 670, Color(255,255,255), TEXT_ALIGN_CENTER)

            --[[Page Timeout]]
            function PageTimeout()
                timer.Create(self.PrintName, 120, 1, function()
                    self:SetPage(1)
                end)
                if self:GetPage() == 1 then
                    timer.Destroy(self.PrintName)
                end
            end
                            
            --[[Page Controls]]--        
            if imgui.xTextButton("Next", "!Roboto@24", boardwidth / 2 - 230, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("nextbtn_formations")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end

            if imgui.xTextButton("Previous", "!Roboto@24", -482, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("prevbtn_formations")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end
                            
            --[[Pages]]--
            if page == 1 then                    
                draw.SimpleText("Single Column", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 200, 50, 50)
                draw.NoTexture()
                draw.Circle( 0, 230, 50, 20 )

                surface.SetDrawColor( 50, 200, 50)
                draw.NoTexture()
                draw.Circle( 0, 340, 50, 20 )
                draw.Circle( 0, 450, 50, 20 )
                draw.Circle( 0, 560, 50, 20 )
            end

            if page == 2 then                    
                draw.SimpleText("Double Column", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 200, 50, 50, 90)
                draw.NoTexture()
                draw.Circle( 0, math.cos( CurTime() ) * 140 + 330, 45, 20 )

                surface.SetDrawColor( 200, 50, 50)
                draw.Circle( 0, 190, 45, 20 )

                surface.SetDrawColor( 50, 200, 50)
                draw.NoTexture()
                draw.Circle( -95, 250, 50, 20 )
                draw.Circle( -95, 360, 50, 20 )
                draw.Circle( -95, 470, 50, 20 )

                draw.Circle( 95, 250, 50, 20 )
                draw.Circle( 95, 360, 50, 20 )
                draw.Circle( 95, 470, 50, 20 )

                draw.SimpleText("Ensure there is sufficient room for your CO to pass through.", imgui.xFont("!DermaDefaultBold@25"), 0, 550, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("When your CO says centre face you will turn inwards and salute when your CO passes you.", imgui.xFont("!DermaDefaultBold@25"), 0, 570, Color(255,255,255), TEXT_ALIGN_CENTER)
            end

            if page == 3 then                    
                draw.SimpleText("Tight Wedge", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 200, 50, 50)
                draw.NoTexture()
                draw.Circle( 0, 210, 45, 20 )

                surface.SetDrawColor( 50, 200, 50)
                draw.NoTexture()
                draw.Circle( -70, 290, 50, 20 )
                draw.Circle( -150, 370, 50, 20 )
                draw.Circle( -230, 450, 50, 20 )

                draw.Circle( 70, 290, 50, 20 )
                draw.Circle( 150, 370, 50, 20 )
                draw.Circle( 230, 450, 50, 20 )

                surface.SetDrawColor( 200, 200, 200)
                surface.DrawRect(-73, 290, 5, -60)
                surface.DrawRect(-153, 370, 5, -60)
                surface.DrawRect(-233, 450, 5, -60)

                surface.DrawRect(68, 290, 5, -60)
                surface.DrawRect(147, 370, 5, -60)
                surface.DrawRect(228, 450, 5, -60)

                draw.SimpleText("Use an aggressive stance. Hold your weapon out.", imgui.xFont("!DermaDefaultBold@25"), 0, 550, Color(255,255,255), TEXT_ALIGN_CENTER)
            end

            if page == 4 then                    
                draw.SimpleText("Loose Wedge", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 200, 50, 50, 90)
                draw.NoTexture()
                draw.Circle( math.sin( CurTime() ) * 60 - 70, math.cos( CurTime() ) * 60 + 290, 25, 20 )

                surface.SetDrawColor( 200, 50, 50)
                draw.Circle( 0, 190, 30, 20 ) -- CO Circle

                draw.NoTexture()
                surface.SetDrawColor( 50, 200, 50)
                draw.Circle( -70, 290, 30, 20 )
                draw.Circle( -150, 370, 30, 20 )
                draw.Circle( -230, 450, 30, 20 )

                draw.Circle( 70, 290, 30, 20 )
                draw.Circle( 150, 370, 30, 20 )
                draw.Circle( 230, 450, 30, 20 )

                surface.SetDrawColor( 200, 200, 200)
                surface.DrawRect(-73, 290, 5, -60)
                surface.DrawRect(-153, 370, 5, -60)
                surface.DrawRect(-233, 450, 5, -60)

                surface.DrawRect(68, 290, 5, -60)
                surface.DrawRect(147, 370, 5, -60)
                surface.DrawRect(228, 450, 5, -60)

                draw.SimpleText("Ensure there is sufficient room for your CO to pass through", imgui.xFont("!DermaDefaultBold@25"), 0, 550, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("Use an aggressive stance. Hold your weapon out.", imgui.xFont("!DermaDefaultBold@25"), 0, 575, Color(255,255,255), TEXT_ALIGN_CENTER)
            end

            if page == 5 then                    
                draw.SimpleText("Herringbone", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 50, 200, 50)
                draw.NoTexture()
                draw.Circle( 0, 230, 50, 20 )
                draw.Circle( 0, 340, 50, 20 )
                draw.Circle( 0, 450, 50, 20 )
                draw.Circle( 0, 560, 50, 20 )
                

                surface.SetDrawColor( 200, 200, 200)
                surface.DrawRect(-2.5, 230, 5, -60)
                surface.DrawRect(0, 337.5, 60, 5)
                surface.DrawRect(0, 447.5, -60, 5)
                surface.DrawRect(-2.5, 560, 5, 60)

                draw.SimpleText("The back unit never does an about face, they watch behind.", imgui.xFont("!DermaDefaultBold@20"), 0, 620, Color(255,255,255), TEXT_ALIGN_CENTER)
            end

            if page == 6 then
                draw.SimpleText("Prisoner Diamond", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 200, 50, 50)
                draw.NoTexture()
                draw.Circle( 0, 350, 50, 20 )

                surface.SetDrawColor( 50, 200, 50)
                draw.NoTexture()
                draw.Circle( 0, 240, 50, 20 )
                draw.Circle( 110, 350, 50, 20 )
                draw.Circle( -110, 350, 50, 20 )
                draw.Circle( 0, 460, 50, 20 )
                surface.SetDrawColor( 255, 255, 255)
                surface.DrawRect(-2.5, 260, 5, 60)
                surface.DrawRect(-2.5, 380, 5, 60)
                surface.DrawRect(30, 345, 60, 5)
                surface.DrawRect(-90, 345, 60, 5)

                draw.SimpleText("There must be no gap between you and the Prisoner,", imgui.xFont("!DermaDefaultBold@25"), 0, 550, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("tell them to get on the ground and strip their weapons using the weapon stripper.", imgui.xFont("!DermaDefaultBold@25"), 0, 570, Color(255,255,255), TEXT_ALIGN_CENTER)
    
            end

            if page == 7 then
                draw.SimpleText("VIP Diamond", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 200, 50, 50)
                draw.NoTexture()
                draw.Circle( 0, 350, 30, 20 )

                surface.SetDrawColor( 50, 200, 50)
                draw.NoTexture()
                draw.Circle( 0, 230, 30, 20 )
                draw.Circle( 120, 350, 30, 20 )
                draw.Circle( -120, 350, 30, 20 )
                draw.Circle( 0, 470, 30, 20 )

                surface.SetDrawColor( 255, 255, 255)
                surface.DrawRect(-2.5, 175, 5, 60)
                surface.DrawRect(-2.5, 465, 5, 60)
                surface.DrawRect(125, 348, 60, 5)
                surface.DrawRect(-180, 348, 60, 5)

                draw.SimpleText("There must be at least one and a half", imgui.xFont("!DermaDefaultBold@25"), 0, 550, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("persons space between you and the VIP.", imgui.xFont("!DermaDefaultBold@25"), 0, 570, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("Say that your area is clear", imgui.xFont("!DermaDefaultBold@25"), 0, 590, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("(I.E. North Clear if your facing north)", imgui.xFont("!DermaDefaultBold@25"), 0, 610, Color(255,255,255), TEXT_ALIGN_CENTER)
            end

            if page == 8 then
                draw.SimpleText("Firing Squad", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.Circle( -50, 250, 40, 20 )
                draw.Circle( -150, 250, 40, 20 )
                draw.Circle( 50, 250, 40, 20 )
                draw.Circle( 150, 250, 40, 20 )

                surface.SetDrawColor( 50, 200, 50)
                draw.NoTexture()
                draw.Circle( -50, 350, 40, 20 )
                draw.Circle( -150, 350, 40, 20 )
                draw.Circle( 50, 350, 40, 20 )
                draw.Circle( 150, 350, 40, 20 )

                draw.SimpleText("- Crouched", imgui.xFont("!DermaDefaultBold@25"), 200, 250, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("- Standing", imgui.xFont("!DermaDefaultBold@25"), 200, 350, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("When told to do an About Face, turn around", imgui.xFont("!DermaDefaultBold@25"), 0, 550, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("and do the opposite. Crouching stand up and standing crouch.", imgui.xFont("!DermaDefaultBold@25"), 0, 570, Color(255,255,255), TEXT_ALIGN_CENTER)
    
            end

            
            imgui.End3D2D()
        end
    end

end