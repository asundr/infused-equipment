Scriptname INEQ_SharedCharges extends INEQ_RechargeBase 
{Holds and transfers charges used by various abilities}

;===========================================  Properties  ===========================================================================>
float	Property	ChargeDistance			Auto	Hidden
float	Property	ChargeMagickaMP			Auto	Hidden
int		Property	ChargeMagickaPR			Auto	Hidden
int		Property	MaxCharges				Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
float	Property	DEFChargeDistance	=	1000.0	Autoreadonly
float	Property	DEFChargeMagickaMP	=	400.0	Autoreadonly
int		Property	DEFChargeMagickaPR	=	10		Autoreadonly
int		Property	DEFMaxCharges		=	5		Autoreadonly

;===========================================  Variables  ============================================================================>
bool bBalanced = True
int numCharges	= 5

INEQ_SharedChargesListener EventListener

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnPlayerLoadGame()
	parent.PlayerLoadGame()
	RegisterForRecharge()
EndEvent

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	bBalanced		= True
	ChargeDistance	= DEFChargeDistance
	ChargeMagickaMP	= DEFChargeMagickaMP
	ChargeMagickaPR	= DEFChargeMagickaPR
	MaxCharges		= DEFMaxCharges
Endfunction

Function FullReset()
	parent.FullReset()
	numCharges = 5
EndFunction
	
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
			RegisterForRecharge()
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
			RegisterForRecharge()
			Debug.Notification("Shared charges: " +numCharges)
			return iRequest
		elseif !bExact
			iRequest = numCharges
			numCharges = 0
			RegisterForRecharge()
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

; Register with any recharge sources
Function RegisterForRecharge(bool bForced = False)
	RegisterForDistanceTravelledEvent(bForced)
	RegisterForMagickaSiphonEvent(bForced)
EndFunction
;___________________________________________________________________________________________________________________________

; Links to a class, that's capable of listening to EventListener behavior
Function registerListener(INEQ_SharedChargesListener akListener)
	EventListener = akListener
	RegisterForRecharge()
EndFunction
;___________________________________________________________________________________________________________________________

; Registers for DistanceTravelledEvent if not at maximum charges and not currently registered
function RegisterForDistanceTravelledEvent(bool bForced)
	if EventListener
		if numCharges < maxCharges
			EventListener.RegisterForDistanceTravelledEvent(ChargeDistance, bForced)
		endif
	endif
endFunction

; Receiver for DistanceTravelledEvent
Function OnDistanceTravelledEvent()
	addCharge()
EndFunction
;___________________________________________________________________________________________________________________________

; Registers for MagickaSiphonEvent if not at maximum charges and not currently registered
Function RegisterForMagickaSiphonEvent(bool bForced)
	if EventListener
		if numCharges < maxCharges
			EventListener.RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR, bForced)
		endif
	endif
EndFunction

; Receiver for MagickaSiphonEvent
function OnMagickaSiphonEvent()
	addCharge()
EndFunction

;===============================================================================================================================
;====================================		    Menus			================================================
;================================================================================================

Function ChargeMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		SetButtonMain(Button)
		aiButton = MainMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9		; Cancel menu
			MenuActive.SetValue(0)
		elseif aiButton == 1		; Turn on Balanced
			RestoreDefaultFields()
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Charge Storage
			MaxCharges = ListenerMenu.ChargeStorage(MaxCharges, DEFMaxCharges)
		elseif aiButton == 4		; Distance Cost
			ChargeDistance = ListenerMenu.DistanceTravelledCost(ChargeDistance, DEFChargeDistance)
		elseif aiButton == 5		; Magicka Cost
			ChargeMagickaMP = ListenerMenu.MagickaSiphonCost(ChargeMagickaMP, DEFChargeMagickaMP)
		elseif aiButton == 8		; Priority
			ChargeMagickaPR = ListenerMenu.MagickaSiphonPriority(ChargeMagickaPR, DEFChargeMagickaPR)
		endif
	endwhile
	RegisterForRecharge(True)
EndFunction

Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
	else
		Button.set(1)
		Button.set(3)
		Button.set(4)
		Button.set(5)
	endif
	Button.set(8)
	Button.set(9)
EndFunction
