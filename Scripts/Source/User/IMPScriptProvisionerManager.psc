Scriptname IMPScriptProvisionerManager extends Quest Conditional

RefCollectionAlias property ProvisionerCollection auto const mandatory
RefCollectionAlias property ProvisionerLoadedCollection auto const mandatory
RefCollectionAlias property ProvisionerCollectionEXT auto const mandatory
RefCollectionAlias property ProvisionerBrahminCollection auto const mandatory
ReferenceAlias property ActorNameAlias auto const mandatory
LocationAlias property LocationNameAlias auto const mandatory
LocationAlias property DurationNameAlias auto const mandatory
Message property IMP_ProvisionerManagerProvisionerAssignSuccededMESGn auto const mandatory
Message property IMP_ProvisionerManagerProvisionerUnvalidMESGn auto const mandatory
Message property IMP_ProvisionerManagerProvisionerBrahminAssignSuccededMESGn auto const mandatory
Message property IMP_ProvisionerManagerProvisionerBrahminUnvalidMESGn auto const mandatory
Message property IMP_ProvisionerManagerProvisionerBrahminUnlinkedMESGn auto const mandatory
Message property IMP_ProvisionerManagerProvisionerBrahminCantStopMESGn auto const mandatory
Message property IMP_ProvisionerManagerWantToUnassignMESGb auto const mandatory
Message property IMP_ProvisionerManagerUnassignSuccededMESGn auto const mandatory
Message property IMP_ProvisionerManagerSandboxDurationSettingMenu01MESGb auto const mandatory
Message property IMP_ProvisionerManagerSandboxDurationSettingMenu02MESGb auto const mandatory
Formlist property IMP_ProvisionerManagerSandboxDurationList auto const mandatory

Float CurrentSandboxDurationValue Conditional
Float SandboxDurationSubmenu Conditional

ObjectReference property TrashbinMarkerRef auto const mandatory

IMPScriptMain IMP

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	InitializeCollections()
EndEvent



;===================
;===================
; SCRIPTS FOR PROVISIONERS
;===================
;===================

;=====================
; FUNCTIONS FOR INITIALIZATION
;=====================

Function InitializeCollections()
	;*** provisioner collection ***
	ProvisionerCollection.RemoveAll()
	ProvisionerCollection.AddRefCollection(ProvisionerCollectionEXT)
EndFunction



;==================
; WORKHOP PARENT EVENTS
;==================

Event WorkshopParentScript.WorkshopActorCaravanAssign(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ProvisionerRef=akArgs[0] as ObjectReference
	if ProvisionerCollection.Find(ProvisionerRef) < 0
		ProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStartDate, Utility.GetCurrentGametime()+IMP.IMP_ProvisionerStartNewSandboxPkgTimer.GetValue())
		ProvisionerCollection.AddRef(ProvisionerRef)
		(ProvisionerRef as Actor).EvaluatePackage()
	endif
EndEvent


Event WorkshopParentScript.WorkshopActorCaravanUnassign(WorkshopParentScript akSender, Var[] akArgs)
	ObjectReference ProvisionerRef=akArgs[0] as ObjectReference
	if ProvisionerCollection.Find(ProvisionerRef) >= 0
		ProvisionerCollection.RemoveRef(ProvisionerRef)
		ProvisionerLoadedCollection.RemoveRef(ProvisionerRef)
		ProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStage, 0)
		ProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageEndDate, 0)
		ProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStartDate, 0)
		ProvisionerRef.SetLinkedRef(NONE, IMP.IMP_LinkProvisionerMarker)
		(ProvisionerRef as Actor).EvaluatePackage()

		Actor myBrahmin=(ProvisionerRef as WorkshopNPCScript).myBrahmin
		myBrahmin.SetLinkedRef(NONE, IMP.IMP_LinkProvisionerbrahminMarker)
		ProvisionerBrahminCollection.RemoveRef(myBrahmin)
		myBrahmin.EvaluatePackage()
	endif
EndEvent



;==============================
; FUNCTIONS USED BY PROVISIONER PACKAGES
;==============================

