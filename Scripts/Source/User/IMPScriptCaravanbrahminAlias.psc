Scriptname IMPScriptCaravanbrahminAlias extends ReferenceAlias

Event OnLoad()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CaravanManager.CaravanbrahminAliasOnLoad(GetReference())
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CaravanManager.CaravanbrahminAliasOnLoad(GetReference())
EndEvent

;---------

Event OnCommandModeGiveCommand(int aeCommandType, ObjectReference akTarget)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CommandMode.SettlerCommandModeGiveCommand_PUBLIC(GetReference(), aeCommandType, akTarget)
endEvent

Event OnCommandModeEnter()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerF4SE.SettlerOnCommandModeEnter_PUBLIC(GetReference())
EndEvent

Event OnCommandModeExit()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.MarkerManagerF4SE.SettlerOnCommandModeExit_PUBLIC()
EndEvent

;---------

Event OnCellDetach()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CaravanManager.CaravanbrahminAliasOnUnload(GetReference())
EndEvent