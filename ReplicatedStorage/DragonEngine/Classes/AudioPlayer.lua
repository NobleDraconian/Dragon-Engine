--[[
	Music Player
	
	Acts as a 'music player', allowing the easy deployment of audio on the client and server.
		
	Programmed by @Reshiram110
	
	Last updated : 8-18-2018 @ 1:30 AM EST (Added methods 'ResumeAudio' and 'PauseAudio')
--]]

--[[
	Option parameter
	
	You can supply options to apply to audio with most Audio Player functions.
	The options table is structured like the following:
	{
		Property=Value,
		Property=Value,
		Tween={
			TweenInfo.new(),
			{
				Property=Goal,
				Property=Goal,			
			}
		}
	}
	
	Here's an example that slows the currently playing audio's pitch and stops it in the timespan of two seconds.
	AudioPlayer:StopAudio({
		Tween={
			TweenInfo.new(2),
			{
				Pitch=0
			}
		}	
	})
	
	Here's another example that plays an audio 20 seconds and fades it in in the timespan of 1 second.
	AudioPlayer:PlayAudio("MySong",{
		Time=20,
		Tween={
			TweenInfo.new(1),
			{
				Volume=1,
			}
		}
	})
--]]



---------------------
-- ROBLOX Services --
---------------------

-------------
-- DEFINES --
-------------

---------------
-- FUNCTIONS --
---------------
local function GetAudioFromList(Name,List)
	for i,v in pairs(List) do
		if v[1]==Name then
			return v[2],i
		end
	end
	return false
end



local AudioPlayer={}

function AudioPlayer.new(Location)
	local NewAudioPlayer={
		Audio=Instance.new('Sound',Location or script), --Creating a sound object at the given location
		                                                --or at the script location by default.
		AudioList={}, --Holds all sound names and their IDs.
		CurrentAudio=0, --The current position in the audio list.
				
		Name="Audio Player" --The name of the audio player.
	}
	setmetatable(NewAudioPlayer,{__index=AudioPlayer})
	
	return NewAudioPlayer
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : AddAudio
-- @Description : Adds an audio with the given name and ID to the audio list.
-- @Params : string "Name" - The name to assign to the audio being added.
--           string "ID" - The rbxasset id of the audio being added.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:AddAudio(Name,ID)
	table.insert(self.AudioList,{Name,"rbxassetid://"..ID}) --Adding the audio to the audio list.
	self.Audio.SoundId="rbxassetid://"..ID
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RemoveAudio
-- @Description : Removes the audio with the given name from the audio list.
-- @Params : string "Name " - The name of the audio to remove from the audio list.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:RemoveAudio(Name)
	local ID,Index=GetAudioFromList(Name,self.AudioList) --Getting the audio information from the audio list.
	
	assert(ID~=false,self.Name.." : Failed to remove audio '"..Name.."', audio not found.")
	
	table.remove(self.AudioList,Index) --Removing the audio from the audio list.
	if self.AudioList[Index]==nil then self.CurrentAudio=#self.AudioList end --If the removed song was at the end
	                                                                         --of the audio list, then automatically
	                                                                         --set the audio list position to the last
	                                                                         --audio in the audio list.
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RemoveAllAudio
-- @Description : Removes ALL audio from the audio list.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:RemoveAllAudio()
	self.AudioList={}
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : PlayAudio
-- @Description : Plays an audio in the audio list with the given name, and applies additional options to the
--                audio.
-- @Params : string "Name" - The name of the audio to play.
--           optional table "Options" - The table of options to apply to the audio. See top of module for more info.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:PlayAudio(Name,Options)
	
	local ID,Index=GetAudioFromList(Name,self.AudioList) --Getting the audio information from the audio list.
	
	assert(ID~=false,self.Name.." : Failed to play audio '"..Name.."', audio not found.")
	
	self.Audio.SoundId=ID
	
	wait() --Dunno why, but adding this wait() here lets any tweens on the audio run properly. Hacky?
	
	self.CurrentAudio=Index	--Setting the audio list pointer to the current audio index position.
	
	if Options~=nil then --There is options being applied to the audio.
		
		--[[ Iterating through all non-tween options and applying them to the audio ]]--
		for Property,Value in pairs(Options) do
			if Property~="Tween" then --Option isn't a tween, change the property of the audio.
				self.Audio[Property]=Value
			end
		end
		
		--[[ If a tween exists, we run the tween on the audio ]]--
		if Options["Tween"]~=nil then --There is a tween, play it.
			local Tween=game:GetService("TweenService"):Create(self.Audio,Options["Tween"][1],Options["Tween"][2])
			Tween:Play()
		end
	end
	
	self.Audio:Play()
	--We check for a timeposition property because it has to be set AFTER audio is :Play()ed. (Ignore this)
	--if Options~=nil and Options["TimePosition"]~=nil then self.Audio.TimePosition=Options.TimePosition end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : StopAudio
