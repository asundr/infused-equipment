Scriptname INEQ_DLC1AurielsShieldScript extends ReferenceAlias Hidden 

GlobalVariable Property TimesHit Auto
GlobalVariable Property CurrentStage Auto

Event OnLoad()
	debug.trace("Checking shield state")
	if CurrentStage.GetValue() == 1
		;debug.Notification("Shield at LEVEL 1")
		GetReference().SetAnimationVariableFloat("fDampRate", 1)
		GetReference().SetAnimationVariableFloat("fToggleBlend", 0.75)
	elseif CurrentStage.GetValue() == 2
		;debug.Notification("Shield at LEVEL 2")
		GetReference().SetAnimationVariableFloat("fDampRate", 1)
		GetReference().SetAnimationVariableFloat("fToggleBlend", 0.85)
	elseif CurrentStage.GetValue() == 3
		;debug.Notification("Shield at LEVEL 3")
		GetReference().SetAnimationVariableFloat("fDampRate", 1)
		GetReference().SetAnimationVariableFloat("fToggleBlend", 1)
	endif
EndEvent