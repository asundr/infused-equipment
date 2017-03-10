Scriptname INEQ_SharedCharges extends ReferenceAlias 
{Holds and transfers charges used by various abilities}

;===========================================  Properties  ===========================================================================>
float	Property	ChargeDistance	=	110.0	Auto	Hidden
float	Property	ChargeMagicka	=	150.0	Auto	Hidden
int		Property	PriorityMagicka	=	10		Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
float	Property	DEFChargeDistance	=	2000.0	Autoreadonly	Hidden
float	Property	DEFChargeMagicka	=	150.0	Autoreadonly	Hidden
int		Property	DEFPriorityMagicka	=	10		Autoreadonly	Hidden

;===========================================  Variables  ============================================================================>
Actor SelfRef
INEQ_SharedChargesListener EventListener

int numCharges	= 5	;use GV for persistence?
int maxCharges	= 5

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	SelfRef = GetReference() as Actor
	RegisterForTrackedStatsEvent()
EndEvent

; Registers for events on load if they should be active
Event OnPlayerLoadGame()
	RegisterForDistanceTravelledEvent()
	RegisterForMagickaSiphonEvent()
EndEvent

Function RestoreDefaultFields()
	ChargeDistance = DEFChargeDistance
	ChargeMagicka = DEFChargeMagicka
	PriorityMagicka = DEFPriorityMagicka
Endfunction
	
;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Returns number of charges
int function getCharge()
	return numCharges
endfunction
;___________________________________________________________________________________________________________________________

; Adds charge if below maximum. If sum is less than max, register for another event, otherwise set charge at max and unregister
Function addCharge(int charge = 1)
	if numCharges != maxCharges
		numCharges += charge
		if numCharges < maxCharges
			Debug.Notification("Shared charges: " +numCharges)
			RegisterForDistanceTravelledEvent()
			RegisterForMagickaSiphonEvent()
			return
		else
			numCharges = maxCharges
			Debug.Notification("Shared charges: " +numCharges)
		endif
	endif
	EventListener.UnregisterForDistanceTravelledEvent()
	EventListener.UnregisterForMagickaSiphonEvent()
EndFunction
;___________________________________________________________________________________________________________________________

; Will transfer the exact number of requested charges if available
bool Function requestCharge(int iRequest)
	return requestChargeUpTo(iRequest, True)
EndFunction

; Will transfer up to the number of requested charges
int function requestChargeUpTo(int iRequest, bool bExact = False)
	if iRequest > 0
		if numCharges >= iRequest
			numCharges -= iRequest
			RegisterForDistanceTravelledEvent()
			RegisterForMagickaSiphonEvent()
			Debug.Notification("Shared charges: " +numCharges)
			return iRequest
		elseif !bExact
			iRequest = numCharges
			numCharges = 0
			RegisterForDistanceTravelledEvent()
			RegisterForMagickaSiphonEvent()
			Debug.Notification("Shared charges: " +numCharges)
			return iRequest
		else
			return 0
		endif
	else
		return 0
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Links to a class, that's capable of listening to EventListener behavior
Function registerListener(INEQ_SharedChargesListener akListener)
	EventListener = akListener
	RegisterForDistanceTravelledEvent()
	RegisterForMagickaSiphonEvent()
EndFunction
;___________________________________________________________________________________________________________________________

; Registers for DistanceTravelledEvent if not at maximum charges and not currently registered
function RegisterForDistanceTravelledEvent()
	if numCharges < maxCharges && EventListener ;&& !EventListener.isRegisteredDistanceTravelled()
		EventListener.RegisterForDistanceTravelledEvent(ChargeDistance)
	endif
endFunction

; Receiver for DistanceTravelledEvent
Function OnDistanceTravelledEvent()
	addCharge()
EndFunction
;___________________________________________________________________________________________________________________________

; Registers for MagickaSiphonEvent if not at maximum charges and not currently registered
Function RegisterForMagickaSiphonEvent()
	if numCharges < maxCharges && EventListener ;&& !EventListener.isRegisteredMagickaSiphon()
		EventListener.RegisterForMagickaSiphonEvent(ChargeMagicka, PriorityMagicka)
	endif
EndFunction

; Receiver for MagickaSiphonEvent
function OnMagickaSiphonEvent()
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
