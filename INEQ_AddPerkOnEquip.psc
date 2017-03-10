Scriptname INEQ_AddPerkOnEquip extends ActiveMagicEffect  
{Adds the abilityes perk on equip}

;===========================================  Properties  ===========================================================================>

Keyword property KW_EnbaleAbility auto
Perk  Property  somePerk  auto

;===========================================  Variables  ============================================================================>

Actor selfRef
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

	Event OnBeginState()
		SelfRef.RemovePerk(somePerk)
	EndEvent
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		EquipCheckKW(akReference)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Equipped
	
	Event OnBeginState()
		SelfRef.AddPerk(somePerk)
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		UnequipCheck(akReference)
	EndEvent

EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

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
	SelfRef.RemovePerk(somePerk)
EndEvent