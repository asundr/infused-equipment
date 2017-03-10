Scriptname INEQ_BookMenuScript extends ObjectReference  

ReferenceAlias	Property	Alias_Register	Auto
INEQ_AbilityRegister abRegister

Event OnInit()
	abRegister  = Alias_Register as INEQ_AbilityRegister
EndEvent

Event OnRead()
	Game.DisablePlayerControls(False, False, False, False, False, True) 	; Ensure MessageBox is not on top of other menus & prevent book from opening normally.
	Game.EnablePlayerControls(False, False, False, False, False, True)	 	; Undo DisablePlayerControls
	abRegister.MainMenu()
EndEvent

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	if !akNewContainer
		abRegister.StartRegister()
		akOldContainer.additem(self, 1, true)
	endif
EndEvent