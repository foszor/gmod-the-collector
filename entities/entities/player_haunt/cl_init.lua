
// includes
include( "shared.lua" );

// globals
local matBlack = Material( "black_outline" );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	// get owner
	local pl = self:GetOwner();
	
	// refresh position
	self:UpdatePosition( pl );
	
	// think fast
	self:NextThink( CurTime() );
	return true;

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	// check if we should draw
	local pl = self:GetOwner();
	if ( !ValidEntity( pl ) || !pl:Alive() ) then
	
		return;
		
	elseif ( LocalPlayer() != pl ) then
	
		return;
		
	elseif ( !pl.HallucinateTime || pl.HallucinateTime < CurTime() ) then
	
		return;
		
	end
	
	// fade
	self:SetColor( 255, 255, 255, 80 );
	
	// randomly draw phantoms
	local amt = math.random( 2, 4 )
	for i = 1, amt do
	
		// random scale
		local scale = math.random( 8, 20 ) * 0.1;
		
		// draw phantom
		self:SetModelScale( Vector() * scale );
		SetMaterialOverride( ( math.random( 1, 2 ) == 1 ) && matBlack || nil );
		self:DrawModel();
	
	end
	
	// reset
	SetMaterialOverride( nil );
	self:SetModelScale( Vector() );
	
	// draw normal model
	self:DrawModel();

end
