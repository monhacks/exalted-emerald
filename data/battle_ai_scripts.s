#include "constants/battle.h"
#include "constants/battle_ai.h"
#include "constants/abilities.h"
#include "constants/items.h"
#include "constants/moves.h"
#include "constants/battle_move_effects.h"
#include "constants/hold_effects.h"
#include "constants/pokemon.h"
	.include "asm/macros/battle_ai_script.inc"

	.section script_data, "aw", %progbits

	.align 2
gBattleAI_ScriptsTable:: @ 82DBEF8
	.4byte AI_CheckBadMove
	.4byte AI_TryToFaint
	.4byte AI_CheckViability
	.4byte AI_SetupFirstTurn
	.4byte AI_Risky
	.4byte AI_PreferStrongestMove
	.4byte AI_PreferBatonPass
	.4byte AI_DoubleBattle
	.4byte AI_HPAware
	.4byte AI_Unknown
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Ret
	.4byte AI_Roaming
	.4byte AI_Safari
	.4byte AI_FirstBattle

AI_CheckBadMove:
	if_target_is_ally AI_Ret
	if_move MOVE_FISSURE, AI_CBM_CheckIfNegatesType
	if_move MOVE_HORN_DRILL, AI_CBM_CheckIfNegatesType
	get_how_powerful_move_is
	if_equal MOVE_POWER_DISCOURAGED, AI_CheckBadMove_CheckEffect

AI_CBM_CheckIfNegatesType: @ 82DBF92
	if_type_effectiveness AI_EFFECTIVENESS_x0, Score_Minus10
	get_ability AI_USER
	if_equal ABILITY_MOLD_BREAKER, AI_CheckBadMove_CheckEffect
	if_equal ABILITY_TERAVOLT, AI_CheckBadMove_CheckEffect
	if_equal ABILITY_TURBOBLAZE, AI_CheckBadMove_CheckEffect
	get_ability AI_TARGET
	if_equal ABILITY_VOLT_ABSORB, CheckIfVoltAbsorbCancelsElectric
	if_equal ABILITY_LIGHTNING_ROD, CheckIfVoltAbsorbCancelsElectric
	if_equal ABILITY_MOTOR_DRIVE, CheckIfVoltAbsorbCancelsElectric
	if_equal ABILITY_WATER_ABSORB, CheckIfWaterAbsorbCancelsWater
	if_equal ABILITY_DRY_SKIN, CheckIfWaterAbsorbCancelsWater
	if_equal ABILITY_FLASH_FIRE, CheckIfFlashFireCancelsFire
	if_equal ABILITY_WONDER_GUARD, CheckIfWonderGuardCancelsMove
	if_equal ABILITY_LEVITATE, CheckIfLevitateCancelsGroundMove
	if_equal ABILITY_SOUNDPROOF, CheckIfSoundproofCancelsMove
	goto AI_CheckBadMove_CheckEffect

CheckIfSoundproofCancelsMove:
	if_move_flag FLAG_SOUND, Score_Minus10
	goto AI_CheckBadMove_CheckEffect

CheckIfVoltAbsorbCancelsElectric: @ 82DBFBD
	get_curr_move_type
	if_equal TYPE_ELECTRIC, Score_Minus12
	goto AI_CheckBadMove_CheckEffect

CheckIfWaterAbsorbCancelsWater: @ 82DBFCA
	get_curr_move_type
	if_equal TYPE_WATER, Score_Minus12
	goto AI_CheckBadMove_CheckEffect

CheckIfFlashFireCancelsFire: @ 82DBFD7
	get_curr_move_type
	if_equal TYPE_FIRE, Score_Minus12
	goto AI_CheckBadMove_CheckEffect

CheckIfWonderGuardCancelsMove: @ 82DBFE4
	if_type_effectiveness AI_EFFECTIVENESS_x2, AI_CheckBadMove_CheckEffect
	if_type_effectiveness AI_EFFECTIVENESS_x4, AI_CheckBadMove_CheckEffect
	goto Score_Minus10

CheckIfLevitateCancelsGroundMove: @ 82DBFEF
	get_curr_move_type
	if_equal TYPE_GROUND, Score_Minus10

AI_CheckBadMove_CheckEffect: @ 82DC045
	if_effect EFFECT_SLEEP, AI_CBM_Sleep
	if_effect EFFECT_EXPLOSION, AI_CBM_Explosion
	if_effect EFFECT_DREAM_EATER, AI_CBM_DreamEater
	if_effect EFFECT_ATTACK_UP, AI_CBM_AttackUp
	if_effect EFFECT_DEFENSE_UP, AI_CBM_DefenseUp
	if_effect EFFECT_SPEED_UP, AI_CBM_SpeedUp
	if_effect EFFECT_SPECIAL_ATTACK_UP, AI_CBM_SpAtkUp
	if_effect EFFECT_SPECIAL_DEFENSE_UP, AI_CBM_SpDefUp
	if_effect EFFECT_ACCURACY_UP, AI_CBM_AccUp
	if_effect EFFECT_EVASION_UP, AI_CBM_EvasionUp
	if_effect EFFECT_ATTACK_DOWN, AI_CBM_AttackDown
	if_effect EFFECT_DEFENSE_DOWN, AI_CBM_DefenseDown
	if_effect EFFECT_SPEED_DOWN, AI_CBM_SpeedDown
	if_effect EFFECT_SPECIAL_ATTACK_DOWN, AI_CBM_SpAtkDown
	if_effect EFFECT_SPECIAL_DEFENSE_DOWN, AI_CBM_SpDefDown
	if_effect EFFECT_ACCURACY_DOWN, AI_CBM_AccDown
	if_effect EFFECT_EVASION_DOWN, AI_CBM_EvasionDown
	if_effect EFFECT_HAZE, AI_CBM_Haze
	if_effect EFFECT_BIDE, AI_CBM_HighRiskForDamage
	if_effect EFFECT_ROAR, AI_CBM_Roar
	if_effect EFFECT_TOXIC, AI_CBM_Toxic
	if_effect EFFECT_LIGHT_SCREEN, AI_CBM_LightScreen
	if_effect EFFECT_OHKO, AI_CBM_OneHitKO
	if_effect EFFECT_SUPER_FANG, AI_CBM_HighRiskForDamage
	if_effect EFFECT_MIST, AI_CBM_Mist
	if_effect EFFECT_FOCUS_ENERGY, AI_CBM_FocusEnergy
	if_effect EFFECT_CONFUSE, AI_CBM_Confuse
	if_effect EFFECT_ATTACK_UP_2, AI_CBM_AttackUp
	if_effect EFFECT_DEFENSE_UP_2, AI_CBM_DefenseUp
	if_effect EFFECT_SPEED_UP_2, AI_CBM_SpeedUp
	if_effect EFFECT_SPECIAL_ATTACK_UP_2, AI_CBM_SpAtkUp
	if_effect EFFECT_SPECIAL_DEFENSE_UP_2, AI_CBM_SpDefUp
	if_effect EFFECT_ACCURACY_UP_2, AI_CBM_AccUp
	if_effect EFFECT_EVASION_UP_2, AI_CBM_EvasionUp
	if_effect EFFECT_ATTACK_DOWN_2, AI_CBM_AttackDown
	if_effect EFFECT_DEFENSE_DOWN_2, AI_CBM_DefenseDown
	if_effect EFFECT_SPEED_DOWN_2, AI_CBM_SpeedDown
	if_effect EFFECT_SPECIAL_ATTACK_DOWN_2, AI_CBM_SpAtkDown
	if_effect EFFECT_SPECIAL_DEFENSE_DOWN_2, AI_CBM_SpDefDown
	if_effect EFFECT_ACCURACY_DOWN_2, AI_CBM_AccDown
	if_effect EFFECT_EVASION_DOWN_2, AI_CBM_EvasionDown
	if_effect EFFECT_REFLECT, AI_CBM_Reflect
	if_effect EFFECT_POISON, AI_CBM_Toxic
	if_effect EFFECT_PARALYZE, AI_CBM_Paralyze
	if_effect EFFECT_SUBSTITUTE, AI_CBM_Substitute
	if_effect EFFECT_RECHARGE, AI_CBM_HighRiskForDamage
	if_effect EFFECT_LEECH_SEED, AI_CBM_LeechSeed
	if_effect EFFECT_DISABLE, AI_CBM_Disable
	if_effect EFFECT_LEVEL_DAMAGE, AI_CBM_HighRiskForDamage
	if_effect EFFECT_PSYWAVE, AI_CBM_HighRiskForDamage
	if_effect EFFECT_COUNTER, AI_CBM_HighRiskForDamage
	if_effect EFFECT_ENCORE, AI_CBM_Encore
	if_effect EFFECT_SNORE, AI_CBM_DamageDuringSleep
	if_effect EFFECT_SLEEP_TALK, AI_CBM_DamageDuringSleep
	if_effect EFFECT_FLAIL, AI_CBM_HighRiskForDamage
	if_effect EFFECT_MEAN_LOOK, AI_CBM_CantEscape
	if_effect EFFECT_NIGHTMARE, AI_CBM_Nightmare
	if_effect EFFECT_MINIMIZE, AI_CBM_EvasionUp
	if_effect EFFECT_CURSE, AI_CBM_Curse
	if_effect EFFECT_SPIKES, AI_CBM_Spikes
	if_effect EFFECT_FORESIGHT, AI_CBM_Foresight
	if_effect EFFECT_PERISH_SONG, AI_CBM_PerishSong
	if_effect EFFECT_SANDSTORM, AI_CBM_Sandstorm
	if_effect EFFECT_SWAGGER, AI_CBM_Confuse
	if_effect EFFECT_ATTRACT, AI_CBM_Attract
	if_effect EFFECT_CAPTIVATE, AI_CBM_Captivate
	if_effect EFFECT_RETURN, AI_CBM_HighRiskForDamage
	if_effect EFFECT_PRESENT, AI_CBM_HighRiskForDamage
	if_effect EFFECT_FRUSTRATION, AI_CBM_HighRiskForDamage
	if_effect EFFECT_SAFEGUARD, AI_CBM_Safeguard
	if_effect EFFECT_MAGNITUDE, AI_CBM_Magnitude
	if_effect EFFECT_BATON_PASS, AI_CBM_BatonPass
	if_effect EFFECT_SONICBOOM, AI_CBM_HighRiskForDamage
	if_effect EFFECT_RAIN_DANCE, AI_CBM_RainDance
	if_effect EFFECT_SUNNY_DAY, AI_CBM_SunnyDay
	if_effect EFFECT_BELLY_DRUM, AI_CBM_BellyDrum
	if_effect EFFECT_PSYCH_UP, AI_CBM_Haze
	if_effect EFFECT_MIRROR_COAT, AI_CBM_HighRiskForDamage
	if_effect EFFECT_SKULL_BASH, AI_CBM_HighRiskForDamage
	if_effect EFFECT_FUTURE_SIGHT, AI_CBM_FutureSight
	if_effect EFFECT_TELEPORT, Score_Minus10
	if_effect EFFECT_DEFENSE_CURL, AI_CBM_DefenseUp
	if_effect EFFECT_FAKE_OUT, AI_CBM_FakeOut
	if_effect EFFECT_STOCKPILE, AI_CBM_Stockpile
	if_effect EFFECT_SPIT_UP, AI_CBM_SpitUpAndSwallow
	if_effect EFFECT_SWALLOW, AI_CBM_SpitUpAndSwallow
	if_effect EFFECT_HAIL, AI_CBM_Hail
	if_effect EFFECT_TORMENT, AI_CBM_Torment
	if_effect EFFECT_FLATTER, AI_CBM_Confuse
	if_effect EFFECT_WILL_O_WISP, AI_CBM_WillOWisp
	if_effect EFFECT_MEMENTO, AI_CBM_Memento
	if_effect EFFECT_FOCUS_PUNCH, AI_CBM_HighRiskForDamage
	if_effect EFFECT_HELPING_HAND, AI_CBM_HelpingHand
	if_effect EFFECT_TRICK, AI_CBM_TrickAndKnockOff
	if_effect EFFECT_INGRAIN, AI_CBM_Ingrain
	if_effect EFFECT_SUPERPOWER, AI_CBM_HighRiskForDamage
	if_effect EFFECT_RECYCLE, AI_CBM_Recycle
	if_effect EFFECT_KNOCK_OFF, AI_CBM_TrickAndKnockOff
	if_effect EFFECT_ENDEAVOR, AI_CBM_HighRiskForDamage
	if_effect EFFECT_IMPRISON, AI_CBM_Imprison
	if_effect EFFECT_REFRESH, AI_CBM_Refresh
	if_effect EFFECT_LOW_KICK, AI_CBM_HighRiskForDamage
	if_effect EFFECT_MUD_SPORT, AI_CBM_MudSport
	if_effect EFFECT_TICKLE, AI_CBM_Tickle
	if_effect EFFECT_COSMIC_POWER, AI_CBM_CosmicPower
	if_effect EFFECT_BULK_UP, AI_CBM_BulkUp
	if_effect EFFECT_WATER_SPORT, AI_CBM_WaterSport
	if_effect EFFECT_CALM_MIND, AI_CBM_CalmMind
	if_effect EFFECT_DRAGON_DANCE, AI_CBM_DragonDance
	if_effect EFFECT_STICKY_WEB, AI_CBM_StickyWeb
	if_effect EFFECT_STEALTH_ROCK, AI_CBM_StealthRock
	if_effect EFFECT_TOXIC_SPIKES, AI_CBM_ToxicSpikes
	if_effect EFFECT_AQUA_RING, AI_CBM_AquaRing
	if_effect EFFECT_GRAVITY, AI_CBM_Gravity
	if_effect EFFECT_EMBARGO, AI_CBM_Embargo
	if_effect EFFECT_LUCKY_CHANT, AI_CBM_LuckyChant
	if_effect EFFECT_HEAL_PULSE, AI_CBM_HealPulse
	if_effect EFFECT_QUASH, AI_CBM_Quash
	if_effect EFFECT_GASTRO_ACID, AI_CBM_GastroAcid
	if_effect EFFECT_HEAL_BLOCK, AI_CBM_HealBlock
	if_effect EFFECT_WORRY_SEED, AI_CBM_WorrySeed
	if_effect EFFECT_MIRACLE_EYE, AI_CBM_MiracleEye
	if_effect EFFECT_MAGNET_RISE, AI_CBM_MagnetRise
	if_effect EFFECT_TELEKINESIS, AI_CBM_Telekinesis
	if_effect EFFECT_MISTY_TERRAIN, AI_CBM_MistyTerrain
	if_effect EFFECT_GRASSY_TERRAIN, AI_CBM_GrassyTerrain
	if_effect EFFECT_ELECTRIC_TERRAIN, AI_CBM_ElectricTerrain
	if_effect EFFECT_PSYCHIC_TERRAIN, AI_CBM_PsychicTerrain
	if_effect EFFECT_QUIVER_DANCE, AI_CBM_QuiverDance
	if_effect EFFECT_COIL, AI_CBM_Coil
	if_effect EFFECT_TAILWIND, AI_CBM_Tailwind
	if_effect EFFECT_SIMPLE_BEAM, AI_CBM_SimpleBeam
	if_effect EFFECT_NATURAL_GIFT, AI_CBM_NaturalGift
	if_effect EFFECT_FLING, AI_CBM_Fling
	if_effect EFFECT_ATTACK_ACCURACY_UP, AI_CBM_AtkAccUp
	if_effect EFFECT_ATTACK_SPATK_UP, AI_CBM_AtkSpAtkUp
	if_effect EFFECT_GROWTH, AI_CBM_AtkSpAtkUp
	if_effect EFFECT_AROMATIC_MIST, AI_CBM_AromaticMist
	if_effect EFFECT_ACUPRESSURE, AI_CBM_Acupressure
	if_effect EFFECT_BESTOW, AI_CBM_Bestow
	if_effect EFFECT_PSYCHO_SHIFT, AI_CBM_PsychicShift
	if_effect EFFECT_DEFOG, AI_CBM_Defog
	if_effect EFFECT_SYNCHRONOISE, AI_CBM_Synchronoise
	if_effect EFFECT_AUTONOMIZE, AI_CBM_SpeedUp
	if_effect EFFECT_TOXIC_THREAD, AI_CBM_ToxicThread
	if_effect EFFECT_VENOM_DRENCH, AI_CBM_VenomDrench
	if_effect EFFECT_DEFENSE_UP_3, AI_CBM_DefenseUp
	if_effect EFFECT_SHIFT_GEAR, AI_CBM_DragonDance
	if_effect EFFECT_NOBLE_ROAR, AI_CBM_NobleRoar
	if_effect EFFECT_SHELL_SMASH, AI_CBM_ShellSmash
	if_effect EFFECT_LAST_RESORT, AI_CBM_LastResort
	if_effect EFFECT_BELCH, AI_CBM_Belch
	if_effect EFFECT_DO_NOTHING, Score_Minus8
	if_effect EFFECT_POWDER, AI_CBM_Powder
	if_effect EFFECT_PROTECT, AI_CBM_Protect
	if_effect EFFECT_TAUNT, AI_CBM_Taunt
	if_effect EFFECT_HEAL_BELL, AI_CBM_HealBell
	if_effect EFFECT_FOLLOW_ME, AI_CBM_FollowMe
	if_effect EFFECT_FALSE_SWIPE, Score_Minus5
	if_effect EFFECT_SUCKER_PUNCH, AI_CBM_SuckerPunch
	if_effect EFFECT_WIDE_GUARD, AI_CBM_Protect
	end

AI_CBM_HealPulse:
	if_not_double_battle Score_Minus30
	if_target_is_ally AI_CBM_HealPulse2
	goto Score_Minus30
AI_CBM_HealPulse2:
	if_hp_equal AI_TARGET, 100, Score_Minus5
	end

AI_CBM_SuckerPunch:
	if_has_no_attacking_moves AI_USER, Score_Minus10
	end

AI_CBM_FollowMe:
	if_not_double_battle Score_Minus10
	if_battler_absent AI_USER_PARTNER, Score_Minus10
	end

AI_CBM_HealBell:
	if_status AI_USER, STATUS1_ANY, Score_Plus2
	if_status_in_party AI_USER, STATUS1_ANY, Score_Plus2
	score -10
	end

AI_CBM_Taunt:
	if_target_taunted Score_Minus10
	end

AI_CBM_Protect:
	get_protect_count AI_USER
	if_more_than 2, Score_Minus10
	if_status AI_TARGET, STATUS1_SLEEP | STATUS1_FREEZE, Score_Minus8
	end

AI_CBM_Powder:
	if_type AI_TARGET, TYPE_FIRE, AI_Ret
	if_has_move_with_type AI_TARGET, TYPE_FIRE, AI_Ret
	score -5
	end

AI_CBM_Belch:
	if_cant_use_belch AI_USER, Score_Minus10
	end

AI_CBM_LastResort:
	if_cant_use_last_resort AI_USER, Score_Minus10
	end

AI_CBM_ShellSmash:
	if_ability AI_USER, ABILITY_CONTRARY, AI_CBM_ShellSmashContrary
	if_stat_level_not_equal AI_USER, STAT_SPATK, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_SPEED, 12, AI_Ret
	if_stat_level_equal AI_USER, STAT_ATK, 12, Score_Minus10
	end
AI_CBM_ShellSmashContrary:
	if_stat_level_not_equal AI_USER, STAT_DEF, 12, AI_Ret
	if_stat_level_equal AI_USER, STAT_SPDEF, 12, Score_Minus10
	end

AI_CBM_NobleRoar:
	if_stat_level_not_equal AI_TARGET, STAT_SPATK, 12, AI_Ret
	if_stat_level_equal AI_TARGET, STAT_ATK, 12, Score_Minus10
	end

AI_CBM_VenomDrench:
	if_not_status AI_TARGET, STATUS1_PSN_ANY, Score_Minus10
	if_stat_level_not_equal AI_TARGET, STAT_SPEED, 12, AI_Ret
	if_stat_level_not_equal AI_TARGET, STAT_SPATK, 12, AI_Ret
	if_stat_level_equal AI_TARGET, STAT_ATK, 12, Score_Minus10
	end

AI_CBM_ToxicThread:
	if_stat_level_not_equal AI_TARGET, STAT_SPEED, 12, AI_Ret
	goto AI_CBM_Toxic

AI_CBM_Synchronoise:
	if_share_type AI_USER, AI_TARGET AI_Ret
	goto Score_Minus10

AI_CBM_Defog:
	if_side_affecting AI_USER, SIDE_STATUS_SPIKES | SIDE_STATUS_STEALTH_ROCK | SIDE_STATUS_TOXIC_SPIKES | SIDE_STATUS_STICKY_WEB, AI_Ret
	goto AI_CBM_EvasionDown

AI_CBM_PsychicShift:
	if_not_status AI_USER, STATUS1_ANY, Score_Minus10
	if_status AI_TARGET, STATUS1_ANY, Score_Minus10
	if_status AI_USER, STATUS1_PARALYSIS, AI_CBM_Paralyze
	if_status AI_USER, STATUS1_PSN_ANY, AI_CBM_Toxic
	if_status AI_USER, STATUS1_BURN, AI_CBM_WillOWisp
	if_status AI_USER, STATUS1_SLEEP, AI_CBM_Sleep
	end

AI_CBM_Bestow:
	if_target_is_ally AI_CBM_Bestow2
	score -10
	end

AI_CBM_Bestow2:
	if_holds_no_item AI_USER, Score_Minus10
	if_holds_no_item AI_TARGET, AI_Ret
	score -10
	end

AI_CBM_Acupressure:
	if_double_battle AI_Ret
	if_stat_level_not_equal AI_USER, STAT_ATK, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_DEF, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_SPATK, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_SPDEF, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_SPEED, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_ACC, 12, AI_Ret
	if_stat_level_equal AI_USER, STAT_EVASION, 12, Score_Minus10
	end

AI_CBM_AromaticMist:
	if_target_is_ally AI_Ret
	goto Score_Minus10

AI_CBM_AtkAccUp:
	if_stat_level_not_equal AI_USER, STAT_ATK, 12, AI_Ret
	if_stat_level_equal AI_USER, STAT_ACC, 12, Score_Minus10
	end

AI_CBM_AtkSpAtkUp:
	if_stat_level_not_equal AI_USER, STAT_ATK, 12, AI_Ret
	if_stat_level_equal AI_USER, STAT_SPATK, 12, Score_Minus10
	end