-- @Description : Stops the currently playing audio, and applies additional options to the audio.
-- @Params : optional table "Options" - The table of options to apply to the audio. See top of module for more info.
--           bool "YieldForTween" - Determiens whether or not the calling thread will wait for the audios tween
--                                  to finish playing before contuining. (Only applicable if a tween option is set.)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:StopAudio(Options,YieldForTween)
	local Tween;
	
	if Options~=nil then --There is options being applied to the audio before stopping it.
		
		--[[ Iterating through all non-tween options and applying them to the audio ]]--
		for Property,Value in pairs(Options) do
			if Property~="Tween" then
				self.Audio[Property]=Value --Option isn't a tween, change the property of the audio.
			end
		end
		
		--[[ If a tween exists, we run the tween on the audio ]]--
		if Options["Tween"]~=nil then --There is a tween, play it.
			Tween=game:GetService("TweenService"):Create(self.Audio,Options["Tween"][1],Options["Tween"][2])
			Tween:Play()	
		end
		
	end
	
	if YieldForTween then --Wait for the tween to finish running before contuining.
		if YieldForTween then Tween.Completed:wait() end
		self.Audio:Stop()
	else
		if Tween~=nil then --If a tween option exists, run the tween in a new thread.
			spawn(function()
				Tween.Completed:wait()
				self.Audio:Stop()
			end)
		end
	end
	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : PauseAudio
-- @Description : Pauses the currently playing audio, and applies additional options to the audio.
-- @Params : optional table "Options" - The table of options to apply to the audio. See top of module for more info.
--           bool "YieldForTween" - Determiens whether or not the calling thread will wait for the audios tween
--                                  to finish playing before contuining. (Only applicable if a tween option is set.)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:PauseAudio(Options,YieldForTween)
	local Tween;
	
	if Options~=nil then --There is options being applied to the audio before pausing it.
		
		--[[ Iterating through all non-tween options and applying them to the audio ]]--
		for Property,Value in pairs(Options) do
			if Property~="Tween" then
				self.Audio[Property]=Value --Option isn't a tween, change the property of the audio.
			end
		end
		
		--[[ If a tween exists, we run the tween on the audio ]]--
		if Options["Tween"]~=nil then --There is a tween, play it.
			Tween=game:GetService("TweenService"):Create(self.Audio,Options["Tween"][1],Options["Tween"][2])
			Tween:Play()	
		end
		
	end
	
	if YieldForTween then --Wait for the tween to finish running before contuining.
		if YieldForTween then Tween.Completed:wait() end
		self.Audio:Pause()
	else
		if Tween~=nil then --If a tween option exists, run the tween in a new thread.
			spawn(function()
				Tween.Completed:wait()
				self.Audio:Pause()
			end)
		else
			self.Audio:Pause()
		end
	end
	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : ResumeAudio
-- @Description : Resumes an audio that was paused, and applies additional options to the audio.
-- @Params : string "Name" - The name of the audio to play.
--           optional table "Options" - The table of options to apply to the audio. See top of module for more info.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:ResumeAudio(Options,YieldForTween)
	local Tween;
	
	self.Audio:Resume()
	
	if Options~=nil then --There is options being applied to the audio before pausing it.
		
		--[[ Iterating through all non-tween options and applying them to the audio ]]--
		for Property,Value in pairs(Options) do
			if Property~="Tween" then
				self.Audio[Property]=Value --Option isn't a tween, change the property of the audio.
			end
		end
		
		--[[ If a tween exists, we run the tween on the audio ]]--
		if Options["Tween"]~=nil then --There is a tween, play it.
			Tween=game:GetService("TweenService"):Create(self.Audio,Options["Tween"][1],Options["Tween"][2])
			Tween:Play()	
		end
	end
	
	if YieldForTween then --Wait for the tween to finish running before contuining.
		if YieldForTween then Tween.Completed:wait() end
	else
		if Tween~=nil then --If a tween option exists, run the tween in a new thread.
			spawn(function()
				Tween.Completed:wait()
			end)
		end
	end
	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : PlayNext
-- @Description : Plays the next audio in the list. If the previous position in the audio list was the last position,
--                the audio list position is automatically set to the first position.
-- @Params : optional table "Options" - The table of options to apply to the audio. See top of module for more info.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:PlayNext(Options)
	self.CurrentAudio=self.CurrentAudio+1
	if self.AudioList[self.CurrentAudio]==nil then self.CurrentAudio=1 end --Moving to the first position in the audio list.
	self:PlayAudio(self.AudioList[self.CurrentAudio][1],Options) --Playing the audio.
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : PlayRandom
-- @Description : Plays a random audio from the audio list.
-- @Params : optional table "Options" - The table of options to apply to the audio. See top of module for more info.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:PlayRandom(Options)
	local Name=self.AudioList[Random.new():NextInteger(1,#self.AudioList)][1] --Picking a random audio from the audio list.
	self:PlayAudio(Name,Options)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Destroy
-- @Description : Destroys the audio player.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:Destroy()
	self.Audio:Destroy()
	setmetatable(self,{__index=nil,__newindex=nil})
end

return AudioPlayer