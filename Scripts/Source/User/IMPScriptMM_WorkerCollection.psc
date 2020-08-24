Scriptname IMPScriptMM_WorkerCollection extends RefCollectionAlias

Event OnCellDetach(ObjectReference akSender)
	if akSender
		IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
		IMP.MarkerManagerOwnership.WorkerOnUnload_PUBLIC(akSender)
	endif
EndEvent

Event OnWorkshopNPCTransfer(ObjectReference akSender, Location akNewWorkshop, Keyword akActionKW)
	if akSender
		IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
		IMP.MarkerManagerOwnership.WorkerOnWorkshopNPCTransfer_PUBLIC(akSender)
	endif
EndEvent

Event OnDeath(ObjectReference akSender, Actor akKiller)
	if akSender
		IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
		IMP.MarkerManagerOwnership.WorkerOnDeath_PUBLIC(akSender)
	endif
EndEvent
