Scriptname INEQ_InfusedLight extends INEQ_AbilityBase1H  
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell property LightSpell auto

String  Property	WeaponDraw		=	"WeaponDraw"  	Autoreadonly			; Draw weapon
String	Property	WeaponSheathe	=	"WeaponSheathe"	Autoreadonly			; sheathe weapon

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================		    Start			================================================
;================================================================================================

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	SelfRef.RemoveSpell(LightSpell)
	UnregisterForAnimationEvent(selfRef, WeaponDraw)
	UnregisterForAnimationEVent(SelfRef, WeaponSheathe)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Ready

	Event OnBeginState()
		RegisterForAnimationEvent(selfRef, WeaponDraw)
		SelfRef.RemoveSpell(LightSpell)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		GoToState("Active")
	endEVENT

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
		GoToState("Ready")
	endEVENT

	Event OnEndState()
		SelfRef.RemoveSpell(LightSpell)
		UnregisterForAnimationEVent(SelfRef, WeaponSheathe)
	EndEvent

EndState
