ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "base_board"
ENT.Category = "Core's Military Boards"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local PageCount = 4

local uicols = {
    header = {
        background = Color(0, 191, 255),
        foreground = Color(255, 255, 255)
    },
    main = {
        background = Color(100, 100, 100),
        foreground = Color(255, 255, 255)
    },
    button = {
        background = Color(175,175,175),
        foreground = Color(255,255,255),
        active = Color(0,255,0)
    }
}

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
    net.Receive( "nextbtn", function( len, ply )
        local ent = net.ReadEntity()
        if ent:GetClass() == ENT.PrintName and IsValid( ply ) and IsValid(ent) then
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

    net.Receive( "prevbtn", function( len, ply )
        local ent = net.ReadEntity()
        if ent:GetClass() == ENT.PrintName and IsValid( ply ) and IsValid(ent) then
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
        if imgui.Entity3D2D(self, Vector(-50, 0, 0), Angle(0, 90, 0), 0.15, 600, 450) then

            local boardwidth = 1024
            local page = self:GetPage()

            --[[Header]]--
            draw.RoundedBox(25, -boardwidth / 2, -35, boardwidth, 70, uicols.header.background)
            draw.SimpleText(self.PrintName, imgui.xFont("!Roboto@40"), 0, -20, uicols.header.foreground, TEXT_ALIGN_CENTER)

            --[[Main Body]]--
            draw.RoundedBox(25, -boardwidth / 2, 50, boardwidth, 650, uicols.main.background)
            draw.SimpleText(page .. "/" .. self.Pages, imgui.xFont("!Roboto@20"), 0, 670, uicols.main.foreground, TEXT_ALIGN_CENTER)

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
            if imgui.xTextButton("Next", "!Roboto@24", boardwidth / 2 - 230, 610, 200, 55, 1, uicols.button.background, uicols.button.foreground, uicols.button.active) then
                net.Start("nextbtn")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end

            if imgui.xTextButton("Previous", "!Roboto@24", -482, 610, 200, 55, 1, uicols.button.background, uicols.button.foreground, uicols.button.active) then
                net.Start("prevbtn")
                net.WriteEntity(self)
                net.SendToServer()
                surface.PlaySound("buttons/button24.wav")
                PageTimeout()
            end

            
            --[[Pages]]--
            if page == 1 then                    
                draw.SimpleText("Howdy", imgui.xFont("!DermaDefaultBold@60"), 0, 70, Color(255,255,255), TEXT_ALIGN_CENTER)

                if SysTime() - start > 3 then
                    start = SysTime()
	            end
            end
            
            imgui.End3D2D()
        end
    end

end