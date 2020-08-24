Scriptname IMPScriptRS_SandboxingCreatureColl extends RefCollectionAlias

Event OnCommandModeGiveCommand(ObjectReference akSender, int aeCommandType, ObjectReference akTarget)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CreatureManager.CreatureCommandModeGiveCommand_PUBLIC(akSender, akTarget)
endEvent

Event OnCommandModeEnter(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CreatureManager.CreatureOnCommandModeEnter_PUBLIC()
	IMP.MarkerManagerF4SE.SettlerOnCommandModeEnter_PUBLIC(akSender)
EndEvent

Event OnCommandModeExit(ObjectReference akSender)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CreatureManager.CreatureOnCommandModeExit_PUBLIC()
	IMP.MarkerManagerF4SE.SettlerOnCommandModeExit_PUBLIC()
EndEvent