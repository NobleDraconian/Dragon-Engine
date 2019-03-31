--[[
	Audio Player

	Acts as a 'music player', allowing the easy deployment of audio on the client and server.

	Programmed by @Reshiram110
]]

local AudioPlayer={}

---------------------
-- Roblox Services --
---------------------
local HttpService=game:GetService("HttpService")

-------------
-- DEFINES --
-------------
local CLASS_DEBUG=true --Determines whether or not debug output will be displayed.

if CLASS_DEBUG then print("[Audio Player] Debug mode enabled. Logging will be verbose.") end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : new
-- @Description : Creates and returns a new instance of the audioplayer class.
-- @Returns : table "NewAudioPlayer" - The new instance of the audio player.
-- @Example : local MyAudioPlayer=AudioPlayer.new()
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer.new()
	local NewAudioPlayer={

		--[[ Properties ]]--
		Name="",
		Sound=Instance.new('Sound',script),
		
		Playlist={}, --Contains all of the information about the different sounds
		PlaylistPosition=0, --The current position in the playlist.

		AutoPlay=false, --Determines whether or not the audioplayer will autoplay when moving to a new song.
		Looped=false, --Determines whether or not the audioplayer will loop through the playlist.
		
		CurrentSong={Name="",ID="rbxassetid://0",Looped=false}, --Information about the current song

		_Destroyed=false, --Used to prevent further usage after this object is destroyed.
		
		--[[ Events ]]--
		_Events={
			AudioAdded=Instance.new('BindableEvent'), --Fired when an audio is added to the playlist.
			AudioRemoved=Instance.new('BindableEvent'), --Fired when an audio is removed from the playlist.
		}
		
	}
	NewAudioPlayer.AudioAdded=NewAudioPlayer._Events.AudioAdded.Event
	NewAudioPlayer.AudioRemoved=NewAudioPlayer._Events.AudioRemoved.Event

	setmetatable(NewAudioPlayer,{__index=AudioPlayer})

	return NewAudioPlayer
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : Destroy
-- @Description : Destroys the audio player.
-- @Example : AudioPlayer:Destroy()
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:Destroy()
	assert(self._Destroyed==false,"[Audio Player '"..self.Name.."'] Destroy() : Cannot destroy already destroyed audioplayer.")

	self:RemoveAllAudio()

	self.Sound:Destroy()
	for _,BindableEvent in pairs(self._Events) do
		BindableEvent:Destroy()
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : AddAudio
-- @Description : Adds an audio with the given name and ID to the playlist.
-- @Params : string "Name" - The name to assign to the audio being added.
--           string "ID" - The rbxasset id of the audio being added.
-- @Example : AudioPlayer:AddAudio("LobbyMusic","18300397")
--            AudioPlayer:AddAudio("LobbyMusic","rbxassetid://183003997")
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:AddAudio(Name,ID)
	assert(self._Destroyed==false,"[Audio Player '"..self.Name.."'] AddAudio() : Cannot add audio to destroyed audioplayer.")
	assert(ID~=nil,"[Audio Player '"..self.Name.."'] AddAudio() : Audio ID expected, got nil.")
	assert(typeof(ID)=="string","[Audio Player '"..self.Name.."'] AddAudio(): String expected for ID, got "..typeof(ID).." instead.")

	if string.find(ID,"rbxassetid://")==nil then
		ID="rbxassetid://"..ID
	end

	table.insert(self.Playlist,{
		Name=(Name or "NewAudio"),
		ID=ID,
		Looped=false
	})
	self._Events.AudioAdded:Fire(Name,#self.Playlist)

	if CLASS_DEBUG then
		print("")
		print("Audio added to audioplayer '"..self.Name.."'.")
		print("Added audio : "..HttpService:JSONEncode(self.Playlist[#self.Playlist]))
		print("New audio list :")
		for Index=1,#self.Playlist do
			print(Index.." : "..HttpService:JSONEncode(self.Playlist[Index]))
		end
		print("")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RemoveAudio
-- @Description : Removes an audio with the given name from the playlist.
-- @Params : string "Name" - The name of the audio to be removed from the playlist.
-- @Example : AudioPlayer:RemoveAudio("LobbyMusic")
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:RemoveAudio(Name)
	assert(self._Destroyed==false,"[Audio Player '"..self.Name.."'] RemoveAudio() : Cannot remove audio from destroyed audioplayer.")
	assert(Name~=nil,"[Audio Player '"..self.Name.."'] RemoveAudio() : Name expected, got nil.")
	assert(typeof(Name)=="string","[Audio Player '"..self.Name.."'] RemoveAudio() : string expected for Name, got "..typeof(Name).." instead.")

	local AudioIndex=self:FindAudio(Name)

	if AudioIndex~=nil then
		if CLASS_DEBUG then
			print("")
			print("Audio removed from audioplayer '"..self.Name.."'.")
			print("Removed audio : "..HttpService:JSONEncode(self.Playlist[AudioIndex]))
		end

		table.remove(self.Playlist,AudioIndex)
		self._Events.AudioRemoved:Fire(Name,AudioIndex)

		if CLASS_DEBUG then
			print("New audio list :")
			for Index=1,#self.Playlist do
				print(Index.." : "..HttpService:JSONEncode(self.Playlist[Index]))
			end
			print("")
		end
	else
		warn("[Audio Player '"..self.Name.."'] RemoveAudio() : Could not remove audio '"..Name.."', audio was not found.")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : RemoveAllAudio
-- @Description : Removes all audio from the playlist.
-- @Example : AudioPlayer:RemoveAllAudio()
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:RemoveAllAudio()
	assert(self._Destroyed==false,"[Audio Player '"..self.Name.."'] RemoveAudio() : Cannot remove audio from destroyed audioplayer.")

	for Index=1,#self.Playlist do
		self:RemoveAudio(self.Playlist[1].Name)
	end
	self.CurrentSong={}
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @Name : FindAudio
-- @Description : Finds an audio in the playlist with the given name.
-- @Params : string "Name" - The name of the audio to find.
-- @Returns : int "Index" - The index of where the audio is in the playlist. Returns nil if the requested audio is not found.
-- @Example : local SongIndex=AudioPlayer:FindAudio("LobbyMusic")
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AudioPlayer:FindAudio(Name)
	assert(self._Destroyed==false,"[Audio Player '"..self.Name.."'] FindAudio() : Cannot find audio in destroyed audioplayer.")
	assert(Name~=nil,"[Audio Player '"..self.Name.."'] FindAudio() : Name expected, got nil.")
	assert(typeof(Name)=="string","[Audio Player '"..self.Name.."'] FindAudio() : string expected for Name, got "..typeof(Name).." instead.")
	
	for Index=1,#self.Playlist do
		if self.Playlist[Index].Name==Name then return Index end
	end

	warn("[Audio Player '"..self.Name.."'] FindAudio() : Could not find an audio with the name '"..Name.."'.")

	return nil
end

return AudioPlayer