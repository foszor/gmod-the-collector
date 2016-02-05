
// SENT setup
ENT.Type 					= "anim";
ENT.PrintName				= "";
ENT.Author					= "";
ENT.Contact					= "";
ENT.Spawnable				= false;
ENT.AdminSpawnable			= false;
ENT.RenderGroup 			= RENDERGROUP_TRANSLUCENT;
ENT.AutomaticFrameAdvance	= true;
ENT.Model					= Model( "models/Zombie/Classic_torso.mdl" );


/*------------------------------------
	UpdatePosition()
------------------------------------*/
function ENT:UpdatePosition( pl )

	if ( !ValidEntity( pl ) ) then
	
		if ( SERVER ) then
		
			self:ReleaseProp();
			self:Remove();
			
		end
		
		return;
	
	end

	// get current aim direction
	local aim = pl:GetAimVector();
	
	// build trace
	local trace = {};
		trace.start = pl:GetShootPos();
		trace.endpos = ( trace.start + ( aim * 40 ) );
		trace.filter = pl;
		
	// run trace
	local traceres = util.TraceLine( trace );
	
	// calculate new position
	local newpos = traceres.HitPos + ( aim * -8 );
	newpos = newpos + ( aim:Angle():Up() * -24 );
	
	// rotate to face client
	local ang = ( aim * -1 ):Angle();
	ang:RotateAroundAxis( aim:Angle():Right(), -35 );
	
	// update
	self:SetPos( newpos );
	self:SetAngles( ang );
	
end