Function SetProvisionerSandboxPackage(Actor akActorRef, Bool bForceStartPackage=FALSE)
	ObjectReference ProvisionerMarkerRef=Game.FindClosestReferenceOfType(IMP.IMP_Marker_ProvisionerMarker, akActorRef.GetPositionX(), akActorRef.GetPositionY(), akActorRef.GetPositionZ(), IMP.IMP_MarkerSearchMaxRadius.GetValue())
	
	if \
	ProvisionerMarkerRef && \
	ProvisionerMarkerRef.IsDisabled() == False && \
	ProvisionerMarkerRef.IsDeleted() == False
		;*** is provisioner's location home or destination? ***
		Bool bStartPackage
		Location MarkerWorkshopLocation=ProvisionerMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation()
		Location ProvisionerStartLocation=akActorRef.GetLinkedRef(IMP.WorkshopLinkCaravanStart).GetCurrentLocation()
		if bForceStartPackage
			bStartPackage=True
		elseif MarkerWorkshopLocation==ProvisionerStartLocation
			bStartPackage=True
		else
			Location ProvisionerEndLocation=akActorRef.GetLinkedRef(IMP.WorkshopLinkCaravanEnd).GetCurrentLocation()
			if MarkerWorkshopLocation==ProvisionerEndLocation
				;*** if provisioner passes near his home settlement, then stop ***
				bStartPackage=True
			else
				;*** if provisioner passes near a settlement which is not his home or destination, then roll: 30% he chooses to stop ***

				;*** if night, then there is higher chance a provisioner choses to stop at the nearest settlement ***
				Float CurrentGamehour=IMP.Gamehour.GetValue()
				Int ExtraChanceDuringNight
				if CurrentGamehour >= 21 || CurrentGamehour < 3
					ExtraChanceDuringNight=Utility.RandomInt(1,3)
				endif

				Int Roll=Utility.RandomInt(1, 10)
				if Roll <= (3 + ExtraChanceDuringNight)
					bStartPackage=True
				endif
			endif
		endif


		if bStartPackage
			akActorRef.SetLinkedRef(ProvisionerMarkerRef, IMP.IMP_LinkProvisionerMarker)
			akActorRef.SetValue(IMP.IMP_ProvisionerPackageStage, 1)

			Float CurrentGametime=Utility.GetCurrentGametime()
			Float TravelMaxDuration= 0.50 ;= 12 hours

			if akActorRef.GetValue(IMP.IMP_ProvisionerPackageEndDate) < CurrentGametime
				akActorRef.SetValue(IMP.IMP_ProvisionerPackageEndDate, CurrentGametime+TravelMaxDuration)
			endif

			if akActorRef.GetValue(IMP.IMP_ProvisionerPackageStartDate) < CurrentGametime
				akActorRef.SetValue(IMP.IMP_ProvisionerPackageStartDate, CurrentGametime+TravelMaxDuration+IMP.IMP_ProvisionerStartNewSandboxPkgTimer.GetValue())
			endif

			akActorRef.EvaluatePackage()
		else
			UnsetProvisionerSandboxPackage(akActorRef)
		endif
	else
		UnsetProvisionerSandboxPackage(akActorRef)
	endif
EndFunction

Function SetProvisionerSandboxPackage_PUBLIC(Actor akActorRef)
	SetProvisionerSandboxPackage(akActorRef)
EndFunction

Function SetSandboxDuration(Actor akActorRef)
	Float CurrentGametime=Utility.GetCurrentGametime()
	ObjectReference ProvisionerMarkerRef=akActorRef.GetLinkedRef(IMP.IMP_LinkProvisionerMarker)
	if ProvisionerMarkerRef
		Float MarkerSandboxDuration=GetSandboxDuration(ProvisionerMarkerRef)
		akActorRef.SetValue(IMP.IMP_ProvisionerPackageEndDate, CurrentGametime+MarkerSandboxDuration)
		akActorRef.SetValue(IMP.IMP_ProvisionerPackageStartDate, CurrentGametime+MarkerSandboxDuration+IMP.IMP_ProvisionerStartNewSandboxPkgTimer.GetValue())
		akActorRef.EvaluatePackage()
	endif
EndFunction

Function SetSandboxDuration_PUBLIC(Actor akActorRef)
	SetSandboxDuration(akActorRef)
EndFunction

;---------

