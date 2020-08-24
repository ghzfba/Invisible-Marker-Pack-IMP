Scriptname IMPScriptPM_BrahminCollection extends RefCollectionAlias

Event OnCommandModeGiveCommand(ObjectReference akSender, int aeCommandType, ObjectReference akTarget)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CommandMode.SettlerCommandModeGiveCommand_PUBLIC(akSender, aeCommandType, akTarget)
endEvent