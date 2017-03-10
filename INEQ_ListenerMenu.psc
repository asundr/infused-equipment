ScriptName	INEQ_ListenerMenu	extends	Quest
{Library of reusable menus to modify common properties}

;===========================================  Properties  ===========================================================================>
Message	Property	ChargeModeMenu		Auto
Message	Property	PriorityMenu		Auto
Message	Property	RechargeDistanceMenu Auto
Message	Property	RechargeMagickaMenu	Auto
Message	Property	ChargeStorageMenu	Auto
Message	Property	ChargeCostMenu		Auto
Message Property	TimeOptions			Auto
Message	Property	PercentageMenu		Auto

;==========================================  Autoreadonly  ==========================================================================>

;===========================================  Variables  ============================================================================>
INEQ_MenuButtonConditional Button

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	Button = (self as Quest) as INEQ_MenuButtonConditional
EndEvent

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

int Function ChargeCost(int value, int default = 100)
	int aiButton
	int modifier = 0
	while True
		Debug.Notification("Currrent charge cost: " +(value + modifier))
		aiButton = ChargeCostMenu.Show()
		if aiButton == 0
			return value + modifier
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
			modifier = default - value
		endif
		if value + modifier < 1
			modifier = 1 - value
		endif
	endwhile
EndFunction

;___________________________________________________________________________________________________________________________

int Function ChargeStorage(int value, int default = 5)
	int aiButton
	int modifier = 0
	while True
		Debug.Notification("Currrent local charge storage: " +(value + modifier))
		aiButton = ChargeStorageMenu.Show()
		if aiButton == 0
			return value + modifier
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
			modifier = default - value
		endif
		if value + modifier < 1
			modifier = 1 - value
		endif
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

; Selects how the blade will use charges between the local and shared pool
; 0=shared charges, 1=prioritize local, 2=only use local charges
int Function ChargeMode(int value, int default = 0)
	int aiButton
	while True
		SetButtonChargeMode(value)
		aiButton = ChargeModeMenu.Show()
		if aiButton == 0
			return value
		elseif aiButton == 4
			value = default
		else		
			value = aiButton - 1
		endif
	endwhile
EndFunction

Function SetButtonChargeMode(int ChargeMode)
	Button.clear()
	if ChargeMode == 0
		Button.set(2)
		Button.set(3)
	elseif ChargeMode == 1
		Button.set(1)
		Button.Set(3)
	elseif ChargeMode == 2
		Button.set(1)
		Button.set(2)
	endif
	Button.set(4)
EndFunction
;___________________________________________________________________________________________________________________________

float Function MagickaSiphonCost(float value, float default = 10.0)
	int aiButton
	while True
		Debug.Notification("Currrent magicka siphon cost: " +value+ " MP")
		aiButton = RechargeMagickaMenu.Show()
		if aiButton == 0
			return value
		elseif aiButton == 1
			value -= 1000.0
		elseif aiButton == 2
			value -= 100.0
		elseif aiButton == 3
			value -= 50.0
		elseif aiButton == 4
			value -= 10.0
		elseif aiButton == 5
			value += 10.0
		elseif aiButton == 6
			value += 50.0
		elseif aiButton == 7
			value += 100.0
		elseif aiButton == 8
			value += 1000.0
		elseif aiButton == 9
			value = default
		endif
		if value < 1.0
			value = 1.0
		endif
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

float Function DistanceTravelledCost(float value, float default = 100.0)
	int aiButton
	while True
		Debug.Notification("Currrent recharge distance: " +value+ " feet")
		aiButton = RechargeDistanceMenu.Show()
		if aiButton == 0
			return value
		elseif aiButton == 1
			value -= 10000.0
		elseif aiButton == 2
			value -= 1000.0
		elseif aiButton == 3
			value -= 100.0
		elseif aiButton == 4
			value -= 50.0
		elseif aiButton == 5
			value += 50.0
		elseif aiButton == 6
			value += 100.0
		elseif aiButton == 7
			value += 1000.0
		elseif aiButton == 8
			value += 10000.0
		elseif aiButton == 9
			value = default
		endif
		if value < 50.0
			value = 50.0
		endif
	endwhile
EndFunction

;___________________________________________________________________________________________________________________________

; Allows player to set priority for magicka siphon, migher means sooner
int Function MagickaSiphonPriority(int value, int default = 0)
	int aiButton
	while True
		Debug.Notification("Currrent priority: " +value)
		aiButton = PriorityMenu.Show()
		if aiButton == 0
			return value
		elseif aiButton == 1
			value -= 50
		elseif aiButton == 2
			value -= 10
		elseif aiButton == 3
			value -= 5
		elseif aiButton == 4
			value -= 1
		elseif aiButton == 5
			value += 1
		elseif aiButton == 6
			value += 5
		elseif aiButton == 7
			value += 10
		elseif aiButton == 8
			value += 50
		elseif aiButton == 9
			value = default
		endif
	endwhile
EndFunction
;___________________________________________________________________________________________________________________________

; Allows player to set time for cooldown
int Function ChargeTime(int value, int default = 0)
	int aiButton
	while True
		Debug.Notification("Currrent charge time: " +value+ " seconds")
		aiButton = TimeOptions.Show()
		if aiButton == 0
			return value
		elseif aiButton == 1
			value -= 1000
		elseif aiButton == 2
			value -= 100
		elseif aiButton == 3
			value -= 10
		elseif aiButton == 4
			value -= 1
		elseif aiButton == 5
			value += 1
		elseif aiButton == 6
			value += 10
		elseif aiButton == 7
			value += 100
		elseif aiButton == 8
			value += 1000
		elseif aiButton == 9
			value = default
		endif
		if value < 1
			value = 1
		endif
	endwhile
endFunction
;___________________________________________________________________________________________________________________________

; Allows player to set probability
float Function SetPercentage(float value, float default = 0.0, String varName = "")
	int aiButton
	while True
		Debug.Notification("Currrent " +varName+ " percentage: " +((value*100) as int)+ "%")
		aiButton = PercentageMenu.Show()
		if aiButton == 0
			return value
		elseif aiButton == 1
			value -= 0.50
		elseif aiButton == 2
			value -= 0.10
		elseif aiButton == 3
			value -= 0.05
		elseif aiButton == 4
			value -= 0.01
		elseif aiButton == 5
			value += 0.01
		elseif aiButton == 6
			value += 0.05
		elseif aiButton == 7
			value += 0.10
		elseif aiButton == 8
			value += 0.50
		elseif aiButton == 9
			value = default
		endif
		if value < 0.0
			value = 0.0
		elseif value > 1.0
			value = 1.0
		endif
	endwhile
EndFunction
