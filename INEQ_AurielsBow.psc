Scriptname INEQ_AurielsBow  extends INEQ_AbilityBase 
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
GlobalVariable Property DLC1EclipseActive  Auto  
GlobalVariable Property GameHour  Auto  

Spell Property DLC1AurielsBowSunAttackSpell Auto
Spell Property DLC1AurielsBowEclipseSpell Auto

Ammo Property DLC1ElvenArrowBlood  Auto  
Ammo Property DLC1ElvenArrowBlessed  Auto

FormList Property SunAffectingWorldspaces  Auto  

ImageSpaceModifier property LightImodFX auto
{Light spell iMod for spell}
ImageSpaceModifier property DarkImodFX auto
{Dark spell iMod for spell}

ReferenceAlias	Property	AliasDT	Auto

String  Property  BowDraw 	= 	"bowDraw"  		autoreadonly
String  Property  ArrowFired = 	"attackStop"  	autoreadonly

Float	Property	ChargeDistance	=	200.0	Autoreadonly

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef
ImageSpaceModifier MyImageSpace = None
INEQ_DistanceTravelled DT
bool sunCharged

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	DT = AliasDT as INEQ_DistanceTravelled
	sunCharged = false
	DT.RegisterForEvent(self , ChargeDistance)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Ready
	
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
				RegisterForSingleUpdateGameTime(20 - GameHour.Value)
				DLC1EclipseActive.Value = 1.0
			elseif sunCharged
				DLC1AurielsBowSunAttackSpell.Cast(SelfRef, SelfRef)
				sunCharged = false
				DT.RegisterForEvent(self , ChargeDistance)
			endif
		endif
;Debug.Notification("Exit Nocked via OnPlayerBowShot")
		GoToState("Ready")
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
;Debug.Notification("Exit Nocked via AnimationEvent")
		Utility.Wait(0.1)
		GoToState("Ready")
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(Game.GetPlayer(), ArrowFired)
		GetSunGazeImod(False)
	EndEvent

EndState

ImageSpaceModifier Function GetSunGazeImod(bool activate = True)
	if activate
		if SelfRef.IsSneaking()
			MyImageSpace = DarkImodFX
		else
			MyImageSpace = LightImodFX
		endif
	else
		MyImageSpace = None
	endif
	Game.SetSunGazeImageSpaceModifier(MyImageSpace)
EndFunction

;===============================================================================================================================
;====================================	   Ext Functions		================================================
;================================================================================================

;event for clearskies speel to rest eclipse


Function OnDistanceTravelledEvent()
	sunCharged = True
	Debug.Notification("Auriel's sunburst recharged")
EndFunction

Event OnUpdateGameTime()
	ResetEclipse()
EndEvent

Function ResetEclipse()
	DLC1EclipseActive.Value = 0
	SelfRef.DispelSpell(DLC1AurielsBowEclipseSpell)
EndFunction
