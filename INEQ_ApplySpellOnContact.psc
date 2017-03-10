Scriptname INEQ_ApplySpellOnContact extends ActiveMagicEffect 

Spell Property SomeSpell Auto
 
Event OnEffectStart(Actor akTarget, Actor akCaster)
	akTarget.AddSpell(SomeSpell)
EndEvent