Scriptname IMPScriptMarkerManagerOwnership extends Quest Conditional

RefCollectionAlias property WorkshopCollection auto const mandatory
RefCollectionAlias property WorkshopCollectionEXT auto const mandatory
RefCollectionAlias property WorkObjectCollection auto const mandatory
RefCollectionAlias property WorkerCollection auto const mandatory
ReferenceAlias property MarkerNameAlias auto const mandatory
ReferenceAlias property MarkerOwnershipAlias auto const mandatory
ReferenceAlias property OwnershipPublicAlias auto const mandatory
Message property IMP_MarkerManagerUnsetOwnershipMenuMESGb auto const mandatory

IMPScriptMain IMP
IMPScriptMarker[] SettlerSandboxMarkerRefs

ObjectReference MenuSettlerRef

Int MarkerRefCount Conditional
Int ActionsDoneCount Conditional
Bool bHasMarkerOwner_ Conditional

;= filled in v 3.11 =
Message property IMP_MarkerManagerOwnership_MarkerListMESGb auto

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	InitializeCollections()

	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorCaravanUnassign")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectDestroyed")

	SettlerSandboxMarkerRefs=new IMPScriptMarker[0]
EndEvent

Event OnQuestShutdown()
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorCaravanUnassign")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectDestroyed")
EndEvent



;=====================
; FUNCTIONS FOR INITIALIZATION
;=====================

Function InitializeCollections()
	;*** workshop collection ***
	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)

	;*** settler collection ***
	Int i=0
	while i<WorkshopCollectionEXT.GetCount()
		ObjectReference iWorkshopRef=WorkshopCollectionEXT.GetAt(i)
		if iWorkshopRef.Is3DLoaded()
			SetCollections(iWorkshopRef)
		endif
		i+=1
	endwhile
EndFunction


Function SetCollections(ObjectReference akWorkshopRef)
	if akWorkshopRef
		ObjectReference[] WorkshopResourceRefs=akWorkshopRef.GetWorkshopResourceObjects()
		Int WorkshopResourceCount=WorkshopResourceRefs.length

		if  WorkshopResourceCount > 0
			ObjectReference[] WorkshopWorkobjectRefs=new ObjectReference[0]
			Int i=0
			while i < WorkshopResourceCount
				WorkshopObjectScript iObjectRef=WorkshopResourceRefs[i] as WorkshopObjectScript
				if iObjectRef
					if \
					iObjectRef.HasKeyword(IMP.WorkshopWorkObject) && \
					iObjectRef.GetValue(IMP.WorkshopResourceObject) > 0 && \
					iObjectRef.RequiresActor() && \
					iObjectRef.IsActorAssigned()

						;*** set workobjects ***
						iObjectRef.SetLinkedRef(iObjectRef.GetAssignedActor(), IMP.IMP_LinkWorkshopobjectOwner)
						WorkObjectCollection.AddRef(iObjectRef)

						;*** set workers ***
						WorkerCollection.AddRef(iObjectRef.GetAssignedActor())

					endif
				endif
				i+=1
			endwhile

		endif
	endif
EndFunction



;===========================
; FUNCTIONS USED BY COLLECTION SCRIPTS
;===========================

Function WorkshopOnLoad_PUBLIC(ObjectReference akWorkshopRef)
	SetCollections(akWorkshopRef)

	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction

;---------

Function WorkObjectOnUnload_PUBLIC(ObjectReference akWorkObjectRef)
	akWorkObjectRef.SetLinkedRef(NONE, IMP.IMP_LinkWorkshopobjectOwner)
	WorkObjectCollection.RemoveRef(akWorkObjectRef)
EndFunction

;---------

Function WorkerOnUnload_PUBLIC(ObjectReference akWorkerRef)
	WorkerCollection.RemoveRef(akWorkerRef)
EndFunction

Function WorkerOnWorkshopNPCTransfer_PUBLIC(ObjectReference akWorkerRef)
	SetAllSandboxMarkersPublic(GetSandboxMarkerRefs(akWorkerRef))
EndFunction

