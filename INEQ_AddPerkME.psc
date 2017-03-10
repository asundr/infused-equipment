Scriptname INEQ_AddPerkME extends activemagiceffect  

Perk  Property  somePerk  Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.addPerk(somePerk)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	akTarget.removePerk(somePerk)
EndEvent