AI_CBM_Fling:
	if_holds_no_item AI_USER, Score_Minus10
	if_ability AI_USER, ABILITY_KLUTZ, Score_Minus10
	if_status3 AI_USER, STATUS3_EMBARGO, Score_Minus10
	if_field_status STATUS_FIELD_MAGIC_ROOM, Score_Minus10
	end

AI_CBM_NaturalGift:
	if_doesnt_hold_berry AI_USER, Score_Minus10
	if_ability AI_USER, ABILITY_KLUTZ, Score_Minus10
	if_status3 AI_USER, STATUS3_EMBARGO, Score_Minus10
	if_field_status STATUS_FIELD_MAGIC_ROOM, Score_Minus10
	end

AI_CBM_SimpleBeam:
	if_ability AI_TARGET, ABILITY_SIMPLE, Score_Minus10
	end

AI_CBM_Tailwind:
	if_side_affecting AI_USER, SIDE_STATUS_TAILWIND, Score_Minus10
	if_field_status STATUS_FIELD_TRICK_ROOM, Score_Minus10
	end

AI_CBM_QuiverDance:
	if_stat_level_not_equal AI_USER, STAT_SPATK, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_SPDEF, 12, AI_Ret
	if_stat_level_equal AI_USER, STAT_SPEED, 12, Score_Minus10
	end

AI_CBM_Coil:
	if_stat_level_not_equal AI_USER, STAT_ATK, 12, AI_Ret
	if_stat_level_not_equal AI_USER, STAT_DEF, 12, AI_Ret
	if_stat_level_equal AI_USER, STAT_ACC, 12, Score_Minus10
	end

AI_CBM_MistyTerrain:
	if_field_status STATUS_FIELD_MISTY_TERRAIN, Score_Minus10
	end

AI_CBM_GrassyTerrain:
	if_field_status STATUS_FIELD_GRASSY_TERRAIN, Score_Minus10
	end

AI_CBM_ElectricTerrain:
	if_field_status STATUS_FIELD_ELECTRIC_TERRAIN, Score_Minus10
	end

AI_CBM_PsychicTerrain:
	if_field_status STATUS_FIELD_PSYCHIC_TERRAIN, Score_Minus10
	end

AI_CBM_Quash:
	if_not_double_battle Score_Minus10
	end

AI_CBM_Telekinesis:
	if_status3 AI_TARGET, STATUS3_TELEKINESIS, Score_Minus10
	end

AI_CBM_MagnetRise:
	if_status3 AI_USER, STATUS3_MAGNET_RISE, Score_Minus10
	end

AI_CBM_MiracleEye:
	if_status3 AI_TARGET, STATUS3_MIRACLE_EYED, Score_Minus10
	if_status2 AI_TARGET, STATUS2_FORESIGHT, Score_Minus10
	end

AI_CBM_WorrySeed:
	get_ability AI_TARGET
	if_equal ABILITY_INSOMNIA, Score_Minus10
	if_equal ABILITY_VITAL_SPIRIT, Score_Minus10
	end

AI_CBM_HealBlock:
	if_status3 AI_TARGET, STATUS3_HEAL_BLOCK, Score_Minus10
	end

AI_CBM_GastroAcid:
	if_status3 AI_TARGET, STATUS3_GASTRO_ACID, Score_Minus10
	end

AI_CBM_AquaRing:
	if_status3 AI_USER, STATUS3_AQUA_RING, Score_Minus10
	end

AI_CBM_LuckyChant:
	if_side_affecting AI_USER, SIDE_STATUS_LUCKY_CHANT, Score_Minus10
	end

AI_CBM_Embargo:
	if_status3 AI_TARGET, STATUS3_EMBARGO, Score_Minus10
	end

AI_CBM_Gravity:
	if_field_status STATUS_FIELD_GRAVITY, Score_Minus10
	end

AI_CBM_ToxicSpikes:
	if_not_side_affecting AI_TARGET, SIDE_STATUS_TOXIC_SPIKES, AI_Ret
	get_hazards_count AI_TARGET, EFFECT_TOXIC_SPIKES
	if_equal 2, Score_Minus10
	end

AI_CBM_StealthRock:
	if_side_affecting AI_TARGET, SIDE_STATUS_STEALTH_ROCK, Score_Minus10
	end

AI_CBM_StickyWeb:
	if_side_affecting AI_TARGET, SIDE_STATUS_STICKY_WEB, Score_Minus10
	end

AI_CBM_Sleep: @ 82DC2D4
	get_ability AI_TARGET
	if_equal ABILITY_INSOMNIA, Score_Minus10
	if_equal ABILITY_VITAL_SPIRIT, Score_Minus10
	if_status AI_TARGET, STATUS1_ANY, Score_Minus10
	if_side_affecting AI_TARGET, SIDE_STATUS_SAFEGUARD, Score_Minus10
	end

AI_CBM_Explosion: @ 82DC2F7
	if_type_effectiveness AI_EFFECTIVENESS_x0, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_DAMP, Score_Minus10
	count_usable_party_mons AI_USER
	if_not_equal 0, AI_CBM_Explosion_End
	count_usable_party_mons AI_TARGET
	if_not_equal 0, Score_Minus10
	goto Score_Minus1

AI_CBM_Explosion_End: @ 82DC31A
	end

AI_CBM_Nightmare: @ 82DC31B
	if_status2 AI_TARGET, STATUS2_NIGHTMARE, Score_Minus10
	if_not_status AI_TARGET, STATUS1_SLEEP, Score_Minus8
	end

AI_CBM_DreamEater: @ 82DC330
	if_not_status AI_TARGET, STATUS1_SLEEP, Score_Minus8
	if_type_effectiveness AI_EFFECTIVENESS_x0, Score_Minus10
	end

AI_CBM_BellyDrum: @ 82DC341
	if_hp_less_than AI_USER, 51, Score_Minus10

AI_CBM_AttackUp: @ 82DC348
	if_stat_level_equal AI_USER, STAT_ATK, 12, Score_Minus10
	@ Do not raise attack if has no physical moves
	if_has_move_with_effect AI_USER, EFFECT_BATON_PASS, AI_Ret
	if_has_no_physical_move AI_USER, Score_Minus10
	end

AI_CBM_DefenseUp: @ 82DC351
	if_stat_level_equal AI_USER, STAT_DEF, 12, Score_Minus10
	end

AI_CBM_SpeedUp: @ 82DC35A
	if_stat_level_equal AI_USER, STAT_SPEED, 12, Score_Minus10
	end

AI_CBM_SpAtkUp: @ 82DC363
	if_stat_level_equal AI_USER, STAT_SPATK, 12, Score_Minus10
	@ Do not raise sp. attack if has no special moves
	if_has_move_with_effect AI_USER, EFFECT_BATON_PASS, AI_Ret
	if_has_no_special_move AI_USER, Score_Minus10
	end

AI_CBM_SpDefUp: @ 82DC36C
	if_stat_level_equal AI_USER, STAT_SPDEF, 12, Score_Minus10
	end

AI_CBM_AccUp: @ 82DC375
	if_stat_level_equal AI_USER, STAT_ACC, 12, Score_Minus10
	end

AI_CBM_EvasionUp: @ 82DC37E
	if_stat_level_equal AI_USER, STAT_EVASION, 12, Score_Minus10
	end

AI_CBM_AttackDown: @ 82DC387
	if_stat_level_equal AI_TARGET, STAT_ATK, 0, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_HYPER_CUTTER, Score_Minus10
	goto CheckIfAbilityBlocksStatChange

AI_CBM_DefenseDown: @ 82DC39C
	if_stat_level_equal AI_TARGET, STAT_DEF, 0, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_BIG_PECKS, Score_Minus10
	goto CheckIfAbilityBlocksStatChange

AI_CBM_SpeedDown: @ 82DC3A9
	if_stat_level_equal AI_TARGET, STAT_SPEED, 0, Score_Minus10
	if_ability AI_TARGET, ABILITY_SPEED_BOOST, Score_Minus10
	goto CheckIfAbilityBlocksStatChange

AI_CBM_SpAtkDown: @ 82DC3BF
	if_stat_level_equal AI_TARGET, STAT_SPATK, 0, Score_Minus10
	goto CheckIfAbilityBlocksStatChange

AI_CBM_SpDefDown: @ 82DC3CC
	if_stat_level_equal AI_TARGET, STAT_SPDEF, 0, Score_Minus10
	goto CheckIfAbilityBlocksStatChange

AI_CBM_AccDown: @ 82DC3D9
	if_stat_level_equal AI_TARGET, STAT_ACC, 0, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_KEEN_EYE, Score_Minus10
	goto CheckIfAbilityBlocksStatChange

AI_CBM_EvasionDown: @ 82DC3EE
	if_stat_level_equal AI_TARGET, STAT_EVASION, 0, Score_Minus10

CheckIfAbilityBlocksStatChange: @ 82DC3F6
	get_ability AI_TARGET
	if_equal ABILITY_CLEAR_BODY, Score_Minus10
	if_equal ABILITY_WHITE_SMOKE, Score_Minus10
	end

AI_CBM_Haze: @ 82DC405
	if_stat_level_less_than AI_USER, STAT_ATK, 6, AI_CBM_Haze_End
	if_stat_level_less_than AI_USER, STAT_DEF, 6, AI_CBM_Haze_End
	if_stat_level_less_than AI_USER, STAT_SPEED, 6, AI_CBM_Haze_End
	if_stat_level_less_than AI_USER, STAT_SPATK, 6, AI_CBM_Haze_End
	if_stat_level_less_than AI_USER, STAT_SPDEF, 6, AI_CBM_Haze_End
	if_stat_level_less_than AI_USER, STAT_ACC, 6, AI_CBM_Haze_End
	if_stat_level_less_than AI_USER, STAT_EVASION, 6, AI_CBM_Haze_End
	if_stat_level_more_than AI_TARGET, STAT_ATK, 6, AI_CBM_Haze_End
	if_stat_level_more_than AI_TARGET, STAT_DEF, 6, AI_CBM_Haze_End
	if_stat_level_more_than AI_TARGET, STAT_SPEED, 6, AI_CBM_Haze_End
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 6, AI_CBM_Haze_End
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 6, AI_CBM_Haze_End
	if_stat_level_more_than AI_TARGET, STAT_ACC, 6, AI_CBM_Haze_End
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 6, AI_CBM_Haze_End
	goto Score_Minus10

AI_CBM_Haze_End: @ 82DC47A
	end

AI_CBM_Roar: @ 82DC47B
	count_usable_party_mons AI_TARGET
	if_equal 0, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_SUCTION_CUPS, Score_Minus10
	end

AI_CBM_Toxic: @ 82DC48C
	get_target_type1
	if_equal TYPE_STEEL, Score_Minus10
	if_equal TYPE_POISON, Score_Minus10
	get_target_type2
	if_equal TYPE_STEEL, Score_Minus10
	if_equal TYPE_POISON, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_IMMUNITY, Score_Minus10
	if_equal ABILITY_TOXIC_BOOST, Score_Minus10
	if_status AI_TARGET, STATUS1_ANY, Score_Minus10
	if_side_affecting AI_TARGET, SIDE_STATUS_SAFEGUARD, Score_Minus10
	end

AI_CBM_LightScreen: @ 82DC4C5
	if_side_affecting AI_USER, SIDE_STATUS_LIGHTSCREEN, Score_Minus8
	end

AI_CBM_OneHitKO: @ 82DC4D0
	if_type_effectiveness AI_EFFECTIVENESS_x0, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_STURDY, Score_Minus10
	if_level_cond 1, Score_Minus10
	end

AI_CBM_Magnitude: @ 82DC4E5
	get_ability AI_TARGET
	if_equal ABILITY_LEVITATE, Score_Minus10

AI_CBM_HighRiskForDamage: @ 82DC4ED
	if_type_effectiveness AI_EFFECTIVENESS_x0, Score_Minus10
	get_ability AI_TARGET
	if_not_equal ABILITY_WONDER_GUARD, AI_CBM_HighRiskForDamage_End
	if_type_effectiveness AI_EFFECTIVENESS_x2, AI_CBM_HighRiskForDamage_End
	goto Score_Minus10

AI_CBM_HighRiskForDamage_End: @ 82DC506
	end

AI_CBM_Mist: @ 82DC507
	if_side_affecting AI_USER, SIDE_STATUS_MIST, Score_Minus8
	end

AI_CBM_FocusEnergy: @ 82DC512
	if_status2 AI_USER, STATUS2_FOCUS_ENERGY, Score_Minus10
	end

AI_CBM_Confuse: @ 82DC51D
	if_status2 AI_TARGET, STATUS2_CONFUSION, Score_Minus5
	get_ability AI_TARGET
	if_equal ABILITY_OWN_TEMPO, Score_Minus10
	if_side_affecting AI_TARGET, SIDE_STATUS_SAFEGUARD, Score_Minus10
	end

AI_CBM_Reflect: @ 82DC53A
	if_side_affecting AI_USER, SIDE_STATUS_REFLECT, Score_Minus8
	end

AI_CBM_Paralyze: @ 82DC545
	if_type_effectiveness AI_EFFECTIVENESS_x0, Score_Minus10
	get_target_type1
	if_equal TYPE_ELECTRIC, Score_Minus10
	get_target_type2
	if_equal TYPE_ELECTRIC, Score_Minus10
	get_ability AI_TARGET
	if_equal ABILITY_LIMBER, Score_Minus10
	if_status AI_TARGET, STATUS1_ANY, Score_Minus10
	if_side_affecting AI_TARGET, SIDE_STATUS_SAFEGUARD, Score_Minus10
	end

AI_CBM_Substitute: @ 82DC568
	if_status2 AI_USER, STATUS2_SUBSTITUTE, Score_Minus8
	if_hp_less_than AI_USER, 26, Score_Minus10
	end

AI_CBM_LeechSeed: @ 82DC57A
	if_status3 AI_TARGET, STATUS3_LEECHSEED, Score_Minus10
	get_target_type1
	if_equal TYPE_GRASS, Score_Minus10
	get_target_type2
	if_equal TYPE_GRASS, Score_Minus10
	end

AI_CBM_Disable: @ 82DC595
	if_any_move_disabled AI_TARGET, Score_Minus8
	if_no_move_used AI_TARGET, Score_Minus8
	end

AI_CBM_Encore: @ 82DC59D
	if_any_move_encored AI_TARGET, Score_Minus8
	if_no_move_used AI_TARGET, Score_Minus8
	end

AI_CBM_DamageDuringSleep: @ 82DC5A5
	if_not_status AI_USER, STATUS1_SLEEP, Score_Minus8
	end

AI_CBM_CantEscape: @ 82DC5B0
	if_status2 AI_TARGET, STATUS2_ESCAPE_PREVENTION, Score_Minus10
	end

AI_CBM_Curse: @ 82DC5BB
	if_stat_level_equal AI_USER, STAT_ATK, 12, Score_Minus10
	if_stat_level_equal AI_USER, STAT_DEF, 12, Score_Minus8
	end

AI_CBM_Spikes: @ 82DC5CC
	if_not_side_affecting AI_TARGET, SIDE_STATUS_SPIKES, AI_Ret
	get_hazards_count AI_TARGET, EFFECT_SPIKES
	if_equal 3, Score_Minus10
	end

AI_CBM_Foresight: @ 82DC5D7
	if_status2 AI_TARGET, STATUS2_FORESIGHT, Score_Minus10
	if_status3 AI_TARGET, STATUS3_MIRACLE_EYED, Score_Minus10
	end

AI_CBM_PerishSong: @ 82DC5E2
	if_status3 AI_TARGET, STATUS3_PERISH_SONG, Score_Minus10
	end

AI_CBM_Sandstorm: @ 82DC5ED
	get_weather
	if_equal AI_WEATHER_SANDSTORM, Score_Minus8
	end

AI_IsOppositeGender:
	get_ability AI_TARGET
	if_equal ABILITY_OBLIVIOUS, Score_Minus10
	get_gender AI_USER
	if_equal 0, AI_IsOppositeGenderFemale
	if_equal 254, AI_IsOppositeGenderMale
	goto Score_Minus10
AI_IsOppositeGenderFemale: @ 82DC61A
	get_gender AI_TARGET
	if_equal 254, AI_CBM_Attract_End
	goto Score_Minus10
AI_IsOppositeGenderMale: @ 82DC627
	get_gender AI_TARGET
	if_equal 0, AI_CBM_Attract_End
	goto Score_Minus10
	end

AI_CBM_Captivate:
	call AI_IsOppositeGender
	goto AI_CBM_SpAtkDown

AI_CBM_Attract: @ 82DC5F5
	if_status2 AI_TARGET, STATUS2_INFATUATION, Score_Minus10
	call AI_IsOppositeGender
	end

AI_CBM_Attract_End: @ 82DC634
	end

AI_CBM_Safeguard: @ 82DC635
	if_side_affecting AI_USER, SIDE_STATUS_SAFEGUARD, Score_Minus8
	end

AI_CBM_Memento: @ 82DC640
	if_stat_level_equal AI_TARGET, STAT_ATK, 0, Score_Minus10
	if_stat_level_equal AI_TARGET, STAT_SPATK, 0, Score_Minus8

AI_CBM_BatonPass: @ 82DC650
	count_usable_party_mons AI_USER
	if_equal 0, Score_Minus10
	end

AI_CBM_RainDance: @ 82DC659
	get_weather
	if_equal AI_WEATHER_RAIN, Score_Minus8
	end

AI_CBM_SunnyDay: @ 82DC661
	get_weather
	if_equal AI_WEATHER_SUN, Score_Minus8
	end

AI_CBM_FutureSight: @ 82DC669
	if_side_affecting AI_TARGET, SIDE_STATUS_FUTUREATTACK, Score_Minus12
	if_side_affecting AI_USER, SIDE_STATUS_FUTUREATTACK, Score_Minus12
	score +5
	end

AI_CBM_FakeOut: @ 82DC680
	is_first_turn_for AI_USER
	if_equal 0, Score_Minus10
	end

AI_CBM_Stockpile: @ 82DC689
	get_stockpile_count AI_USER
	if_equal 3, Score_Minus10
	end

AI_CBM_SpitUpAndSwallow: @ 82DC692
	if_type_effectiveness AI_EFFECTIVENESS_x0, Score_Minus10
	get_stockpile_count AI_USER
	if_equal 0, Score_Minus10
	end

AI_CBM_Hail: @ 82DC6A1
	get_weather
	if_equal AI_WEATHER_HAIL, Score_Minus8
	end

AI_CBM_Torment: @ 82DC6A9
	if_status2 AI_TARGET, STATUS2_TORMENT, Score_Minus10
	end

AI_CBM_WillOWisp: @ 82DC6B4
	get_ability AI_TARGET
	if_equal ABILITY_WATER_VEIL, Score_Minus10
	if_equal ABILITY_FLARE_BOOST, Score_Minus10
	if_status AI_TARGET, STATUS1_ANY, Score_Minus10
	get_target_type1
	if_equal TYPE_FIRE, Score_Minus10
	get_target_type2
	if_equal TYPE_FIRE, Score_Minus10
	if_side_affecting AI_TARGET, SIDE_STATUS_SAFEGUARD, Score_Minus10
	end

AI_CBM_HelpingHand: @ 82DC6E3
	if_not_double_battle Score_Minus10
	end

AI_CBM_TrickAndKnockOff: @ 82DC6EB
	get_ability AI_TARGET
	if_equal ABILITY_STICKY_HOLD, Score_Minus10
	end

AI_CBM_Ingrain: @ 82DC6F4
	if_status3 AI_USER, STATUS3_ROOTED, Score_Minus10
	end

AI_CBM_Recycle: @ 82DC6FF
	get_used_held_item AI_USER
	if_equal 0, Score_Minus10
	end

AI_CBM_Imprison: @ 82DC708
	if_status3 AI_USER, STATUS3_IMPRISONED_OTHERS, Score_Minus10
	end

AI_CBM_Refresh: @ 82DC713
	if_not_status AI_USER, STATUS1_POISON | STATUS1_BURN | STATUS1_PARALYSIS | STATUS1_TOXIC_POISON, Score_Minus10
	end

AI_CBM_MudSport: @ 82DC71E
	if_field_status STATUS_FIELD_MUDSPORT, Score_Minus10
	end

AI_CBM_Tickle: @ 82DC729
	if_stat_level_equal AI_TARGET, STAT_ATK, 0, Score_Minus10
	if_stat_level_equal AI_TARGET, STAT_DEF, 0, Score_Minus8
	end

AI_CBM_CosmicPower: @ 82DC73A
	if_stat_level_equal AI_USER, STAT_DEF, 12, Score_Minus10
	if_stat_level_equal AI_USER, STAT_SPDEF, 12, Score_Minus8
	end

AI_CBM_BulkUp: @ 82DC74B
	if_stat_level_equal AI_USER, STAT_ATK, 12, Score_Minus10
	if_stat_level_equal AI_USER, STAT_DEF, 12, Score_Minus8
	end

AI_CBM_WaterSport: @ 82DC75C
	if_field_status STATUS_FIELD_WATERSPORT, Score_Minus10
	end

AI_CBM_CalmMind: @ 82DC767
	if_stat_level_equal AI_USER, STAT_SPATK, 12, Score_Minus10
	if_stat_level_equal AI_USER, STAT_SPDEF, 12, Score_Minus8
	end

AI_CBM_DragonDance: @ 82DC778
	if_stat_level_equal AI_USER, STAT_ATK, 12, Score_Minus10
	if_stat_level_equal AI_USER, STAT_SPEED, 12, Score_Minus8
	end

Score_Minus1:
	score -1
	end

Score_Minus2:
	score -2
	end

Score_Minus3:
	score -3
	end

Score_Minus5:
	score -5
	end

Score_Minus8:
	score -8
	end

Score_Minus10:
	score -10
	end

Score_Minus12:
	score -12
	end

Score_Minus30:
	score -30
	end

Score_Plus1:
	score +1
	end

Score_Plus2:
	score +2
	end

Score_Plus3:
	score +3
	end

Score_Plus5:
	score +5
	end

Score_Plus10:
	score +10
	end

@ omae wa mou shindeiru
@ Basically a scenario where the players mon is faster, able to hit and able to OHKO
@ In which, it would be best to use a priority move to deal any damage
AI_CheckIfAlreadyDead:
	if_status2 AI_TARGET, STATUS2_RECHARGE | STATUS2_BIDE, AI_Ret
	if_ai_can_go_down AI_CheckIfAlreadyDeadPriorities
	end
