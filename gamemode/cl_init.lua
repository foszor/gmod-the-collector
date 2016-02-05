
// includ files
include( 'shared.lua' );
include ( 'vgui_block.lua' );
include ( 'vgui_compass.lua' );

// globals
local playerinit = false;
local stinger_nextsound;
local screen_shaketime = 0;
local screen_flickerstart = 99999;
local screen_flickerend = 0;
local screen_brightness = -0.2;
local screen_barheight;
local screen_spot_texture = surface.GetTextureID( "Decals/beersplash" );
local bgmusic_sound;
local bgmusic_volume = 0.01;
local bgmusic_silenttime = 0;
local bgmusic_nextsilenttime = 0;
local scaremusic_sound;
local blood_texture1 = surface.GetTextureID( "effects/blood_core" );
local blood_texture2 = surface.GetTextureID( "effects/blood_gore" );
local blood_texture3 = surface.GetTextureID( "effects/blood2" );
local slowmostart;
local slowmoend;
local slowmotime = -9;
local blood_alpha1;
local blood_alpha2;
local blood_alpha3;
local quest_type = 0;


// fonts
surface.CreateFont( "My type of font", ScreenScale( 16 ), 100, true, false, "QuestTitle" );
surface.CreateFont( "My type of font", ScreenScale( 8 ), 1, true, false, "HUDTop" );


// music tracks
local bgmusic_tracks = {

	Sound( "music/HL2_song1.mp3" ),
	Sound( "music/HL2_song7.mp3" ),
	Sound( "music/HL2_song8.mp3" ),
	Sound( "music/HL2_song13.mp3" )

};

// scare sounds
local scare_sounds = {
	
	Sound( "ambient/levels/citadel/strange_talk1.wav" ),
	Sound( "ambient/levels/citadel/strange_talk11.wav" ),
	Sound( "ambient/levels/citadel/strange_talk8.wav" )
	
};

// stinger sounds
local stinger_sounds = {
	
	Sound( "ambient/creatures/town_scared_breathing2.wav" ),
	Sound( "ambient/creatures/town_scared_breathing1.wav" ),
	Sound( "ambient/creatures/town_muffled_cry1.wav" ),
	Sound( "ambient/creatures/town_child_scream1.wav" ),
	Sound( "ambient/levels/streetwar/city_scream3.wav" ),
	Sound( "ambient/creatures/town_scared_sob1.wav" ),
	Sound( "ambient/creatures/town_scared_sob2.wav" )
	
};

// hallucination screams
local hallucinate_scream_sounds = {

	Sound( "npc/zombie_poison/pz_throw2.wav" ),
	Sound( "npc/zombie_poison/pz_throw3.wav" ),
	Sound( "npc/fast_zombie/leap1.wav" ),
	Sound( "npc/fast_zombie/wake1.wav" ),
	
};

// hallucination attack sounds
local hallucinate_attack_sounds = {

	Sound( "npc/fast_zombie/claw_strike1.wav" ),
	Sound( "npc/fast_zombie/claw_strike2.wav" )
	
};

// screen color
local colormod = {

	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1.2,
	[ "$pp_colour_colour" ] = 0.1,
	[ "$pp_colour_mulr" ] = 0.3,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
	
};

// hidden hud elements
local disabledhud = {

	[ "CHudSuitPower" ] = 1,
	[ "CHudHealth" ] = 1,
	[ "CHudBattery" ] = 1,
	[ "CHudAmmo" ] = 1,
	[ "CHudSecondaryAmmo" ] = 1,
	[ "CHudCrosshair" ] = 1,
	[ "CHudWeapon" ] = 1,
	[ "CHudVehicle" ] = 1
	
};


/*------------------------------------
	Initialize()
------------------------------------*/
function GM:Initialize()

	// randomize
	math.randomseed( os.time() );
	
end


