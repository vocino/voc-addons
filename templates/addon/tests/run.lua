-- VocName regression tests. Stub-harness: no WoW client needed.
-- Run from anywhere:  lua tests/run.lua   (repo root also fine)
-- Works on Lua 5.1 (the client's dialect) and 5.2+.
--
-- Convention: each test builds a fresh stub world, drives ns.* or the
-- frame's OnEvent handler or the slash handler, and asserts. Any failed
-- assert aborts with the test name. The stubs below are the family's
-- shared set (chat, sounds, tooltip, Settings, frames); add the WoW
-- APIs the one job reads beside them.

local testDir = debug.getinfo(1, "S").source:gsub("\\", "/"):match("@?(.*/)") or ""
local mainPath = testDir .. "../main.lua"

local passed = 0
local function check(name, cond)
  if not cond then error("FAIL: " .. name, 2) end
  passed = passed + 1
end

-- Fresh stub world per test.
local function loadAddon(world)
  local g = {}
  for k, v in pairs(_G) do g[k] = v end -- inherit stdlib (string, table...)
  g._G = g
  g.print = function(...) world.printed[#world.printed + 1] = table.concat({ ... }, " ") end
  g.strtrim = function(s) return (tostring(s or ""):gsub("^%s*(.-)%s*$", "%1")) end
  g.SlashCmdList = {}
  g.PlaySound = function(id) world.sounds[#world.sounds + 1] = id end
  g.GameTooltip = {
    SetOwner = function(_, owner, anchor) world.gametip.owner, world.gametip.anchor = owner, anchor end,
    SetText = function(_, t, r, gg, b) world.gametip.title = t world.gametip.titleColor = { r, gg, b } end,
    AddLine = function(_, t) world.gametip.lines[#world.gametip.lines + 1] = t end,
    Show = function() world.gametip.shown = true end,
    Hide = function() world.gametip.shown = false end,
  }
  g.CreateFrame = function(ftype, _, _, template)
    local f = { events = {}, scripts = {}, ctype = ftype, template = template }
    f.RegisterEvent = function(_, e) f.events[e] = true end
    f.UnregisterEvent = function(_, e) f.events[e] = nil end
    f.SetScript = function(_, n, fn) f.scripts[n] = fn end
    f.SetText = function(_, t) f.text = t end
    f.SetSize = function(_, w, h) f.size = { w, h } end
    f.SetPoint = function(_, ...) f.point = { ... } end
    f.SetShown = function(_, s) f.shown = s end
    world.frames[#world.frames + 1] = f
    return f
  end
  if world.withSettings then
    local S = {}
    S.RegisterVerticalLayoutCategory = function(n)
      world.settingsCat = n
      return { GetID = function() return 42 end }
    end
    S.RegisterAddOnCategory = function() world.settingsCatRegistered = true end
    S.RegisterAddOnSetting = function(_, var, key, tbl, typ, label, default)
      world.settingsReg[#world.settingsReg + 1] =
        { var = var, key = key, tbl = tbl, type = typ, label = label, default = default }
      local s = {}
      s.SetValueChangedCallback = function(_, fn) world.settingCallbacks[var] = fn end
      return s
    end
    S.CreateCheckbox = function() world.settingsChecks = world.settingsChecks + 1 end
    S.OpenToCategory = function(id) world.openedCategory = id end
    g.Settings = S
  end
  g.VocNameDB = nil -- client hasn't restored SavedVariables at file-exec time

  local f = assert(io.open(mainPath, "r"))
  local src = f:read("*a")
  f:close()
  -- 5.1 sandboxes with setfenv; 5.2+ takes the env as load's 4th arg.
  local chunk
  if setfenv then
    chunk = assert(loadstring(src, "@" .. mainPath))
    setfenv(chunk, g)
  else
    chunk = assert(load(src, "@" .. mainPath, "t", g))
  end
  local ns = {}
  chunk("VocName", ns)
  world.frame = world.frames[1] -- the event frame, created at load
  world.frame.onEvent = function(...)
    return world.frames[1].scripts.OnEvent(...)
  end
  world.ns = ns
  world.env = g
  return ns
end

local function newWorld()
  return { printed = {}, sounds = {}, frames = {}, gametip = { lines = {} },
           withSettings = false, settingsReg = {}, settingsChecks = 0,
           settingCallbacks = {}, savedVars = nil }
end

-- Simulate the client deserializing SavedVariables (a FRESH table replaces
-- the file-top default) and then firing ADDON_LOADED.
local function clientLoaded(w)
  w.env.VocNameDB = w.savedVars or {}
  w.frame.onEvent(nil, "ADDON_LOADED", "VocName")
end

-- 1. Defaults fill in; wrong-typed keys reset; unknown keys survive.
do
  local w = newWorld()
  w.savedVars = { enabled = "yes", custom = 7 }
  local ns = loadAddon(w)
  clientLoaded(w)
  local o = ns.opts()
  check("db rebound to the client's table", ns.db == w.env.VocNameDB)
  check("wrong-typed key resets", o.enabled == true)
  check("missing key defaults", o.announce == true)
  check("unknown key kept", o.custom == 7)
end

-- 2. Chat voice: colored addon prefix, then the message.
do
  local w = newWorld()
  local ns = loadAddon(w)
  ns.say("hello")
  check("say prefixes the addon name", w.printed[1] == "|c" .. ns.PREFIX_COLOR .. "VocName|r: hello")
  check("family prefix color", ns.PREFIX_COLOR == "ff66ccff")
end

-- 3. Slash grammar: toggle, on/off, config, help, typos never act.
do
  local w = newWorld()
  local ns = loadAddon(w)
  clientLoaded(w)
  local slash = w.env.SlashCmdList.VOCNAME
  check("short and long slash registered",
    w.env.SLASH_VOCNAME1 == "/vn" and w.env.SLASH_VOCNAME2 == "/vocname" and w.env.SLASH_VOCNAME3 == nil)
  slash("")
  check("bare toggles off", ns.opts().enabled == false)
  slash(" ON ")
  check("on sets explicitly", ns.opts().enabled == true)
  check("toggles confirm with the checkbox pair (numeric fallback, no SOUNDKIT)",
    table.concat(w.sounds, ",") == "857,856")
  w.env.SOUNDKIT = { IG_MAINMENU_OPTION_CHECKBOX_OFF = 1857 }
  slash("off")
  check("SOUNDKIT name wins over the fallback", w.sounds[#w.sounds] == 1857)
  slash("config")
  check("config prints the path without Settings",
    w.printed[#w.printed] == "|cff66ccffVocName|r: open Settings > AddOns > VocName")
  local before = #w.printed
  slash("help")
  check("help lists every command", #w.printed == before + 1 + #ns.HELP)
  check("help ends with config then help",
    ns.HELP[#ns.HELP - 1]:find("^/vn config") ~= nil and ns.HELP[#ns.HELP]:find("^/vn help") ~= nil
    and ns.HELP[#ns.HELP]:find("/vocname works too", 1, true) ~= nil)
  before = #w.printed
  slash("onn") -- typo: help, never an action
  check("unknown subcommand prints help", #w.printed == before + 1 + #ns.HELP)
  check("unknown subcommand never toggles", ns.opts().enabled == false)
end

-- 4. Native Settings panel: built once, bound to the live table,
-- retried at PLAYER_LOGIN, applied live.
do
  local w = newWorld()
  w.withSettings = true
  local ns = loadAddon(w)
  local S = w.env.Settings
  w.env.Settings = nil
  clientLoaded(w)
  check("no Settings at ADDON_LOADED: nothing built", ns.settingsBuilt == false)
  w.env.Settings = S
  w.frame.onEvent(nil, "PLAYER_LOGIN")
  check("PLAYER_LOGIN builds the panel", ns.settingsBuilt == true and w.settingsCat == "VocName")
  check("category registered", w.settingsCatRegistered == true)
  check("two checkboxes", w.settingsChecks == 2 and #w.settingsReg == 2)
  check("bound to the live table", w.settingsReg[1].tbl == ns.db)
  check("every setting has a callback", w.settingCallbacks["VocName_enabled"] ~= nil
    and w.settingCallbacks["VocName_announce"] ~= nil)
  w.frame.onEvent(nil, "PLAYER_LOGIN")
  check("built once", w.settingsChecks == 2)
  w.env.SlashCmdList.VOCNAME("config")
  check("config opens the category", w.openedCategory == 42)
end

-- 5. Addon compartment: click opens settings; hover follows the tooltip
-- contract (gold title, one line, the slash hint).
do
  local w = newWorld()
  w.withSettings = true
  loadAddon(w)
  clientLoaded(w)
  check("compartment globals", type(w.env.VocName_CompartmentClick) == "function"
    and type(w.env.VocName_CompartmentEnter) == "function"
    and type(w.env.VocName_CompartmentLeave) == "function")
  w.env.VocName_CompartmentClick("VocName", "LeftButton")
  check("compartment click opens config", w.openedCategory == 42)
  local btn = {}
  w.env.VocName_CompartmentEnter("VocName", btn)
  check("compartment tooltip anchors to the button", w.gametip.owner == btn and w.gametip.shown == true)
  check("compartment tooltip title is gold", w.gametip.title == "VocName"
    and w.gametip.titleColor[1] == 1 and w.gametip.titleColor[2] == 0.82 and w.gametip.titleColor[3] == 0)
  check("compartment tooltip teaches the slash", #w.gametip.lines == 2
    and w.gametip.lines[2]:find("/vn", 1, true) ~= nil)
  w.env.VocName_CompartmentLeave("VocName", btn)
  check("compartment leave hides the tooltip", w.gametip.shown == false)
end

-- 6. The one job runs at login, honors the switch, and stays quiet when
-- announcements are off.
do
  local w = newWorld()
  local ns = loadAddon(w)
  clientLoaded(w)
  w.frame.onEvent(nil, "PLAYER_LOGIN")
  check("runs at login", w.printed[#w.printed] == "|cff66ccffVocName|r: did the one job")
  ns.opts().announce = false
  local before = #w.printed
  ns.run()
  check("quiet without announce", #w.printed == before)
  ns.opts().enabled = false
  ns.opts().announce = true
  ns.run()
  check("off does nothing", #w.printed == before)
end

print("tests/run.lua: " .. passed .. " checks passed")
