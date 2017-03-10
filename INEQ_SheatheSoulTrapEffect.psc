Scriptname INEQ_SheatheSoulTrapEffect extends activemagiceffect  
{Scripted effect for the Soul Trap Visual FX}

;===========================================  Properties  ===========================================================================>
Formlist	Property	DisintegrationMainImmunityList	Auto

Sound			Property	TrapSoundFX	Auto ; create a sound property we'll point to in the editor

EffectShader	Property	TargetFXS	Auto
VisualEffect	Property	TargetVFX	Auto
VisualEffect	Property	CasterVFX	Auto

VisualEffect	Property	MGTeleportOutEffect	Auto
Sound			Property	QSTDwemerGong		Auto
Spell			Property	VisualSpell			Auto
Activator		Property	AshPileObject		Auto

ReferenceAlias	Property	SharedChargesAlias	Auto

;==========================================  Autoreadonly  ==========================================================================>


;===========================================  Variables  ============================================================================>
Actor SelfRef
Actor Target

INEQ_SharedCharges SharedCharges

;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; 
Event OnEffectStart(Actor akTarget, Actor akCaster)
	SharedCharges =  SharedChargesAlias as INEQ_SharedCharges
	Target = akTarget
	SelfRef = akCaster
	Target.Kill()
EndEvent

; 
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if Target && Target.IsDead()
		SharedCharges.addCharge(1)
		;VisualSpell.cast(SelfRef)
		Target.ApplyHavokImpulse(SelfRef.GetPositionX() - Target.GetPositionX(), SelfRef.GetPositionY() - Target.GetPositionY(), SelfRef.GetPositionZ() - Target.GetPositionZ() + 100, 350.0)
		QSTDwemerGong.play(SelfRef)
		if SelfRef.TrapSoul(Target)
			if	!DisintegrationMainImmunityList.hasForm(Target.getRace() as Form)
				Target.SetCriticalStage(Target.CritStage_DisintegrateStart)
				TargetFXS.Play(Target,3)    	; Play Effect Shaders
				Target.AttachAshPile()			; AshPileObject
				RegisterForSingleUpdate(3.0)
			endif
			TrapSoundFX.play(SelfRef)
			TargetVFX.Play(Target,2.7,SelfRef)
			CasterVFX.Play(SelfRef,3.9,Target)
		endif
	endif
endEvent

Event OnUpdate()
	;Target.AttachAshPile(none)	; AshPileObject
	TargetFXS.Stop(Target)
	Target.SetAlpha (0.0,True)
	Target.SetCriticalStage(Target.CritStage_DisintegrateEnd)
EndEvent