Function UnsetProvisionerSandboxPackage(Actor akActorRef)
	Float CurrentGametime=Utility.GetCurrentGametime()

	if \
	akActorRef.Is3DLoaded() && \
	akActorRef.GetValue(IMP.IMP_ProvisionerPackageStartDate) < CurrentGametime  
		akActorRef.SetValue(IMP.IMP_ProvisionerPackageStartDate, CurrentGametime+IMP.IMP_ProvisionerStartNewSandboxPkgTimer.GetValue())
	endif

	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkProvisionerMarker)
	akActorRef.SetValue(IMP.IMP_ProvisionerPackageStage, 0)
	akActorRef.EvaluatePackage()

	
	;*** handle my brahmin ***
	Actor myBrahmin=(akActorRef as WorkshopNPCScript).myBrahmin
	UnsetProvisionerbrahminSandboxPackage(myBrahmin)
EndFunction

Function UnsetProvisionerSandboxPackage_PUBLIC(Actor akActorRef)
	UnsetProvisionerSandboxPackage(akActorRef)
EndFunction

;---------

Float Function GetSandboxDuration(ObjectReference akMarkerRef)
	if akMarkerRef
		Float Result

		Float MarkerValue=akMarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)

		if MarkerValue > 0
			Result=MarkerValue
		else
			Float Gamehour=IMP.GameHour.GetValue()

			if MarkerValue == -6
				;*** leave at sunrise ***
				if Gamehour > 6
					Result=24-Gamehour+6
				else
					Result=6-Gamehour
				endif

			elseif MarkerValue == -12
				;*** leave at midday ***
				if Gamehour > 12
					Result=24-Gamehour+12
				else
					Result=12-Gamehour
				endif

			elseif MarkerValue == -18
				;*** leave at sunset ***
				if Gamehour > 18
					Result=24-Gamehour+18
				else
					Result=18-Gamehour
				endif

			elseif MarkerValue == -24
				;*** leave at midnight ***
				Result=24-Gamehour

			endif

		endif

		Return Result/24
	endif
EndFunction

;---------

Location Function GetSandboxDurationText(Float afMarkerValue)
	if afMarkerValue == -6
		return IMP_ProvisionerManagerSandboxDurationList.GetAt(0) as Location
	elseif afMarkerValue == -12
		return IMP_ProvisionerManagerSandboxDurationList.GetAt(1) as Location
	elseif afMarkerValue == -18
		return IMP_ProvisionerManagerSandboxDurationList.GetAt(2) as Location
	elseif afMarkerValue == -24
		return IMP_ProvisionerManagerSandboxDurationList.GetAt(3) as Location
	endif
EndFunction



;=======================
; FUNCTIONS USED BY COLLECTIONS
;=======================

Function ProvisionerOnLoad_PUBLIC(ObjectReference akProvisionerRef)
	ProvisionerLoadedCollection.AddRef(akProvisionerRef)
	ProvisionerBrahminCollection.AddRef((akProvisionerRef as WorkshopNPCScript).myBrahmin)
EndFunction

Function ProvisionerOnUnload_PUBLIC(ObjectReference akProvisionerRef)
	ProvisionerLoadedCollection.RemoveRef(akProvisionerRef)
	ProvisionerBrahminCollection.RemoveRef((akProvisionerRef as WorkshopNPCScript).myBrahmin)
EndFunction


;==============================
; FUNCTIONS USED BY WorkshopJobAssign Script
;==============================

