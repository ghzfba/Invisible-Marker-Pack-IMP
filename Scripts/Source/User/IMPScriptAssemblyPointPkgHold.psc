Scriptname IMPScriptAssemblyPointPkgHold extends Package Const

Event OnChange(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.AssemblyPoint.UnsetAllPackagesAssemblyPoint_PUBLIC(akActor)
EndEvent