local name, ns = ...
-- VocName: one sentence saying what it does. Nothing else.
--
-- This is the family skeleton (voc-addons templates/addon): chat voice,
-- sounds, palette, defaults, a native Settings panel, the compartment
-- entry, and the slash grammar, each in the shape every sibling uses.
-- Replace the one job below; keep the shape.

VocNameDB = VocNameDB or {}
ns.db = VocNameDB

-- Chat voice shared by every Voc addon (FAMILY.md "Chat voice"): one
-- line, the addon name as a colored prefix, then the message.
ns.PREFIX_COLOR = "ff66ccff"
function ns.say(msg)
  print("|c" .. ns.PREFIX_COLOR .. name .. "|r: " .. tostring(msg))
end

-- Confirmation sounds shared by every Voc addon (FAMILY.md "Sounds"):
-- SOUNDKIT names first, the numeric IDs behind them so a Blizzard
-- rename never silences the polish. Presence-gated: no sound API, no
-- sound, never an error.
ns.SOUNDS = {
  on = { "IG_MAINMENU_OPTION_CHECKBOX_ON", 856 },
  off = { "IG_MAINMENU_OPTION_CHECKBOX_OFF", 857 },
  open = { "IG_MAINMENU_OPEN", 850 },
  close = { "IG_MAINMENU_CLOSE", 851 },
}
function ns.play(kind)
  local s = ns.SOUNDS[kind]
  if not s or type(PlaySound) ~= "function" then return end
  local id = type(SOUNDKIT) == "table" and SOUNDKIT[s[1]] or nil
  pcall(PlaySound, type(id) == "number" and id or s[2])
end

-- Palette (FAMILY.md "Palette"), defined once. Nothing paints a color
-- at a call site.
ns.COLORS = {
  gold = { 1, 0.82, 0 },
  text = { 1, 1, 1 },
  muted = { 0.5, 0.5, 0.5 },
  red = { 0.9, 0.3, 0.25 },
  green = { 0.25, 0.9, 0.35 },
}
local COLORS = ns.COLORS

-- Defaults: the single source of truth (FAMILY.md "Settings"). A key
-- holding the wrong type resets; unknown keys are left alone.
local defaults = {
  enabled = true,
  announce = true,
}
ns.defaults = defaults

function ns.opts()
  if type(ns.db) ~= "table" then ns.db = {} VocNameDB = ns.db end
  for k, v in pairs(defaults) do
    if type(ns.db[k]) ~= type(v) then ns.db[k] = v end
  end
  return ns.db
end

-- The one job. ------------------------------------------------------

-- Replace this with the addon's work. Keep it behind ns.* functions
-- that stubbed WoW APIs can drive (FAMILY.md principle 7).
function ns.run()
  local o = ns.opts()
  if not o.enabled then return end
  if o.announce then ns.say("did the one job") end
end

-- Toggle or set the main switch; every toggle confirms with the
-- checkbox pair (voc-addons principle 3).
function ns.setEnabled(on)
  local o = ns.opts()
  o.enabled = on
  ns.play(on and "on" or "off")
  ns.say("VocName " .. (on and "on" or "off"))
end

-- Blizzard Settings panel (Settings > AddOns > VocName). Built once,
-- after SavedVariables land, and only if the Settings API is present;
-- every setting carries a value-changed callback so it applies live.
function ns.onSettingChanged(setting, fn)
  if setting and type(setting.SetValueChangedCallback) == "function" then
    setting:SetValueChangedCallback(fn)
  end
end

ns.settingsBuilt = false
function ns.ensureSettings()
  if ns.settingsBuilt then return end
  if type(Settings) ~= "table" then return end
  if type(Settings.RegisterVerticalLayoutCategory) ~= "function" then return end
  local category = Settings.RegisterVerticalLayoutCategory("VocName")
  Settings.RegisterAddOnCategory(category)
  local db = ns.opts() -- bound, defaulted table
  local function check(key, label, tooltip, onChange)
    local s = Settings.RegisterAddOnSetting(
      category, "VocName_" .. key, key, db, type(defaults[key]), label, defaults[key])
    Settings.CreateCheckbox(category, s, tooltip)
    ns.onSettingChanged(s, onChange or ns.run)
  end
  check("enabled", "Enable VocName", "Do the one job. Off leaves everything alone.")
  check("announce", "Chat announcements", "Print a line when VocName acts.")
  ns.settingsBuilt = true
  ns.settingsCategory = category
end

function ns.openConfig()
  local ok = pcall(function() Settings.OpenToCategory(ns.settingsCategory:GetID()) end)
  if not ok then ns.say("open Settings > AddOns > VocName") end
end

-- Addon compartment (FAMILY.md "Addon compartment"): the toc names
-- these three globals; Blizzard's compartment menu calls them with
-- (addonName, button). The click opens the window when the addon has
-- one and its settings otherwise; hover follows the tooltip contract:
-- gold title, one line, the slash hint.
function VocName_CompartmentClick()
  ns.openConfig()
end

function VocName_CompartmentEnter(_, button)
  if type(GameTooltip) ~= "table" then return end
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  GameTooltip:SetText("VocName", COLORS.gold[1], COLORS.gold[2], COLORS.gold[3])
  GameTooltip:AddLine("One sentence saying what it does.",
    COLORS.text[1], COLORS.text[2], COLORS.text[3], true)
  GameTooltip:AddLine("/vn toggles it. /vn help lists the rest.",
    COLORS.muted[1], COLORS.muted[2], COLORS.muted[3], true)
  GameTooltip:Show()
end

function VocName_CompartmentLeave()
  if type(GameTooltip) == "table" then GameTooltip:Hide() end
end

-- Slash grammar shared by every Voc addon (FAMILY.md): the bare command
-- does the one main thing, `config` opens the panel, `help` lists the
-- rest, and anything unrecognized prints help instead of acting.
ns.HELP = {
  "/vn            toggle VocName on/off",
  "/vn on|off     set it explicitly",
  "/vn config     open Settings > AddOns > VocName",
  "/vn help       this list (/vocname works too)",
}

function ns.help()
  ns.say("commands")
  for _, line in ipairs(ns.HELP) do print("  " .. line) end
end

-- Blizzard's slash dispatcher reads SLASH_* globals by name, so these
-- cannot be namespaced (they are declared in .luacheckrc instead).
SLASH_VOCNAME1 = "/vn"
SLASH_VOCNAME2 = "/vocname"
SlashCmdList.VOCNAME = function(msg)
  msg = strtrim(msg or ""):lower()
  if msg == "" then
    ns.setEnabled(not ns.opts().enabled)
  elseif msg == "on" or msg == "off" then
    ns.setEnabled(msg == "on")
  elseif msg == "config" then
    ns.openConfig()
  else
    ns.help()
  end
end

-- Events. ADDON_LOADED rebinds SavedVariables (the client replaces the
-- global after this file ran); PLAYER_LOGIN retries the panel in case
-- the Settings API was not up yet.
ns.frame = CreateFrame("Frame")
ns.frame:RegisterEvent("ADDON_LOADED")
ns.frame:RegisterEvent("PLAYER_LOGIN")
ns.frame:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 ~= name then return end
    if type(VocNameDB) ~= "table" then VocNameDB = {} end
    ns.db = VocNameDB
    ns.ensureSettings()
  elseif event == "PLAYER_LOGIN" then
    ns.ensureSettings()
    ns.run()
  end
end)
