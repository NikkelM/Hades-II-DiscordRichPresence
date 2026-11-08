---@meta _

import = require

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY'].auto()
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']
---@module 'SGG_Modding-Chalk'
chalk = mods['SGG_Modding-Chalk']
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto 'config.lua'
public.config = config

local function on_ready()
	if config.enabled == false then return end

	mod = modutil.mod.Mod.Register(_PLUGIN.guid)

	import "Scripts/PresenceData.lua"
	import "Scripts/RichPresence.lua"
	import "Scripts/RoomLogic.lua"

	mod.InitializePresence()
end

local function on_reload()
	if config.enabled == false then return end

	mod.InitializePresence()
	mod.RefreshPresence()
end

local function on_ready_late()
	if config.enabled == false then return end
end

local function on_reload_late()
	if config.enabled == false then return end
end

local loader = reload.auto_multiple()

modutil.once_loaded.game(function()
	loader.load("early", on_ready, on_reload)
end)

mods.on_all_mods_loaded(function()
	modutil.once_loaded.game(function()
		loader.load("late", on_ready_late, on_reload_late)
	end)
end)
