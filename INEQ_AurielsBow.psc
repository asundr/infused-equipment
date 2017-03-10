Scriptname INEQ_AurielsBow  extends INEQ_AbilityBase 
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Message	Property	OptionsMenu	Auto

GlobalVariable	Property	DLC1EclipseActive	Auto  
GlobalVariable	Property	GameHour			Auto  

Spell	Property	DLC1AurielsBowSunAttackSpell	Auto
Spell	Property	DLC1AurielsBowEclipseSpell		Auto

Ammo	Property	DLC1ElvenArrowBlood		Auto  
Ammo	Property	DLC1ElvenArrowBlessed	Auto

ImageSpaceModifier	property	LightImodFX	Auto
ImageSpaceModifier	property	DarkImodFX	Auto

FormList	Property	SunAffectingWorldspaces	Auto  

bool	Property	bBalanced		Auto	Hidden

Float	Property	ChargeDistance	Auto	Hidden
int		Property	ChargeTime		Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
Float	Property	DEFChargeDistance	=	100.0	Autoreadonly	; in feet ; 2000.0
int		Property	DEFChargeTime		=	600		Autoreadonly

int		Property	EclipseResetTime	=	20		Autoreadonly	; 24 HourTime (default 20 = 8pm)

String	Property	BowDraw		=	"bowDraw"		Autoreadonly
String	Property	ArrowFired	=	"attackStop"	Autoreadonly

;===========================================  Variables  ============================================================================>
ImageSpaceModifier MyImageSpace = None
bool bRecharged
bool bUseCharges
bool bUseTimer

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	RegisterAbilityToAlias()
	RegisterForDistanceTravelledEvent(ChargeDistance)
EndEvent

Function RestoreDefaultFields()
	bBalanced		= True
	bRecharged		= False
	bUseCharges		= True
	bUseTimer		= False
	ChargeDistance	= DEFChargeDistance
	ChargeTime		= DEFChargeTime
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, BowDraw)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		GoToState("ArrowNocked")
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, BowDraw)
	EndEvent
	
EndState

;___________________________________________________________________________________________________________________________

State ArrowNocked

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, ArrowFired)
		GetSunGazeImod()
	EndEvent
	
	Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float akBowDraw, bool abSunGazing)
		if abSunGazing == True && DLC1EclipseActive.Value == 0 && akBowDraw >= 0.95
			if  SelfRef.IsSneaking()
				DLC1AurielsBowEclipseSpell.Cast(SelfRef, SelfRef)
				RegisterForSingleUpdateGameTime(EclipseResetTime - GameHour.Value)
				DLC1EclipseActive.Value = 1.0
			else
				if 	akAmmo == DLC1ElvenArrowBlessed
					DLC1AurielsBowSunAttackSpell.Cast(SelfRef, SelfRef)
				elseif !bUseCharges
					DLC1AurielsBowSunAttackSpell.Cast(SelfRef, SelfRef)
				elseif bRecharged
					DLC1AurielsBowSunAttackSpell.Cast(SelfRef, SelfRef)
					bRecharged = false
					RegisterRecharge()
				endif
			endif
		endif
;Debug.Notification("Exit Nocked via OnPlayerBowShot")
		GoToState("Equipped")
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
;Debug.Notification("Exit Nocked via AnimationEvent")
		Utility.Wait(0.1)
		GoToState("Equipped")
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(Game.GetPlayer(), ArrowFired)
		GetSunGazeImod(False)
	EndEvent

EndState

;===============================================================================================================================
;=======================================	   Functions		===================================================
;================================================================================================

;event for clearskies spell to reset eclipse

; Alters the sunglare corresponding to the sunburst/eclipse ability depending on the player's sneak state
ImageSpaceModifier Function GetSunGazeImod(bool activate = True)
	if activate
		if SelfRef.IsSneaking()
			MyImageSpace = DarkImodFX
		else
			if bRecharged
				MyImageSpace = LightImodFX
			else
				MyImageSpace = None
			endif
		endif
	else
		MyImageSpace = None
	endif
	Game.SetSunGazeImageSpaceModifier(MyImageSpace)
EndFunction
;___________________________________________________________________________________________________________________________

Function RegisterRecharge()
	if bUseTimer
		RegisterForSingleUpdate(ChargeTime)
	else
		RegisterForDistanceTravelledEvent(ChargeDistance)
	endif
EndFunction
;___________________________________________________________________________________________________________________________

Function ReRegisterRecharge()
	UnregisterForUpdate()
	UnregisterForDistanceTravelledEvent()
	RegisterRecharge()
EndFunction
;___________________________________________________________________________________________________________________________

; Recharges Auriel's sunburst after a predefined Distance travelled
Function OnDistanceTravelledEvent()
	bRecharged = True
	Debug.Notification("Auriel's sunburst recharged")
EndFunction

; Recharges Auriel's sunburst after a predefined time
Event OnUpdate()
	bRecharged = True
	Debug.Notification("Auriel's sunburst recharged")
EndEvent
;___________________________________________________________________________________________________________________________

; Resets the eclipse at a predetermined gamehour
Event OnUpdateGameTime()
	ResetEclipse()
EndEvent

; Removes the eclipse's visuals and effect
Function ResetEclipse()
	DLC1EclipseActive.Value = 0
	SelfRef.DispelSpell(DLC1AurielsBowEclipseSpell)
EndFunction

;===============================================================================================================================
;====================================			Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		setButtonMain(Button)
		aiButton = OptionsMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9	; Cancel menu
			MenuActive.SetValue(0)
		elseif aiButton == 1	; Turn on Balanced (Magicka Based)
			RestoreDefaultFields()
		elseif aiButton == 2	; Turn off Balanced (Cooldown Based)
			bBalanced = False
		elseif aiButton == 3	; Turn on charges
			bUseCharges = True
			bRecharged = True
		elseif aiButton == 4	; Turn off charges
			bUseCharges = False
			ReRegisterRecharge()
		elseif aiButton == 5	; Turn on timer
			bUseTimer = True
			ReRegisterRecharge()
		elseif aiButton == 6	; Turn off timer (use distance)
			bUseTimer = False
			ReRegisterRecharge()
		elseif aiButton == 7	; Set Distance
			ChargeDistance = ListenerMenu.DistanceTravelledCost(ChargeDistance, DEFChargeDistance)
			ReRegisterRecharge()
		elseif aiButton == 8	; Set time
			ChargeTime = ListenerMenu.ChargeTime(ChargeTime, DEFChargeTime)
			ReRegisterRecharge()
		endif
	endwhile
EndFunction

Function setButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
	else
		Button.set(1)
		if bUseCharges
			Button.set(4)
			if bUseTimer
				Button.set(6)
				Button.set(8)
			else
				Button.set(5)
				Button.set(7)
			endif
		else
			Button.set(3)
		endif
	endif
	Button.set(9)
EndFunction
