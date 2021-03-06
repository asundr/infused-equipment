Scriptname INEQ_AddAbilityOnEquip extends INEQ_AbilityBase  

;===========================================  Properties  ===========================================================================>
Spell	Property	AbilitySpell	Auto

;==========================================  Autoreadonly  ==========================================================================>


;===========================================  Variables  ============================================================================>


;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

;Event OnEffectFinish (Actor akTarget, Actor akCaster)
;	SelfRef.removespell(AbilitySpell)
;	parent.EffectFinish(akTarget, akCaster)
;EndEvent

Function EffectFinish(Actor akTarget, Actor akCaster)
	SelfRef.removespell(AbilitySpell)
	parent.EffectFinish(akTarget, akCaster)
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		SelfRef.addSpell(AbilitySpell, false)
	EndEvent

	Event OnEndState()
		SelfRef.removespell(AbilitySpell)
	EndEvent

EndState
