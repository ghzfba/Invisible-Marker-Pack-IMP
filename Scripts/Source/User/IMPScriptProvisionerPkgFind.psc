Scriptname IMPScriptProvisionerPkgFind extends Package Const

Event OnStart(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.ProvisionerManager.SetProvisionerSandboxPackage_PUBLIC(akActor)
EndEvent

Event OnChange(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	if !akActor.GetLinkedRef(IMP.IMP_LinkProvisionerMarker)
		IMP.ProvisionerManager.UnsetProvisionerSandboxPackage_PUBLIC(akActor)
	endif
EndEvent
