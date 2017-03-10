Scriptname INEQ_ThrowVoice extends INEQ_AbilityBase  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell property ThrowVoiceSpell auto

String  Property  BashExit  = 	"bashExit"  	Autoreadonly			; End bashing

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start/Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForAnimationEvent(selfRef, BashExit)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, BashExit)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if (EventName == BashExit) && SelfRef.isSneaking() && !SelfRef.isInCombat()
			ThrowVoiceSpell.cast(SelfRef)
;			SelfRef.damageAv("stamina", 25)		;default cost
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, BashExit)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Charging

	Event OnBeginState()
					
	EndEvent

EndState
