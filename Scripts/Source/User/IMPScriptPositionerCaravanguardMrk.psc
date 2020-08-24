Scriptname IMPScriptPositionerCaravanguardMrk extends ObjectReference

IMPScriptMain IMP

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMP.CaravanManager.CaravanguardMarkerOnPlaced_PUBLIC(Self, akReference)
EndEvent
	
Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMP.CaravanManager.CaravanguardMarkerOnMoved_PUBLIC()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMP.CaravanManager.CaravanguardMarkerOnDestroyed_PUBLIC(Self)
EndEvent