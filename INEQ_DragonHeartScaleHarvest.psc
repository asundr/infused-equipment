Scriptname INEQ_DragonHeartScaleHarvest extends ActiveMagicEffect  

miscobject Property MGRDragonHeartScales  Auto 

Actor Dragon

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Dragon = akTarget
	GoToState("Ready")
EndEvent


State Ready

	Event OnActivate (ObjectReference ActionRef)
		if Dragon.IsDead()
			Dragon.AddItem(MGRDragonHeartScales,1)
			GoToState("Finished")
		endif
	EndEvent

EndState


State Finished

EndState