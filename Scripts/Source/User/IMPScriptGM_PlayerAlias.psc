Scriptname IMPScriptGM_PlayerAlias extends ReferenceAlias

Event OnSit(ObjectReference akFurniture)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.PlayerOnSit_PUBLIC(akFurniture)
endEvent