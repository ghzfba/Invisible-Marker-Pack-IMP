Scriptname IMPScriptMarkerSandboxWorkType extends ObjectReference

Static property PropToPlace auto const
Int property BonusItemID auto

IMPScriptMain IMP
Float LastBonusItemGotSettler
ObjectReference PropRef



Event OnInit()
	IMP=Game.GetFormFromFile(0x01000F9B, "IMP.esp") as IMPScriptMain
	LastBonusItemGotSettler=Utility.GetCurrentGametime()
EndEvent

;=========

Event OnActivate(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()
		PlaceProp()
	endif
EndEvent

Event OnExitFurniture(ObjectReference akActionRef)
	if akActionRef != Game.GetPlayer()
		DeleteProp(bFadeOut=True)
		AddBonusItemToWorkshop()
	endif
EndEvent

;=========

Event OnLoad()
	if IsFurnitureInUse()
		PlaceProp()
	endif
	AddBonusItemToWorkshop()
EndEvent

Event OnUnload()
	if IsFurnitureInUse()
		DeleteProp(bFadeOut=False)
	endif
EndEvent

;=========

Function AddBonusItemToWorkshop()
	Float CurrentGametime=Utility.GetCurrentGametime()
	if CurrentGametime >= LastBonusItemGotSettler +1
		ObjectReference WorkshopRef=GetLinkedRef(IMP.WorkshopItemKeyword)
		Int ItemCount=Math.Floor(CurrentGametime - LastBonusItemGotSettler)
		Int i=0
		while i < ItemCount
			if Utility.RandomInt(1,100) <= IMP.IMP_BonusItemChance.GetValue()
				WorkshopRef.AddItem(IMP.IMP_BonusItemList.GetAt(BonusItemID) as LeveledItem)
			endif
			i+=1
		endwhile
		LastBonusItemGotSettler=CurrentGametime
	endif
EndFunction

;=========

Function PlaceProp()
	if PropToPlace
		PropRef=PlaceAtMe(PropToPlace)
	endif
EndFunction

Function DeleteProp(Bool bFadeOut)
	if PropRef
		PropRef.DisableNoWait(bFadeOut)
		PropRef.Delete()
		PropRef=NONE
	endif
EndFunction

;=========

Function SetBonusItemID_PUBLIC(Int aiID)
	BonusItemID=aiID
EndFunction

Int Function GetBonusItemID_PUBLIC()
	return BonusItemID
EndFunction