Scriptname INEQ_BowInitArrowQuest extends INEQ_AbilityBase  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Quest Property ArrowAliasQuest Auto

;==========================================  Autoreadonly  ==========================================================================>
float	Property	QuestStopStep	=	0.1	Autoreadonly
int		Property	CountMax		=	10	Autoreadonly

;===========================================  Variables  ============================================================================>
int count

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	ArrowAliasQuest.Stop()
	parent.EffectFinish(akTarget, akCaster)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	; Stops the Quest containing the Arrow alias the registers to restart it
	Event OnPlayerBowShot(Weapon akWeapon, Ammo akAmmo, float afPower, bool abSunGazing)
		ArrowAliasQuest.Stop()
		count = 0
		RegisterForSingleUpdate(0)
	EndEvent
	
	; Attempts to restart the Quest containing the arrow alias
	Event OnUpdate()
		if ArrowAliasQuest.IsStopped()
			ArrowAliasQuest.Start()
		else
			if count < CountMax
				RegisterForSingleUpdate(QuestStopStep)
			else
				Debug.Trace(self+ ": ArrowAliasQuest did not stop within " +(QuestStopStep*CountMax)+ " second(s)")
			endif
		endif
	EndEvent
	
	Event OnEndState()
		UnregisterForUpdate()
	EndEvent
	
EndState
