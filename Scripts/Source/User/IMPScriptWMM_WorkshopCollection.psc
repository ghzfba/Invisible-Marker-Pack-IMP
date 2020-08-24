Scriptname IMPScriptWMM_WorkshopCollection extends RefCollectionAlias

IMPScriptMain IMP

Event OnAliasInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

Event OnLoad(ObjectReference akSender)
	IMP.WorkshopMode.WorkshopOnLoad_PUBLIC()
EndEvent

Event OnWorkshopMode(ObjectReference akSender, bool aStart)
	if aStart
		IMP.CommandMode.RegisterForWorkshopMode_PUBLIC(akSender)
		IMP.WorkshopMode.WorkshopOnWorkshopModeTrue_PUBLIC()
		IMP.MarkerManagerF4SE.RegisterWorkshopF4SE_PUBLIC(akSender)
	else
		IMP.Pin.Pin_StartResetTimer_PUBLIC()
		IMP.CommandMode.UnregisterForWorkshopMode_PUBLIC()
		IMP.WorkshopMode.WorkshopOnWorkshopModeFalse_PUBLIC()
		IMP.MarkerManagerF4SE.UnregisterWorkshopF4SE_PUBLIC()
	endif
EndEvent