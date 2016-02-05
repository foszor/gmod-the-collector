
local PANEL = {}

/*------------------------------------
	Init()
------------------------------------*/
function PANEL:Init()

	self:SetModel( Model( "models/Gibs/HGIBS.mdl" ) );
	
	self.Visible = false;
	
	self:PerformLayout();
	
	self:SetAmbientLight( Color( 1, 1, 1 ) );
	
end


/*------------------------------------
	Think()
------------------------------------*/
function PANEL:Think()


end


/*------------------------------------
	LayoutEntity()
------------------------------------*/
function PANEL:LayoutEntity( ent )

	local pl = LocalPlayer();
	if ( !IsValid( pl ) ) then
	
		return;
		
	end

	self:SetCamPos( Vector( 0, 12, 0 ) )
	self:SetLookAt( Vector( 0, 0, 0 ) )
	
	local dir = pl:GetNWAngle( "GoalDir", Angle( 0, 0, 0 ) );
	
	ent:SetPos( Vector( 0, 0, 0 ) );
	
	if ( pl:GetNWInt( "GoalStatus" ) == 3 ) then
	
		self:SetCamPos( Vector( 0, 0, 0 ) )
		
	else
	
		self:SetCamPos( Vector( 0, 12, 0 ) )
	
	end
	
	local targetang = dir + Angle( 10 + ( math.sin( CurTime() ) * 5 ), 145, 0 );
	
	if ( pl:GetNWInt( "GoalState" ) == 2 ) then
	
		//targetang = targetang + Angle( 0, CurTime() * 300, 0 );
	
	end
	
	self.CurrentAngle = self.CurrentAngle or targetang;
	
	self.CurrentAngle.yaw = math.ApproachAngle( self.CurrentAngle.yaw, targetang.yaw, FrameTime() * ( math.abs( targetang.yaw - self.CurrentAngle.yaw ) + 1 ) * 0.7 );
	
	ent:SetAngles( self.CurrentAngle );

end


/*------------------------------------
	PerformLayout()
------------------------------------*/
function PANEL:PerformLayout()

	local size = ScrH() * 0.12;

	self:SetSize( size, size );
	self:SetPos( ScrW() - size, ScrH() - size );
	
end

vgui.Register( "CollectorCompass", PANEL, "DModelPanel" );
