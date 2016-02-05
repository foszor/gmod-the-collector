
// setup gamemode
GM.Name			= "The Collector";
GM.Author		= "Brandon Gandy";
GM.Email		= "brandon@foszor.com";
GM.Website		= "www.foszor.com";
GM.TeamBased	= false;


// prop types
GM.PropClassList = {
	
	"prop_physics",
	"prop_physics_multiplayer",
	"prop_physics_respawnable"
	
};

// acceptable player models
GM.PlayerModelList = {
	
	Model( "models/Humans/Group03/Male_01.mdl" ),
	Model( "models/Humans/Group03/Male_02.mdl" ),
	Model( "models/Humans/Group03/Male_03.mdl" ),
	Model( "models/Humans/Group03/Male_04.mdl" ),
	Model( "models/Humans/Group03/Male_05.mdl" ),
	Model( "models/Humans/Group03/Male_06.mdl" ),
	Model( "models/Humans/Group03/Male_07.mdl" ),
	Model( "models/Humans/Group03/Male_08.mdl" ),
	Model( "models/Humans/Group03/Male_09.mdl" )
	
};

// globals
SLOWMO_DURATION			= 3;

// quest enums
QUEST_ENIGMA			= 1;
QUEST_CONSUMPTION		= 2;
QUEST_IMMOLATE			= 3;
QUEST_ASCENSION			= 4;
QUEST_FUSION			= 5;
QUEST_EXODUS			= 6;

// team enums
TEAM_PLAYERS 			=  1003;

// create teams
team.SetUp( TEAM_PLAYERS, "Players", Color( 255, 0, 0, 255 ), false );
