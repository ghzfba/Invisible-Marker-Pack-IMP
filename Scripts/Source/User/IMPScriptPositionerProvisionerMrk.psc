Scriptname IMPScriptPositionerProvisionerMrk extends ObjectReference

IMPScriptMain IMP

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMP.ProvisionerManager.ProvisionerMarkerOnPlaced_PUBLIC(Self, akReference)
EndEvent
	
Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMP.ProvisionerManager.ProvisionerMarkerOnMoved_PUBLIC()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMP.ProvisionerManager.ProvisionerMarkerOnDestroyed_PUBLIC(Self)
EndEvent
