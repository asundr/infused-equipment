Scriptname INEQ_SheatheSoulTrapEffect extends activemagiceffect  
{Scripted effect for the Soul Trap Visual FX}

;======================================================================================;
;  PROPERTIES  /
;=============/
ImageSpaceModifier property TrapImod auto
{IsMod applied when we trap a soul}
sound property TrapSoundFX auto ; create a sound property we'll point to in the editor
{Sound played when we trap a soul}
VisualEffect property TargetVFX auto
{Visual Effect on Target aiming at Caster}
VisualEffect property CasterVFX auto
{Visual Effect on Caster aming at Target}
EffectShader property CasterFXS auto
{Effect Shader on Caster during Soul trap}
EffectShader property TargetFXS auto
{Effect Shader on Target during Soul trap}
bool property bIsEnchantmentEffect = false auto
{Set this to true if this soul trap is on a weapon enchantment or a spell that can do damage to deal with a fringe case}

Sound Property QSTDwemerGong	 auto
Explosion property SomeExplosion auto

Activator property AshPileObject auto
VisualEffect  Property  MGTeleportOutEffect  Auto

ReferenceAlias	Property	SharedChargesAlias	Auto
Spell	Property	VisualSpell	Auto

Formlist	Property	DisintegrationMainImmunityList	Auto

;======================================================================================;
;  VARIABLES   /
;=============/
Actor SelfRef
Actor Target
; objectreference playerref
bool DeadAlready = FALSE
bool bUseWait = True

INEQ_SharedCharges SharedCharges

;======================================================================================;
;  EVENTS      /
;=============/


Event OnEffectStart(Actor akTarget, Actor akCaster)
	
	SharedCharges =  SharedChargesAlias as INEQ_SharedCharges

	Target = akTarget
	SelfRef = akCaster
	if bIsEnchantmentEffect == False
		DeadAlready = Target.IsDead()
	endif
	bUseWait = False
	Target.kill(SelfRef)
; 	debug.trace("Is Soultrap target dead? ("+deadAlready+")("+Target+")") 
EndEvent


Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if Target
		if bUseWait 
			Utility.Wait(0.25)
		endif
		if DeadAlready == False
			
			SharedCharges.addCharge(1)
			VisualSpell.cast(SelfRef)
			Target.ApplyHavokImpulse(SelfRef.GetPositionX() - Target.GetPositionX(), SelfRef.GetPositionY() - Target.GetPositionY(), SelfRef.GetPositionZ() - Target.GetPositionZ() + 100, 350.0)
			
			if SelfRef.TrapSoul(Target) == true
				;debug.trace(Target + " is, in fact, dead.  Play soul trap visFX")

;				if (SomeExplosion)
					;SelfRef.placeatme(SomeExplosion)
;				endif
				
				if	!DisintegrationMainImmunityList.hasForm(Target.getRace() as Form)
					Target.SetCriticalStage(Target.CritStage_DisintegrateStart)
					TargetFXS.Play(Target,3)    	; Play Effect Shaders
					Target.AttachAshPile()	;AshPileObject
					RegisterForSingleUpdate(3.0)
				endif
				

				;QSTDwemerGong.play(SelfRef)		
				;TrapSoundFX.play(SelfRef)       					; play TrapSoundFX sound from player
				;TrapImod.apply()                                  	; apply isMod at full strength
			;TargetVFX.Play(Target,2.7,SelfRef)             		; Play TargetVFX and aim them at the player
				CasterVFX.Play(SelfRef,3.9,Target)
			
				;CasterFXS.Play(SelfRef,3)
				

			else
				;debug.trace(Target + " is, in fact, dead, But the TrapSoul check failed or came back false")
			endif
		else
			;debug.trace(self + "tried to soulTrap, but " + Target + " is already Dead.")
		endif
	endif
endEvent

Event OnUpdate()
	;Target.AttachAshPile(none)	;AshPileObject
	TargetFXS.Stop(Target)
	Target.SetAlpha (0.0,True)
	Target.SetCriticalStage(Target.CritStage_DisintegrateEnd)
EndEvent
