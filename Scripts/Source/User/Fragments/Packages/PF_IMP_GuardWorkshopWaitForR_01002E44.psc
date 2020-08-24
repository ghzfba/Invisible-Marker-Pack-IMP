;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Packages:PF_IMP_GuardWorkshopWaitForR_01002E44 Extends Package Hidden Const

;BEGIN FRAGMENT Fragment_Begin
Function Fragment_Begin(Actor akActor)
;BEGIN CODE
IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
IMP.GuardManager.SetSandboxPackage_PUBLIC(akActor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