Function AssignProvisionerToMarker_PUBLIC(ObjectReference akProvisionerRef, ObjectReference akMarkerRef)
	if akProvisionerRef && akMarkerRef
	
		if akProvisionerRef.HasKeyword(IMP.IMP_IsProvisioner)
		
			ActorNameAlias.ForceRefTo(akProvisionerRef)
			ObjectReference LinkedMarkerRef=akProvisionerRef.GetLinkedRef(IMP.IMP_LinkProvisionerMarker)
			ObjectReference SelectedMarkerRef=akMarkerRef

			if LinkedMarkerRef == NONE
				akProvisionerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkProvisionerMarker)
				Float CurrentGametime=Utility.GetCurrentGametime()
				Float MarkerSandboxDuration=GetSandboxDuration(SelectedMarkerRef)
				if akProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageEndDate) < CurrentGametime
					akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageEndDate, CurrentGametime+MarkerSandboxDuration)
				endif
				if akProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageStartDate) < CurrentGametime
					akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStartDate, CurrentGametime+MarkerSandboxDuration+IMP.IMP_ProvisionerStartNewSandboxPkgTimer.GetValue())
				endif
				akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStage, 2)
				(akProvisionerRef  as Actor).EvaluatePackage()

				LocationNameAlias.ForceLocationTo(SelectedMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
				Float SandboxEndDateMenu=(akProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageEndDate)-CurrentGametime)*24
				IMP_ProvisionerManagerProvisionerAssignSuccededMESGn.Show(SandboxEndDateMenu)
				

			elseif LinkedMarkerRef != SelectedMarkerRef
				;*** do this to reset IMP_LinkProvisionerMarker package target ***
				akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStage, -1)
				(akProvisionerRef  as Actor).EvaluatePackage()

				akProvisionerRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkProvisionerMarker)
				Float CurrentGametime=Utility.GetCurrentGametime()
				Float MarkerSandboxDuration=SelectedMarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)/24
				if akProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageEndDate) < CurrentGametime
					akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageEndDate, CurrentGametime+MarkerSandboxDuration)
				endif
				if akProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageStartDate) < CurrentGametime
					akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStartDate, CurrentGametime+MarkerSandboxDuration+IMP.IMP_ProvisionerStartNewSandboxPkgTimer.GetValue())
				endif
				akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStage, 2)
				(akProvisionerRef  as Actor).EvaluatePackage()

				LocationNameAlias.ForceLocationTo(SelectedMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword).GetCurrentLocation())
				Float SandboxEndDateMenu=(akProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageEndDate)-CurrentGametime)*24
				IMP_ProvisionerManagerProvisionerAssignSuccededMESGn.Show(SandboxEndDateMenu)
				

			elseif LinkedMarkerRef == SelectedMarkerRef
				Int iButton=IMP_ProvisionerManagerWantToUnassignMESGb.Show()
				if iButton==1
					akProvisionerRef.SetLinkedRef(NONE, IMP.IMP_LinkProvisionerMarker)
					akProvisionerRef.SetValue(IMP.IMP_ProvisionerPackageStage, 0)
					(akProvisionerRef  as Actor).EvaluatePackage()

					IMP_ProvisionerManagerUnassignSuccededMESGn.Show()
				endif
			endif
			
		else
		
			IMP_ProvisionerManagerProvisionerUnvalidMESGn.Show()
			
		endif
		
	endif
EndFunction



;============================
; FUNCTIONS USED BY PROVISIONER MARKER
;============================

Message property IMP_ProvisionerManagerMainMenu01MESGb auto const mandatory
Message property IMP_ProvisionerManagerMainMenu02MESGb auto const mandatory

Function ShowProvisionerMarkerMenu(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	ObjectReference WorkshopCenter=akWorkshopRef.GetLinkedRef(IMP.WorkshopLinkCenter)
	Int CaravanRouteCount=WorkshopCenter.CountRefsLinkedToMe(IMP.WorkshopLinkCaravanStart) + WorkshopCenter.CountRefsLinkedToMe(IMP.WorkshopLinkCaravanEnd)

	ObjectReference[] ProvisionerMarkerRefs=akWorkshopRef.GetRefsLinkedToMe(IMP.IMP_LinkProvisionermarkerWorkshop)
	Int ProvisionerMarkerCount=ProvisionerMarkerRefs.length

	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	Int MarkerIndex=ProvisionerMarkerRefs.Find(MarkerRef)+1

	Int LinkedProvisionerCount=MarkerRef.CountRefsLinkedToMe(IMP.IMP_LinkProvisionerMarker)

	LocationNameAlias.ForceLocationTo(akWorkshopRef.GetCurrentLocation())
	CurrentSandboxDurationValue=MarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
	Message ProvisionerManagerMainMenu
	if CurrentSandboxDurationValue <= 0
		DurationNameAlias.ForceLocationTo(GetSandboxDurationText(CurrentSandboxDurationValue))
		ProvisionerManagerMainMenu=IMP_ProvisionerManagerMainMenu01MESGb
	else
		ProvisionerManagerMainMenu=IMP_ProvisionerManagerMainMenu02MESGb
	endif


	Int iButton=ProvisionerManagerMainMenu.Show(CaravanRouteCount, ProvisionerMarkerCount, MarkerIndex, LinkedProvisionerCount, CurrentSandboxDurationValue)
	if iButton == 1
		ObjectReference[] ProvisionerRefsToCollection=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkProvisionerMarker)
		IMP.PIN.Pin_AddActorArrayToCollection_PUBLIC(ProvisionerRefsToCollection, akPositionerRef)

	elseif iButton == 2
		ShowProvisionerDurationMenu(akPositionerRef, akWorkshopRef)
	endif
