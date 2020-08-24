Scriptname IMPScriptPositionerCaravanbrahminMrk extends ObjectReference

IMPScriptMain IMP

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMP.CaravanManager.CaravanbrahminMarkerOnPlaced_PUBLIC(Self, akReference)
EndEvent
	
Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMP.CaravanManager.CaravanbrahminMarkerOnMoved_PUBLIC()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMP.CaravanManager.CaravanbrahminMarkerOnDestroyed_PUBLIC(Self)
EndEvent