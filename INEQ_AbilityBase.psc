Scriptname INEQ_AbilityBase extends INEQ_EventListenerBase Hidden

Keyword	Property	KW_EnbaleAbility	Auto
Actor	Property	SelfRef				Auto

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

Function UnequipCheck(ObjectReference akReference)
	if (akReference == EquipRef)
		EquipRef = none
		GoToState("Unequipped")
	endif
EndFunction
;___________________________________________________________________________________________________________________________

Function ResetState()
	if !EquipRef.HasKeyword(KW_EnbaleAbility)
		GoToState("Unequipped")
	endif
EndFunction
