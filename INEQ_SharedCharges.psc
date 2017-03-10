Scriptname INEQ_SharedCharges extends ReferenceAlias 
{Holds and transfers charges used by various abilities}

;===========================================  Properties  ===========================================================================>

float	Property	ChargeDistance	=	300.0	Autoreadonly

;===========================================  Variables  ============================================================================>
Actor SelfRef

int numCharges	= 0	;use GV for persistence?
int maxCharges	= 5

INEQ_SharedChargesListener EventListener

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnInit()
	SelfRef = GetReference() as Actor
	RegisterForTrackedStatsEvent()
EndEvent

; Registers for events on load if they should be active
Event OnPlayerLoadGame()
	Debug.MessageBox("Player load for shared charges")
	RegisterForDistanceTravelledEvent()
EndEvent
	
;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

Function addCharge(int iRequest = 1)
	numCharges += iRequest
	if numCharges >= maxCharges
		numCharges = maxCharges
	else
		RegisterForDistanceTravelledEvent()
	endif
	Debug.Notification("Shared charges: " +numCharges)
endFunction

; Will transfer the number of requested charges if available
bool Function requestCharge(int iRequest)
	return requestChargeUpTo(iRequest, True)
EndFunction

; Will transfer up to the number of requested charges
int function requestChargeUpTo(int iRequest, bool bExact = False)
	if iRequest > 0
		if numCharges >= iRequest
			numCharges -= iRequest
			RegisterForDistanceTravelledEvent()
			Debug.Notification("Shared charges: " +numCharges)
			return iRequest
		elseif !bExact
			iRequest = numCharges
			numCharges = 0
			Debug.Notification("Shared charges: " +numCharges)
			return iRequest
		else
			return 0
		endif
	else
		return 0
	endif
EndFunction

int function getCharge()
	return numCharges
endfunction

; Links to a class, that's capable of listening to EventListener behavior
Function registerListener(INEQ_SharedChargesListener akListener)
	EventListener = akListener
	RegisterForDistanceTravelledEvent()
EndFunction
;___________________________________________________________________________________________________________________________

; Registers for DistanceTravelledEvent if not at maximum charges and not currently registered
function RegisterForDistanceTravelledEvent()
	if numCharges < maxCharges && EventListener && !EventListener.bDistanceChargingActive
		EventListener.RegisterForDistanceTravelledEvent(ChargeDistance)
	endif
endFunction

; Receiver for DistanceTravelledEvent
Function OnDistanceTravelledEvent()
	addCharge()
EndFunction
;___________________________________________________________________________________________________________________________

;Doesn't seem to register... :(
Event OnTrackedStatsEvent(string asStat, int aiStatValue)
	if asStat == "Bunnies Slaughtered"
		Debug.MessageBox("You monster")
		addCharge()
	endif
EndEvent
