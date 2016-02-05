
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

/*------------------------------------
	SpawnFunction()
------------------------------------*/
function ENT:SpawnFunction( pl, tr )

	local ent = ents.Create( "vortex" );
		ent:SetPos( tr.HitPos + Vector( 0, 0, 16 ) );
	ent:Spawn();
	
	return ent;

end

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize( )

	self:DrawShadow( false );
	self.Birth = CurTime();
	self.Meals = 0;
	
	self:SetCollisionBounds(
		Vector( -16, -16, -16 ),
		Vector( 16, 16, 72 )
	);
	
	self:SetSolid( SOLID_BBOX );
	self:SetTrigger( true );
	self:SetNotSolid( true );
	
	self.EatDelay = 0;
	
	self.Dissolver = ents.Create( "env_entity_dissolver" );
	self.Dissolver:SetPos( self:GetPos() );
	self.Dissolver:SetKeyValue( "dissolvetype", 1 );
	self.Dissolver:Spawn();
	self.Dissolver:Activate();
	self.Dissolver:SetParent( self );

end


function ENT:Think()
/*
	local mins, maxs = self:WorldSpaceAABB();
	mins = mins - self:GetPos();
	maxs = maxs - self:GetPos();
	debugoverlay.Box( self:GetPos(), mins, maxs, 1, Color( 255, 255, 255, 32 ) );
	*/

	local curtime = CurTime();
	
	if ( curtime - self.Birth > 120 ) then
	
		self:Remove();
		return;
	
	end
	
	local close;
	local close_dist = PROP_ATTACK_DISTANCE;

	for _, pl in pairs( player.GetAll() ) do
	
		if ( pl:Alive() && pl:Team() == TEAM_PLAYERS ) then
		
			local dist = ( self:GetPos() - pl:GetPos() ):Length();
			
			if ( dist <= close_dist && dist >= 32 ) then
			
				close_dist = dist;
				close = pl;
			
			end
		
		end
	
	end
	
	if ( close ) then
	
		local dir = ( ( close:GetShootPos() - Vector( 0, 0, 32 ) ) - self:GetPos() ):Normalize();
		//dir.z = 0;
		self:SetPos( self:GetPos() + ( dir * 0.5 ) );
	
	end
	
	self:NextThink( curtime );
	return true;

end


function ENT:Touch( ent )

	if ( !ValidEntity( ent ) ) then
	
		return;
		
	end

	local curtime = CurTime();

	local class = ent:GetClass();
	if ( !table.HasValue( GAMEMODE.PropClassList, class ) ) then
	
	//	print( "stopa ", ent );
		return;
		
	elseif ( !ent.Punted || curtime - ent.Punted > 5 ) then
	
	//	print( "stopb ", ent.Punted, ent );
		return;
		
	end
	
	if ( curtime - self.EatDelay <= 2 ) then
	
	//	print( "stopc ", ent );
		return;
	
	end
	
	self.EatDelay = curtime;
	
	local obj = ent:GetPhysicsObject();
	if ( ValidEntity( obj ) ) then
	
		obj:SetVelocity( Vector( 0, 0, 0 ) );
		obj:SetVelocityInstantaneous( Vector( 0, 0, 0 ) );
		obj:EnableMotion( false );
		obj:EnableCollisions( false );
		obj:Sleep();
		obj:SetMass( PROP_HAUNT_MASS + 1 );
		
	end
	
	self:EmitSound( Sound("ambient/energy/whiteflash.wav" ) );
	
	//print( "touched ", ent );
	ent:SetName( "timetodie" );
	self.Dissolver:Fire( "Dissolve", "timetodie", 0 );
	
	self.Meals = self.Meals + 1;
	self.Birth = curtime;

end
