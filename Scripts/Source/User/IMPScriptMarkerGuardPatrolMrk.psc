Scriptname IMPScriptMarkerGuardPatrolMrk extends ObjectReference

ObjectReference IdleMarkerRef
ObjectReference PrevMarkerRef
ObjectReference NextMarkerRef


ObjectReference Function GetIdleMarkerRef()
	return IdleMarkerRef
EndFunction

Function SetIdleMarkerRef(ObjectReference akIdleMarkerRef)
	IdleMarkerRef=akIdleMarkerRef
EndFunction

Function DeleteIdleMarker()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	IdleMarkerRef.SetFactionOwner(IMP.IMP_GuardPatrol_IdlemarkerGuardOwnership)
	IdleMarkerRef.SetLinkedRef(NONE)
	IdleMarkerRef.DisableNoWait()
	IdleMarkerRef.Delete()
	IdleMarkerRef=NONE
EndFunction