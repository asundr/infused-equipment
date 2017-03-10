Scriptname INEQ_InfusedLight extends INEQ_AbilityBase1H  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Message	Property	OptionsMenu			Auto
Message	Property	LightThresholdMenu	Auto

Spell	Property	LightSpell	Auto

float	Property	LightThreshold	Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
float	Property	DEFLightThreshold	=	25.0	Autoreadonly

String	Property	WeaponDraw		=	"WeaponDraw"  		Autoreadonly		; Draw weapon
String	Property	WeaponSheathe	=	"WeaponSheathe"		Autoreadonly		; sheathe weapon

;===========================================  Variables  ============================================================================>


;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	RegisterAbilityToAlias()
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SelfRef.RemoveSpell(LightSpell)
	parent.EffectFinish(akTarget, akCaster)
EndEvent

Function RestoreDefaultFields()
	parent.RestoreDefaultFields()
	LightThreshold = DEFLightThreshold
EndFunction

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped

	Event OnBeginState()
		RegisterForAnimationEvent(selfRef, WeaponDraw)
		SelfRef.RemoveSpell(LightSpell)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, String EventName)
		if SelfRef.GetLightLevel() < LightThreshold && !SelfRef.isSneaking()
			GoToState("Active")
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, WeaponDraw)
	EndEvent

EndState
;___________________________________________________________________________________________________________________________

State Active

	Event OnBeginState()
		RegisterForAnimationEvent(SelfRef, WeaponSheathe)
		SelfRef.addspell(LightSpell, false)
	EndEvent
	
	Event OnAnimationEvent(ObjectReference akSource, String EventName)
		GoToState("Equipped")
	EndEvent

	Event OnEndState()
		SelfRef.RemoveSpell(LightSpell)
		UnregisterForAnimationEVent(SelfRef, WeaponSheathe)
	EndEvent

EndState

;===============================================================================================================================
;====================================			Menus			================================================
;================================================================================================

Function AbilityMenu(INEQ_MenuButtonConditional Button, INEQ_ListenerMenu ListenerMenu, GlobalVariable MenuActive)
	bool abMenu = True
	int aiButton
	while abMenu && MenuActive.Value
		setButtonMain(Button)
		aiButton = OptionsMenu.Show()
		if aiButton == 0
			abMenu = False
		elseif aiButton == 9	; Cancel Menu
			MenuActive.SetValue(0)
		elseif aiButton == 1	; Set light threshold
			SetLightThreshold()
		endif
	endwhile
EndFunction

Function setButtonMain(INEQ_MenuButtonConditional Button)
	Button.clear()
	Button.set(1)
	Button.set(9)
EndFunction
;___________________________________________________________________________________________________________________________

Function SetLightThreshold()
	bool abMenu = True
	int aiButton
	while abMenu
		Debug.Notification("Currrent light level threshhold: " +(LightThreshold as int))
		aiButton = LightThresholdMenu.Show()
		if aiButton == 0
			return
		elseif aiButton == 1
			LightThreshold -= 50.0
		elseif aiButton == 2
			LightThreshold -= 10.0
		elseif aiButton == 3
			LightThreshold -= 5.0
		elseif aiButton == 4
			LightThreshold -= 1.0
		elseif aiButton == 5
			LightThreshold += 1.0
		elseif aiButton == 6
			LightThreshold += 5.0
		elseif aiButton == 7
			LightThreshold += 10.0
		elseif aiButton == 8
			LightThreshold += 50.0
		elseif aiButton == 9
			LightThreshold = DEFLightThreshold
		endif
		if LightThreshold < 1.0
			LightThreshold = 1.0
		endif
	endwhile
EndFunction
