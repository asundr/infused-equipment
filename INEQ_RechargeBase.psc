Scriptname INEQ_RechargeBase extends ReferenceAlias

Actor	Property	SelfRef		Auto
Message	Property	MainMenu	Auto
String	Property	Name		Auto

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnInit()
	Init()
EndEvent

Event OnPlayerLoadGame()
	PlayerLoadGame()
EndEvent
;___________________________________________________________________________________________________________________________

Function Init()
	FullReset()
EndFunction

; Used to perform maintenence when the player loads
Function PlayerLoadGame()
EndFunction
;___________________________________________________________________________________________________________________________

; Restores menu-modifiable variables
Function RestoreDefaultFields()
EndFunction

; Used to initialize and reset Recharge Source
Function FullReset()
	RestoreDefaultFields()
EndFunction

;===============================================================================================================================
;====================================		   Functions		================================================
;================================================================================================

bool Function HasMenu()
	return MainMenu
EndFunction
;___________________________________________________________________________________________________________________________

String Function getName()
	return Name
EndFunction
;___________________________________________________________________________________________________________________________

Function ChargeMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	Debug.Trace(self+  " attempted to access non-existent charge menu")
EndFunction
