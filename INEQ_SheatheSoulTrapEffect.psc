Scriptname INEQ_SheatheSoulTrapEffect extends ActiveMagicEffect  
{Scripted effect for the Soul Trap Visual FX}

;===========================================  Properties  ===========================================================================>
Sound			Property	TrapSoundFX	Auto
EffectShader	Property	TargetFXS	Auto
VisualEffect	Property	TargetVFX	Auto
VisualEffect	Property	CasterVFX	Auto

Formlist		Property	DisintegrationMainImmunityList	Auto

ReferenceAlias	Property	SharedChargesAlias	Auto

;==========================================  Autoreadonly  ==========================================================================>

;===========================================  Variables  ============================================================================>
Actor SelfRef
Actor Target
INEQ_SharedCharges SharedCharges
;===============================================================================================================================
;====================================			Functions			================================================
;================================================================================================

; Kills target and initializes variables
Event OnEffectStart(Actor akTarget, Actor akCaster)
	SharedCharges =  SharedChargesAlias as INEQ_SharedCharges
	Target = akTarget
	SelfRef = akCaster
	Target.Kill()
EndEvent

; Applies visuals and adds shared charge and/or soul
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if Target && Target.IsDead()
		SharedCharges.addCharge(1)		
		TargetVFX.Play(Target, 2.7, SelfRef)
		CasterVFX.Play(SelfRef, 3.9, Target)
		Target.ApplyHavokImpulse(SelfRef.GetPositionX() - Target.GetPositionX(), SelfRef.GetPositionY() - Target.GetPositionY(), SelfRef.GetPositionZ() - Target.GetPositionZ() + 100, 350.0)
		if SelfRef.TrapSoul(Target)
			TrapSoundFX.play(SelfRef)
			if	!DisintegrationMainImmunityList.hasForm(Target.getRace() as Form)
				Target.SetCriticalStage(Target.CritStage_DisintegrateStart)
				TargetFXS.Play(Target, 3.0)
				
				Utility.wait(1.5)
				Target.AttachAshPile()
				Utility.wait(1.2)
				
				TargetFXS.Stop(Target)
				Target.SetAlpha (0.0, True)
				Target.SetCriticalStage(Target.CritStage_DisintegrateEnd)
			endif
		endif
	endif
endEvent
