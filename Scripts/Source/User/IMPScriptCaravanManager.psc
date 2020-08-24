Scriptname IMPScriptCaravanManager extends Quest Conditional

RefCollectionAlias property CaravanleaderCollection auto const mandatory
RefCollectionAlias property CaravanguardCollection auto const mandatory
RefCollectionAlias property CaravanbrahminCollection auto const mandatory
ReferenceAlias property LucasMillerAlias auto const mandatory
ReferenceAlias property DocWeathersAlias auto const mandatory
ReferenceAlias property CarlaAlias auto const mandatory
ReferenceAlias property CricketAlias auto const mandatory
ReferenceAlias property ActorNameAlias auto const mandatory
Message property IMP_CaravanManagerAssignSuccededMESGn auto const mandatory
Message property IMP_CaravanManagerUnassignSuccededMESGn auto const mandatory
Message property IMP_CaravanManagerWantToUnassignMESGb auto const mandatory
Message property IMP_CaravanManagerBrahminUnvalidMESGn auto const mandatory
Message property IMP_CaravanManagerGuardUnvalidMESGn auto const mandatory
Message property IMP_CaravanManagerLeaderUnvalidMESGn auto const mandatory
ObjectReference property TrashbinMarkerRef auto const mandatory

IMPScriptMain IMP

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent


;================================
; FUNCTIONS USED BY CARAVAN LEADER PACKAGES
;================================

Function SetCaravanleaderSandboxPackage(Actor akActorRef)
	ObjectReference CaravanleaderMarkerRef=Game.FindClosestReferenceOfType(IMP.IMP_Marker_CaravanleaderMarker, akActorRef.GetPositionX(), akActorRef.GetPositionY(), akActorRef.GetPositionZ(), IMP.IMP_MarkerSearchMaxRadius.GetValue())

	if \
	CaravanleaderMarkerRef && \
	CaravanleaderMarkerRef.IsDisabled() == False && \
	CaravanleaderMarkerRef.IsDeleted() == False
		akActorRef.SetLinkedRef(CaravanleaderMarkerRef, IMP.IMP_LinkCaravanleaderMarker)
		akActorRef.SetValue(IMP.IMP_CaravanPackageStage, 1)
		akActorRef.EvaluatePackage()
	else
		akActorRef.SetValue(IMP.IMP_CaravanPackageStage, -1)
		akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanleaderMarker)
		akActorRef.EvaluatePackage()
	endif
EndFunction

Function SetCaravanleaderSandboxPackage_PUBLIC(Actor akActorRef)
	SetCaravanleaderSandboxPackage(akActorRef)
EndFunction

;---------

Function UnsetCaravanleaderSandboxPackage(Actor akActorRef)
	akActorRef.SetValue(IMP.IMP_CaravanPackageStage, 0)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanleaderMarker)
	akActorRef.EvaluatePackage()
EndFunction

Function UnsetCaravanleaderSandboxPackage_PUBLIC(Actor akActorRef)
	UnsetCaravanleaderSandboxPackage(akActorRef)
EndFunction



;=============================
; FUNCTIONS USED BY CARAVAN LEADER ALIAS
;=============================

Function CaravanleaderAliasOnLoad(ObjectReference akCaravanLeaderRef)
	if akCaravanLeaderRef.Is3DLoaded()
		Location CurrentLocation=akCaravanLeaderRef.GetCurrentLocation()
		if \
		CurrentLocation != IMP.BunkerHillLocation && \
		CurrentLocation.HasKeyword(IMP.LocTypeWorkshop) == True
			CaravanleaderCollection.AddRef(akCaravanLeaderRef)
		endif
	endif
EndFunction

