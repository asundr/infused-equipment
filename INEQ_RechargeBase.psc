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
EndFunction

Function PlayerLoadGame()
EndFunction
;___________________________________________________________________________________________________________________________

Function Maintenance()
EndFunction

Function RestoreDefaultFields()
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
