Scriptname IMPScriptPositionerGuardPatrolMrk extends ObjectReference

IMPScriptMain IMP

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Event OnLoad()
	IMP.GuardPatrol.GuardPatrolMarkerOnLoad_PUBLIC(Self)
EndEvent

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	IMP.GuardPatrol.GuardPatrolMarkerOnPlaced_PUBLIC(Self)
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMP.GuardPatrol.GuardPatrolMarkerOnMoved_PUBLIC(Self)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMP.GuardPatrol.GuardPatrolMarkerOnDestroyed_PUBLIC(Self)
EndEvent