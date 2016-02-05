
local PANEL = {}

/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	self:SetModel( Model( "models/props_c17/playgroundTick-tack-toe_block01a.mdl" ) );
	
	self.Visible = false;
	
	self:PerformLayout();
	
end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()

	self:SetAmbientLight( Color( 10, 10, 10 ) );
	//self:SetDirectionalLight( BOX_TOP, Color( 1, 1, 1 ) )


end


/*------------------------------------
	LayoutEntity()
------------------------------------*/
function PANEL:LayoutEntity( ent )

	local pl = LocalPlayer();
	if ( !IsValid( pl ) ) then
	
		return;
		
	end

	self:SetCamPos( Vector( 0, 25, 0 ) );
	self:SetLookAt( Vector( 0, 0, 0 ) );
	
	// blank = -10
	// O = 90
	// X = 180
	
	local ang = Angle( -10, 80 + ( math.sin( CurTime() * 1 ) * 8 ), 10 + ( math.sin( CurTime() * 1 ) * 3 ) );
	
	ent:SetAngles( ang );

end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()

	local size = ScrH() * 0.14;

	self:SetSize( size, size );
	
end

vgui.Register( "CollectorBlock", PANEL, "DModelPanel" );
