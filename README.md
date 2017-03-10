# infused-equipment
By Arun Sundaram

Plugin Page:	http://www.nexusmods.com/skyrimspecialedition/mods/8705

Infused Equipment is a plugin for The Elder Scrolls V: Skyrim that is largely programmed in the language
[Papyrus](http://www.creationkit.com/index.php?title=Category:Papyrus). The classes contained here are used by
the main plugin file that can be found in the [Plugin Page](http://www.nexusmods.com/skyrimspecialedition/mods/8705).

This plugin implements a novel method of learning unique scripted abilities that are transferrable, unlike
those found in the original application. In addition to the abilities programmed through this plugin, 
Infused Equipment also serves as a framework for other authors to seamlessly add their own abilities. [See here for
example scripts.] (https://github.com/asundr/infused-equipment-example-addon)


### Core and Base Classes
	
- **AbilityRegister**: Provides access to the menus that allow the user to modify settings and interact with the
		plugin's core functionality. Also, handles maintenance and the addition of plugins.

- **MenuButtonConditional**: Object used by menus to dynamically display and hide buttons in menus.

- **ListenerMenu**: Contains common menus used by abilities and recharge sources.
		
- **EquipmentScript**: One of these is used for each available item that can be infused. Keeps track of the
		infused item's reference and delegates behavior from AbilityRegister to AbilityAliasProperties.
		
- **AbilityAliasProperties**: Object used for each ability to determine whether its unlocked and active. It also
		provides access to the ability itself and its menus which would otherwise be awkward to do directly.

- **RechargeBase**: Some abilities must use charges to balance the benefit they provide. This class provides the
		base behavior (like menus, initialization) used by the charge sources that generate those charges.
		
- **DistanceTravelled**: Generates charges based on the distance the user travels. To do this, an ability must
		register a distance in feet and then this object notifies the correct ability when that distance
		is reached.
		
- **MagickaSiphon**: Generates charges from the user's excess regenerated magicka stat. An ability must first register
		an amount of magicka and a priority. Then it will be notified when the amount has been 
		reached in the order of highest priority.
		
- **SharedCharges**: Stores charges which are generated from DistanceTravelled and MagickaSiphon and can be used
		by other abilities that have access to it.

- **SharedChargeListener**: Since SharedCharges can't directly request and receive charge events, it does so via
		this object that extends EventListenerBase.
		
- **EventListenerBase**: Contains behavior for registering, unregistering and receiving events from DistanceTravelled
		and MagickaSiphon. Also, contains behavior for accessing SharedCharges and an empty function for 
		custom 3rd party events.
		
- **AbilityBase**: This is the base class for all abilities used in the plugin. It extends EventListenerBase and
		includes all common ability behavior from menus to handling equipping and unequipping the ability.
		
- **AbilityBase1H**: Extends AbilityBase and contains override functions necessary for melee items.

- **AbilityBaseShield**: Extends AbilityBase and contains override functions necessary for shields.

- __AddAbilityOnEquip\*__: Extends AbilityBase\* and has the simple function of adding a constant ability to the user.

- __AddPerkOnEquip\*__: Extends AbilityBase\* and has the simple function of adding a constant perk to the user.



### Various Helper Classes

- **ApplySpellOnContact**: Applies an effect to a target.

- **AddPerkME**: Applies a perk to a target.

- **MehrunesRazorContact**: Applies the Mehrunes' razor effect to a target.

- **Hands_NamiraRing_PFragment**: Behavior for Namira ability on activating target.

- **DragonHeartScaleHarvest**: Applies Kahvozein's Blade effect to target.

- **RuneBashProximity**: Used to check proximity on RuneBash ability.

- **SheatheSoulTrapEffect**: Applies the Sheath Soul Trap effect and can add shared charges.

- **TeleportArrowAliasScript**: Handles teleporting the player if an appropriate projectile is detected.



### Classes that extend AbilityBase (Abilities)

These classes extend the various AbilityBase\*, AddAbilityOnEquip\* and AddPerkOnEquip\* classes and are used for the instances of the abilities at runtime. For descriptions of what the ability scripts do, see the corresponding ability description on the [Plugin page](http://www.nexusmods.com/skyrimspecialedition/mods/8705).
