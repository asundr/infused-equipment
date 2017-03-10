Scriptname INEQ_AhzidalsRetribution extends INEQ_AbilityBase
{Adds Ahzidal's Retribution's random paralysis on hit effect}

;===========================================  Properties  ===========================================================================>
Keyword property WeapTypeBow	Auto
Spell property DLC2dunKolbjornArmorParalyze Auto
Sound property MAGParalysisEnchantment Auto

;===========================================  Variables  ============================================================================>
;Actor selfRef
ObjectReference EquipRef

;===========================================  Start/Finish  ============================================================================>

;Event OnEffectStart (Actor akTarget, Actor akCaster)
;	selfRef = akCaster
;	GoToState("Unequipped")
;EndEvent

;===========================================	States	  ============================================================================>

State Equipped
	
	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		if ((akSource as Weapon) != None && !akSource.HasKeyword(WeapTypeBow) && (akAggressor as Actor) != None)
			int rand = Utility.RandomInt(0, 99)
			if (rand < 5)
				MAGParalysisEnchantment.Play(akAggressor)
				DLC2dunKolbjornArmorParalyze.Cast(akAggressor)
			EndIf
		EndIf
	EndEvent

EndState
