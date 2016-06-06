local table = table
local surface = surface
local draw = draw
local math = math
local string = string

-- Fonts
surface.CreateFont("ZbState", {font = "Trebuchet24",
                                    size = 26,
                                    weight = 1000})

-- Color presets
local bg_colors = {
   background_main = Color(0, 0, 10, 200),

   noround = Color(100,100,100,200),
   traitor = Color(200, 25, 25, 200),
   innocent = Color(25, 200, 25, 200),
   detective = Color(25, 25, 200, 200)
};

local health_colors = {
   border = COLOR_WHITE,
   background = Color(100, 25, 25, 222),
   fill = Color(200, 50, 50, 250)
};

local ammo_colors = {
   border = COLOR_WHITE,
   background = Color(20, 20, 5, 222),
   fill = Color(205, 155, 0, 255)
};

print(GetHUDPanel())

-- Modified RoundedBox
local Tex_Corner8 = surface.GetTextureID( "gui/corner8" )
local function RoundedMeter( bs, x, y, w, h, color)
   surface.SetDrawColor(clr(color))

   surface.DrawRect( x+bs, y, w-bs*2, h )
   surface.DrawRect( x, y+bs, bs, h-bs*2 )

   surface.SetTexture( Tex_Corner8 )
   surface.DrawTexturedRectRotated( x + bs/2 , y + bs/2, bs, bs, 0 )
   surface.DrawTexturedRectRotated( x + bs/2 , y + h -bs/2, bs, bs, 90 )

   if w > 14 then
      surface.DrawRect( x+w-bs, y+bs, bs, h-bs*2 )
      surface.DrawTexturedRectRotated( x + w - bs/2 , y + bs/2, bs, bs, 270 )
      surface.DrawTexturedRectRotated( x + w - bs/2 , y + h - bs/2, bs, bs, 180 )
   else
      surface.DrawRect( x + math.max(w-bs, bs), y, bs/2, h )
   end

end

---- The bar painting is loosely based on:
---- http://wiki.garrysmod.com/?title=Creating_a_HUD

-- Paints a graphical meter bar
local function PaintBar(x, y, w, h, colors, value)
   -- Background
   -- slightly enlarged to make a subtle border
   draw.RoundedBox(8, x-1, y-1, w+2, h+2, colors.background)

   -- Fill
   local width = w * math.Clamp(value, 0, 1)

   if width > 0 then
      --RoundedMeter(8, x, y, width, h, colors.fill)
   end
end

--[[local roundstate_string = {
   [ROUND_WAIT]   = "round_wait",
   [ROUND_PREP]   = "round_prep",
   [ROUND_ACTIVE] = "round_active",
   [ROUND_POST]   = "round_post"
};]]

local function DrawBg(x, y, width, height, client)
   -- Traitor area sizes
   local th = 30
   local tw = 170

   -- Adjust for these
   y = y - th
   height = height + th

   -- main bg area, invariant
   -- encompasses entire area
   draw.RoundedBox(8, x, y, width, height, bg_colors.background_main)

   -- main border, traitor based
   local col = bg_colors.innocent
   if GAMEMODE.round_state != ROUND_ACTIVE then
      col = bg_colors.noround
   elseif client:Team() == 1 then
      col = bg_colors.innocent
   elseif client:Team() == 2 then
      col = bg_colors.traitor
   end

   draw.RoundedBox(8, x, y, tw, th, col)
end

local sf = surface
local dr = draw

local function ShadowedText(text, font, x, y, color, xalign, yalign)

   dr.SimpleText(text, font, x+2, y+2, COLOR_BLACK, xalign, yalign)

   dr.SimpleText(text, font, x, y, color, xalign, yalign)
end

local margin = 10

--local key_params = { usekey = Key("+use", "USE") }

