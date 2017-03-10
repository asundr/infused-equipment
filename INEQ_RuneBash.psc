Scriptname INEQ_RuneBash extends INEQ_AbilityBase1H  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Message		Property	MainMenu	Auto

Spell		Property	RuneSpell		Auto
Activator	Property	ProximityCheck	Auto

bool	Property	bBalanced	=	True	Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
String  Property  BashExit  = 	"bashExit"  	Autoreadonly			; End bashing

;===========================================  Variables  ============================================================================>
bool bCheckProximity = True

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	RegisterAbilityToAlias()
EndEvent

Function RestoreDefaultFields()
	bBalanced = True
	bCheckProximity = True
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped
	
	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, BashExit)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if (akSource == SelfRef) &&  (EventName == BashExit)
			if bCheckProximity
				AttemptCastRune()
			else
				RuneSpell.cast(SelfRef)
			endif
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(SelfRef, BashExit)
	EndEvent

EndState

;___________________________________________________________________________________________________________________________

State Cooldown

	Event OnBeginState()
			
	EndEvent

EndState

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Checks the proximity before deciding whether to cast the rune
Function AttemptCastRune()
	ObjectReference box = SelfRef.Placeatme(ProximityCheck, abInitiallyDisabled = True)
	float direction = SelfRef.getAngleZ()
	float pitch	=	SelfRef.getangleX()
	float xOff = 400.0 * Math.sin(direction) * Math.sin(pitch + 90)		; 500	;300
	float yOff = 400.0 * Math.cos(direction) * Math.sin(pitch + 90)
	float zOff = 400.0 * Math.sin(SelfRef.getAngleX() + 180)
	box.MoveTo(SelfRef, xOff, yOff, 128.0 + zOff)
;	SetLocalAngle(box, pitch, 90.0, direction)
	box.setscale(2.5)								; 3.0	;2.0
	(box as INEQ_RuneBashProximity).register(self, SelfRef)
EndFunction
;___________________________________________________________________________________________________________________________

; Handles casting the rune and the casting cost
Function CastRune()
	;Debug.Notification("cast rune")
	RuneSpell.cast(SelfRef)
;	SelfRef.damageAv("stamina", 25)		;default cost
EndFunction
;___________________________________________________________________________________________________________________________

; Sets the angle of an object around the object's local origin (x = pitch, y = yaw, z = heading)
Function SetLocalAngle(ObjectReference MyObject, Float LocalX, Float LocalY, Float LocalZ) Global
	float AngleX = LocalX * Math.Cos(LocalZ) + LocalY * Math.Sin(LocalZ)
	float AngleY = LocalY * Math.Cos(LocalZ) - LocalX * Math.Sin(LocalZ)
	MyObject.SetAngle(AngleX, AngleY, LocalZ)
EndFunction

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
		elseif aiButton == 9		; Cancel menu
			MenuActive.SetValue(0)
		elseif aiButton == 1		; Turn on Balanced
			bBalanced = True
			RestoreDefaultFields()
		elseif aiButton == 2		; Turn off Balanced
			bBalanced = False
		elseif aiButton == 3		; Turn on Proximity Check
			bCheckProximity = True
		elseif aiButton == 4		; Turn off proximity check
			bCheckProximity = False
		elseif aiButton == 5		; 
			
		endif
	endwhile
EndFunction

; Updates the Button to show the correct menu options
Function SetButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	if bBalanced
		;Button.set(2)
	else
		;Button.set(1)
	endif
	
	if bCheckProximity
		Button.set(4)
	else
		Button.set(3)
	endif
	Button.set(9)
EndFunction
