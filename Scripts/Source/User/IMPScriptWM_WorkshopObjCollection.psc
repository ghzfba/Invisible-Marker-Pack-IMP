Scriptname IMPScriptWM_WorkshopObjCollection extends RefCollectionAlias

Event OnCellDetach(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CommandMode.WorkshopObjectOnUnload_PUBLIC(akSender)
EndEvent