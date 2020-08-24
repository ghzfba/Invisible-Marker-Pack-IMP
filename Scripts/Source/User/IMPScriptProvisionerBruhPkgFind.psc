Scriptname IMPScriptProvisionerBruhPkgFind extends Package Const

Event OnStart(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.ProvisionerManager.SetProvisionerbrahminSandboxPackage_PUBLIC(akActor)
EndEvent

Event OnChange(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	if !akActor.GetLinkedRef(IMP.IMP_LinkProvisionerbrahminMarker)
		IMP.ProvisionerManager.UnsetProvisionerbrahminSandboxPackage_PUBLIC(akActor)
	endif
EndEvent

