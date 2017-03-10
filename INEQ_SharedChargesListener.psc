Scriptname INEQ_SharedChargesListener extends INEQ_EventListenerBase
{Links to the SharedCharge class and gives it access to EventListener behavior}

;===========================================  Properties  ===========================================================================>

;===========================================  Variables  ============================================================================>

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	(SharedChargesAlias as INEQ_SharedCharges).registerListener(self)
EndEvent

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Forwards the DistanceTravelled Event to SharedCharges
Function OnDistanceTravelledEvent()
	(SharedChargesAlias as INEQ_SharedCharges).OnDistanceTravelledEvent()
EndFunction

; Forwards the MagickaSiphon Event to SharedCharges
Function OnMagickaSiphonEvent()
	(SharedChargesAlias as INEQ_SharedCharges).OnMagickaSiphonEvent()
EndFunction
