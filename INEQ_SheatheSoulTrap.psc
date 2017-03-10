Scriptname INEQ_SheatheSoulTrap extends activemagiceffect  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto
Spell property SheathSpell auto

String  Property  WeaponSheathe  = 	"WeaponSheathe"  	Autoreadonly		; weapon sheathed


;===========================================  Variables  ============================================================================>

Actor SelfRef
ObjectReference EquipRef

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

;___________________________________________________________________________________________________________________________

State Unequipped
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
;		Debug.Notification("equip")
		EquipCheckKW(akReference)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Equipped
	
	Event OnBeginState()
		RegisterForAnimationEvent(selfRef, WeaponSheathe)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
;			Debug.Notification("Weapon is sheathed")
			SheathSpell.cast(selfRef, selfRef)
	EndEvent

	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent
	
	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, WeaponSheathe)
	EndEvent

EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

Function EquipCheckKW(ObjectReference akReference)
;	Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
;	Debug.Notification("ME-Alias: " +Alias_Armour.GetReference().getFormID()+ ", HasKeyword: " + Alias_Armour.GetReference().HasKeyword(KW_EnbaleAbility) )
	if akReference.HasKeyword(KW_EnbaleAbility)
;		Debug.Notification("KW found")
		EquipRef = akReference
		GoToState("Equipped")
;	else
;		Debug.Notification("Missing KW")
	endif
EndFunction

;___________________________________________________________________________________________________________________________

Function UnequipCheck(ObjectReference akReference)
;		Debug.Notification("Unequip event...")
		Debug.Notification("ME-Reference: " +akReference.getformid()+ ", HasKeyword " +akReference.HasKeyword(KW_EnbaleAbility))
		if (akReference == EquipRef)
;			Debug.Notification("Unequipped, effect disabled")
			EquipRef = none
			GoToState("Unequipped")
;		else
;			Debug.Notification("(" +akReference.getFormID()+ ") Not the equipped ref")
		endif
EndFunction

;___________________________________________________________________________________________________________________________

Function ResetState()
	if !EquipRef.HasKeyword(KW_EnbaleAbility)
		GoToState("Unequipped")
	endif
EndFunction

;===============================================================================================================================
;====================================		   Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForAnimationEvent(selfRef, WeaponSheathe)
EndEvent