Function HandleFollowersOnLoad(ObjectReference akCaravanLeaderRef, ReferenceAlias akAlias01, ReferenceAlias akAlias02=NONE, ReferenceAlias akAlias03=NONE)
	if akCaravanLeaderRef.Is3DLoaded()
		Cell PlayerCurrentCell=Game.GetPlayer().GetParentCell()

		ObjectReference Ref01=akAlias01.GetReference()
		if \
		Ref01.GetParentCell() != PlayerCurrentCell
		Ref01.IsNearPlayer() == False
			Ref01.MoveTo(akCaravanLeaderRef)
		endif

		ObjectReference Ref02=akAlias02.GetReference()
		if \
		Ref02.GetParentCell() != PlayerCurrentCell
		Ref02.IsNearPlayer() == False
			Ref01.MoveTo(akCaravanLeaderRef)
		endif

		ObjectReference Ref03=akAlias01.GetReference()
		if \
		Ref03.GetParentCell() != PlayerCurrentCell
		Ref03.IsNearPlayer() == False
			Ref03.MoveTo(akCaravanLeaderRef)
		endif
	endif
EndFunction


Function CaravanleaderAliasOnUnload(ObjectReference akCaravanLeaderRef)
	if (akCaravanLeaderRef.GetCurrentLocation().HasKeyword(IMP.LocTypeWorkshop)) == False
		UnsetCaravanleaderSandboxPackage_PUBLIC(akCaravanLeaderRef as Actor)
		CaravanleaderCollection.RemoveRef(akCaravanLeaderRef)
	endif
EndFunction

Function AssignCaravanleaderToMarker_PUBLIC(ObjectReference akCaravanleaderRef, ObjectReference akMarkerRef)
	if akCaravanleaderRef && akMarkerRef
	
		if akCaravanleaderRef.HasKeyword(IMP.IMP_IsCaravanLeader) == True

			ActorNameAlias.ForceRefTo(akCaravanleaderRef)
			ObjectReference LinkedMarkerRef=akCaravanleaderRef.GetLinkedRef(IMP.IMP_LinkCaravanleaderMarker)
			ObjectReference SelectedMarkerRef=akMarkerRef

			if LinkedMarkerRef == NONE
				akCaravanleaderRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkCaravanleaderMarker)
				akCaravanleaderRef.SetValue(IMP.IMP_CaravanPackageStage, 2)
				(akCaravanleaderRef as Actor).EvaluatePackage()
				IMP_CaravanManagerAssignSuccededMESGn.Show()

			elseif LinkedMarkerRef != SelectedMarkerRef
				;*** do this to reset IMP_LinkCaravanleaderMarker package target ***
				akCaravanleaderRef.SetValue(IMP.IMP_CaravanPackageStage, -2)
				(akCaravanleaderRef as Actor).EvaluatePackage()

				akCaravanleaderRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkCaravanleaderMarker)
				akCaravanleaderRef.SetValue(IMP.IMP_CaravanPackageStage, 2)
				(akCaravanleaderRef as Actor).EvaluatePackage()
				IMP_CaravanManagerAssignSuccededMESGn.Show()

			elseif LinkedMarkerRef == SelectedMarkerRef
				Int iButton=IMP_CaravanManagerWantToUnassignMESGb.Show()
				if iButton==1
					akCaravanleaderRef.SetValue(IMP.IMP_CaravanPackageStage, 0)
					akCaravanleaderRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanleaderMarker)
					(akCaravanleaderRef as Actor).EvaluatePackage()
					IMP_CaravanManagerUnassignSuccededMESGn.Show()
				endif
			endif
			
		else
		
			IMP_CaravanManagerLeaderUnvalidMESGn.Show()
		
		endif

	endif
EndFunction



;===============================
; FUNCTIONS USED BY CARAVAN LEADER MARKER
;===============================

