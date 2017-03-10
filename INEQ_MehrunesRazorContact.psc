Scriptname INEQ_MehrunesRazorContact extends ActiveMagicEffect  
{Probabilistically kills target if the target is not immune}

;===========================================  Properties  ===========================================================================>
Faction	Property	pDA07MehrunesRazorImmuneFaction	Auto

GlobalVariable	Property	KillChance	Auto

;==========================================  Autoreadonly  ==========================================================================>

;===========================================  Variables  ============================================================================>

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Apply this effect if the target is not immune
Event OnEffectStart(Actor akTarget, Actor akCaster)
	If akTarget.IsInFaction(pDA07MehrunesRazorImmuneFaction) == 0
		If (Utility.RandomInt(1, 100) <= KillChance.GetValueInt())
 			Debug.Notification("Mehrunes Razor eliminated a foe")
			akTarget.Kill()
		EndIf
	EndIf
EndEvent
