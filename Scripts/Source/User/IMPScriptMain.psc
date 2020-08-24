Scriptname IMPScriptMain extends Quest Conditional

;= Added in IMP v.3.11 ===
Formlist property IMP_ExcludedNPCS auto
Formlist property IMP_IncludedNPCS auto
Formlist property IMP_PositionersUsedByChildren auto
GlobalVariable property IMP_AIOInstalled auto
ActorValue property WorkshopRatingScavengeGeneral auto
Keyword property ActorTypeSupermutant auto
Keyword property IMP_IsSandboxRelaxPositionerRobot auto
ReferenceAlias property TrashbinMarkerAlias auto

;= Added in IMP v.3.11 ===
Followersscript property Followers auto

;=========================

MiscObject property IMP_Qube auto const mandatory
GlobalVariable property IMP_MarkerSearchMaxRadius auto const mandatory
IMPScriptSettings property Settings auto const mandatory
IMPScriptMarkerManagerPin property Pin auto const mandatory
GlobalVariable property IMP_ModVersion auto const mandatory
GlobalVariable property IMP_ModUpdate auto const mandatory
GlobalVariable property IMP_KeyScanCodeF4SE auto const mandatory
GlobalVariable property IMP_ChemMenu_ShowHolotapeRecipe auto const mandatory
GlobalVariable property IMP_ChemMenu_ShowQubeRecipe auto const mandatory
Keyword property IMP_IsRefPinned auto const mandatory
Keyword property IMP_IsSettler auto const mandatory

Group WorkshopModeManager
IMPScriptWorkshopModeManager property WorkshopMode auto const mandatory
GlobalVariable property IMP_IsInWorkshopMode auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowBehaviourPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowCreaturePositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowFXPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowGuardPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowMiscPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowPreexPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowRelaxationPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowVendorPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowWorkPositioner auto const mandatory
GlobalVariable property IMP_PositionerFilter_ShowRadius auto const mandatory
EndGroup

Group MarkerPlacingProperties
IMPScriptWorkshopJobAssigning property JobAssigning auto const mandatory
IMPScriptWorkshopCommandMode property CommandMode auto const mandatory
Formlist property IMP_MarkerList auto const mandatory
Formlist property IMP_PositionerList auto const mandatory
Formlist property IMP_SafetyObjectExclusions auto const mandatory
Keyword property IMP_IsSandboxWorkMarker auto const mandatory
Keyword property IMP_IsSandboxRelaxMarker auto const mandatory
Keyword property IMP_IsWorkPositioner auto const mandatory
Keyword property IMP_IsSandboxWorkPositioner auto const mandatory
Keyword property IMP_IsSandboxRelaxPositioner auto const mandatory
Keyword property IMP_IsBehaviourPositioner auto const mandatory
Keyword property IMP_IsMiscPositioner auto const mandatory
Keyword property IMP_IsGuardPositioner auto const mandatory
Keyword property IMP_IsVendorPositioner auto const mandatory
Keyword property IMP_IsCreaturePositioner auto const mandatory
Keyword property IMP_IsCreatureMarker auto const mandatory
Keyword property IMP_IsFXPositioner auto const mandatory
Keyword property IMP_IsPreexPositioner auto const mandatory
Keyword property IMP_IsRadiusPositioner auto const mandatory
Keyword property IMP_IsWorkshopGuardPositioner auto const mandatory
Keyword property IMP_IsSandboxMerchantPositioner auto const mandatory
Keyword property IMP_IsSandboxMerchantMarker auto const mandatory
EndGroup