Function CaravanleaderMarkerOnPlaced_PUBLIC(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	if akPositionerRef && akWorkshopRef
		Location MarkerLocation=akWorkshopRef.GetCurrentLocation()
		Int CaravanleaderCollectionCount=CaravanleaderCollection.GetCount()
		Int i=0
		while i < CaravanleaderCollectionCount
			Actor iCaravanleaderRef=CaravanleaderCollection.GetAt(i) as Actor
			if \
			iCaravanleaderRef.Is3DLoaded() == True && \
			iCaravanleaderRef.IsDead() == False && \
			iCaravanleaderRef.GetCurrentLocation() == MarkerLocation && \
			iCaravanleaderRef.GetLinkedRef(IMP.IMP_LinkCaravanleaderMarker) == NONE && \
			MarkerLocation != IMP.BunkerHillLocation && \
			MarkerLocation.HasKeyword(IMP.LocTypeWorkshop) == True
				SetCaravanleaderSandboxPackage(iCaravanleaderRef)
			endif

			i+=1
		endwhile
	endif
EndFunction


Function CaravanleaderMarkerOnMoved_PUBLIC()
	CaravanleaderCollection.EvaluateAll()
EndFunction


Function CaravanleaderMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	if MarkerRef
		MarkerRef.DisableNoWait()
		MarkerRef.Delete()

		MarkerRef.MoveTo(TrashbinMarkerRef)
		while (MarkerRef.GetParentCell() != TrashbinMarkerRef.GetParentCell())
			;wait until marker is moved to holding cell
		endwhile

		Actor[] CaravanleaderRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkCaravanleaderMarker) as Actor[]
		Int CaravanleaderRefCount=CaravanleaderRefs.length
		if CaravanleaderRefCount > 0
			Int i=0
			while i < CaravanleaderRefCount
				Actor iCaravanleaderRef=CaravanleaderRefs[i] as Actor
				UnsetCaravanleaderSandboxPackage(iCaravanleaderRef)
				i+=1
			endwhile
		endif
	endif
EndFunction



;================================
;================================
; FUNCTIONS USED BY CARAVAN GUARD PACKAGES
;================================
;================================

Function SetCaravanguardSandboxPackage(Actor akActorRef)
	ObjectReference CaravanguardMarkerRef=Game.FindClosestReferenceOfType(IMP.IMP_Marker_CaravanguardMarker, akActorRef.GetPositionX(), akActorRef.GetPositionY(), akActorRef.GetPositionZ(), IMP.IMP_MarkerSearchMaxRadius.GetValue())

	if \
	CaravanguardMarkerRef && \
	CaravanguardMarkerRef.IsDisabled() == False && \
	CaravanguardMarkerRef.IsDeleted() == False
		akActorRef.SetLinkedRef(CaravanguardMarkerRef, IMP.IMP_LinkCaravanguardMarker)
		akActorRef.SetValue(IMP.IMP_CaravanPackageStage, 1)
		akActorRef.EvaluatePackage()
	else
		akActorRef.SetValue(IMP.IMP_CaravanPackageStage, -1)
			akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanguardMarker)
		akActorRef.EvaluatePackage()
	endif
EndFunction

Function SetCaravanguardSandboxPackage_PUBLIC(Actor akActorRef)
	SetCaravanguardSandboxPackage(akActorRef)
EndFunction

;---------

Function UnsetCaravanguardSandboxPackage(Actor akActorRef)
	akActorRef.SetValue(IMP.IMP_CaravanPackageStage, 0)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanguardMarker)
	akActorRef.EvaluatePackage()
EndFunction

Function UnsetCaravanguardSandboxPackage_PUBLIC(Actor akActorRef)
	UnsetCaravanguardSandboxPackage(akActorRef)
EndFunction



;=============================
; FUNCTIONS USED BY CARAVAN GUARD ALIAS
;=============================

Function CaravanguardAliasOnLoad(ObjectReference akCaravanGuardRef)
	if akCaravanGuardRef.Is3DLoaded()
		Location CurrentLocation=akCaravanGuardRef.GetCurrentLocation()
		if \
		CurrentLocation != IMP.BunkerHillLocation && \
		CurrentLocation.HasKeyword(IMP.LocTypeWorkshop) == True
			CaravanguardCollection.AddRef(akCaravanGuardRef)
		endif
	endif
EndFunction

Function CaravanguardAliasOnUnload(ObjectReference akCaravanGuardRef)
	if (akCaravanGuardRef.GetCurrentLocation().HasKeyword(IMP.LocTypeWorkshop)) == False
		UnsetCaravanguardSandboxPackage_PUBLIC(akCaravanGuardRef as Actor)
		CaravanguardCollection.RemoveRef(akCaravanGuardRef)
	endif
