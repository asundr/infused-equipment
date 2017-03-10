Scriptname INEQ_AddPerkOnEquipShield extends INEQ_AbilityBaseShield
{Adds the abilityes perk on equip}

;===========================================  Properties  ===========================================================================>
Perk	Property	SomePerk	Auto

;==========================================  Autoreadonly  ==========================================================================>


;===========================================  Variables  ============================================================================>


;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

;Event OnEffectFinish (Actor akTarget, Actor akCaster)
;	SelfRef.RemovePerk(somePerk)
;	parent.EffectFinish(akTarget, akCaster)
;EndEvent

Function EffectFinish(Actor akTarget, Actor akCaster)
	SelfRef.RemovePerk(somePerk)
	parent.EffectFinish(akTarget, akCaster)
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		SelfRef.AddPerk(somePerk)
	EndEvent
	
	Event OnEndState()
		SelfRef.RemovePerk(somePerk)
	EndEvent

EndState
