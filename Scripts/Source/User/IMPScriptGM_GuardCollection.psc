Scriptname IMPScriptGM_GuardCollection extends RefCollectionAlias

Event OnCellDetach(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.GuardOnUnload_PUBLIC(akSender)
EndEvent


;= POWER ARMOR MANAGEMENT ==============

Event OnSit(ObjectReference akSender, ObjectReference akFurniture)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.GuardOnSit_PUBLIC(akSender, akFurniture)
EndEvent

Event OnGetUp(ObjectReference akSender, ObjectReference akFurniture)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.GuardOnGetUp_PUBLIC(akSender, akFurniture)
EndEvent