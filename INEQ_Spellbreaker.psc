Scriptname INEQ_Spellbreaker extends INEQ_AbilityBaseShield  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell	Property	abSpellbreaker	Auto

;==========================================  Autoreadonly  ==========================================================================>
String	Property	BlockStop	=	"blockStop"			Autoreadonly		; stop blocking
String	Property	BlockStart	=	"blockStartOut"		Autoreadonly		; start blocking

;===========================================  Variables  ============================================================================>


;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SelfRef.removespell(abSpellbreaker)
	parent.EffectFinish(akTarget, akCaster)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
;		Debug.Notification("Enter Equipped")
		SelfRef.removespell(abSpellbreaker)
		RegisterForAnimationEvent(selfRef, BlockStart)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if (akSource == selfRef) &&  (EventName == BlockStart)
			GoToState("Blocking")
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, BlockStart)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Blocking

	Event OnBeginState()
;		Debug.Notification("Enter blocking")
		SelfRef.addspell(abSpellbreaker, false)
		RegisterForAnimationEvent(selfRef, BlockStop)				
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  (akSource == selfRef) && ( EventName == BlockStop)
			GoToState("Equipped")
		endif
	EndEvent

	Event OnEndState()
		SelfRef.removespell(abSpellbreaker)
		UnregisterForAnimationEvent(selfRef, BlockStop) 
	EndEvent

EndState
