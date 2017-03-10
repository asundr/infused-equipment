Scriptname INEQ_ThrowVoice extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Message	Property	MainMenu			Auto
Sound	Property	INEQ__ShoutFail		Auto
Spell	Property	ThrowVoiceSpell		Auto

int		Property	ShoutTime			Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
int		Property	DEFShoutTime	=	5		Autoreadonly

String	Property	BashExit	=	"bashExit"	Autoreadonly			; End bashing

;===========================================  Variables  ============================================================================>
bool bBalanced
bool bUseShoutCharge
;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	bBalanced		= True
	bUseShoutCharge	= True
	ShoutTime		= DEFShoutTime
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, BashExit)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if SelfRef.isSneaking() && TeleportCost()
			ThrowVoiceSpell.cast(SelfRef)
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, BashExit)
	EndEvent

EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

bool Function TeleportCost()
	if bUseShoutCharge
		if !SelfRef.GetVoiceRecoveryTime()
			SelfRef.SetVoiceRecoveryTime(ShoutTime * SelfRef.GetActorValue("ShoutRecoveryMult"))
			return True
		else
			INEQ__ShoutFail.play(SelfRef)
		endif
	else
		return True
	endif
	return false
EndFunction

;===============================================================================================================================
;====================================		    Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		SetButtonMain(Button)
		aiButton = MainMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9		; Cancel Menu
			MenuActive.SetValue(0)
		elseif aiButton == 1		; Turn on Balanced
			RestoreDefaultFields()
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Shout cost -> On
			bUseShoutCharge = True
		elseif aiButton == 4		; Shout Cost -> Off
			bUseShoutCharge = False
		elseif aiButton == 5		; Set Charge Time
			ShoutTime = ListenerMenu.ChargeTime(ShoutTime, DEFShoutTime)
		endif
	endwhile
EndFunction

; Updates the Button to show the correct menu options
Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
	else
		Button.set(1)
		if bUseShoutCharge
			Button.set(4)
			Button.set(5)
		else
			Button.set(3)
		endif
	endif
	Button.set(9)
EndFunction
