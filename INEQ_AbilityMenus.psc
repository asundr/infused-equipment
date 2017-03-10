ScriptName	INEQ_AbilityMenus	extends	Quest
{}

;===========================================  Properties  ===========================================================================>
Message	Property	ChargeModeMenu		Auto
Message	Property	PriorityMenu		Auto
Message	Property	RechargeDistanceMenu Auto
Message	Property	RechargeMagickaMenu	Auto
Message	Property	ChargeStorageMenu	Auto
Message	Property	ChargeCostMenu		Auto


INEQ_MenuButtonConditional Button

;===============================================================================================================================
;====================================		  Start/Finish		================================================
;================================================================================================

Event OnInit()
	Button = (self as Quest) as INEQ_MenuButtonConditional;self.GetQuest() as INEQ_MenuButtonConditional
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

Function ChargeCost(int value, int default = 100)
	int aiButton
	int modifier = 0
	while True
		Debug.Notification("Currrent charge cost: " +(value + modifier))
		aiButton = ChargeCostMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			modifier -= 50
		elseif aiButton == 2
			modifier -= 10
		elseif aiButton == 3
			modifier -= 5
		elseif aiButton == 4
			modifier -= 1
		elseif aiButton == 5
			modifier += 1
		elseif aiButton == 6
			modifier += 5
		elseif aiButton == 7
			modifier += 10
		elseif aiButton == 8
			modifier += 50
		elseif aiButton == 9
			modifier = default
		endif
		if value + modifier < 1
			modifier = 1 - value
		endif
	endwhile
EndFunction