AI_CheckIfAlreadyDeadPriorities:
	if_target_faster Score_Minus1
	if_random_less_than 126, AI_Ret
	score +1
	end

@ The purpose is to use a move effect that hits the hardest or similar
AI_CV_DmgMove:
	get_considered_move_power
	if_equal 0, AI_Ret
	get_how_powerful_move_is
	if_equal MOVE_POWER_WEAK, Score_Minus1
	end

@ If move deals shit damage, and there are other mons to switch in, use support moves instead
AI_WeakDmg:
	get_considered_move_power
	if_equal 0, AI_Ret
	if_has_no_move_with_split AI_USER, SPLIT_STATUS, AI_Ret
	get_curr_dmg_hp_percent
	if_more_than 30, AI_Ret
	if_more_than 20, Score_Minus1
	get_how_powerful_move_is
	if_equal MOVE_POWER_BEST, Score_Minus2
	score -3
	end

AI_CheckViability:
	if_target_is_ally AI_Ret
	call_if_always_hit AI_CV_AlwaysHit
	call_if_move_flag FLAG_HIGH_CRIT, AI_CV_HighCrit
	call AI_CheckIfAlreadyDead
	call AI_CV_DmgMove
	call AI_WeakDmg
	if_effect EFFECT_HIT, AI_CV_Hit
	if_effect EFFECT_SLEEP, AI_CV_Sleep
	if_effect EFFECT_ABSORB, AI_CV_Absorb
	if_effect EFFECT_EXPLOSION, AI_CV_SelfKO
	if_effect EFFECT_DREAM_EATER, AI_CV_DreamEater
	if_effect EFFECT_MIRROR_MOVE, AI_CV_MirrorMove
	if_effect EFFECT_ATTACK_UP, AI_CV_AttackUp
	if_effect EFFECT_DEFENSE_UP, AI_CV_DefenseUp
	if_effect EFFECT_SPEED_UP, AI_CV_SpeedUp
	if_effect EFFECT_SPECIAL_ATTACK_UP, AI_CV_SpAtkUp
	if_effect EFFECT_SPECIAL_DEFENSE_UP, AI_CV_SpDefUp
	if_effect EFFECT_ACCURACY_UP, AI_CV_AccuracyUp
	if_effect EFFECT_EVASION_UP, AI_CV_EvasionUp
	if_effect EFFECT_ATTACK_DOWN, AI_CV_AttackDown
	if_effect EFFECT_DEFENSE_DOWN, AI_CV_DefenseDown
	if_effect EFFECT_SPEED_DOWN, AI_CV_SpeedDown
	if_effect EFFECT_SPECIAL_ATTACK_DOWN, AI_CV_SpAtkDown
	if_effect EFFECT_SPECIAL_DEFENSE_DOWN, AI_CV_SpDefDown
	if_effect EFFECT_ACCURACY_DOWN, AI_CV_AccuracyDown
	if_effect EFFECT_EVASION_DOWN, AI_CV_EvasionDown
	if_effect EFFECT_HAZE, AI_CV_Haze
	if_effect EFFECT_BIDE, AI_CV_Bide
	if_effect EFFECT_ROAR, AI_CV_Roar
	if_effect EFFECT_CONVERSION, AI_CV_Conversion
	if_effect EFFECT_RESTORE_HP, AI_CV_Heal
	if_effect EFFECT_SOFTBOILED, AI_CV_Heal
	if_effect EFFECT_SWALLOW, AI_CV_Heal
	if_effect EFFECT_ROOST, AI_CV_Heal
	if_effect EFFECT_TOXIC, AI_CV_Toxic
	if_effect EFFECT_LIGHT_SCREEN, AI_CV_LightScreen
	if_effect EFFECT_REST, AI_CV_Rest
	if_effect EFFECT_OHKO, AI_CV_OneHitKO
	if_effect EFFECT_SUPER_FANG, AI_CV_SuperFang
	if_effect EFFECT_TRAP, AI_CV_Trap
	if_effect EFFECT_CONFUSE, AI_CV_Confuse
	if_effect EFFECT_FOCUS_ENERGY, AI_CV_FocusEnergy
	if_effect EFFECT_ATTACK_UP_2, AI_CV_AttackUp
	if_effect EFFECT_DEFENSE_UP_2, AI_CV_DefenseUp
	if_effect EFFECT_SPEED_UP_2, AI_CV_SpeedUp
	if_effect EFFECT_SPECIAL_ATTACK_UP_2, AI_CV_SpAtkUp
	if_effect EFFECT_SPECIAL_DEFENSE_UP_2, AI_CV_SpDefUp
	if_effect EFFECT_ACCURACY_UP_2, AI_CV_AccuracyUp
	if_effect EFFECT_EVASION_UP_2, AI_CV_EvasionUp
	if_effect EFFECT_ATTACK_DOWN_2, AI_CV_AttackDown
	if_effect EFFECT_DEFENSE_DOWN_2, AI_CV_DefenseDown
	if_effect EFFECT_SPEED_DOWN_2, AI_CV_SpeedDown
	if_effect EFFECT_SPECIAL_ATTACK_DOWN_2, AI_CV_SpAtkDown
	if_effect EFFECT_SPECIAL_DEFENSE_DOWN_2, AI_CV_SpDefDown
	if_effect EFFECT_ACCURACY_DOWN_2, AI_CV_AccuracyDown
	if_effect EFFECT_EVASION_DOWN_2, AI_CV_EvasionDown
	if_effect EFFECT_REFLECT, AI_CV_Reflect
	if_effect EFFECT_AURORA_VEIL, AI_CV_AuroraVeil
	if_effect EFFECT_POISON, AI_CV_Poison
	if_effect EFFECT_TOXIC_THREAD, AI_CV_ToxicThread
	if_effect EFFECT_PARALYZE, AI_CV_Paralyze
	if_effect EFFECT_SWAGGER, AI_CV_Swagger
	if_effect EFFECT_SPEED_DOWN_HIT, AI_CV_SpeedDownFromChance
	if_effect EFFECT_TWO_TURNS_ATTACK, AI_CV_ChargeUpMove
	if_effect EFFECT_VITAL_THROW, AI_CV_VitalThrow
	if_effect EFFECT_SUBSTITUTE, AI_CV_Substitute
	if_effect EFFECT_RECHARGE, AI_CV_Recharge
	if_effect EFFECT_LEECH_SEED, AI_CV_LeechSeed
	if_effect EFFECT_DISABLE, AI_CV_Disable
	if_effect EFFECT_COUNTER, AI_CV_Counter
	if_effect EFFECT_ENCORE, AI_CV_Encore
	if_effect EFFECT_PAIN_SPLIT, AI_CV_PainSplit
	if_effect EFFECT_SNORE, AI_CV_Snore
	if_effect EFFECT_LOCK_ON, AI_CV_LockOn
	if_effect EFFECT_SLEEP_TALK, AI_CV_SleepTalk
	if_effect EFFECT_DESTINY_BOND, AI_CV_DestinyBond
	if_effect EFFECT_FLAIL, AI_CV_Flail
	if_effect EFFECT_HEAL_BELL, AI_CV_HealBell
	if_effect EFFECT_THIEF, AI_CV_Thief
	if_effect EFFECT_MEAN_LOOK, AI_CV_Trap
	if_effect EFFECT_MINIMIZE, AI_CV_EvasionUp
	if_effect EFFECT_CURSE, AI_CV_Curse
	if_effect EFFECT_PROTECT, AI_CV_Protect
	if_effect EFFECT_FORESIGHT, AI_CV_Foresight
	if_effect EFFECT_ENDURE, AI_CV_Endure
	if_effect EFFECT_BATON_PASS, AI_CV_BatonPass
	if_effect EFFECT_PURSUIT, AI_CV_Pursuit
	if_effect EFFECT_MORNING_SUN, AI_CV_HealWeather
	if_effect EFFECT_SYNTHESIS, AI_CV_HealWeather
	if_effect EFFECT_MOONLIGHT, AI_CV_HealWeather
	if_effect EFFECT_RAIN_DANCE, AI_CV_RainDance
	if_effect EFFECT_SUNNY_DAY, AI_CV_SunnyDay
	if_effect EFFECT_BELLY_DRUM, AI_CV_BellyDrum
	if_effect EFFECT_PSYCH_UP, AI_CV_PsychUp
	if_effect EFFECT_MIRROR_COAT, AI_CV_MirrorCoat
	if_effect EFFECT_SKULL_BASH, AI_CV_ChargeUpMove
	if_effect EFFECT_SOLARBEAM, AI_CV_ChargeUpMove
	if_effect EFFECT_SEMI_INVULNERABLE, AI_CV_Fly
	if_effect EFFECT_FAKE_OUT, AI_CV_FakeOut
	if_effect EFFECT_SPIT_UP, AI_CV_SpitUp
	if_effect EFFECT_HAIL, AI_CV_Sandstorm
	if_effect EFFECT_SANDSTORM, AI_CV_Sandstorm
	if_effect EFFECT_FLATTER, AI_CV_Flatter
	if_effect EFFECT_MEMENTO, AI_CV_SelfKO
	if_effect EFFECT_FACADE, AI_CV_Facade
	if_effect EFFECT_FOCUS_PUNCH, AI_CV_FocusPunch
	if_effect EFFECT_SMELLINGSALT, AI_CV_SmellingSalt
	if_effect EFFECT_TRICK, AI_CV_Trick
	if_effect EFFECT_ROLE_PLAY, AI_CV_ChangeSelfAbility
	if_effect EFFECT_SUPERPOWER, AI_CV_Superpower
	if_effect EFFECT_MAGIC_COAT, AI_CV_MagicCoat
	if_effect EFFECT_RECYCLE, AI_CV_Recycle
	if_effect EFFECT_REVENGE, AI_CV_Revenge
	if_effect EFFECT_BRICK_BREAK, AI_CV_BrickBreak
	if_effect EFFECT_KNOCK_OFF, AI_CV_KnockOff
	if_effect EFFECT_ENDEAVOR, AI_CV_Endeavor
	if_effect EFFECT_ERUPTION, AI_CV_Eruption
	if_effect EFFECT_SKILL_SWAP, AI_CV_ChangeSelfAbility
	if_effect EFFECT_IMPRISON, AI_CV_Imprison
	if_effect EFFECT_REFRESH, AI_CV_Refresh
	if_effect EFFECT_SNATCH, AI_CV_Snatch
	if_effect EFFECT_MUD_SPORT, AI_CV_MudSport
	if_effect EFFECT_OVERHEAT, AI_CV_Overheat
	if_effect EFFECT_TICKLE, AI_CV_DefenseDown
	if_effect EFFECT_COSMIC_POWER, AI_CV_SpDefUp
	if_effect EFFECT_BULK_UP, AI_CV_DefenseUp
	if_effect EFFECT_WATER_SPORT, AI_CV_WaterSport
	if_effect EFFECT_CALM_MIND, AI_CV_SpDefUp
	if_effect EFFECT_DRAGON_DANCE, AI_CV_DragonDance
	if_effect EFFECT_POWDER, AI_CV_Powder
	if_effect EFFECT_MISTY_TERRAIN, AI_CV_MistyTerrain
	if_effect EFFECT_GRASSY_TERRAIN, AI_CV_GrassyTerrain
	if_effect EFFECT_ELECTRIC_TERRAIN, AI_CV_ElectricTerrain
	if_effect EFFECT_PSYCHIC_TERRAIN, AI_CV_PsychicTerrain
	if_effect EFFECT_STEALTH_ROCK, AI_CV_Hazards
	if_effect EFFECT_SPIKES, AI_CV_Hazards
	if_effect EFFECT_STICKY_WEB, AI_CV_Hazards
	if_effect EFFECT_TOXIC_SPIKES, AI_CV_Hazards
	if_effect EFFECT_PERISH_SONG, AI_CV_PerishSong
	if_effect EFFECT_ROLLOUT, AI_CV_Rollout
	if_effect EFFECT_MULTI_HIT, AI_CV_MultiHit
	if_effect EFFECT_TRIPLE_KICK, AI_CV_MultiHit
	if_effect EFFECT_FUTURE_SIGHT, AI_CV_FutureSight
	if_effect EFFECT_TRICK_ROOM, AI_CV_TrickRoom
	if_effect EFFECT_HIT_ESCAPE, AI_CV_HitEscape
	if_effect EFFECT_POWER_SWAP, AI_CV_PowerSwap
	if_effect EFFECT_GUARD_SWAP, AI_CV_GuardSwap
	if_effect EFFECT_HEART_SWAP, AI_CV_HeartSwap
	if_effect EFFECT_SPEED_SWAP, AI_CV_SpeedSwap
	if_effect EFFECT_FURY_CUTTER, AI_CV_FuryCutter
	if_effect EFFECT_TAILWIND, AI_CV_TailWind
	if_effect EFFECT_EMBARGO, AI_CV_Embargo
	if_effect EFFECT_SUCKER_PUNCH, AI_CV_SuckerPunch
	if_effect EFFECT_HEAL_PULSE, AI_CV_HealPulse
	if_effect EFFECT_HURRICANE, AI_CV_Hurricane
	if_effect EFFECT_SPEED_UP_HIT, AI_CV_SpeedUp2
	if_effect EFFECT_CLEAR_SMOG, AI_CV_ClearSmog
	if_effect EFFECT_WIDE_GUARD, AI_CV_WideGuard
	end

AI_CV_WideGuard:
@	get_protect_count AI_USER
@	if_more_than 2, Score_Minus10
@	if_more_than 1, Score_Minus5
@	if_has_move AI_TARGET, MOVE_FAKE_OUT, AI_CV_WideGuard2
@	has_priority_move AI_TARGET, AI_CV_WideGuard3
	score -10
	end

AI_CV_WideGuard2:
	is_first_turn_for AI_TARGET
	if_equal 1, Score_Plus10
AI_CV_WideGuard3:
	if_not_double_battle AI_Ret
	if_battler_absent AI_TARGET_PARTNER, AI_Ret
	score +2
	if_has_move AI_TARGET_PARTNER, MOVE_FAKE_OUT, AI_CV_WideGuard4
	goto AI_CV_WideGuard5

AI_CV_WideGuard4:
	is_first_turn_for AI_TARGET_PARTNER
	if_equal 1, Score_Plus10
AI_CV_WideGuard5:
	has_priority_move AI_TARGET_PARTNER, Score_Plus2
	end

AI_CV_ClearSmog:
	if_stat_level_less_than AI_TARGET, STAT_ATK, 6, Score_Minus2
	if_stat_level_less_than AI_TARGET, STAT_DEF, 6, Score_Minus2
	if_stat_level_less_than AI_TARGET, STAT_SPEED, 6, Score_Minus2
	if_stat_level_less_than AI_TARGET, STAT_SPATK, 6, Score_Minus2
	if_stat_level_less_than AI_TARGET, STAT_SPDEF, 6, Score_Minus2
	if_stat_level_less_than AI_TARGET, STAT_ACC, 6, Score_Minus2
	if_stat_level_less_than AI_TARGET, STAT_EVASION, 6, Score_Minus2
	end

AI_CV_Hurricane:
	get_weather
	if_equal AI_WEATHER_RAIN, Score_Plus1
	if_equal AI_WEATHER_SUN, Score_Minus2
	end

AI_CV_HealPulse:
	if_hp_more_than AI_TARGET, 75, Score_Minus3
	if_hp_more_than AI_TARGET, 50, Score_Minus1
	end

AI_CV_SuckerPunch:
	if_random_less_than 128, AI_Ret
	if_target_not_taunted Score_Minus1
	end

AI_CV_Embargo:
	if_holds_no_item AI_TARGET, Score_Minus1
	end

AI_CV_TailWind:
	if_double_battle Score_Plus2
	end

AI_CV_FuryCutter:
	if_type_effectiveness AI_EFFECTIVENESS_x4, AI_CV_FuryCutter2
	if_type_effectiveness AI_EFFECTIVENESS_x2, AI_CV_FuryCutter3
AI_CV_FuryCutter2:
	score +1
AI_CV_FuryCutter3:
	if_random_less_than 128, AI_Ret
	score +1
	end

AI_CV_PowerSwap:
	if_stat_level_more_than AI_TARGET, STAT_ATK, 10, AI_CV_PowerSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 10, AI_CV_PowerSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_ATK, 8, AI_CV_PowerSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 8, AI_CV_PowerSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_ATK, 6, AI_CV_PowerSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 6, AI_CV_PowerSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_ATK, 4, AI_CV_PowerSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 4, AI_CV_PowerSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_ATK, 2, AI_CV_PowerSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 2, AI_CV_PowerSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_ATK, 0, AI_CV_PowerSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 0, AI_CV_PowerSwap2
	score -1
AI_CV_PowerSwap2:
	if_stat_level_more_than AI_USER, STAT_ATK, 10, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPATK, 10, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_ATK, 8, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPATK, 8, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_ATK, 6, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPATK, 6, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_ATK, 4, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPATK, 4, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_ATK, 2, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPATK, 2, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_ATK, 0, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPATK, 0, Score_Minus1
	end

AI_CV_GuardSwap:
	if_stat_level_more_than AI_TARGET, STAT_DEF, 10, AI_CV_GuardSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 10, AI_CV_GuardSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_DEF, 8, AI_CV_GuardSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 8, AI_CV_GuardSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_DEF, 6, AI_CV_GuardSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 6, AI_CV_GuardSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_DEF, 4, AI_CV_GuardSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 4, AI_CV_GuardSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_DEF, 2, AI_CV_GuardSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 2, AI_CV_GuardSwap2
	score -1
	if_stat_level_more_than AI_TARGET, STAT_DEF, 0, AI_CV_GuardSwap2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 0, AI_CV_GuardSwap2
	score -1
AI_CV_GuardSwap2:
	if_stat_level_more_than AI_USER, STAT_DEF, 10, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPDEF, 10, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_DEF, 8, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPDEF, 8, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_DEF, 6, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPDEF, 6, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_DEF, 4, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPDEF, 4, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_DEF, 2, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPDEF, 2, Score_Minus1
	score +1
	if_stat_level_more_than AI_USER, STAT_DEF, 0, Score_Minus1
	if_stat_level_more_than AI_USER, STAT_SPDEF, 0, Score_Minus1
	end

AI_CV_HeartSwap:
	end

AI_CV_SpeedSwap:
	if_target_faster Score_Plus2
	end

AI_CV_HitEscape:
	if_target_faster AI_CV_HitEscape2
	score -1
AI_CV_HitEscape2:
	if_random_less_than 64 Score_Minus2
	if_random_less_than 128 Score_Minus1
	end

AI_CV_TrickRoom:
	if_field_status STATUS_FIELD_TRICK_ROOM, Score_Minus10
	if_target_faster Score_Plus1
	goto Score_Minus5

AI_CV_FutureSight:
	count_usable_party_mons AI_USER
	if_equal 0, Score_Minus10
	is_first_turn_for AI_USER
	if_equal 0, AI_CV_FutureSight2
	goto AI_CV_FutureSight3

AI_CV_FutureSight2:
	score -3
AI_CV_FutureSight3:
	if_doesnt_have_move_with_effect AI_TARGET, EFFECT_PROTECT, AI_CV_FutureSight4
	score +3
AI_CV_FutureSight4:
	if_random_less_than 128, Score_Minus3
	end

AI_CV_MultiHit:
	if_ability AI_USER, ABILITY_SKILL_LINK, AI_CV_MultiHit2
	goto AI_CV_MultiHit3

AI_CV_MultiHit2:
	score +2
AI_CV_MultiHit3:
	if_status2 AI_USER, STATUS2_FOCUS_ENERGY, Score_Plus1
	end

AI_CV_Rollout:
	if_status AI_USER, STATUS1_ANY, Score_Minus10
	if_status2 AI_USER, STATUS2_CONFUSION | STATUS2_INFATUATION, Score_Minus10
	if_stat_level_less_than AI_USER, STAT_ACC, 6, Score_Minus5
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 6, Score_Minus5
	if_status2 AI_TARGET, STATUS2_CONFUSION | STATUS2_INFATUATION, AI_CV_Rollout2
	if_status AI_TARGET, STATUS1_PARALYSIS, AI_CV_Rollout2
	goto AI_CV_Rollout3

AI_CV_Rollout2:
	score +1
AI_CV_Rollout3:
	if_status AI_TARGET, STATUS1_SLEEP | STATUS1_FREEZE, Score_Plus2
	end

AI_CV_PerishSong:
	get_ability AI_USER
	if_equal ABILITY_ARENA_TRAP, AI_CV_PerishSong_ArenaTrap
	if_equal ABILITY_MAGNET_PULL, AI_CV_PerishSong_MagnetPull
	if_equal ABILITY_SHADOW_TAG, AI_CV_PerishSong_ShadowTag
AI_CV_PerishSongCheckTrap:
	if_status2 AI_TARGET, STATUS2_WRAPPED | STATUS2_ESCAPE_PREVENTION, Score_Plus3
	@ If has a move that can trap, use it first, then use Perish Song
	if_double_battle AI_Ret
	if_has_move_with_effect AI_USER, EFFECT_TRAP, Score_Minus5
	if_has_move_with_effect AI_USER, EFFECT_MEAN_LOOK, Score_Minus5
	end
AI_CV_PerishSong_ArenaTrap:
	if_grounded AI_TARGET, Score_Plus2
	goto AI_CV_PerishSongCheckTrap
AI_CV_PerishSong_MagnetPull:
	if_type AI_TARGET, TYPE_STEEL, Score_Plus2
	goto AI_CV_PerishSongCheckTrap
AI_CV_PerishSong_ShadowTag:
	if_no_ability AI_TARGET, ABILITY_SHADOW_TAG, Score_Plus2
	goto AI_CV_PerishSongCheckTrap

AI_CV_Hazards:
	if_ability AI_TARGET, ABILITY_MAGIC_BOUNCE, AI_CV_StealthRockEnd
	is_first_turn_for AI_USER
	if_equal 0, AI_CV_StealthRockEnd
	score +2
AI_CV_StealthRockEnd:
	end
AI_CV_StealthRock2:
	score -2
	goto AI_CV_StealthRockEnd

AI_CV_MistyTerrain:
	call AI_CV_TerrainExpander
	end

AI_CV_GrassyTerrain:
	call AI_CV_TerrainExpander
	end

