Scriptname IMPScriptMM_WorkobjectCollection extends RefCollectionAlias

Event OnCellDetach(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerOwnership.WorkObjectOnUnload_PUBLIC(akSender)
EndEvent
