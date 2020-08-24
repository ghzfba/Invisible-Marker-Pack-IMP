Scriptname IMPScriptWM_SettlerCollection extends RefCollectionAlias

Event OnCommandModeGiveCommand(ObjectReference akSender, int aeCommandType, ObjectReference akTarget)
	if akTarget
		IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
		IMP.CommandMode.SettlerCommandModeGiveCommand_PUBLIC(akSender, aeCommandType, akTarget)
	endif
endEvent

;=========

Event OnCommandModeEnter(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerF4SE.SettlerOnCommandModeEnter_PUBLIC(akSender)
	IMP.CommandMode.ChildOnCommandModeEnter_PUBLIC(akSender)
EndEvent

Event OnCommandModeExit(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerF4SE.SettlerOnCommandModeExit_PUBLIC()
	IMP.CommandMode.ChildOnCommandModeExit_PUBLIC(akSender)
EndEvent

;=========

Event OnWorkshopNPCTransfer(ObjectReference akSender, Location akNewWorkshop, Keyword akActionKW)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CommandMode.SettlerOnDeath_PUBLIC(akSender)
EndEvent

Event OnDeath(ObjectReference akSender, Actor akKiller)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CommandMode.SettlerOnDeath_PUBLIC(akSender)
endEvent

Event OnCellDetach(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CommandMode.SettlerOnUnload_PUBLIC(akSender)
EndEvent