AI_CV_ElectricTerrain:
	call AI_CV_TerrainExpander
	end

AI_CV_PsychicTerrain:
	call AI_CV_TerrainExpander
	end

AI_CV_TerrainExpander:
	get_hold_effect AI_USER
	if_equal HOLD_EFFECT_TERRAIN_EXTENDER, Score_Plus2
	end

AI_CV_Powder:
	if_type AI_TARGET, TYPE_FIRE, AI_CV_Powder2
	if_has_move_with_type AI_TARGET, TYPE_FIRE, AI_CV_Powder2
	score -2
	end
AI_CV_Powder2:
	is_first_turn_for AI_TARGET
	if_equal 0, AI_CV_Powder3
	if_random_less_than 100, AI_CV_Powder3
	score +1
AI_CV_Powder3:
	if_type AI_USER, TYPE_BUG, AI_CV_Powder4
	if_type AI_USER, TYPE_GRASS, AI_CV_Powder4
	if_no_type AI_USER, TYPE_STEEL, AI_CV_Powder5
AI_CV_Powder4:
	score +1
AI_CV_Powder5:
	get_last_used_bank_move AI_USER
	if_equal_u32 MOVE_POWDER, AI_CV_Powder6
	if_random_less_than 150, Score_Minus1
	if_random_less_than 200, AI_Ret
	score +2
	end
AI_CV_Powder6:
	if_random_less_than 136, Score_Minus2
	score +1
	end

AI_CV_Hit:
	end

AI_CV_Sleep: @ 82DCA92
	if_has_move_with_effect AI_TARGET, EFFECT_DREAM_EATER, AI_CV_SleepEncourageSlpDamage
	if_has_move_with_effect AI_TARGET, EFFECT_NIGHTMARE, AI_CV_SleepEncourageSlpDamage
	goto AI_CV_Sleep_End

AI_CV_SleepEncourageSlpDamage: @ 82DCAA5
	if_random_less_than 128, AI_CV_Sleep_End
	score +1

AI_CV_Sleep_End: @ 82DCAAD
	end

AI_CV_Absorb: @ 82DCAAE
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_AbsorbEncourageMaybe
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_AbsorbEncourageMaybe
	goto AI_CV_Absorb_End

AI_CV_AbsorbEncourageMaybe: @ 82DCABF
	if_random_less_than 50, AI_CV_Absorb_End
	score -3

AI_CV_Absorb_End: @ 82DCAC7
	end

AI_CV_SelfKO: @ 82DCAC8
	if_stat_level_less_than AI_TARGET, STAT_EVASION, 7, AI_CV_SelfKO_Encourage1
	score -1
	if_stat_level_less_than AI_TARGET, STAT_EVASION, 10, AI_CV_SelfKO_Encourage1
	if_random_less_than 128, AI_CV_SelfKO_Encourage1
	score -1

AI_CV_SelfKO_Encourage1: @ 82DCAE2
	if_hp_less_than AI_USER, 80, AI_CV_SelfKO_Encourage2
	if_target_faster AI_CV_SelfKO_Encourage2
	if_random_less_than 50, AI_CV_SelfKO_End
	goto Score_Minus3

AI_CV_SelfKO_Encourage2: @ 82DCAFA
	if_hp_more_than AI_USER, 50, AI_CV_SelfKO_Encourage4
	if_random_less_than 128, AI_CV_SelfKO_Encourage3
	score +1

AI_CV_SelfKO_Encourage3: @ 82DCB09
	if_hp_more_than AI_USER, 30, AI_CV_SelfKO_End
	if_random_less_than 50, AI_CV_SelfKO_End
	score +1
	goto AI_CV_SelfKO_End

AI_CV_SelfKO_Encourage4: @ 82DCB1D
	if_random_less_than 50, AI_CV_SelfKO_End
	score -1

AI_CV_SelfKO_End: @ 82DCB25
	end

AI_CV_DreamEater: @ 82DCB26
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_DreamEater_ScoreDown1
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_DreamEater_ScoreDown1
	goto AI_CV_DreamEater_End

AI_CV_DreamEater_ScoreDown1: @ 82DCB37
	score -1

AI_CV_DreamEater_End: @ 82DCB39
	end

AI_CV_MirrorMove: @ 82DCB3A
	if_target_faster AI_CV_MirrorMove2
	get_last_used_bank_move AI_TARGET
	if_not_in_hwords AI_CV_MirrorMove_EncouragedMovesToMirror, AI_CV_MirrorMove2
	if_random_less_than 128, AI_CV_MirrorMove_End
	score +2
	goto AI_CV_MirrorMove_End

AI_CV_MirrorMove2: @ 82DCB58
	get_last_used_bank_move AI_TARGET
	if_in_hwords AI_CV_MirrorMove_EncouragedMovesToMirror, AI_CV_MirrorMove_End
	if_random_less_than 80, AI_CV_MirrorMove_End
	score -1

AI_CV_MirrorMove_End: @ 82DCB6B
	end

AI_CV_MirrorMove_EncouragedMovesToMirror: @ 82DCB6C
    .2byte MOVE_SLEEP_POWDER
    .2byte MOVE_LOVELY_KISS
    .2byte MOVE_SPORE
    .2byte MOVE_HYPNOSIS
    .2byte MOVE_SING
    .2byte MOVE_GRASS_WHISTLE
    .2byte MOVE_SHADOW_PUNCH
    .2byte MOVE_SAND_ATTACK
    .2byte MOVE_SMOKESCREEN
    .2byte MOVE_TOXIC
    .2byte MOVE_GUILLOTINE
    .2byte MOVE_HORN_DRILL
    .2byte MOVE_FISSURE
    .2byte MOVE_SHEER_COLD
    .2byte MOVE_CROSS_CHOP
    .2byte MOVE_AEROBLAST
    .2byte MOVE_CONFUSE_RAY
    .2byte MOVE_SWEET_KISS
    .2byte MOVE_SCREECH
    .2byte MOVE_COTTON_SPORE
    .2byte MOVE_SCARY_FACE
    .2byte MOVE_FAKE_TEARS
    .2byte MOVE_METAL_SOUND
    .2byte MOVE_THUNDER_WAVE
    .2byte MOVE_GLARE
    .2byte MOVE_POISON_POWDER
    .2byte MOVE_SHADOW_BALL
    .2byte MOVE_DYNAMIC_PUNCH
    .2byte MOVE_HYPER_BEAM
    .2byte MOVE_EXTREME_SPEED
    .2byte MOVE_THIEF
    .2byte MOVE_COVET
    .2byte MOVE_ATTRACT
    .2byte MOVE_SWAGGER
    .2byte MOVE_TORMENT
    .2byte MOVE_FLATTER
    .2byte MOVE_TRICK
    .2byte MOVE_SUPERPOWER
    .2byte MOVE_SKILL_SWAP
    .2byte -1

AI_CV_AttackUp:
	if_physical_moves_unusable AI_USER, AI_TARGET, Score_Minus8
	if_stat_level_less_than AI_USER, STAT_ATK, 9, AI_CV_AttackUp2
	if_random_less_than 100, AI_CV_AttackUp3
	score -1
	goto AI_CV_AttackUp3

AI_CV_AttackUp2:
	if_hp_not_equal AI_USER, 100, AI_CV_AttackUp3
	if_random_less_than 128, AI_CV_AttackUp3
	score +2

AI_CV_AttackUp3:
	if_hp_more_than AI_USER, 70, AI_Ret
	if_hp_less_than AI_USER, 40, Score_Minus2
	if_random_less_than 180, Score_Minus2
	end

AI_CV_DefenseUp:
	if_hp_less_than AI_USER, 30, Score_Minus5
	if_hp_less_than AI_USER, 70, Score_Minus3
	if_has_no_physical_move AI_TARGET, Score_Minus2
	if_stat_level_more_than AI_USER, STAT_DEF, 8, Score_Minus1
	if_random_less_than 64, Score_Plus2
	if_random_less_than 128, Score_Plus1
	end

AI_CV_SpeedUp:
	if_hp_less_than AI_USER, 30, Score_Minus5
	if_hp_less_than AI_USER, 70, Score_Minus3
	if_stat_level_more_than AI_USER, STAT_SPEED, 8, Score_Minus1
	if_user_faster AI_CV_SpeedUp3
AI_CV_SpeedUp2:
	if_random_less_than 128, Score_Plus2
AI_CV_SpeedUp3:
	if_random_less_than 128, Score_Plus1
	end

AI_CV_SpAtkUp:
	if_stat_level_less_than AI_USER, STAT_SPATK, 9, AI_CV_SpAtkUp2
	if_random_less_than 100, AI_CV_SpAtkUp3
	score -1
	goto AI_CV_SpAtkUp3

AI_CV_SpAtkUp2:
	if_hp_not_equal AI_USER, 100, AI_CV_SpAtkUp3
	if_random_less_than 128, AI_CV_SpAtkUp3
	score +2

AI_CV_SpAtkUp3:
	if_hp_more_than AI_USER, 70, AI_Ret
	if_hp_less_than AI_USER, 40, Score_Minus2
	if_random_greater_than 70, Score_Minus2
	end

AI_CV_SpDefUp:
	if_hp_less_than AI_USER, 30, Score_Minus5
	if_hp_less_than AI_USER, 70, Score_Minus3
	if_has_no_special_move AI_TARGET, Score_Minus2
	if_stat_level_more_than AI_USER, STAT_SPDEF, 8, Score_Minus1
	if_random_less_than 64, Score_Plus2
	if_random_less_than 128, Score_Plus1
	end

AI_CV_AccuracyUp:
	if_stat_level_less_than AI_USER, STAT_ACC, 9, AI_CV_AccuracyUp2
	if_random_less_than 50, AI_CV_AccuracyUp2
	score -2

AI_CV_AccuracyUp2:
	if_hp_less_than AI_USER, 70, Score_Minus2
	end

AI_CV_EvasionUp:
	if_hp_less_than AI_USER, 90, AI_CV_EvasionUp2
	if_random_less_than 100, AI_CV_EvasionUp2
	score +3

AI_CV_EvasionUp2:
	if_stat_level_less_than AI_USER, STAT_EVASION, 9, AI_CV_EvasionUp3
	if_random_less_than 128, AI_CV_EvasionUp3
	score -1

AI_CV_EvasionUp3:
	if_not_status AI_TARGET, STATUS1_TOXIC_POISON, AI_CV_EvasionUp5
	if_hp_more_than AI_USER, 50, AI_CV_EvasionUp4
	if_random_less_than 80, AI_CV_EvasionUp5

AI_CV_EvasionUp4:
	if_random_less_than 50, AI_CV_EvasionUp5
	score +3

AI_CV_EvasionUp5:
	if_not_status3 AI_TARGET, STATUS3_LEECHSEED, AI_CV_EvasionUp6
	if_random_less_than 70, AI_CV_EvasionUp6
	score +3

AI_CV_EvasionUp6:
	if_not_status3 AI_USER, STATUS3_ROOTED, AI_CV_EvasionUp7
	if_random_less_than 128, AI_CV_EvasionUp7
	score +2

AI_CV_EvasionUp7:
	if_not_status2 AI_TARGET, STATUS2_CURSED, AI_CV_EvasionUp8
	if_random_less_than 70, AI_CV_EvasionUp8
	score +3

AI_CV_EvasionUp8:
	if_hp_more_than AI_USER, 70, AI_Ret
	if_stat_level_equal AI_USER, STAT_EVASION, 6, AI_Ret
	if_hp_less_than AI_USER, 40, Score_Minus2
	if_hp_less_than AI_TARGET, 40, Score_Minus2
	if_random_greater_than 70, Score_Minus2
	end

AI_CV_AlwaysHit:
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 10, AI_CV_AlwaysHit_ScoreUp1
	if_stat_level_less_than AI_USER, STAT_ACC, 2, AI_CV_AlwaysHit_ScoreUp1
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 8, AI_CV_AlwaysHit2
	if_stat_level_less_than AI_USER, STAT_ACC, 4, AI_CV_AlwaysHit2
	end

AI_CV_AlwaysHit_ScoreUp1:
	score +1

AI_CV_AlwaysHit2:
	if_random_greater_than 100, Score_Plus1
	end

AI_CV_AttackDown:
	if_stat_level_equal AI_TARGET, STAT_ATK, 6, AI_CV_AttackDown3
	score -1
	if_hp_more_than AI_USER, 90, AI_CV_AttackDown2
	score -1

AI_CV_AttackDown2:
	if_stat_level_more_than AI_TARGET, STAT_ATK, 3, AI_CV_AttackDown3
	if_random_less_than 50, AI_CV_AttackDown3
	score -2

AI_CV_AttackDown3:
	if_hp_more_than AI_TARGET, 70, AI_CV_AttackDown4
	score -2

AI_CV_AttackDown4:
	if_has_physical_move AI_TARGET, AI_Ret
	if_random_greater_than 50, Score_Minus2
	end

AI_CV_DefenseDown:
	if_hp_less_than AI_USER, 70, AI_CV_DefenseDown2
	if_stat_level_more_than AI_TARGET, STAT_DEF, 3, AI_CV_DefenseDown3

AI_CV_DefenseDown2:
	if_random_less_than 50, AI_CV_DefenseDown3
	score -2

AI_CV_DefenseDown3:
	if_hp_less_than AI_TARGET, 70, Score_Minus2
	end

AI_CV_SpeedDownFromChance: @ 82DCE6B
	if_move MOVE_ICY_WIND, AI_CV_SpeedDown
	if_move MOVE_ROCK_TOMB, AI_CV_SpeedDown
	if_move MOVE_MUD_SHOT, AI_CV_SpeedDown
	end

AI_CV_SpeedDown: @ 82DCE81
	if_target_faster AI_CV_SpeedDown2
	score -3
	goto AI_CV_SpeedDown_End
AI_CV_SpeedDown2: @ 82DCE8E
	if_random_less_than 70, AI_CV_SpeedDown_End
	score +2
AI_CV_SpeedDown_End: @ 82DCE96
	end

AI_CV_SpAtkDown:
	if_stat_level_equal AI_TARGET, STAT_ATK, 6, AI_CV_SpAtkDown3
	score -1
	if_hp_more_than AI_USER, 90, AI_CV_SpAtkDown2
	score -1

AI_CV_SpAtkDown2:
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 3, AI_CV_SpAtkDown3
	if_random_less_than 50, AI_CV_SpAtkDown3
	score -2

AI_CV_SpAtkDown3:
	if_hp_more_than AI_TARGET, 70, AI_CV_SpAtkDown4
	score -2

AI_CV_SpAtkDown4:
	if_has_special_move AI_TARGET, AI_CV_SpAtkDown_End
	if_random_less_than 50, AI_CV_SpAtkDown_End
	score -2

AI_CV_SpAtkDown_End: @ 82DCEE1
	end

AI_CV_SpDefDown: @ 82DCEEB
	if_hp_less_than AI_USER, 70, AI_CV_SpDefDown2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 3, AI_CV_SpDefDown3

AI_CV_SpDefDown2: @ 82DCEFA
	if_random_less_than 50, AI_CV_SpDefDown3
	score -2

AI_CV_SpDefDown3: @ 82DCF02
	if_hp_more_than AI_TARGET, 70, AI_CV_SpDefDown_End
	score -2

AI_CV_SpDefDown_End: @ 82DCF0B
	end

AI_CV_AccuracyDown: @ 82DCF0C
	if_hp_less_than AI_USER, 70, AI_CV_AccuracyDown2
	if_hp_more_than AI_TARGET, 70, AI_CV_AccuracyDown3

AI_CV_AccuracyDown2:
	if_random_less_than 100, AI_CV_AccuracyDown3
	score -1

AI_CV_AccuracyDown3:
	if_stat_level_more_than AI_USER, STAT_ACC, 4, AI_CV_AccuracyDown4
	if_random_less_than 80, AI_CV_AccuracyDown4
	score -2

AI_CV_AccuracyDown4:
	if_not_status AI_TARGET, STATUS1_TOXIC_POISON, AI_CV_AccuracyDown5
	if_random_less_than 70, AI_CV_AccuracyDown5
	score +2

AI_CV_AccuracyDown5:
	if_not_status3 AI_TARGET, STATUS3_LEECHSEED, AI_CV_AccuracyDown6
	if_random_less_than 70, AI_CV_AccuracyDown6
	score +2

AI_CV_AccuracyDown6:
	if_not_status3 AI_USER, STATUS3_ROOTED, AI_CV_AccuracyDown7
	if_random_less_than 128, AI_CV_AccuracyDown7
	score +1

AI_CV_AccuracyDown7:
	if_not_status2 AI_TARGET, STATUS2_CURSED, AI_CV_AccuracyDown8
	if_random_less_than 70, AI_CV_AccuracyDown8
	score +2

AI_CV_AccuracyDown8:
	if_hp_more_than AI_USER, 70, AI_CV_AccuracyDown_End
	if_stat_level_equal AI_TARGET, STAT_ACC, 6, AI_CV_AccuracyDown_End
	if_hp_less_than AI_USER, 40, AI_CV_AccuracyDown_ScoreDown2
	if_hp_less_than AI_TARGET, 40, AI_CV_AccuracyDown_ScoreDown2
	if_random_less_than 70, AI_CV_AccuracyDown_End

AI_CV_AccuracyDown_ScoreDown2:
	score -2

AI_CV_AccuracyDown_End:
	end

AI_CV_EvasionDown:
	if_hp_less_than AI_USER, 70, AI_CV_EvasionDown2
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 3, AI_CV_EvasionDown3
AI_CV_EvasionDown2:
	if_random_less_than 50, AI_CV_EvasionDown3
	score -2
AI_CV_EvasionDown3:
	if_hp_more_than AI_TARGET, 70, AI_CV_EvasionDown_4
	score -2
AI_CV_EvasionDown_4:
	if_stat_level_less_than AI_USER, STAT_ACC, 6, AI_CV_EvasionDown_5
	if_stat_level_less_than AI_TARGET, STAT_EVASION, 7, AI_CV_EvasionDown_6
	if_ability AI_USER, ABILITY_NO_GUARD, AI_CV_EvasionDown_6
AI_CV_EvasionDown_End:
	end
AI_CV_EvasionDown_5:
	score +1
	goto AI_CV_EvasionDown_End
AI_CV_EvasionDown_6:
	score -2
	goto AI_CV_EvasionDown_End

AI_CV_Haze:
	if_stat_level_more_than AI_USER, STAT_ATK, 8, AI_CV_Haze2
	if_stat_level_more_than AI_USER, STAT_DEF, 8, AI_CV_Haze2
	if_stat_level_more_than AI_USER, STAT_SPATK, 8, AI_CV_Haze2
	if_stat_level_more_than AI_USER, STAT_SPDEF, 8, AI_CV_Haze2
	if_stat_level_more_than AI_USER, STAT_EVASION, 8, AI_CV_Haze2
	if_stat_level_less_than AI_TARGET, STAT_ATK, 4, AI_CV_Haze2
	if_stat_level_less_than AI_TARGET, STAT_DEF, 4, AI_CV_Haze2
	if_stat_level_less_than AI_TARGET, STAT_SPATK, 4, AI_CV_Haze2
	if_stat_level_less_than AI_TARGET, STAT_SPDEF, 4, AI_CV_Haze2
	if_stat_level_less_than AI_TARGET, STAT_ACC, 4, AI_CV_Haze2
	goto AI_CV_Haze3

AI_CV_Haze2:
	if_random_less_than 50, AI_CV_Haze3
	score -3

AI_CV_Haze3:
	if_stat_level_more_than AI_TARGET, STAT_ATK, 8, AI_CV_Haze4
	if_stat_level_more_than AI_TARGET, STAT_DEF, 8, AI_CV_Haze4
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 8, AI_CV_Haze4
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 8, AI_CV_Haze4
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 8, AI_CV_Haze4
	if_stat_level_less_than AI_USER, STAT_ATK, 4, AI_CV_Haze4
	if_stat_level_less_than AI_USER, STAT_DEF, 4, AI_CV_Haze4
	if_stat_level_less_than AI_USER, STAT_SPATK, 4, AI_CV_Haze4
	if_stat_level_less_than AI_USER, STAT_SPDEF, 4, AI_CV_Haze4
	if_stat_level_less_than AI_USER, STAT_ACC, 4, AI_CV_Haze4
	if_random_less_than 50, AI_CV_Haze_End
	score -1
	goto AI_CV_Haze_End

AI_CV_Haze4:
	if_random_less_than 50, AI_CV_Haze_End
	score +3

AI_CV_Haze_End:
	end

AI_CV_Bide:
	if_hp_more_than AI_USER, 90, AI_CV_Bide_End
	score -2

AI_CV_Bide_End:
	end

AI_CV_Roar:
	if_stat_level_more_than AI_TARGET, STAT_ATK, 8, AI_CV_Roar2
	if_stat_level_more_than AI_TARGET, STAT_DEF, 8, AI_CV_Roar2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 8, AI_CV_Roar2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 8, AI_CV_Roar2
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 8, AI_CV_Roar2
	score -3
	goto AI_CV_Roar_End

AI_CV_Roar2:
	if_random_less_than 128, AI_CV_Roar_End
	score +2

AI_CV_Roar_End:
	end

AI_CV_Conversion:
	if_hp_more_than AI_USER, 90, AI_CV_Conversion2
	score -2

AI_CV_Conversion2:
	get_turn_count
	if_equal 0, AI_CV_Conversion_End
	if_random_less_than 200, Score_Minus2

AI_CV_Conversion_End:
	end

AI_CV_HealWeather:
	get_weather
	if_equal AI_WEATHER_HAIL, AI_CV_HealWeather_ScoreDown2
	if_equal AI_WEATHER_RAIN, AI_CV_HealWeather_ScoreDown2
	if_equal AI_WEATHER_SANDSTORM, AI_CV_HealWeather_ScoreDown2
	goto AI_CV_Heal

AI_CV_HealWeather_ScoreDown2:
	score -2

AI_CV_Heal:
	if_hp_equal AI_USER, 100, AI_CV_Heal3
	if_target_faster AI_CV_Heal4
	score -8
	goto AI_CV_Heal_End

AI_CV_Heal2:
	if_hp_less_than AI_USER, 50, AI_CV_Heal5
	if_hp_more_than AI_USER, 80, AI_CV_Heal3
	if_random_less_than 70, AI_CV_Heal5