EndFunction

Function ShowProvisionerMarkerMenu_PUBLIC(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	ShowProvisionerMarkerMenu(akPositionerRef, akWorkshopRef)
EndFunction


;---------

Float InitialSandboxDurationValue

Function ShowProvisionerDurationMenu(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	if akPositionerRef && akWorkshopRef

		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()


		LocationNameAlias.ForceLocationTo(akWorkshopRef.GetCurrentLocation())
		CurrentSandboxDurationValue=MarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
		DurationNameAlias.ForceLocationTo(GetSandboxDurationText(CurrentSandboxDurationValue))


		Message ProvisionerManagerSandboxDurationSettingMenu
		if CurrentSandboxDurationValue <= 0
			ProvisionerManagerSandboxDurationSettingMenu=IMP_ProvisionerManagerSandboxDurationSettingMenu01MESGb
		else
			ProvisionerManagerSandboxDurationSettingMenu=IMP_ProvisionerManagerSandboxDurationSettingMenu02MESGb
		endif


		Int iButton=ProvisionerManagerSandboxDurationSettingMenu.Show(CurrentSandboxDurationValue)
		if iButton==0
			ShowProvisionerMarkerMenu(akPositionerRef, akWorkshopRef)

		elseif iButton==1
			SetCustomDurationINIT(MarkerRef, akWorkshopRef)

		elseif iButton==2
			InitialSandboxDurationValue=MarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
			MarkerRef.SetValue(IMP.IMP_ProvisionerMarkerSandboxDuration, -6)
			UpdateDuration(MarkerRef)

		elseif iButton==3
			InitialSandboxDurationValue=MarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
			MarkerRef.SetValue(IMP.IMP_ProvisionerMarkerSandboxDuration, -12)
			UpdateDuration(MarkerRef)

		elseif iButton==4
			InitialSandboxDurationValue=MarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
			MarkerRef.SetValue(IMP.IMP_ProvisionerMarkerSandboxDuration, -18)
			UpdateDuration(MarkerRef)

		elseif iButton==5
			InitialSandboxDurationValue=MarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
			MarkerRef.SetValue(IMP.IMP_ProvisionerMarkerSandboxDuration, -24)
			UpdateDuration(MarkerRef)

		endif

	endif
EndFunction


;---------


Float TempCustomDuration
Bool bSetCustomDuration_cond Conditional
Message property IMP_ProvisionerManagerCustomDurationMenu01MESGb auto const mandatory
Message property IMP_ProvisionerManagerCustomDurationMenu02MESGb auto const mandatory

Function SetCustomDurationINIT(ObjectReference akMarkerRef, ObjectReference akWorkshopRef)
	TempCustomDuration=Math.Max(1, CurrentSandboxDurationValue)		
	SetCustomDuration(akMarkerRef, akWorkshopRef)
EndFunction

Function SetCustomDuration(ObjectReference akMarkerRef, ObjectReference akWorkshopRef)
	bSetCustomDuration_cond = TempCustomDuration==CurrentSandboxDurationValue

	int iButton

	if CurrentSandboxDurationValue <= 0
		iButton=IMP_ProvisionerManagerCustomDurationMenu01MESGb.Show(TempCustomDuration)
	else
		iButton=IMP_ProvisionerManagerCustomDurationMenu02MESGb.Show(CurrentSandboxDurationValue, TempCustomDuration)
	endif

	if iButton == 0
		TempCustomDuration=TempCustomDuration+1
		if TempCustomDuration > 24
			TempCustomDuration=1
		endif
		SetCustomDuration(akMarkerRef, akWorkshopRef)

	elseif iButton == 1
		TempCustomDuration=TempCustomDuration-1
		if TempCustomDuration < 1
			TempCustomDuration=24
		endif
		SetCustomDuration(akMarkerRef, akWorkshopRef)

	elseif iButton == 2
		InitialSandboxDurationValue=akMarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
		akMarkerRef.SetValue(IMP.IMP_ProvisionerMarkerSandboxDuration, TempCustomDuration)
		UpdateDuration(akMarkerRef)
		
	elseif iButton == 3
		ShowProvisionerMarkerMenu((akMarkerRef as IMPScriptMarker).GetPositionerRef(), akWorkshopRef)

	endif
EndFunction

;---------

Message property IMP_ProvisionerManagerWantToUpdateMarkerMESGb auto const mandatory

Function UpdateDuration(ObjectReference akMarkerRef)
	if akMarkerRef
		Float NewSandboxDurationValue=akMarkerRef.GetValue(IMP.IMP_ProvisionerMarkerSandboxDuration)
		if NewSandboxDurationValue != 0  &&  NewSandboxDurationValue != InitialSandboxDurationValue

			ObjectReference[] ProvisionerRefs=akMarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkProvisionerMarker)
			Int ProvisionerRefCount=ProvisionerRefs.length
			if ProvisionerRefCount > 0
				Int iButton=IMP_ProvisionerManagerWantToUpdateMarkerMESGb.Show(ProvisionerRefCount)
				if iButton == 1
					Int i=0
					while i < ProvisionerRefCount
						Actor iProvisionerRef=ProvisionerRefs[i] as Actor
						SetSandboxDuration(iProvisionerRef)
						(iProvisionerRef as WorkshopNPCScript).myBrahmin.EvaluatePackage()
						i+=1
					endwhile
				endif
			endif

		endif
	endif
EndFunction



;=========

Function ProvisionerMarkerOnPlaced_PUBLIC(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	if akPositionerRef && akWorkshopRef
		;*** wait marker is placed ***
		ObjectReference MarkerRef
		Float EndLoopTime=Utility.GetCurrentRealTime()+10
		Bool bEndLoop
		while MarkerRef == NONE && bEndLoop == False					
			if EndLoopTime > Utility.GetCurrentRealTime()
				MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
			else
				bEndLoop=True
				return
			endif					
		endwhile
		MarkerRef.SetValue(IMP.IMP_ProvisionerMarkerSandboxDuration, IMP.IMP_ProvisionerSandboxDurationDefault.GetValue())
		MarkerRef.SetLinkedRef(akWorkshopRef, IMP.IMP_LinkProvisionermarkerWorkshop)
		Int ProvisionerLoadedCollectionCount=ProvisionerLoadedCollection.GetCount()
		if ProvisionerLoadedCollectionCount > 0
			Int i=0
			while i < ProvisionerLoadedCollectionCount
				ObjectReference iProvisionerRef=ProvisionerLoadedCollection.GetAt(i)
				if iProvisionerRef.GetCurrentLocation() == akWorkshopRef.GetCurrentLocation()
					if iProvisionerRef.GetLinkedRef(IMP.IMP_LinkProvisionerMarker) == NONE
						SetProvisionerSandboxPackage(iProvisionerRef as Actor, bForceStartPackage=True)
					endif
				endif
				i+=1
			endwhile
		endif
	endif
EndFunction


Function ProvisionerMarkerOnMoved_PUBLIC()
	ProvisionerCollection.EvaluateAll()
EndFunction


Function ProvisionerMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	if MarkerRef
		MarkerRef.SetLinkedRef(NONE, IMP.IMP_LinkProvisionermarkerWorkshop)
		MarkerRef.DisableNoWait()
		MarkerRef.Delete()

		MarkerRef.MoveTo(TrashbinMarkerRef)
		while (MarkerRef.GetParentCell() != TrashbinMarkerRef.GetParentCell())
			;wait until marker is moved to holding cell
		endwhile

		Actor[] ProvisionerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkProvisionerMarker) as Actor[]
		Int ProvisionerRefCount=ProvisionerRefs.length
		if ProvisionerRefCount > 0
			Float CurrentGametime=Utility.GetCurrentGametime()
			Int i=0
			while i < ProvisionerRefCount
				Actor iProvisionerRef=ProvisionerRefs[i] as Actor
				if iProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageEndDate) >= CurrentGametime
					SetProvisionerSandboxPackage(iProvisionerRef, bForceStartPackage=True)
				else
					UnsetProvisionerSandboxPackage(iProvisionerRef)
				endif
				i+=1
			endwhile
		endif
	endif
