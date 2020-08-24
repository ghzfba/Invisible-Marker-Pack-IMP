Scriptname IMPScriptWorkshopJobAssigning extends Quest

Message property IMP_WorkshopJobAssigningSuccededMESGn auto const mandatory
IMPScriptMain IMP

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent



;=========================================
; FUNCTIONS USED BY SettlerCommandModeGiveCommand_PUBLIC
;=========================================

function AssignActorToObject(WorkshopNPCScript assignedActor, WorkshopObjectScript assignedObject, bool bResetMode = false, bool bAddActorCheck = true)
	WorkshopScript workshopRef
	if assignedObject.workshopID > -1
		workshopRef = IMP.WorkshopParent.GetWorkshop(assignedObject.workshopID)
	endif
	if workshopRef == NONE
		return
	endif

	; make sure I'm added to this workshop
	if bAddActorCheck
		IMP.WorkshopParent.AddActorToWorkshop(assignedActor, workshopRef, bResetMode)
	endif

	; get object's current owner
	WorkshopNPCScript previousOwner = assignedObject.GetAssignedActor()

	if assignedObject.HasKeyword(IMP.WorkshopParent.WorkshopWorkObject)
		; work object
		; actor no longer counts as "new"
		assignedActor.bNewSettler = false

		; is object already assigned to this actor?
		bool bAlreadyAssigned = (previousOwner == assignedActor)

		; unassign actor from whatever he was doing
		actorValue multiResourceValue = assignedActor.assignedMultiResource

		; if assigned actor is assigned to multi-resource, AND this has that resource, don't unassign him - can work on multiple resource objects
		bool bShouldUnassign = true
		if (multiResourceValue && assignedObject.HasResourceValue(multiResourceValue))
			; same multi resource - may not need to unassign if actor has enough unused resource points left
			float totalProduction = assignedActor.multiResourceProduction + assignedObject.GetResourceRating(multiResourceValue)
			int resourceIndex = IMP.WorkshopParent.GetResourceIndex(multiResourceValue)

			if totalProduction <= IMP.WorkshopParent.WorkshopRatings[resourceIndex].maxProductionPerNPC
				bShouldUnassign = false
				; don't unassign - can work on multiple resource objects
			endif
		elseif bAlreadyAssigned
			; already assigned
			bShouldUnassign = false
		endif

		if bShouldUnassign
			UnassignActor(assignedActor, bSendUnassignEvent = !bAlreadyAssigned)
		endif

		; unassign current owner, if any (and different from new owner)
		if previousOwner && previousOwner != assignedActor
			IMP.WorkshopParent.UnassignActorFromObject(previousOwner, assignedObject)
		endif

		; mark assigned object as assigned to this actor
		assignedObject.AssignActor(assignedActor)

		; flag actor as a worker
		assignedActor.SetWorker(true)

		; 1.5 - new 24-hour work flag
		if assignedObject.bWork24Hours
			assignedActor.bWork24Hours = true 
		endif

		; if assigned object has scavenge rating, flag worker as scavenger (for packages)
		if assignedObject.HasResourceValue(IMP.WorkshopParent.WorkshopRatings[IMP.WorkshopParent.WorkshopRatingScavengeGeneral].resourceValue)
			assignedActor.SetScavenger(true)
		endif

		; add vendor faction if any
		if assignedObject.VendorType > -1
			IMP.WorkshopParent.SetVendorData(workshopRef, assignedActor, assignedObject)
		endif

		; update workshop ratings for new assignment
		IMP.WorkshopParent.UpdateWorkshopRatingsForResourceObject(assignedObject, workshopRef)

		; remove "unassigned" resource value
		assignedActor.SetValue(IMP.WorkshopParent.WorkshopRatings[IMP.WorkshopParent.WorkshopRatingPopulationUnassigned].resourceValue, 0)

		; to save time, in reset mode we ignore this and do it at the end
		if !bResetMode
			; reset unassigned population count
			IMP.WorkshopParent.SetUnassignedPopulationRating(workshopRef)
		endif

		; special cases:
		; is this a multi-resource object?
		if assignedObject.HasMultiResource()
			multiResourceValue = assignedObject.GetMultiResourceValue()
			; flag actor with this keyword
			assignedActor.SetMultiResource(multiResourceValue)
			assignedActor.AddMultiResourceProduction(assignedObject.GetResourceRating(multiResourceValue))
			if !bResetMode
				IMP.WorkshopParent.TryToAssignResourceType(workshopRef, multiResourceValue)				
			endif
		endif

		; reset ai to get him to notice the new markers
		assignedActor.EvaluatePackage()

		; send custom event for this object
		; don't send event in reset mode, or if already assigned to this actor
		if bAlreadyAssigned == false
			Var[] kargs = new Var[2]
			kargs[0] = assignedObject
			kargs[1] = workshopRef
			IMP.WorkshopParent.SendCustomEvent("WorkshopActorAssignedToWork", kargs)

			IMP_WorkshopJobAssigningSuccededMESGn.Show()		
		endif
	endif