AI_CV_Heal3:
	score -3
	goto AI_CV_Heal_End

AI_CV_Heal4:
	if_hp_less_than AI_USER, 70, AI_CV_Heal5
	if_random_less_than 30, AI_CV_Heal5
	score -3
	goto AI_CV_Heal_End

AI_CV_Heal5:
	if_doesnt_have_move_with_effect AI_TARGET, EFFECT_SNATCH, AI_CV_Heal6
	if_random_less_than 100, AI_CV_Heal_End

AI_CV_Heal6:
	if_random_less_than 20, AI_CV_Heal_End
	score +2

AI_CV_Heal_End:
	end

EncouragePsnVenoshock:
	if_doesnt_have_move_with_effect AI_USER, EFFECT_VENOSHOCK, EncouragePsnVenoshockEnd
	score +1
	if_random_less_than 128, EncouragePsnVenoshockEnd
	score +1
EncouragePsnVenoshockEnd:
	end

AI_CV_Toxic:
	call EncouragePsnVenoshock
AI_CV_LeechSeed:
	if_user_has_no_attacking_moves AI_CV_Toxic3
	if_hp_more_than AI_USER, 50, AI_CV_Toxic2
	if_random_less_than 50, AI_CV_Toxic2
	score -3
AI_CV_Toxic2:
	if_hp_more_than AI_TARGET, 50, AI_CV_Toxic3
	if_random_less_than 50, AI_CV_Toxic3
	score -3
AI_CV_Toxic3:
	if_has_move_with_effect AI_USER, EFFECT_SPECIAL_DEFENSE_UP, AI_CV_Toxic4
	if_has_move_with_effect AI_USER, EFFECT_PROTECT, AI_CV_Toxic4
	goto AI_CV_Toxic_End
AI_CV_Toxic4:
	if_random_less_than 60, AI_CV_Toxic_End
	score +2
AI_CV_Toxic_End:
	end

AI_CV_LightScreen:
	call EncourageLightClay
	if_hp_less_than AI_USER, 50, AI_CV_LightScreen_ScoreDown2
	if_has_special_move AI_TARGET, AI_CV_LightScreen_End
	if_random_less_than 50, AI_CV_LightScreen_End
AI_CV_LightScreen_ScoreDown2:
	score -2
AI_CV_LightScreen_End:
	end

AI_CV_Rest:
	if_target_faster AI_CV_Rest4
	if_hp_not_equal AI_USER, 100, AI_CV_Rest2
	score -8
	goto AI_CV_Rest_End

AI_CV_Rest2:
	if_hp_less_than AI_USER, 40, AI_CV_Rest6
	if_hp_more_than AI_USER, 50, AI_CV_Rest3
	if_random_less_than 70, AI_CV_Rest6

AI_CV_Rest3:
	score -3
	goto AI_CV_Rest_End

AI_CV_Rest4:
	if_hp_less_than AI_USER, 60, AI_CV_Rest6
	if_hp_more_than AI_USER, 70, AI_CV_Rest5
	if_random_less_than 50, AI_CV_Rest6

AI_CV_Rest5:
	score -3
	goto AI_CV_Rest_End

AI_CV_Rest6:
	if_doesnt_have_move_with_effect AI_TARGET, EFFECT_SNATCH, AI_CV_Rest7
	if_random_less_than 50, AI_CV_Rest_End

AI_CV_Rest7:
	if_random_less_than 10, AI_CV_Rest_End
	score +3

AI_CV_Rest_End:
	end

AI_CV_OneHitKO:
	end

AI_CV_SuperFang:
	if_hp_more_than AI_TARGET, 50, AI_CV_SuperFang_End
	score -1

AI_CV_SuperFang_End:
	end

AI_CV_Trap:
	if_status2 AI_TARGET, STATUS2_WRAPPED | STATUS2_ESCAPE_PREVENTION, AI_CV_TrapEnd
	if_status3 AI_TARGET, STATUS3_PERISH_SONG, AI_CV_Trap5
	if_doesnt_have_move_with_effect AI_USER, EFFECT_PERISH_SONG, AI_CV_Trap1
	score +3
AI_CV_Trap1:
	if_status AI_TARGET, STATUS1_TOXIC_POISON, AI_CV_Trap2
	if_status2 AI_TARGET, STATUS2_CURSED | STATUS2_INFATUATION, AI_CV_Trap2
	goto AI_CV_TrapItem
AI_CV_Trap5:
	score +5
	goto AI_CV_TrapItem
AI_CV_Trap2:
	score +2
	if_random_less_than 128, AI_CV_TrapItem
	score +2
AI_CV_TrapItem:
	get_considered_move_power
	if_equal 0, AI_CV_TrapEnd
	if_status2 AI_TARGET, STATUS2_WRAPPED, AI_CV_TrapEnd
	get_hold_effect AI_USER
	if_equal HOLD_EFFECT_GRIP_CLAW AI_CV_Trap4
	if_equal HOLD_EFFECT_BINDING_BAND AI_CV_Trap4
	goto AI_CV_TrapEnd
AI_CV_Trap4:
	score +2
AI_CV_TrapEnd:
	end

AI_CV_HighCrit:
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_HighCrit_End
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_HighCrit_End
	if_type_effectiveness AI_EFFECTIVENESS_x2, AI_CV_HighCrit2
	if_type_effectiveness AI_EFFECTIVENESS_x4, AI_CV_HighCrit2
	if_random_less_than 128, AI_CV_HighCrit_End

AI_CV_HighCrit2:
	if_random_less_than 128, AI_CV_HighCrit_End
	score +1

AI_CV_HighCrit_End:
	end

AI_CV_FocusEnergy:
	if_has_move_with_flag AI_USER, FLAG_HIGH_CRIT, AI_CV_FocusEnergy2
	if_has_move_with_effect AI_USER, EFFECT_MULTI_HIT, AI_CV_FocusEnergy2
AI_CV_FocusEnergy3:
	get_hold_effect AI_USER
	if_not_equal HOLD_EFFECT_SCOPE_LENS, AI_CV_FocusEnergyEnd
	score +1
AI_CV_FocusEnergyEnd:
	end
AI_CV_FocusEnergy2:
	score +1
	goto AI_CV_FocusEnergy3

AI_CV_Swagger:
	if_has_move AI_USER, MOVE_PSYCH_UP, AI_CV_SwaggerHasPsychUp

AI_CV_Flatter:
	if_random_less_than 128, AI_CV_Confuse
	score +1

AI_CV_Confuse:
	if_hp_more_than AI_TARGET, 70, AI_CV_Confuse_End
	if_random_less_than 128, AI_CV_Confuse2
	score -1

AI_CV_Confuse2:
	if_hp_more_than AI_TARGET, 50, AI_CV_Confuse_End
	score -1
	if_hp_more_than AI_TARGET, 30, AI_CV_Confuse_End
	score -1

AI_CV_Confuse_End:
	end

AI_CV_SwaggerHasPsychUp:
	if_stat_level_more_than AI_TARGET, STAT_ATK, 3, AI_CV_SwaggerHasPsychUp_Minus5
	score +3
	get_turn_count
	if_not_equal 0, AI_CV_SwaggerHasPsychUp_End
	score +2
	goto AI_CV_SwaggerHasPsychUp_End

AI_CV_SwaggerHasPsychUp_Minus5:
	score -5

AI_CV_SwaggerHasPsychUp_End:
	end

EncourageLightClay:
	get_hold_effect AI_USER
	if_not_equal HOLD_EFFECT_LIGHT_CLAY, EncourageLightClayEnd
	score +1
	if_random_less_than 111, EncourageLightClayEnd
	score +1
EncourageLightClayEnd:
	end

AI_CV_AuroraVeil:
	call EncourageLightClay
	end

AI_CV_Reflect:
	call EncourageLightClay
	if_hp_less_than AI_USER, 50, AI_CV_Reflect_ScoreDown2
	if_has_physical_move AI_TARGET, AI_CV_Reflect_End
	if_random_less_than 50, AI_CV_Reflect_End
AI_CV_Reflect_ScoreDown2:
	score -2
AI_CV_Reflect_End:
	end

AI_CV_ToxicThread:
	if_status AI_TARGET, STATUS1_ANY, AI_CV_ToxicThreadSpd
	call EncouragePsnVenoshock
AI_CV_ToxicThreadSpd:
	if_target_faster AI_CV_ToxicThread2
	if_not_status AI_TARGET, STATUS1_ANY, AI_CV_ToxicThread3
	score -1
	goto AI_CV_ToxicThread3
AI_CV_ToxicThread2:
	score +1
AI_CV_ToxicThread3:
	goto AI_CV_Poison2

AI_CV_Poison:
	call EncouragePsnVenoshock
AI_CV_Poison2:
	if_hp_less_than AI_USER, 50, AI_CV_Poison_ScoreDown1
	if_hp_more_than AI_TARGET, 50, AI_CV_Poison_End
AI_CV_Poison_ScoreDown1:
	score -1
AI_CV_Poison_End:
	end

AI_CV_Paralyze:
	if_target_faster AI_CV_Paralyze2
	if_hp_more_than AI_USER, 70, AI_CV_Paralyze_End
	score -1
	goto AI_CV_Paralyze_End

AI_CV_Paralyze2:
	if_random_less_than 20, AI_CV_Paralyze_End
	score +3

AI_CV_Paralyze_End:
	end

AI_CV_VitalThrow:
	if_target_faster AI_CV_VitalThrow_End
	if_hp_more_than AI_USER, 60, AI_CV_VitalThrow_End
	if_hp_less_than AI_USER, 40, AI_CV_VitalThrow2
	if_random_less_than 180, AI_CV_VitalThrow_End

AI_CV_VitalThrow2:
	if_random_less_than 50, AI_CV_VitalThrow_End
	score -1

AI_CV_VitalThrow_End:
	end

AI_CV_Substitute:
	if_not_status2 AI_TARGET, STATUS2_WRAPPED | STATUS2_ESCAPE_PREVENTION, AI_CV_Substitute1
	if_status3 AI_TARGET, STATUS3_PERISH_SONG, AI_CV_SubstitutePlus3Continue
	if_status AI_TARGET, STATUS1_BURN | STATUS1_PSN_ANY, AI_CV_SubstitutePlus1Continue
	goto AI_CV_Substitute1
AI_CV_SubstitutePlus1Continue:
	score +1
	goto AI_CV_Substitute1
AI_CV_SubstitutePlus3Continue:
	score +3
AI_CV_Substitute1:
	if_hp_more_than AI_USER, 90, AI_CV_Substitute4
	if_hp_more_than AI_USER, 70, AI_CV_Substitute3
	if_hp_more_than AI_USER, 50, AI_CV_Substitute2
	if_random_less_than 100, AI_CV_Substitute2
	score -1
AI_CV_Substitute2:
	if_random_less_than 100, AI_CV_Substitute3
	score -1
AI_CV_Substitute3:
	if_random_less_than 100, AI_CV_Substitute4
	score -1
AI_CV_Substitute4:
	if_target_faster AI_CV_Substitute_End
	get_last_used_bank_move AI_TARGET
	get_move_effect_from_result
	if_equal EFFECT_SLEEP, AI_CV_Substitute5
	if_equal EFFECT_TOXIC, AI_CV_Substitute5
	if_equal EFFECT_POISON, AI_CV_Substitute5
	if_equal EFFECT_PARALYZE, AI_CV_Substitute5
	if_equal EFFECT_WILL_O_WISP, AI_CV_Substitute5
	if_equal EFFECT_CONFUSE, AI_CV_Substitute6
	if_equal EFFECT_LEECH_SEED, AI_CV_Substitute7
	goto AI_CV_Substitute_End
AI_CV_Substitute5:
	if_not_status AI_TARGET, STATUS1_ANY, AI_CV_Substitute8
	goto AI_CV_Substitute_End
AI_CV_Substitute6:
	if_not_status2 AI_TARGET, STATUS2_CONFUSION, AI_CV_Substitute8
	goto AI_CV_Substitute_End
AI_CV_Substitute7:
	if_status3 AI_TARGET, STATUS3_LEECHSEED, AI_CV_Substitute_End
AI_CV_Substitute8:
	if_random_less_than 100, AI_CV_Substitute_End
	score +1
AI_CV_Substitute_End:
	end

AI_CV_Recharge:
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_Recharge_ScoreDown1
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_Recharge_ScoreDown1
	if_target_faster AI_CV_Recharge2
	if_hp_more_than AI_USER, 40, AI_CV_Recharge_ScoreDown1
	goto AI_CV_Recharge_End

AI_CV_Recharge2:
	if_hp_less_than AI_USER, 60, AI_CV_Recharge_End

AI_CV_Recharge_ScoreDown1:
	score -1

AI_CV_Recharge_End:
	end

AI_CV_Disable:
	if_target_faster AI_CV_Disable_End
	get_last_used_bank_move AI_TARGET
	get_move_power_from_result
	if_equal 0, AI_CV_Disable2
	score +1
	goto AI_CV_Disable_End

AI_CV_Disable2:
	if_random_less_than 100, AI_CV_Disable_End
	score -1

AI_CV_Disable_End:
	end

AI_CV_Counter:
	if_status AI_TARGET, STATUS1_SLEEP, AI_CV_Counter_ScoreDown1
	if_status2 AI_TARGET, STATUS2_INFATUATION, AI_CV_Counter_ScoreDown1
	if_status2 AI_TARGET, STATUS2_CONFUSION, AI_CV_Counter_ScoreDown1
	if_hp_more_than AI_USER, 30, AI_CV_Counter2
	if_random_less_than 10, AI_CV_Counter2
	score -1

AI_CV_Counter2:
	if_hp_more_than AI_USER, 50, AI_CV_Counter3
	if_random_less_than 100, AI_CV_Counter3
	score -1

AI_CV_Counter3:
	if_has_move AI_USER, MOVE_MIRROR_COAT, AI_CV_Counter7
	get_last_used_bank_move AI_TARGET
	get_move_power_from_result
	if_equal 0, AI_CV_Counter5
	if_target_not_taunted AI_CV_Counter4
	if_random_less_than 100, AI_CV_Counter4
	score +1

AI_CV_Counter4:
	get_last_used_bank_move AI_TARGET
	get_move_split_from_result
	if_not_equal SPLIT_PHYSICAL, AI_CV_Counter_ScoreDown1
	if_random_less_than 100, AI_CV_Counter_End
	score +1
	goto AI_CV_Counter_End

AI_CV_Counter5:
	if_target_not_taunted AI_CV_Counter6
	if_random_less_than 100, AI_CV_Counter6
	score +1

AI_CV_Counter6:
	if_has_physical_move AI_TARGET, AI_CV_Counter_End
	if_random_less_than 50, AI_CV_Counter_End

AI_CV_Counter7:
	if_random_less_than 100, AI_CV_Counter8
	score +4

AI_CV_Counter8:
	end

AI_CV_Counter_ScoreDown1:
	score -1

AI_CV_Counter_End:
	end

AI_CV_Encore:
	if_any_move_disabled AI_TARGET, AI_CV_Encore2
	if_target_faster AI_CV_Encore_ScoreDown2
	get_last_used_bank_move AI_TARGET
	get_move_effect_from_result
	if_not_in_bytes AI_CV_Encore_EncouragedMovesToEncore, AI_CV_Encore_ScoreDown2

AI_CV_Encore2:
	if_random_less_than 30, AI_CV_Encore_End
	score +3
	goto AI_CV_Encore_End

AI_CV_Encore_ScoreDown2:
	score -2

AI_CV_Encore_End:
	end

AI_CV_Encore_EncouragedMovesToEncore:
    .byte EFFECT_DREAM_EATER
    .byte EFFECT_ATTACK_UP
    .byte EFFECT_DEFENSE_UP
    .byte EFFECT_SPEED_UP
    .byte EFFECT_SPECIAL_ATTACK_UP
    .byte EFFECT_HAZE
    .byte EFFECT_ROAR
    .byte EFFECT_CONVERSION
    .byte EFFECT_TOXIC
    .byte EFFECT_LIGHT_SCREEN
    .byte EFFECT_REST
    .byte EFFECT_SUPER_FANG
    .byte EFFECT_SPECIAL_DEFENSE_UP_2
    .byte EFFECT_CONFUSE
    .byte EFFECT_POISON
    .byte EFFECT_PARALYZE
    .byte EFFECT_LEECH_SEED
    .byte EFFECT_DO_NOTHING
    .byte EFFECT_ATTACK_UP_2
    .byte EFFECT_ENCORE
    .byte EFFECT_CONVERSION_2
    .byte EFFECT_LOCK_ON
    .byte EFFECT_HEAL_BELL
    .byte EFFECT_MEAN_LOOK
    .byte EFFECT_NIGHTMARE
    .byte EFFECT_PROTECT
    .byte EFFECT_SKILL_SWAP
    .byte EFFECT_FORESIGHT
    .byte EFFECT_PERISH_SONG
    .byte EFFECT_SANDSTORM
    .byte EFFECT_ENDURE
    .byte EFFECT_SWAGGER
    .byte EFFECT_ATTRACT
    .byte EFFECT_SAFEGUARD
    .byte EFFECT_RAIN_DANCE
    .byte EFFECT_SUNNY_DAY
    .byte EFFECT_BELLY_DRUM
    .byte EFFECT_PSYCH_UP
    .byte EFFECT_FUTURE_SIGHT
    .byte EFFECT_FAKE_OUT
    .byte EFFECT_STOCKPILE
    .byte EFFECT_SPIT_UP
    .byte EFFECT_SWALLOW
    .byte EFFECT_HAIL
    .byte EFFECT_TORMENT
    .byte EFFECT_WILL_O_WISP
    .byte EFFECT_FOLLOW_ME
    .byte EFFECT_CHARGE
    .byte EFFECT_TRICK
    .byte EFFECT_ROLE_PLAY
    .byte EFFECT_INGRAIN
    .byte EFFECT_RECYCLE
    .byte EFFECT_KNOCK_OFF
    .byte EFFECT_SKILL_SWAP
    .byte EFFECT_IMPRISON
    .byte EFFECT_REFRESH
    .byte EFFECT_GRUDGE
    .byte EFFECT_TEETER_DANCE
    .byte EFFECT_MUD_SPORT
    .byte EFFECT_WATER_SPORT
    .byte EFFECT_DRAGON_DANCE
    .byte EFFECT_CAMOUFLAGE
    .byte -1

AI_CV_PainSplit:
	if_hp_less_than AI_TARGET, 80, AI_CV_PainSplit_ScoreDown1
	if_target_faster AI_CV_PainSplit2
	if_hp_more_than AI_USER, 40, AI_CV_PainSplit_ScoreDown1
	score +1
	goto AI_CV_PainSplit_End

AI_CV_PainSplit2:
	if_hp_more_than AI_USER, 60, AI_CV_PainSplit_ScoreDown1
	score +1
	goto AI_CV_PainSplit_End

AI_CV_PainSplit_ScoreDown1:
	score -1

AI_CV_PainSplit_End:
	end

AI_CV_Snore:
	score +2
	end

AI_CV_LockOn:
	if_status3 AI_USER, STATUS3_ALWAYS_HITS, Score_Minus10
	get_last_used_bank_move AI_USER
	get_move_effect_from_result
	if_equal EFFECT_LOCK_ON, Score_Minus10
	if_random_less_than 128, AI_CV_LockOn_End
	score +2

AI_CV_LockOn_End:
	end

AI_CV_SleepTalk:
	if_status AI_USER, STATUS1_SLEEP, Score_Plus10
	score -5
	end

AI_CV_DestinyBond:
	score -1
	if_target_faster AI_CV_DestinyBond_End
	if_hp_more_than AI_USER, 70, AI_CV_DestinyBond_End
	if_random_less_than 128, AI_CV_DestinyBond2
	score +1

AI_CV_DestinyBond2:
	if_hp_more_than AI_USER, 50, AI_CV_DestinyBond_End
	if_random_less_than 128, AI_CV_DestinyBond3
	score +1

AI_CV_DestinyBond3:
	if_hp_more_than AI_USER, 30, AI_CV_DestinyBond_End
	if_random_less_than 100, AI_CV_DestinyBond_End
	score +2

AI_CV_DestinyBond_End:
	end

AI_CV_Flail:
	if_target_faster AI_CV_Flail2
	if_hp_more_than AI_USER, 33, AI_CV_Flail_ScoreDown1
	if_hp_more_than AI_USER, 20, AI_CV_Flail_End
	if_hp_less_than AI_USER, 8, AI_CV_Flail_ScoreUp1
	goto AI_CV_Flail3

AI_CV_Flail2:
	if_hp_more_than AI_USER, 60, AI_CV_Flail_ScoreDown1
	if_hp_more_than AI_USER, 40, AI_CV_Flail_End
	goto AI_CV_Flail3

AI_CV_Flail_ScoreUp1:
	score +1

AI_CV_Flail3:
	if_random_less_than 100, AI_CV_Flail_End
	score +1
	goto AI_CV_Flail_End

AI_CV_Flail_ScoreDown1:
	score -1

AI_CV_Flail_End:
	end

AI_CV_HealBell:
	if_move MOVE_HEAL_BELL AI_CV_HealBell2
AI_CV_HealBellEnd:
	end
@ Don't use Heal Bell to heal a partner that has Soundproof
AI_CV_HealBell2:
	if_status AI_USER, STATUS1_ANY, AI_CV_HealBellEnd
	if_not_status AI_USER_PARTNER, STATUS1_ANY, AI_CV_HealBellEnd
	if_ability AI_USER_PARTNER, ABILITY_SOUNDPROOF, Score_Minus3
	goto AI_CV_HealBellEnd

AI_CV_Thief:
	get_hold_effect AI_TARGET
	if_not_in_bytes AI_CV_Thief_EncourageItemsToSteal, AI_CV_Thief_ScoreDown2
	if_random_less_than 50, AI_CV_Thief_End
	score +1
	goto AI_CV_Thief_End

AI_CV_Thief_ScoreDown2:
	score -2

AI_CV_Thief_End:
	end

AI_CV_Thief_EncourageItemsToSteal:
    .byte HOLD_EFFECT_CURE_SLP
    .byte HOLD_EFFECT_CURE_STATUS
    .byte HOLD_EFFECT_RESTORE_HP
    .byte HOLD_EFFECT_EVASION_UP
    .byte HOLD_EFFECT_LEFTOVERS
    .byte HOLD_EFFECT_LIGHT_BALL
    .byte HOLD_EFFECT_THICK_CLUB
    .byte -1