Group MarkerManager
IMPScriptMarkerManagerMenu property MarkerManagerMenu auto const mandatory
IMPScriptMarkerManagerOwnership property MarkerManagerOwnership auto const mandatory
IMPScriptMarkerManagerMenuF4SE property MarkerManagerF4SE auto const mandatory
ActorValue property IMP_BonusItemID auto const mandatory
Formlist property IMP_BonusItemList auto const mandatory
Formlist property IMP_BonusItemNameList auto const mandatory
Spell property IMP_ReduceActionPointsSpellSmall auto const mandatory
Spell property IMP_ReduceActionPointsSpellMedium auto const mandatory
Spell property IMP_ReduceActionPointsSpellLarge auto const mandatory
Keyword property IMP_LinkWorkshopobjectOwner auto const mandatory
GlobalVariable property IMP_BonusItemChance auto const mandatory
GlobalVariable property IMP_SetSafetyValueWorkshopObjects auto const mandatory
GlobalVariable property IMP_MarkerManagerMenu_ShowNotification auto const mandatory
GlobalVariable property IMP_MarkerManagerMenu_ShowAllOpenInventoryButtons auto const mandatory
EndGroup

Group PreexistentMarkerManager
IMPScriptPreexMarkerManagerINGAME property PreexMarkerIngame auto const mandatory
IMPScriptPreexMarkerManagerEDITOR property PreexMarkerEditor auto const mandatory
Formlist property IMP_PreexMarkerFurnitureList auto const mandatory
Formlist property IMP_PreexPositionerFurnitureList auto const mandatory
Faction property IMP_PreexMarkerEditor_FakeFactionOwner auto const mandatory
Static property IMP_SearchMarker auto const mandatory
Keyword property IMP_LinkPositionerPreexMarker auto const mandatory
Keyword property IMP_LinkPositionerPreexResource auto const mandatory
Keyword property IMP_LinkPreexWorkshop auto const mandatory
Keyword property IMP_IsPreexMarkerEditorReplacer auto const mandatory
Quest property IMP_PreexMarkerManager_PlacedByEditor auto const mandatory
EndGroup

Group GuardManager
IMPScriptGuardManager property GuardManager auto const mandatory
IMPScriptGuardManagerPatrol property GuardPatrol auto const mandatory
IMPScriptGuardManagerScout property GuardScout auto const mandatory
Activator property IMP_Marker_Guard_RelaxMarker auto const mandatory
Activator property IMP_Controller_GuardPatrol auto const mandatory
Activator property IMP_Controller_GuardScoutFollower auto const mandatory
Activator property IMP_Controller_GuardPatrolFollower auto const mandatory
Activator property IMP_Controller_GuardPatrolFollowerCreature auto const mandatory
Activator property IMP_Controller_GuardScoutFollowerCreature auto const mandatory
ActorValue property IMP_GuardShiftTimeStarting auto const mandatory
ActorValue property IMP_GuardShiftTimeEnd auto const mandatory
ActorValue property IMP_GuardShiftTimeMode auto const mandatory
ActorValue property IMP_GuardShiftTypeID auto const mandatory
ActorValue property IMP_GuardShiftRandom auto const mandatory
ActorValue property IMP_WorkshopGuardRelaxCount auto const mandatory
ActorValue property IMP_GuardPatrol_MarkerCount auto const mandatory
ActorValue property IMP_GuardPatrolTypeCircuit auto const mandatory
ActorValue property IMP_GuardPatrolTypeStopAtMarker auto const mandatory
ActorValue property IMP_GuardPatrolDontDeletePatrolRoute auto const mandatory
ActorValue property IMP_GuardPatrolWait auto const mandatory
ActorValue property IMP_GuardScoutRadiusID auto const mandatory
ActorValue property IMP_GuardScoutTaskStart auto const mandatory
ActorValue property IMP_GuardScoutTaskEnd auto const mandatory
ActorValue property IMP_GuardCreatureFollowerStartingSafetyValue auto const mandatory
Keyword property IMP_LinkGuardMarker auto const mandatory
Keyword property IMP_LinkGuardMarkerForced auto const mandatory
Keyword property IMP_LinkGuardPowerarmorMrk auto const mandatory
Keyword property IMP_LinkGuardPowerarmor auto const mandatory
Keyword property IMP_LinkGuardPatrolController auto const mandatory
Keyword property IMP_IsGuard auto const mandatory
Keyword property IMP_IsGuardRelaxPositioner auto const mandatory
Keyword property IMP_IsGuardPatrolPositioner auto const mandatory
Keyword property IMP_IsGuardPatrolController auto const mandatory
Keyword property IMP_IsGuardScoutPositioner auto const mandatory
Keyword property IMP_IsGuardScoutController auto const mandatory
keyword property IMP_IsPowerarmorPositioner auto const mandatory
Keyword property IMP_LinkGuardPatrolidlemarker auto const mandatory
Keyword property IMP_LinkScoutMarker auto const mandatory
Keyword property IMP_LinkGuardFollowerLeaderPatrol auto const mandatory
Keyword property IMP_LinkGuardFollowerLeaderScout auto const mandatory
Keyword property IMP_LinkGuardFollowerMarkerPatrol auto const mandatory
Keyword property IMP_LinkGuardFollowerMarkerScout auto const mandatory
Formlist property IMP_GuardShiftTypeList auto const mandatory
IdleMarker property IMP_PatrolIdleMarker auto const mandatory
Faction property IMP_GuardPatrol_IdlemarkerGuardOwnership auto const mandatory
EndGroup