EndFunction

;---------

Function ProvisionerMarkerOnLoad_PUBLIC(ObjectReference akMarkerRef)
	if akMarkerRef
		akMarkerRef.SetLinkedRef(akMarkerRef.GetLinkedRef(IMP.WorkshopItemKeyword), IMP.IMP_LinkProvisionermarkerWorkshop)
	endif
EndFunction


Function ProvisionerMarkerOnUnload_PUBLIC(ObjectReference akMarkerRef)
	if akMarkerRef
		akMarkerRef.SetLinkedRef(NONE, IMP.IMP_LinkProvisionermarkerWorkshop)
	endif
EndFunction



;=========================
;=========================
; SCRIPTS FOR PROVISIONER'S BRAHMIN
;=========================
;=========================

;=====================================
; FUNCTIONS USED BY PROVISIONER'S BRAHMIN PACKAGES
;=====================================

Function SetProvisionerbrahminSandboxPackage(Actor akActorRef)
	ObjectReference ProvisionerbrahminMarkerRef=Game.FindClosestReferenceOfType(IMP.IMP_Marker_ProvisionerbrahminMarker, akActorRef.GetPositionX(), akActorRef.GetPositionY(), akActorRef.GetPositionZ(), IMP.IMP_MarkerSearchMaxRadius.GetValue())

	if \
	ProvisionerbrahminMarkerRef && \
	ProvisionerbrahminMarkerRef.IsDisabled() == False && \
	ProvisionerbrahminMarkerRef.IsDeleted() == False
		akActorRef.SetLinkedRef(ProvisionerbrahminMarkerRef, IMP.IMP_LinkProvisionerbrahminMarker)
		akActorRef.SetValue(IMP.IMP_ProvisionerBrahminPackageStage, 1)
		akActorRef.EvaluatePackage()
	else
		akActorRef.SetValue(IMP.IMP_ProvisionerBrahminPackageStage, 2)
		akActorRef.EvaluatePackage()
	endif
