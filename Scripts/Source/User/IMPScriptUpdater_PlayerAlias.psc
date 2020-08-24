Scriptname IMPScriptUpdater_PlayerAlias extends ReferenceAlias

;= PROPERTIES =
GlobalVariable property gUpdater auto mandatory
GlobalVariable property gVersion auto mandatory
Message property ModInstalledMESGn auto mandatory


;= SCRIPT ================

Event OnAliasInit()
	RunUpdater()
EndEvent

Event OnPlayerLoadGame()
	RunUpdater()
EndEvent


Function RunUpdater()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	if gUpdater.GetValue() < 1.0
		; nothing to update
	endif 

	if gUpdater.GetValue() < 3.11
		IMP.IMP_AIOInstalled=Game.GetFormFromFile(0x010153A2, "IMP.esp") as GlobalVariable

		IMP.TrashbinMarkerAlias=(IMP as Quest).GetAlias(1) as ReferenceAlias
		IMP.TrashbinMarkerAlias.ForceRefTo(IMP.ProvisionerManager.TrashbinMarkerREF)

		IMP.AssemblyPoint.IMP_BattlePositionWantToUnassignMESGb=Game.GetFormFromFile(0x0102CA51, "IMP.esp") as Message
		IMP.MarkerManagerOwnership.IMP_MarkerManagerOwnership_MarkerListMESGb=Game.GetFormFromFile(0x0100BF91, "IMP.esp") as Message
		IMP.MarkerManagerMenu.IMP_SetSafetyValueMenuEntryNoneMESGb=Game.GetFormFromFile(0x0102E8C0, "IMP.esp") as Message
		IMP.MarkerManagerMenu.IMP_SetSafetyValueMenuEntryMESGb=Game.GetFormFromFile(0x0102E8BF, "IMP.esp") as Message
		IMP.CommandMode.IMP_WorkshopCommandModeNPCRobotOnlyMESGn=Game.GetFormFromFile(0x0102E125, "IMP.esp") as Message

		IMP.IMP_ExcludedNPCS=Game.GetFormFromFile(0x0102D988, "IMP.esp") as Formlist
		IMP.IMP_IncludedNPCS=Game.GetFormFromFile(0x0102D98A, "IMP.esp") as Formlist
		IMP.IMP_PositionersUsedByChildren=Game.GetFormFromFile(0x0102D989, "IMP.esp") as Formlist

		IMP.IMP_IsSandboxRelaxPositionerRobot=Game.GetFormFromFile(0x0102E124, "IMP.esp") as Keyword

		Quest WorkshopManager_CommandMode=Game.GetFormFromFile(0x01000FA0, "IMP.esp") as Quest
		IMP.CommandMode.WorkshopObjectCollection =WorkshopManager_CommandMode.GetAlias(7) as RefCollectionAlias
		IMP.CommandMode.WorkshopObjectBlockedCollection =WorkshopManager_CommandMode.GetAlias(8) as RefCollectionAlias

		IMP.WorkshopRatingScavengeGeneral=Game.GetFormFromFile(0x00086748, "Fallout4.esm") as ActorValue
		IMP.ActorTypeSupermutant=Game.GetFormFromFile(0x0006D7B6, "Fallout4.esm") as Keyword
	endif 

	if gUpdater.GetValue() < 3.12
		IMP.Followers=(Game.GetFormFromFile(0x000289E4, "Fallout4.esm") as Quest) as FollowersScript
	endif

	;---------
		
	if gUpdater.GetValue() < gVersion.GetValue()
		gUpdater.SetValue(gVersion.GetValue())
		ModInstalledMESGn.Show(gUpdater.GetValue())
	endif				
EndFunction