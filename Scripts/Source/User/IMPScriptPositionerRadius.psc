Scriptname IMPScriptPositionerRadius extends ObjectReference

Activator property PositionerRadiusForm auto const mandatory
GlobalVariable property PositionerDisplayCondition auto const mandatory
Int property Size=1024 auto
Bool property bEnableRadiusOnPositionerPlacedEvent=True auto

IMPScriptMain IMP
ObjectReference PositionerRadiusRef
ObjectReference WorkshopRef
Bool bIsRadiusDeleted

Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent

;======

Function CreateRadiusPositioner(ObjectReference akWorkshopRef=NONE, Bool abIsCreatedByPositioner=False, Int aiSize=-1)
	if akWorkshopRef && bIsRadiusDeleted == False
		if aiSize != -1
			Size=aiSize
		endif

		PositionerRadiusRef=PlaceAtMe(PositionerRadiusForm, abInitiallyDisabled=True)
		PositionerRadiusRef.MoveTo(Self, afZOffset=64)
		PositionerRadiusRef.SetScale(Size/1024.00)

		ObjectReference MarkerRef=((Self as ObjectReference) as IMPScriptPositioner).GetMarkerRef()
		(MarkerRef as IMPScriptMarker).SaveRadiusSize(Size)
		
		IMP.WorkshopMode.AddPositioner_PUBLIC(PositionerRadiusRef)
		
		if IMP.IMP_PositionerFilter_ShowRadius.GetValue() == 1  &&  PositionerDisplayCondition.GetValue() == 1
			if abIsCreatedByPositioner
				if bEnableRadiusOnPositionerPlacedEvent
					PositionerRadiusRef.EnableNoWait()
				else
					;*** don't creat: wait option from menus ***
				endif
			else
				if IMP.IMP_IsInWorkshopMode.GetValue() == 1
					PositionerRadiusRef.EnableNoWait()
				endif
			endif
		endif

		WorkshopRef=akWorkshopRef
		RegisterForRemoteEvent(WorkshopRef, "OnWorkshopMode")
	endif
EndFunction

;======

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	if bIsRadiusDeleted == False
		PositionerRadiusRef.DisableNoWait()
	endif
EndEvent
	
Event OnWorkshopObjectMoved(ObjectReference akReference)
	if bIsRadiusDeleted == False
		PositionerRadiusRef.MoveTo(Self, afZOffset=64)
		PositionerRadiusRef.EnableNoWait()
	endif
EndEvent

;=========

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	IMP.WorkshopMode.RemovePositioner_PUBLIC(PositionerRadiusRef)
	PositionerRadiusRef.DisableNoWait()
	PositionerRadiusRef.Delete()
	PositionerRadiusRef=NONE
	WorkshopRef=NONE
	UnregisterForRemoteEvent(WorkshopRef, "OnWorkshopMode")
	bIsRadiusDeleted=True
EndEvent

Event OnCellDetach()
	IMP.WorkshopMode.RemovePositioner_PUBLIC(PositionerRadiusRef)
	PositionerRadiusRef.DisableNoWait()
	PositionerRadiusRef.Delete()
	PositionerRadiusRef=NONE
	WorkshopRef=NONE
	UnregisterForRemoteEvent(WorkshopRef, "OnWorkshopMode")
EndEvent

;=========

Event ObjectReference.OnWorkshopMode(ObjectReference akSender, bool aStart)
	if IMP.IMP_PositionerFilter_ShowRadius.GetValue() == 1  &&  PositionerDisplayCondition.GetValue() == 1
		if aStart == True
			PositionerRadiusRef.EnableNoWait()
		endif
	endif
EndEvent

;=========

Function RestrictedSandbox_SetScaleRadiusPositioner_PUBLIC(Int aiSizeValue, Bool bEnableRadiusPositioner=False)
	if PositionerRadiusRef == NONE
		Float EndLoopTime=Utility.GetCurrentRealTime()+5
		while PositionerRadiusRef == NONE && EndLoopTime > Utility.GetCurrentRealTime()
			;wait untill Ref is acquired
		endwhile
	endif

	Size=aiSizeValue
	PositionerRadiusRef.SetScale(Size/1024.00)

	ObjectReference MarkerRef=((Self as ObjectReference) as IMPScriptPositioner).GetMarkerRef()
	(MarkerRef as IMPScriptMarker).SaveRadiusSize(Size)	

	if bEnableRadiusPositioner
		if IMP.IMP_PositionerFilter_ShowRadius.GetValue() == 1  &&  PositionerDisplayCondition.GetValue() == 1
			if IsEnabled()
				PositionerRadiusRef.EnableNoWait()
			endif
		endif
	endif
EndFunction