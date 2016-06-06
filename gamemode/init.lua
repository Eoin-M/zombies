AddCSLuaFile( "shared.lua" ) --Tell the server that the client needs to download shared.lua
AddCSLuaFile( "cl_init.lua" ) --Tell the server that the client needs to download cl_init.lua
AddCSLuaFile("cl_hud.lua")
 
include( 'shared.lua' ) --Tell the server to load shared.lua

CreateConVar("zb_preptime_seconds", "10")
CreateConVar("zb_roundtime_minutes", "6")
CreateConVar("zb_zombies_pct", "0.25")

function GM:Initialize()
	print("GM:Initialize")
	GAMEMODE.round_state = ROUND_WAIT
	GAMEMODE.FirstRound = true
	GAMEMODE.RoundStartTime = 0
	
	WaitForPlayers()
end

-- Round state is encapsulated by set/get so that it can easily be changed to
-- eg. a networked var if this proves more convenient
function SetRoundState(state)
   GAMEMODE.round_state = state
end

function GetRoundState()
   return GAMEMODE.round_state
end

local function EnoughPlayers()
   local ready = 0
   -- only count truly available players, ie. no forced specs
   for _, ply in pairs(player.GetAll()) do
      if IsValid(ply) then
         ready = ready + 1
      end
   end
   print("Ready: " .. ready)
   return ready >= 1--ttt_minply:GetInt()
end

function WaitingForPlayersChecker()
   if GetRoundState() == ROUND_WAIT then
      if EnoughPlayers() then
         timer.Create("wait2prep", 1, 1, PrepareRound)

         timer.Stop("waitingforply")
      end
   end
end

-- Start waiting for players
function WaitForPlayers()
   SetRoundState(ROUND_WAIT)

   if not timer.Start("waitingforply") then
      timer.Create("waitingforply", 2, 0, WaitingForPlayersChecker)
   end
end

function PrepareRound()
	print("Prepare Round")
	--if GAMEMODE.FirstRound then
		local ptime = GetConVar("zb_preptime_seconds"):GetInt()
		GAMEMODE.FirstRound = false
	--end
	print("Prep Time: " .. ptime)
	SetRoundEnd(CurTime() + ptime)
	
	for k,ply in pairs(player.GetAll()) do
		ply:SetTeam(1)
		ply:Spawn()
	end

	timer.Create("prep2begin", ptime, 1, BeginRound)
	SetRoundState(ROUND_PREP)
end

function BeginRound()
	print("Begin Round")
	local endtime = GetConVar("zb_roundtime_minutes"):GetInt() * 60
	SetRoundEnd(CurTime() + endtime)
	
	ChooseZombies()
	SetRoundState(ROUND_ACTIVE)
end