EndFunction

Function AssignCaravanguardToMarker_PUBLIC(ObjectReference akCaravanguardRef, ObjectReference akMarkerRef)
	if akCaravanguardRef && akMarkerRef
	
		if akCaravanguardRef.HasKeyword(IMP.IMP_IsCaravanguard) == True
			ActorNameAlias.ForceRefTo(akCaravanguardRef)
			ObjectReference LinkedMarkerRef=akCaravanguardRef.GetLinkedRef(IMP.IMP_LinkCaravanguardMarker)
			ObjectReference SelectedMarkerRef=akMarkerRef

			if LinkedMarkerRef == NONE
				akCaravanguardRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkCaravanguardMarker)
				akCaravanguardRef.SetValue(IMP.IMP_CaravanPackageStage, 1)
				(akCaravanguardRef as Actor).EvaluatePackage()
				IMP_CaravanManagerAssignSuccededMESGn.Show()

			elseif LinkedMarkerRef != SelectedMarkerRef
				;*** do this to reset IMP_LinkCaravanguardMarker package target ***
				akCaravanguardRef.SetValue(IMP.IMP_CaravanPackageStage, -2)
				(akCaravanguardRef as Actor).EvaluatePackage()

				akCaravanguardRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkCaravanguardMarker)
				akCaravanguardRef.SetValue(IMP.IMP_CaravanPackageStage, 1)
				(akCaravanguardRef as Actor).EvaluatePackage()
				IMP_CaravanManagerAssignSuccededMESGn.Show()

			elseif LinkedMarkerRef == SelectedMarkerRef
				Int iButton=IMP_CaravanManagerWantToUnassignMESGb.Show()
				if iButton==1
					akCaravanguardRef.SetValue(IMP.IMP_CaravanPackageStage, 0)
					akCaravanguardRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanguardMarker)
					(akCaravanguardRef as Actor).EvaluatePackage()
					IMP_CaravanManagerUnassignSuccededMESGn.Show()
				endif
			endif			
		
		else
		
			IMP_CaravanManagerGuardUnvalidMESGn.Show()

		endif

	endif
EndFunction



;==============================
; FUNCTIONS USED BY CARAVAN GUARD MARKER
;==============================

Function CaravanguardMarkerOnPlaced_PUBLIC(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	if akPositionerRef && akWorkshopRef
		Location MarkerLocation=akWorkshopRef.GetCurrentLocation()
		Int CaravanguardCollectionCount=CaravanguardCollection.GetCount()
		Int i=0
		while i < CaravanguardCollectionCount
			Actor iCaravanguardRef=CaravanguardCollection.GetAt(i) as Actor
			if \
			iCaravanguardRef.Is3DLoaded() == True && \
			iCaravanguardRef.IsDead() == False && \
			iCaravanguardRef.GetCurrentLocation() == MarkerLocation && \
			iCaravanguardRef.GetLinkedRef(IMP.IMP_LinkCaravanguardMarker) == NONE && \
			MarkerLocation != IMP.BunkerHillLocation && \
			MarkerLocation.HasKeyword(IMP.LocTypeWorkshop) == True


				if iCaravanguardRef.IsInFaction(IMP.CaravanVendorCarlaFaction)
					if CarlaAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanguardSandboxPackage(iCaravanguardRef)
					endif

				elseif iCaravanguardRef.IsInFaction(IMP.CaravanVendorCricketFaction)
					if CricketAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanguardSandboxPackage(iCaravanguardRef)
					endif

				elseif iCaravanguardRef.IsInFaction(IMP.CaravanVendorDocWeathersFaction)
					if DocWeathersAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanguardSandboxPackage(iCaravanguardRef)
					endif

				elseif iCaravanguardRef.IsInFaction(IMP.CaravanVendorLucasFaction)
					if LucasMillerAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanguardSandboxPackage(iCaravanguardRef)
					endif
				endif


			endif

			i+=1
		endwhile
	endif
EndFunction


Function CaravanguardMarkerOnMoved_PUBLIC()
	CaravanguardCollection.EvaluateAll()
EndFunction


Function CaravanguardMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	if MarkerRef
		MarkerRef.DisableNoWait()
		MarkerRef.Delete()

		MarkerRef.MoveTo(TrashbinMarkerRef)
		while (MarkerRef.GetParentCell() != TrashbinMarkerRef.GetParentCell())
			;wait until marker is moved to holding cell
		endwhile

		Actor[] CaravanguardRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkCaravanguardMarker) as Actor[]
		Int CaravanguardRefCount=CaravanguardRefs.length
		if CaravanguardRefCount > 0
			Int i=0
			while i < CaravanguardRefCount
				Actor iCaravanguardRef=CaravanguardRefs[i] as Actor
				UnsetCaravanguardSandboxPackage(iCaravanguardRef)
				i+=1
			endwhile
		endif
	endif
