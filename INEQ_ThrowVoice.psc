Scriptname INEQ_ThrowVoice extends INEQ_AbilityBase  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell	property	ThrowVoiceSpell	Auto

;==========================================  Autoreadonly  ==========================================================================>
String	Property	BashExit	=	"bashExit"	Autoreadonly			; End bashing

;===========================================  Variables  ============================================================================>


;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================


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
