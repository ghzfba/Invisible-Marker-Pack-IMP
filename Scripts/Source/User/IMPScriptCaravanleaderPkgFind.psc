Scriptname IMPScriptCaravanleaderPkgFind extends Package Const

Event OnStart(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CaravanManager.SetCaravanleaderSandboxPackage_PUBLIC(akActor)
EndEvent

Event OnChange(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	if !akActor.GetLinkedRef(IMP.IMP_LinkCaravanleaderMarker)
		IMP.CaravanManager.UnsetCaravanleaderSandboxPackage_PUBLIC(akActor)
	endif
EndEvent
