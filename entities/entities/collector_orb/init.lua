AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	// Use the helibomb model just for the shadow (because it's about the same size)
	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	
	self:DrawShadow( false );
	
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER );
	self:SetTrigger( true );
	
	local size = 4;
	
	// Don't use the model's physics - create a sphere instead
	self.Entity:PhysicsInitSphere( size, "rubber" )
	
	// Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	// Set collision bounds exactly
	self.Entity:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
	
	self.Birth = CurTime();
	GAMEMODE.OrbCount = GAMEMODE.OrbCount + 1;
	self.NextDrawThink = 0;
	
	local obj = self:GetPhysicsObject();
	if ( ValidEntity( obj ) ) then
	
		obj:ApplyForceCenter( Vector( math.random( -10, 10 ), math.random( -10, 10 ), math.random( 50, 100 ) ) );
		
	end
	
end


function ENT:Use( activator, caller )

end


function ENT:Boom()

	local effectdata = EffectData();
	effectdata:SetStart( self:GetPos() );
	effectdata:SetOrigin( self:GetPos() );
	effectdata:SetScale( 0.1 );
	effectdata:SetMagnitude( 0.3 );
	util.Effect( "cball_bounce", effectdata );
	
	self:EmitSound( Sound( "ambient/water/rain_drip" .. math.random( 1, 4 ) .. ".wav" ), 80, 115 );

	GAMEMODE.OrbCount = GAMEMODE.OrbCount - 1;
	self:Remove();

end


function ENT:Think( )

	local curtime = CurTime();

	if ( curtime - self.Birth > 30 ) then
	
		self:Boom();
		return;
	
	end
	
	if ( curtime > self.NextDrawThink ) then
	
		self.NextDrawThink = curtime + 1;
	
		local close;
		local close_dist = PROP_HAUNT_DISTANCE + 1;
	
		for _, pl in pairs( player.GetAll() ) do
		
			if ( pl:Alive() && pl:Team() == TEAM_PLAYERS ) then
			
				local dist = ( self:GetPos() - pl:GetPos() ):Length();
				
				if ( dist <= close_dist ) then
				
					close_dist = dist;
					close = pl;
				
				end
			
			end
		
		end
		
		if ( ValidEntity( close ) ) then
		
			local obj = self:GetPhysicsObject();
			if ( ValidEntity( obj ) ) then
			
				local dir = ( close:GetPos() - self:GetPos() ):Normalize();
				obj:ApplyForceCenter( dir * 34 );
				
			end
		
		end
	
	end

end


function ENT:Touch( ent )

	if ( !ValidEntity( ent ) || !ent:IsPlayer() || !ent:Alive() ) then
	
		return;
		
	end
	
	self:Boom();
	return;
	
end
