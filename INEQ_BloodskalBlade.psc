Scriptname INEQ_BloodskalBlade extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell	Property	DLC2BloodskalBladeSpellHoriz	Auto
Spell	Property	DLC2BloodskalBladeSpellVert		Auto

ReferenceAlias	Property	SharedChargesAlias		Auto
ReferenceAlias	Property	DistanceTravelledAlias	Auto
ReferenceAlias	Property	MagickaSiphonAlias		Auto

Message	Property	MainMenu			Auto
Message	Property	ChargeModeMenu		Auto
Message Property	ChargeOptionsMenu	Auto
Message	Property	PriorityMenu		Auto
Message	Property	RechargeDistanceMenu Auto
Message	Property	RechargeMagickaMenu	Auto
Message	Property	ChargeStorageMenu	Auto
Message	Property	ChargeCostMenu		Auto

bool	Property	bBalanced		=	True	Auto	Hidden
bool	Property	bUseCharges		=	True	Auto	Hidden

int		Property	ChargeMode		=	0		Auto	Hidden	; 0=shared charges, 1=prioritize local, 2=only use local charges
Int		Property	LocalCharge		=	0		Auto	Hidden

Int 	Property	MaxLocalCharge	=	4		Auto	Hidden
Int		Property	ChargeCost		=	2		Auto	Hidden
float	Property	ChargeDistance	=	100.0	Auto	Hidden	; 1000.0, should be high relative to ChargeMagickaSiphon
float	Property	ChargeMagickaMP =	50.0	Auto	Hidden
int		Property	ChargeMagickaPR =	50		Auto	Hidden

int		Property	DEFMaxLocalCharge	=	4		Autoreadonly
int		Property	DEFChargeCost		=	2		Autoreadonly
float	Property	DEFChargeDistance	=	5000.0	Autoreadonly
float	Property	DEFChargeMagickaMP	=	2000.0	Autoreadonly
int		Property	DEFChargeMagickaPR	=	50		Autoreadonly


String  Property WeaponSwing  = 	"weaponSwing"  					Autoreadonly	; weapon attack
String	Property PWStanding2H	= 	"AttackPowerStanding_FXstart"	Autoreadonly
String	Property PWRight2H		= 	"AttackPowerRight_FXstart"		Autoreadonly
String	Property PWLeft2H		= 	"AttackPowerLeft_FXstart"		Autoreadonly
String	Property PWForward2H	= 	"AttackPowerForward_FXstart"	Autoreadonly
String	Property PWBackward2H	= 	"AttackPowerBackward_FXstart"	Autoreadonly

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

INEQ_SharedCharges SharedCharges
INEQ_DistanceTravelled DistanceTravelled
INEQ_MagickaSiphon MagickaSiphon

bool bRegisteredDT = False
bool bRegisteredMS = False

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	SharedCharges = SharedChargesAlias as INEQ_SharedCharges
	DistanceTravelled = DistanceTravelledAlias as INEQ_DistanceTravelled
	MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
	RegisterAbilityToAlias()
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	DistanceTravelled.UnregisterForEvent(Self)
	MagickaSiphon.UnregisterForEvent(self)
	UnregisterAbilityToAlias()
	unregisterForAnimationEvent(SelfRef, PWStanding2H)
	unregisterForAnimationEvent(SelfRef, PWRight2H)
	unregisterForAnimationEvent(SelfRef, PWLeft2H)
	unregisterForAnimationEvent(SelfRef, PWBackward2H)
	unregisterForAnimationEvent(SelfRef, PWForward2H)
	UnregisterForAnimationEvent(selfRef, WeaponSwing)
EndEvent

Event OnPlayerLoad()
	Maintenance()
EndEvent

Function Maintenance()
	if DistanceTravelled
		RegisterForDistanceTravelledEvent(ChargeDistance)
	else
		DistanceTravelled = DistanceTravelledAlias as INEQ_DistanceTravelled
		if DistanceTravelled
			RegisterForDistanceTravelledEvent(ChargeDistance)
		endif
	endif
	
	if MagickaSiphon
		RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
	else
		MagickaSiphon = MagickaSiphonAlias as INEQ_MagickaSiphon
		if MagickaSiphon
			RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
		endif
	endif
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
		Maintenance()
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