EndFunction



;=================================
;=================================
; FUNCTIONS USED BY CARAVAN BRAHMIN PACKAGES
;=================================
;=================================

Function SetCaravanbrahminSandboxPackage(Actor akActorRef)
	ObjectReference CaravanbrahminMarkerRef=Game.FindClosestReferenceOfType(IMP.IMP_Marker_CaravanbrahminMarker, akActorRef.GetPositionX(), akActorRef.GetPositionY(), akActorRef.GetPositionZ(), IMP.IMP_MarkerSearchMaxRadius.GetValue())

	if \
	CaravanbrahminMarkerRef && \
	CaravanbrahminMarkerRef.IsDisabled() == False && \
	CaravanbrahminMarkerRef.IsDeleted() == False
		akActorRef.SetLinkedRef(CaravanbrahminMarkerRef, IMP.IMP_LinkCaravanbrahminMarker)
		akActorRef.SetValue(IMP.IMP_CaravanPackageStage, 1)
		akActorRef.EvaluatePackage()
	else
		akActorRef.SetValue(IMP.IMP_CaravanPackageStage, -1)
		akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanbrahminMarker)
		akActorRef.EvaluatePackage()
	endif
EndFunction

Function SetCaravanbrahminSandboxPackage_PUBLIC(Actor akActorRef)
	SetCaravanbrahminSandboxPackage(akActorRef)
EndFunction

;---------

Function UnsetCaravanbrahminSandboxPackage(Actor akActorRef)
	akActorRef.SetValue(IMP.IMP_CaravanPackageStage, 0)
	akActorRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanbrahminMarker)
	akActorRef.EvaluatePackage()
EndFunction

Function UnsetCaravanbrahminSandboxPackage_PUBLIC(Actor akActorRef)
	UnsetCaravanbrahminSandboxPackage(akActorRef)
EndFunction



;==============================
; FUNCTIONS USED BY CARAVAN BRAHMIN ALIAS
;==============================

Function CaravanbrahminAliasOnLoad(ObjectReference akCaravanbrahminRef)
	if akCaravanbrahminRef.Is3DLoaded()
		Location CurrentLocation=akCaravanbrahminRef.GetCurrentLocation()
		if \
		CurrentLocation != IMP.BunkerHillLocation && \
		CurrentLocation.HasKeyword(IMP.LocTypeWorkshop) == True
			CaravanbrahminCollection.AddRef(akCaravanbrahminRef)
		endif
	endif
EndFunction

Function CaravanbrahminAliasOnUnload(ObjectReference akCaravanbrahminRef)
	if (akCaravanbrahminRef.GetCurrentLocation().HasKeyword(IMP.LocTypeWorkshop)) == False
		UnsetCaravanbrahminSandboxPackage_PUBLIC(akCaravanbrahminRef as Actor)
		CaravanbrahminCollection.RemoveRef(akCaravanbrahminRef)
	endif
EndFunction

