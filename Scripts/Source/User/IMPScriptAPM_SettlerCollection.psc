Scriptname IMPScriptAPM_SettlerCollection extends RefCollectionAlias

Event OnCombatStateChanged(ObjectReference akSender, Actor akTarget, int aeCombatState)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.AssemblyPoint.SettlerOnCombatStateChanged_PUBLIC(akSender, aeCombatState)
EndEvent

Event OnCellDetach(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.AssemblyPoint.SettlerOnUnload_PUBLIC(akSender)
EndEvent

Event OnWorkshopNPCTransfer(ObjectReference akSender, Location akNewWorkshop, Keyword akActionKW)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.AssemblyPoint.SettlerOnWorkshopNPCTransfer_PUBLIC(akSender)
EndEvent

Event OnDeath(ObjectReference akSender, Actor akKiller)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.AssemblyPoint.SettlerOnDeath_PUBLIC(akSender)
EndEvent