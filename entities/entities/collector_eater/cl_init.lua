
include( "shared.lua" );

local BlackBall = Material( "sprites/strider_blackball" );
local Refract = Material( "sprites/heatwave" );
local Glow = CreateMaterial(
	"Glow02",
	"UnlitGeneric",
	{
		["$basetexture"] = "sprites/glow02",
		["$additive"] = "1",
		["$vertexcolor"] = "1"
	}
);

// rendreing group
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT;

/*------------------------------------
	VortexThink()
------------------------------------*/
local function VortexThink( particle )

	// vortex
	local dir = Vector( math.cos( CurTime() * 2 + particle:GetBounce() ), math.sin( CurTime() * 2 + particle:GetBounce() ), 0 );
	local velocity = dir:Cross( Vector(0,0,1) ):GetNormal() * 50 + Vector( 0, 0, 50 );
	particle:SetVelocity( velocity );
	
	particle:SetNextThink( RealTime() );

end


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize( )

	self.Emitter = ParticleEmitter( self:GetPos() );
	self.NextEmit = CurTime();
	
	// sound
	self.Sound = CreateSound( self.Entity, "ambient/levels/citadel/citadel_drone_loop4.wav" );
	self.Sound:Play();
	
end


/*------------------------------------
	OnRemove()
------------------------------------*/
function ENT:OnRemove( )

	self.Sound:Stop();

end

/*------------------------------------
	Draw()
------------------------------------*/
function ENT:Draw( )

	local delta = math.sin( CurTime() * 2 );
	local refract = delta * 0.01;

	// refraction
	render.SetMaterial( Refract );
	Refract:SetMaterialFloat( "$refractamount", refract );
	render.UpdateRefractTexture();
	render.DrawSprite( self:GetPos(), 32, 32, Color( 0, 0, 0, 255 ) );
	
	// outer glow
	render.SetMaterial( Glow );
	render.DrawQuadEasy( self:GetPos(), EyeVector() * -1, 32, 32, Color( 255, 0, 0, 255 ), CurTime() * 100 );

	// inner black core
	render.SetMaterial( BlackBall );
	render.DrawQuadEasy( self:GetPos(), EyeVector() * -1, 16, 16, Color( 0, 0, 0, 255 ), CurTime() * 100 );
	
	// inner glow
	render.SetMaterial( Glow );
	render.DrawQuadEasy( self:GetPos(), EyeVector() * -1, 24, 24, Color( 64, 0, 0, 255 ), CurTime() * 100 );

end

/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think( )

	if( self.NextEmit <= CurTime() ) then
	
		self.NextEmit = CurTime() + 0.01;

		// create particle
		local particle = self.Emitter:Add( "effects/blood_core", self:GetPos() );
			particle:SetStartSize( 8 );
			particle:SetEndSize( 8 );
			particle:SetStartAlpha( 128 );
			particle:SetEndAlpha( 0 );
			particle:SetDieTime( math.Rand( 1, 2 ) );
			particle:SetLifeTime( 0 );
			particle:SetColor( 80, 80, 80 );
			particle:SetVelocity( Vector(0,0,1) );
			particle:SetStartLength( 48 );
			particle:SetEndLength( 64 );
			particle:SetThinkFunction( VortexThink );
			particle:SetBounce( math.random( 0, 360 ) );
			particle:SetNextThink( RealTime() );
			
		// create particle
		local particle = self.Emitter:Add( "effects/blood_core", self:GetPos() );
			particle:SetStartSize( 2 );
			particle:SetEndSize( 2 );
			particle:SetStartAlpha( 255 );
			particle:SetEndAlpha( 0 );
			particle:SetDieTime( math.Rand( 1, 2 ) );
			particle:SetLifeTime( 0 );
			particle:SetColor( 255, 0, 0 );
			particle:SetVelocity( Vector(0,0,1) );
			particle:SetStartLength( 48 );
			particle:SetEndLength( 64 );
			particle:SetThinkFunction( VortexThink );
			particle:SetBounce( math.random( 0, 360 ) );
			particle:SetNextThink( RealTime() );
			
		// create particle
		local particle = self.Emitter:Add( "effects/blood_core", self:GetPos() );
			particle:SetStartSize( 2 );
			particle:SetEndSize( 2 );
			particle:SetStartAlpha( 255 );
			particle:SetEndAlpha( 0 );
			particle:SetDieTime( math.Rand( 1, 2 ) );
			particle:SetLifeTime( 0 );
			particle:SetColor( 255, 0, 0 );
			particle:SetVelocity( Vector(0,0,1) );
			particle:SetStartLength( 16 );
			particle:SetEndLength( 1 );
			particle:SetVelocity( ( Vector(0,0,1) + VectorRand() * 0.4 ) * math.Rand( 50, 100 ) );
			particle:SetGravity( Vector(0,0,-100) );
			particle:SetCollide( true );
			particle:SetBounce( 0.4 );

	end
	
	// the sun emits dynamic light
	local light = DynamicLight( self:EntIndex() );
		light.Pos = self:GetPos();
		light.Size = 128;
		light.Decay = 512;
		light.DieTime = CurTime() + 1;
		light.R = 255;
		light.G = 8;
		light.B = 8;
		light.Brightness = 2;
	
end