/*------------------------------------
	StartBackgroundMusic()
------------------------------------*/
local function StartBackgroundMusic()

	// stop music if needed
	if ( bgmusic_sound ) then
	
		bgmusic_sound:Stop();
		timer.Remove( 'bgmusic' );
		
	end
	
	// select a random tract
	local sound = table.Random( bgmusic_tracks );
	
	// play music
	bgmusic_sound = CreateSound( LocalPlayer(), sound );
	bgmusic_volume = 0.01;
	bgmusic_sound:Play();
	bgmusic_sound:ChangeVolume( bgmusic_volume );
	print( "music " .. sound );
	
	// start over when finished
	timer.Create( 'bgmusic', SoundDuration( sound ), 1, function() StartBackgroundMusic() end );

end


/*------------------------------------
	UpdateBackgroundMusic()
------------------------------------*/
local function UpdateBackgroundMusic( curtime )

	// time to update
	if ( bgmusic_sound ) then
		
		// calculate target volume level
		local volumetarget = ( bgmusic_silenttime > curtime ) && 0.01 || 0.3;
		
		// calculate speed
		local delta = ( volumetarget < bgmusic_volume ) && 0.3 || 0.03;
		
		// update volume
		local last = bgmusic_volume;
		bgmusic_volume = math.Approach( bgmusic_volume, volumetarget, FrameTime() * delta );
		if ( last != bgmusic_volume ) then
		
			bgmusic_sound:ChangeVolume( bgmusic_volume );
			
		end
		
	end

end


/*------------------------------------
	PostProcessPermitted()
------------------------------------*/
function GM:PlayerInitialize()

	// turn off teeth (transparent player models look silly with them on!)
	RunConsoleCommand( "r_teeth", "0" );
	
	// get player
	local pl = LocalPlayer();
	
	// still spectating
	if ( pl:Team() != TEAM_PLAYERS ) then
		
		return;
		
	end
	
	// create compass (if needed)
	if ( !self.Compass ) then
	
		self.Compass = vgui.Create( "CollectorCompass" );
		
	end
	
	// start music
	StartBackgroundMusic();
	
end


/*------------------------------------
	PostProcessPermitted()
------------------------------------*/
function GM:PostProcessPermitted( str )

	// nope
	return false;

end


/*------------------------------------
	ScreenColor()
------------------------------------*/
local function ScreenColor( pl, speed, curtime )

	// check if running
	local running = ( speed > 100 );
	local alive = pl:Alive();
	
	// set target brightness
	local targetbrightness = ( running ) && -0.35 || -0.08;
	if ( !alive ) then
	
		targetbrightness = -1;
		
	else
	
		if ( screen_brightness < -0.35 ) then
		
			screen_brightness = -0.35;
		
		end
		
	end
	
	// special handling for spectators
	if ( pl:Team() != TEAM_PLAYERS ) then
	
		targetbrightness = -0.2;
		running = false;
		
	end
	
	// determine how fast to interpolate
	local delta = ( running ) && 0.035 || 0.055;
	if ( !alive ) then
	
		delta = 0.1;
		
	end
	
	// interpolate brightness
	screen_brightness = math.Approach( screen_brightness, targetbrightness, FrameTime() * delta );
	colormod[ "$pp_colour_brightness" ] = screen_brightness;
	
	// check if we're in slow motion
	if ( curtime - slowmotime <= SLOWMO_DURATION ) then
	
		screen_brightness = -0.08;
	
	end
	
	// force a screen flicker?
	local forceflicker = ( math.random( 1, ( screen_brightness < -0.18 ) && 200 || 650 ) == 1 );
	
	// flicker the screen
	if ( ( curtime >= screen_flickerstart && curtime <= screen_flickerend && math.random( 1, 3 ) == 2 ) || forceflicker ) then
	
		colormod[ "$pp_colour_brightness" ] = math.random( 8, 35 ) * -0.01;
	
	end
	
	// push to screen
	DrawColorModify( colormod );
	
end


/*------------------------------------
	ScreenBloom()
------------------------------------*/
local function ScreenBloom( pl, speed, curtime )

	DrawBloom( 0.75, 1.2, 8, 8, 1, 0, 1, 1, 1 );
	
