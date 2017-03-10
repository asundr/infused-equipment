Scriptname INEQ_EventListenerBase extends ActiveMagicEffect Hidden

; INEQ_DistanceTravelled
Function OnDistanceTravelledEvent()
	Debug.Trace(self+ ": Could not find DistanceTravelledEvent override on Requester")
EndFunction

; INEQ_MagickaSiphon
Function OnMagickaSiphonEvent()
	Debug.Trace(self+ ": Could not find OnMagickaSiphonEvent override on Requester")
EndFunction
