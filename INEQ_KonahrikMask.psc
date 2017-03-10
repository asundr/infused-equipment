Scriptname INEQ_KonahrikMask extends INEQ_AbilityBase  

;===========================================  Properties  ===========================================================================>
float property HPthreshold = 0.20 autoreadonly
{Below this HP we have a chance of the special effects.  Default 20% (0.2)}
float property effectChance = 0.010 autoreadonly
{effect may happen when HP is below this level DEFAULT 25% (0.25)}
float property rareEffectChance = 0.02 autoreadonly
{Very Rare effect may happen when HP is below this level DEFAULT 5% (0.05)}

Explosion property fakeForceBall1024 auto

Spell property flameCloak auto
Spell property GrandHealing auto
Spell property rareSpell  auto

MagicEffect property DragonPriestMaskFireCloakFFSelf Auto
MagicEffect property rareEffect auto

;===========================================  Variables  ============================================================================>
ObjectReference EquipRef

;===============================================================================================================================
;====================================			States			================================================
;================================================================================================

State Equipped

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		if (selfRef.getActorValuePercentage("Health") < HPthreshold) && !SelfRef.HasMagicEffect(DragonPriestMaskFireCloakFFSelf) && !SelfRef.isDead()
			float rand = utility.RandomFloat(0,1)
			if rand <= effectChance
				selfRef.placeAtMe(fakeForceBall1024)
				selfRef.knockAreaEffect(1,1024)
				GrandHealing.cast(selfRef,selfRef)
				flameCloak.cast(selfRef,selfRef)		
			endif
			if rand <= rareEffectChance && !(selfRef.hasMagicEffect(rareEffect))
				rareSpell.cast(selfRef,selfRef)
			endif
		endif
	endEvent
	
EndState