end


/*------------------------------------
	ScreenShake()
------------------------------------*/
local function ScreenShake( pl, speed, curtime )

	if ( screen_shaketime > curtime ) then
	
		DrawSharpen( 1.01, 0.8 );
		DrawMotionBlur( 0.1, 0.2, 0.02 );
		
	end
	
end



/*------------------------------------
	RenderScreenspaceEffects()
------------------------------------*/
function GM:RenderScreenspaceEffects()

	// get reused values
	local pl = LocalPlayer();
	local speed = pl:GetVelocity():Length();
	local curtime = CurTime();
	
	// color
	ScreenColor( pl, speed, curtime );
	
	// bloom
	ScreenBloom( pl, speed, curtime );
	
	// shake
	ScreenShake( pl, speed, curtime );

end


/*------------------------------------
	CalcView()
------------------------------------*/
function GM:CalcView( pl, origin, angles, fov )

	local curtime = CurTime();

	// get their ragdoll
	local ragdoll = pl:GetRagdollEntity();
	if( IsValid( ragdoll ) ) then
		
		// find the eyes
		local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) );
		if( eyes ) then
			
			// use eyes
			origin = eyes.Pos;
			angles = eyes.Ang;
			
		end
		
		// hide ragdoll
		ragdoll:SetColor( 255, 255, 255, 0 );
		ragdoll:SetNoDraw( true );
		
	end
	
	// create new view
	local view = {};
	view.origin = origin;
	
	// slowly roll back and forth
	local roll = math.Clamp( ( angles.pitch + 5 ) * 0.2, -6, 6 );
	roll = roll * math.sin( curtime * 0.08 );
	view.angles = angles + Angle( 0, 0, roll );
	
	// apply a screen shake
	if ( screen_shaketime > curtime ) then
		
		local str = 1;
		view.origin = view.origin + Vector( math.random( -str, str ), math.random( -str, str ), math.random( -str, str ) );
		
	end
	
	// slowly zoom in and out
	view.fov = 100 + ( math.sin( curtime * 0.09 ) * 3 );
	
	// check if we're in slow motion
	if ( curtime - slowmotime <= SLOWMO_DURATION ) then
	
		// calculate percentage complete
		local p = ( ( slowmotime + SLOWMO_DURATION ) - curtime ) / 8;
		
		// find the camera position
		local newpos = LerpVector( 1 - p, slowmostart, slowmoend );

		// calculate direction
		local dir = ( slowmoend - newpos ):Normalize();
		
		// override
		view.origin = newpos;
		view.angles = dir:Angle();
		
		// zoom out over time
		view.fov = 100 - ( 60 * p );
		
		if( IsValid( ragdoll ) ) then
		
			// show ragdoll
			ragdoll:SetColor( 255, 255, 255, 255 );
			ragdoll:SetNoDraw( false );
			
		end
		
	end
		
	return view;

end


/*------------------------------------
	HUDShouldDraw()
------------------------------------*/
function GM:HUDShouldDraw( name )

	// validate player
	local pl = LocalPlayer();
	if ( !ValidEntity( pl ) ) then
	
		return;
		
	end
	
	// dead players dont show damage
	if ( ( pl:Health() <= 0 ) && name == "CHudDamageIndicator" ) then
	
		return false;
		
	end
	
	return ( disabledhud[ name ] == nil );
		
end


