Scriptname IMPScriptCaravanBrahminPkgSandbox extends Package Const

Event OnChange(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CaravanManager.UnsetCaravanbrahminSandboxPackage_PUBLIC(akActor)
EndEvent