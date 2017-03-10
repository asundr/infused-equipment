Scriptname INEQ_AurielsBow  extends ActiveMagicEffect 
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto

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

String  Property  BowDraw = "bowDraw"  autoreadonly
String  Property  ArrowFired = "attackStop"  autoreadonly

;===========================================  Variables  ============================================================================>

Actor selfRef
ObjectReference EquipRef
ImageSpaceModifier MyImageSpace = None

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectStart (Actor akTarget, Actor akCaster)
;	Debug.Notification("Ability added")
	selfRef = akCaster
	GoToState( "Unequipped")
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Off

EndState

State Unequipped
	
	Event OnBeginState()
		
	EndEvent
	
	Event OnUpdateGameTime()
		ResetEclipse()
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		EquipCheckKW(akReference)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Equipped
	
	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, BowDraw)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		GoToState("ArrowNocked")
	EndEvent
	
	Event OnUpdateGameTime()
		ResetEclipse()
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, BowDraw)
	EndEvent
	
EndState

State ArrowNocked

	Event OnBeginState()
Debug.Notification("Enter Nocked")
		RegisterForAnimationEvent(Game.GetPlayer(), ArrowFired)
		GetSunGazeImod()
	EndEvent
	
	Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float akBowDraw, bool abSunGazing)
		if abSunGazing == True && DLC1EclipseActive.Value == 0 && akBowDraw >= 0.95
			if  SelfRef.IsSneaking()
				DLC1AurielsBowEclipseSpell.Cast(SelfRef, SelfRef)
				RegisterForSingleUpdateGameTime(20 - GameHour.Value)
				DLC1EclipseActive.Value = 1.0
			else
				DLC1AurielsBowSunAttackSpell.Cast(SelfRef, SelfRef)
			endif
		endif
Debug.Notification("Exit Nocked via OnPlayerBowShot")
		GoToState("Equipped")
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
Debug.Notification("Exit Nocked via AnimationEvent")
		Utility.Wait(0.1)
		GoToState("Equipped")
	EndEvent
	
	Event OnUpdateGameTime()
		ResetEclipse()
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(Game.GetPlayer(), ArrowFired)
		GetSunGazeImod(False)
	EndEvent


EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

Function ResetEclipse()
	DLC1EclipseActive.Value = 0
	SelfRef.DispelSpell(DLC1AurielsBowEclipseSpell)
EndFunction

;___________________________________________________________________________________________________________________________

ImageSpaceModifier Function GetSunGazeImod(bool activate = True)
	if activate
		if SelfRef.IsSneaking()
;			Debug.Trace("Imod is Dark!")
			MyImageSpace = DarkImodFX
		else
;			Debug.Trace("Imod is Light!")
			MyImageSpace = LightImodFX
		endif
	else
		MyImageSpace = None
	endif
	Game.SetSunGazeImageSpaceModifier(MyImageSpace)
EndFunction

;___________________________________________________________________________________________________________________________

Function EquipCheckKW(ObjectReference akReference)
;	Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
;	Debug.Notification("ME-Alias: " +Alias_Armour.GetReference().getFormID()+ ", HasKeyword: " + Alias_Armour.GetReference().HasKeyword(KW_EnbaleAbility) )
	if akReference.HasKeyword(KW_EnbaleAbility)
;		Debug.Notification("KW found: Ability effect active")
		EquipRef = akReference
		GoToState("Equipped")
;	else
;		Debug.Notification("Missing KW: Effect not activated")
	endif
EndFunction

;___________________________________________________________________________________________________________________________

Function UnequipCheck(ObjectReference akReference)
;		Debug.Notification("Unequip event...")
		if (akReference == EquipRef)
;			Debug.Notification("Unequipped, effect disabled")
			EquipRef = none
			GoToState("Unequipped")
;		else
;			Debug.Notification("(" +akReference.getFormID()+ ") Not the equipped ref")
		endif
EndFunction

;===============================================================================================================================
;====================================		   Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	
EndEvent

