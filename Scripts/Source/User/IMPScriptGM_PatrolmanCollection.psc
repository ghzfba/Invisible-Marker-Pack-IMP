Scriptname IMPScriptGM_PatrolmanCollection extends RefCollectionAlias

Event OnCommandModeEnter(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardPatrol.GuardOnCommandModeEnter_PUBLIC(akSender)
endEvent

Event OnCommandModeExit(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardPatrol.GuardOnCommandModeExit_PUBLIC(akSender)
endEvent

Event OnDeath(ObjectReference akSender, Actor akKiller)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardPatrol.UnsetPatrolGuard_PUBLIC(akSender)
endEvent

Event OnWorkshopNPCTransfer(ObjectReference akSender, Location akNewWorkshop, Keyword akActionKW)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardPatrol.UnsetPatrolGuard_PUBLIC(akSender)
endEvent