function ChooseZombies()
	local players = player.GetAll()
	-- get number of zombies: pct of players rounded down
	local zb_count = math.floor(table.Count(players) * GetConVar("zb_zombies_pct"):GetFloat())
	-- make sure there is at least 1 traitor
	zb_count = math.Clamp(zb_count, 1, table.Count(players))

	local zbs = 0 --no. of selected zombies
	while zbs < zb_count do
		-- select random index in players table
		local pick = math.random(1, #players)

		-- the player we consider
		local pply = players[pick]

		-- make this guy zombie
		if IsValid(pply) then
		 pply:SetTeam(2)
		 pply:Spawn()

		 table.remove(players, pick)
		 zbs = zbs + 1
		end
	end
end

function SetRoundEnd(endtime)
   SetGlobalFloat("zb_round_end", endtime)
end
	
function GM:PlayerInitialSpawn( ply ) --"When the player first joins the server and spawns" function
 
    ply:SetTeam( 0 ) --Add the player to team 0
	ply:SetWalkSpeed( 165 )
	ply:SetRunSpeed( 220 )
 
end --End the "when player first joins server and spawns" function

--util.PrecacheModel( "/models/player/zm_classic.mdl" )

local survivorMDL = {
	"alyx",
	"breen",
	"barney",
	"eli",
	"gman_high",
	"kleiner",
	"monk",
	"odessa",
	"magnusson" }

for k,v in pairs(survivorMDL) do				
	util.PrecacheModel(survivorMDL[k])
end

local zombieMDL = {	
	"zombie_classic",
	"zombie_fast",
	"corpse1",
	"charple",
	"zombie_soldier" }

for k,v in pairs(zombieMDL) do				
	util.PrecacheModel(zombieMDL[k])
end

function GM:PlayerSpawn( ply )
	
	ply:StripWeapons()
	ply:StripAmmo()
	local oldhands = ply:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end
	
	if (ply:Team() == 1) then --If player team equals 1
		SetupSurvivor( ply )
 
	elseif (ply:Team() == 2) then
		SetupZombie( ply )
 
	end -- This ends the if/elseif.
	
end

function GM:PlayerLoadout( ply )
	ply:Give( "weapon_smg1" )
	return true
end

function SetupSurvivor( ply )
	local mdl = chooseMDL(survivorMDL)
	ply:SetModel( "models/player/" .. mdl .. ".mdl" )
	setHands(ply)
	ply:Give( "weapon_physcannon" )
	ply:Give( "weapon_smg1" )
	ply:GiveAmmo( 90, "smg1" )
	ply:Give( "weapon_357" ) --Give them the Magnum
	ply:GiveAmmo( 36, 	"357", true )
end

function SetupZombie( ply )
	local mdl = chooseMDL(zombieMDL)
	ply:SetModel( "models/player/" .. mdl .. ".mdl" )
	setHands(ply)
	ply:Give( "weapon_gb_fists" )
	ply:Give( "weapon_mu_knife" )
	ply:Give( "weapon_ttt_smokegrenade" )
	ply.knifeTime = CurTime()
	currSpeed = ply:GetRunSpeed()
	if (currSpeed < 240) then currSpeed = 240 end
	currSpeed = currSpeed + 5
	ply:PrintMessage( HUD_PRINTTALK, "Sprint Speed: " .. currSpeed )
	ply:SetRunSpeed( currSpeed )
end

function chooseMDL(mdls)
	local rnd = math.ceil(math.random() * table.Count(mdls));
	local mdl = mdls[rnd]
	return mdl
end

function setHands( ply )
	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		ply:SetHands( hands )
		hands:SetOwner( ply )

		-- Which hands should we use?
		--local char = ""
		
		--if(ply:Team() == 1) then char = "kleiner" 
		--else char = "zombiefast" end
		
		local mdl =  player_manager.TranslateToPlayerModelName( ply:GetModel() )
		info = player_manager.TranslatePlayerHands( mdl )
		print(info)
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = ply:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		ply:DeleteOnRemove( hands )

		hands:Spawn()
	end
end

function GM:PlayerDeath( victim, inflictor, attacker )
	if (victim:Team() == 1) then
		victim:SetTeam( 2 )
	end
	
	if (team.NumPlayers(1) == 0) then
		--reset()
	end
end

function reset()
	local players = player.GetAll()
	
	for key,value in pairs(players) do
		players[key]:SetTeam( 1 )
		players[key]:KillSilent()
	end
end

function GM:PlayerCanPickupWeapon( ply, wep )
	if(ply:Team() == 1) then
		return ( wep:GetClass() != "weapon_mu_knife" )
	else
		return ( wep:GetClass() == "weapon_mu_knife" || wep:GetClass() == "weapon_ttt_smokegrenade" || wep:GetClass() == "weapon_gb_fists")
	end
end

function GM:Think()
	self:ZombieThink()
end

function GM:ZombieThink()
	local zombies = team.GetPlayers(2)
	if(table.Count(zombies) == 0) then return end
	
	for k,v in pairs(zombies) do
		if(zombies[k]:Alive()) then
			if(zombies[k]:HasWeapon("weapon_mu_knife")) then
				--zombies[k]:ZombieKnifeTime()
				zombies[k].knifeTime = CurTime()
				
			elseif((zombies[k].knifeTime + 30) < CurTime()) then
				zombies[k]:Give( "weapon_mu_knife" )
				zombies[k].knifeTime = CurTime()
			end
		end
	end
end
	