Function WorkerOnDeath_PUBLIC(ObjectReference akWorkerRef)
	SetAllSandboxMarkersPublic(GetSandboxMarkerRefs(akWorkerRef))
EndFunction



;==================
; WORKSHOP PARENT EVENTS
;==================

Event WorkshopParentScript.WorkshopActorAssignedToWork(WorkshopParentScript akSender, Var[] akArgs)
	;*** Get assigned workshop object ref ***
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference

	if \
	WorkshopObjectRef.HasKeyword(IMP.WorkshopWorkObject) && \
	WorkshopObjectRef.GetValue(IMP.WorkshopResourceObject) > 0

		;*** Set ownership ***
		Actor OwnerRef=WorkshopObjectRef.GetActorRefOwner()
		WorkshopObjectRef.SetLinkedRef(OwnerRef, IMP.IMP_LinkWorkshopobjectOwner)

		;*** Set collections ***
		WorkObjectCollection.AddRef(WorkshopObjectRef)
		WorkerCollection.AddRef(OwnerRef)

		;*** Update internal data if IMP marker ***
		if WorkshopObjectRef as IMPScriptMarker
			(WorkshopObjectRef as IMPScriptMarker).UpdateInternalData()
		endif
		
	endif
EndEvent

;---------

Event WorkshopParentScript.WorkshopActorUnassigned(WorkshopParentScript akSender, Var[] akArgs)
	;*** Get assigned workshop object ref ***
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference

	if WorkObjectCollection.Find(WorkshopObjectRef) >= 0
		;*** Unset ownership ***
		ObjectReference OwnerRef=WorkshopObjectRef.GetLinkedRef(IMP.IMP_LinkWorkshopobjectOwner)
		WorkshopObjectRef.SetLinkedRef(NONE, IMP.IMP_LinkWorkshopobjectOwner)


		;*** Set collection ***
		WorkObjectCollection.RemoveRef(WorkshopObjectRef)


		;*** Update internal data if IMP marker ***
		if WorkshopObjectRef as IMPScriptMarker
			(WorkshopObjectRef as IMPScriptMarker).UpdateInternalData()
		endif

		;*** Check linked sandbox markers ***
		ManageSandboxMarkersOnDestructionEvent(OwnerRef)
	endif
EndEvent


Event WorkshopParentScript.WorkshopObjectDestroyed(WorkshopParentScript akSender, Var[] akArgs)
	;*** Get assigned workshop object ref ***
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference

	if WorkObjectCollection.Find(WorkshopObjectRef) >= 0

		;*** Unset ownership ***
		ObjectReference OwnerRef=WorkshopObjectRef.GetLinkedRef(IMP.IMP_LinkWorkshopobjectOwner)
		WorkshopObjectRef.SetLinkedRef(NONE, IMP.IMP_LinkWorkshopobjectOwner)


		;*** Set collection ***
		WorkObjectCollection.RemoveRef(WorkshopObjectRef)


		;*** Update internal data if IMP marker ***
		(WorkshopObjectRef as IMPScriptMarker).UpdateInternalData()


		;*** Check linked sandbox markers ***
		ManageSandboxMarkersOnDestructionEvent(OwnerRef)
	endif
EndEvent


Bool Function bHasWorkstations(ObjectReference OwnerRef)
	if OwnerRef
		ObjectReference WorkshopRef=OwnerRef.GetLinkedRef(IMP.WorkshopItemKeyword)
		ObjectReference[] OwnedObjectsRefs=WorkshopRef.GetWorkshopOwnedObjects(OwnerRef as Actor)
		Int OwnedObjectsCount=OwnedObjectsRefs.length
		Int i=0
		while i < OwnedObjectsCount
			WorkshopObjectScript iOwnedObjectRef=OwnedObjectsRefs[i] as WorkshopObjectScript
			if iOwnedObjectRef.Is3DLoaded()  && \
			iOwnedObjectRef.IsBed() == False && \
			iOwnedObjectRef.IsActorAssigned() == True &&  iOwnedObjectRef.GetAssignedActor()
				i=OwnedObjectsCount
				return True
			endif
			i+=1
		endwhile
	endif
