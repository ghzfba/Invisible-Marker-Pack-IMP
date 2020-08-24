;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_IMPScript_TerminalFilters2 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
IMP.IMP_PreexMarkerManager_PlacedByEditor.Start()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
