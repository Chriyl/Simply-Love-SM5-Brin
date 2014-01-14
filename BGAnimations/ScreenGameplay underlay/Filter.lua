-- filter code rewrite
local Player = ...;
assert(...);

local IsUsingSoloSingles = PREFSMAN:GetPreference('Center1Player');
local NumPlayers = GAMESTATE:GetNumPlayersEnabled();
local NumSides = GAMESTATE:GetNumSidesJoined();

local pName;
local prefName = "FilterColor";
local filterColor;
local fallbackColor = color("0,0,0,0.75");

local function InitFilter()
	pName = pname(Player);
	prefName = prefName..pName;
	
	local darkness = getenv("ScreenFilter"..pName)
	if darkness == "Dark" then
		filterColor = color("#00000088");
	elseif darkness == "Darker" then
		filterColor = color("#000000AA");
	elseif darkness == "Darkest" then
		filterColor = color("#000000EE");
	else
		filterColor = color("#00000000");
	end
	
end;

local function FilterPosition()
	if IsUsingSoloSingles and NumPlayers == 1 and NumSides == 1 then return SCREEN_CENTER_X; end;

	local strPlayer = (NumPlayers == 1) and "OnePlayer" or "TwoPlayers";
	local strSide = (NumSides == 1) and "OneSide" or "TwoSides";
	return THEME:GetMetric("ScreenGameplay","Player".. pName .. strPlayer .. strSide .."X");
end;

-- updated by sillybear
-- xxx: does this still only account for dance?
local function FilterWidth()
	if NumPlayers == 1 and NumSides == 2 then 
		return ((SCREEN_WIDTH*1.058)/GetScreenAspectRatio());
	else
		return ((SCREEN_WIDTH*0.529)/GetScreenAspectRatio());
	end;
end;

InitFilter();

local filter = Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(diffuse,fallbackColor;y,SCREEN_CENTER_Y);
		BeginCommand=function(self)
			if getenv("ScreenFilter"..pName) == "Off" then
				self:visible(false);
			else
				self:visible(true);
				-- setup
				self:x( FilterPosition() );
				self:zoomto( FilterWidth(), SCREEN_HEIGHT );
				self:diffuse( filterColor );
			end;
		end;
		OffCommand=function(self)
			local pStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(Player);
			if pStats:FullCombo() then
				self:accelerate(0.25);
				self:glow( color("1,1,1,0.75") );
				self:decelerate(0.75);
				self:glow( color("1,1,1,0") );
			end;
		end;
	};
};
return filter;