AI_CV_Curse:
	if_type AI_USER, TYPE_GHOST, AI_CV_CurseGhost
	if_stat_level_more_than AI_USER, STAT_DEF, 9, AI_CV_Curse2
	if_random_less_than 128, AI_CV_Curse2
	score +1
AI_CV_Curse2:
	if_stat_level_more_than AI_USER, STAT_ATK, 9, AI_CV_Curse3
	if_random_less_than 128, AI_CV_Curse3
	score +1
AI_CV_Curse3:
	if_stat_level_more_than AI_USER, STAT_DEF, 6, AI_CV_Curse4
	if_random_less_than 98, AI_CV_Curse4
	score +1
AI_CV_Curse4:
	if_stat_level_more_than AI_USER, STAT_ATK, 6, AI_CV_Curse5
	if_random_less_than 99, AI_CV_Curse5
	score +1
AI_CV_Curse5:
	get_hold_effect AI_USER
	if_not_equal HOLD_EFFECT_RESTORE_STATS, AI_CV_Curse_End
	score +2
	goto AI_CV_Curse_End
AI_CV_CurseGhost:
	if_hp_more_than AI_USER, 80, AI_CV_Curse_End
	score -1
AI_CV_Curse_End:
	end

AI_CV_Protect:
	get_protect_count AI_USER
	if_more_than 1, AI_CV_Protect_ScoreDown5
	if_status  AI_USER, STATUS1_PSN_ANY | STATUS1_BURN, AI_CV_ProtectUserStatused
	if_status2 AI_USER, STATUS2_CURSED | STATUS2_INFATUATION, AI_CV_ProtectUserStatused
	if_status3 AI_USER, STATUS3_PERISH_SONG | STATUS3_LEECHSEED | STATUS3_YAWN, AI_CV_ProtectUserStatused
	if_has_move_with_effect AI_TARGET, EFFECT_RESTORE_HP, AI_CV_Protect3
	if_has_move_with_effect AI_TARGET, EFFECT_DEFENSE_CURL, AI_CV_Protect3
	if_status  AI_TARGET, STATUS1_TOXIC_POISON, AI_CV_Protect_ScoreUp2
	if_status2 AI_TARGET, STATUS2_CURSED | STATUS2_INFATUATION, AI_CV_Protect_ScoreUp2
	if_status3 AI_TARGET, STATUS3_PERISH_SONG | STATUS3_LEECHSEED | STATUS3_YAWN, AI_CV_Protect_ScoreUp2
	get_last_used_bank_move AI_TARGET
	get_move_effect_from_result
	if_not_equal EFFECT_LOCK_ON, AI_CV_Protect_ScoreUp2
	goto AI_CV_Protect2
AI_CV_Protect_ScoreUp2:
	score +2
AI_CV_Protect2:
	if_random_less_than 128, AI_CV_Protect4
	score -1
AI_CV_Protect4:
	get_protect_count AI_USER
	if_equal 0, AI_CV_Protect_End
	score -1
	if_random_less_than 128, AI_CV_Protect_End
	score -1
	goto AI_CV_Protect_End
AI_CV_ProtectUserStatused:
	score -1
	if_double_battle AI_CV_Protect4
	score -1
	goto AI_CV_Protect4
AI_CV_Protect3:
	get_last_used_bank_move AI_TARGET
	get_move_effect_from_result
	if_not_equal EFFECT_LOCK_ON, AI_CV_Protect_End
AI_CV_Protect_ScoreDown5:
	score -5
AI_CV_Protect_End:
	end

AI_CV_Foresight:
	if_has_move_with_type AI_USER, TYPE_NORMAL, AI_CV_ForesightGhost
	if_has_move_with_type AI_USER, TYPE_FIGHTING, AI_CV_ForesightGhost
	goto AI_CV_ForesightEvs
AI_CV_ForesightGhost:
	if_type AI_USER, TYPE_GHOST, AI_CV_Foresight2
AI_CV_ForesightEvs:
	if_stat_level_more_than AI_USER, STAT_EVASION, 8, AI_CV_Foresight3
	score -3
	goto AI_CV_Foresight_End
AI_CV_Foresight2:
	if_random_less_than 80, AI_CV_Foresight_End
AI_CV_Foresight3:
	if_random_less_than 80, AI_CV_Foresight_End
	score +2
AI_CV_Foresight_End:
	end

AI_CV_Endure:
	get_protect_count AI_USER
	if_more_than 1, AI_CV_Endure2
	if_hp_less_than AI_USER, 8, AI_CV_Endure2
	if_hp_less_than AI_USER, 14, AI_CV_Endure4
	if_hp_less_than AI_USER, 35, AI_CV_Endure3
	if_doesnt_have_move_with_effect AI_USER, EFFECT_FLAIL, AI_CV_Endure2
	score +1
	goto AI_CV_Endure_End
AI_CV_Endure2:
	score -3
	goto AI_CV_Endure_End
AI_CV_Endure4:
	score -1
	goto AI_CV_Endure_End
AI_CV_Endure3:
	if_has_move_with_effect AI_USER, EFFECT_FLAIL, Score_Plus2
	if_random_less_than 70, AI_CV_Endure_End
	score +1
AI_CV_Endure_End:
	end

AI_CV_BatonPass:
	if_stat_level_more_than AI_USER, STAT_ATK, 8, AI_CV_BatonPass2
	if_stat_level_more_than AI_USER, STAT_DEF, 8, AI_CV_BatonPass2
	if_stat_level_more_than AI_USER, STAT_SPATK, 8, AI_CV_BatonPass2
	if_stat_level_more_than AI_USER, STAT_SPDEF, 8, AI_CV_BatonPass2
	if_stat_level_more_than AI_USER, STAT_EVASION, 8, AI_CV_BatonPass2
	goto AI_CV_BatonPass5
AI_CV_BatonPass2:
	if_target_faster AI_CV_BatonPass3
	if_hp_more_than AI_USER, 60, AI_CV_BatonPass_Last
	goto AI_CV_BatonPass4
AI_CV_BatonPass3:
	if_hp_more_than AI_USER, 70, AI_CV_BatonPass_Last
AI_CV_BatonPass4:
	if_random_less_than 80, AI_CV_BatonPass_Last
	score +2
	goto AI_CV_BatonPass_Last
AI_CV_BatonPass5:
	if_stat_level_more_than AI_USER, STAT_ATK, 7, AI_CV_BatonPass7
	if_stat_level_more_than AI_USER, STAT_DEF, 7, AI_CV_BatonPass7
	if_stat_level_more_than AI_USER, STAT_SPATK, 7, AI_CV_BatonPass7
	if_stat_level_more_than AI_USER, STAT_SPDEF, 7, AI_CV_BatonPass7
	if_stat_level_more_than AI_USER, STAT_EVASION, 7, AI_CV_BatonPass7
	goto AI_CV_BatonPass_ScoreDown2
AI_CV_BatonPass7:
	if_target_faster AI_CV_BatonPass8
	if_ai_can_go_down AI_CV_BatonPass4
	if_hp_more_than AI_USER, 60, AI_CV_BatonPass_ScoreDown2
	goto AI_CV_BatonPass_Last
AI_CV_BatonPass8:
	if_ai_can_go_down AI_CV_BatonPass_ScoreDown2
	if_hp_less_than AI_USER, 70, AI_CV_BatonPass_Last
	goto AI_CV_BatonPass_ScoreDown2
AI_CV_BatonPass9:
	if_stat_level_more_than AI_USER, STAT_ATK, 6, AI_CV_BatonPass10
	if_stat_level_more_than AI_USER, STAT_DEF, 6, AI_CV_BatonPass10
	if_stat_level_more_than AI_USER, STAT_SPATK, 6, AI_CV_BatonPass10
	if_stat_level_more_than AI_USER, STAT_SPDEF, 6, AI_CV_BatonPass10
	if_stat_level_more_than AI_USER, STAT_EVASION, 6, AI_CV_BatonPass10
	goto AI_CV_BatonPass_ScoreDown2
AI_CV_BatonPass10:
	if_target_faster AI_CV_BatonPass11
	if_ai_can_go_down AI_CV_BatonPass4
	if_hp_more_than AI_USER, 60, AI_CV_BatonPass_ScoreDown2
	goto AI_CV_BatonPass_Last
AI_CV_BatonPass11:
	if_ai_can_go_down AI_CV_BatonPass_ScoreDown2
	if_hp_less_than AI_USER, 70, AI_CV_BatonPass_Last
	goto AI_CV_BatonPass_ScoreDown2
AI_CV_BatonPass_ScoreDown2:
	score -2
	end
AI_CV_BatonPass_Last:
	get_best_dmg_hp_percent
	if_less_than 10, Score_Plus2
	if_less_than 20, Score_Plus1
AI_CV_BatonPass_End:
	end

AI_CV_Pursuit:
	is_first_turn_for AI_USER
	if_not_equal 0, AI_Ret
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_Ret
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_Ret
	if_hp_more_than AI_TARGET, 40, AI_CV_Pursuit2
	score +2 @ If the target is low, it is likely to switch out, so encourage Purusit use
AI_CV_Pursuit2:
	if_type_effectiveness AI_EFFECTIVENESS_x2, AI_CV_Pursuit3
	if_type_effectiveness AI_EFFECTIVENESS_x4, AI_CV_Pursuit3
	end

AI_CV_Pursuit3:
	if_random_less_than 128, AI_Ret
	goto Score_Plus1

AI_CV_RainDance:
	if_user_faster AI_CV_RainDance2
	get_ability AI_USER
	if_equal ABILITY_SWIFT_SWIM, AI_CV_RainDance3
	get_ability AI_USER_PARTNER
	if_equal ABILITY_SWIFT_SWIM, AI_CV_RainDance3
AI_CV_RainDance2:
	if_hp_less_than AI_USER, 40, AI_CV_RainDance_ScoreDown1
	get_weather
	if_equal AI_WEATHER_HAIL, AI_CV_RainDance3
	if_equal AI_WEATHER_SUN, AI_CV_RainDance3
	if_equal AI_WEATHER_SANDSTORM, AI_CV_RainDance3
	if_ability AI_USER, ABILITY_RAIN_DISH, AI_CV_RainDance3
	if_ability AI_USER_PARTNER, ABILITY_RAIN_DISH, AI_CV_RainDance3
	if_ability AI_USER, ABILITY_HYDRATION, AI_CV_Hydration
	if_no_ability AI_USER_PARTNER, ABILITY_HYDRATION, AI_CV_RainDance_Rock
AI_CV_Hydration:
	if_status AI_USER, STATUS1_ANY, AI_CV_RainDance3
	if_status AI_USER_PARTNER, STATUS1_ANY, AI_CV_RainDance3
	goto AI_CV_RainDance_Rock
AI_CV_RainDance3:
	score +1
	goto AI_CV_RainDance_Rock
AI_CV_RainDance_ScoreDown1:
	score -1
AI_CV_RainDance_Rock:
	get_hold_effect AI_USER
	if_not_equal HOLD_EFFECT_DAMP_ROCK, AI_CV_RainDance_End
	score +2
AI_CV_RainDance_End:
	end

AI_CV_SunnyDay:
	if_hp_less_than AI_USER, 40, AI_CV_SunnyDay_ScoreDown1
	get_weather
	if_equal AI_WEATHER_HAIL, AI_CV_SunnyDay2
	if_equal AI_WEATHER_RAIN, AI_CV_SunnyDay2
	if_equal AI_WEATHER_SANDSTORM, AI_CV_SunnyDay2
	goto AI_CV_SunnyDay_End
AI_CV_SunnyDay2:
	score +1
	goto AI_CV_SunnyDay_End
AI_CV_SunnyDay_ScoreDown1:
	score -1
AI_CV_SunnyDay_End:
	get_hold_effect AI_USER
	if_not_equal HOLD_EFFECT_HEAT_ROCK, AI_Ret
	score +2
	end

AI_CV_BellyDrum:
	if_hp_less_than AI_USER, 90, AI_CV_BellyDrum_ScoreDown2
	goto AI_CV_BellyDrum_End

AI_CV_BellyDrum_ScoreDown2:
	score -2

AI_CV_BellyDrum_End:
	end

AI_CV_PsychUp:
	if_stat_level_more_than AI_TARGET, STAT_ATK, 8, AI_CV_PsychUp2
	if_stat_level_more_than AI_TARGET, STAT_DEF, 8, AI_CV_PsychUp2
	if_stat_level_more_than AI_TARGET, STAT_SPATK, 8, AI_CV_PsychUp2
	if_stat_level_more_than AI_TARGET, STAT_SPDEF, 8, AI_CV_PsychUp2
	if_stat_level_more_than AI_TARGET, STAT_EVASION, 8, AI_CV_PsychUp2
	goto AI_CV_PsychUp_ScoreDown2

AI_CV_PsychUp2:
	if_stat_level_less_than AI_USER, STAT_ATK, 7, AI_CV_PsychUp3
	if_stat_level_less_than AI_USER, STAT_DEF, 7, AI_CV_PsychUp3
	if_stat_level_less_than AI_USER, STAT_SPATK, 7, AI_CV_PsychUp3
	if_stat_level_less_than AI_USER, STAT_SPDEF, 7, AI_CV_PsychUp3
	if_stat_level_less_than AI_USER, STAT_EVASION, 7, AI_CV_PsychUp_ScoreUp1
	if_random_less_than 50, AI_CV_PsychUp_End
	goto AI_CV_PsychUp_ScoreDown2

AI_CV_PsychUp_ScoreUp1:
	score +1

AI_CV_PsychUp3:
	score +1
	end

AI_CV_PsychUp_ScoreDown2:
	score -2

AI_CV_PsychUp_End:
	end

AI_CV_MirrorCoat:
	if_status AI_TARGET, STATUS1_SLEEP, AI_CV_MirrorCoat_ScoreDown1
	if_status2 AI_TARGET, STATUS2_INFATUATION, AI_CV_MirrorCoat_ScoreDown1
	if_status2 AI_TARGET, STATUS2_CONFUSION, AI_CV_MirrorCoat_ScoreDown1
	if_hp_more_than AI_USER, 30, AI_CV_MirrorCoat2
	if_random_less_than 10, AI_CV_MirrorCoat2
	score -1

AI_CV_MirrorCoat2:
	if_hp_more_than AI_USER, 50, AI_CV_MirrorCoat3
	if_random_less_than 100, AI_CV_MirrorCoat3
	score -1

AI_CV_MirrorCoat3:
	if_has_move AI_USER, MOVE_COUNTER, AI_CV_MirrorCoat_ScoreUp4
	get_last_used_bank_move AI_TARGET
	get_move_power_from_result
	if_equal 0, AI_CV_MirrorCoat5
	if_target_not_taunted AI_CV_MirrorCoat4
	if_random_less_than 100, AI_CV_MirrorCoat4
	score +1

AI_CV_MirrorCoat4:
	get_last_used_bank_move AI_TARGET
	get_move_split_from_result
	if_not_equal SPLIT_SPECIAL, AI_CV_MirrorCoat_ScoreDown1
	if_random_less_than 100, AI_CV_MirrorCoat_End
	score +1
	goto AI_CV_MirrorCoat_End

AI_CV_MirrorCoat5:
	if_target_not_taunted AI_CV_MirrorCoat6
	if_random_less_than 100, AI_CV_MirrorCoat6
	score +1

AI_CV_MirrorCoat6:
	if_has_special_move AI_TARGET, AI_CV_MirrorCoat_End
	if_random_less_than 50, AI_CV_MirrorCoat_End

AI_CV_MirrorCoat_ScoreUp4:
	if_random_less_than 100, AI_CV_MirrorCoat_ScoreUp4_End
	score +4

AI_CV_MirrorCoat_ScoreUp4_End:
	end

AI_CV_MirrorCoat_ScoreDown1:
	score -1

AI_CV_MirrorCoat_End:
	end

AI_CV_ChargeUpMove:
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, Score_Minus5
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, Score_Minus3
	if_has_move_with_effect AI_TARGET, EFFECT_PROTECT, Score_Minus8
	if_hp_more_than AI_USER, 38, AI_CV_ChargeUpMove_End
	score -1
	goto AI_CV_ChargeUpMove_End

AI_CV_ChargeUpMove_End:
	end

AI_CV_Fly:
	if_doesnt_have_move_with_effect AI_TARGET, EFFECT_PROTECT, AI_CV_Fly2
	score -1
	goto AI_CV_Fly_End

AI_CV_Fly2:
	if_status AI_TARGET, STATUS1_TOXIC_POISON, AI_CV_Fly6
	if_status2 AI_TARGET, STATUS2_CURSED, AI_CV_Fly6
	if_status3 AI_TARGET, STATUS3_LEECHSEED, AI_CV_Fly6
	get_weather
	if_equal AI_WEATHER_HAIL, AI_CV_Fly3
	if_equal AI_WEATHER_SANDSTORM, AI_CV_Fly4
	goto AI_CV_Fly5

AI_CV_Fly3:
	get_user_type1
	if_in_bytes AI_CV_Fly_TypesToEncourage, AI_CV_Fly6
	get_user_type2
	if_in_bytes AI_CV_Fly_TypesToEncourage, AI_CV_Fly6
	goto AI_CV_Fly5

AI_CV_Fly4:
	get_user_type1
	if_equal TYPE_ICE, AI_CV_Fly6
	get_user_type2
	if_equal TYPE_ICE, AI_CV_Fly6

AI_CV_Fly5:
	if_target_faster AI_CV_Fly_End
	get_last_used_bank_move AI_TARGET
	get_move_effect_from_result
	if_not_equal EFFECT_LOCK_ON, AI_CV_Fly6
	goto AI_CV_Fly_End

AI_CV_Fly6:
	if_random_less_than 80, AI_CV_Fly_End
	score +1

AI_CV_Fly_End:
	end

AI_CV_Fly_TypesToEncourage:
    .byte TYPE_GROUND
    .byte TYPE_ROCK
    .byte TYPE_STEEL
    .byte -1

AI_CV_FakeOut:
	get_ability AI_TARGET
	if_in_bytes AI_CV_Trick_AbilitiesToDiscourage, Score_Minus1
	if_status2 AI_TARGET, STATUS2_SUBSTITUTE, Score_Minus1
	score +5
	end

AI_CV_Trick_AbilitiesToDiscourage:
    .byte ABILITY_INNER_FOCUS
    .byte ABILITY_SHIELD_DUST
    .byte ABILITY_STEADFAST
    .byte -1

AI_CV_SpitUp:
	get_stockpile_count AI_USER
	if_less_than 2, AI_CV_SpitUp_End
	if_random_less_than 80, AI_CV_SpitUp_End
	score +2

AI_CV_SpitUp_End:
	end

AI_CV_Hail:
	if_hp_less_than AI_USER, 40, AI_CV_Hail_ScoreDown1
	get_weather
	if_equal AI_WEATHER_SUN, AI_CV_Hail2
	if_equal AI_WEATHER_RAIN, AI_CV_Hail2
	if_equal AI_WEATHER_SANDSTORM, AI_CV_Hail2
	goto AI_CV_Hail_Rock
AI_CV_Hail2:
	score +1
	goto AI_CV_Hail_Rock
AI_CV_Hail_ScoreDown1:
	score -1
AI_CV_Hail_Rock:
	get_hold_effect AI_USER
	if_not_equal HOLD_EFFECT_ICY_ROCK, AI_Ret
	score +2
AI_CV_Hail_Ability:
	get_ability AI_USER
	if_equal ABILITY_ICE_BODY, AI_CV_Hail_AbilityPlus
	if_equal ABILITY_SNOW_CLOAK, AI_CV_Hail_AbilityPlus
	if_equal ABILITY_SLUSH_RUSH, AI_CV_Hail_AbilityPlus
	if_not_equal ABILITY_FORECAST, AI_CV_Hail_End
AI_CV_Hail_AbilityPlus:
	score +1,
AI_CV_Hail_End:
	end

AI_CV_Sandstorm:
	if_hp_less_than AI_USER, 40, AI_CV_Sandstorm_ScoreDown1
	get_weather
	if_equal AI_WEATHER_SUN, AI_CV_Sandstorm2
	if_equal AI_WEATHER_RAIN, AI_CV_Sandstorm2
	if_equal AI_WEATHER_HAIL, AI_CV_Sandstorm2
	goto AI_CV_Sandstorm_End
AI_CV_Sandstorm2:
	score +1
	goto AI_CV_Sandstorm_End
AI_CV_Sandstorm_ScoreDown1:
	score -1
AI_CV_Sandstorm_Rock:
	get_hold_effect AI_USER
	if_not_equal HOLD_EFFECT_SMOOTH_ROCK, AI_CV_Sandstorm_Ability
	score +2
AI_CV_Sandstorm_Ability:
	get_ability AI_USER
	if_equal ABILITY_SAND_VEIL, AI_CV_Sandstorm_AbilityPlus
	if_equal ABILITY_SAND_RUSH, AI_CV_Sandstorm_AbilityPlus
	if_not_equal ABILITY_SAND_VEIL, AI_CV_Sandstorm_End
AI_CV_Sandstorm_AbilityPlus:
	score +1,
AI_CV_Sandstorm_End:
	end

AI_CV_Facade:
	if_not_status AI_USER, STATUS1_ANY, AI_Ret
	goto Score_Plus2

AI_CV_FocusPunch:
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_FocusPunch2
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_FocusPunch2
	if_status AI_TARGET, STATUS1_SLEEP, AI_CV_FocusPunch_ScoreUp1
	if_status2 AI_TARGET, STATUS2_INFATUATION, AI_CV_FocusPunch3
	if_status2 AI_TARGET, STATUS2_CONFUSION, AI_CV_FocusPunch3
	is_first_turn_for AI_USER
	if_not_equal 0, AI_CV_FocusPunch_End
	if_random_less_than 100, AI_CV_FocusPunch_End
	score +1
	goto AI_CV_FocusPunch_End

AI_CV_FocusPunch2:
	score -1
	goto AI_CV_FocusPunch_End

AI_CV_FocusPunch3:
	if_random_less_than 100, AI_CV_FocusPunch_End
	if_status2 AI_USER, STATUS2_SUBSTITUTE, Score_Plus5

AI_CV_FocusPunch_ScoreUp1:
	score +1

AI_CV_FocusPunch_End:
	end