Function AssignCaravanbrahminToMarker_PUBLIC(ObjectReference akCaravanbrahminRef, ObjectReference akMarkerRef)
	if akCaravanbrahminRef && akMarkerRef

		if akCaravanbrahminRef.HasKeyword(IMP.IMP_IsCaravanbrahmin) == True

				ActorNameAlias.ForceRefTo(akCaravanbrahminRef)
				ObjectReference LinkedMarkerRef=akCaravanbrahminRef.GetLinkedRef(IMP.IMP_LinkCaravanbrahminMarker)
				ObjectReference SelectedMarkerRef=akMarkerRef

				if LinkedMarkerRef == NONE
					akCaravanbrahminRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkCaravanbrahminMarker)
					akCaravanbrahminRef.SetValue(IMP.IMP_CaravanPackageStage, 1)
					(akCaravanbrahminRef as Actor).EvaluatePackage()
					IMP_CaravanManagerAssignSuccededMESGn.Show()

				elseif LinkedMarkerRef != SelectedMarkerRef
					;*** do this to reset IMP_LinkCaravanbrahminMarker package target ***
					akCaravanbrahminRef.SetValue(IMP.IMP_CaravanPackageStage, -2)
					(akCaravanbrahminRef as Actor).EvaluatePackage()

					akCaravanbrahminRef.SetLinkedRef(SelectedMarkerRef, IMP.IMP_LinkCaravanbrahminMarker)
					akCaravanbrahminRef.SetValue(IMP.IMP_CaravanPackageStage, 1)
					(akCaravanbrahminRef as Actor).EvaluatePackage()
					IMP_CaravanManagerAssignSuccededMESGn.Show()

				elseif LinkedMarkerRef == SelectedMarkerRef
					Int iButton=IMP_CaravanManagerWantToUnassignMESGb.Show()
					if iButton==1
						akCaravanbrahminRef.SetValue(IMP.IMP_CaravanPackageStage, 0)
						akCaravanbrahminRef.SetLinkedRef(NONE, IMP.IMP_LinkCaravanbrahminMarker)
						(akCaravanbrahminRef as Actor).EvaluatePackage()
						IMP_CaravanManagerUnassignSuccededMESGn.Show()
					endif
				endif
			
		else
		
			IMP_CaravanManagerBrahminUnvalidMESGn.Show()

		endif
		
	endif
EndFunction



;===============================
; FUNCTIONS USED BY CARAVAN BRAHMIN MARKER
;===============================

Function CaravanbrahminMarkerOnPlaced_PUBLIC(ObjectReference akPositionerRef, ObjectReference akWorkshopRef)
	if akPositionerRef && akWorkshopRef
		Location MarkerLocation=akWorkshopRef.GetCurrentLocation()
		Int CaravanbrahminCollectionCount=CaravanbrahminCollection.GetCount()
		Int i=0
		while i < CaravanbrahminCollectionCount
			Actor iCaravanbrahminRef=CaravanbrahminCollection.GetAt(i) as Actor
			if \
			iCaravanbrahminRef.Is3DLoaded() == True && \
			iCaravanbrahminRef.IsDead() == False && \
			iCaravanbrahminRef.GetCurrentLocation() == MarkerLocation && \
			iCaravanbrahminRef.GetLinkedRef(IMP.IMP_LinkCaravanbrahminMarker) == NONE && \
			MarkerLocation != IMP.BunkerHillLocation && \
			MarkerLocation.HasKeyword(IMP.LocTypeWorkshop) == True


				if iCaravanbrahminRef.IsInFaction(IMP.CaravanVendorCarlaFaction)
					if CarlaAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanbrahminSandboxPackage(iCaravanbrahminRef)
					endif

				elseif iCaravanbrahminRef.IsInFaction(IMP.CaravanVendorCricketFaction)
					if CricketAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanbrahminSandboxPackage(iCaravanbrahminRef)
					endif

				elseif iCaravanbrahminRef.IsInFaction(IMP.CaravanVendorDocWeathersFaction)
					if DocWeathersAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanbrahminSandboxPackage(iCaravanbrahminRef)
					endif

				elseif iCaravanbrahminRef.IsInFaction(IMP.CaravanVendorLucasFaction)
					if LucasMillerAlias.GetReference().GetValue(IMP.IMP_CaravanPackageStage) == 2
						SetCaravanbrahminSandboxPackage(iCaravanbrahminRef)
					endif
				endif


			endif

			i+=1
		endwhile
	endif
