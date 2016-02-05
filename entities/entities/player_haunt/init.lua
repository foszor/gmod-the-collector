
// client files
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

// includes
include( "shared.lua" );


/*------------------------------------
	Initialize()
------------------------------------*/
function ENT:Initialize()

	local curtime = CurTime();

	self:SetModel( self.Model );
	self:DrawShadow( false );
	self.NextPunt = 0;
	self.LastWalk = curtime;
	
	self.DelayThink = curtime + 1;
	self.DelayHaunt = curtime + 5;
	self.FlashlightOff = 0;
	
end


/*------------------------------------
	UpdateTransmitState()
------------------------------------*/
function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS;
	
end;


/*------------------------------------
	SlowPlayer()
------------------------------------*/
function ENT:SlowPlayer( pl, curtime )
	
	if ( CurTime() < ( self.NextSpawn or 0 ) || #pl.TrackPositions < 2 ) then
	
		return;
		
	end
	
	if ( pl:GetVelocity():Length() < 140 || !pl:OnGround() ) then
	
		self.LastWalk = curtime;
		return;
		
	elseif ( curtime - self.LastWalk <= 3 ) then
		return;
		
	end
	
	pl:Ignite( 3, 0 );
	
	/*
	for i = 2, ( #pl.TrackPositions - 1 ) do
	
		local trackpos = pl.TrackPositions[ i ];
	
		if ( EntityClear( pl, trackpos ) ) then
		
			local m = ents.Create( "npc_fastzombie" );
			m:SetPos( trackpos + Vector( 0, 0, 4 ) );
			
			local ang = ( pl:GetPos() - trackpos ):Normalize():Angle();
			
			m:SetAngles( ang );
			
			m:SetKeyValue( "renderfx", 16 );
			m:SetColor( 255, 255, 255, 130 );
			
			m:Spawn();
			
			m:Fire( "SetBodyGroup", "2", 0 );
			
			m.Terror = true;
			
			pl.Terror = m;
			
			local time = math.random( 6, 10 );
			
			SafeRemoveEntityDelayed( m, time );
			
			self.NextSpawn = curtime + time + 1;
			
			timer.Simple( 1, function()
			
				if ( ValidEntity( m ) ) then
			
					m:SetEnemy( pl );
					//m:NavSetGoal( curpos );
					//m:SetTarget( pl );
					m:SetLastPosition( pl:GetPos() );
					
					m:SetSchedule( SCHED_PATROL_RUN );
					
				end
				
			end );
			
			print( "monster!" );
			break;
		
		end
	
	end
*/
end


/*------------------------------------
	ReleaseProp()
------------------------------------*/
function ENT:ReleaseProp()

	if ( ValidEntity( self.HauntedProp ) ) then
	
	//	self.HauntedProp.Punted = 0;
		self.HauntedProp.Haunted = nil;
		self.HauntedProp = nil;
		
	end
	
end


/*------------------------------------
	ReleaseOrb()
------------------------------------*/
local function ReleaseOrb( prop )

	if ( GAMEMODE.OrbCount >= 20 ) then
	
		return;
	
	end

	local orb = ents.Create( "collector_orb" );
	orb:SetPos( prop:GetPos() );
	orb:SetOwner( prop );
	orb:Spawn();
	prop.Orbed = true;
	//print( "orbing!" );

end


/*------------------------------------
	HauntProp()
------------------------------------*/
function ENT:HauntProp( pl, curtime )
	
	local pl_pos = pl:GetPos();
	local close_dist = 513;
	local close_prop;

	if ( !ValidEntity( self.HauntedProp ) ) then
	
		local props = ents.FindInSphere( pl_pos, 256 );
		
		for _, prop in pairs( props ) do
		
			local class = prop:GetClass();
		
			if ( table.HasValue( GAMEMODE.PropClassList, class ) ) then
				
				prop.Punted = prop.Punted or 0;
				
				local obj = prop:GetPhysicsObject();
				
				if ( ValidEntity( obj ) ) then
			
					local dist = ( prop:GetPos() - pl_pos ):Length();
					if ( dist < close_dist && prop:Visible( pl ) && curtime > prop.Punted + 2 && !prop.Haunted && obj:GetMass() < PROP_HAUNT_MASS ) then
					
						close_prop = prop;
						close_dist = dist;
						
					end
					
				end
			
			end
		
		end
		
		if ( ValidEntity( close_prop ) ) then
		
			self:ReleaseProp();
			self.HauntedProp = close_prop;
		//	self.HauntedProp.Punted = 0;
			self.HauntedProp.Haunted = true;
			
			if ( !self.HauntedProp.Orbed ) then
			
				ReleaseOrb( self.HauntedProp );
				ReleaseOrb( self.HauntedProp );
			
			end
		
		end
		
	else
	
		local dist = ( self.HauntedProp:GetPos() - pl_pos ):Length();
		if ( dist > PROP_HAUNT_DISTANCE || !self.HauntedProp:Visible( pl ) || math.random( 1, 10 ) == 3 ) then
			
			self:ReleaseProp();
			return;
			
		end
	
		local obj = self.HauntedProp:GetPhysicsObject();
		if ( ValidEntity( obj ) ) then
		
			local mass = obj:GetMass();
			
			local force = mass * 10;
			
			if ( mass > 10 ) then
			
				obj:EnableMotion( true );
				obj:Wake();
				obj:ApplyForceOffset( Vector( math.random( -force, force ), math.random( -force, force ), math.random( 0, force ) ), obj:GetPos() + Vector( math.random( -50, 50 ), math.random( -50, 50 ), math.random( -50, 50 ) ) );
				
			end
			
			if ( !self.HauntedProp.NextHauntSound || curtime > self.HauntedProp.NextHauntSound ) then
			
				local sound = "npc/zombie/zombie_pain" .. math.random( 1, 6 ) ..".wav";
				Sound( sound );
				self.HauntedProp.NextHauntSound = curtime + SoundDuration( sound ) + math.random( 4, 8 );
				self.HauntedProp:EmitSound( sound, 90, 100 );
			
			end
			
			//local viewdir = ( self.HauntedProp:GetPos() - pl_pos ):GetNormal();
			if( curtime - ( self.HauntedProp.LastLighted or 0 ) >= 1 && !GAMEMODE.IsSlowMo ) then
				
				if ( dist <= PROP_ATTACK_DISTANCE && curtime > self.NextPunt ) then
					
					self.HauntedProp:EmitSound( Sound( "npc/fast_zombie/claw_miss1.wav" ), 90, 100 );
					
					local dir = ( pl:GetShootPos() - self.HauntedProp:GetPos() ):Normalize();
					
					if ( table.HasValue( EXPLOSIVE_PROPS, self.HauntedProp:GetModel() ) ) then
						
						// just for waxx
						self.HauntedProp:Fire( "AddOutput", "physdamagescale 3", 0 );
						
					end
					self.HauntedProp.OldPos = self.HauntedProp:LocalToWorld( self.HauntedProp:OBBCenter() ) + Vector( 0, 0, 8 );
					//self.HauntedProp:Fire( "minhealthdmg", 1, 0 );
					//self.HauntedProp:Fire( "physdamagescale", 5, 0 );
					obj:ApplyForceCenter( dir * ( force * 100 ) );
					self.HauntedProp.Punted = curtime;
					
					self:ReleaseProp();
					
					local delay = 0.75 + ( 4 * ( obj:GetMass() / PROP_HAUNT_MASS ) );
					
					self.NextPunt = curtime + delay;
					
				end
				
			end
			
		end
		
	end

end


/*------------------------------------
	RunAnimation()
------------------------------------*/
function ENT:RunAnimation()

	// randomly change animation
	if ( math.random( 1, 10 ) == 1 ) then
	
		if ( !self.Animation ) then
			
			self.Animation = self:LookupSequence( "crawl" );
			
		end
		
		self:SetPlaybackRate( 4.0 );
		self:ResetSequence( self.Animation );
		self:SetCycle( 1 );
		
	end

end


/*------------------------------------
	PreventFlashlight()
------------------------------------*/
function ENT:PreventFlashlight( pl, curtime )

	if ( !pl:FlashlightIsOn() ) then
		
		self.FlashlightOff = curtime;
		return;
		
	end

	if ( curtime - self.FlashlightOff > 8 ) then
		
		// attack
		local dmginfo = DamageInfo();
		dmginfo:SetAttacker( GetWorldEntity() );
		dmginfo:SetInflictor( GetWorldEntity() );
		dmginfo:SetDamage( 10 );
		pl:DispatchTraceAttack( dmginfo, pl:GetPos(), pl:GetShootPos() );
		self.FlashlightOff = curtime;
		pl:Flashlight( false );
		
		umsg.Start( "hallucinate", pl );
		umsg.End();
		
	end

end


/*------------------------------------
	Think()
------------------------------------*/
function ENT:Think()

	local pl = self:GetOwner();
	local curtime = CurTime();
	
	// not everything needs to run every think
	if ( curtime > self.DelayThink ) then
		
		// delay next think
		self.DelayThink = curtime + 0.5;
		
		// refresh position
		self:UpdatePosition( pl );
		
		// animate!
		self:RunAnimation();
		
		if ( curtime > self.DelayHaunt ) then
		
			self:HauntProp( pl, curtime );
			
		end
		
		self:SlowPlayer( pl, curtime );
		
		if ( pl:Team() == TEAM_PLAYERS ) then
		
			// flashlight shit
			self:PreventFlashlight( pl, curtime );
			
		end
		
	end
	
	// think fast!
	self:NextThink( curtime );
	return true;

end