/*------------------------------------
	DrawHUD()
------------------------------------*/
local function DrawHUD( sw, sh, curtime )

	// calculate target bar height
	local targetheight = sh * 0.05;
	
	// increase during shake
	if ( screen_shaketime > curtime ) then
	
		targetheight = targetheight * 2;
		
	end
	
	// set to default if needed
	screen_barheight = screen_barheight or targetheight;
	
	// interpolate the bar height
	screen_barheight = math.Approach( screen_barheight, targetheight, FrameTime() * ( math.abs( targetheight - screen_barheight ) + 1 ) * 10 );
	local h = math.floor( screen_barheight );
	
	// draw black bars
	surface.SetDrawColor( 0, 0, 0, 255 );
	surface.DrawRect( 0, 0, sw, h );
	surface.DrawRect( 0, sh - h, sw, h );
	
	// draw white lines
	surface.SetDrawColor( 255, 255, 255, 20 );
	surface.DrawRect( 0, h, sw, 1 );
	surface.DrawRect( 0, sh - h - 1, sw, 1 );
	
	if ( LocalPlayer():Team() == TEAM_PLAYERS ) then
	
		draw.SimpleText( "[f1] quest tips    [f2] spectate", "HUDTop", sw * 0.5, 2, Color( 255, 255, 255, 70 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP );
		
	else
	
		draw.SimpleText( "[f1] overview    [f2] begin playing", "HUDTop", sw * 0.5, 2, Color( 255, 255, 255, 70 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP );
	
	end
	
	local quest = "";
	if ( quest_type == QUEST_ENIGMA ) then
	
		quest = "Enigma";
		
	elseif ( quest_type == QUEST_CONSUMPTION ) then
	
		quest = "Consumption";
		
	elseif ( quest_type == QUEST_IMMOLATE ) then
	
		quest = "Immolate";
		
	elseif ( quest_type == QUEST_ASCENSION ) then
	
		quest = "Ascension";
		
	elseif ( quest_type == QUEST_FUSION ) then
	
		quest = "Fusion";
		
	elseif ( quest_type == QUEST_EXODUS ) then
	
		quest = "Exodus";
		
	end
	
	draw.SimpleText( quest, "QuestTitle", 2, sh - 2 - ScreenScale( 16 ), Color( 255, 255, 255, 80 + ( math.sin( curtime ) * 40 ) ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP );

end


/*------------------------------------
	DrawScreenSpots()
------------------------------------*/
local function DrawScreenSpots( sw, sh, curtime )

	// determine if we should draw a spot
	if ( ( curtime >= screen_flickerstart && curtime <= screen_flickerend && math.random( 1, 3 ) == 1 ) || math.random( 1, 400 ) == 2 ) then
	
		// calculate size
		local size = sh * 0.5;

		// randomly size it
		local w = size * ( math.random( 5, 12 ) * 0.1 );
		local h = size * ( math.random( 5, 12 ) * 0.1 );
		
		// randomly position it
		local x = math.random( w, sw );
		local y = math.random( h, sh );
		
		// render
		surface.SetTexture( screen_spot_texture);
		surface.SetDrawColor( 0, 0, 0, 255 );
		surface.DrawTexturedRectRotated( x, y, w, h, math.random( 0, 360 ) );
		
	end
	
end


/*------------------------------------
	HUDDrawTargetID()
------------------------------------*/
function GM:HUDDrawTargetID()

	// get local player
	local lp = LocalPlayer();
	
	// cycle all players
	for _, pl in pairs( player.GetAll() ) do
	
		// validate player
		if ( pl:Team() == TEAM_PLAYERS && pl:Alive() && pl != lp ) then
		
			// calculate distance
			local dist = ( lp:GetPos() - pl:GetPos() ):Length();
			if ( dist < 300 ) then
				
				// create position
				local pos = ( pl:GetShootPos() + Vector( 0, 0, 12 ) ):ToScreen();
				
				// calculate alpha
				local alpha = 180 - ( ( dist / 300 ) * 180 );
				
				// show text over their head
				draw.DrawText( pl:Name(), "Default", pos.x, pos.y, Color( 255, 255, 255, alpha ), TEXT_ALIGN_CENTER );
			
			end
			
		end
	
	end

end


/*------------------------------------
	DrawHealth()
------------------------------------*/
local function DrawHealth( hp, sw, sh )
	
	// no blood should show
	if ( hp >= 100 ) then

		blood_alpha1 = 0;
		blood_alpha2 = 0;
		blood_alpha3 = 0;	
		return;
		
	end
	
	// fade speed
	local delta = FrameTime() * 100;
	
	// calculate blood spot 1
	local target = ( 255 / 20 ) * math.min( 100 - hp, 20 );
	blood_alpha1 = blood_alpha1 or target;
	blood_alpha1 = math.Approach( blood_alpha1, target, delta );
	blood_alpha1 = math.max( target, blood_alpha1 );
	surface.SetDrawColor( Color( 70, 0, 0, blood_alpha1 ) );
	
	// figure out position
	local x = sw * 0.02;
	local y = 0;
	local size = sh * 0.6;
	
	// draw
	surface.SetTexture( blood_texture1 );
	surface.DrawTexturedRect( x, y, size, size );
	
	if ( hp >= 80 ) then
	
		return;
		
	end
	
	local target = ( 255 / 30 ) * math.min( 30, 80 - hp );
	blood_alpha2 = blood_alpha2 or target;
	blood_alpha2 = math.Approach( blood_alpha2, target, delta );
	blood_alpha2 = math.max( target, blood_alpha2 );
	surface.SetDrawColor( Color( 70, 0, 0, blood_alpha2 ) );
	
	x = sw - size - ( sw * 0.05 );
	y = sh - size - ( sh * 0.1 );
	size = sh * 0.7;
	
	surface.SetTexture( blood_texture2 );
	surface.DrawTexturedRect( x, y, size, size );
	
	if ( hp >= 50 ) then
	
		return;
		
	end
	
	local target = ( 255 / 30 ) * math.min( 30, 50 - hp );
	blood_alpha3 = blood_alpha3 or target;
	blood_alpha3 = math.Approach( blood_alpha3, target, delta );
	blood_alpha3 = math.max( target, blood_alpha3 );
	surface.SetDrawColor( Color( 70, 0, 0, blood_alpha3 ) );
	
	size = sh * 0.5;
	x = 0;
	y = sh - size;
	
	surface.SetTexture( blood_texture3 );
	surface.DrawTexturedRect( x, y, size, size );
	
end


/*------------------------------------
	HUDPaint()
------------------------------------*/
function GM:HUDPaint()

	local sw = ScrW();
	local sh = ScrH();
	local curtime = CurTime();
	local pl = LocalPlayer();
	
	if ( !ValidEntity( pl ) ) then
	
		return;
		
	end
	
	DrawHUD( sw, sh, curtime );
	
	local hp = pl:Health();
	
	if ( pl:Team() == TEAM_PLAYERS && hp > 0 ) then
		
		DrawHealth( hp, sw, sh );
		
	end
	
	DrawScreenSpots( sw, sh, curtime );
	
	self:HUDDrawTargetID();

end


/*------------------------------------
	StingerSounds()
------------------------------------*/
local function StingerSounds( curtime )

	// initial delay
	stinger_nextsound = stinger_nextsound || curtime + math.random( 20, 70 );
	
	// not time yet!
	if ( curtime < stinger_nextsound ) then
	
		return;
		
	end
	
	// find a unique sound
	local sound = table.Random( stinger_sounds );
	while ( sound == stinger_nextsound ) do
	
		sound = table.Random( stinger_sounds );
		
	end
	
	// get sound length
	local len = SoundDuration( sound );
	
	// delay next stinger
	stinger_nextsound = curtime + len + math.random( 50, 80 );
	
	// play sound
	surface.PlaySound( sound );
	
	// add some screen shake
	screen_shaketime = curtime + ( len * 0.2 );
	
	// silence the music (if it isnt too soon)
	if ( curtime > bgmusic_nextsilenttime ) then
	
		bgmusic_silenttime = curtime + len + 2;
		bgmusic_nextsilenttime = bgmusic_silenttime + 2;
	
	end
	
end


/*------------------------------------
	ScreenFlicker()
------------------------------------*/
local function ScreenFlicker( curtime )

	// initial delay
	if ( screen_flickerend == 0 ) then
		
		screen_flickerend = curtime + math.random( 20, 40 );
		
	end
	
	// time to flicker
	if ( curtime > ( screen_flickerend + 5 ) ) then
	
		// randomize flickering
		if ( math.random( 1, 850 ) == 2 ) then
			
			// set the flickering times
			screen_flickerstart = curtime + math.random( 1, 2 );
			screen_flickerend = screen_flickerstart + math.random( 3, 10 ) * 0.1;	
			
		end
		
	end
	
end


/*------------------------------------
	Think()
------------------------------------*/
function GM:Think()

	// validate player
	local pl = LocalPlayer();
	if ( !ValidEntity( pl ) ) then
	
		return;
		
	end
	
	// check for spectators and dead people
	if ( pl:Team() != TEAM_PLAYERS || pl:Health() <= 0 ) then
	
		// stop music if needed
		if ( bgmusic_sound ) then
		
			bgmusic_sound:Stop();
			bgmusic_sound = nil;
			timer.Remove( 'bgmusic' );
			
		end
		playerinit = false;
		return;
		
	end

	// initialize the player if needed
	if ( !playerinit ) then
		
		playerinit = true;
		self:PlayerInitialize();
		
	end
	
	// get current time
	local curtime = CurTime();
	
	// run the scary stuff
	StingerSounds( curtime );
	ScreenFlicker( curtime );
	
	// keep music playing
	UpdateBackgroundMusic( curtime );

end


/*------------------------------------
	PlayerBindPress()
------------------------------------*/
function GM:PlayerBindPress( pl, bind, pressed )

	// disable jump
	if ( string.find( bind, "+jump" ) && pressed ) then
	
		// allow jumping on ladders (thx chad)
		if ( pl:GetMoveType() == MOVETYPE_LADDER ) then
		
			return false;
			
		end
		
		return true;
		
	end

end


/*------------------------------------
	PlayScareSound()
------------------------------------*/
local function PlayScareSound()

	local curtime = CurTime();
	
	// delay not met yet
	if ( curtime < bgmusic_nextsilenttime ) then
	
		return;
		
	end
	
	// select a sound
	local sound = table.Random( scare_sounds );
	
	// get duration
	local len = SoundDuration( sound );
	
	// set silent times
	bgmusic_silenttime = curtime + len + 4;
	bgmusic_nextsilenttime = bgmusic_silenttime + 2;
	
	// stop any existing sound
	if ( scaremusic_sound ) then
		
		scaremusic_sound:Stop();
		
	end
	
	// play sound
	scaremusic_sound = CreateSound( LocalPlayer(), sound );
	scaremusic_sound:Play();
	scaremusic_sound:ChangeVolume( 0.3 );

end


/*------------------------------------
	HallucinationAttack()
------------------------------------*/
local function HallucinationAttack()
	
	// get info
	local curtime = CurTime();
	local pl = LocalPlayer();
	
	pl.HallucinateTime = curtime + 0.28;
	
	// play sounds
	surface.PlaySound( table.Random( hallucinate_scream_sounds ) );
	surface.PlaySound( table.Random( hallucinate_attack_sounds ) );

	// darken screen
	screen_brightness = -0.3;
	
	// add some screen shake
	screen_shaketime = curtime + 0.6;
	
	PlayScareSound();

end
usermessage.Hook( "hallucinate", HallucinationAttack );



/*------------------------------------
	SlowMoWatch()
------------------------------------*/
local function SlowMoWatch( msg )

	slowmostart = msg:ReadVector();
	slowmoend = msg:ReadVector();
	slowmotime = CurTime();
	surface.PlaySound( "npc/scanner/scanner_nearmiss1.wav" );

end
usermessage.Hook( "slowmowatch", SlowMoWatch );


/*------------------------------------
	QuestUpdate()
------------------------------------*/
local function QuestUpdate( msg )

	quest_type = msg:ReadShort();

end
usermessage.Hook( "questupdate", QuestUpdate );
