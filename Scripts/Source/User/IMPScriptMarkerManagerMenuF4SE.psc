Scriptname IMPScriptMarkerManagerMenuF4SE extends Quest

ReferenceAlias property WorkshopF4SEAlias auto const mandatory


IMPScriptMain IMP
ObjectReference SelectedObjectRef

;=========

Event OnQuestInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
EndEvent



;=========

Function RegisterWorkshopF4SE_PUBLIC(ObjectReference akWorkshopRef)
	if IMP.IMP_KeyScanCodeF4SE.GetValue() != -1
		if akWorkshopRef
			WorkshopF4SEAlias.ForceRefTo(akWorkshopRef)
			RegisterForKey(IMP.IMP_KeyScanCodeF4SE.GetValue() as Int)
		endif
	endif
EndFunction

Function UnregisterWorkshopF4SE_PUBLIC()
	WorkshopF4SEAlias.Clear()
	UnregisterForKey(IMP.IMP_KeyScanCodeF4SE.GetValue() as Int)
EndFunction

;---------

Function WorkshopOnGrabbed_PUBLIC(ObjectReference akWorkshopObjectRef)
	SelectedObjectRef=akWorkshopObjectRef
	if SelectedObjectRef
		IMP.MarkerManagerMenu.CanMarkerManagerMenuBeShown_PUBLIC(SelectedObjectRef)
	endif
EndFunction

Function WorkshopOnMoved_PUBLIC()
	SelectedObjectRef=NONE
EndFunction


;=========


Function SettlerOnCommandModeEnter_PUBLIC(ObjectReference akSettlerRef)
	if IMP.IMP_KeyScanCodeF4SE.GetValue() != -1
		SelectedObjectRef=akSettlerRef
		if SelectedObjectRef
			IMP.MarkerManagerMenu.CanSettlerManagerMenuBeShown_PUBLIC(SelectedObjectRef)
		endif
	endif
EndFunction

Function SettlerOnCommandModeExit_PUBLIC()
	SelectedObjectRef=NONE
EndFunction


;=========


Event OnKeyDown(int keyCode)
	if keyCode == IMP.IMP_KeyScanCodeF4SE.GetValue()
		if SelectedObjectRef
			IMP.MarkerManagerMenu.HandleF4SEButton_PUBLIC(SelectedObjectRef)
		endif
	endif
EndEvent
