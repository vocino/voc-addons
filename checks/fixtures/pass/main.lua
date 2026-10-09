local name, ns = ...
-- The smallest addon that passes every voc-addons check. checks/self-test.sh
-- mutates a copy of this folder to prove each check fails when it should.

ns.PREFIX_COLOR = "ff66ccff"
function ns.say(msg)
  print("|c" .. ns.PREFIX_COLOR .. name .. "|r: " .. tostring(msg))
end

ns.COLORS = { gold = { 1, 0.82, 0 }, text = { 1, 1, 1 }, muted = { 0.5, 0.5, 0.5 } }

ns.SOUNDS = { on = { "IG_MAINMENU_OPTION_CHECKBOX_ON", 856 } }
function ns.play(kind)
  local s = ns.SOUNDS[kind]
  if not s or type(PlaySound) ~= "function" then return end
  local id = type(SOUNDKIT) == "table" and SOUNDKIT[s[1]] or nil
  pcall(PlaySound, type(id) == "number" and id or s[2])
end

function VocFixture_CompartmentClick() ns.say("hello") end
function VocFixture_CompartmentEnter(_, button)
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  GameTooltip:SetText("VocFixture", ns.COLORS.gold[1], ns.COLORS.gold[2], ns.COLORS.gold[3])
  GameTooltip:Show()
end
function VocFixture_CompartmentLeave() GameTooltip:Hide() end

ns.HELP = {
  "/vf            say hello",
  "/vf config     open Settings > AddOns > VocFixture",
  "/vf help       this list (/vocfixture works too)",
}