endFunction


Function UnassignActor(WorkshopNPCScript theActor, bool bSendUnassignEvent = true)
	WorkshopScript workshopRef = IMP.WorkshopParent.GetWorkshop(theActor.GetWorkshopID())

	; am I currently assigned to something?
	int foundIndex = -1

	; caravan?
	foundIndex = IMP.WorkshopParent.CaravanActorAliases.Find(theActor)
	if foundIndex > -1
		; remove me from the caravan alias collection
		IMP.WorkshopParent.CaravanActorAliases.RemoveRef(theActor)
		IMP.WorkshopParent.CaravanActorRenameAliases.RemoveRef(theActor)

		Location startLocation = workshopRef.myLocation
		Location endLocation = IMP.WorkshopParent.GetWorkshop(theActor.GetCaravanDestinationID()).myLocation
		; unlink locations
		startLocation.RemoveLinkedLocation(endLocation, IMP.WorkshopParent.WorkshopCaravanKeyword)

		; set back to Boss
		if theActor.IsCreated()
			; Patch 1.4: allow custom loc ref type on workshop NPC
			theActor.SetAsBoss(startLocation)
		endif

		; update workshop rating - increment unassigned actors total
		theActor.SetValue(IMP.WorkshopParent.WorkshopRatings[IMP.WorkshopParent.WorkshopRatingPopulationUnassigned].resourceValue, 1)

		; clear caravan brahmin
		IMP.WorkshopParent.CaravanActorBrahminCheck(theActor)

		; 1.6: send custom event for this actor
		Var[] kargs = new Var[2]
		kargs[0] = theActor
		kargs[1] = workshopRef
		IMP.WorkshopParent.SendCustomEvent("WorkshopActorCaravanUnassign", kargs)
	endif

	; work object?
	if theActor.GetWorkshopID() == workshopRef.GetWorkshopID()
		; unassign ownership of all work objects
		ObjectReference[] OwnedResourceObjects=GetOwnedObjects(theActor as ObjectReference)
		
		int i = 0
		while i < OwnedResourceObjects.Length
			WorkshopObjectScript theObject = OwnedResourceObjects[i] as WorkshopObjectScript
			if theObject.RequiresActor()
				; this will also add the actor to the unassigned actor list (when it unassigns the last object)
				IMP.WorkshopParent.UnassignObject(theObject)
				if bSendUnassignEvent
					; send custom event for this object
					Var[] kargs = new Var[2]
					kargs[0] = theObject
					kargs[1] = workshopRef
					IMP.WorkshopParent.SendCustomEvent("WorkshopActorUnassigned", kargs)
				endif
			endif
			i += 1
		endWhile

		; clear actor work flags
		theActor.SetMultiResource(NONE)
		theActor.SetWorker(false)
	endif
endFunction


ObjectReference[] Function GetOwnedObjects(ObjectReference akSettlerRef)
	if akSettlerRef
		WorkshopScript WorkshopRef=akSettlerRef.GetLinkedRef(IMP.WorkshopItemKeyword) as WorkshopScript
		ObjectReference[] WorkshopResourceRefs=WorkshopRef.GetWorkshopResourceObjects()
		Int WorkshopResourceCount=WorkshopResourceRefs.length
		if WorkshopResourceCount
			ObjectReference[] OwnedObjectRefs=new ObjectReference[0]

			Int i=0
			while i < WorkshopResourceCount
				ObjectReference iObjectRef=WorkshopResourceRefs[i]
				if iObjectRef.GetActorRefOwner() == akSettlerRef
					OwnedObjectRefs.Add(iObjectRef)
				endif
				i+=1
			endwhile
			
			return OwnedObjectRefs
		endif
	endif
EndFunction