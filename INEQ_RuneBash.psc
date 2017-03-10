Scriptname INEQ_RuneBash extends INEQ_AbilityBase1H  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell property RuneSpell auto

String  Property  BashExit  = 	"bashExit"  	Autoreadonly			; End bashing

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start			================================================
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
		if (akSource == SelfRef) &&  (EventName == BashExit)
			RuneSpell.cast(SelfRef)
;			SelfRef.damageAv("stamina", 25)		;default cost
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, BashExit)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Cooldown

	Event OnBeginState()
					
	EndEvent

EndState
