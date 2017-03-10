Scriptname INEQ_MehrunesRazor extends ActiveMagicEffect  

Faction Property pDA07MehrunesRazorImmuneFaction auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	;Apply this effect if the target is not in the excluded faction
	If akTarget.IsInFaction(pDA07MehrunesRazorImmuneFaction) == 0
; 		Debug.trace(self + " hitting " + akTarget + " with Mehrunes' Razor")
		If (Utility.RandomInt() <= 1)
 			debug.Notification("Mehrunes Razor eliminated a foe")
			akTarget.Kill()
		EndIf
	EndIf

EndEvent