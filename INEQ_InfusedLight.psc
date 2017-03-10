Scriptname INEQ_InfusedLight extends INEQ_AbilityBase1H  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell	Property	LightSpell	Auto

float	Property	LightThreshold	=	25.0	Auto	Hidden

;==========================================  Autoreadonly  ==========================================================================>
float	Property	DEFLightThreshold	=	25.0	Autoreadonly

String	Property	WeaponDraw		=	"WeaponDraw"  		Autoreadonly		; Draw weapon
String	Property	WeaponSheathe	=	"WeaponSheathe"		Autoreadonly		; sheathe weapon

;===========================================  Variables  ============================================================================>


;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SelfRef.RemoveSpell(LightSpell)
	parent.EffectFinish(akTarget, akCaster)
EndEvent

Function RestoreDefaultFields()
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

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if SelfRef.GetLightLevel() < LightThreshold
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
	
	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		GoToState("Equipped")
	EndEvent

	Event OnEndState()
		SelfRef.RemoveSpell(LightSpell)
		UnregisterForAnimationEVent(SelfRef, WeaponSheathe)
	EndEvent

EndState
