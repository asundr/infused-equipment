Scriptname INEQ_ForcefulDraw extends INEQ_AbilityBase1H
{Attached to the ability's magic effect}

;===========================================  Properties  ===========================================================================>
Spell	property	DrawSpell		auto
Spell	property	DrawVisual		auto
Spell	Property	RechargeVisual	Auto

Explosion property DLC1SC_LightningBoltImpactExplosion auto
Explosion property DLC1VampDetectLifeExplosion auto

ReferenceAlias Property AliasDT Auto

Float	Property	ChargeDistance	=	100.0	Autoreadonly

String  Property  WeaponDrawn  = "WeaponDraw"  	Autoreadonly			; Draw weapon

;===========================================  Variables  ============================================================================>

ObjectReference EquipRef
INEQ_DistanceTravelled DT
bool bRecharged

;===============================================================================================================================
;====================================	    Start/Finish		================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	DT = AliasDT as INEQ_DistanceTravelled
	bRecharged = false
EndEvent

Event OnEffectFinish (Actor akTarget, Actor akCaster)
	UnregisterForUpdate()
	UnregisterForAnimationEvent(selfRef, WeaponDrawn)
EndEvent

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Unequipped
	
;	Event OnUpdate()
;		CastRecharge()
;	EndEvent

	Function OnDistanceTravelledEvent()
		CastRecharge()
	EndFunction

EndState
;___________________________________________________________________________________________________________________________

State Ready

	Event OnBeginState()
		if(bRecharged)
			GoToState("Active")
		else
			;RegisterForSingleUpdate(5) ;900
			DT.RegisterForEvent(self , ChargeDistance) 			;have two modes, time based and distance based
		endif
	EndEvent
	
	Function OnDistanceTravelledEvent()
		CastRecharge()
		GoToState("Active")
	EndFunction

;	Event OnUpdate()
;		CastRecharge()
;		GoToState("Active")
;	EndEvent

EndState

Function CastRecharge()
	RechargeVisual.cast(SelfRef,SelfRef)
	bRecharged = True
	Debug.Notification("Forceful Draw recharged!")
EndFunction
;___________________________________________________________________________________________________________________________

State Active

	Event OnBeginState()
		registerForAnimationEvent(selfRef, WeaponDrawn)
	EndEvent

	Event OnAnimationEvent(ObjectReference akSource, string EventName)
		if selfRef.isInCombat() && !selfRef.isSneaking()
			CastForcefulDraw()
		endif
	EndEvent

	Event OnEndState()
		UnregisterForAnimationEvent(selfRef, WeaponDrawn)
	EndEvent

EndState

Function CastForcefulDraw()
	selfRef.placeatme(DLC1SC_LightningBoltImpactExplosion)
	DrawVisual.cast(selfRef,selfRef)
	selfRef.placeatme(DLC1VampDetectLifeExplosion)
	DrawSpell.cast(selfRef)
	bRecharged = False
	GoToState("Ready")
EndFunction
