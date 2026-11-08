modutil.mod.Path.Wrap("SetRichPresence", function(base, args)
	base(args)

	-- To only change the Discord status, not the Steam status
	if args.Key == "status" then
		mod.PublishPresence(args.Value)
	end
end)

modutil.mod.Path.Wrap("StartRoom", function(base, currentRun, currentRoom)
	mod.ObservePresenceRoom(currentRun, currentRoom, false)

	return base(currentRun, currentRoom)
end)

modutil.mod.Path.Wrap("RestoreUnlockRoomExits", function(base, currentRun, currentRoom)
	mod.ObservePresenceRoom(currentRun, currentRoom, false, true)

	return base(currentRun, currentRoom)
end)

modutil.mod.Path.Wrap("DeathAreaRoomTransition", function(base, currentRoom, args)
	mod.ObservePresenceRoom(nil, currentRoom, true)

	return base(currentRoom, args)
end)

modutil.mod.Path.Wrap("HubPostBountyLoad", function(base, currentRoom, args)
	mod.ObservePresenceRoom(nil, currentRoom, true)

	return base(currentRoom, args)
end)

modutil.mod.Path.Wrap("HubPostDreamLoad", function(base, currentRoom, args)
	mod.ObservePresenceRoom(nil, currentRoom, true)

	return base(currentRoom, args)
end)