EndFunction

Function SetProvisionerbrahminSandboxPackage_PUBLIC(Actor akActorRef)
	SetProvisionerbrahminSandboxPackage(akActorRef)
EndFunction

;---------

Function UnsetProvisionerbrahminSandboxPackage(Actor akActorRef)
	akActorRef.SetValue(IMP.IMP_ProvisionerBrahminPackageStage, 0)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkProvisionerbrahminMarker)
	akActorRef.EvaluatePackage()
EndFunction

Function UnsetProvisionerbrahminSandboxPackage_PUBLIC(Actor akActorRef)
	UnsetProvisionerbrahminSandboxPackage(akActorRef)
EndFunction



;=======================
; FUNCTIONS USED BY COLLECTIONS
;=======================

Function ProvisionerBrahminCommandModeGiveCommand_PUBLIC(ObjectReference akBrahminRef, int aeCommandType, ObjectReference akTarget)
	if aeCommandType == 10
		(akBrahminRef as Actor).SetCanDoCommand(False)
		AssignProvisionerBrahminToMarker_PUBLIC(akBrahminRef, akTarget)
	elseif aeCommandType != 0
		(akBrahminRef as Actor).SetCanDoCommand(False)
	endif
EndFunction


Function AssignProvisionerBrahminToMarker_PUBLIC(ObjectReference akBrahminRef, ObjectReference akMarkerRef)
	if akBrahminRef && akMarkerRef

		if akBrahminRef.HasKeyword(IMP.IMP_IsProvisionerBrahmin) == True
		
			ActorNameAlias.ForceRefTo(akBrahminRef)
			ObjectReference LinkedMarkerRef=akBrahminRef.GetLinkedRef(IMP.IMP_LinkProvisionerbrahminMarker)
			ObjectReference SelectedMarkerRef=akMarkerRef
			ObjectReference ProvisionerRef=akBrahminRef.GetLinkedRef(IMP.WorkshopLinkFollow)

			if ProvisionerRef == NONE
				IMP_ProvisionerManagerProvisionerBrahminUnlinkedMESGn.Show()			
			
			
			elseif \
			ProvisionerRef.GetLinkedRef(IMP.IMP_LinkProvisionerMarker) == NONE || \
			ProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageEndDate) < Utility.GetCurrentGametime() || \
			ProvisionerRef.HasKeyword(IMP.IMP_IsProvisioner) == False
				IMP_ProvisionerManagerProvisionerBrahminCantStopMESGn.Show()


			elseif LinkedMarkerRef == NONE
				akBrahminRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkProvisionerbrahminMarker)
				akBrahminRef.SetValue(IMP.IMP_ProvisionerBrahminPackageStage, 1)
				(akBrahminRef as Actor).EvaluatePackage()

				IMP_ProvisionerManagerProvisionerBrahminAssignSuccededMESGn.Show()
				

			elseif LinkedMarkerRef != SelectedMarkerRef
				;*** do this to reset IMP_LinkProvisionerbrahminMarker package target ***
				akBrahminRef.SetValue(IMP.IMP_ProvisionerBrahminPackageStage, -1)
				(akBrahminRef as Actor).EvaluatePackage()

				akBrahminRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkProvisionerbrahminMarker)
				akBrahminRef.SetValue(IMP.IMP_ProvisionerBrahminPackageStage, 1)
				(akBrahminRef as Actor).EvaluatePackage()

				IMP_ProvisionerManagerProvisionerBrahminAssignSuccededMESGn.Show()
				

			elseif LinkedMarkerRef == SelectedMarkerRef
				Int iButton=IMP_ProvisionerManagerWantToUnassignMESGb.Show()
				if iButton==1
					akBrahminRef.SetLinkedRef(NONE, IMP.IMP_LinkProvisionerbrahminMarker)
					akBrahminRef.SetValue(IMP.IMP_ProvisionerBrahminPackageStage, 0)
					(akBrahminRef as Actor).EvaluatePackage()

					IMP_ProvisionerManagerUnassignSuccededMESGn.Show()
				endif
			endif
			
		else
		
			IMP_ProvisionerManagerProvisionerbrahminUnvalidMESGn.Show()
		
		endif

	endif
