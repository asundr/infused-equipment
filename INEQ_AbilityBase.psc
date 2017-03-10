Scriptname INEQ_AbilityBase extends INEQ_EventListenerBase Hidden

Keyword		Property	KW_EnbaleAbility		Auto
Actor		Property	SelfRef					Auto
ReferenceAlias	Property	AbilityAliasProperties	Auto



ObjectReference EquipRef

;Event OnEffectStart (Actor akTarget, Actor akCaster)
;	SelfRef = akCaster
;	GoToState( "Unequipped")
;EndEvent

Auto State Unequipped
	
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		EquipCheckKW(akReference)
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
EndState

State Equipped
EndState

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

; Checks to see if the passed item has the correct keyword and, if so, enable's the ability
Function EquipCheckKW(ObjectReference akReference)
	if akReference && akReference.HasKeyword(KW_EnbaleAbility)
		EquipRef = akReference
		GoToState("Equipped")
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; All but the Unequipped state require this. the Unequipped state has an empty override
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	UnequipCheck(akReference)
EndEvent

; Checks the passed unequipped item matches the refereence of this ability's item and, if so, disables the ability
Function UnequipCheck(ObjectReference akReference)
	if (akReference == EquipRef)
		EquipRef = none
		GoToState("Unequipped")
	endif
EndFunction
;___________________________________________________________________________________________________________________________
; Register's this ability with it's associated AbilityAliasProperties. Should be used in OnEffectStart()
; Only use this if implementing a menu for the ability
Function RegisterAbilityToAlias()
	if AbilityAliasProperties
		(AbilityAliasProperties as INEQ_AbilityAliasProperties).RegisterAbility(self)
	endif
EndFunction
;___________________________________________________________________________________________________________________________
; Unregisters this ability from the Alias. Should be used in OnEffectFinish()
; Only use this if implementing a menu for the ability
Function UnregisterAbilityToAlias()
	if AbilityAliasProperties
		(AbilityAliasProperties as INEQ_AbilityAliasProperties).UnregisterAbility()
	endif
EndFunction
;___________________________________________________________________________________________________________________________

; Menu palceholder - should be overriden by implementation of ability's menu
Function AbilityMenu(INEQ_MenuButtonConditional Button = none)
	Debug.Trace(self+ " attempted to access non-existent ability menu")
EndFunction
;___________________________________________________________________________________________________________________________

; currently unused
Function ResetState()
	if !EquipRef.HasKeyword(KW_EnbaleAbility)
		GoToState("Unequipped")
	endif
EndFunction
