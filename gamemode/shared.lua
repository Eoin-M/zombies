GM.Name 	= "Zombies" --Set the gamemode name
GM.Author 	= "Eoin And Seán" --Set the author name
GM.Email 	= "eoin.mgr@gmail.com" --Set the author email
GM.Website 	= "eoinmaguire.com" --Set the author website

team.SetUp( 1, "Survivors", Color( 0, 255, 255, 255 ) ) --Here we make the team Survivors
team.SetUp( 2, "Zombies", Color( 225, 0, 0 , 225 ) )

COLOR_WHITE  = Color(255, 255, 255, 255)
COLOR_BLACK  = Color(0, 0, 0, 255)

-- Round status consts
ROUND_WAIT   = 1
ROUND_PREP   = 2
ROUND_ACTIVE = 3
ROUND_POST   = 4

include("util.lua")