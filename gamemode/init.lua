
// client files
AddCSLuaFile( 'cl_init.lua' );
AddCSLuaFile( 'shared.lua' );
AddCSLuaFile( 'vgui_block.lua' );
AddCSLuaFile( 'vgui_compass.lua' );

resource.AddFile( "gamemodes/collector/content/resource/fonts/mytype.ttf" );

// include files
include( 'shared.lua' );
include( 'sv_player.lua' );
include( 'sv_quests.lua' );


// constants
PROP_HAUNT_DISTANCE 		= 256;
PROP_HAUNT_MASS 			= 300;
PROP_ATTACK_DISTANCE 		= 200;


// types of explosive props
EXPLOSIVE_PROPS = {
	
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_junk/propane_tank001a.mdl",
	"models/props_junk/gascan001a.mdl"

};


/*------------------------------------
	Initialize()
------------------------------------*/
function GM:Initialize()

	// base class
	self.BaseClass.Initialize( self );
	
	// randomize
	math.randomseed( os.time() );
	game.ConsoleCommand( "phys_timescale 1\n" );
	self.IsSlowMo = false;
	self.NextSlowMo = 0;
	
end


/*------------------------------------
	FixProps()
------------------------------------*/
local function FixProps()
	
	// check each type
	for _, proptype in pairs( GAMEMODE.PropClassList ) do
		
		// find the props
		local props = ents.FindByClass( proptype );
		for _, prop in pairs( props ) do
		
			prop:SetCollisionGroup( COLLISION_GROUP_NONE );
			
		end
		
	end

end


/*------------------------------------
	CleanMap()
------------------------------------*/
function GM:CleanMap()

	// revert the map
	//game.CleanUpMap(); WTF CRASHES?

	// entity count
	local count = 0;
	
	// remove non-compatible entities (they fork up the gameplay!)
	local classlist = { "item*", "weapon*", "collector_orb" };
	for _, class in pairs( classlist ) do
	
		// find each class
		for _, ent in pairs( ents.FindByClass( class ) ) do
		
			// remove and count entity
			SafeRemoveEntity( ent );
			count = count + 1;
		
		end
		
	end
	
	self.OrbCount = 0;
	
	// prop count
	local pcount = 0;
	
	// check each type
	for _, proptype in pairs( self.PropClassList ) do
		
		// find the props
		local props = ents.FindByClass( proptype );
		for _, prop in pairs( props ) do
		
			prop.Orbed = nil;
			
			// check if the prop is too close to the players start
			if ( ( prop:GetPos() - self.SpawnPoint:GetPos() ):Length() <= PROP_HAUNT_DISTANCE + 10 ) then
			
				local obj = prop:GetPhysicsObject();
				if ( ValidEntity( obj ) && obj:GetMass() < PROP_HAUNT_MASS ) then
				
					// remove and count propp
					pcount = pcount + 1;
					SafeRemoveEntity( prop );
					
				end
				
			end
			
		end
		
	end
	
	// notify
	print( "Removed " .. count .. " non-compatible map entities and " .. pcount .. " spawn invasive props." );
	
	FixProps();

end


/*------------------------------------
	InitPostEntity()
------------------------------------*/
function GM:InitPostEntity()
	
	// types of spawn entities to use
	local spawnlist = {
		
		"info_player_counterterrorist",
		"info_player_deathmatch",
		"info_player_rebel",
		"info_player_combine",
		"info_player_start"
		
	};
	
	// check each type
	for _, spawntype in pairs( spawnlist ) do
		
		// find the spawn entities
		local spawns = ents.FindByClass( spawntype );
		if ( spawns && #spawns > 0 ) then
			
			// save one
			self.SpawnPoint = spawns[ 1 ];
			print( "Using spawn point " .. tostring( self.SpawnPoint ) );
			break;
			
		end
		
	end
	
	FixProps();

end


/*------------------------------------
	Think()
------------------------------------*/
function GM:Think()

	// get time
	local curtime = CurTime();
	
	local players = 0;
	local specs = 0;
	
	// cycle all players
	for _, pl in pairs( player.GetAll() ) do
		
		// validate
		if ( ValidEntity( pl ) && pl:IsConnected() ) then
			
			// always think
			self:ClientThink( pl, curtime );
			
			if ( pl:Team() == TEAM_PLAYERS ) then
				
				// players only think
				self:PlayerThink( pl, curtime );
				players = players + 1;
				
			else
			
				specs = specs + 1;
				
			end
			
		end
		
	end
	
	self:QuestsThink( players, specs );
	
end


/*------------------------------------
	EntityClear()
------------------------------------*/
function EntityClear( ent, pos )

	pos = pos or ent:GetPos();

	// build trace
	local trace = {};
		trace.start = pos;
		trace.endpos = pos;

	local tr = util.TraceEntity( trace, ent );
	return ( !tr.HitNonWorld );
	
end


/*------------------------------------
	ShowTeam()
------------------------------------*/
function GM:ShowTeam( pl )

	local curtime = CurTime();

	if ( curtime - ( pl.LastTeamSwitch or -2 ) < 3 || !pl:Alive() ) then
	
		return;
		
	end
	
	pl.LastTeamSwitch = curtime;

	if ( pl:Team() == TEAM_SPECTATOR ) then
	
		pl:SetTeam( TEAM_PLAYERS );
		MessageAll( pl:Name() .. " is now a player" );
		
		
	else
	
		pl:SetTeam( TEAM_SPECTATOR );
		MessageAll( pl:Name() .. " is now spectating" );
	
	end
	
	pl:KillSilent();
	pl:Spawn();

end


/*------------------------------------
	MessageAll()
------------------------------------*/
function MessageAll( text )

	for _, pl in pairs( player.GetAll() ) do
	
		if ( ValidEntity( pl ) && pl:IsConnected() ) then
		
			pl:ChatPrint( text );
		
		end
	
	end

end
