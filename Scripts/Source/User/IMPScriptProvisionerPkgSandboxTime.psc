Scriptname IMPScriptProvisionerPkgSandboxTime  extends Package Const

Event OnEnd(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.ProvisionerManager.SetSandboxDuration_PUBLIC(akActor)
EndEvent

