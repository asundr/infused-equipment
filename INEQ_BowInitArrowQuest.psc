Scriptname INEQ_BowInitArrowQuest extends INEQ_AbilityBase  
{Starts and stops the quest that applies the teleport behaivior to an arrow}

;===========================================  Properties  ===========================================================================>
Message			Property	MainMenu		Auto
Quest			Property	ArrowAliasQuest	Auto
GlobalVariable	Property	ShoutTime		Auto
;==========================================  Autoreadonly  ==========================================================================>
int		Property	DEFShoutTime	=	20		Autoreadonly
float	Property	QuestStopStep	=	0.1		Autoreadonly
int		Property	CountMax		=	10		Autoreadonly
;===========================================  Variables  ============================================================================>
int count
bool bBalanced

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	ArrowAliasQuest.Stop()
	parent.EffectFinish(akTarget, akCaster)
EndEvent

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	bBalanced = True
	ShoutTime.SetValue(DEFShoutTime)
EndFunction

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

;===============================================================================================================================
;====================================		    Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		SetButtonMain(Button)
		aiButton = MainMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9		; Cancel Menu
			MenuActive.SetValue(0)
		elseif aiButton == 1		; Turn on Balanced
			RestoreDefaultFields()
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Shout cost -> On
			ShoutTime.SetValueInt(DEFShoutTime)
		elseif aiButton == 4		; Shout Cost -> Off
			ShoutTime.SetValue(0)
		elseif aiButton == 5		; Set Charge Time
			ShoutTime.Value = ListenerMenu.ChargeTime(ShoutTime.GetValueInt(), DEFShoutTime)
		endif
	endwhile
EndFunction

; Updates the Button to show the correct menu options
Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		Button.set(2)
	else
		Button.set(1)
		if ShoutTime.Value
			Button.set(4)
			Button.set(5)
		else
			Button.set(3)
		endif
	endif
	Button.set(9)
EndFunction
