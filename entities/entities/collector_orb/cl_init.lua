include('shared.lua')

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

local matBall = Material( "sprites/grav_flare" )

function ENT:Initialize()

	
end

function ENT:Draw()
	
	local pos = self.Entity:GetPos()
	local vel = self.Entity:GetVelocity()
		
	render.SetMaterial( matBall );
	
	if ( vel:Length() > 1 ) then
	
		for i = 1, 4 do
		
			local col = Color( 255, 255, 255, 200 / i )
			render.DrawSprite( pos + vel*(i*-0.01), 8, 8, col )
			
		end
	
	end
	
	render.DrawSprite( pos, 8, 8, Color( 255, 255, 255, 255 ) )
	
end