local function SpecHUDPaint(client)
   local L = GetLang() -- for fast direct table lookups

   -- Draw round state
   local x       = margin
   local height  = 32
   local width   = 250
   local round_y = ScrH() - height - margin

   -- move up a little on low resolutions to allow space for spectator hints
   if ScrW() < 1000 then round_y = round_y - 15 end

   local time_x = x + 170
   local time_y = round_y + 4

   draw.RoundedBox(8, x, round_y, width, height, bg_colors.background_main)
   draw.RoundedBox(8, x, round_y, time_x - x, height, bg_colors.noround)

   local text = L[ roundstate_string[GAMEMODE.round_state] ]
   ShadowedText(text, "ZbState", x + margin, round_y, COLOR_WHITE)

   -- Draw round/prep/post time remaining
   local text = util.SimpleTime(math.max(0, GetGlobalFloat("zb_round_end", 0) - CurTime()), "%02i:%02i")
   ShadowedText(text, "TimeLeft", time_x + margin, time_y, COLOR_WHITE)

   local tgt = client:GetObserverTarget()
   if IsValid(tgt) and tgt:IsPlayer() then
      ShadowedText(tgt:Nick(), "TimeLeft", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)

   elseif IsValid(tgt) and tgt:GetNWEntity("spec_owner", nil) == client then
      PunchPaint(client)
   else
      ShadowedText(interp(L.spec_help, key_params), "TabLarge", ScrW() / 2, margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
   end
end

local function InfoPaint(client)
   --local L = GetLang()
   --print(GetRoundState())
   if(GetRoundState() == ROUND_WAIT) then return end

   local width = 250
   local height = 90

   local x = margin
   local y = ScrH() - margin - height
   local zb_y = y - 30

   DrawBg(x, y, width, height, client)

   local bar_height = 25
   local bar_width = width - (margin*2)

   -- Draw health
   local health = math.max(0, client:Health())
   local health_y = y + margin

   PaintBar(x + margin, health_y, bar_width, bar_height, health_colors, health/100)

   ShadowedText(tostring(health), "HealthAmmo", bar_width, health_y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)

   -- Draw traitor state
   --local round_state = GAMEMODE.round_state

   -- Draw round time
   --local is_haste = HasteMode() and round_state == ROUND_ACTIVE
   --local is_traitor = client:IsActiveTraitor()
   local text
   if(client:Team() == 1) then text = "Survivor"
   else text = "Zombie" end
		
   ShadowedText(text, "ZbState", x + margin + 73, zb_y, COLOR_WHITE, TEXT_ALIGN_CENTER)
   
   if(GetRoundState() == ROUND_WAIT) then text = "Waiting For Players"
   elseif(GetRoundState() == ROUND_PREP) then text = "Prep Time"
   elseif(GetRoundState() == ROUND_ACTIVE and client:Team() == 1) then text = "Goal: Survive"
   elseif(GetRoundState() == ROUND_ACTIVE and client:Team() == 2) then text = "Goal: Kill"
   elseif(GetRoundState() == ROUND_POST) then text = "Round Over" 
   else text = "Bug Occurred" end
   
   ShadowedText(text, "ZbState", x + margin + 73, zb_y + 75, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
   
   local endtime = GetGlobalFloat("zb_round_end", 0) - CurTime()

   local font = "TimeLeft"
   local color = COLOR_WHITE
   local rx = x + margin + 170
   local ry = zb_y + 3

   -- Time displays differently depending on whether haste mode is on,
   -- whether the player is traitor or not, and whether it is overtime.
   --[[if is_haste then
      local hastetime = GetGlobalFloat("ttt_haste_end", 0) - CurTime()
      if hastetime < 0 then
         if (not is_traitor) or (math.ceil(CurTime()) % 7 <= 2) then
            -- innocent or blinking "overtime"
            text = L.overtime
            font = "Trebuchet18"

            -- need to hack the position a little because of the font switch
            ry = ry + 5
            rx = rx - 3
         else
            -- traitor and not blinking "overtime" right now, so standard endtime display
            text  = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
            color = COLOR_RED
         end
      else
         -- still in starting period
         local t = hastetime
         if is_traitor and math.ceil(CurTime()) % 6 < 2 then
            t = endtime
            color = COLOR_RED
         end
         text = util.SimpleTime(math.max(0, t), "%02i:%02i")
      end
   else]]
      -- bog standard time when haste mode is off (or round not active)
      text = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
   --end

   ShadowedText(text, font, rx, ry, color)

   --if is_haste then
      --dr.SimpleText(L.hastemode, "TabLarge", x + margin + 165, zb_y - 8)
   --end

end

-- Paints player status HUD element in the bottom left
function GM:HUDPaint()
   local client = LocalPlayer()

   --[[if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTTargetID" ) then
       hook.Call( "HUDDrawTargetID", GAMEMODE )
   end
   
   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTMStack" ) then
       MSTACK:Draw(client)
   end

   if (not client:Alive()) or client:Team() == TEAM_SPEC then
      if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTSpecHUD" ) then
          SpecHUDPaint(client)
      end

      return
   end

   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTRadar" ) then
       RADAR:Draw(client)
   end
   
   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTTButton" ) then
       TBHUD:Draw(client)
   end
   
   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTWSwitch" ) then
       WSWITCH:Draw(client)
   end

   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTVoice" ) then
       VOICE.Draw(client)
   end
   
   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTDisguise" ) then
       DISGUISE.Draw(client)
   end

   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTPickupHistory" ) then
       hook.Call( "HUDDrawPickupHistory", GAMEMODE )
   end

   -- Draw bottom left info panel
   if hook.Call( "HUDShouldDraw", GAMEMODE, "TTTInfoPanel" ) then]]
       InfoPaint(client)
   --end]]
end

-- Hide the standard HUD stuff
local hud = {"CHudHealth"} --, "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function GM:HUDShouldDraw(name)
   for k, v in pairs(hud) do
      if name == v then return false end
   end

   return true
end

