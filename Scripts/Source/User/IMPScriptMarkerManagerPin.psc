Scriptname IMPScriptMarkerManagerPin extends Quest

RefCollectionAlias property PinnedActorCollection auto const mandatory
RefCollectionAlias property PinnedMarkerCollection auto const mandatory
ReferenceAlias property MarkerNameAlias auto const mandatory
ReferenceAlias property ActorNameAlias auto const mandatory

Int MarkerObjectiveIndex=10
Int ActorObjectiveIndex=20
Int TimerID=10
GlobalVariable property IMP_MarkerManagerMenu_PinTimer auto const mandatory

IMPScriptMain IMP


;=========


Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent


Function Pin_AddActorToCollection_PUBLIC(ObjectReference akActorRef, ObjectReference akPositionerRef)
	if akActorRef  &&  akPositionerRef
		StopResetTimer()
		PinnedMarkerCollection.RemoveAll()
		PinnedActorCollection.RemoveAll()
		PinnedActorCollection.AddRef(akActorRef)

		if PinnedActorCollection.GetCount()>0
			MarkerNameAlias.ForceRefTo(akPositionerRef)
			SetActive()
			SetObjectiveDisplayed(MarkerObjectiveIndex, False)
			SetObjectiveDisplayed(ActorObjectiveIndex)
		endif
	endif
EndFunction

Function Pin_RemoveActorFromCollection_PUBLIC(ObjectReference akActorRef)
	if akActorRef
		PinnedActorCollection.RemoveRef(akActorRef)

		if PinnedActorCollection.GetCount()==0
			SetObjectiveDisplayed(ActorObjectiveIndex, False)
			SetActive(False)
			ActorNameAlias.Clear()
		endif
	endif
EndFunction

;---------

Function Pin_AddMarkerToCollection_PUBLIC(ObjectReference akMarkerRef, ObjectReference akActorRef)
	if akMarkerRef  &&  akActorRef
		StopResetTimer()
		PinnedActorCollection.RemoveAll()
		PinnedMarkerCollection.RemoveAll()
		PinnedMarkerCollection.AddRef(akMarkerRef)

		if PinnedMarkerCollection.GetCount()>0
			ActorNameAlias.ForceRefTo(akActorRef)
			SetActive()
			SetObjectiveDisplayed(ActorObjectiveIndex, False)
			SetObjectiveDisplayed(MarkerObjectiveIndex)
		endif
	endif
EndFunction

Function Pin_RemoveMarkerFromCollection_PUBLIC(ObjectReference akMarkerRef)
	if akMarkerRef
		PinnedMarkerCollection.RemoveRef(akMarkerRef)

		if PinnedMarkerCollection.GetCount()==0
			SetObjectiveDisplayed(MarkerObjectiveIndex, False)
			SetActive(False)
			MarkerNameAlias.Clear()
		endif
	endif
EndFunction


;---------


Function Pin_AddActorArrayToCollection_PUBLIC(ObjectReference[] akActorRefs, ObjectReference akPositionerRef)
	if akActorRefs && akPositionerRef
		StopResetTimer()
		PinnedMarkerCollection.RemoveAll()
		PinnedActorCollection.RemoveAll()
		PinnedActorCollection.AddArray(akActorRefs)

		if PinnedActorCollection.GetCount()>0
			MarkerNameAlias.ForceRefTo(akPositionerRef)
			SetActive()
			SetObjectiveDisplayed(MarkerObjectiveIndex, False)
			SetObjectiveDisplayed(ActorObjectiveIndex)
		endif
	endif
EndFunction

Function Pin_AddMarkerArrayToCollection_PUBLIC(ObjectReference[] akMarkerRefs, ObjectReference akActorRef)
	if akMarkerRefs && akActorRef
		StopResetTimer()
		PinnedActorCollection.RemoveAll()
		PinnedMarkerCollection.RemoveAll()
		PinnedMarkerCollection.AddArray(akMarkerRefs)

		if PinnedMarkerCollection.GetCount()>0
			ActorNameAlias.ForceRefTo(akActorRef)
			SetActive()
			SetObjectiveDisplayed(ActorObjectiveIndex, False)
			SetObjectiveDisplayed(MarkerObjectiveIndex)
		endif
	endif
EndFunction


;=========


Function Pin_StartResetTimer_PUBLIC()
	CancelTimer(TimerID)
	if PinnedMarkerCollection.GetCount()>0
		StartResetTimer()
	elseif PinnedActorCollection.GetCount()>0
		StartResetTimer()
	endif
EndFunction

Function StartResetTimer()
	CancelTimer(TimerID)
	StartTimer(IMP_MarkerManagerMenu_PinTimer.GetValue(), TimerID)
EndFunction

Function StopResetTimer()
	CancelTimer(TimerID)
EndFunction

;---------

Event OnTimer(int aiTimerID)		
	if aiTimerID == TimerID
		Pin_ResetCollection()
	endif
EndEvent

Function Pin_ResetCollection()
	StopResetTimer()
	MarkerNameAlias.Clear()
	ActorNameAlias.Clear()
	PinnedActorCollection.RemoveAll()
	PinnedMarkerCollection.RemoveAll()
	SetObjectiveDisplayed(MarkerObjectiveIndex, False)
	SetObjectiveDisplayed(ActorObjectiveIndex, False)
	SetActive(False)
EndFunction


Bool Function bIsRefPinned_PUBLIC(ObjectReference akRef)
	if akRef
		return akRef.HasKeyword(IMP.IMP_IsRefPinned)
	endif
EndFunction
