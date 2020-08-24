;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Packages:PF_IMP_WorkshopJobAssigning__01003DC8 Extends Package Hidden Const

;BEGIN FRAGMENT Fragment_End
Function Fragment_End(Actor akActor)
;BEGIN CODE
IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
IMP.JobAssigning.UnsetLinkedSettlerWorkmarker_PUBLIC(akActor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