AI_CV_SmellingSalt:
	if_status AI_TARGET, STATUS1_PARALYSIS, AI_CV_SmellingSalt_ScoreUp1
	goto AI_CV_SmellingSalt_End

AI_CV_SmellingSalt_ScoreUp1:
	score +1

AI_CV_SmellingSalt_End:
	end

AI_CV_Trick:
	get_hold_effect AI_USER
	if_in_bytes AI_CV_Trick_EffectsToEncourage2, AI_CV_Trick3
	if_in_bytes AI_CV_Trick_EffectsToEncourage, AI_CV_Trick4

AI_CV_Trick2:
	score -3
	goto AI_CV_Trick_End

AI_CV_Trick3:
	get_hold_effect AI_TARGET
	if_in_bytes AI_CV_Trick_EffectsToEncourage2, AI_CV_Trick2
	score +5
	goto AI_CV_Trick_End

AI_CV_Trick4:
	get_hold_effect AI_TARGET
	if_in_bytes AI_CV_Trick_EffectsToEncourage, AI_CV_Trick2
	if_random_less_than 50, AI_CV_Trick_End
	score +2

AI_CV_Trick_End:
	end

AI_CV_Trick_EffectsToEncourage:
    .byte HOLD_EFFECT_CONFUSE_SPICY
    .byte HOLD_EFFECT_CONFUSE_DRY
    .byte HOLD_EFFECT_CONFUSE_SWEET
    .byte HOLD_EFFECT_CONFUSE_BITTER
    .byte HOLD_EFFECT_CONFUSE_SOUR
    .byte HOLD_EFFECT_MACHO_BRACE
    .byte HOLD_EFFECT_CHOICE_BAND
    .byte -1

AI_CV_Trick_EffectsToEncourage2:
    .byte HOLD_EFFECT_CHOICE_BAND
    .byte -1

AI_CV_ChangeSelfAbility:
	get_ability AI_USER
	if_in_bytes AI_CV_ChangeSelfAbility_AbilitiesToEncourage, AI_CV_ChangeSelfAbility2
	get_ability AI_TARGET
	if_in_bytes AI_CV_ChangeSelfAbility_AbilitiesToEncourage, AI_CV_ChangeSelfAbility3

AI_CV_ChangeSelfAbility2:
	score -1
	goto AI_CV_ChangeSelfAbility_End

AI_CV_ChangeSelfAbility3:
	if_random_less_than 50, AI_CV_ChangeSelfAbility_End
	score +2

AI_CV_ChangeSelfAbility_End:
	end

AI_CV_ChangeSelfAbility_AbilitiesToEncourage:
    .byte ABILITY_SPEED_BOOST
    .byte ABILITY_BATTLE_ARMOR
    .byte ABILITY_SAND_VEIL
    .byte ABILITY_STATIC
    .byte ABILITY_FLASH_FIRE
    .byte ABILITY_WONDER_GUARD
    .byte ABILITY_EFFECT_SPORE
    .byte ABILITY_SWIFT_SWIM
    .byte ABILITY_HUGE_POWER
    .byte ABILITY_RAIN_DISH
    .byte ABILITY_CUTE_CHARM
    .byte ABILITY_SHED_SKIN
    .byte ABILITY_MARVEL_SCALE
    .byte ABILITY_PURE_POWER
    .byte ABILITY_CHLOROPHYLL
    .byte ABILITY_SHIELD_DUST
    .byte -1

AI_CV_Superpower:
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_Superpower_ScoreDown1
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_Superpower_ScoreDown1
	if_stat_level_less_than AI_USER, STAT_ATK, 6, AI_CV_Superpower_ScoreDown1
	if_target_faster AI_CV_Superpower2
	if_hp_more_than AI_USER, 40, AI_CV_Superpower_ScoreDown1
	goto AI_CV_Superpower_End

AI_CV_Superpower2:
	if_hp_less_than AI_USER, 60, AI_CV_Superpower_End

AI_CV_Superpower_ScoreDown1:
	score -1

AI_CV_Superpower_End:
	end

AI_CV_MagicCoat:
	if_hp_more_than AI_TARGET, 30, AI_CV_MagicCoat2
	if_random_less_than 100, AI_CV_MagicCoat2
	score -1

AI_CV_MagicCoat2:
	is_first_turn_for AI_USER
	if_equal 0, AI_CV_MagicCoat4
	if_random_less_than 150, AI_CV_MagicCoat_End
	score +1
	goto AI_CV_MagicCoat_End

AI_CV_MagicCoat3:
	if_random_less_than 50, AI_CV_MagicCoat_End

AI_CV_MagicCoat4:
	if_random_less_than 30, AI_CV_MagicCoat_End
	score -1

AI_CV_MagicCoat_End:
	end

AI_CV_Recycle:
	get_used_held_item AI_USER
	if_not_in_bytes AI_CV_Recycle_ItemsToEncourage, AI_CV_Recycle_ScoreDown2
	if_random_less_than 50, AI_CV_Recycle_End
	score +1
	goto AI_CV_Recycle_End

AI_CV_Recycle_ScoreDown2:
	score -2

AI_CV_Recycle_End:
	end

AI_CV_Recycle_ItemsToEncourage:
    .byte ITEM_CHESTO_BERRY
    .byte ITEM_LUM_BERRY
    .byte ITEM_STARF_BERRY
		.byte ITEM_SITRUS_BERRY
    .byte -1

AI_CV_Revenge:
	if_status AI_TARGET, STATUS1_SLEEP, AI_CV_Revenge_ScoreDown2
	if_status2 AI_TARGET, STATUS2_INFATUATION, AI_CV_Revenge_ScoreDown2
	if_status2 AI_TARGET, STATUS2_CONFUSION, AI_CV_Revenge_ScoreDown2
	if_random_less_than 180, AI_CV_Revenge_ScoreDown2
	score +2
	goto AI_CV_Revenge_End

AI_CV_Revenge_ScoreDown2:
	score -2

AI_CV_Revenge_End:
	end

AI_CV_BrickBreak:
	if_side_affecting AI_TARGET, SIDE_STATUS_REFLECT, AI_CV_BrickBreak_ScoreUp1
	goto AI_CV_BrickBreak_End

AI_CV_BrickBreak_ScoreUp1:
	score +1

AI_CV_BrickBreak_End:
	end

AI_CV_KnockOff:
	if_hp_less_than AI_TARGET, 30, AI_CV_KnockOff_End
	is_first_turn_for AI_USER
	if_more_than 0, AI_CV_KnockOff_End
	if_random_less_than 180, AI_CV_KnockOff_End
	score +1

AI_CV_KnockOff_End:
	end

AI_CV_Endeavor:
	if_hp_less_than AI_TARGET, 70, AI_CV_Endeavor_ScoreDown1
	if_target_faster AI_CV_Endeavor2
	if_hp_more_than AI_USER, 40, AI_CV_Endeavor_ScoreDown1
	score +1
	goto AI_CV_Endeavor_End

AI_CV_Endeavor2:
	if_hp_more_than AI_USER, 50, AI_CV_Endeavor_ScoreDown1
	score +1
	goto AI_CV_Endeavor_End

AI_CV_Endeavor_ScoreDown1:
	score -1

AI_CV_Endeavor_End:
	end

AI_CV_Eruption:
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_Eruption_ScoreDown1
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_Eruption_ScoreDown1
	if_target_faster AI_CV_Eruption2
	if_hp_more_than AI_TARGET, 50, AI_CV_Eruption_End
	goto AI_CV_Eruption_ScoreDown1

AI_CV_Eruption2:
	if_hp_more_than AI_TARGET, 70, AI_CV_Eruption_End

AI_CV_Eruption_ScoreDown1:
	score -1

AI_CV_Eruption_End:
	end

AI_CV_Imprison:
	is_first_turn_for AI_USER
	if_more_than 0, AI_CV_Imprison_End
	if_random_less_than 100, AI_CV_Imprison_End
	score +2

AI_CV_Imprison_End:
	end

AI_CV_Refresh:
	if_status AI_USER, STATUS1_ANY, Score_Plus3
	goto Score_Minus8

AI_CV_Snatch:
	is_first_turn_for AI_USER
	if_equal 1, AI_CV_Snatch3
	if_random_less_than 30, AI_CV_Snatch_End
	if_target_faster AI_CV_Snatch2
	if_hp_not_equal AI_USER, 100, AI_CV_Snatch5
	if_hp_less_than AI_TARGET, 70, AI_CV_Snatch5
	if_random_less_than 60, AI_CV_Snatch_End
	goto AI_CV_Snatch5

AI_CV_Snatch2:
	if_hp_more_than AI_TARGET, 25, AI_CV_Snatch5
	if_has_move_with_effect AI_TARGET, EFFECT_RESTORE_HP, AI_CV_Snatch3
	if_has_move_with_effect AI_TARGET, EFFECT_DEFENSE_CURL, AI_CV_Snatch3
	goto AI_CV_Snatch4

AI_CV_Snatch3:
	if_random_less_than 150, AI_CV_Snatch_End
	score +2
	goto AI_CV_Snatch_End

AI_CV_Snatch4:
	if_random_less_than 230, AI_CV_Snatch5
	score +1
	goto AI_CV_Snatch_End

AI_CV_Snatch5:
	if_random_less_than 30, AI_CV_Snatch_End
	score -2

AI_CV_Snatch_End:
	end

AI_CV_MudSport:
	if_hp_less_than AI_USER, 50, AI_CV_MudSport_ScoreDown1
	get_target_type1
	if_equal TYPE_ELECTRIC, AI_CV_MudSport2
	get_target_type2
	if_equal TYPE_ELECTRIC, AI_CV_MudSport2
	goto AI_CV_MudSport_ScoreDown1

AI_CV_MudSport2:
	score +1
	goto AI_CV_MudSport_End

AI_CV_MudSport_ScoreDown1:
	score -1

AI_CV_MudSport_End:
	end

AI_CV_Overheat:
	if_type_effectiveness AI_EFFECTIVENESS_x0_25, AI_CV_Overheat_ScoreDown1
	if_type_effectiveness AI_EFFECTIVENESS_x0_5, AI_CV_Overheat_ScoreDown1
	if_target_faster AI_CV_Overheat2
	if_hp_more_than AI_USER, 60, AI_CV_Overheat_End
	goto AI_CV_Overheat_ScoreDown1

AI_CV_Overheat2:
	if_hp_more_than AI_USER, 80, AI_CV_Overheat_End

AI_CV_Overheat_ScoreDown1:
	score -1

AI_CV_Overheat_End:
	end

AI_CV_WaterSport:
	if_hp_less_than AI_USER, 50, AI_CV_WaterSport_ScoreDown1
	get_target_type1
	if_equal TYPE_FIRE, AI_CV_WaterSport2
	get_target_type2
	if_equal TYPE_FIRE, AI_CV_WaterSport2
	goto AI_CV_WaterSport_ScoreDown1

AI_CV_WaterSport2:
	score +1
	goto AI_CV_WaterSport_End

AI_CV_WaterSport_ScoreDown1:
	score -1

AI_CV_WaterSport_End:
	end

AI_CV_DragonDance:
	if_target_faster AI_CV_DragonDance2
	if_hp_more_than AI_USER, 50, AI_CV_DragonDance_End
	if_random_less_than 70, AI_CV_DragonDance_End
	score -1
	goto AI_CV_DragonDance_End

AI_CV_DragonDance2:
	if_random_less_than 128, AI_CV_DragonDance_End
	score +1

AI_CV_DragonDance_End:
	end

AI_TryToFaint:
	if_target_is_ally AI_Ret
	if_can_faint AI_TryToFaint_Can
	get_how_powerful_move_is
	if_equal MOVE_POWER_DISCOURAGED, Score_Minus1
AI_TryToFaint2:
	if_type_effectiveness AI_EFFECTIVENESS_x4, AI_TryToFaint_DoubleSuperEffective
	goto AI_TryToFaint_CheckIfDanger
AI_TryToFaint_DoubleSuperEffective:
	if_random_less_than 80, AI_TryToFaint_CheckIfDanger
	score +2
	goto AI_TryToFaint_CheckIfDanger
AI_TryToFaint_Can:
	if_effect EFFECT_EXPLOSION, AI_TryToFaint_CheckIfDanger
	if_user_faster AI_TryToFaint_ScoreUp4
	if_move_flag FLAG_HIGH_CRIT AI_TryToFaint_ScoreUp4
	score +2
	goto AI_TryToFaint_CheckIfDanger
AI_TryToFaint_ScoreUp4:
	score +4
AI_TryToFaint_CheckIfDanger:
	if_user_faster AI_TryToFaint_End
	if_ai_can_go_down AI_TryToFaint_Danger
AI_TryToFaint_End:
	end
AI_TryToFaint_Danger:
	get_how_powerful_move_is
	if_not_equal MOVE_POWER_BEST, Score_Minus1
	score +1
	goto AI_TryToFaint_End

AI_SetupFirstTurn:
	if_target_is_ally AI_Ret
	get_turn_count
	if_not_equal 0, AI_SetupFirstTurn_End
	get_considered_move_effect
	if_not_in_hwords AI_SetupFirstTurn_SetupEffectsToEncourage, AI_SetupFirstTurn_End
	if_random_less_than 80, AI_SetupFirstTurn_End
	score +2

AI_SetupFirstTurn_End:
	end

.align 1
AI_SetupFirstTurn_SetupEffectsToEncourage:
    .2byte EFFECT_ATTACK_UP
    .2byte EFFECT_DEFENSE_UP
    .2byte EFFECT_SPEED_UP
    .2byte EFFECT_SPECIAL_ATTACK_UP
    .2byte EFFECT_SPECIAL_DEFENSE_UP
    .2byte EFFECT_ACCURACY_UP
    .2byte EFFECT_EVASION_UP
    .2byte EFFECT_ATTACK_DOWN
    .2byte EFFECT_DEFENSE_DOWN
    .2byte EFFECT_SPEED_DOWN
    .2byte EFFECT_SPECIAL_ATTACK_DOWN
    .2byte EFFECT_SPECIAL_DEFENSE_DOWN
    .2byte EFFECT_ACCURACY_DOWN
    .2byte EFFECT_EVASION_DOWN
    .2byte EFFECT_CONVERSION
    .2byte EFFECT_LIGHT_SCREEN
    .2byte EFFECT_SPECIAL_DEFENSE_UP_2
    .2byte EFFECT_FOCUS_ENERGY
    .2byte EFFECT_CONFUSE
    .2byte EFFECT_ATTACK_UP_2
    .2byte EFFECT_DEFENSE_UP_2
    .2byte EFFECT_SPEED_UP_2
    .2byte EFFECT_SPECIAL_ATTACK_UP_2
    .2byte EFFECT_SPECIAL_DEFENSE_UP_2
    .2byte EFFECT_ACCURACY_UP_2
    .2byte EFFECT_EVASION_UP_2
    .2byte EFFECT_ATTACK_DOWN_2
    .2byte EFFECT_DEFENSE_DOWN_2
    .2byte EFFECT_SPEED_DOWN_2
    .2byte EFFECT_SPECIAL_ATTACK_DOWN_2
    .2byte EFFECT_SPECIAL_DEFENSE_DOWN_2
    .2byte EFFECT_ACCURACY_DOWN_2
    .2byte EFFECT_EVASION_DOWN_2
    .2byte EFFECT_REFLECT
    .2byte EFFECT_POISON
    .2byte EFFECT_PARALYZE
    .2byte EFFECT_SUBSTITUTE
    .2byte EFFECT_LEECH_SEED
    .2byte EFFECT_MINIMIZE
    .2byte EFFECT_CURSE
    .2byte EFFECT_SWAGGER
    .2byte EFFECT_CAMOUFLAGE
    .2byte EFFECT_YAWN
    .2byte EFFECT_DEFENSE_CURL
    .2byte EFFECT_TORMENT
    .2byte EFFECT_FLATTER
    .2byte EFFECT_WILL_O_WISP
    .2byte EFFECT_INGRAIN
    .2byte EFFECT_IMPRISON
    .2byte EFFECT_TEETER_DANCE
    .2byte EFFECT_TICKLE
    .2byte EFFECT_COSMIC_POWER
    .2byte EFFECT_BULK_UP
    .2byte EFFECT_CALM_MIND
    .2byte EFFECT_ACUPRESSURE
    .2byte EFFECT_AUTONOMIZE
    .2byte EFFECT_SHIFT_GEAR
    .2byte EFFECT_SHELL_SMASH
    .2byte EFFECT_GROWTH
    .2byte EFFECT_QUIVER_DANCE
    .2byte EFFECT_ATTACK_SPATK_UP
    .2byte EFFECT_ATTACK_ACCURACY_UP
    .2byte EFFECT_PSYCHIC_TERRAIN
    .2byte EFFECT_GRASSY_TERRAIN
    .2byte EFFECT_ELECTRIC_TERRAIN
    .2byte EFFECT_MISTY_TERRAIN
    .2byte EFFECT_STEALTH_ROCK
    .2byte EFFECT_TOXIC_SPIKES
    .2byte EFFECT_TRICK_ROOM
    .2byte EFFECT_WONDER_ROOM
    .2byte EFFECT_MAGIC_ROOM
    .2byte EFFECT_TAILWIND
    .2byte EFFECT_DRAGON_DANCE
    .2byte EFFECT_STICKY_WEB
    .2byte -1

AI_PreferStrongestMove:
	if_target_is_ally AI_Ret
	get_how_powerful_move_is
	if_not_equal MOVE_POWER_BEST, AI_PreferStrongestMove_End
	if_random_less_than 100, AI_PreferStrongestMove_End
	score +2
AI_PreferStrongestMove_End:
	end

AI_Risky:
	if_target_is_ally AI_Ret
	get_considered_move_effect
	if_move_flag FLAG_HIGH_CRIT AI_Risky_RandChance
	if_not_in_bytes AI_Risky_EffectsToEncourage, AI_Risky_End
AI_Risky_RandChance:
	if_random_less_than 128, AI_Risky_End
	score +2
AI_Risky_End:
	end

AI_Risky_EffectsToEncourage:
    .byte EFFECT_SLEEP
    .byte EFFECT_EXPLOSION
    .byte EFFECT_MIRROR_MOVE
    .byte EFFECT_OHKO
    .byte EFFECT_CONFUSE
    .byte EFFECT_METRONOME
    .byte EFFECT_PSYWAVE
    .byte EFFECT_COUNTER
    .byte EFFECT_DESTINY_BOND
    .byte EFFECT_SWAGGER
    .byte EFFECT_ATTRACT
    .byte EFFECT_PRESENT
    .byte EFFECT_ALL_STATS_UP_HIT
    .byte EFFECT_BELLY_DRUM
    .byte EFFECT_MIRROR_COAT
    .byte EFFECT_FOCUS_PUNCH
    .byte EFFECT_REVENGE
    .byte EFFECT_TEETER_DANCE
    .byte -1

.align 1
sMovesTable_ProtectMoves:
    .2byte MOVE_PROTECT
    .2byte MOVE_DETECT
    .2byte -1

sEffectsStatRaise:
	.2byte EFFECT_ATTACK_UP
	.2byte EFFECT_ATTACK_UP_2
	.2byte EFFECT_DEFENSE_UP
	.2byte EFFECT_DEFENSE_UP_2
	.2byte EFFECT_SPEED_UP
	.2byte EFFECT_SPEED_UP_2
	.2byte EFFECT_SPECIAL_ATTACK_UP
	.2byte EFFECT_SPECIAL_ATTACK_UP_2
	.2byte EFFECT_SPECIAL_DEFENSE_UP
	.2byte EFFECT_SPECIAL_DEFENSE_UP_2
	.2byte EFFECT_CALM_MIND
	.2byte EFFECT_DRAGON_DANCE
	.2byte EFFECT_ACUPRESSURE
	.2byte EFFECT_SHELL_SMASH
	.2byte EFFECT_SHIFT_GEAR
	.2byte EFFECT_ATTACK_ACCURACY_UP
	.2byte EFFECT_ATTACK_SPATK_UP
	.2byte EFFECT_GROWTH
	.2byte EFFECT_COIL
	.2byte EFFECT_QUIVER_DANCE
	.2byte -1

AI_PreferBatonPass:
	if_target_is_ally AI_Ret
	count_usable_party_mons AI_USER
	if_equal 0, AI_PreferBatonPassEnd
	get_how_powerful_move_is
	if_not_equal MOVE_POWER_DISCOURAGED, AI_PreferBatonPassEnd
	if_doesnt_have_move_with_effect AI_USER, EFFECT_BATON_PASS, AI_PreferBatonPassEnd
	get_considered_move_effect
	if_in_hwords sEffectsStatRaise, AI_PreferBatonPass2
	if_effect EFFECT_PROTECT, AI_PreferBatonPass3
	if_move MOVE_BATON_PASS, AI_PreferBatonPass_EncourageIfHighStats
	end
AI_PreferBatonPass2:
	get_turn_count
	if_equal 0, Score_Plus5
	if_hp_less_than AI_USER, 60, Score_Minus10
	goto Score_Plus1
AI_PreferBatonPass3:
	get_last_used_bank_move AI_USER
	if_in_hwords sMovesTable_ProtectMoves, Score_Minus2
	score +2
	end
AI_PreferBatonPass_EncourageIfHighStats:
	get_turn_count
	if_equal 0, Score_Minus2
	if_stat_level_more_than AI_USER, STAT_ATK, 8, Score_Plus3
	if_stat_level_more_than AI_USER, STAT_ATK, 7, Score_Plus2
	if_stat_level_more_than AI_USER, STAT_ATK, 6, Score_Plus1
	if_stat_level_more_than AI_USER, STAT_SPATK, 8, Score_Plus3
	if_stat_level_more_than AI_USER, STAT_SPATK, 7, Score_Plus2
	if_stat_level_more_than AI_USER, STAT_SPATK, 6, Score_Plus1
	end
AI_PreferBatonPassEnd:
	end

AI_ConsiderAllyChosenMove:
	get_ally_chosen_move
	if_equal 0, AI_ConsiderAllyChosenMoveRet
	get_move_effect_from_result
	if_equal EFFECT_HELPING_HAND, AI_PartnerChoseHelpingHand
	if_equal EFFECT_PERISH_SONG, AI_PartnerChosePerishSong
AI_ConsiderAllyChosenMoveRet:
	end

AI_PartnerChoseHelpingHand:
	@ Do not use a status move if you know your move's power will be boosted
	get_considered_move_power
	if_equal 0, Score_Minus5
	end

