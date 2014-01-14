local rv;
local t = Def.ActorFrame{};

local zoom_factor = WideScale(0.8,0.9);

local labelX_col1 = WideScale(-70,-90);
local dataX_col1  = WideScale(-75,-96);

local labelX_col2 = WideScale(10,20);
local dataX_col2  = WideScale(5,15);

local highscoreX = WideScale(56, 80);
local highscorenameX = WideScale(84, 120);

local paneCategories = {
	'RadarCategory_TapsAndHolds',
	'RadarCategory_Jumps',
	'RadarCategory_Holds',
	'RadarCategory_Mines',
	'RadarCategory_Hands',
	'RadarCategory_Rolls'
};

local paneStrings = {
	THEME:GetString("RadarCategory","Taps"),
	THEME:GetString("RadarCategory","Jumps"),
	THEME:GetString("RadarCategory","Holds"),
	THEME:GetString("RadarCategory","Mines"),
	THEME:GetString("RadarCategory","Hands"),
	THEME:GetString("RadarCategory","Rolls")
};


	
for p=1,2 do
	
	local player = "PlayerNumber_P"..p;
	
	local pd = Def.ActorFrame{
		Name="PaneDisplay"..p;
		InitCommand=function(self)
			self:Center();
			
			if p == 1 then
				self:player(PLAYER_1);
				self:addx(-1 * SCREEN_WIDTH/4 - 5);
			elseif p == 2 then
				self:player(PLAYER_2);
				self:addx(1 * SCREEN_WIDTH/4 + 5);
			end;
		end;

		PlayerJoinedMessageCommand=function(self, params)
			if p==1 and params.Player == PLAYER_1 then
				self:visible(true);
				(cmd(zoom,0;bounceend,0.3;zoom,1))(self);
			elseif p==2 and params.Player == PLAYER_2 then
				self:visible(true);
				(cmd(zoom,0;bounceend,0.3;zoom,1))(self);
			end;
	 	end;
	
		-- These playcommand("Set") need to apply to the ENTIRE panedisplay 
		-- (all its children) so declare each here
		CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
		CurrentCourseChangedMessageCommand=cmd(playcommand,"Set");
		CurrentStepsP1ChangedMessageCommand=function(self)
			if p == 1 then self:playcommand("Set"); end;				
		end;
		CurrentTrailP1ChangedMessageCommand=function(self)
			if p == 1 then self:playcommand("Set"); end;
		end;
		CurrentStepsP2ChangedMessageCommand=function(self)
			if p == 2 then self:playcommand("Set"); end;
		end;
		CurrentTrailP2ChangedMessageCommand=function(self)
			if p == 2 then self:playcommand("Set"); end;
		end;
	};

	-- colored background for chart statistics
	pd[#pd+1] = Def.Quad{
		InitCommand=cmd(diffuse, DifficultyIndexColor(p*2); zoomto, SCREEN_WIDTH/2-10, SCREEN_HEIGHT/8.5; y, SCREEN_HEIGHT/3 + 15.33; );
		SetCommand=function(self)
			local player = "PlayerNumber_P"..p;
			
			if GAMESTATE:IsHumanPlayer(player) then
				local currentSteps = GAMESTATE:GetCurrentSteps(player);
				if currentSteps then
					local currentDifficulty = currentSteps:GetDifficulty();
					self:diffuse(DifficultyColor(currentDifficulty));
				end
			end
		end;
	};
	
	
	
	for i=1,#paneCategories do

		pd[#pd+1] = Def.ActorFrame
		{

			Name="PLAYER_"..p..paneStrings[i];
			OnCommand=cmd(addx, -SCREEN_WIDTH/20; addy,6 );

			-- chart statistics labels
			LoadFont("_misoreg hires")..{
				Text=paneStrings[i];					
				InitCommand=function(self)
					self:zoom(zoom_factor);
			
					if i <= #paneCategories/2 then
						self:x(labelX_col1);
					else
						self:x(labelX_col2);
					end
	
					if 	paneStrings[i] == "Steps"  or paneStrings[i] == "Mines" then
						self:y(150);
					elseif paneStrings[i] == "Jumps" or paneStrings[i] == "Hands" then
						self:y(168);	
					elseif paneStrings[i] == "Holds" or paneStrings[i] == "Rolls" then
						self:y(186);
					end
	
					self:diffuse(color("#000000"));
					self:shadowlength(0.2);
					self:horizalign(left);
					self:NoStroke();
				end;
			};


			-- chart statistics numbers (values)
			LoadFont("_misoreg hires")..{					
				InitCommand=function(self)
					self:zoom(zoom_factor);
	
					if i <= #paneCategories/2 then
						self:x(dataX_col1);
					else
						self:x(dataX_col2);
					end
	
					if 	i == 1  or i == 4 then
						self:y(150);
					elseif i == 2 or i == 5 then
						self:y(168);	
					elseif i == 3 or i == 6 then
						self:y(186);
					end
	
					self:diffuse(color("#000000"));
					self:shadowlength(0.2);
					self:horizalign(right);
					self:NoStroke();
					self:playcommand("Set");
				end;
				SetCommand=function(self)
									
					local song, steps, player;
		
					if p == 1 then
						player = PLAYER_1;
					else
						player = PLAYER_2;
					end
				
					if GAMESTATE:IsCourseMode() then
						song = GAMESTATE:GetCurrentCourse();
						steps = GAMESTATE:GetCurrentTrail(player);
					else
						song = GAMESTATE:GetCurrentSong();
						steps = GAMESTATE:GetCurrentSteps(player);
					end;
				
					if steps then		
						rv = steps:GetRadarValues(player);
						local val = rv:GetValue(paneCategories[i]);
						self:settext( val );
					else
						self:settext( "" );	
					end
				
					if not song then
						self:settext("?")
					end

				end;

			};

			-- chart difficulty meter
			LoadFont("_wendy small")..{
				InitCommand=cmd(horizalign, right; NoStroke;);
				SetCommand=function(self)	
					local player;
		
					if p == 1 then
						player = PLAYER_1;
					else
						player = PLAYER_2;
					end
								
					local steps = GAMESTATE:GetCurrentSteps(player);
					self:xy(SCREEN_WIDTH/4 + 20, SCREEN_HEIGHT/2 - 70);
					self:diffuse(0,0,0,1);
				
					if steps then
						if steps:GetMeter() then				
							self:settext(steps:GetMeter());
						end
					end

					local song = GAMESTATE:GetCurrentSong();
					local course = GAMESTATE:GetCurrentCourse();
				
					if not(song or course) then
						self:settext("?")
					end
				
				end;
			};
		};

	end;


	--MACHINE high score
	pd[#pd+1] = LoadFont("_misoreg hires")..{
	
		InitCommand=cmd(x, highscoreX; y, 156; zoom, zoom_factor; diffuse,color("0,0,0,1"); halign, 1 );
		SetCommand=function(self)
			local SongOrCourse, StepsOrTrail;

			local text = "";
			local profile, scorelist;
	
		
			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse();
				StepsOrTrail = GAMESTATE:GetCurrentTrail(player);
			else
				SongOrCourse = GAMESTATE:GetCurrentSong();
				StepsOrTrail = GAMESTATE:GetCurrentSteps(player);
			end;

			if SongOrCourse then
				if StepsOrTrail then
					profile = PROFILEMAN:GetMachineProfile();
					scorelist = profile:GetHighScoreList(SongOrCourse,StepsOrTrail);
					local scores = scorelist:GetHighScores();
					local topscore = scores[1];
				
					if not topscore then
						text = string.format("%.2f%%", 0);
					else
						text = string.format("%.2f%%", topscore:GetPercentDP()*100.0);
					end;
				else
					text = string.format("%.2f%%", 0);
				end;
			else
				text = "?";
			end;
		
			self:settext( text );

		end;
	};


	--MACHINE highscore name
	pd[#pd+1] = LoadFont("_misoreg hires")..{
	
		InitCommand=cmd(x, highscorenameX; y, 156; zoom, zoom_factor; diffuse, color("0,0,0,1"); halign, 1);
		SetCommand=function(self)
			local SongOrCourse, StepsOrTrail;

			local text = "";
			local profile, name, scores, topscore, scorelist;
					
			if GAMESTATE:IsCourseMode() then
				SongOrCourse = GAMESTATE:GetCurrentCourse();
				StepsOrTrail = GAMESTATE:GetCurrentTrail(player);
			else
				SongOrCourse = GAMESTATE:GetCurrentSong();
				StepsOrTrail = GAMESTATE:GetCurrentSteps(player);
			end;

			if SongOrCourse then
				if StepsOrTrail then
				
					profile = PROFILEMAN:GetMachineProfile();
					scorelist = profile:GetHighScoreList(SongOrCourse,StepsOrTrail);
					scores = scorelist:GetHighScores();
					topscore = scores[1];
				
					if topscore then
						name = topscore:GetName();
					end;
									
					if not name then
						text = "????";
					elseif name == "" then
						text = "----"
					else
						text = name
					end;
				else
					text = "???";
				end;
			else
				text = "???";
			end;
		
			self:settext( text );

		end;
	};




	--PLAYER PROFILE high score
	pd[#pd+1] = LoadFont("_misoreg hires")..{
	
		InitCommand=cmd(x, highscoreX; y, 176; zoom, zoom_factor; diffuse,color("0,0,0,1"); halign, 1 );
		SetCommand=function(self)
		
			if PROFILEMAN:IsPersistentProfile(player) then
			
				local SongOrCourse, StepsOrTrail;

				local text = "";
				local profile, scorelist;
			
				if GAMESTATE:IsCourseMode() then
					SongOrCourse = GAMESTATE:GetCurrentCourse();
					StepsOrTrail = GAMESTATE:GetCurrentTrail(player);
				else
					SongOrCourse = GAMESTATE:GetCurrentSong();
					StepsOrTrail = GAMESTATE:GetCurrentSteps(player);
				end;

				if SongOrCourse then
					if StepsOrTrail then	
						profile = PROFILEMAN:GetProfile(player);
						scorelist = profile:GetHighScoreList(SongOrCourse,StepsOrTrail);
						local scores = scorelist:GetHighScores();
						local topscore = scores[1];
			
						if not topscore then
							text = string.format("%.2f%%", 0);
						else
							text = string.format("%.2f%%", topscore:GetPercentDP()*100.0);
						end;
					else
						text = string.format("%.2f%%", 0);
					end;
				else
					text = "?";
				end;
		
				self:settext( text );
			
			else
				self:visible(false);
			end
		end;
	};


	--PLAYER PROFILE highscore name
	pd[#pd+1] = LoadFont("_misoreg hires")..{
	
		InitCommand=cmd(x, highscorenameX; y, 176; zoom, zoom_factor; diffuse, color("0,0,0,1"); halign, 1);
		SetCommand=function(self)
		
			if PROFILEMAN:IsPersistentProfile(player) then
				local SongOrCourse, StepsOrTrail;

				local text = "";
				local profile, name, scores, topscore, scorelist;
		
				if GAMESTATE:IsCourseMode() then
					SongOrCourse = GAMESTATE:GetCurrentCourse();
					StepsOrTrail = GAMESTATE:GetCurrentTrail(player);
				else
					SongOrCourse = GAMESTATE:GetCurrentSong();
					StepsOrTrail = GAMESTATE:GetCurrentSteps(player);
				end;

				if SongOrCourse then
					if StepsOrTrail then	
						profile = PROFILEMAN:GetProfile(player);
						scorelist = profile:GetHighScoreList(SongOrCourse,StepsOrTrail);
						scores = scorelist:GetHighScores();
						topscore = scores[1];
		
						if topscore then
							name = topscore:GetName();
						end;
							
						if not name then
							text = "????";
						elseif name == "" then
							text = "----"
						else
							text = name
						end;
					else
						text = "???";
					end;
				else
					text = "???";
				end;
		
				self:settext( text );
			else
				self:visible(false);
			end;
		end;
	};
	t[#t+1] = pd;
			
end;


return t;