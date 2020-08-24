Scriptname IMPScriptPreexMarkerManagerINGAME extends Quest

RefCollectionAlias property WorkshopCollection auto const mandatory
RefCollectionAlias property WorkshopCollectionEXT auto const mandatory

IMPScriptMain IMP

Bool bIsPlacePreexMarkerRefBusy
ObjectReference[] ProcessedMarkerRefs
ObjectReference[] ProcessedResourceRefs

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	InitializeCollections()

	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectDestructionStageChanged")
	RegisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectRepaired")
EndEvent

Event OnQuestShutdown()
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorAssignedToWork")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopActorUnassigned")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectDestructionStageChanged")
	UnregisterForCustomEvent(IMP.WorkshopParent, "WorkshopObjectRepaired")
EndEvent



;==================
; WORKSHOP PARENT EVENTS
;==================

Event WorkshopParentScript.WorkshopActorAssignedToWork(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference
	if WorkshopObjectRef
		PlacePreexMarkersFromResource(WorkshopObjectRef)
	endif
EndEvent

Event WorkshopParentScript.WorkshopActorUnassigned(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference
	if WorkshopObjectRef
		DeletePositioners(akArgs[0] as ObjectReference)
	endif
EndEvent

Event WorkshopParentScript.WorkshopObjectDestructionStageChanged(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference
	if WorkshopObjectRef
		if (akArgs[0] as ObjectReference).IsDestroyed() == True
			DeletePositioners(akArgs[0] as ObjectReference)
		endif
	endif
EndEvent

Event WorkshopParentScript.WorkshopObjectRepaired(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference WorkshopObjectRef=akArgs[0] as ObjectReference
	if WorkshopObjectRef
		if WorkshopObjectRef.IsDestroyed() == True
			PlacePreexMarkersFromResource(WorkshopObjectRef)
		endif
	endif
EndEvent



;============
; MAIN FUNCTIONS
;============

Function PlacePreexMarkersFromWorkshop(ObjectReference akWorkshopRef)
	if akWorkshopRef
		ObjectReference[] WorkshopResourceRefs=akWorkshopRef.GetWorkshopResourceObjects()
		Int WorkshopResourceCount=WorkshopResourceRefs.length

		if WorkshopResourceCount > 0
			Int i=0
			while i < WorkshopResourceCount
				ObjectReference iWorkshopResourceRef=WorkshopResourceRefs[i]
				if iWorkshopResourceRef
					PlacePreexMarkersFromResource(iWorkshopResourceRef)
				endif
				i+=1
			endwhile
		endif

		ProcessedMarkerRefs.Clear()
	endif
EndFunction


Function PlacePreexMarkersFromResource(ObjectReference akResourceRef)
	WorkshopObjectScript WorkshopResourceRef=akResourceRef as WorkshopObjectScript
	if WorkshopResourceRef
		if WorkshopResourceRef.FurnitureBase

			Bool bPlaceMarkers
			if WorkshopResourceRef.IsActorAssigned() == True && WorkshopResourceRef.GetAssignedActor()
				bPlaceMarkers=True
			elseif WorkshopResourceRef.IsActorAssigned() == False
				bPlaceMarkers=True
			endif

			if bPlaceMarkers
				if bIsPlacePreexMarkerRefBusy
					ProcessedResourceRefs.Add(akResourceRef)

				else
					bIsPlacePreexMarkerRefBusy=True
				
					Int ExpectedFurnitureMarkerCount=WorkshopResourceRef.FurnitureMarkerNodes.length
					ObjectReference[] FurnitureMarkerRefs=WorkshopResourceRef.GetFurnitureMarkerRefs()
					Int CreatedFurnitureMarkerCount=FurnitureMarkerRefs.length


					if ExpectedFurnitureMarkerCount > CreatedFurnitureMarkerCount
						Float EndLoopTime=Utility.GetCurrentRealTime()+5
						Bool bEndLoop
						while bEndLoop == False
							if Utility.GetCurrentRealTime() >= EndLoopTime
								bEndLoop=True
							elseif CreatedFurnitureMarkerCount >= ExpectedFurnitureMarkerCount
								bEndLoop=True
							else
								FurnitureMarkerRefs=WorkshopResourceRef.GetFurnitureMarkerRefs()
								CreatedFurnitureMarkerCount=FurnitureMarkerRefs.length
							endif
						endwhile
					endif


					if CreatedFurnitureMarkerCount > 0																																								
						Int i=0
						while i < CreatedFurnitureMarkerCount
							ObjectReference iFurnitureMarkerRef=FurnitureMarkerRefs[i]
							if iFurnitureMarkerRef
								ObjectReference PositionerRef=iFurnitureMarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkPositionerPreexMarker)[0]
								if PositionerRef == NONE

									Form MarkerBaseObject=iFurnitureMarkerRef.GetBaseObject()
									Int Index=IMP.IMP_PreexMarkerFurnitureList.Find(MarkerBaseObject)

									if Index >= 0
										PositionerRef=iFurnitureMarkerRef.PlaceAtMe(IMP.IMP_PreexPositionerFurnitureList.GetAt(Index) as Form, abInitiallyDisabled=!(IMP.IMP_IsInWorkshopMode.GetValue() as Bool))
										ProcessedMarkerRefs.Add(PositionerRef)
										PositionerRef.SetLinkedRef(akResourceRef, IMP.IMP_LinkPositionerPreexResource)
										PositionerRef.SetLinkedRef(iFurnitureMarkerRef, IMP.IMP_LinkPositionerPreexMarker)						
										ObjectReference WorkshopRef=akResourceRef.GetLinkedRef(IMP.WorkshopItemKeyword)
										PositionerRef.SetLinkedRef(WorkshopRef, IMP.WorkshopItemKeyword)
											
										IMP.WorkshopMode.AddPositioner_PUBLIC(PositionerRef)
											
										(PositionerRef as IMPScriptPositionerPreexIngame).SetRemoteEventsRef_PUBLIC(akResourceRef)
										(PositionerRef as IMPScriptPositionerPreexIngame).SaveResourcePos_PUBLIC(akResourceRef)
										(PositionerRef as IMPScriptPositionerPreexIngame).SaveMarkerPos_PUBLIC(iFurnitureMarkerRef)
									endif

								endif
							endif

							i+=1

						endwhile
						
						
					endif

					
					bIsPlacePreexMarkerRefBusy=False

					if ProcessedResourceRefs.length > 0
						ObjectReference ProcessedResourceRef=ProcessedResourceRefs[0]
						ProcessedResourceRefs.Remove(0)
						if ProcessedResourceRef
							PlacePreexMarkersFromResource(ProcessedResourceRef)
						endif
					endif					
					
					
				endif
			endif

		endif
	endif
EndFunction


;---------


Function DeletePositioners(ObjectReference akResourceRef)
	WorkshopObjectScript WorkshopResourceRef=akResourceRef as WorkshopObjectScript
	if WorkshopResourceRef
		if WorkshopResourceRef.FurnitureBase
			ObjectReference[] PositionerRefs=akResourceRef.GetRefsLinkedToMe(IMP.IMP_LinkPositionerPreexResource)
			Int PositionerCount=PositionerRefs.length
			if PositionerCount > 0
				Int i=0
				while i < PositionerCount
					ObjectReference iPositionerRef=PositionerRefs[i]
					iPositionerRef.SetLinkedRef(NONE, IMP.IMP_LinkPositionerPreexResource)
					iPositionerRef.SetLinkedRef(NONE, IMP.IMP_LinkPositionerPreexMarker)
					iPositionerRef.SetLinkedRef(NONE, IMP.WorkshopItemKeyword)
	
					IMP.WorkshopMode.RemovePositioner_PUBLIC(iPositionerRef)
	
					iPositionerRef.DisableNoWait()
					iPositionerRef.Delete()

					i+=1
				endwhile
			endif
		endif
	endif
EndFunction



;=====================
; FUNCTION FOR INITIALIZATION
;=====================

Function InitializeCollections()
	ProcessedMarkerRefs=new ObjectReference[0]
	ProcessedResourceRefs=new ObjectReference[0]

	;*** workshop collection ***
	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)

	;*** current workshop resources ***
	Int i=0
	while i<WorkshopCollectionEXT.GetCount()
		ObjectReference iWorkshopRef=WorkshopCollectionEXT.GetAt(i)
		if iWorkshopRef
			if iWorkshopRef.Is3DLoaded()
				PlacePreexMarkersFromWorkshop(iWorkshopRef)
			endif
		endif
		i+=1
	endwhile
EndFunction



;==========================
; FUNCTIONS USED BY EXTERNAL SCRIPTS
;==========================

Function WorkshopOnLoad_PUBLIC(ObjectReference akWorkshopRef)
	InitializeCollections()

	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction






