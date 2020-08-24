Scriptname IMPScriptCaravanBrahminPkgFind extends Package Const

Event OnStart(Actor akActor)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.CaravanManager.SetCaravanbrahminSandboxPackage_PUBLIC(akActor)
EndEvent