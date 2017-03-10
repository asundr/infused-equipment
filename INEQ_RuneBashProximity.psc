Scriptname INEQ_RuneBashProximity extends ObjectReference Hidden 
{Reports to the runebash ability whether this attached trigger box is occupied}

;===========================================  Properties  ===========================================================================>

;==========================================  Autoreadonly  ==========================================================================>
float	Property	WaitForTrigger	=	0.15	Autoreadonly

;===========================================  Variables  ============================================================================>
INEQ_RuneBash BashAbility
ObjectReference BoxRef

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

auto state Ready

	; If box is occupied, go to the inert state and delete the box unless its the player
	Event OnTriggerEnter(ObjectReference triggerRef)
	;Debug.Notification("OnTriggerEnter time: " + (Utility.getCurrentRealTime() - gametime))
		if triggerRef != BoxRef
			GoToState("Triggered")
		else
			;Debug.Notification("player in box")
		endif
	EndEvent
	
	; If box is unoccupied before the timer expires, tell the ability to cast the spell
	Event OnUpdate()
		BashAbility.castRune()
		Disable()
		Delete()
	EndEvent
	
endstate	

;___________________________________________________________________________________________________________________________

State Triggered

	Event OnBeginState()
		Disable()
		Delete()
	EndEvent

EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Used by INEQ_RuneBash to start checking for occumants in the trigger box
function register(INEQ_RuneBash akBashability, ObjectReference akBoxRef)
	BashAbility = akBashability
	BoxRef = akBoxRef
	;gametime = Utility.getCurrentRealTime()
	RegisterForSingleUpdate(WaitForTrigger)
	Enable()
EndFunction
