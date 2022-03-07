ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Faces Board"
ENT.Category = "Induction Networks"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local PageCount = 4

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
    net.Receive( "nextbtn_faces", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "faces" then
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

    net.Receive( "prevbtn_faces", function( len, ply )
        local ent = net.ReadEntity()
        if IsValid( ply ) and IsValid(ent) and ent:GetClass() == "faces" then
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
                timer.Create(self.PrintName, 90, 1, function()
                    self:SetPage(1)
                end)
                if self:GetPage() == 1 then
                    timer.Destroy(self.PrintName)
                end
            end
                            
            --[[Page Controls]]--        
            if imgui.xTextButton("Next", "!Roboto@24", boardwidth / 2 - 230, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("nextbtn_faces")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end

            if imgui.xTextButton("Previous", "!Roboto@24", -482, 610, 200, 55, 1, Color(175,175,175), Color(255,255,255), Color(0,255,0)) then
                net.Start("prevbtn_faces")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end

            
            --[[Pages]]--
            if page == 1 then                    
                draw.SimpleText("Right Face", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.RotatedBox( 0, 300, 50, 50, Lerp( SysTime() - start, 0, -90 ), Color( 50, 50, 200) )

                draw.SimpleText("Turn 90° to your right.", imgui.xFont("!DermaDefaultBold@25"), 0, 425, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("Displayed as the letter R in chat", imgui.xFont("!DermaDefault@25"), 0, 475, Color(255,255,255), TEXT_ALIGN_CENTER)

                if SysTime() - start > 3 then
                    start = SysTime()
	            end
            end

            if page == 2 then                    
                draw.SimpleText("Left Face", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.RotatedBox( 0, 300, 50, 50, Lerp( SysTime() - start, 0, 90 ), Color( 50, 50, 200) )

                draw.SimpleText("Turn 90° to your left.", imgui.xFont("!DermaDefaultBold@25"), 0, 425, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("Displayed as the letter L in chat", imgui.xFont("!DermaDefault@25"), 0, 475, Color(255,255,255), TEXT_ALIGN_CENTER)

                if SysTime() - start > 3 then
                    start = SysTime()
	            end
            end

            if page == 3 then                    
                draw.SimpleText("About Face", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                draw.RotatedBox( 0, 300, 50, 50, Lerp( SysTime() - start, 0, -180 ), Color( 50, 50, 200) )

                draw.SimpleText("Turn 180° to your right.", imgui.xFont("!DermaDefaultBold@25"), 0, 425, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("Displayed as the letter A in chat", imgui.xFont("!DermaDefault@25"), 0, 475, Color(255,255,255), TEXT_ALIGN_CENTER)

                if SysTime() - start > 3 then
                    start = SysTime()
	            end
            end

            if page == 4 then                    
                draw.SimpleText("Front Face", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)
                
                surface.SetDrawColor( 50, 50, 200)
                draw.NoTexture()
                surface.SetDrawColor( 200, 50, 50)
                draw.Circle( 0, 210, 30, 20 )
                surface.SetDrawColor( 50, 200, 50)
                draw.Circle( 0, 300, 30, 20 )

                draw.SimpleText("Turn around your right shoulder to face your CO.", imgui.xFont("!DermaDefaultBold@25"), 0, 425, Color(255,255,255), TEXT_ALIGN_CENTER)
                draw.SimpleText("Displayed as the letter F in chat", imgui.xFont("!DermaDefault@25"), 0, 475, Color(255,255,255), TEXT_ALIGN_CENTER)
            end

            
            imgui.End3D2D()
        end
    end

end