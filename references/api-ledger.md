# API ledger

Every Blizzard name the Voc family relies on, with how it was verified
(FAMILY.md "Sources of truth"; the skill's principle 11). One row per
name, the verdict of `tools/verify-api` on the `live` and `forever`
branches of the wow-ui-source mirror. The per-repo `.reference/`
folders hold local analysis checkouts and notes; this file is the
shared, auditable record, so a claim that a name was verified can be
read by anyone.

Verdicts: `ok, documented` means listed in
`Blizzard_APIDocumentationGenerated` under that namespace; `ok, Lua:
<file>` means defined in Blizzard's own UI code; `ok, documented
global` and `bare` mean a C-side global Blizzard's code still calls
bare (`bare` is undocumented, so presence-gate it); `used` means an
undocumented namespaced function Blizzard's own code calls, so
presence-gate it. A name whose verdict is `GONE` or `unknown` never
ships unguarded, and the bare forms Blizzard moved into a namespace
live in `checks/deprecated-globals.txt` instead of here.

Last full run: 2026-10-09, both branches at that day's head. Re-run
with `tools/verify-api <name>...`; when a row changes, change the code
first, the row second. Add a row when an addon comes to rely on a new
name, and paste the verdict into the commit that adds the name to
`.luacheckrc`.

| Name | live | forever |
| --- | --- | --- |
| `C_AddOns.GetAddOnInfo` | ok, documented | same |
| `C_AddOns.IsAddOnLoaded` | ok, documented | same |
| `C_AddOns.GetAddOnMetadata` | ok, documented | same |
| `C_Container.GetContainerItemInfo` | ok, documented | same |
| `C_Container.GetContainerItemLink` | ok, documented | same |
| `C_Container.GetContainerNumSlots` | ok, documented | same |
| `C_Container.PickupContainerItem` | ok, documented | same |
| `C_Container.UseContainerItem` | ok, documented | same |
| `C_EquipmentSet.GetEquipmentSetIDs` | ok, documented | same |
| `C_EquipmentSet.GetItemIDs` | ok, documented | same |
| `C_Item.EquipItemByName` | ok, documented | same |
| `C_Item.GetDetailedItemLevelInfo` | ok, documented | same |
| `C_Item.GetItemIconByID` | ok, documented | same |
| `C_Item.GetItemInfo` | ok, documented | same |
| `C_Item.GetItemInfoInstant` | ok, documented | same |
| `C_Item.GetItemSetInfo` | ok, documented | same |
| `C_Item.GetItemUniquenessByID` | ok, documented | same |
| `C_Item.GetSetBonusesForSpecializationByItemID` | ok, documented | same |
| `C_Item.IsDecorItem` | ok, documented | same |
| `C_Item.IsItemBindToAccountUntilEquip` | ok, documented | same |
| `C_Item.RequestLoadItemDataByID` | ok, documented | same |
| `C_MerchantFrame.GetNumJunkItems` | ok, documented | same |
| `C_MerchantFrame.SellAllJunkItems` | ok, documented | same |
| `C_MountJournal.GetMountFromItem` | ok, documented | same |
| `C_MountJournal.GetMountInfoByID` | ok, documented | same |
| `C_PetJournal.GetPetInfoByItemID` | used, undocumented; Blizzard calls it | same |
| `C_PetJournal.GetNumCollectedInfo` | used, undocumented; Blizzard calls it | same |
| `C_PvP.GetWarModeRewardBonus` | ok, documented | same |
| `C_PvP.IsWarModeDesired` | ok, documented | same |
| `C_QuestLog.GetAllCompletedQuestIDs` | ok, documented | same |
| `C_QuestLog.GetTitleForQuestID` | ok, documented | same |
| `C_Sound.PlaySound` | ok, documented | same |
| `C_SpecializationInfo.GetSpecialization` | ok, documented | same |
| `C_SpecializationInfo.GetSpecializationInfo` | ok, documented | same |
| `C_Spell.GetSpellName` | ok, documented | same |
| `C_Timer.After` | ok, documented | same |
| `C_Timer.NewTicker` | ok, documented | same |
| `C_ToyBox.GetToyInfo` | used, undocumented; Blizzard calls it | same |
| `C_TransmogCollection.PlayerHasTransmog` | ok, documented | same |
| `C_UnitAuras.GetPlayerAuraBySpellID` | ok, documented | same |
| `CanGuildBankRepair` | bare, undocumented; Blizzard calls it | same |
| `CanMerchantRepair` | bare, undocumented; Blizzard calls it | same |
| `ClickSendMailItemButton` | bare, undocumented; Blizzard calls it | same |
| `CreateFrame` | bare, undocumented; Blizzard calls it | same |
| `CreateObjectPool` | ok, Lua: Blizzard_SharedXMLBase/Pools.lua | same |
| `CreateSettingsListSectionHeaderInitializer` | ok, Lua: Blizzard_Settings_Shared/Blizzard_SettingControls.lua | same |
| `DeleteCursorItem` | ok, documented global | same |
| `GetCursorInfo` | ok, documented global | same |
| `GetExpansionLevel` | ok, documented global | same |
| `GetInventoryItemLink` | bare, undocumented; Blizzard calls it | same |
| `GetMoney` | ok, documented global | same |
| `GetProfessionInfo` | bare, undocumented; Blizzard calls it | same |
| `GetProfessions` | bare, undocumented; Blizzard calls it | same |
| `GetRepairAllCost` | bare, undocumented; Blizzard calls it | same |
| `GetTime` | ok, documented global | same |
| `GetXPExhaustion` | ok, documented global | same |
| `InCombatLockdown` | bare, undocumented; Blizzard calls it | same |
| `IsInInstance` | ok, documented global | same |
| `IsShiftKeyDown` | ok, documented global | same |
| `PlaySound` | ok, Lua: Blizzard_SharedXML/Mainline/Sound.lua | same |
| `PlayerHasToy` | bare, undocumented; Blizzard calls it | same |
| `Pool_HideAndClearAnchors` | ok, Lua: Blizzard_SharedXMLBase/Pools.lua | same |
| `RepairAllItems` | bare, undocumented; Blizzard calls it | same |
| `StaticPopup_Show` | ok, Lua: Blizzard_StaticPopup/StaticPopup.lua | same |
| `UnitClass` | ok, documented global | same |
| `UnitGUID` | ok, documented global | same |
| `UnitLevel` | ok, documented global | same |
| `UnitXP` | ok, documented global | same |
| `UnitXPMax` | ok, documented global | same |
| `hooksecurefunc` | bare, undocumented; Blizzard calls it | same |
| `strtrim` | ok, Lua: Blizzard_SharedXMLBase/Compat.lua | same |
| `Mixin` | ok, documented global | same |
| `BackdropTemplateMixin` | ok, Lua: Blizzard_SharedXML/Backdrop.lua | same |
| `MinimalSliderWithSteppersMixin` | ok, Lua: Blizzard_SharedXML/Shared/Slider/MinimalSlider.lua | same |
| `UIPanelButtonMixin` | ok, Lua: Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.lua | same |
| `Settings.RegisterVerticalLayoutCategory` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.RegisterAddOnCategory` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.RegisterAddOnSetting` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.CreateCheckbox` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.CreateSlider` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.CreateDropdown` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.CreateSliderOptions` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.CreateControlTextContainer` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `Settings.OpenToCategory` | ok, Lua: Blizzard_Settings_Shared/Blizzard_Settings.lua | same |
| `SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON` | ok, = 856 | same |
| `SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF` | ok, = 857 | same |
| `SOUNDKIT.IG_MAINMENU_OPEN` | ok, = 850 | same |
| `SOUNDKIT.IG_MAINMENU_CLOSE` | ok, = 851 | same |
| `SOUNDKIT.ITEM_REPAIR` | ok, = 7994 | same |
| `SOUNDKIT.IG_QUEST_LIST_COMPLETE` | ok, = 878 | same |
| `SOUNDKIT.UI_AUTO_QUEST_COMPLETE` | ok, = 23404 | same |
| `SOUNDKIT.UI_WORLDQUEST_COMPLETE` | ok, = 73277 | same |
