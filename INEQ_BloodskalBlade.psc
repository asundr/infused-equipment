Scriptname INEQ_BloodskalBlade extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Message	Property	MainMenu			Auto
Message Property	ChargeOptionsMenu	Auto

Spell	Property	DLC2BloodskalBladeSpellHoriz	Auto
Spell	Property	DLC2BloodskalBladeSpellVert		Auto

bool	Property	bBalanced			Auto	Hidden
bool	Property	bUseCharges			Auto	Hidden

int		Property	ChargeMode			Auto	Hidden	; 0=shared charges, 1=prioritize local, 2=only use local charges
Int		Property	ChargeCost			Auto	Hidden
float	Property	ChargeDistance		Auto	Hidden	; 1000.0, should be high relative to ChargeMagickaSiphon
float	Property	ChargeMagickaMP		Auto	Hidden
int		Property	ChargeMagickaPR		Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
int		Property	DEFChargeMode		=	0		Autoreadonly
int		Property	DEFMaxLocalCharge	=	4		Autoreadonly
int		Property	DEFChargeCost		=	2		Autoreadonly
float	Property	DEFChargeDistance	=	100.0	Autoreadonly
float	Property	DEFChargeMagickaMP	=	1000.0	Autoreadonly
int		Property	DEFChargeMagickaPR	=	50		Autoreadonly

String  Property WeaponSwing	=	"weaponSwing"  					Autoreadonly
String	Property PWStanding2H	= 	"AttackPowerStanding_FXstart"	Autoreadonly
String	Property PWRight2H		= 	"AttackPowerRight_FXstart"		Autoreadonly
String	Property PWLeft2H		= 	"AttackPowerLeft_FXstart"		Autoreadonly
String	Property PWForward2H	= 	"AttackPowerForward_FXstart"	Autoreadonly
String	Property PWBackward2H	= 	"AttackPowerBackward_FXstart"	Autoreadonly

;===========================================  Variables  ============================================================================>

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	RegisterAbilityToAlias()
	RegisterForRecharge()
EndEvent

Event OnPlayerLoadGame()
	parent.PlayerLoadGame()
	Maintenance()
EndEvent

Function Maintenance()
	parent.Maintenance()
	RegisterForRecharge()
EndFunction

Function RestoreDefaultFields()
	bUseCharges		=	True
	bBalanced		=	True
	MaxLocalCharge	=	DEFMaxLocalCharge
	ChargeCost		=	DEFChargeCost
	ChargeDistance	=	DEFChargeDistance
	ChargeMagickaMP	=	DEFChargeMagickaMP
	ChargeMagickaPR	=	DEFChargeMagickaPR
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		int itemType = SelfRef.getEquippedItemType(1)
		if itemType == 5
			GoToState("Equipped2HGreatsword")
		elseif itemType == 6
			GoToState("Equipped2HOther")
		elseif itemType > 0 && itemType < 5
			GoToState("Equipped1H")
		endif
		RegisterForRecharge()
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Equipped1H

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  SelfRef.GetAnimationVariableBool("bAllowRotation") &&  !SelfRef.GetAnimationVariableBool("isBlocking") &&\
				!SelfRef.GetAnimationVariableBool("isBashing") &&   !SelfRef.GetAnimationVariableBool("isSneaking")
			if !bUseCharges || hasCharge()
				if SelfRef.GetAnimationVariableFloat("Speed") == 0
					DLC2BloodskalBladeSpellVert.cast(selfRef)
				else
					float direction = selfRef.GetAnimationVariableFloat( "Direction" )
					if (direction == 0.25 || direction == 0.75)
						DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
					else
						DLC2BloodskalBladeSpellVert.cast(selfRef)
					endif
				endif
			endif
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

State Equipped2HOther

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if  SelfRef.GetAnimationVariableBool("bAllowRotation") &&  !SelfRef.GetAnimationVariableBool("isBlocking") &&\
				!SelfRef.GetAnimationVariableBool("isBashing") &&   !SelfRef.GetAnimationVariableBool("isSneaking")
			if !bUseCharges || hasCharge()
				if SelfRef.GetAnimationVariableFloat("Speed") == 0
					DLC2BloodskalBladeSpellVert.cast(SelfRef)
				else
					float direction = selfRef.GetAnimationVariableFloat( "Direction" )
					if (direction == 0.00 || direction == 1.00)
						DLC2BloodskalBladeSpellVert.cast(selfRef)
					;elseif (direction == 0.25 || direction == 0.75 || direction == 0.5)
					else
						DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
					endif
				endif
			endif
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, WeaponSwing)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Equipped2HGreatsword

	Event OnBeginState()
		registerForAnimationEvent(SelfRef, PWStanding2H)
		registerForAnimationEvent(SelfRef, PWRight2H)
		registerForAnimationEvent(SelfRef, PWLeft2H)
		registerForAnimationEvent(SelfRef, PWBackward2H)
		registerForAnimationEvent(SelfRef, PWForward2H)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if !bUseCharges || hasCharge()
			if EventName == PWStanding2H|| EventName == PWForward2H 
				DLC2BloodskalBladeSpellVert.cast(selfRef)
			;elseif EventName == PWBackward2H || EventName == PWRight2H || EventName == PWLeft2H
			else
				DLC2BloodskalBladeSpellHoriz.cast(SelfRef)
			endif
		endif
	EndEvent
	
	Event OnEndState()
		unregisterForAnimationEvent(SelfRef, PWStanding2H)
		unregisterForAnimationEvent(SelfRef, PWRight2H)
		unregisterForAnimationEvent(SelfRef, PWLeft2H)
		unregisterForAnimationEvent(SelfRef, PWBackward2H)
		unregisterForAnimationEvent(SelfRef, PWForward2H)
	EndEvent
	
EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Returns whether the necessary charges were obtained
bool function hasCharge()
	if ChargeMode == 0		; shared priority
		int shared = GetSharedCharge()
		if shared >= ChargeCost						; Attempts to use charges from shared first if available
			return RequestSharedCharge(ChargeCost)
		elseif shared + LocalCharge >= ChargeCost	
			RequestSharedCharge(shared)				; else uses remaining shared charges
			removeLocalCharge(ChargeCost - shared)	; and use local charges to complete chage cost
			return true
		endif
	elseif ChargeMode == 1	; local priority
		return removeLocalCharge(ChargeCost) || RequestSharedCharge(ChargeCost)
	elseif ChargeMode == 2	; local only
		return removeLocalCharge(ChargeCost) 
	endif
	return false
endfunction
;___________________________________________________________________________________________________________________________

; Removes and returns the number of requested charges from the local charge
int function removeLocalCharge(int iRequest)
	if iRequest > 0 && LocalCharge >= iRequest
		LocalCharge -= iRequest
		Debug.Notification("Bloodskal Charges: " +LocalCharge)
		RegisterForRecharge()
		return iRequest
	else
		return 0
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Adds charges up to max, and (un)registers recharge accordingly
function addLocalCharge(int charge = 1)
	if LocalCharge != MaxLocalCharge
		LocalCharge += charge
		if LocalCharge < MaxLocalCharge
			Debug.Notification("Bloodskal Charges: " +LocalCharge)
			RegisterForRecharge()
			return
		else
			LocalCharge = MaxLocalCharge
			Debug.Notification("Bloodskal Charges: " +LocalCharge)
		endif
	endif
	UnregisterForDistanceTravelledEvent()
	UnregisterForMagickaSiphonEvent()
endFunction
;___________________________________________________________________________________________________________________________

; Recharge from distance travelled
function OnDistanceTravelledEvent()
	addLocalCharge()
endfunction
;___________________________________________________________________________________________________________________________

; Recharge from magicak siphon
function OnMagickaSiphonEvent()
	addLocalCharge()
EndFunction
;___________________________________________________________________________________________________________________________

; Register for any recharge sources
Function RegisterForRecharge()
	RegisterForDistanceTravelledEvent(ChargeDistance)
	RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
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
		elseif aiButton == 3		; Turn On Charges
			bUseCharges = True
		elseif aiButton == 4		; Turn Off Charges
			bUseCharges = False
		elseif aiButton == 5		; Set ChargeMode
			ChargeMode = ListenerMenu.ChargeMode(ChargeMode, DEFChargeMode)
		elseif aiButton == 6		; Charge Options
			MenuChargeOptions(ListenerMenu)
		elseif aiButton == 7		; Set Priority
			ChargeMagickaPR = ListenerMenu.MagickaSiphonPriority(ChargeMagickaPR, DEFChargeMagickaPR)
		endif
	endwhile
EndFunction

; Updates the Button to show the correct menu options
Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
		Button.set(7)
	else
		Button.set(1)
		if bUseCharges
			Button.set(4)
			Button.set(6)
		else
			Button.set(3)
		endif
	endif
	Button.set(5)
	Button.set(7)
	Button.set(9)
EndFunction
;___________________________________________________________________________________________________________________________

Function MenuChargeOptions(INEQ_ListenerMenu ListenerMenu)
	bool abMenu = True
	int aiButton
	while abMenu
		aiButton = ChargeOptionsMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1	; Charge Cost
			ChargeCost = ListenerMenu.ChargeCost(ChargeCost, DEFChargeCost)
		elseif aiButton == 2	; Charge Storage
			MaxLocalCharge = ListenerMenu.ChargeStorage(MaxLocalCharge, DEFMaxLocalCharge)
			RegisterForRecharge()
		elseif aiButton == 3	; Recharge MP
			ChargeMagickaMP = ListenerMenu.MagickaSiphonCost(ChargeMagickaMP, DEFChargeMagickaMP)
		elseif aiButton == 4	; Recharge Distance
			ChargeDistance = ListenerMenu.DistanceTravelledCost(ChargeDistance, DEFChargeDistance)
		endif
	endwhile
EndFunction
