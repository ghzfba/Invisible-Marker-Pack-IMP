;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Packages:PF_IMP_AssemblyPointSandboxA_01003D9F Extends Package Hidden Const

;BEGIN FRAGMENT Fragment_End
Function Fragment_End(Actor akActor)
;BEGIN CODE
IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
IMP.AssemblyPoint.EndFleePackage_PUBLIC(akActor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
