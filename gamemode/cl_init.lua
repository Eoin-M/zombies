include( 'shared.lua' ) --Tell the client to load shared.lua
include("cl_hud.lua")

local surface = surface

-- Fonts
surface.CreateFont("zbFrameFont", {font = "Trebuchet24",
                                    size = 30,
                                    weight = 1000})

--[[function set_team()
 
local frame = vgui.Create( "DFrame" )
frame:SetPos( ScrW() / 2, ScrH() / 2 ) --Set the window in the middle of the players screen/game window
frame:SetSize( 200, 210 ) --Set the size
frame:SetTitle( "Change Team" ) --Set title
frame:SetVisible( true )
frame:SetDraggable( false )
frame:ShowCloseButton( true )
frame:MakePopup()
 
team_1 = vgui.Create( "DButton", frame )
team_1:SetPos( frame:GetTall() / 2, 5 ) --Place it half way on the tall and 5 units in horizontal
team_1:SetSize( 50, 100 )
team_1:SetText( "Team 1" )
team_1.DoClick = function() --Make the player join team 1
    RunConsoleCommand( "team_1" )
end
 
team_2 = vgui.Create( "DButton", frame )
team_2:SetPos( frame:GetTall() / 2, 105 ) --Place it next to our previous one
team_2:SetSize( 50, 100 )
team_2:SetText( "Team 2" )
team_2.DoClick = function() --Make the player join team 2
    RunConsoleCommand( "team_2" )
end
 
end
concommand.Add( "team_menu", set_team )]]

-- Round state comm

function GM:Initialize()
   GAMEMODE.round_state = ROUND_WAIT
end

function GetRoundState() return GAMEMODE.round_state end

local frame
local function RoundStateChange(o, n)
	if(o == ROUND_ACTIVE and n == ROUND_POST) then
		frame = vgui.Create( "DFrame" )
		frame:SetSize( ScrW()/3, ScrH()/3 ) --Set the size
		frame:Center() --Set the window in the middle of the players screen/game window
		frame:SetTitle( "Round Over" ) --Set title
		frame:SetVisible( true )
		frame:SetDraggable( false )
		frame:ShowCloseButton( true )
		frame:MakePopup()
		
		winners = vgui.Create( "DLabel", frame )
		winners:SetContentAlignment( 5 )
		winners:SetSize( ScrW()/1.5, ScrH()/1.5 )
		winners:Center()
		winners:SetFont( "zbFrameFont" )
		if (team.NumPlayers(1) == 0) then
			winners:SetText( "Winners are the: Zombies")
		else winners:SetText( "Winners are the: Survivors") end
		
	elseif(frame) then 
		frame:Remove()
	end
	print(frame)
end

local function ReceiveRoundState()
   local o = GetRoundState()
   GAMEMODE.round_state = net.ReadUInt(3)

   if o != GAMEMODE.round_state then
      RoundStateChange(o, GAMEMODE.round_state)
   end
   
end

net.Receive("zb_RoundState", ReceiveRoundState)

function GM:PostDrawViewModel( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end