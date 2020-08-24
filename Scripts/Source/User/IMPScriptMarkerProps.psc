Scriptname IMPScriptMarkerProps extends ObjectReference

Group Prop1
Form property Prop1 auto const
Bool property bShowProp1OnActivate auto const
Bool property bShowProp1OnTimer auto const
Bool property bHideProp1OnExitFurniture auto const
Bool property bFadeOutProp1=True auto const
EndGroup

Group Prop2
Form property Prop2 auto const
Bool property bShowProp2OnActivate auto const
Bool property bShowProp2OnTimer auto const
Bool property bHideProp2OnExitFurniture auto const
Bool property bFadeOutProp2=True auto const
EndGroup

Group Prop3
Form property Prop3 auto const
Bool property bShowProp3OnActivate auto const
Bool property bShowProp3OnTimer auto const
Bool property bHideProp3OnExitFurniture auto const
Bool property bFadeOutProp3=True auto const
EndGroup

Group Prop4
Form property Prop4 auto const
Bool property bShowProp4OnActivate auto const
Bool property bShowProp4OnTimer auto const
Bool property bHideProp4OnExitFurniture auto const
Bool property bFadeOutProp4=True auto const
EndGroup

Group Timer
Int property InitStartTime auto const
Int property InitEndTime auto const
EndGroup

Group Sound
Sound property FXSound auto const
Float property AdditionalSoundDelay auto const
EndGroup
;---------

Int TimerID=10
Int SoundInstanceID=-1

;---------

ObjectReference Prop1Ref
ObjectReference Prop2Ref
ObjectReference Prop3Ref
ObjectReference Prop4Ref


;=========


Function CreateProps()
	Bool bIsFurnitureInUse=IsFurnitureInUse()
	Bool bCreatePropInitiallyDisabled

	if Prop1
		bCreatePropInitiallyDisabled=bShowProp1OnActivate || bShowProp1OnTimer
		Prop1Ref=PlaceAtMe(Prop1, abInitiallyDisabled=bCreatePropInitiallyDisabled)
		if bIsFurnitureInUse
			Prop1Ref.EnableNoWait()
		endif
		if !bCreatePropInitiallyDisabled  ||  bIsFurnitureInUse
			SetSound()
		endif
	endif
	if Prop2
		bCreatePropInitiallyDisabled=bShowProp2OnActivate || bShowProp2OnTimer
		Prop2Ref=PlaceAtMe(Prop2, abInitiallyDisabled=bCreatePropInitiallyDisabled)
		if bIsFurnitureInUse
			Prop2Ref.EnableNoWait()
		endif
		if !bCreatePropInitiallyDisabled  ||  bIsFurnitureInUse
			SetSound()
		endif
	endif
	if Prop3
		bCreatePropInitiallyDisabled=bShowProp3OnActivate || bShowProp3OnTimer
		Prop3Ref=PlaceAtMe(Prop3, abInitiallyDisabled=bCreatePropInitiallyDisabled)
		if bIsFurnitureInUse
			Prop3Ref.EnableNoWait()
		endif
		if !bCreatePropInitiallyDisabled  ||  bIsFurnitureInUse
			SetSound()
		endif
	endif
	if Prop4
		bCreatePropInitiallyDisabled=bShowProp4OnActivate || bShowProp4OnTimer
		Prop4Ref=PlaceAtMe(Prop4, abInitiallyDisabled=bCreatePropInitiallyDisabled)
		if bIsFurnitureInUse
			Prop4Ref.EnableNoWait()
		endif
		if !bCreatePropInitiallyDisabled  ||  bIsFurnitureInUse
			SetSound()
		endif
	endif


	if bShowProp1OnTimer  ||  bShowProp2OnTimer  ||  bShowProp3OnTimer  ||  bShowProp4OnTimer
		SetTimer()
	endif
EndFunction


Function MoveProps(ObjectReference akTargetRef)
	if akTargetRef
		if Prop1Ref
			Prop1Ref.MoveTo(akTargetRef)
		endif
		if Prop2Ref
			Prop2Ref.MoveTo(akTargetRef)
		endif
		if Prop3Ref
			Prop3Ref.MoveTo(akTargetRef)
		endif
		if Prop4Ref
			Prop4Ref.MoveTo(akTargetRef)
		endif
	endif
EndFunction


Function DeleteProps()
	if Prop1Ref
		Prop1Ref.DisableNoWait()
		Prop1Ref.Delete()
		Prop1Ref=NONE
	endif

	if Prop2Ref
		Prop2Ref.DisableNoWait()
		Prop2Ref.Delete()
		Prop2Ref=NONE
	endif

	if Prop3Ref
		Prop3Ref.DisableNoWait()
		Prop3Ref.Delete()
		Prop3Ref=NONE
	endif

	if Prop4Ref
		Prop4Ref.DisableNoWait()
		Prop4Ref.Delete()
		Prop4Ref=NONE
	endif

	UnsetSound()

	UnsetTimer()
EndFunction


;=========


