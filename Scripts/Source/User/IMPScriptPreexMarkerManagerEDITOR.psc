Scriptname IMPScriptPreexMarkerManagerEDITOR extends Quest

RefCollectionAlias property WorkshopCollection auto const mandatory
RefCollectionAlias property WorkshopCollectionEXT auto const mandatory
Formlist property IMP_PreexPlaced_MarkerReplacer auto const mandatory
Formlist property IMP_PreexPlaced_MarkerToReplace auto const mandatory

Faction[] FormerMarkerOwnerFactions
ObjectReference[] ReplacedPreexMarkerRefs

IMPScriptMain IMP
Bool bIsUninstalled

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	FormerMarkerOwnerFactions=new Faction[0]
	ReplacedPreexMarkerRefs=new ObjectReference[0]

	InitializeCollections()
EndEvent


Event OnQuestShutdown()
	if bIsUninstalled == False
		StopPreexMarkerEditorQuest()
	endif
EndEvent



;=====================
; FUNCTION FOR INITIALIZATION
;=====================

Function InitializeCollections()
	;*** workshop collection ***
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)

	Int i=0
	while i<WorkshopCollectionEXT.GetCount()
		ObjectReference iWorkshopRef=WorkshopCollectionEXT.GetAt(i)
		if iWorkshopRef.Is3DLoaded()
			FindPreexMarkers(iWorkshopRef)
		endif
		i+=1
	endwhile
EndFunction



;============
; MAIN FUNCTIONS
;============

Function FindPreexMarkers(ObjectReference akWorkshopRef)
	if \
	akWorkshopRef && \
	akWorkshopRef.Is3DLoaded()

		ObjectReference[] MarkerRefs=akWorkshopRef.FindAllReferencesOfType(IMP_PreexPlaced_MarkerToReplace, IMP.IMP_MarkerSearchMaxRadius.GetValue())
		Int MarkerCount=MarkerRefs.length

		if MarkerCount > 0
			Location WorkshopLocation=akWorkshopRef.GetCurrentLocation()
			Int i=0
			while i < MarkerCount
				ObjectReference iPreexMarkerRef=MarkerRefs[i]

				if \
				WorkshopLocation == iPreexMarkerRef.GetCurrentLocation() && \
				iPreexMarkerRef.IsWithinBuildableArea(akWorkshopRef) && \
				iPreexMarkerRef.IsCreated() == False && \
				iPreexMarkerRef.IsEnabled() == True && \
				ReplacedPreexMarkerRefs.Find(iPreexMarkerRef) < 0

					Actor OwnerRef=iPreexMarkerRef.GetActorRefOwner()	
					Faction OwnerFaction=iPreexMarkerRef.GetFactionOwner()


					;*** add iPreexMarkerRef to arrays in order to save its ref id (persistent) ***
					ReplacedPreexMarkerRefs.Add(iPreexMarkerRef)
					FormerMarkerOwnerFactions.Add(iPreexMarkerRef.GetFactionOwner())


					;*** create NewMarkerRef ***
					Int Index=IMP_PreexPlaced_MarkerToReplace.Find(iPreexMarkerRef.GetBaseObject())
					ObjectReference NewMarkerRef=iPreexMarkerRef.PlaceAtMe(IMP_PreexPlaced_MarkerReplacer.GetAt(Index) as Form, abDeleteWhenAble=False)
					NewMarkerRef.SetLinkedRef(akWorkshopRef, IMP.WorkshopItemKeyword)
					NewMarkerRef.SetAngle(0, 0, iPreexMarkerRef.GetAngleZ())


					(NewMarkerRef as IMPScriptMarker).SetPreexMarkerEditorReplacer(True)


					;*** copy ownership to NewMarkerRef ***
					if OwnerFaction
						NewMarkerRef.SetFactionOwner(OwnerFaction)
					elseif OwnerRef
						NewMarkerRef.SetActorRefOwner(OwnerRef)
					endif


					;*** create positioner ***
					Int IndexList=IMP.IMP_MarkerList.Find(NewMarkerRef.GetBaseObject())
					ObjectReference NewPositionerRef =  NewMarkerRef.PlaceAtMe(IMP.IMP_PositionerList.GetAt(IndexList) as Form, abInitiallyDisabled =! (IMP.IMP_IsInWorkshopMode.GetValue()) as Bool)
					NewPositionerRef.SetLinkedRef(akWorkshopRef, IMP.WorkshopItemKeyword)
					IMP.WorkshopMode.AddPositioner_PUBLIC(NewPositionerRef)
	
					;*** set markers ***
					(NewMarkerRef as IMPScriptMarker).SetPositionerRef(NewPositionerRef)
					(NewPositionerRef as IMPScriptPositioner).SetMarkerRef(NewMarkerRef)

					;*** create props ***
					(NewMarkerRef as IMPScriptMarkerProps).CreateProps()
					
					Form MarkerBaseObject=iPreexMarkerRef.GetBaseObject()
					if MarkerBaseObject == IMP.WorkshopGuardMarker
						;*** special case: complete marker creation if it is WorkshopGuardMarker ***
						IMP.WorkshopParent.BuildObjectPUBLIC(NewMarkerRef, akWorkshopRef as WorkshopScript)

						iPreexMarkerRef.SetFactionOwner(IMP.IMP_PreexMarkerEditor_FakeFactionOwner)

						;*** update positioner UI ***
						(NewMarkerRef as IMPScriptMarker).UpdateInternalData()
					
					else
						iPreexMarkerRef.SetFactionOwner(IMP.IMP_PreexMarkerEditor_FakeFactionOwner)
					endif


				endif

				i+=1
			endwhile

		endif

	endif
EndFunction


Function RestoreReplacedPreexMarkers()
	Int ReplacedPreexMarkerCount=ReplacedPreexMarkerRefs.length

	Int i=0
	while i < ReplacedPreexMarkerCount
		Objectreference iMarkerRef=ReplacedPreexMarkerRefs[i]
		iMarkerRef.SetFactionOwner(FormerMarkerOwnerFactions[i])
		i+=1
	endwhile

	IMP.WorkshopMode.DeletePreexMarkersEditor_PUBLIC()

	ReplacedPreexMarkerRefs.Clear()
	FormerMarkerOwnerFactions.Clear()
EndFunction



;======================
; FUNCTIONS USED BY COLLECTIONS
;======================

Function WorkshopOnLoad_PUBLIC(ObjectReference akWorkshopRef)
	FindPreexMarkers(akWorkshopRef)

	WorkshopCollection.RemoveAll()
	WorkshopCollection.AddRefCollection(WorkshopCollectionEXT)
EndFunction



;============
; UNINSTALL QUEST
;============

Function StopPreexMarkerEditorQuest()
	bIsUninstalled=True
	RestoreReplacedPreexMarkers()
	Stop()
EndFunction

Function StopPreexMarkerEditorQuest_PUBLIC()
	StopPreexMarkerEditorQuest()
EndFunction