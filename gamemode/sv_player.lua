
local HPREGEN_TIME = 5;
local HPREGEN_AMOUNT = 12;

/*------------------------------------
	PlayerInitialSpawn()
------------------------------------*/
function GM:PlayerInitialSpawn( pl )

	// start as spectator
	pl:SetTeam( TEAM_SPECTATOR );
	
end


/*------------------------------------
	PlayerLoadout()
------------------------------------*/
function GM:PlayerLoadout( pl )
	
end


/*------------------------------------
	PlayerSetModel()
------------------------------------*/
function GM:PlayerSetModel( pl )

	if ( pl:Team() == TEAM_PLAYERS ) then
		
		// select a random model
		pl.PlayerModel = pl.PlayerModel or table.Random( self.PlayerModelList );
		
		// set model
		pl:SetModel( pl.PlayerModel );
		
	end

end


/*------------------------------------
	PlayerSelectSpawn()
------------------------------------*/
function GM:PlayerSelectSpawn( pl )

	local alive = {};
	for _, p in pairs( player.GetAll() ) do
	
		if ( p:Alive() && p:Team() == TEAM_PLAYERS && p != pl ) then
		
			table.insert( alive, p );
		
		end
	
	end
	
	if ( #alive == 0 ) then
	
		self:CleanMap();
		return self.SpawnPoint;
		
	end
	
	local rand = table.Random( alive );
	
	local pos = rand:GetPos();
	
	if ( #rand.TrackPositions > 0 ) then
	
		for i = 1, #rand.TrackPositions do
		
			local check = rand.TrackPositions[ i ];
			
			if ( EntityClear( rand, check ) ) then
			
				pos = rand.TrackPositions[ i ];
				break;
				
			end
		
		end
	
	end
	
	if ( !pos ) then
	
		return self.SpawnPoint;
		
	end
	
	local e = ents.Create( "info_target" );
	e:SetPos( pos );
	e:Spawn();
	
	SafeRemoveEntityDelayed( e, 2 );
	
	return e;
	
end


/*------------------------------------
	PlayerInitialSpawn()
------------------------------------*/
function GM:PlayerSpawn( pl )

	// base class
	self.BaseClass.PlayerSpawn( self, pl );
	
	// spooky DSP effect
	pl:SetDSP( 2, false );
	
	if ( pl:Team() == TEAM_PLAYERS ) then
		
		// movement
		pl:SetWalkSpeed( 115 );
		pl:SetRunSpeed( 180 );
		pl:SetCrouchedWalkSpeed( 0.85 );
		pl:SetJumpPower( 0 );
		
		pl.TrackPositions = {};
		pl.LastFlashlightToggle = CurTime();
		
		// make them appear ghostly
		pl:SetKeyValue( "renderfx", 16 );
		
		// create haunt
		pl.HauntEntity = ents.Create( "player_haunt" );
		pl.HauntEntity:SetPos( pl:GetPos() );
		pl.HauntEntity:SetOwner( pl );
		pl.HauntEntity:Spawn();
		
		pl:SetCollisionGroup( COLLISION_GROUP_WEAPON );
		
		self:SendQuestUpdate( pl );
		
	else
	
		pl:Spectate( OBS_MODE_FIXED );
		
		// hax for bots
		if ( pl:SteamID() == "BOT" ) then
		
			timer.Simple( 1, function() GAMEMODE:ShowTeam( pl ) end );
			
		end
		
	end

end


/*------------------------------------
	SetPlayerAnimation()
------------------------------------*/
function GM:SetPlayerAnimation( pl, anim )

	if ( pl:Team() == TEAM_PLAYERS ) then
		
		// gather information about player
		local speed = pl:GetVelocity():Length();
		local ground = pl:OnGround();
		local duck = pl:KeyDown( IN_DUCK );
		local flashlight = pl:FlashlightIsOn();
		
		// default idle sequence
		local sequence = pl:LookupSequence( ( flashlight ) && "idle_alert_02" || "idle_subtle" );
		if ( duck ) then
		
			sequence = pl:LookupSequence( ( speed > 0 ) && "Crouch_walk_all" || "Crouch_idleD" );
		
		else
		
			// running sequence
			if ( speed > 140 ) then
				
				sequence = pl:LookupSequence( ( flashlight ) && "run_alert_holding_all" || "run_all" );
				
			// walking sequence
			elseif ( speed > 0 ) then
				
				sequence = pl:LookupSequence( ( flashlight ) && "walkAlertHOLDALL1" || "walk_all" );
				
			end
			
		end
		
		// dont restart unelss needed
		if ( pl:GetSequence() == sequence ) then
			
			return;
			
		end
		
		// play
		pl:SetPlaybackRate( 1.0 );
		pl:ResetSequence( sequence );
		pl:SetCycle( 0 );
		
	end
	
end


/*------------------------------------
	ClientThink()
------------------------------------*/
function GM:ClientThink( pl, curtime )

end


/*------------------------------------
	PlayerThink()
------------------------------------*/
function GM:PlayerThink( pl, curtime )
	
	if ( pl:Alive() ) then
	
		self:TrackPlayer( pl, curtime );
		self:ApplyFlashlight( pl, curtime );
		
		if ( curtime > ( pl.NextHpGen or 0 ) ) then
			
			pl.NextHpGen = curtime + HPREGEN_TIME;
			pl:SetHealth( math.Clamp( pl:Health() + HPREGEN_AMOUNT, 0, 100 ) );
			
		end
		
	end
	
end


/*------------------------------------
	FindInCone()
------------------------------------*/
local function FindInCone( pl, pos, dir, length, degrees )

	local pl_pos = pl:EyePos();

	local degreeDot = 1 - ( ( 1 / 180 ) * degrees );

	// find all entities that can possibly be in the cone we specified.
	local entities = ents.FindInSphere( pos, length );
	for i = #entities, 1, -1 do
	
		local ent = entities[ i ];
		
		local posEnt = ent:GetPos();
		local forward = ent:GetForward();
		local right = ent:GetRight();
		local up = ent:GetUp();
		local mins = ent:OBBMins();
		local maxs = ent:OBBMaxs();
		
		local cornerInView = false;
	
		// the test points corners
		local point = {};
		point[1] = Vector( 0, 0, 0 );
		point[2] = Vector( 0, mins.y, 0 );
		point[3] = Vector( 0, maxs.y, 0 );
		point[4] = Vector( maxs.x, 0, 0 );
		point[5] = Vector( mins.x, 0, 0 );
		point[6] = Vector( 0, 0, mins.z );
		point[7] = Vector( 0, 0, maxs.z );
		point[8] = mins;
		point[9] = Vector( maxs.x, mins.y, mins.z );
		point[10] = Vector( maxs.x, maxs.y, mins.z );
		point[11] = Vector( mins.x, maxs.y, mins.z );
		point[12] = maxs;
		point[13] = Vector( mins.x, maxs.y, maxs.z );
		point[14] = Vector( mins.x, mins.y, maxs.z );
		point[15] = Vector( maxs.x, mins.y, maxs.z );

		// ok, can't get away with a fast one, check corners
		for i = 1, 14 do
		
			local dirEnt = ( ent:LocalToWorld( point[i] ) - pos );
			dirEnt:Normalize();
		
			// check if its inside the view cone
			local dot = dirEnt:Dot( dir );
			if( dot > degreeDot ) then
			
				cornerInView = true;
				break;
			
			end
		
		end
		
		// found?
		if( !cornerInView || !ent:VisibleVec( pl_pos ) ) then
		
			table.remove( entities, i );
		
		end

	end
	
	return entities;

end


/*------------------------------------
	ApplyFlashlight()
------------------------------------*/
function GM:ApplyFlashlight( pl, curtime )

	if ( ( pl.NextApplyFlashlight or 0 ) > curtime ) then
	
		return;
		
	end
	
	pl.NextApplyFlashlight = curtime + 0.3;
	
	if ( !pl:FlashlightIsOn() ) then
	
		return;
		
	end
	
	// build trace
	local trace = {};
		trace.start = pl:EyePos();
		trace.endpos = ( trace.start + ( pl:EyeAngles():Forward() * PROP_HAUNT_DISTANCE ) );
		trace.filter = pl;
		
	// run trace
	local traceres = util.TraceLine( trace );
	
	if ( ValidEntity( traceres.Entity ) ) then
		
		local class = traceres.Entity:GetClass();
		if ( table.HasValue( self.PropClassList, class ) ) then
			
			traceres.Entity.LastLighted = curtime;
			
			if ( false ) then
				local mins, maxs = traceres.Entity:WorldSpaceAABB();
				local center = ( maxs + mins ) * 0.5;
				maxs = maxs - center;
				mins = mins - center;
				debugoverlay.Box( center, mins, maxs, 0, Color( 128, 255, 128, 64 ) );
			end
			
		end
	
	end
	
	local entlist = FindInCone( pl, pl:GetShootPos(), pl:GetAimVector(), PROP_HAUNT_DISTANCE, 5 );
	for _, ent in pairs( entlist ) do
	
		local class = ent:GetClass();
		if ( table.HasValue( self.PropClassList, class ) ) then
			
			ent.LastLighted = curtime;
			if ( false ) then
				local mins, maxs = traceres.Entity:WorldSpaceAABB();
				local center = ( maxs + mins ) * 0.5;
				maxs = maxs - center;
				mins = mins - center;
				debugoverlay.Box( center, mins, maxs, 0, Color( 128, 255, 128, 64 ) );
			end
			
		end
	
	end

end


/*------------------------------------
	TrackPlayer()
------------------------------------*/
function GM:TrackPlayer( pl, curtime )
	
	pl.NextTrackTime = pl.NextTrackTime or 0;
	if ( curtime < pl.NextTrackTime || !pl:OnGround() || !pl:GetGroundEntity() ) then
		
		return;
		
	end
	
	pl.NextTrackTime = curtime + 0.8;
	
	local curpos = pl:GetPos();
	
	local lastpos = pl.TrackPositions[ 1 ];
	if ( !lastpos ) then
		
		table.insert( pl.TrackPositions, 1, curpos );
		return;
		
	end
		
	local dist = ( lastpos - curpos ):Length();
	if ( dist < 64 ) then
		
		return;
		
	end
	
	table.insert( pl.TrackPositions, 1, curpos );
	
	if ( false ) then
	
		for _, track in pairs( pl.TrackPositions ) do
		
			local color = EntityClear( pl, track ) && Color( 100, 255, 100, 64 ) || Color( 255, 100, 100, 64 );
			debugoverlay.Box( track, Vector( -16, -16, 0 ), Vector( 16, 16, 32 ), 0.8, color );
		
		end
		
	end
	
	pl.TrackPositions[ 6 ] = nil;

end


/*------------------------------------
	PlayerNoClip()
------------------------------------*/
function GM:PlayerNoClip( pl )

	return true;
	
end


/*------------------------------------
	PlayerHurt()
------------------------------------*/
function GM:PlayerHurt( pl, attacker )

	if ( ValidEntity( attacker ) && attacker:IsNPC() && attacker.Terror ) then
	
		attacker:Remove();
		
	end
	
	if ( pl:Alive() ) then
	
		local curtime = CurTime();
		
		if ( curtime - ( pl.LastPainNoise or 0 ) > 0.6 ) then
		
			pl:EmitSound( Sound( "vo/npc/male01/pain0" .. math.random( 1, 6 ) .. ".wav" ) );
		
		end
		pl.NextHpGen = curtime + HPREGEN_TIME;
		pl.LastPainNoise = curtime;
		
	end

end



/*------------------------------------
	EntityTakeDamage()
------------------------------------*/
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

	if ( !ValidEntity( ent ) ) then
	
		return;
		
	end

	if ( ent:IsPlayer() ) then
	
		local class = inflictor:GetClass();
		local parent = inflictor:GetParent();
		
		if ( class == "entityflame" && ValidEntity( parent ) && parent:IsPlayer() && parent != ent ) then
			
			dmginfo:ScaleDamage( 0 );
			
		elseif ( self.IsSlowMo ) then
		
			dmginfo:ScaleDamage( 0 );
			
		else
		
			if ( dmginfo:GetDamage() > 50 ) then
			
				dmginfo:SetDamage( 50 );
				
			end
			
			if( dmginfo:IsDamageType( DMG_BURN ) ) then
			
				dmginfo:ScaleDamage( 4 );
			
			end
			
		end
		
	elseif ( table.HasValue( self.PropClassList, ent:GetClass() ) ) then
	
		local class = inflictor:GetClass();
		local parent = inflictor:GetParent();
	
		if ( class == "entityflame" && ValidEntity( parent ) && parent:IsPlayer() ) then
		
			self:QuestsBurntEntity( ent, parent );
			
		end
	
	end

end


/*------------------------------------
	PlayerDeathSound()
------------------------------------*/
function GM:PlayerDeathSound()

	return true;
	
end


/*------------------------------------
	SlowDown()
------------------------------------*/
local function SlowDown()

	game.ConsoleCommand( "phys_timescale 0.2\n" );

end


/*------------------------------------
	PlayerDeathSound()
------------------------------------*/
local function SpeedUp()

	game.ConsoleCommand( "phys_timescale 1\n" );
	GAMEMODE.IsSlowMo = false;

end


function _R.Player:CreateRagdollServer()
	if CLIENT then return end
	if not ( self and self.IsValid and self.IsPlayer and self:IsValid() and self:IsPlayer()) then return Error("No player given.\n") end
	
	local ply_pos = self:GetPos()
	local ply_ang = self:GetAngles()
	local ply_mdl = self:GetModel()
	local ply_skn = self:GetSkin()
	local ply_col = self:GetColor()
	local ply_mat = self:GetMaterial()
	
	local ent = ents.Create("prop_ragdoll")
	ent:SetPos(ply_pos)
	ent:SetAngles(ply_ang - Angle(ply_ang.p,0,0))
	ent:SetModel(ply_mdl)
	ent:SetSkin(ply_skn)
	ent:SetMaterial(ply_mat)
	ent:Spawn()
	
	SafeRemoveEntityDelayed( ent, 10 );
	
	if not ent:IsValid() then return end
	
	local plyvel = self:GetVelocity()

	for i = 1, ent:GetPhysicsObjectCount() do
		local bone = ent:GetPhysicsObjectNum(i)
		
		if bone and bone.IsValid and bone:IsValid() then
			local bonepos, boneang = self:GetBonePosition(ent:TranslatePhysBoneToBone(i))
			
			bone:SetPos(bonepos)
			bone:SetAngle(boneang)
			
			bone:AddVelocity(plyvel)
		end
	end
	
end


/*------------------------------------
	DoPlayerDeath()
------------------------------------*/
function GM:DoPlayerDeath( pl, attacker, dmginfo )

	pl:AddDeaths( 1 );
	
	local curtime = CurTime();
	
	if ( curtime > self.NextSlowMo && ValidEntity( attacker ) && dmginfo:GetDamage() >= 4 && attacker.OldPos ) then
	
		local class = attacker:GetClass();
		if ( table.HasValue( self.PropClassList, class ) ) then
	
			local plpos = pl:GetShootPos();
		
			local dist = ( attacker.OldPos - plpos ):Length();
			
			if ( dist >= 160 ) then
			
				SlowDown();
				
				umsg.Start( "slowmowatch" );
				umsg.Vector( attacker.OldPos + Vector( 0, 0, 8 ) );
				umsg.Vector( plpos - Vector( 0, 0, 30 ) );
				umsg.End();
				
				self.IsSlowMo = true;
				self.NextSlowMo = curtime + 30;
				
				timer.Simple( 3, SpeedUp );
				
			end
			
		end
		
	end
	
	pl:CreateRagdollServer();
	//pl:CreateRagdoll();
	
end


/*------------------------------------
	PlayerDeath()
------------------------------------*/
function GM:PlayerDeath( pl, inflictor, attacker )

	if ( ValidEntity( pl.HauntEntity ) ) then
	
		pl.HauntEntity:ReleaseProp();
		pl.HauntEntity:Remove();
		
	end
	
	pl:EmitSound( Sound( "vo/npc/male01/pain0" .. math.random( 7, 9 ) .. ".wav" ) );
	
	pl.DeathTime = CurTime();
	
	MessageAll( pl:Name() .. " died." );
	
end


/*------------------------------------
	PlayerDeathThink()
------------------------------------*/
function GM:PlayerDeathThink( pl )

	local curtime = CurTime();

	if ( curtime - ( pl.DeathTime or curtime ) > 10 ) then
	
		pl:Spawn();
	
	end

end


/*------------------------------------
	PlayerSwitchFlashlight()
------------------------------------*/
function GM:PlayerSwitchFlashlight( pl, state )

	if ( pl:Team() != TEAM_PLAYERS ) then
	
		return false;
		
	end

	if ( !state ) then
	
		pl.LastFlashlightToggle = CurTime();
		return true;
		
	end
	
	return ( CurTime() - ( pl.LastFlashlightToggle or 0 ) > 1.25 );

end


/*------------------------------------
	PlayerDisconnected()
------------------------------------*/
function GM:PlayerDisconnected( pl )

	if ( ValidEntity( pl.HauntEntity ) ) then
	
		pl.HauntEntity:ReleaseProp();
		pl.HauntEntity:Remove();
		
	end
	
end


/*------------------------------------
	CanPlayerSuicide()
------------------------------------*/
function GM:CanPlayerSuicide( pl )

	return ( pl:Team() == TEAM_PLAYERS );

end
