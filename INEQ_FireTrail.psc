Scriptname INEQ_FireTrail extends ActiveMagicEffect  

Spell			Property	SpellImpact				auto
Keyword			property	INEQ__KWWaterwalking	auto
ImpactDataset	property	TrailSet				auto

Hazard			property	TrailHazard				auto

Actor selfRef
ObjectReference EquipRef

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SelfRef = akCaster
	;RegisterForSingleUpdate(1)
	RegisterForAnimationEvent(selfRef, "FootSprintLeft" )
	RegisterForAnimationEvent(selfRef, "FootSprintRight" )
EndEVent








Event OnAnimationEvent( ObjectReference akSelfRef, string e )
	Debug.Notification("foot event")
	If (  e == "FootSprintLeft" )
;		akSelfRef.PlayImpactEffect( TrailSet, "NPC L Calf [LClf]", 0, 0, -1, 128, false, false )
		akSelfRef.PlaceAtMe( TrailHazard)
	ElseIf (  e == "FootSprintRight" )
;		akSelfRef.PlayImpactEffect( TrailSet, "NPC R Calf [RClf]", 0, 0, -1, 128, false, false )
		akSelfRef.PlaceAtMe( TrailHazard)
	endif
endEvent




Event OnUpdate()
	
	;SpellImpact.cast(SelfRef, SelfRef)
	Debug.Notification("hit")
	if (SelfRef.isSprinting())
		SelfRef.PlayImpactEffect( TrailSet, "NPC L Thigh [LThg]", 0, 0, -1, 128, false, false )
	EndIf
	RegisterForSingleUpdate(1)
EndEvent