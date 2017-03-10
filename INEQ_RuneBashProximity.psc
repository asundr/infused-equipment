Scriptname INEQ_RuneBashProximity extends ObjectReference Hidden 

INEQ_RuneBash BashAbility
ObjectReference SelfRef

;float gametime

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

auto state Ready

	Event onTriggerEnter(ObjectReference triggerRef)
	;Debug.Notification("OnTriggerEnter time: " + (Utility.getCurrentRealTime() - gametime))
		if triggerRef != SelfRef
			GoToState("Triggered")
		else
			;Debug.Notification("player in box")
		endif
	EndEvent
	
	Event OnUpdate()
		BashAbility.castRune()
		Disable()
		Delete()
	EndEvent
	
endstate	
	
State Triggered

	Event OnBeginState()
		Disable()
		Delete()
	EndEvent

EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

function register(INEQ_RuneBash akBashability, ObjectReference akSelfRef)
	BashAbility = akBashability
	SelfRef = akSelfRef
	;gametime = Utility.getCurrentRealTime()
	RegisterForSingleUpdate(0.15)
	Enable()
EndFunction