Scriptname IMPScriptMarker extends ObjectReference

Keyword property LinkOwnerMarker auto const

IMPScriptMain IMP
ObjectReference PositionerRef
Bool bHasBeenInitialized
Bool bIsPreexMarkerEditorReplacer
Int RadiusSizeValue;= used to save radius size by positioners

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Event OnLoad()
	if bIsPreexMarkerEditorReplacer
		if IMP.IMP_PreexMarkerManager_PlacedByEditor.IsRunning() == False
			bHasBeenInitialized=False
			DeleteMarker()
			Return
		endif
	endif

	if bHasBeenInitialized
		;*** create positioner ***
		Int IndexList=IMP.IMP_MarkerList.Find(GetBaseObject())
		PositionerRef=PlaceAtMe(IMP.IMP_PositionerList.GetAt(IndexList) as Form, abInitiallyDisabled=!(IMP.IMP_IsInWorkshopMode.GetValue()) as Bool)
		PositionerRef.SetLinkedRef(GetLinkedRef(IMP.WorkshopItemKeyword), IMP.WorkshopItemKeyword)
		IMP.WorkshopMode.AddPositioner_PUBLIC(PositionerRef)

		;*** set marker ***
		(PositionerRef as IMPScriptPositioner).SetMarkerRef(Self)

		;*** update positioner data ***
		UpdateInternalData()


		;*** create radius positioner (if exists) ***
		(PositionerRef as IMPScriptPositionerRadius).CreateRadiusPositioner(akWorkshopRef=GetLinkedRef(IMP.WorkshopItemKeyword), abIsCreatedByPositioner=False, aiSize=RadiusSizeValue)


		;*** create props (if exist) ***
		((Self as ObjectReference) as IMPScriptMarkerProps).CreateProps()


		;*** create link with owner (optional) ***
		GetActorRefOwner().SetLinkedRef(Self, LinkOwnerMarker)
	endif
EndEvent

;---------

Event OnCellDetach()
	;*** delete link with owner ***
	GetActorRefOwner().SetLinkedRef(NONE, LinkOwnerMarker)

	((Self as ObjectReference) as IMPScriptMarkerProps).DeleteProps()

	(PositionerRef as IMPScriptPositioner).DeletePositioner() 
	PositionerRef=NONE

	if ((Self as ObjectReference) as IMPScriptMarkerPreexMarkerEditor)
		((Self as ObjectReference) as IMPScriptMarkerPreexMarkerEditor).HandleUnload()
	else
		bHasBeenInitialized=True
	endif
EndEvent

;=========

Objectreference Function GetPositionerRef()
	return PositionerRef
EndFunction

Function SetPositionerRef(ObjectReference akPositionerRef)
	PositionerRef=akPositionerRef
EndFunction

;=========

Function SetPreexMarkerEditorReplacer(Bool abFlag)
	bIsPreexMarkerEditorReplacer=abFlag
EndFunction

;=========

Function UpdateInternalData()
	if PositionerRef.HasKeyword(IMP.WorkshopWorkObject)
		PositionerRef.SetActorRefOwner(GetActorRefOwner())
	endif
EndFunction

;=========

Function DeleteMarker()
	;*** remove my refs from external collections ***
	IMP.CommandMode.WorkshopObjectOnUnload_PUBLIC(Self)
	IMP.CreatureManager.WorkshopObjectOnUnload_PUBLIC(Self)
	IMP.MarkerManagerOwnership.WorkObjectOnUnload_PUBLIC(Self)

	;*** delete link from owner ***
	GetActorRefOwner().SetLinkedRef(NONE, LinkOwnerMarker)

	;*** null positioner ref ***
	PositionerRef=NONE

	;*** delete props ***
	((Self as ObjectReference) as IMPScriptMarkerProps).DeleteProps()

	;*** unlink marker from workshop ***
	ObjectReference WorkshopRef=GetLinkedRef(IMP.WorkshopItemKeyword)
	IMP.WorkshopParent.RemoveObjectPUBLIC(Self,  WorkshopRef as WorkshopScript)
	SetLinkedRef(NONE, IMP.WorkshopItemKeyword)

	;*** remove ownership ***
	((Self as ObjectReference) as IMPScriptMarkerProps).SetIdleMarkerOwnership(NONE)
	SetActorRefOwner(NONE)

	MoveTo(IMP.TrashbinMarkerAlias.GetReference())
	DisableNoWait()
	Delete()

	GotoState("Deleted")
EndFunction

;=========

Function SaveRadiusSize(Int aiRadiusSizeValue)
	RadiusSizeValue=aiRadiusSizeValue
EndFunction

Int Function GetRadiusSize()
	return RadiusSizeValue
EndFunction

;=========

State Deleted

EndState