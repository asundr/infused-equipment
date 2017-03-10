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

;======================================================================================;
;  VARIABLES   /
;=============/
actor CasterActor
actor Victim
; objectreference playerref
bool DeadAlready = FALSE
bool bUseWait = True

;======================================================================================;
;  EVENTS      /
;=============/


Event OnEffectStart(Actor Target, Actor Caster)
	victim = target
	CasterActor = Caster
	if bIsEnchantmentEffect == False
		DeadAlready = Victim.IsDead()
	endif
	bUseWait = False
	victim.kill(CasterActor)
; 	debug.trace("Is Soultrap target dead? ("+deadAlready+")("+victim+")") 
EndEvent


Event OnEffectFinish(Actor Target, Actor Caster)
	debug.trace(self + " is finishing")
	if victim
		if bUseWait 
			Utility.Wait(0.25)
		endif
		if DeadAlready == False
			if Caster.TrapSoul(victim) == true
				debug.trace(victim + " is, in fact, dead.  Play soul trap visFX")

				if (SomeExplosion)
					;Caster.placeatme(SomeExplosion)
				endif
				
			;Target.SetCriticalStage(Target.CritStage_DisintegrateStart)
				
				;Caster.PushActorAway(Target, -1000)
				Target.ApplyHavokImpulse(Caster.GetPositionX() - Target.GetPositionX(), Caster.GetPositionY() - Target.GetPositionY(), Caster.GetPositionZ() - Target.GetPositionZ() + 100, 350.0)

				QSTDwemerGong.play(Caster)		
				;TrapSoundFX.play(Caster)       ; play TrapSoundFX sound from player
				;TrapImod.apply()                                  ; apply isMod at full strength
				TargetVFX.Play(victim,2.7,Caster)              ; Play TargetVFX and aim them at the player
				CasterVFX.Play(Caster,3.9,victim)
			TargetFXS.Play(victim,3)    						; Play Effect Shaders
				;CasterFXS.Play(Caster,3)
				
			;utility.wait(3)     
			;Target.AttachAshPile(AshPileObject)
			;Target.SetCriticalStage(Target.CritStage_DisintegrateEnd)
				
			else
				debug.trace(victim + " is, in fact, dead, But the TrapSoul check failed or came back false")
			endif
		
		else
			debug.trace(self + "tried to soulTrap, but " + victim + " is already Dead.")
		endif
	endif
endEvent