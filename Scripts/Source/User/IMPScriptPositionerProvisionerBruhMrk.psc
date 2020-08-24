Scriptname IMPScriptPositionerProvisionerBruhMrk extends ObjectReference

IMPScriptMain IMP

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMP.ProvisionerManager.ProvisionerbrahminMarkerOnPlaced_PUBLIC(Self, akReference)
EndEvent
	
Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMP.ProvisionerManager.ProvisionerbrahminMarkerOnMoved_PUBLIC()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMP.ProvisionerManager.ProvisionerbrahminMarkerOnDestroyed_PUBLIC(Self)
EndEvent