Group AssemblyPointManager
IMPScriptAssemblyPointManager property AssemblyPoint auto const mandatory
Activator property IMP_Marker_AssemblyPoint auto const mandatory
ActorValue property IMP_WorkshopSafehouseCount auto const mandatory
ActorValue property IMP_AssemblyPointReached auto const mandatory
Keyword property IMP_LinkSettlerAssemblypointMarkerForced auto const mandatory
Keyword property IMP_LinkSettlerAssemblypointMarker auto const mandatory
Keyword property IMP_IsAssemblyPointPositioner auto const mandatory
Keyword property IMP_IsAssemblyPointMarker auto const mandatory
Keyword property IMP_IsBattlePositionPositioner auto const mandatory
Keyword property IMP_IsBattlePositionMarker auto const mandatory
Keyword property IMP_IsReservistMarker auto const mandatory
Keyword property IMP_IsReservist auto const mandatory
EndGroup

Group CaravanManager
IMPScriptCaravanManager property CaravanManager auto const mandatory
Keyword property IMP_LinkCaravanbrahminMarker auto const mandatory
Keyword property IMP_LinkCaravanguardMarker auto const mandatory
Keyword property IMP_LinkCaravanleaderMarker auto const mandatory
Keyword property IMP_IsCaravanBrahmin auto const mandatory
Keyword property IMP_IsCaravanGuard auto const mandatory
Keyword property IMP_IsCaravanLeader auto const mandatory
Keyword property IMP_IsCaravanBrahminPositioner auto const mandatory
Keyword property IMP_IsCaravanGuardPositioner auto const mandatory
Keyword property IMP_IsCaravanLeaderPositioner auto const mandatory
Activator property IMP_Marker_CaravanbrahminMarker auto const mandatory
Activator property IMP_Marker_CaravanguardMarker auto const mandatory
Activator property IMP_Marker_CaravanleaderMarker auto const mandatory
ActorValue property IMP_CaravanPackageStage auto const mandatory
EndGroup

Group ProvisionerManager
IMPScriptProvisionerManager property ProvisionerManager auto const mandatory
Keyword property IMP_LinkProvisionerMarker auto const mandatory
Keyword property IMP_LinkProvisionerbrahminMarker auto const mandatory
Keyword property IMP_IsProvisioner auto const mandatory
Keyword property IMP_IsProvisionerBrahmin auto const mandatory
Keyword property IMP_IsProvisionerPositioner auto const mandatory
Keyword property IMP_IsProvisionerBrahminPositioner auto const mandatory
Keyword property IMP_LinkProvisionermarkerWorkshop auto const mandatory
Activator property IMP_Marker_ProvisionerMarker auto const mandatory
Activator property IMP_Marker_ProvisionerBrahminMarker auto const mandatory
ActorValue property IMP_ProvisionerPackageStage auto const mandatory
ActorValue property IMP_ProvisionerPackageEndDate auto const mandatory
ActorValue property IMP_ProvisionerPackageStartDate auto const mandatory
ActorValue property IMP_ProvisionerMarkerSandboxDuration auto const mandatory
ActorValue property IMP_ProvisionerBrahminPackageStage auto const mandatory
GlobalVariable property IMP_ProvisionerSandboxDurationDefault auto const mandatory
GlobalVariable property IMP_ProvisionerStartNewSandboxPkgTimer auto const mandatory
EndGroup

