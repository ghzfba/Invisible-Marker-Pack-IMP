Scriptname IMPScriptRS_WorkshopCollection extends RefCollectionAlias

Event OnLoad(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CreatureManager.WorkshopOnLoad_PUBLIC(akSender)
EndEvent


Event OnWorkshopMode(ObjectReference akSender, bool aStart)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	if aStart
		IMP.CreatureManager.RegisterForWorkshopMode_PUBLIC(akSender)
	else
		IMP.CreatureManager.UnregisterForWorkshopMode_PUBLIC()
	endif
EndEvent