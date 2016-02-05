
// includes
include( "shared.lua" );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

end


/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw()

	self:SetModelScale( Vector() );

	self:DrawModel();

	SetMaterialOverride( "debug/white" );
	render.SuppressEngineLighting( true );
	render.SetColorModulation( 1, 0, 0 );
	render.SetBlend( 0.4 );
	
	for i = 1, 4 do
	
		self:SetModelScale( Vector() * math.abs( math.cos( CurTime() ) * ( 1.1 + ( i * 0.1 ) ) ) );
	
		self:DrawModel();
		
	end
	
	SetMaterialOverride( nil );
	
	render.SetBlend( 1 );
	render.SetColorModulation( 1, 1, 1 );
	render.SuppressEngineLighting( false );
	
end
