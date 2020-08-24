Scriptname IMPScriptGuardRelaxPkgFind extends Package

Event OnStart(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.SetSandboxPackage_PUBLIC(akActor)
EndEvent


