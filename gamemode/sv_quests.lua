
local EnigmaBlock;
local ConsumptionEater;
local QuestOrder;
local CurrentQuest;


/*------------------------------------
	InitQuests()
------------------------------------*/
function GM:InitQuests()

	QuestOrder = {};

	//local pool = { 1, 2, 3, 4, 5 };
	local pool = { 2, 2, 2, 2, 2 };
	
	for i = 1, 5 do
	
		local key = math.random( 1, #pool );
		local val = pool[ key ];
		table.insert( QuestOrder, val );
		table.remove( pool, key );
	
	end
	
	//table.insert( QuestOrder, 6 );
	
	PrintTable( QuestOrder );

end


/*------------------------------------
	StartNextQuest()
------------------------------------*/
function GM:StartNextQuest()

	CurrentQuest = QuestOrder[ 1 ];
	table.remove( QuestOrder, 1 );
	self:SendQuestUpdate();
	print( "starting quest ", CurrentQuest );

end


/*------------------------------------
	SendQuestUpdate()
------------------------------------*/
function GM:SendQuestUpdate( pl )

	umsg.Start( "questupdate", pl );
	umsg.Short( CurrentQuest );
	umsg.End();

end


/*------------------------------------
	GetPropList()
------------------------------------*/
local function GetPropList()

	local proplist = {};

	for _, t in pairs( { "prop_physics_respawnable", "prop_physics_multiplayer" } ) do
	
		local part = ents.FindByClass( t );
		
		for _, prop in pairs( part ) do
		
			if ( prop:GetGroundEntity() ) then
			
				local obj = prop:GetPhysicsObject();
				if ( ValidEntity( obj ) && obj:GetMass() <= PROP_HAUNT_MASS ) then
		
					table.insert( proplist, prop );
					
				end
				
			end
		
		end
	
	end
	
	if ( #proplist == 0 ) then
	
		for _, prop in pairs( ents.FindByClass( "prop_physics" ) ) do
		
			if ( prop:GetGroundEntity() ) then
			
				local obj = prop:GetPhysicsObject();
				if ( ValidEntity( obj ) && obj:GetMass() <= PROP_HAUNT_MASS ) then
		
					table.insert( proplist, prop );
					
				end
				
			end
		
		end
	
	end
	
	return proplist;

end


/*------------------------------------
	GetRandomProp()
------------------------------------*/
local function GetRandomProp()

	local proplist = GetPropList();
	
	for i = 1, 100 do
	
		local prop = table.Random( proplist );
		
	//	if ( prop:OnGround() ) then
		
			local obj = prop:GetPhysicsObject();
			if ( ValidEntity( obj ) ) then
				
				local mass = obj:GetMass();
				
				if ( mass > 10 ) then
					
					return prop;
					
				end
				
			end
			
	//	end
		
	end
	
	return nil;

end


/*------------------------------------
	AscensionThink()
------------------------------------*/
function GM:AscensionThink()

	for _, pl in pairs( player.GetAll() ) do
	
		if ( pl:Team() == TEAM_PLAYERS ) then
		
			pl:SetNWInt( "GoalStatus", 3 );
		
			if ( !pl.Ascended && pl:GetMoveType() == MOVETYPE_WALK ) then
			
				local vel = pl:GetVelocity();
				if ( vel.z > 400 ) then
				
					pl.Ascended = true;
				
				end
			
			end
		
		end
	
	end

end


/*------------------------------------
	ConsumptionThink()
------------------------------------*/
function GM:ConsumptionThink()

	if ( !ValidEntity( ConsumptionEater ) ) then
		
		local gprop = GetRandomProp();
		
		if ( ValidEntity( gprop ) ) then
	
			ConsumptionEater = ents.Create( "collector_eater" );
			ConsumptionEater:SetPos( gprop:GetPos() );
			ConsumptionEater:Spawn();
			gprop:Remove();
			
			timer.Simple( 0.1, function()
			
				if ( !ValidEntity( ConsumptionEater ) ) then return; end
			
				ConsumptionEater:DropToFloor();
				ConsumptionEater:SetPos( ConsumptionEater:GetPos() + Vector( 0, 0, 16 ) );
				
			end );
			
			print( "spawned eater" );
			
		end
		
	end
	
	if ( ValidEntity( ConsumptionEater ) ) then
	
		local bpos = ConsumptionEater:GetPos()
		
		for _, pl in pairs( player.GetAll() ) do
		
			if ( ( pl:GetPos() - bpos ):Length() < 128 ) then
			
				pl:SetNWInt( "GoalStatus", 2 );
			
			else
			
				pl:SetNWInt( "GoalStatus", 1 );
		
				local dir = ( pl:EyePos() - bpos ):Normalize();
				dir.z = 0;
				
				local ang = dir:Angle();
				local eyes = pl:EyeAngles();
				
				eyes.pitch = 0
				ang = ang - eyes;
				
				pl:SetNWVector( "GoalDir", ang );
				
			end
			
		end
		
	end

end


/*------------------------------------
	EnigmaThink()
------------------------------------*/
function GM:EnigmaThink()

	if ( !ValidEntity( EnigmaBlock ) ) then
	
		local proplist = GetPropList();
		
		local gprop;
		
		for i = 1, 100 do
		
			local prop = table.Random( proplist );
			local obj = prop:GetPhysicsObject();
			if ( ValidEntity( obj ) ) then
			
				local mass = obj:GetMass();
				
				if ( mass > 10 ) then
				
					gprop = prop;
					break;
					
				end
				
			end
			
		end
		
		if ( ValidEntity( gprop ) ) then
	
			EnigmaBlock = ents.Create( "collector_block" );
			EnigmaBlock:SetPos( gprop:GetPos() );
			EnigmaBlock:Spawn();
			gprop:Remove();
			
			print( "spawned block" );
			
		end
		
	end
	
	if ( ValidEntity( EnigmaBlock ) ) then
	
		local bpos = EnigmaBlock:GetPos()
		
		for _, pl in pairs( player.GetAll() ) do
		
			if ( ( pl:GetPos() - bpos ):Length() < 128 ) then
			
				pl:SetNWInt( "GoalStatus", 2 );
			
			else
			
				pl:SetNWInt( "GoalStatus", 1 );
		
				local dir = ( pl:EyePos() - bpos ):Normalize();
				dir.z = 0;
				
				local ang = dir:Angle();
				local eyes = pl:EyeAngles();
				
				eyes.pitch = 0
				ang = ang - eyes;
				
				pl:SetNWVector( "GoalDir", ang );
				
			end
			
		end
		
	end

end


/*------------------------------------
	ImmolateThink()
------------------------------------*/
function GM:ImmolateThink()

	for _, pl in pairs( player.GetAll() ) do
		
		pl:SetNWInt( "GoalStatus", 3 );
		
	end

end


/*------------------------------------
	FusionThink()
------------------------------------*/
function GM:FusionThink()

end


/*------------------------------------
	ExodusThink()
------------------------------------*/
function GM:ExodusThink()

end


/*------------------------------------
	QuestsThink()
------------------------------------*/
function GM:QuestsThink( players, specs )

	if ( players > 0 ) then
	
		if ( QuestOrder == nil ) then
		
			self:InitQuests();
			
		end
		
		if ( CurrentQuest == nil ) then
		
			self:StartNextQuest();
		
		end
		
		if ( CurrentQuest != nil ) then
		
			if ( CurrentQuest == QUEST_ENIGMA ) then
			
				self:EnigmaThink();
				
			elseif ( CurrentQuest == QUEST_CONSUMPTION ) then
			
				self:ConsumptionThink();
				
			elseif ( CurrentQuest == QUEST_IMMOLATE ) then
			
				self:ImmolateThink();
				
			elseif ( CurrentQuest == QUEST_ASCENSION ) then
			
				self:AscensionThink();
				
			elseif ( CurrentQuest == QUEST_FUSION ) then
			
				self:FusionThink();
				
			elseif ( CurrentQuest == QUEST_EXODUS ) then
			
				self:ExodusThink();
				
			end
		
		end
	
	end
	
end


/*------------------------------------
	QuestsBurntEntity()
------------------------------------*/
function GM:QuestsBurntEntity( ent, parent )

end