EndFunction

;---------

Event WorkshopParentScript.WorkshopActorCaravanUnassign(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ProvisionerRef=akArgs[0] as ObjectReference

	;*** Check linked sandbox markers ***
	ManageSandboxMarkersOnDestructionEvent(ProvisionerRef)
EndEvent



;================================
; FUNCTIONS USED BY OWNERSHIP MANAGER MENU
;================================

Function ManageSandboxMarkersOnDestructionEvent(ObjectReference akSettlerRef)
	if akSettlerRef
		SettlerSandboxMarkerRefs.Clear()
		MarkerRefCount=0
		ActionsDoneCount=0


		ObjectReference WorkshopRef=akSettlerRef.GetLinkedRef(IMP.WorkshopItemKeyword)
		ObjectReference[] SettlerObjectsRefs=WorkshopRef.GetWorkshopOwnedObjects(akSettlerRef as Actor)
		Int SettlerObjectsCount=SettlerObjectsRefs.length
		Int SettlerWorkObjectCount=0

		if SettlerObjectsCount > 0
			Int i=0
			while i < SettlerObjectsCount
				WorkshopObjectScript iSettlerWorkObjectRef=SettlerObjectsRefs[i] as WorkshopObjectScript 
				IMPScriptMarker iSettlerIMPMarkerRef=SettlerObjectsRefs[i] as IMPScriptMarker 

				if iSettlerWorkObjectRef
					if iSettlerWorkObjectRef.RequiresActor()  &&   iSettlerWorkObjectRef.IsBed() == False &&   iSettlerWorkObjectRef.IsActorAssigned() == True
						SettlerWorkObjectCount+=1
					endif

				elseif iSettlerIMPMarkerRef
					if iSettlerIMPMarkerRef.HasKeyword(IMP.IMP_IsSandboxRelaxMarker)  ||   iSettlerIMPMarkerRef.HasKeyword(IMP.IMP_IsSandboxWorkMarker)
						SettlerSandboxMarkerRefs.Add(iSettlerIMPMarkerRef)
					endif
					
				endif

				i+=1
			endwhile

			
			if SettlerWorkObjectCount == 0
				MarkerRefCount=SettlerSandboxMarkerRefs.length
				if MarkerRefCount > 0
					MenuSettlerRef=akSettlerRef

					if akSettlerRef.Is3DLoaded()
						MarkerOwnershipAlias.ForceRefTo(MenuSettlerRef)
						Int iButton=IMP_MarkerManagerUnsetOwnershipMenuMESGb.Show(MarkerRefCount)
						if iButton==0
							;*** quit ***
							SettlerSandboxMarkerRefs.Clear()
							MarkerRefCount=0
							ActionsDoneCount=0

						elseif iButton==1
							;*** set all markers to public ownership ***
							SetAllSandboxMarkersPublic(SettlerSandboxMarkerRefs)
							SettlerSandboxMarkerRefs.Clear()
							MarkerRefCount=0
							ActionsDoneCount=0

						elseif iButton==2
							ShowSingleMarkerMenu(0)

						endif

					else
						;*** set all markers to public ownership when unloaded (rare event) ***
						SetAllSandboxMarkersPublic(SettlerSandboxMarkerRefs)
						SettlerSandboxMarkerRefs.Clear()
						MarkerRefCount=0
						ActionsDoneCount=0

					endif

				endif
			endif


		endif

	endif
EndFunction


Function ShowSingleMarkerMenu(Int aiIndex)
	IMPScriptMarker MarkerRef=SettlerSandboxMarkerRefs[aiIndex]


	;*** fill menu aliases ***
	MarkerNameAlias.ForceRefTo(MarkerRef.GetPositionerRef())

	Actor OwnerRef=MarkerRef.GetActorRefOwner()
	bHasMarkerOwner_=OwnerRef as Bool
	if bHasMarkerOwner_
		MarkerOwnershipAlias.ForceRefTo(OwnerRef)
	else
		MarkerOwnershipAlias.ForceRefTo(OwnershipPublicAlias.GetReference())
	endif


	;*** show menu ***
	Int iButton=IMP_MarkerManagerOwnership_MarkerListMESGb.Show(aiIndex+1, MarkerRefCount)
	if iButton==0
		;*** next ***
		Int NextIndex=aiIndex+1
		if NextIndex > (MarkerRefCount-1)
			NextIndex=0
		endif
		ShowSingleMarkerMenu(NextIndex)

	elseif  iButton==1
		;*** previous ***
		Int PrevIndex=aiIndex-1
		if PrevIndex < 0
			PrevIndex=MarkerRefCount-1
		endif
		ShowSingleMarkerMenu(PrevIndex)

	elseif  iButton==2
		;*** set settler ownership ***
		if !bHasMarkerOwner_
			((MarkerRef as ObjectReference) as IMPScriptMarkerProps).SetIdleMarkerOwnership(MenuSettlerRef as Actor)
			MarkerRef.SetActorRefOwner(MenuSettlerRef as Actor)
			(MarkerRef.GetPositionerRef()).SetActorRefOwner(MenuSettlerRef as Actor)
			ActionsDoneCount+=1
			ShowSingleMarkerMenu(aiIndex)
		endif

	elseif  iButton==3
		;*** set public ownership ***
		if bHasMarkerOwner_
			((MarkerRef as ObjectReference) as IMPScriptMarkerProps).SetIdleMarkerOwnership(NONE)
			MarkerRef.SetActorRefOwner(NONE)
			(MarkerRef.GetPositionerRef()).SetActorRefOwner(NONE)
			ActionsDoneCount+=1
			ShowSingleMarkerMenu(aiIndex)
		endif

	elseif  iButton==4  ||  iButton==5
		;*** cancel or OK ***
		SettlerSandboxMarkerRefs.Clear()
		MarkerRefCount=0
		ActionsDoneCount=0

	endif
EndFunction


;---------


IMPScriptMarker[] Function GetSandboxMarkerRefs(ObjectReference akSettlerRef)
	if akSettlerRef
		ObjectReference[] SandboxMarkerRefs=new ObjectReference[0]
		ObjectReference WorkshopRef=akSettlerRef.GetLinkedRef(IMP.WorkshopItemKeyword)
		ObjectReference[] OwnedObjectsRefs=WorkshopRef.GetWorkshopOwnedObjects(akSettlerRef as Actor)
		Int OwnedObjectsRefCount=OwnedObjectsRefs.length
		if OwnedObjectsRefCount > 0
			;*** get owned objectrefs by settler ***
			Int i=0
			while i < OwnedObjectsRefCount
				IMPScriptMarker iObjectRef=OwnedObjectsRefs[i] as IMPScriptMarker
				if \
				iObjectRef.HasKeyword(IMP.IMP_IsSandboxRelaxMarker) || \
				iObjectRef.HasKeyword(IMP.IMP_IsSandboxWorkMarker) || \
				iObjectRef.HasKeyword(IMP.IMP_IsCreatureMarker) || \
				iObjectRef.HasKeyword(IMP.IMP_IsSandboxMerchantMarker)
					SandboxMarkerRefs.Add(iObjectRef)
				endif
				i+=1
			endwhile

			return (SandboxMarkerRefs as IMPScriptMarker[])
		endif		
	endif
EndFunction


Function SetAllSandboxMarkersPublic(IMPScriptMarker[] akSandboxMarkerRefs)
	Int SandboxMarkerCount=akSandboxMarkerRefs.length
	Int i=0
	while i < SandboxMarkerCount
		IMPScriptMarker iSanboxMarkerRef=akSandboxMarkerRefs[i]
		((iSanboxMarkerRef as ObjectReference) as IMPScriptMarkerProps).SetIdleMarkerOwnership(NONE)
		(iSanboxMarkerRef).SetActorRefOwner(NONE)
		(iSanboxMarkerRef.GetPositionerRef()).SetActorRefOwner(NONE)
		i+=1
	endwhile
EndFunction