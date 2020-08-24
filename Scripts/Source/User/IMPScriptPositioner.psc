Scriptname IMPScriptPositioner extends ObjectReference

IMPScriptMain IMP
ObjectReference MarkerRef

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	;*** add positioner to collections ***
	IMP.WorkshopMode.AddPositioner_PUBLIC(Self)
	IMP.CommandMode.IsObjectUsableByChildren_PUBLIC(Self)
	
	;*** create marker ***
	Int IndexList=IMP.IMP_PositionerList.Find(GetBaseObject())
	MarkerRef=PlaceAtMe(IMP.IMP_MarkerList.GetAt(IndexList) as Form, abDeleteWhenAble=False)
	
	;*** set marker ***
	(MarkerRef as IMPScriptMarker).SetPositionerRef(Self)	

	;*** link marker to workshop ***
	WorkshopScript WorkshopRef=akReference as WorkshopScript
	IMP.WorkshopParent.BuildObjectPUBLIC(MarkerRef, WorkshopRef)
	MarkerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)

	;*** create props ***
	((MarkerRef as ObjectReference) as IMPScriptMarkerProps).CreateProps()

	;*** create radius ***
	((Self as ObjectReference) as IMPScriptPositionerRadius).CreateRadiusPositioner(akWorkshopRef=WorkshopRef, abIsCreatedByPositioner=True)
EndEvent

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
EndEvent
	
Event OnWorkshopObjectMoved(ObjectReference akReference)
	MarkerRef.MoveTo(Self)
	((MarkerRef as ObjectReference) as IMPScriptMarkerProps).MoveProps(Self)
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	SetActorRefOwner(NONE)

	IMP.WorkshopMode.RemovePositioner_PUBLIC(Self)
	IMP.CommandMode.WorkshopObjectOnUnload_PUBLIC(Self)
	IMP.CreatureManager.WorkshopObjectOnUnload_PUBLIC(Self)
	IMP.MarkerManagerOwnership.WorkObjectOnUnload_PUBLIC(Self)
	
	(MarkerRef as IMPScriptMarker).DeleteMarker()
	MarkerRef=NONE
EndEvent

;======

ObjectReference Function GetMarkerRef()
	return MarkerRef
EndFunction

Function SetMarkerRef(ObjectReference akMarkerRef)
	if akMarkerRef
		MarkerRef=akMarkerRef
	endif
EndFunction

;======

Function DeletePositioner()
	SetLinkedRef(NONE, IMP.WorkshopItemKeyword)
	SetActorRefOwner(NONE)

	IMP.WorkshopMode.RemovePositioner_PUBLIC(Self)
	IMP.CommandMode.WorkshopObjectOnUnload_PUBLIC(Self)
	IMP.CreatureManager.WorkshopObjectOnUnload_PUBLIC(Self)
	IMP.MarkerManagerOwnership.WorkObjectOnUnload_PUBLIC(Self)

	MarkerRef=NONE

	DisableNoWait()
	Delete()
EndFunction

Event OnCellDetach()
	if MarkerRef == NONE
		DeletePositioner()
	endif
EndEvent