Scriptname IMPScriptPM_ProvisionerCollection extends RefCollectionAlias

Event OnLoad(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.ProvisionerManager.ProvisionerOnLoad_PUBLIC(akSender)
EndEvent

Event OnUnload(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.ProvisionerManager.ProvisionerOnUnload_PUBLIC(akSender)
EndEvent

;=========

Event OnCommandModeGiveCommand(ObjectReference akSender, int aeCommandType, ObjectReference akTarget)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CommandMode.SettlerCommandModeGiveCommand_PUBLIC(akSender, aeCommandType, akTarget)
endEvent

Event OnCommandModeEnter(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerF4SE.SettlerOnCommandModeEnter_PUBLIC(akSender)
EndEvent

Event OnCommandModeExit(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerF4SE.SettlerOnCommandModeExit_PUBLIC()
EndEvent