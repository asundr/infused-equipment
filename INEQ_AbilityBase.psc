Scriptname INEQ_AbilityBase extends INEQ_EventListenerBase Hidden
{Base object that disables/enables ability effects when un/equipping an infused item}

;===========================================  Properties  ===========================================================================>
Keyword			Property	KW_EnbaleAbility		Auto
ReferenceAlias	Property	AbilityAliasProperties	Auto
Actor			Property	SelfRef					Auto	Hidden
ObjectReference	Property	EquipRef				Auto	Hidden
;==========================================  Autoreadonly  ==========================================================================>

;===========================================  Variables  ============================================================================>

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Function EffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	SelfRef = akTarget
EndFunction

Function EffectFinish(Actor akTarget, Actor akCaster)
	UnregisterAbilityToAlias()
	parent.EffectFinish(akTarget, akCaster)
EndFunction

; Placeholder
Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

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
Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	Debug.Trace(self+ " attempted to access non-existent ability menu")
EndFunction
