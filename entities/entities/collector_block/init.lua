
// client files
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

// includes
include( "shared.lua" );

/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	self:SetModel( Model( "models/props_c17/playgroundTick-tack-toe_block01a.mdl" ) );
	self:PhysicsInit( SOLID_VPHYSICS );
	self:DrawShadow( true );
	self:SetUseType( SIMPLE_USE );
	
	self.Birth = CurTime();

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	local curtime = CurTime();

	if ( curtime - self.Birth > 90 ) then
	
		self:Remove();
		return;
	
	end
	
end


function ENT:Use( activator, caller )

	if ( activator:IsPlayer() && activator:Alive() ) then
	
		self:Remove();
		
		local effectdata = EffectData();
		effectdata:SetStart( self:GetPos() );
		effectdata:SetOrigin( self:GetPos() );
		effectdata:SetScale( 1 );
		util.Effect( "cball_bounce", effectdata );
		
		self:EmitSound( Sound( "npc/scanner/scanner_nearmiss" .. math.random( 1, 2 ) .. ".wav" ), 100, 100 );
		
	end

end