Group RestrictedSandboxing
IMPScriptRestrictedSandbox property RestrictedSandbox auto const mandatory
IMPScriptRestrictedSandboxCreatures property CreatureManager auto const mandatory
Keyword property IMP_LinkSettlerRestrictedsandboxmarker auto const mandatory
Keyword property IMP_IsRestrictedSandboxPositioner auto const mandatory
Keyword property IMP_IsRestrictedSandboxCreaturePositioner auto const mandatory
Keyword property IMP_IsWorkshopCreature auto const mandatory
ActorValue property IMP_SandboxerRadius auto const mandatory
ActorValue property IMP_HasCreatureCommandKeyword auto const mandatory
EndGroup

Group FXS
ActorValue property IMP_MarkerPropsTimerStart auto const mandatory
ActorValue property IMP_MarkerPropsTimerEnd auto const mandatory
EndGroup

Group VanillaProperties
WorkshopParentScript property WorkshopParent auto const mandatory
Keyword property WorkshopItemKeyword auto const mandatory
Keyword property WorkshopWorkObject auto const mandatory
Keyword property WorkshopGuardObject auto const mandatory
Keyword property LocTypeWorkshop auto const mandatory
Keyword property WorkshopLinkCenter auto const mandatory
Keyword property WorkshopLinkCaravanStart auto const mandatory
Keyword property WorkshopLinkCaravanEnd auto const mandatory
Keyword property WorkshopLinkFollow auto const mandatory
Keyword property ActorTypeNPC auto const mandatory
Keyword property ActorTypeRobot auto const mandatory
Keyword property ActorTypeCreature auto const mandatory
Keyword property ActorTypeTurret auto const mandatory
Keyword property WorkshopAllowCommand auto const mandatory
Keyword property FurnitureTypePowerArmor auto const mandatory
ActorValue property Food auto const mandatory
ActorValue property Safety auto const mandatory
ActorValue property Aggression auto const mandatory
ActorValue property Confidence auto const mandatory
ActorValue property WorkshopRatingPopulation auto const mandatory
ActorValue property WorkshopResourceObject auto const mandatory
Soundcategory property AudioCategorySFX auto const mandatory
Soundcategory property AudioCategoryFSTplayer auto const mandatory
Soundcategory property AudioCategoryRadio auto const mandatory
Soundcategory property AudioCategoryVOCGeneral auto const mandatory
GlobalVariable property GameHour auto const mandatory
GlobalVariable property GameDaysPassed auto const mandatory
Faction property WorkshopVendorFactionBar auto const mandatory
Faction property WorkshopCaravanFaction auto const mandatory
Faction property MinutemenFaction auto const mandatory
Faction property CaravanVendorCarlaFaction auto const mandatory
Faction property CaravanVendorCricketFaction auto const mandatory
Faction property CaravanVendorDocWeathersFaction auto const mandatory
Faction property CaravanVendorLucasFaction auto const mandatory
Faction property CaravanFaction auto const mandatory
Faction property WorkshopNoPackages auto const mandatory
Faction property HasBeenCompanionFaction auto const mandatory
Location property BunkerHillLocation auto const mandatory
Furniture property WorkshopGuardMarker auto const mandatory
EndGroup


Event OnQuestInit()
	Game.GetPlayer().AddItem(IMP_Qube, 100)
;	Game.GetPlayer().AddItem(IMP_SettingHolotape00)
EndEvent