EndFunction


Function CaravanbrahminMarkerOnMoved_PUBLIC()
	CaravanbrahminCollection.EvaluateAll()
EndFunction


Function CaravanbrahminMarkerOnDestroyed_PUBLIC(ObjectReference akPositionerRef)
	ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()
	if MarkerRef
		MarkerRef.DisableNoWait()
		MarkerRef.Delete()
		
		MarkerRef.MoveTo(TrashbinMarkerRef)
		while (MarkerRef.GetParentCell() != TrashbinMarkerRef.GetParentCell())
			;wait until marker is moved to holding cell
		endwhile

		Actor[] CaravanbrahminRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkCaravanbrahminMarker) as Actor[]
		Int CaravanbrahminRefCount=CaravanbrahminRefs.length
		if CaravanbrahminRefCount > 0
			Int i=0
			while i < CaravanbrahminRefCount
				Actor iCaravanbrahminRef=CaravanbrahminRefs[i] as Actor
				UnsetCaravanbrahminSandboxPackage(iCaravanbrahminRef)
				i+=1
			endwhile
		endif
	endif
EndFunction



;=================================
;=================================
; FUNCTIONS USED BY SHOW MENU MARKER
;=================================
;=================================

Message property IMP_CaravanManagerLeaderMarkerEntryMenuMESGb auto const mandatory
Message property IMP_CaravanManagerGuardMarkerEntryMenuMESGb auto const mandatory
Message property IMP_CaravanManagerBrahminMarkerEntryMenuMESGb auto const mandatory
Int ActorLinkedToSandboxMarkerCount_cond Conditional

Function ShowCaravanSandboxActorMarkerMenu(ObjectReference akPositionerRef)
	if akPositionerRef
		ObjectReference MarkerRef=(akPositionerRef as IMPScriptPositioner).GetMarkerRef()


		ObjectReference[] ActorLinkedToSandboxMarkerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkSettlerRestrictedsandboxmarker)
		Message CaravanManagerMarkerEntryMenu

		if akPositionerRef.HasKeyword(IMP.IMP_IsCaravanLeaderPositioner)
			ActorLinkedToSandboxMarkerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkCaravanleaderMarker)
			CaravanManagerMarkerEntryMenu=IMP_CaravanManagerLeaderMarkerEntryMenuMESGb
		elseif akPositionerRef.HasKeyword(IMP.IMP_IsCaravanGuardPositioner)
			ActorLinkedToSandboxMarkerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkCaravanguardMarker)
			CaravanManagerMarkerEntryMenu=IMP_CaravanManagerGuardMarkerEntryMenuMESGb
		elseif akPositionerRef.HasKeyword(IMP.IMP_IsCaravanBrahminPositioner)
			ActorLinkedToSandboxMarkerRefs=MarkerRef.GetRefsLinkedToMe(IMP.IMP_LinkCaravanbrahminMarker)
			CaravanManagerMarkerEntryMenu=IMP_CaravanManagerBrahminMarkerEntryMenuMESGb
		endif
	
		ActorLinkedToSandboxMarkerCount_cond=ActorLinkedToSandboxMarkerRefs.length
	
	
		Int iButton=CaravanManagerMarkerEntryMenu.Show(ActorLinkedToSandboxMarkerCount_cond)
		if iButton==1
			IMP.Pin.Pin_AddActorArrayToCollection_PUBLIC(ActorLinkedToSandboxMarkerRefs, akPositionerRef)
		endif
	endif
EndFunction

Function ShowCaravanSandboxActorMarkerMenu_PUBLIC(ObjectReference akPositionerRef)
	ShowCaravanSandboxActorMarkerMenu(akPositionerRef)
EndFunction