EndFunction



;===================================
; FUNCTIONS USED BY PROVISIONER'S BRAHMIN MARKER
;===================================

Function ProvisionerbrahminMarkerOnPlaced_PUBLIC(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	if akPositionerRef && akWorkshopRef
		Int ProvisionerBrahminCollectionCount=ProvisionerBrahminCollection.GetCount()
		if ProvisionerBrahminCollectionCount > 0
			Int i=0
			while i < ProvisionerBrahminCollectionCount
				ObjectReference iProvisionerBrahminRef=ProvisionerBrahminCollection.GetAt(i)
				if iProvisionerBrahminRef.GetCurrentLocation() == akWorkshopRef.GetCurrentLocation()
					ObjectReference iProvisionerRef=iProvisionerBrahminRef.GetLinkedRef(IMP.WorkshopLinkFollow)
					if iProvisionerRef.GetValue(IMP.IMP_ProvisionerPackageStage) == 2
						SetProvisionerBrahminSandboxPackage(iProvisionerBrahminRef as Actor)
					endif
				endif
				i+=1
			endwhile
		endif
	endif
EndFunction


Function ProvisionerbrahminMarkerOnMoved_PUBLIC()
	ProvisionerbrahminCollection.EvaluateAll()
EndFunction


Function ProvisionerbrahminMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	if MarkerRef
		MarkerRef.DisableNoWait()
		MarkerRef.Delete()
		
		MarkerRef.MoveTo(TrashbinMarkerRef)
		while (MarkerRef.GetParentCell() != TrashbinMarkerRef.GetParentCell())
			;wait until marker is moved to holding cell
		endwhile

		Actor[] ProvisionerbrahminRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkProvisionerbrahminMarker) as Actor[]
		Int ProvisionerbrahminRefCount=ProvisionerbrahminRefs.length
		if ProvisionerbrahminRefCount > 0
			Int i=0
			while i < ProvisionerbrahminRefCount
				Actor iProvisionerbrahminRef=ProvisionerbrahminRefs[i] as Actor
				UnsetProvisionerbrahminSandboxPackage(iProvisionerbrahminRef)
				i+=1
			endwhile
		endif
	endif
EndFunction