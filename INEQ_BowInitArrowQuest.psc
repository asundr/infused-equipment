Scriptname INEQ_BowInitArrowQuest extends INEQ_AbilityBase  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Quest Property ArrowAliasQuest Auto

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef
int count

;===============================================================================================================================
;====================================		  Start/Finish			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	ArrowAliasQuest.Stop()
	UnregisterForUpdate()
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float afPower, bool abSunGazing)
		ArrowAliasQuest.Stop()
		count = 0
		RegisterForSingleUpdate(0)
	EndEvent
	
	Event OnUpdate()
		if ArrowAliasQuest.IsStopped()
			ArrowAliasQuest.Start()
		else
			if count < 10
				RegisterForSingleUpdate(0.1)
			else
				Debug.MessageBox("Teleport is calibrating...")
			endif
		endif
	EndEvent
	
	Event OnEndState()
		UnregisterForUpdate()
	EndEvent
	
EndState
