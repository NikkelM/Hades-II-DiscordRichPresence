-- Public Discord application ID
local applicationId = "1567677136884605080"

local function presenceProperty(definition, name)
	local key = definition and definition.DiscordRichPresence
	if key ~= nil then
		return key
	end

	return mod.PresenceLocations[name] and name or nil
end

local function activityForLocation(key)
	local location = mod.PresenceLocations[key]
	return {
		details = location.Details,
		large_image = location.LargeImage,
		large_text = "Hades II",
	}
end

function mod.InitializePresence()
	mod.PresenceContext = {}
	mod.AssignPresenceProperties()
	rom.discord.start(applicationId, activityForLocation("MainMenu"))
end

function mod.SubmitPresenceLocation(key)
	local activity = activityForLocation(key)
	local context = mod.PresenceContext

	if context.Trial then
		activity.state = "Attempting a Chaos Trial"
	elseif context.Dream then
		activity.state = "In a Dream Dive"
		if game.CurrentRun and game.CurrentRun["zerp-DreamDiveTweaksEndlessStarted"] then
			activity.state = "In an Endless Dream (Region " .. context.DreamRegion .. " of ???)"
		elseif context.DreamRegion > 0 then
			activity.state = activity.state ..
					" (Region " .. context.DreamRegion .. " of " .. game.GameData.FullRunBiomeCount .. ")"
		end
	end

	rom.discord.set_activity(activity)
end

function mod.PublishPresence(token)
	local context = mod.PresenceContext
	local key = token and token:match("^#RichPresence_(.*)$") or ""

	if context.RoomPresence == "EndingUnderworld" or context.RoomPresence == "EndingSurface" then
		mod.SubmitPresenceLocation(context.RoomPresence)
		return
	end

	if key == "Dream" then
		local location = "Dream"
		if context.H1Flashback then
			location = "H1Flashback"
		elseif context.Room:find("Flashback", 1, true) then
			location = "Flashback"
		elseif context.Anomaly then
			location = "Anomaly"
		elseif context.Dream then
			location = context.EncounterPresence or context.RoomPresence or
					mod.PresenceLocations[context.Region] and context.Region or "Dream"
		end
		mod.SubmitPresenceLocation(location)
		return
	end

	local biomeToken = #key == 1 and ("FGHINOPQ"):find(key, 1, true)
	if key == "" or biomeToken or key == "Boss" then
		local location = context.EncounterPresence or context.RoomPresence
		if location then
			mod.SubmitPresenceLocation(location)
			return
		end
	end

	local location = mod.PresenceLocations[key] and key or mod.PresenceLocations[context.Region] and context.Region or
			"Misc"

	mod.SubmitPresenceLocation(location)
end

---@param currentRun table|nil
---@param currentRoom table
---@param hub boolean
---@param restored? boolean
function mod.ObservePresenceRoom(currentRun, currentRoom, hub, restored)
	currentRun       = currentRun or {}

	local definition = not hub and game.RoomData[currentRoom.Name] or nil
	local bounty     = not hub and game.BountyData[currentRun.ActiveBounty]
	local region     = currentRoom.RoomSetName
	local encounter  = not hub and currentRoom.Encounter

	local context    = {
		Room = currentRoom.Name,
		Region = region,
		RoomPresence = not hub and presenceProperty(definition, currentRoom.Name) or nil,
		EncounterPresence = encounter and presenceProperty(game.EncounterData[encounter.Name], encounter.Name) or nil,
		Anomaly = region == "Anomaly",
		H1Flashback = currentRoom.ModsNikkelMHadesBiomesFlashbackScenes,
		Trial = bounty and bounty.Category == "PackagedBounty",
		Dream = not hub and currentRun.IsDreamRun,
	}

	if context.Dream then
		local current = currentRun.EnteredBiomes
		if not restored and currentRoom.BiomeStartRoom then
			current = current + 1
		end
		context.DreamRegion = current
	end

	mod.PresenceContext = context
	local token = definition and definition.RichPresence or currentRoom.RichPresence
	if hub and not token then
		token = "#RichPresence_Hub"
	end

	mod.PublishPresence(token)
end

function mod.RefreshPresence()
	local currentRun = game.CurrentRun
	if game.CurrentHubRoom then
		mod.ObservePresenceRoom(nil, game.CurrentHubRoom, true)
	elseif currentRun and currentRun.CurrentRoom then
		mod.ObservePresenceRoom(currentRun, currentRun.CurrentRoom, false, true)
	end
end
