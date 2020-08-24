Scriptname IMPScriptSharedPkgTravelToSandbox extends Package Const

Group PkgOwner
ActorValue property PackageAV auto const mandatory
EndGroup

Group Aliases
ReferenceAlias property Alias01 auto const
ReferenceAlias property Alias02 auto const
ReferenceAlias property Alias03 auto const
RefCollectionAlias property RefCollAlias01  auto const
RefCollectionAlias property RefCollAlias02  auto const
EndGroup


Event OnEnd(Actor akActor)
	Float CurrentAV=akActor.GetValue(PackageAV)
	if CurrentAV > 0
		akActor.SetValue(PackageAV, CurrentAV+1)
		akActor.EvaluatePackage()

		Alias01.GetActorRef().EvaluatePackage()
		Alias02.GetActorRef().EvaluatePackage()
		Alias03.GetActorRef().EvaluatePackage()
		RefCollAlias01.EvaluateAll()
		RefCollAlias02.EvaluateAll()
	endif
EndEvent
