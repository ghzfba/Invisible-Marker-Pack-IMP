Scriptname IMPScriptPositionerGuardRelax extends ObjectReference Const

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.GuardRelaxMarkerOnPlaced_PUBLIC(akReference)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IMP.GuardManager.GuardRelaxMarkerOnDestroyed_PUBLIC(akActionRef)
EndEvent