AI_PartnerChosePerishSong:
	if_status2 AI_TARGET, STATUS2_ESCAPE_PREVENTION | STATUS2_WRAPPED, AI_Ret
	get_considered_move_effect
	if_equal EFFECT_MEAN_LOOK, Score_Plus1
	if_equal EFFECT_TRAP, Score_Plus1
	end

AI_ConsiderAllyKnownMoves:
	@ If ally already chose a move, there is nothing to do here.
	get_ally_chosen_move
	if_not_equal 0, AI_Ret
	if_move MOVE_HELPING_HAND, AI_HelpingHandInDoubles
	if_move MOVE_PERISH_SONG, AI_PerishSongInDoubles
	end

AI_HelpingHandInDoubles:
	if_has_no_attacking_moves AI_USER_PARTNER, Score_Minus5
	end

AI_PerishSongInDoubles:
	if_has_move_with_effect AI_USER_PARTNER, EFFECT_MEAN_LOOK, Score_Plus1
	if_has_move_with_effect AI_USER_PARTNER, EFFECT_TRAP, Score_Plus1
	end

AI_DoubleBattle:
	call AI_ConsiderAllyChosenMove
	call AI_ConsiderAllyKnownMoves
	if_target_is_ally AI_TryOnAlly
	if_move MOVE_SKILL_SWAP, AI_DoubleBattleSkillSwap
	get_curr_move_type
	if_move MOVE_EARTHQUAKE, AI_DoubleBattleAllHittingGroundMove
	if_move MOVE_MAGNITUDE, AI_DoubleBattleAllHittingGroundMove
	if_equal TYPE_ELECTRIC, AI_DoubleBattleElectricMove
	if_equal TYPE_FIRE, AI_DoubleBattleFireMove
	get_ability AI_USER
	if_not_equal ABILITY_GUTS, AI_DoubleBattleCheckUserStatus
	if_has_move AI_USER_PARTNER, MOVE_HELPING_HAND, AI_DoubleBattlePartnerHasHelpingHand
	end

AI_DoubleBattlePartnerHasHelpingHand:
	get_how_powerful_move_is
	if_not_equal MOVE_POWER_DISCOURAGED, Score_Plus1
	end

AI_DoubleBattleCheckUserStatus:
	if_status AI_USER, STATUS1_ANY, AI_DoubleBattleCheckUserStatus2
	end

AI_DoubleBattleCheckUserStatus2:
	get_how_powerful_move_is
	if_equal MOVE_POWER_DISCOURAGED, Score_Minus5
	score +1
	if_equal MOVE_POWER_BEST, Score_Plus2
	end

AI_DoubleBattleAllHittingGroundMove:
	if_ability AI_USER_PARTNER, ABILITY_LEVITATE, Score_Plus2
	if_type AI_USER_PARTNER, TYPE_FLYING, Score_Plus2
	if_type AI_USER_PARTNER, TYPE_FIRE, Score_Minus10
	if_type AI_USER_PARTNER, TYPE_ELECTRIC, Score_Minus10
	if_type AI_USER_PARTNER, TYPE_POISON, Score_Minus10
	if_type AI_USER_PARTNER, TYPE_ROCK, Score_Minus10
	goto Score_Minus3

AI_DoubleBattleSkillSwap:
	get_ability AI_USER
	if_equal ABILITY_TRUANT, Score_Plus5
	get_ability AI_TARGET
	if_equal ABILITY_SHADOW_TAG, Score_Plus2
	if_equal ABILITY_PURE_POWER, Score_Plus2
	end

AI_DoubleBattleElectricMove:
	if_no_ability AI_TARGET_PARTNER, ABILITY_LIGHTNING_ROD, AI_DoubleBattleElectricMoveEnd
	score -2
	if_no_type AI_TARGET_PARTNER, TYPE_GROUND, AI_DoubleBattleElectricMoveEnd
	score -8

AI_DoubleBattleElectricMoveEnd:
	end

AI_DoubleBattleFireMove:
	if_flash_fired AI_USER, AI_DoubleBattleFireMove2
	end

AI_DoubleBattleFireMove2:
	goto Score_Plus1

AI_TryOnAlly:
	get_how_powerful_move_is
	if_equal MOVE_POWER_DISCOURAGED, AI_TryStatusMoveOnAlly
	get_curr_move_type
	if_equal TYPE_FIRE, AI_TryFireMoveOnAlly

AI_DiscourageOnAlly:
	goto Score_Minus30

AI_TryFireMoveOnAlly:
	if_ability AI_USER_PARTNER, ABILITY_FLASH_FIRE, AI_TryFireMoveOnAlly_FlashFire
	goto AI_DiscourageOnAlly

AI_TryFireMoveOnAlly_FlashFire:
	if_flash_fired AI_USER_PARTNER, AI_DiscourageOnAlly
	goto Score_Plus3

AI_TryStatusMoveOnAlly:
	if_move MOVE_SKILL_SWAP, AI_TrySkillSwapOnAlly
	if_move MOVE_WILL_O_WISP, AI_TryStatusOnAlly
	if_move MOVE_TOXIC, AI_TryStatusOnAlly
	if_move MOVE_HELPING_HAND, AI_TryHelpingHandOnAlly
	if_move MOVE_SWAGGER, AI_TrySwaggerOnAlly
	goto Score_Minus30

AI_TrySkillSwapOnAlly:
	get_ability AI_TARGET
	if_equal ABILITY_TRUANT, Score_Plus10
	get_ability AI_USER
	if_not_equal ABILITY_LEVITATE, AI_TrySkillSwapOnAlly2
	get_ability AI_TARGET
	if_equal ABILITY_LEVITATE, Score_Minus30
	get_target_type1
	if_not_equal TYPE_ELECTRIC, AI_TrySkillSwapOnAlly2
	score +1
	get_target_type2
	if_not_equal TYPE_ELECTRIC, AI_TrySkillSwapOnAlly2
	score +1
	end

AI_TrySkillSwapOnAlly2:
	if_not_equal ABILITY_COMPOUND_EYES, Score_Minus30
	if_has_move AI_USER_PARTNER, MOVE_FIRE_BLAST, AI_TrySkillSwapOnAllyPlus3
	if_has_move AI_USER_PARTNER, MOVE_THUNDER, AI_TrySkillSwapOnAllyPlus3
	if_has_move AI_USER_PARTNER, MOVE_CROSS_CHOP, AI_TrySkillSwapOnAllyPlus3
	if_has_move AI_USER_PARTNER, MOVE_HYDRO_PUMP, AI_TrySkillSwapOnAllyPlus3
	if_has_move AI_USER_PARTNER, MOVE_DYNAMIC_PUNCH, AI_TrySkillSwapOnAllyPlus3
	if_has_move AI_USER_PARTNER, MOVE_BLIZZARD, AI_TrySkillSwapOnAllyPlus3
	if_has_move AI_USER_PARTNER, MOVE_MEGAHORN, AI_TrySkillSwapOnAllyPlus3
	goto Score_Minus30

AI_TrySkillSwapOnAllyPlus3:
	goto Score_Plus3

AI_TryStatusOnAlly:
	get_ability AI_TARGET
	if_not_equal ABILITY_GUTS, Score_Minus30
	if_status AI_TARGET, STATUS1_ANY, Score_Minus30
	if_hp_less_than AI_USER, 91, Score_Minus30
	goto Score_Plus5

AI_TryHelpingHandOnAlly:
	if_random_less_than 64, Score_Minus1
	goto Score_Plus2

AI_TrySwaggerOnAlly:
	if_has_no_physical_move AI_USER_PARTNER, Score_Minus30
	if_holds_item AI_TARGET, ITEM_PERSIM_BERRY, AI_TrySwaggerOnAlly2
	if_ability AI_USER_PARTNER, ABILITY_OWN_TEMPO, AI_TrySwaggerOnAlly2
	goto Score_Minus30

AI_TrySwaggerOnAlly2:
	if_stat_level_more_than AI_TARGET, STAT_ATK, 7, AI_TrySwaggerOnAlly_End
	score +3

AI_TrySwaggerOnAlly_End:
	end

AI_HPAware:
	if_target_is_ally AI_TryOnAlly
	if_hp_more_than AI_USER, 70, AI_HPAware_UserHasHighHP
	if_hp_more_than AI_USER, 30, AI_HPAware_UserHasMediumHP
	get_considered_move_effect
	if_in_bytes AI_HPAware_DiscouragedEffectsWhenLowHP, AI_HPAware_TryToDiscourage
	goto AI_HPAware_ConsiderTarget

AI_HPAware_UserHasHighHP:
	get_considered_move_effect
	if_in_bytes AI_HPAware_DiscouragedEffectsWhenHighHP, AI_HPAware_TryToDiscourage
	goto AI_HPAware_ConsiderTarget

AI_HPAware_UserHasMediumHP:
	get_considered_move_effect
	if_in_bytes AI_HPAware_DiscouragedEffectsWhenMediumHP, AI_HPAware_TryToDiscourage
	goto AI_HPAware_ConsiderTarget

AI_HPAware_TryToDiscourage:
	if_random_less_than 50, AI_HPAware_ConsiderTarget
	score -2

AI_HPAware_ConsiderTarget:
	if_hp_more_than AI_TARGET, 70, AI_HPAware_TargetHasHighHP
	if_hp_more_than AI_TARGET, 30, AI_HPAware_TargetHasMediumHP
	get_considered_move_effect
	if_in_bytes AI_HPAware_DiscouragedEffectsWhenTargetLowHP, AI_HPAware_TargetTryToDiscourage
	goto AI_HPAware_End

AI_HPAware_TargetHasHighHP:
	get_considered_move_effect
	if_in_bytes AI_HPAware_DiscouragedEffectsWhenTargetHighHP, AI_HPAware_TargetTryToDiscourage
	goto AI_HPAware_End

AI_HPAware_TargetHasMediumHP:
	get_considered_move_effect
	if_in_bytes AI_HPAware_DiscouragedEffectsWhenTargetMediumHP, AI_HPAware_TargetTryToDiscourage
	goto AI_HPAware_End

AI_HPAware_TargetTryToDiscourage:
	if_random_less_than 50, AI_HPAware_End
	score -2

AI_HPAware_End:
	end

AI_HPAware_DiscouragedEffectsWhenHighHP: @ 82DE21F
    .byte EFFECT_EXPLOSION
    .byte EFFECT_RESTORE_HP
    .byte EFFECT_REST
    .byte EFFECT_DESTINY_BOND
    .byte EFFECT_FLAIL
    .byte EFFECT_ENDURE
    .byte EFFECT_MORNING_SUN
    .byte EFFECT_SYNTHESIS
    .byte EFFECT_MOONLIGHT
    .byte EFFECT_SOFTBOILED
    .byte EFFECT_ROOST
    .byte EFFECT_MEMENTO
    .byte EFFECT_GRUDGE
    .byte EFFECT_OVERHEAT
    .byte -1

AI_HPAware_DiscouragedEffectsWhenMediumHP: @ 82DE22D
    .byte EFFECT_EXPLOSION
    .byte EFFECT_ATTACK_UP
    .byte EFFECT_DEFENSE_UP
    .byte EFFECT_SPEED_UP
    .byte EFFECT_SPECIAL_ATTACK_UP
    .byte EFFECT_SPECIAL_DEFENSE_UP
    .byte EFFECT_ACCURACY_UP
    .byte EFFECT_EVASION_UP
    .byte EFFECT_ATTACK_DOWN
    .byte EFFECT_DEFENSE_DOWN
    .byte EFFECT_SPEED_DOWN
    .byte EFFECT_SPECIAL_ATTACK_DOWN
    .byte EFFECT_SPECIAL_DEFENSE_DOWN
    .byte EFFECT_ACCURACY_DOWN
    .byte EFFECT_EVASION_DOWN
    .byte EFFECT_BIDE
    .byte EFFECT_CONVERSION
    .byte EFFECT_LIGHT_SCREEN
    .byte EFFECT_MIST
    .byte EFFECT_FOCUS_ENERGY
    .byte EFFECT_ATTACK_UP_2
    .byte EFFECT_DEFENSE_UP_2
    .byte EFFECT_SPEED_UP_2
    .byte EFFECT_SPECIAL_ATTACK_UP_2
    .byte EFFECT_SPECIAL_DEFENSE_UP_2
    .byte EFFECT_ACCURACY_UP_2
    .byte EFFECT_EVASION_UP_2
    .byte EFFECT_ATTACK_DOWN_2
    .byte EFFECT_DEFENSE_DOWN_2
    .byte EFFECT_SPEED_DOWN_2
    .byte EFFECT_SPECIAL_ATTACK_DOWN_2
    .byte EFFECT_SPECIAL_DEFENSE_DOWN_2
    .byte EFFECT_ACCURACY_DOWN_2
    .byte EFFECT_EVASION_DOWN_2
    .byte EFFECT_CONVERSION_2
    .byte EFFECT_SAFEGUARD
    .byte EFFECT_BELLY_DRUM
    .byte EFFECT_TICKLE
    .byte EFFECT_COSMIC_POWER
    .byte EFFECT_BULK_UP
    .byte EFFECT_CALM_MIND
    .byte EFFECT_DRAGON_DANCE
    .byte -1

AI_HPAware_DiscouragedEffectsWhenLowHP: @ 82DE258
    .byte EFFECT_ATTACK_UP
    .byte EFFECT_DEFENSE_UP
    .byte EFFECT_SPEED_UP
    .byte EFFECT_SPECIAL_ATTACK_UP
    .byte EFFECT_SPECIAL_DEFENSE_UP
    .byte EFFECT_ACCURACY_UP
    .byte EFFECT_EVASION_UP
    .byte EFFECT_ATTACK_DOWN
    .byte EFFECT_DEFENSE_DOWN
    .byte EFFECT_SPEED_DOWN
    .byte EFFECT_SPECIAL_ATTACK_DOWN
    .byte EFFECT_SPECIAL_DEFENSE_DOWN
    .byte EFFECT_ACCURACY_DOWN
    .byte EFFECT_EVASION_DOWN
    .byte EFFECT_BIDE
    .byte EFFECT_CONVERSION
    .byte EFFECT_LIGHT_SCREEN
    .byte EFFECT_MIST
    .byte EFFECT_FOCUS_ENERGY
    .byte EFFECT_ATTACK_UP_2
    .byte EFFECT_DEFENSE_UP_2
    .byte EFFECT_SPEED_UP_2
    .byte EFFECT_SPECIAL_ATTACK_UP_2
    .byte EFFECT_SPECIAL_DEFENSE_UP_2
    .byte EFFECT_ACCURACY_UP_2
    .byte EFFECT_EVASION_UP_2
    .byte EFFECT_ATTACK_DOWN_2
    .byte EFFECT_DEFENSE_DOWN_2
    .byte EFFECT_SPEED_DOWN_2
    .byte EFFECT_SPECIAL_ATTACK_DOWN_2
    .byte EFFECT_SPECIAL_DEFENSE_DOWN_2
    .byte EFFECT_ACCURACY_DOWN_2
    .byte EFFECT_EVASION_DOWN_2
    .byte EFFECT_RAGE
    .byte EFFECT_CONVERSION_2
    .byte EFFECT_LOCK_ON
    .byte EFFECT_SAFEGUARD
    .byte EFFECT_BELLY_DRUM
    .byte EFFECT_PSYCH_UP
    .byte EFFECT_MIRROR_COAT
    .byte EFFECT_SOLARBEAM
    .byte EFFECT_ERUPTION
    .byte EFFECT_TICKLE
    .byte EFFECT_COSMIC_POWER
    .byte EFFECT_BULK_UP
    .byte EFFECT_CALM_MIND
    .byte EFFECT_DRAGON_DANCE
    .byte -1

AI_HPAware_DiscouragedEffectsWhenTargetHighHP: @ 82DE288
    .byte -1

AI_HPAware_DiscouragedEffectsWhenTargetMediumHP: @ 82DE289
    .byte EFFECT_ATTACK_UP
    .byte EFFECT_DEFENSE_UP
    .byte EFFECT_SPEED_UP
    .byte EFFECT_SPECIAL_ATTACK_UP
    .byte EFFECT_SPECIAL_DEFENSE_UP
    .byte EFFECT_ACCURACY_UP
    .byte EFFECT_EVASION_UP
    .byte EFFECT_ATTACK_DOWN
    .byte EFFECT_DEFENSE_DOWN
    .byte EFFECT_SPEED_DOWN
    .byte EFFECT_SPECIAL_ATTACK_DOWN
    .byte EFFECT_SPECIAL_DEFENSE_DOWN
    .byte EFFECT_ACCURACY_DOWN
    .byte EFFECT_EVASION_DOWN
    .byte EFFECT_MIST
    .byte EFFECT_FOCUS_ENERGY
    .byte EFFECT_ATTACK_UP_2
    .byte EFFECT_DEFENSE_UP_2
    .byte EFFECT_SPEED_UP_2
    .byte EFFECT_SPECIAL_ATTACK_UP_2
    .byte EFFECT_SPECIAL_DEFENSE_UP_2
    .byte EFFECT_ACCURACY_UP_2
    .byte EFFECT_EVASION_UP_2
    .byte EFFECT_ATTACK_DOWN_2
    .byte EFFECT_DEFENSE_DOWN_2
    .byte EFFECT_SPEED_DOWN_2
    .byte EFFECT_SPECIAL_ATTACK_DOWN_2
    .byte EFFECT_SPECIAL_DEFENSE_DOWN_2
    .byte EFFECT_ACCURACY_DOWN_2
    .byte EFFECT_EVASION_DOWN_2
    .byte EFFECT_POISON
    .byte EFFECT_PAIN_SPLIT
    .byte EFFECT_PERISH_SONG
    .byte EFFECT_SAFEGUARD
    .byte EFFECT_TICKLE
    .byte EFFECT_COSMIC_POWER
    .byte EFFECT_BULK_UP
    .byte EFFECT_CALM_MIND
    .byte EFFECT_DRAGON_DANCE
    .byte -1

AI_HPAware_DiscouragedEffectsWhenTargetLowHP: @ 82DE2B1
    .byte EFFECT_SLEEP
    .byte EFFECT_EXPLOSION
    .byte EFFECT_ATTACK_UP
    .byte EFFECT_DEFENSE_UP
    .byte EFFECT_SPEED_UP
    .byte EFFECT_SPECIAL_ATTACK_UP
    .byte EFFECT_SPECIAL_DEFENSE_UP
    .byte EFFECT_ACCURACY_UP
    .byte EFFECT_EVASION_UP
    .byte EFFECT_ATTACK_DOWN
    .byte EFFECT_DEFENSE_DOWN
    .byte EFFECT_SPEED_DOWN
    .byte EFFECT_SPECIAL_ATTACK_DOWN
    .byte EFFECT_SPECIAL_DEFENSE_DOWN
    .byte EFFECT_ACCURACY_DOWN
    .byte EFFECT_EVASION_DOWN
    .byte EFFECT_BIDE
    .byte EFFECT_CONVERSION
    .byte EFFECT_TOXIC
    .byte EFFECT_LIGHT_SCREEN
    .byte EFFECT_OHKO
    .byte EFFECT_SUPER_FANG
    .byte EFFECT_MIST
    .byte EFFECT_FOCUS_ENERGY
    .byte EFFECT_CONFUSE
    .byte EFFECT_ATTACK_UP_2
    .byte EFFECT_DEFENSE_UP_2
    .byte EFFECT_SPEED_UP_2
    .byte EFFECT_SPECIAL_ATTACK_UP_2
    .byte EFFECT_SPECIAL_DEFENSE_UP_2
    .byte EFFECT_ACCURACY_UP_2
    .byte EFFECT_EVASION_UP_2
    .byte EFFECT_ATTACK_DOWN_2
    .byte EFFECT_DEFENSE_DOWN_2
    .byte EFFECT_SPEED_DOWN_2
    .byte EFFECT_SPECIAL_ATTACK_DOWN_2
    .byte EFFECT_SPECIAL_DEFENSE_DOWN_2
    .byte EFFECT_ACCURACY_DOWN_2
    .byte EFFECT_EVASION_DOWN_2
    .byte EFFECT_POISON
    .byte EFFECT_PARALYZE
    .byte EFFECT_PAIN_SPLIT
    .byte EFFECT_CONVERSION_2
    .byte EFFECT_LOCK_ON
    .byte EFFECT_SPITE
    .byte EFFECT_PERISH_SONG
    .byte EFFECT_SWAGGER
    .byte EFFECT_FURY_CUTTER
    .byte EFFECT_ATTRACT
    .byte EFFECT_SAFEGUARD
    .byte EFFECT_PSYCH_UP
    .byte EFFECT_MIRROR_COAT
    .byte EFFECT_WILL_O_WISP
    .byte EFFECT_TICKLE
    .byte EFFECT_COSMIC_POWER
    .byte EFFECT_BULK_UP
    .byte EFFECT_CALM_MIND
    .byte EFFECT_DRAGON_DANCE
    .byte -1

AI_Unknown:
	if_target_is_ally AI_TryOnAlly
	if_not_effect EFFECT_SUNNY_DAY, AI_Unknown_End
	if_equal 0, AI_Unknown_End
	is_first_turn_for AI_USER
	if_equal 0, AI_Unknown_End
	score +5

AI_Unknown_End: @ 82DE308
	end

AI_Roaming:
	if_status2 AI_USER, STATUS2_WRAPPED, AI_Roaming_End
	if_status2 AI_USER, STATUS2_ESCAPE_PREVENTION, AI_Roaming_End
	get_ability AI_TARGET
	if_equal ABILITY_SHADOW_TAG, AI_Roaming_End
	get_ability AI_USER
	if_equal ABILITY_LEVITATE, AI_Roaming_Flee
	get_ability AI_TARGET
	if_equal ABILITY_ARENA_TRAP, AI_Roaming_End

AI_Roaming_Flee: @ 82DE335
	flee

AI_Roaming_End: @ 82DE336
	end

AI_Safari:
	if_random_safari_flee AI_Safari_Flee
	watch

AI_Safari_Flee:
	flee

AI_FirstBattle:
	if_hp_equal AI_TARGET, 20, AI_FirstBattle_Flee
	if_hp_less_than AI_TARGET, 20, AI_FirstBattle_Flee
	end

AI_FirstBattle_Flee:
	flee

AI_Ret:
	end