Event OnActivate(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()

		if Prop1Ref && bShowProp1OnActivate
			Prop1Ref.EnableNoWait(bFadeOutProp1)
			SetSound()
		endif
		if Prop2Ref && bShowProp2OnActivate
			Prop2Ref.EnableNoWait(bFadeOutProp2)
			SetSound()
		endif
		if Prop3Ref && bShowProp3OnActivate
			Prop3Ref.EnableNoWait(bFadeOutProp3)
			SetSound()
		endif
		if Prop4Ref && bShowProp4OnActivate
			Prop4Ref.EnableNoWait(bFadeOutProp4)
			SetSound()
		endif		

	endif
EndEvent


Event OnExitFurniture(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()

		if Prop1Ref && bHideProp1OnExitFurniture
			Prop1Ref.DisableNoWait(bFadeOutProp1)
			UnsetSound()
		endif
		if Prop2Ref && bHideProp2OnExitFurniture
			Prop2Ref.DisableNoWait(bFadeOutProp2)
			UnsetSound()
		endif
		if Prop3Ref && bHideProp3OnExitFurniture
			Prop3Ref.DisableNoWait(bFadeOutProp3)
			UnsetSound()
		endif
		if Prop4Ref && bHideProp4OnExitFurniture
			Prop4Ref.DisableNoWait(bFadeOutProp4)
			UnsetSound()
		endif		

	endif
EndEvent


;=========


Function SetIdleMarkerOwnership(Actor akOwnerRef)
	if Prop1Ref.GetBaseObject() as IdleMarker
		Prop1Ref.SetActorRefOwner(akOwnerRef)
	endif

	if Prop2Ref.GetBaseObject() as IdleMarker
		Prop2Ref.SetActorRefOwner(akOwnerRef)
	endif

	if Prop3Ref.GetBaseObject() as IdleMarker
		Prop3Ref.SetActorRefOwner(akOwnerRef)
	endif

	if Prop4Ref.GetBaseObject() as IdleMarker
		Prop4Ref.SetActorRefOwner(akOwnerRef)
	endif
EndFunction


;*** UNUSED ***
ObjectReference[] Function GetPropRefs()
	ObjectReference[] PropRefs=new ObjectReference[0]

	if Prop1Ref
		PropRefs.Add(Prop1Ref)
	endif
	if Prop2Ref
		PropRefs.Add(Prop2Ref)
	endif
	if Prop3Ref
		PropRefs.Add(Prop3Ref)
	endif
	if Prop4Ref
		PropRefs.Add(Prop4Ref)
	endif

	if PropRefs.length > 0
		return PropRefs
	endif
EndFunction


;=========


Event OnInit()
	if InitStartTime > 0  ||  InitEndTime > 0
		IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
		SetValue(IMP.IMP_MarkerPropsTimerStart, InitStartTime)
		SetValue(IMP.IMP_MarkerPropsTimerEnd, InitEndTime)
	endif
EndEvent


Function UnsetTimer()
	CancelTimerGameTime(TimerID)
EndFunction


Function SetTimer()
	IMPScriptMain IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain

	Float TimerStart=GetValue(IMP.IMP_MarkerPropsTimerStart)
	Float TimerEnd=GetValue(IMP.IMP_MarkerPropsTimerEnd)
	Float CurrentGamehour=IMP.Gamehour.GetValue()
	if TimerEnd > TimerStart

		CancelTimerGameTime(TimerID)
		if CurrentGamehour >= TimerStart  &&  CurrentGamehour < TimerEnd
			Prop1Ref.EnableNoWait(bFadeOutProp1)
			Prop2Ref.EnableNoWait(bFadeOutProp2)
			Prop3Ref.EnableNoWait(bFadeOutProp3)
			Prop4Ref.EnableNoWait(bFadeOutProp4)
			SetSound()

			Float Timer
			Timer= TimerEnd - CurrentGamehour
			StartTimerGameTime(Timer, TimerID)

		else
			Prop1Ref.DisableNoWait(bFadeOutProp1)
			Prop2Ref.DisableNoWait(bFadeOutProp2)
			Prop3Ref.DisableNoWait(bFadeOutProp3)
			Prop4Ref.DisableNoWait(bFadeOutProp4)
			UnsetSound()

			Float Timer
			Timer=24 - CurrentGamehour + TimerStart
			StartTimerGameTime(Timer, TimerID)
		endif


	elseif TimerStart > TimerEnd
		CancelTimerGameTime(TimerID)
		if CurrentGamehour >= TimerStart  ||  CurrentGamehour < TimerEnd
			Prop1Ref.EnableNoWait(bFadeOutProp1)
			Prop2Ref.EnableNoWait(bFadeOutProp2)
			Prop3Ref.EnableNoWait(bFadeOutProp3)
			Prop4Ref.EnableNoWait(bFadeOutProp4)
			SetSound()

			Float Timer
			Timer= 24 - CurrentGamehour + TimerEnd
			StartTimerGameTime(Timer, TimerID)

		else
			Prop1Ref.DisableNoWait(bFadeOutProp1)
			Prop2Ref.DisableNoWait(bFadeOutProp2)
			Prop3Ref.DisableNoWait(bFadeOutProp3)
			Prop4Ref.DisableNoWait(bFadeOutProp4)
			UnsetSound()

			Float Timer
			Timer=TimerStart - CurrentGamehour
			StartTimerGameTime(Timer, TimerID)
		endif

	endif
EndFunction


Event OnTimerGameTime(int aiTimerID)		
	if aiTimerID == TimerID
		SetTimer()
	endif
EndEvent


;---------


Function SetPropsConstant_PUBLIC(Bool abFadeOut=False)
	UnsetTimer()
	Prop1Ref.EnableNoWait(abFadeOut)
	Prop2Ref.EnableNoWait(abFadeOut)
	Prop3Ref.EnableNoWait(abFadeOut)
	Prop4Ref.EnableNoWait(abFadeOut)
	SetSound()
EndFunction

Function SetPropsTimed_PUBLIC()
	SetTimer()
EndFunction


;=========


Function SetSound()
	if FXSound && SoundInstanceID==-1
		Utility.Wait(0.5+AdditionalSoundDelay)
		SoundInstanceID=FXSound.Play(Self)
	endif
EndFunction


Function UnsetSound()
	Utility.Wait(0.5+AdditionalSoundDelay)
	Sound.StopInstance(SoundInstanceID)
	SoundInstanceID=-1
EndFunction