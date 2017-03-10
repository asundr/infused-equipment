Scriptname INEQ_SharedChargesListener extends INEQ_EventListenerBase
{Links to the SharedCharge class and gives it access to EventListener behavior}

;===========================================  Properties  ===========================================================================>
ReferenceAlias	Property	SharedChargesAlias		Auto

;===========================================  Variables  ============================================================================>
INEQ_SharedCharges 	SharedCharges

;===============================================================================================================================
;====================================	    Maintenance			================================================
;================================================================================================

Event OnEffectStart(Actor akTarget, Actor akCaster)
	parent.EffectStart(akTarget, akCaster)
	SharedCharges = SharedChargesAlias as INEQ_SharedCharges
	SharedCharges.registerListener(self)
EndEvent

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Forwards the DistanceTravelled Event to SharedCharges
Function OnDistanceTravelledEvent()
	SharedCharges.OnDistanceTravelledEvent()
EndFunction

; Forwards the MagickaSiphon Event to SharedCharges
Function OnMagickaSiphonEvent()
	SharedCharges.OnMagickaSiphonEvent()
EndFunction
