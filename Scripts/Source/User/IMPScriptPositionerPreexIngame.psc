Scriptname IMPScriptPositionerPreexIngame extends ObjectReference

Float MarkerPosX
Float MarkerPosY
Float MarkerPosZ
Float MarkerAngleZ

Float ResourcePosX
Float ResourcePosY
Float ResourcePosZ
Float ResourceAngleZ

;======

Event OnWorkshopObjectMoved(ObjectReference akReference)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	GetMarkerRef().MoveTo(Self)
	GetMarkerRef().EnableNoWait()
	SaveMarkerPos(GetMarkerRef())
EndEvent

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	GetMarkerRef().DisableNoWait()
EndEvent

;---------

Event ObjectReference.OnWorkshopObjectGrabbed(ObjectReference akSender, ObjectReference akReference)
	DisableNoWait()
EndEvent


Event ObjectReference.OnWorkshopObjectMoved(ObjectReference akSender, ObjectReference akReference)
	if bResourceMoved(akSender)
		SaveResourcePos(akSender)

		Float EndLoopTime=Utility.GetCurrentRealTime()+5
		Bool bEndLoop
		while bMarkerMoved(GetMarkerRef()) == False  &&  bEndLoop == False
			if Utility.GetCurrentRealTime() >= EndLoopTime 
				bEndLoop=True
			endif	
		endwhile
	
		MoveTo(GetMarkerRef())
		EnableNoWait()
		SaveMarkerPos(GetMarkerRef())	
	else
		EnableNoWait()
	endif
EndEvent


;======


Function DeleteMe()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	UnregisterForRemoteEvent(GetResourceRef(), "OnWorkshopObjectGrabbed")
	UnregisterForRemoteEvent(GetResourceRef(), "OnWorkshopObjectMoved")
	UnregisterForRemoteEvent(GetResourceRef(), "OnWorkshopObjectDestroyed")
	
	SetLinkedRef(NONE, IMP.IMP_LinkPositionerPreexResource)
	SetLinkedRef(NONE, IMP.IMP_LinkPositionerPreexMarker)
	SetLinkedRef(NONE, IMP.WorkshopItemKeyword)
	
	IMP.WorkshopMode.RemovePositioner_PUBLIC(Self)
	
	DisableNoWait()
	Delete()
EndFunction


Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	DeleteMe()
EndEvent


Event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akActionRef)
	DeleteMe()
EndEvent


Event OnCellDetach()
	DeleteMe()
EndEvent


;======


ObjectReference Function GetMarkerRef()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	return GetLinkedRef(IMP.IMP_LinkPositionerPreexMarker)
EndFunction


ObjectReference Function GetResourceRef()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	return GetLinkedRef(IMP.IMP_LinkPositionerPreexResource)
EndFunction


;======


Function SetRemoteEventsRef_PUBLIC(ObjectReference akResourceRef)
	RegisterForRemoteEvent(akResourceRef, "OnWorkshopObjectGrabbed")
	RegisterForRemoteEvent(akResourceRef, "OnWorkshopObjectMoved")
	RegisterForRemoteEvent(akResourceRef, "OnWorkshopObjectDestroyed")
EndFunction

;======

Function SaveMarkerPos(ObjectReference akMarkerRef)
	if akMarkerRef
		MarkerPosX=akMarkerRef.GetPositionX()
		MarkerPosY=akMarkerRef.GetPositionX()
		MarkerPosZ=akMarkerRef.GetPositionX()
		MarkerAngleZ=akMarkerRef.GetAngleZ()
	endif
EndFunction

Function SaveMarkerPos_PUBLIC(ObjectReference akMarkerRef)
	SaveMarkerPos(akMarkerRef)
EndFunction

Bool Function bMarkerMoved(ObjectReference akMarkerRef)
	if akMarkerRef
		if MarkerPosX!=akMarkerRef.GetPositionX()
			return True
		endif
		if MarkerPosY!=akMarkerRef.GetPositionX()
			return True
		endif
		if MarkerPosZ!=akMarkerRef.GetPositionX()
			return True
		endif
		if MarkerAngleZ!=akMarkerRef.GetAngleZ()
			return True
		endif
	endif
EndFunction

;======

Function SaveResourcePos(ObjectReference akResourceRef)
	if akResourceRef
		ResourcePosX=akResourceRef.GetPositionX()
		ResourcePosY=akResourceRef.GetPositionX()
		ResourcePosZ=akResourceRef.GetPositionX()
		ResourceAngleZ=akResourceRef.GetAngleZ()
	endif
EndFunction

Function SaveResourcePos_PUBLIC(ObjectReference akResourceRef)
	SaveResourcePos(akResourceRef)
EndFunction

Bool Function bResourceMoved(ObjectReference akResourceRef)
	if akResourceRef
		if ResourcePosX!=akResourceRef.GetPositionX()
			return True
		endif
		if ResourcePosY!=akResourceRef.GetPositionX()
			return True
		endif
		if ResourcePosZ!=akResourceRef.GetPositionX()
			return True
		endif
		if ResourceAngleZ!=akResourceRef.GetAngleZ()
			return True
		endif
	endif
EndFunction