; Returs whether the necessary charges were obtained
bool function hasCharge()
	if ChargeMode == 0		;shared priority
		; Attempts to use both from shared first if available
		; else uses last from shared and a charge from local if available
		; else attempts to use both from local
		return SharedCharges.requestCharge(ChargeCost) || (LocalCharge > 0 && SharedCharges.requestCharge(1) && removeLocalCharge(1)) || removeLocalCharge(ChargeCost)
	elseif ChargeMode == 1	;local priority
		return removeLocalCharge(ChargeCost) || SharedCharges.requestCharge(ChargeCost)
	elseif ChargeMode == 2	;local only
		return removeLocalCharge(ChargeCost) 
	endif
	Debug.MessageBox("End of hasCharge")
endfunction
;___________________________________________________________________________________________________________________________

; Removes and returns the number of requested charges from the local charge
int function removeLocalCharge(int iRequest)
	if iRequest > 0 && LocalCharge >= iRequest
		LocalCharge -= iRequest
		Debug.Notification("Bloodskal Charges: " +LocalCharge)
		RegisterForDistanceTravelledEvent(ChargeDistance)
		RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
		return iRequest
	else
		return 0
	endif
EndFunction

function addLocalCharge(int charge = 1)
	if LocalCharge != MaxLocalCharge
		LocalCharge += charge
		if LocalCharge < MaxLocalCharge
			Debug.Notification("Bloodskal Charges: " +LocalCharge)
			RegisterForDistanceTravelledEvent(ChargeDistance)
			RegisterForMagickaSiphonEvent(ChargeMagickaMP, ChargeMagickaPR)
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

function OnDistanceTravelledEvent()
	bRegisteredDT = False
	addLocalCharge()
endfunction

function RegisterForDistanceTravelledEvent(float akDistance)
	if !bRegisteredDT && LocalCharge < MaxLocalCharge
		bRegisteredDT = DistanceTravelled.RegisterForEvent(self, akDistance)
	endif
Endfunction

Function UnregisterForDistanceTravelledEvent()
	if bRegisteredDT
		bRegisteredDT	= False
		bRegisteredDT = DistanceTravelled.UnregisterForEvent(self)
	endif
EndFunction
;___________________________________________________________________________________________________________________________

function OnMagickaSiphonEvent()
	bRegisteredMS = False
	addLocalCharge()
EndFunction

function RegisterForMagickaSiphonEvent(float akMagicka, int akPriority)
	if !bRegisteredMS && LocalCharge < MaxLocalCharge
		bRegisteredMS = MagickaSiphon.RegisterForEvent(self, akMagicka, akPriority)
	endif
endfunction

Function UnregisterForMagickaSiphonEvent()
	if bRegisteredMS
		bRegisteredMS = False
		MagickaSiphon.UnregisterForEvent(self)
	endif
endfunction

;===============================================================================================================================
;====================================		    Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button = none)
	bool abMenu = True
	int aiButton
	while abMenu
		SetButtonMain(Button)
		aiButton = MainMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1		; Turn on Balanced
			bBalanced = True
			bUseCharges = True
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Turn On Charges
			bUseCharges = True
		elseif aiButton == 4		; Turn Off Charges
			bUseCharges = False
		elseif aiButton == 5		; Set ChargeMode
			MenuChargeMode(Button)
		elseif aiButton == 6		; Charge Options
			MenuChargeOptions()
		elseif aiButton == 7		; Set Priority
			MenuPriority()
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
			Button.set(5)
			Button.set(6)
			Button.set(7)
		else
			Button.set(3)
		endif
	endif
EndFunction
;___________________________________________________________________________________________________________________________
; Selects how the blade will use charges between the local and shared pool
; 0=shared charges, 1=prioritize local, 2=only use local charges
Function MenuChargeMode(INEQ_MenuButtonConditional Button)
	bool abMenu = True
	int aiButton
	while abMenu
		SetButtonChargeMode(Button)
		aiButton = ChargeModeMenu.Show()
		if aiButton == 0
			return
		else		
			ChargeMode = aiButton - 1
		endif
	endwhile
EndFunction

Function SetButtonChargeMode(INEQ_MenuButtonConditional Button)
	Button.clear()
	if ChargeMode == 0
		Button.set(2)
		Button.set(3)
	elseif ChargeMode == 1
		Button.set(1)
		Button.Set(3)
	elseif ChargeMode == 2
		Button.set(1)
		Button.set(2)
	endif
EndFunction
;___________________________________________________________________________________________________________________________

Function MenuChargeOptions()
	bool abMenu = True
	int aiButton
	while abMenu
		aiButton = ChargeOptionsMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1	; Charge Cost DONT USE UNTIL HASCHARGE() GENARALIZED
			MenuChargeCost()
			Debug.Notification("Option not available")
		elseif aiButton == 2	; Charge Storage
			MenuChargeStorage()
		elseif aiButton == 3	; Recharge MP
			MenuMSCost()
		elseif aiButton == 4	; Recharge Distance
			MenuDTCost()
		endif
	endwhile
EndFunction

Function MenuChargeCost()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent charge cost: " +ChargeCost)
		aiButton = ChargeCostMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			ChargeCost -= 50
		elseif aiButton == 2
			ChargeCost -= 10
		elseif aiButton == 3
			ChargeCost -= 5
		elseif aiButton == 4
			ChargeCost -= 1
		elseif aiButton == 5
			ChargeCost += 1
		elseif aiButton == 6
			ChargeCost += 5
		elseif aiButton == 7
			ChargeCost += 10
		elseif aiButton == 8
			ChargeCost += 50
		elseif aiButton == 9
			ChargeCost = DEFChargeCost
		endif
		if ChargeCost < 1
			ChargeCost = 1
		endif
	endwhile
EndFunction

Function MenuChargeStorage()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent local charge storage: " +MaxLocalCharge)
		aiButton = ChargeStorageMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			MaxLocalCharge -= 50
		elseif aiButton == 2
			MaxLocalCharge -= 10
		elseif aiButton == 3
			MaxLocalCharge -= 5
		elseif aiButton == 4
			MaxLocalCharge -= 1
		elseif aiButton == 5
			MaxLocalCharge += 1
		elseif aiButton == 6
			MaxLocalCharge += 5
		elseif aiButton == 7
			MaxLocalCharge += 10
		elseif aiButton == 8
			MaxLocalCharge += 50
		elseif aiButton == 9
			MaxLocalCharge = DEFMaxLocalCharge
		endif
		if MaxLocalCharge < 1
			MaxLocalCharge = 1
		endif
	endwhile
EndFunction

Function MenuMSCost()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent magicka siphon cost: " +ChargeMagickaMP)
		aiButton = RechargeMagickaMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			ChargeMagickaMP -= 1000.0
		elseif aiButton == 2
			ChargeMagickaMP -= 100.0
		elseif aiButton == 3
			ChargeMagickaMP -= 50.0
		elseif aiButton == 4
			ChargeMagickaMP -= 10.0
		elseif aiButton == 5
			ChargeMagickaMP += 10.0
		elseif aiButton == 6
			ChargeMagickaMP += 50.0
		elseif aiButton == 7
			ChargeMagickaMP += 100.0
		elseif aiButton == 8
			ChargeMagickaMP += 1000.0
		elseif aiButton == 9
			ChargeMagickaMP = DEFChargeMagickaMP
		endif
		if ChargeMagickaMP < 1.0
			ChargeMagickaMP = 1.0
		endif
	endwhile
EndFunction

Function MenuDTCost()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent recharge distance: " +ChargeDistance)
		aiButton = RechargeDistanceMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			ChargeDistance -= 10000.0
		elseif aiButton == 2
			ChargeDistance -= 1000.0
		elseif aiButton == 3
			ChargeDistance -= 100.0
		elseif aiButton == 4
			ChargeDistance -= 50.0
		elseif aiButton == 5
			ChargeDistance += 50.0
		elseif aiButton == 6
			ChargeDistance += 100.0
		elseif aiButton == 7
			ChargeDistance += 1000.0
		elseif aiButton == 8
			ChargeDistance += 10000.0
		elseif aiButton == 9
			ChargeDistance = DEFChargeDistance
		endif
		if ChargeDistance < 50.0
			ChargeDistance = 50.0
		endif
	endwhile
EndFunction

;___________________________________________________________________________________________________________________________

; Allows player to set priority for magicka siphon, migher means sooner
Function MenuPriority()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent priority: " +ChargeMagickaPR)
		aiButton = PriorityMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			ChargeMagickaPR -= 50
		elseif aiButton == 2
			ChargeMagickaPR -= 10
		elseif aiButton == 3
			ChargeMagickaPR -= 5
		elseif aiButton == 4
			ChargeMagickaPR -= 1
		elseif aiButton == 5
			ChargeMagickaPR += 1
		elseif aiButton == 6
			ChargeMagickaPR += 5
		elseif aiButton == 7
			ChargeMagickaPR += 10
		elseif aiButton == 8
			ChargeMagickaPR += 50
		elseif aiButton == 9
			ChargeMagickaPR = DEFChargeMagickaPR
		endif
	endwhile
EndFunction
