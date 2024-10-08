#include "global.h"
#include "malloc.h"
#include "battle.h"
#include "battle_anim.h"
#include "battle_ai_script_commands.h"
#include "battle_factory.h"
#include "battle_setup.h"
#include "data.h"
#include "event_data.h"
#include "item.h"
#include "pokemon.h"
#include "random.h"
#include "recorded_battle.h"
#include "util.h"
#include "constants/abilities.h"
#include "constants/battle_ai.h"
#include "constants/battle_move_effects.h"
#include "constants/hold_effects.h"
#include "constants/moves.h"
#include "constants/species.h"

#define AI_ACTION_DONE          0x0001
#define AI_ACTION_FLEE          0x0002
#define AI_ACTION_WATCH         0x0004
#define AI_ACTION_DO_NOT_ATTACK 0x0008
#define AI_ACTION_UNK5          0x0010
#define AI_ACTION_UNK6          0x0020
#define AI_ACTION_UNK7          0x0040
#define AI_ACTION_UNK8          0x0080

#define AI_THINKING_STRUCT ((struct AI_ThinkingStruct *)(gBattleResources->ai))
#define BATTLE_HISTORY (gBattleResources->battleHistory)
#define BATTLE_HISTORY_USED_MOVES(battler) (gBattleResources->battleHistory->usedMoves[GET_BATTLER_SIDE2(battler)][gBattlerPartyIndexes[battler]])

// AI states
enum
{
    AIState_SettingUp,
    AIState_Processing,
    AIState_FinishedProcessing,
    AIState_DoNotProcess
};

/*
gAIScriptPtr is a pointer to the next battle AI cmd command to read.
when a command finishes processing, gAIScriptPtr is incremented by
the number of bytes that the current command had reserved for arguments
in order to read the next command correctly. refer to battle_ai_scripts.s for the
AI scripts.
*/

extern const u8 *const gBattleAI_ScriptsTable[];

static u8 ChooseMoveOrAction_Singles(void);
static u8 ChooseMoveOrAction_Doubles(void);
static void BattleAI_DoAIProcessing(void);
static void AIStackPushVar(const u8 *);
static bool8 AIStackPop(void);
static s32 CountUsablePartyMons(u8 battlerId);
static s32 AI_GetAbility(u32 battlerId, bool32 guess);

static void Cmd_if_random_less_than(void);
static void Cmd_if_random_greater_than(void);
static void Cmd_if_random_equal(void);
static void Cmd_if_random_not_equal(void);
static void Cmd_score(void);
static void Cmd_if_hp_less_than(void);
static void Cmd_if_hp_more_than(void);
static void Cmd_if_hp_equal(void);
static void Cmd_if_hp_not_equal(void);
static void Cmd_if_status(void);
static void Cmd_if_not_status(void);
static void Cmd_if_status2(void);
static void Cmd_if_not_status2(void);
static void Cmd_if_status3(void);
static void Cmd_if_not_status3(void);
static void Cmd_if_side_affecting(void);
static void Cmd_if_not_side_affecting(void);
static void Cmd_if_less_than(void);
static void Cmd_if_more_than(void);
static void Cmd_if_equal(void);
static void Cmd_if_not_equal(void);
static void Cmd_if_less_than_ptr(void);
static void Cmd_if_more_than_ptr(void);
static void Cmd_if_equal_ptr(void);
static void Cmd_if_not_equal_ptr(void);
static void Cmd_if_move(void);
static void Cmd_if_not_move(void);
static void Cmd_if_in_bytes(void);
static void Cmd_if_not_in_bytes(void);
static void Cmd_if_in_hwords(void);
static void Cmd_if_not_in_hwords(void);
static void Cmd_if_user_has_attacking_move(void);
static void Cmd_if_user_has_no_attacking_moves(void);
static void Cmd_get_turn_count(void);
static void Cmd_get_type(void);
static void Cmd_get_considered_move_power(void);
static void Cmd_get_how_powerful_move_is(void);
static void Cmd_get_last_used_battler_move(void);
static void Cmd_if_equal_u32(void);
static void Cmd_if_not_equal_u32(void);
static void Cmd_if_user_goes(void);
static void Cmd_if_cant_use_belch(void);
static void Cmd_has_priority_move(void);
static void Cmd_nullsub_2B(void);
static void Cmd_count_usable_party_mons(void);
static void Cmd_get_considered_move(void);
static void Cmd_get_considered_move_effect(void);
static void Cmd_get_ability(void);
static void Cmd_get_highest_type_effectiveness(void);
static void Cmd_if_type_effectiveness(void);
static void Cmd_nullsub_32(void);
static void Cmd_nullsub_33(void);
static void Cmd_if_status_in_party(void);
static void Cmd_if_status_not_in_party(void);
static void Cmd_get_weather(void);
static void Cmd_if_effect(void);
static void Cmd_if_not_effect(void);
static void Cmd_if_stat_level_less_than(void);
static void Cmd_if_stat_level_more_than(void);
static void Cmd_if_stat_level_equal(void);
static void Cmd_if_stat_level_not_equal(void);
static void Cmd_if_can_faint(void);
static void Cmd_if_cant_faint(void);
static void Cmd_if_has_move(void);
static void Cmd_if_doesnt_have_move(void);
static void Cmd_if_has_move_with_effect(void);
static void Cmd_if_doesnt_have_move_with_effect(void);
static void Cmd_if_any_move_disabled_or_encored(void);
static void Cmd_if_curr_move_disabled_or_encored(void);
static void Cmd_flee(void);
static void Cmd_if_random_safari_flee(void);
static void Cmd_watch(void);
static void Cmd_get_hold_effect(void);
static void Cmd_get_gender(void);
static void Cmd_is_first_turn_for(void);
static void Cmd_get_stockpile_count(void);
static void Cmd_is_double_battle(void);
static void Cmd_get_used_held_item(void);
static void Cmd_get_move_type_from_result(void);
static void Cmd_get_move_power_from_result(void);
static void Cmd_get_move_effect_from_result(void);
static void Cmd_get_protect_count(void);
static void Cmd_if_move_flag(void);
static void Cmd_if_field_status(void);
static void Cmd_get_move_accuracy(void);
static void Cmd_call_if_eq(void);
static void Cmd_call_if_move_flag(void);
static void Cmd_nullsub_57(void);
static void Cmd_call(void);
static void Cmd_goto(void);
static void Cmd_end(void);
static void Cmd_if_level_cond(void);
static void Cmd_if_target_taunted(void);
static void Cmd_if_target_not_taunted(void);
static void Cmd_check_ability(void);
static void Cmd_is_of_type(void);
static void Cmd_if_target_is_ally(void);
static void Cmd_if_flash_fired(void);
static void Cmd_if_holds_item(void);
static void Cmd_get_ally_chosen_move(void);
static void Cmd_if_has_no_attacking_moves(void);
static void Cmd_get_hazards_count(void);
static void Cmd_if_doesnt_hold_berry(void);
static void Cmd_if_share_type(void);
static void Cmd_if_cant_use_last_resort(void);
static void Cmd_if_has_move_with_split(void);
static void Cmd_if_has_no_move_with_split(void);
static void Cmd_if_physical_moves_unusable(void);
static void Cmd_if_ai_can_go_down(void);
static void Cmd_if_has_move_with_type(void);
static void Cmd_if_no_move_used(void);
static void Cmd_if_has_move_with_flag(void);
static void Cmd_if_battler_absent(void);
static void Cmd_is_grounded(void);
static void Cmd_get_best_dmg_hp_percent(void);
static void Cmd_get_curr_dmg_hp_percent(void);
static void Cmd_get_move_split_from_result(void);

// ewram
EWRAM_DATA const u8 *gAIScriptPtr = NULL;
EWRAM_DATA static u8 sBattler_AI = 0;

// const rom data
typedef void (*BattleAICmdFunc)(void);

static const BattleAICmdFunc sBattleAICmdTable[] =
{
    Cmd_if_random_less_than,                        // 0x0
    Cmd_if_random_greater_than,                     // 0x1
    Cmd_if_random_equal,                            // 0x2
    Cmd_if_random_not_equal,                        // 0x3
    Cmd_score,                                      // 0x4
    Cmd_if_hp_less_than,                            // 0x5
    Cmd_if_hp_more_than,                            // 0x6
    Cmd_if_hp_equal,                                // 0x7
    Cmd_if_hp_not_equal,                            // 0x8
    Cmd_if_status,                                  // 0x9
    Cmd_if_not_status,                              // 0xA
    Cmd_if_status2,                                 // 0xB
    Cmd_if_not_status2,                             // 0xC
    Cmd_if_status3,                                 // 0xD
    Cmd_if_not_status3,                             // 0xE
    Cmd_if_side_affecting,                          // 0xF
    Cmd_if_not_side_affecting,                      // 0x10
    Cmd_if_less_than,                               // 0x11
    Cmd_if_more_than,                               // 0x12
    Cmd_if_equal,                                   // 0x13
    Cmd_if_not_equal,                               // 0x14
    Cmd_if_less_than_ptr,                           // 0x15
    Cmd_if_more_than_ptr,                           // 0x16
    Cmd_if_equal_ptr,                               // 0x17
    Cmd_if_not_equal_ptr,                           // 0x18
    Cmd_if_move,                                    // 0x19
    Cmd_if_not_move,                                // 0x1A
    Cmd_if_in_bytes,                                // 0x1B
    Cmd_if_not_in_bytes,                            // 0x1C
    Cmd_if_in_hwords,                               // 0x1D
    Cmd_if_not_in_hwords,                           // 0x1E
    Cmd_if_user_has_attacking_move,                 // 0x1F
    Cmd_if_user_has_no_attacking_moves,             // 0x20
    Cmd_get_turn_count,                             // 0x21
    Cmd_get_type,                                   // 0x22
    Cmd_get_considered_move_power,                  // 0x23
    Cmd_get_how_powerful_move_is,                   // 0x24
    Cmd_get_last_used_battler_move,                 // 0x25
    Cmd_if_equal_u32,                               // 0x26
    Cmd_if_not_equal_u32,                           // 0x27
    Cmd_if_user_goes,                               // 0x28
    Cmd_if_cant_use_belch,                          // 0x29
    Cmd_has_priority_move,                          // 0x2A
    Cmd_nullsub_2B,                                 // 0x2B
    Cmd_count_usable_party_mons,                    // 0x2C
    Cmd_get_considered_move,                        // 0x2D
    Cmd_get_considered_move_effect,                 // 0x2E
    Cmd_get_ability,                                // 0x2F
    Cmd_get_highest_type_effectiveness,             // 0x30
    Cmd_if_type_effectiveness,                      // 0x31
    Cmd_nullsub_32,                                 // 0x32
    Cmd_nullsub_33,                                 // 0x33
    Cmd_if_status_in_party,                         // 0x34
    Cmd_if_status_not_in_party,                     // 0x35
    Cmd_get_weather,                                // 0x36
    Cmd_if_effect,                                  // 0x37
    Cmd_if_not_effect,                              // 0x38
    Cmd_if_stat_level_less_than,                    // 0x39
    Cmd_if_stat_level_more_than,                    // 0x3A
    Cmd_if_stat_level_equal,                        // 0x3B
    Cmd_if_stat_level_not_equal,                    // 0x3C
    Cmd_if_can_faint,                               // 0x3D
    Cmd_if_cant_faint,                              // 0x3E
    Cmd_if_has_move,                                // 0x3F
    Cmd_if_doesnt_have_move,                        // 0x40
    Cmd_if_has_move_with_effect,                    // 0x41
    Cmd_if_doesnt_have_move_with_effect,            // 0x42
    Cmd_if_any_move_disabled_or_encored,            // 0x43
    Cmd_if_curr_move_disabled_or_encored,           // 0x44
    Cmd_flee,                                       // 0x45
    Cmd_if_random_safari_flee,                      // 0x46
    Cmd_watch,                                      // 0x47
    Cmd_get_hold_effect,                            // 0x48
    Cmd_get_gender,                                 // 0x49
    Cmd_is_first_turn_for,                          // 0x4A
    Cmd_get_stockpile_count,                        // 0x4B
    Cmd_is_double_battle,                           // 0x4C
    Cmd_get_used_held_item,                         // 0x4D
    Cmd_get_move_type_from_result,                  // 0x4E
    Cmd_get_move_power_from_result,                 // 0x4F
    Cmd_get_move_effect_from_result,                // 0x50
    Cmd_get_protect_count,                          // 0x51
    Cmd_if_move_flag,                               // 0x52
    Cmd_if_field_status,                            // 0x53
    Cmd_get_move_accuracy,                          // 0x54
    Cmd_call_if_eq,                                 // 0x55
    Cmd_call_if_move_flag,                          // 0x56
    Cmd_nullsub_57,                                 // 0x57
    Cmd_call,                                       // 0x58
    Cmd_goto,                                       // 0x59
    Cmd_end,                                        // 0x5A
    Cmd_if_level_cond,                              // 0x5B
    Cmd_if_target_taunted,                          // 0x5C
    Cmd_if_target_not_taunted,                      // 0x5D
    Cmd_if_target_is_ally,                          // 0x5E
    Cmd_is_of_type,                                 // 0x5F
    Cmd_check_ability,                              // 0x60
    Cmd_if_flash_fired,                             // 0x61
    Cmd_if_holds_item,                              // 0x62
    Cmd_get_ally_chosen_move,                       // 0x63
    Cmd_if_has_no_attacking_moves,                  // 0x64
    Cmd_get_hazards_count,                          // 0x65
    Cmd_if_doesnt_hold_berry,                       // 0x66
    Cmd_if_share_type,                              // 0x67
    Cmd_if_cant_use_last_resort,                    // 0x68
    Cmd_if_has_move_with_split,                     // 0x69
    Cmd_if_has_no_move_with_split,                  // 0x6A
    Cmd_if_physical_moves_unusable,                 // 0x6B
    Cmd_if_ai_can_go_down,                          // 0x6C
    Cmd_if_has_move_with_type,                      // 0x6D
    Cmd_if_no_move_used,                            // 0x6E
    Cmd_if_has_move_with_flag,                      // 0x6F
    Cmd_if_battler_absent,                          // 0x70
    Cmd_is_grounded,                                // 0x71
    Cmd_get_best_dmg_hp_percent,                    // 0x72
    Cmd_get_curr_dmg_hp_percent,                    // 0x73
    Cmd_get_move_split_from_result,                 // 0x74
};

static const u16 sDiscouragedPowerfulMoveEffects[] =
{
    EFFECT_EXPLOSION,
    EFFECT_DREAM_EATER,
    EFFECT_RECHARGE,
    EFFECT_SKULL_BASH,
    EFFECT_SOLARBEAM,
    EFFECT_SPIT_UP,
    EFFECT_FOCUS_PUNCH,
    EFFECT_SUPERPOWER,
    EFFECT_ERUPTION,
    EFFECT_OVERHEAT,
    0xFFFF
};

// code
void BattleAI_SetupItems(void)
{
    s32 i;
    u8 *data = (u8 *)BATTLE_HISTORY;

    for (i = 0; i < sizeof(struct BattleHistory); i++)
        data[i] = 0;

    // Items are allowed to use in ONLY trainer battles.
    if ((gBattleTypeFlags & BATTLE_TYPE_TRAINER)
        && !(gBattleTypeFlags & (BATTLE_TYPE_LINK | BATTLE_TYPE_SAFARI | BATTLE_TYPE_BATTLE_TOWER
                               | BATTLE_TYPE_EREADER_TRAINER | BATTLE_TYPE_SECRET_BASE | BATTLE_TYPE_FRONTIER
                               | BATTLE_TYPE_INGAME_PARTNER | BATTLE_TYPE_x2000000)
            )
       )
    {
        for (i = 0; i < MAX_TRAINER_ITEMS; i++)
        {
            if (gTrainers[gTrainerBattleOpponent_A].items[i] != 0)
            {
                BATTLE_HISTORY->trainerItems[BATTLE_HISTORY->itemsNo] = gTrainers[gTrainerBattleOpponent_A].items[i];
                BATTLE_HISTORY->itemsNo++;
            }
        }
    }
}

void BattleAI_SetupFlags(void)
{
    if (gBattleTypeFlags & BATTLE_TYPE_RECORDED)
        AI_THINKING_STRUCT->aiFlags = GetAiScriptsInRecordedBattle();
    else if (gBattleTypeFlags & BATTLE_TYPE_SAFARI)
        AI_THINKING_STRUCT->aiFlags = AI_SCRIPT_SAFARI;
    else if (gBattleTypeFlags & BATTLE_TYPE_ROAMER)
        AI_THINKING_STRUCT->aiFlags = AI_SCRIPT_ROAMING;
    else if (gBattleTypeFlags & BATTLE_TYPE_FIRST_BATTLE)
        AI_THINKING_STRUCT->aiFlags = AI_SCRIPT_FIRST_BATTLE;
    else if (gBattleTypeFlags & BATTLE_TYPE_FACTORY)
        AI_THINKING_STRUCT->aiFlags = GetAiScriptsInBattleFactory();
    else if (gBattleTypeFlags & (BATTLE_TYPE_FRONTIER | BATTLE_TYPE_EREADER_TRAINER | BATTLE_TYPE_TRAINER_HILL | BATTLE_TYPE_SECRET_BASE))
        AI_THINKING_STRUCT->aiFlags = AI_SCRIPT_CHECK_BAD_MOVE | AI_SCRIPT_CHECK_VIABILITY | AI_SCRIPT_TRY_TO_FAINT | AI_SCRIPT_HP_AWARE;
    else if (gBattleTypeFlags & BATTLE_TYPE_TWO_OPPONENTS)
        AI_THINKING_STRUCT->aiFlags = gTrainers[gTrainerBattleOpponent_A].aiFlags | gTrainers[gTrainerBattleOpponent_B].aiFlags;
    else
        AI_THINKING_STRUCT->aiFlags = gTrainers[gTrainerBattleOpponent_A].aiFlags;

    // If difficulty is set to hard, make all trainer AI smart
    if (FlagGet(FLAG_ADVENTURE_STARTED) && GAME_DIFFICULTY > 1
    && (gBattleTypeFlags & BATTLE_TYPE_TRAINER) && !(gBattleTypeFlags & (BATTLE_TYPE_RECORDED | BATTLE_TYPE_FACTORY)))
        AI_THINKING_STRUCT->aiFlags |= AI_SCRIPT_CHECK_BAD_MOVE | AI_SCRIPT_CHECK_VIABILITY | AI_SCRIPT_TRY_TO_FAINT | AI_SCRIPT_HP_AWARE;

    if (gBattleTypeFlags & (BATTLE_TYPE_DOUBLE | BATTLE_TYPE_TWO_OPPONENTS) || gTrainers[gTrainerBattleOpponent_A].doubleBattle)
        AI_THINKING_STRUCT->aiFlags |= AI_SCRIPT_DOUBLE_BATTLE; // Act smart in doubles and don't attack your partner.
}

void BattleAI_SetupAIData(u8 defaultScoreMoves)
{
    s32 i, move, dmg;
    u8 moveLimitations;

    // Clear AI data but preserve the flags.
    u32 flags = AI_THINKING_STRUCT->aiFlags;
    memset(AI_THINKING_STRUCT, 0, sizeof(struct AI_ThinkingStruct));
    AI_THINKING_STRUCT->aiFlags = flags;

    // Conditional score reset, unlike Ruby.
    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (defaultScoreMoves & 1)
            AI_THINKING_STRUCT->score[i] = 100;
        else
            AI_THINKING_STRUCT->score[i] = 0;

        defaultScoreMoves >>= 1;
    }

    moveLimitations = CheckMoveLimitations(gActiveBattler, 0, 0xFF);

    // Ignore moves that aren't possible to use.
    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (gBitTable[i] & moveLimitations)
            AI_THINKING_STRUCT->score[i] = 0;
    }

    gBattleResources->AI_ScriptsStack->size = 0;
    sBattler_AI = gActiveBattler;

    // Simulate dmg for all AI moves against all opposing targets
    for (gBattlerTarget = 0; gBattlerTarget < gBattlersCount; gBattlerTarget++)
    {
        if (GET_BATTLER_SIDE2(sBattler_AI) == GET_BATTLER_SIDE2(gBattlerTarget))
            continue;
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            dmg = 0;
            move = gBattleMons[sBattler_AI].moves[i];
            if (gBattleMoves[move].power != 0 && !(moveLimitations & gBitTable[i]))
            {
                dmg = AI_CalcDamage(move, sBattler_AI, gBattlerTarget) * (100 - (Random() % 10)) / 100;
                if (dmg == 0)
                    dmg = 1;
            }

            AI_THINKING_STRUCT->simulatedDmg[sBattler_AI][gBattlerTarget][i] = dmg;
        }
    }

    gBattlerTarget = SetRandomTarget(sBattler_AI);
}

void BattleAI_InitKnownMovesAndAbility(struct Pokemon* party, u8 partyIndex)
{
    // We're initializing the known moves list for every mon with the move set
    // it would know if it was encountered in the wild at that level.
    // This gives the AI some idea of what the opponent mon is capable of
    int i, j, k;
    for (i = 0; i < PARTY_SIZE; i++)
    {
        u16 species = GetMonData(&party[i], MON_DATA_SPECIES_EGG);
        u8 typeMove1Slot = 0xFF;
        u8 typeMove2Slot = 0xFF;

        if (species == SPECIES_NONE || species == SPECIES_EGG)
            continue;

        // Init random ability
        if (gBaseStats[species].abilities[2] != ABILITY_NONE)
            BATTLE_HISTORY->abilities[partyIndex][i] = gBaseStats[species].abilities[Random() % 3];
        else
            BATTLE_HISTORY->abilities[partyIndex][i] = gBaseStats[species].abilities[Random() & 1];

        // Init moves
        k = 0;
        for (j = 0; gLevelUpLearnsets[species][j].move != LEVEL_UP_END; j++)
        {
            u16 move = gLevelUpLearnsets[species][j].move;
            if (gLevelUpLearnsets[species][j].level > party[i].level)
                break;
            // Moves with the same typing as the pokemon are prioritized
            if (gBattleMoves[move].power > 0 && gBattleMoves[move].type == gBaseStats[species].type1)
            {
                if (typeMove1Slot == 0xFF || gBattleMoves[move].power > gBattleMoves[BATTLE_HISTORY->usedMoves[partyIndex][i].moves[typeMove1Slot]].power)
                {
                    typeMove1Slot = typeMove1Slot == 0xFF ? k : typeMove1Slot;
                    BATTLE_HISTORY->usedMoves[partyIndex][i].moves[typeMove1Slot] = move;
                    k++;
                }
            }
            else if (gBattleMoves[move].power > 0 && gBattleMoves[move].type == gBaseStats[species].type2)
            {
                if (typeMove2Slot == 0xFF || gBattleMoves[move].power > gBattleMoves[BATTLE_HISTORY->usedMoves[partyIndex][i].moves[typeMove2Slot]].power)
                {
                    typeMove2Slot = typeMove2Slot == 0xFF ? k : typeMove2Slot;
                    BATTLE_HISTORY->usedMoves[partyIndex][i].moves[typeMove2Slot] = move;
                    k++;
                }
            }
            else
            {
                while (k == typeMove1Slot || k == typeMove2Slot)
                    k = ++k % MAX_MON_MOVES;
                BATTLE_HISTORY->usedMoves[partyIndex][i].moves[k++] = move;
            }
            k = k % MAX_MON_MOVES;
        }
    }
}

void BattleAI_UpdateKnownMoves(u8 battlerId, u16 battlerMove)
{
    u8 i;
    u8 freeSlot = 0xFF;
    u8 type = gBattleMoves[battlerMove].type;
    u8 power = gBattleMoves[battlerMove].power;
    u8 sameType = FALSE;
    u16 freeSlotMove;
    // If all moves are confirmed already, return
    if (BATTLE_HISTORY_USED_MOVES(battlerId).confirmed >= (1 << MAX_MON_MOVES) - 1)
        return;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        u16 move = BATTLE_HISTORY_USED_MOVES(battlerId).moves[i];
        bool8 confirmed = BATTLE_HISTORY_USED_MOVES(battlerId).confirmed & (1 << i);
        if (move == battlerMove)
        {
            if (confirmed)
                return;
            freeSlot = i;
            break;
        }
        if (confirmed)
            continue;

        if (freeSlot == 0xFF)
        {
            freeSlot = i;
            freeSlotMove = move;
        }
        else if (gBattleMoves[move].type == type && power > 0 && gBattleMoves[move].power > 0)
        {
            // Prefer to replace same type non status move
            if (!sameType || gBattleMoves[move].power < gBattleMoves[freeSlotMove].power)
            {
                freeSlot = i;
                freeSlotMove = move;
                sameType = TRUE;
            }
        }
        else if (!sameType && gBattleMoves[move].power <= gBattleMoves[freeSlotMove].power)
        {
            // Prefer to replace weakest move
            freeSlot = i;
            freeSlotMove = move;
        }
    }
    if (freeSlot != 0xFF)
    {
        BATTLE_HISTORY_USED_MOVES(battlerId).confirmed |= 1 << freeSlot;
        BATTLE_HISTORY_USED_MOVES(battlerId).moves[freeSlot] = battlerMove;
    }
}

u8 BattleAI_ChooseMoveOrAction(void)
{
    u16 savedCurrentMove = gCurrentMove;
    u8 ret;

    if (!(gBattleTypeFlags & BATTLE_TYPE_DOUBLE))
        ret = ChooseMoveOrAction_Singles();
    else
        ret = ChooseMoveOrAction_Doubles();

    gCurrentMove = savedCurrentMove;
    return ret;
}

static u32 GetTotalBaseStat(u32 species)
{
    return gBaseStats[species].baseHP
        + gBaseStats[species].baseAttack
        + gBaseStats[species].baseDefense
        + gBaseStats[species].baseSpeed
        + gBaseStats[species].baseSpAttack
        + gBaseStats[species].baseSpDefense;
}

bool32 IsTruantMonVulnerable(u32 battlerAI, u32 opposingBattler)
{
    int i;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        u32 move = BATTLE_HISTORY_USED_MOVES(opposingBattler).moves[i];
        if (gBattleMoves[move].effect == EFFECT_PROTECT && move != MOVE_ENDURE)
            return TRUE;
        if (gBattleMoves[move].effect == EFFECT_SEMI_INVULNERABLE && GetWhoStrikesFirst(battlerAI, opposingBattler, TRUE) == 1)
            return TRUE;
    }
    return FALSE;
}

static u8 ChooseMoveOrAction_Singles(void)
{
    u8 currentMoveArray[MAX_MON_MOVES];
    u8 consideredMoveArray[MAX_MON_MOVES];
    u8 numOfBestMoves;
    s32 i, id;
    u32 flags = AI_THINKING_STRUCT->aiFlags;

    while (flags != 0)
    {
        if (flags & 1)
        {
            AI_THINKING_STRUCT->aiState = AIState_SettingUp;
            BattleAI_DoAIProcessing();
        }
        flags >>= 1;
        AI_THINKING_STRUCT->aiLogicId++;
        AI_THINKING_STRUCT->movesetIndex = 0;
    }

    // Check special AI actions.
    if (AI_THINKING_STRUCT->aiAction & AI_ACTION_FLEE)
        return AI_CHOICE_FLEE;
    if (AI_THINKING_STRUCT->aiAction & AI_ACTION_WATCH)
        return AI_CHOICE_WATCH;

    gActiveBattler = sBattler_AI;
    // If can switch.
    if (CountUsablePartyMons(sBattler_AI) >= 1
        && !IsAbilityPreventingEscape(sBattler_AI)
        && !(gBattleMons[gActiveBattler].status2 & (STATUS2_WRAPPED | STATUS2_ESCAPE_PREVENTION))
        && !(gStatuses3[gActiveBattler] & STATUS3_ROOTED)
        && !(gBattleTypeFlags & (BATTLE_TYPE_ARENA | BATTLE_TYPE_PALACE))
        && AI_THINKING_STRUCT->aiFlags & (AI_SCRIPT_CHECK_VIABILITY | AI_SCRIPT_CHECK_BAD_MOVE | AI_SCRIPT_TRY_TO_FAINT | AI_SCRIPT_PREFER_BATON_PASS))
    {
        // Consider switching if all moves are worthless to use.
        if (GetTotalBaseStat(gBattleMons[sBattler_AI].species) >= 310 // Mon is not weak.
            && gBattleMons[sBattler_AI].hp >= gBattleMons[sBattler_AI].maxHP / 2)
        {
            s32 cap = AI_THINKING_STRUCT->aiFlags & (AI_SCRIPT_CHECK_VIABILITY) ? 95 : 93;
            for (i = 0; i < MAX_MON_MOVES; i++)
            {
                if (AI_THINKING_STRUCT->score[i] > cap)
                    break;
            }

            if (i == MAX_MON_MOVES && GetMostSuitableMonToSwitchInto() != PARTY_SIZE)
            {
                AI_THINKING_STRUCT->switchMon = TRUE;
                return AI_CHOICE_SWITCH;
            }
        }

        // Consider switching if your mon with truant is bodied by Protect spam.
        // Or is using a double turn semi invulnerable move(such as Fly) and is faster.
        if (GetBattlerAbility(sBattler_AI) == ABILITY_TRUANT
            && IsTruantMonVulnerable(sBattler_AI, gBattlerTarget)
            && gDisableStructs[sBattler_AI].truantCounter
            && gBattleMons[sBattler_AI].hp >= gBattleMons[sBattler_AI].maxHP / 2)
        {
            if (GetMostSuitableMonToSwitchInto() != PARTY_SIZE)
            {
                AI_THINKING_STRUCT->switchMon = TRUE;
                return AI_CHOICE_SWITCH;
            }
        }
    }

    numOfBestMoves = 1;
    currentMoveArray[0] = AI_THINKING_STRUCT->score[0];
    consideredMoveArray[0] = 0;

    for (i = 1; i < MAX_MON_MOVES; i++)
    {
        if (gBattleMons[sBattler_AI].moves[i] != MOVE_NONE)
        {
            // In ruby, the order of these if statements is reversed.
            if (currentMoveArray[0] == AI_THINKING_STRUCT->score[i])
            {
                currentMoveArray[numOfBestMoves] = AI_THINKING_STRUCT->score[i];
                consideredMoveArray[numOfBestMoves++] = i;
            }
            if (currentMoveArray[0] < AI_THINKING_STRUCT->score[i])
            {
                numOfBestMoves = 1;
                currentMoveArray[0] = AI_THINKING_STRUCT->score[i];
                consideredMoveArray[0] = i;
            }
        }
    }
    return consideredMoveArray[Random() % numOfBestMoves];
}

static u8 ChooseMoveOrAction_Doubles(void)
{
    s32 i, j;
    u32 flags;
    s16 bestMovePointsForTarget[MAX_BATTLERS_COUNT];
    s8 mostViableTargetsArray[MAX_BATTLERS_COUNT];
    u8 actionOrMoveIndex[MAX_BATTLERS_COUNT];
    u8 mostViableMovesScores[MAX_MON_MOVES];
    u8 mostViableMovesIndices[MAX_MON_MOVES];
    s32 mostViableTargetsNo;
    s32 mostViableMovesNo;
    s16 mostMovePoints;

    for (i = 0; i < MAX_BATTLERS_COUNT; i++)
    {
        if (i == sBattler_AI || gBattleMons[i].hp == 0)
        {
            actionOrMoveIndex[i] = 0xFF;
            bestMovePointsForTarget[i] = -1;
        }
        else
        {
            if (gBattleTypeFlags & BATTLE_TYPE_PALACE)
                BattleAI_SetupAIData(gBattleStruct->field_92 >> 4);
            else
                BattleAI_SetupAIData(0xF);

            gBattlerTarget = i;

            AI_THINKING_STRUCT->aiLogicId = 0;
            AI_THINKING_STRUCT->movesetIndex = 0;
            flags = AI_THINKING_STRUCT->aiFlags;
            while (flags != 0)
            {
                if (flags & 1)
                {
                    AI_THINKING_STRUCT->aiState = AIState_SettingUp;
                    BattleAI_DoAIProcessing();
                }
                flags >>= 1;
                AI_THINKING_STRUCT->aiLogicId++;
                AI_THINKING_STRUCT->movesetIndex = 0;
            }

            if (AI_THINKING_STRUCT->aiAction & AI_ACTION_FLEE)
            {
                actionOrMoveIndex[i] = AI_CHOICE_FLEE;
            }
            else if (AI_THINKING_STRUCT->aiAction & AI_ACTION_WATCH)
            {
                actionOrMoveIndex[i] = AI_CHOICE_WATCH;
            }
            else
            {
                mostViableMovesScores[0] = AI_THINKING_STRUCT->score[0];
                mostViableMovesIndices[0] = 0;
                mostViableMovesNo = 1;
                for (j = 1; j < MAX_MON_MOVES; j++)
                {
                    if (gBattleMons[sBattler_AI].moves[j] != 0)
                    {
                        if (mostViableMovesScores[0] == AI_THINKING_STRUCT->score[j])
                        {
                            mostViableMovesScores[mostViableMovesNo] = AI_THINKING_STRUCT->score[j];
                            mostViableMovesIndices[mostViableMovesNo] = j;
                            mostViableMovesNo++;
                        }
                        if (mostViableMovesScores[0] < AI_THINKING_STRUCT->score[j])
                        {
                            mostViableMovesScores[0] = AI_THINKING_STRUCT->score[j];
                            mostViableMovesIndices[0] = j;
                            mostViableMovesNo = 1;
                        }
                    }
                }
                actionOrMoveIndex[i] = mostViableMovesIndices[Random() % mostViableMovesNo];
                bestMovePointsForTarget[i] = mostViableMovesScores[0];

                // Don't use a move against ally if it has less than 100 points.
                if (i == (sBattler_AI ^ BIT_FLANK) && bestMovePointsForTarget[i] < 100)
                {
                    bestMovePointsForTarget[i] = -1;
                    mostViableMovesScores[0] = mostViableMovesScores[0]; // Needed to match.
                }
            }
        }
    }

    mostMovePoints = bestMovePointsForTarget[0];
    mostViableTargetsArray[0] = 0;
    mostViableTargetsNo = 1;

    for (i = 1; i < MAX_BATTLERS_COUNT; i++)
    {
        if (mostMovePoints == bestMovePointsForTarget[i])
        {
            mostViableTargetsArray[mostViableTargetsNo] = i;
            mostViableTargetsNo++;
        }
        if (mostMovePoints < bestMovePointsForTarget[i])
        {
            mostMovePoints = bestMovePointsForTarget[i];
            mostViableTargetsArray[0] = i;
            mostViableTargetsNo = 1;
        }
    }

    gBattlerTarget = mostViableTargetsArray[Random() % mostViableTargetsNo];
    return actionOrMoveIndex[gBattlerTarget];
}

static void BattleAI_DoAIProcessing(void)
{
    while (AI_THINKING_STRUCT->aiState != AIState_FinishedProcessing)
    {
        switch (AI_THINKING_STRUCT->aiState)
        {
            case AIState_DoNotProcess: // Needed to match.
                break;
            case AIState_SettingUp:
                gAIScriptPtr = gBattleAI_ScriptsTable[AI_THINKING_STRUCT->aiLogicId]; // set AI ptr to logic ID.
                if (gBattleMons[sBattler_AI].pp[AI_THINKING_STRUCT->movesetIndex] == 0)
                {
                    AI_THINKING_STRUCT->moveConsidered = 0;
                }
                else
                {
                    AI_THINKING_STRUCT->moveConsidered = gBattleMons[sBattler_AI].moves[AI_THINKING_STRUCT->movesetIndex];
                }
                AI_THINKING_STRUCT->aiState++;
                break;
            case AIState_Processing:
                if (AI_THINKING_STRUCT->moveConsidered != 0)
                {
                    sBattleAICmdTable[*gAIScriptPtr](); // Run AI command.
                }
                else
                {
                    AI_THINKING_STRUCT->score[AI_THINKING_STRUCT->movesetIndex] = 0;
                    AI_THINKING_STRUCT->aiAction |= AI_ACTION_DONE;
                }
                if (AI_THINKING_STRUCT->aiAction & AI_ACTION_DONE)
                {
                   AI_THINKING_STRUCT->movesetIndex++;

                    if (AI_THINKING_STRUCT->movesetIndex < MAX_MON_MOVES && !(AI_THINKING_STRUCT->aiAction & AI_ACTION_DO_NOT_ATTACK))
                        AI_THINKING_STRUCT->aiState = AIState_SettingUp;
                    else
                        AI_THINKING_STRUCT->aiState++;

                    AI_THINKING_STRUCT->aiAction &= ~(AI_ACTION_DONE);
                }
                break;
        }
    }
}

static bool32 IsBattlerAIControlled(u32 battlerId)
{
    switch (GetBattlerPosition(battlerId))
    {
    case B_POSITION_PLAYER_LEFT:
    default:
        return FALSE;
    case B_POSITION_OPPONENT_LEFT:
        return TRUE;
    case B_POSITION_PLAYER_RIGHT:
        if (gBattleTypeFlags & BATTLE_TYPE_INGAME_PARTNER)
            return FALSE;
        else
            return TRUE;
    case B_POSITION_OPPONENT_RIGHT:
        return TRUE;
    }
}

void RecordAbilityBattle(u8 battlerId, u8 abilityId)
{
    BATTLE_HISTORY->abilities[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]] = abilityId;
}

void RecordItemEffectBattle(u8 battlerId, u8 itemEffect)
{
    BATTLE_HISTORY->itemEffects[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]] = itemEffect;
}

static void SaveBattlerData(u8 battlerId)
{
    if (!IsBattlerAIControlled(battlerId))
    {
        u32 i;

        AI_THINKING_STRUCT->saved[battlerId].ability = gBattleMons[battlerId].ability;
        AI_THINKING_STRUCT->saved[battlerId].heldItem = gBattleMons[battlerId].item;
        AI_THINKING_STRUCT->saved[battlerId].species = gBattleMons[battlerId].species;
        for (i = 0; i < 4; i++)
            AI_THINKING_STRUCT->saved[battlerId].moves[i] = gBattleMons[battlerId].moves[i];
    }
}

static void SetBattlerData(u8 battlerId)
{
    if (!IsBattlerAIControlled(battlerId))
    {
        struct Pokemon *illusionMon;
        u32 i;

        // Use the known battler's ability.
        if (BATTLE_HISTORY->abilities[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]] != ABILITY_NONE)
            gBattleMons[battlerId].ability = BATTLE_HISTORY->abilities[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]];
        // Check if mon can only have one ability.
        else if (gBaseStats[gBattleMons[battlerId].species].abilities[1] == gBaseStats[gBattleMons[battlerId].species].abilities[0])
            gBattleMons[battlerId].ability = gBaseStats[gBattleMons[battlerId].species].abilities[0];
        // The ability is unknown.
        else
            gBattleMons[battlerId].ability = ABILITY_NONE;

        if (BATTLE_HISTORY->itemEffects[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]] == 0)
            gBattleMons[battlerId].item = 0;

        for (i = 0; i < 4; i++)
        {
            if (BATTLE_HISTORY_USED_MOVES(battlerId).moves[i] == 0)
                gBattleMons[battlerId].moves[i] = 0;
        }

        // Simulate Illusion
        if ((illusionMon = GetIllusionMonPtr(battlerId)) != NULL)
            gBattleMons[battlerId].species = GetMonData(illusionMon, MON_DATA_SPECIES_EGG);
    }
}

static void RestoreBattlerData(u8 battlerId)
{
    if (!IsBattlerAIControlled(battlerId))
    {
        u32 i;

        gBattleMons[battlerId].ability = AI_THINKING_STRUCT->saved[battlerId].ability;
        gBattleMons[battlerId].item = AI_THINKING_STRUCT->saved[battlerId].heldItem;
        gBattleMons[battlerId].species = AI_THINKING_STRUCT->saved[battlerId].species;
        for (i = 0; i < 4; i++)
            gBattleMons[battlerId].moves[i] = AI_THINKING_STRUCT->saved[battlerId].moves[i];
    }
}

static bool32 AI_GetIfCrit(u32 move, u8 battlerAtk, u8 battlerDef)
{
    bool32 isCrit;

    switch (CalcCritChanceStage(battlerAtk, battlerDef, move, FALSE))
    {
    case -1:
    case 0:
    default:
        isCrit = FALSE;
        break;
    case 1:
        if (gBattleMoves[move].flags & FLAG_HIGH_CRIT && (Random() % 5 == 0))
            isCrit = TRUE;
        else
            isCrit = FALSE;
        break;
    case 2:
        if (gBattleMoves[move].flags & FLAG_HIGH_CRIT && (Random() % 2 == 0))
            isCrit = TRUE;
        else if (!(gBattleMoves[move].flags & FLAG_HIGH_CRIT) && (Random() % 4) == 0)
            isCrit = TRUE;
        else
            isCrit = FALSE;
        break;
    case -2:
    case 3:
    case 4:
        isCrit = TRUE;
        break;
    }

    return isCrit;
}

s32 AI_CalcDamage(u16 move, u8 battlerAtk, u8 battlerDef)
{
    s32 dmg, moveType;
    u8 rolloutTimer, rolloutTimerStartValue;

    SaveBattlerData(battlerAtk);
    SaveBattlerData(battlerDef);

    SetBattlerData(battlerAtk);
    SetBattlerData(battlerDef);

    rolloutTimer = gDisableStructs[battlerAtk].rolloutTimer;
    rolloutTimerStartValue = gDisableStructs[battlerAtk].rolloutTimerStartValue;
    gDisableStructs[battlerAtk].rolloutTimer = 5; // calculate damage based on initial rollout value, since we're locked into it otherwise anyways
    gDisableStructs[battlerAtk].rolloutTimerStartValue = 5;

    gBattleStruct->dynamicMoveType = 0;
    SetTypeBeforeUsingMove(move, battlerAtk);
    GET_MOVE_TYPE(move, moveType);
    dmg = CalculateMoveDamage(move, battlerAtk, battlerDef, moveType, 0, AI_GetIfCrit(move, battlerAtk, battlerDef), FALSE, FALSE);

    gDisableStructs[battlerAtk].rolloutTimer = rolloutTimer;
    gDisableStructs[battlerAtk].rolloutTimerStartValue = rolloutTimerStartValue;

    RestoreBattlerData(battlerAtk);
    RestoreBattlerData(battlerDef);

    return dmg;
}

s32 AI_CalcPartyMonDamage(u16 move, u8 battlerAtk, u8 battlerDef, struct Pokemon *mon)
{
    s32 dmg;
    u32 i;
    struct BattlePokemon *battleMons = Alloc(sizeof(struct BattlePokemon) * MAX_BATTLERS_COUNT);

    for (i = 0; i < MAX_BATTLERS_COUNT; i++)
        battleMons[i] = gBattleMons[i];

    PokemonToBattleMon(mon, &gBattleMons[battlerAtk]);
    dmg = AI_CalcDamage(move, battlerAtk, battlerDef);

    for (i = 0; i < MAX_BATTLERS_COUNT; i++)
        gBattleMons[i] = battleMons[i];

    Free(battleMons);

    return dmg;
}

s32 AI_CalcDamageOnPartyMon(u16 move, u8 battlerAtk, u8 battlerDef, struct Pokemon *mon)
{
    s32 dmg;
    u32 i;
    struct BattlePokemon *battleMons = Alloc(sizeof(struct BattlePokemon) * MAX_BATTLERS_COUNT);

    for (i = 0; i < MAX_BATTLERS_COUNT; i++)
        battleMons[i] = gBattleMons[i];

    PokemonToBattleMon(mon, &gBattleMons[battlerDef]);
    dmg = AI_CalcDamage(move, battlerAtk, battlerDef);

    for (i = 0; i < MAX_BATTLERS_COUNT; i++)
        gBattleMons[i] = battleMons[i];

    Free(battleMons);

    return dmg;
}

u16 AI_GetTypeEffectiveness(u16 move, u8 battlerAtk, u8 battlerDef)
{
    u16 typeEffectiveness;

    SaveBattlerData(battlerAtk);
    SaveBattlerData(battlerDef);

    SetBattlerData(battlerAtk);
    SetBattlerData(battlerDef);

    typeEffectiveness = CalcTypeEffectivenessMultiplier(move, gBattleMoves[move].type, battlerAtk, battlerDef, FALSE);

    RestoreBattlerData(battlerAtk);
    RestoreBattlerData(battlerDef);

    return typeEffectiveness;
}

static void Cmd_if_random_less_than(void)
{
    u16 random = Random();

    if (random % 256 < gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_if_random_greater_than(void)
{
    u16 random = Random();

    if (random % 256 > gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_if_random_equal(void)
{
    u16 random = Random();

    if (random % 256 == gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_if_random_not_equal(void)
{
    u16 random = Random();

    if (random % 256 != gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_score(void)
{
    AI_THINKING_STRUCT->score[AI_THINKING_STRUCT->movesetIndex] += gAIScriptPtr[1]; // Add the result to the array of the move consider's score.

    if (AI_THINKING_STRUCT->score[AI_THINKING_STRUCT->movesetIndex] < 0) // If the score is negative, flatten it to 0.
        AI_THINKING_STRUCT->score[AI_THINKING_STRUCT->movesetIndex] = 0;

    gAIScriptPtr += 2; // AI return.
}

static u8 BattleAI_GetWantedBattler(u8 wantedBattler)
{
    switch (wantedBattler)
    {
    case AI_USER:
        return sBattler_AI;
    case AI_TARGET:
    default:
        return gBattlerTarget;
    case AI_USER_PARTNER:
        return sBattler_AI ^ BIT_FLANK;
    case AI_TARGET_PARTNER:
        return gBattlerTarget ^ BIT_FLANK;
    }
}

static void Cmd_if_hp_less_than(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if ((u32)(100 * gBattleMons[battlerId].hp / gBattleMons[battlerId].maxHP) < gAIScriptPtr[2])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_hp_more_than(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if ((u32)(100 * gBattleMons[battlerId].hp / gBattleMons[battlerId].maxHP) > gAIScriptPtr[2])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_hp_equal(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if ((u32)(100 * gBattleMons[battlerId].hp / gBattleMons[battlerId].maxHP) == gAIScriptPtr[2])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_hp_not_equal(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if ((u32)(100 * gBattleMons[battlerId].hp / gBattleMons[battlerId].maxHP) != gAIScriptPtr[2])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_status(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);

    if (gBattleMons[battlerId].status1 & status)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_not_status(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);

    if (!(gBattleMons[battlerId].status1 & status))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_status2(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);

    if ((gBattleMons[battlerId].status2 & status))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_not_status2(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);

    if (!(gBattleMons[battlerId].status2 & status))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_status3(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);

    if (gStatuses3[battlerId] & status)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_not_status3(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);

    if (!(gStatuses3[battlerId] & status))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_side_affecting(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);
    u32 side = GET_BATTLER_SIDE(battlerId);

    if (gSideStatuses[side] & status)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_not_side_affecting(void)
{
    u16 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 status = T1_READ_32(gAIScriptPtr + 2);
    u32 side = GET_BATTLER_SIDE(battlerId);

    if (!(gSideStatuses[side] & status))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
    else
        gAIScriptPtr += 10;
}

static void Cmd_if_less_than(void)
{
    if (AI_THINKING_STRUCT->funcResult < gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_if_more_than(void)
{
    if (AI_THINKING_STRUCT->funcResult > gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_if_equal(void)
{
    if (AI_THINKING_STRUCT->funcResult == gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_if_not_equal(void)
{
    if (AI_THINKING_STRUCT->funcResult != gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_if_less_than_ptr(void)
{
    const u8 *value = T1_READ_PTR(gAIScriptPtr + 1);

    if (AI_THINKING_STRUCT->funcResult < *value)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_if_more_than_ptr(void)
{
    const u8 *value = T1_READ_PTR(gAIScriptPtr + 1);

    if (AI_THINKING_STRUCT->funcResult > *value)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_if_equal_ptr(void)
{
    const u8 *value = T1_READ_PTR(gAIScriptPtr + 1);

    if (AI_THINKING_STRUCT->funcResult == *value)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_if_not_equal_ptr(void)
{
    const u8 *value = T1_READ_PTR(gAIScriptPtr + 1);

    if (AI_THINKING_STRUCT->funcResult != *value)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_if_move(void)
{
    u16 move = T1_READ_16(gAIScriptPtr + 1);

    if (AI_THINKING_STRUCT->moveConsidered == move)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_not_move(void)
{
    u16 move = T1_READ_16(gAIScriptPtr + 1);

    if (AI_THINKING_STRUCT->moveConsidered != move)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_in_bytes(void)
{
    const u8 *ptr = T1_READ_PTR(gAIScriptPtr + 1);

    while (*ptr != 0xFF)
    {
        if (AI_THINKING_STRUCT->funcResult == *ptr)
        {
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
            return;
        }
        ptr++;
    }
    gAIScriptPtr += 9;
}

static void Cmd_if_not_in_bytes(void)
{
    const u8 *ptr = T1_READ_PTR(gAIScriptPtr + 1);

    while (*ptr != 0xFF)
    {
        if (AI_THINKING_STRUCT->funcResult == *ptr)
        {
            gAIScriptPtr += 9;
            return;
        }
        ptr++;
    }
    gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
}

static void Cmd_if_in_hwords(void)
{
    const u16 *ptr = (const u16 *)T1_READ_PTR(gAIScriptPtr + 1);

    while (*ptr != 0xFFFF)
    {
        if (AI_THINKING_STRUCT->funcResult == *ptr)
        {
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
            return;
        }
        ptr++;
    }
    gAIScriptPtr += 9;
}

static void Cmd_if_not_in_hwords(void)
{
    const u16 *ptr = (const u16 *)T1_READ_PTR(gAIScriptPtr + 1);

    while (*ptr != 0xFFFF)
    {
        if (AI_THINKING_STRUCT->funcResult == *ptr)
        {
            gAIScriptPtr += 9;
            return;
        }
        ptr++;
    }
    gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
}

static void Cmd_if_user_has_attacking_move(void)
{
    s32 i;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (gBattleMons[sBattler_AI].moves[i] != 0
            && gBattleMoves[gBattleMons[sBattler_AI].moves[i]].power != 0)
            break;
    }

    if (i == MAX_MON_MOVES)
        gAIScriptPtr += 5;
    else
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
}

static void Cmd_if_user_has_no_attacking_moves(void)
{
    s32 i;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (gBattleMons[sBattler_AI].moves[i] != 0
         && gBattleMoves[gBattleMons[sBattler_AI].moves[i]].power != 0)
            break;
    }

    if (i != MAX_MON_MOVES)
        gAIScriptPtr += 5;
    else
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
}

static void Cmd_get_turn_count(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleResults.battleTurnCounter;
    gAIScriptPtr += 1;
}

static void Cmd_get_type(void)
{
    u8 typeVar = gAIScriptPtr[1];

    switch (typeVar)
    {
    case AI_TYPE1_USER: // AI user primary type
        AI_THINKING_STRUCT->funcResult = gBattleMons[sBattler_AI].type1;
        break;
    case AI_TYPE1_TARGET: // target primary type
        AI_THINKING_STRUCT->funcResult = gBattleMons[gBattlerTarget].type1;
        break;
    case AI_TYPE2_USER: // AI user secondary type
        AI_THINKING_STRUCT->funcResult = gBattleMons[sBattler_AI].type2;
        break;
    case AI_TYPE2_TARGET: // target secondary type
        AI_THINKING_STRUCT->funcResult = gBattleMons[gBattlerTarget].type2;
        break;
    case AI_TYPE_MOVE: // type of move being pointed to
        AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->moveConsidered].type;
        break;
    }
    gAIScriptPtr += 2;
}

static void Cmd_is_of_type(void)
{
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (IS_BATTLER_OF_TYPE(battlerId, gAIScriptPtr[2]))
        AI_THINKING_STRUCT->funcResult = TRUE;
    else
        AI_THINKING_STRUCT->funcResult = FALSE;

    gAIScriptPtr += 3;
}

static void Cmd_get_considered_move_power(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->moveConsidered].power;
    gAIScriptPtr += 1;
}

// Checks if the move dealing less damage does not have worse effects.
static bool32 CompareTwoMoves(u32 bestMove, u32 goodMove)
{
    s32 defAbility = AI_GetAbility(gBattlerTarget, FALSE);

    // Check if physical moves hurt.
    if (GetBattlerHoldEffect(sBattler_AI, TRUE) != HOLD_EFFECT_PROTECTIVE_PADS
        && (BATTLE_HISTORY->itemEffects[GET_BATTLER_SIDE2(gBattlerTarget)][gBattlerPartyIndexes[gBattlerTarget]] == HOLD_EFFECT_ROCKY_HELMET
        || defAbility == ABILITY_IRON_BARBS || defAbility == ABILITY_ROUGH_SKIN))
    {
        if (IS_MOVE_PHYSICAL(goodMove) && !IS_MOVE_PHYSICAL(bestMove))
            return FALSE;
    }
    // Check recoil
    if (GetBattlerAbility(sBattler_AI) != ABILITY_ROCK_HEAD)
    {
        if (((gBattleMoves[goodMove].effect == EFFECT_RECOIL
                || gBattleMoves[goodMove].effect == EFFECT_RECOIL_IF_MISS
                || gBattleMoves[goodMove].effect == EFFECT_RECOIL_50
                || gBattleMoves[goodMove].effect == EFFECT_RECOIL_33_STATUS)
            && (gBattleMoves[bestMove].effect != EFFECT_RECOIL
                 && gBattleMoves[bestMove].effect != EFFECT_RECOIL_IF_MISS
                 && gBattleMoves[bestMove].effect != EFFECT_RECOIL_50
                 && gBattleMoves[bestMove].effect != EFFECT_RECOIL_33_STATUS
                 && gBattleMoves[bestMove].effect != EFFECT_RECHARGE)))
            return FALSE;
    }
    // Check recharge
    if (gBattleMoves[goodMove].effect == EFFECT_RECHARGE && gBattleMoves[bestMove].effect != EFFECT_RECHARGE)
        return FALSE;
    // Check additional effect.
    if (gBattleMoves[bestMove].effect != 0 && gBattleMoves[goodMove].effect == 0)
        return FALSE;

    return TRUE;
}

static void Cmd_get_how_powerful_move_is(void)
{
    s32 i, checkedMove, bestId, currId, hp;
    s32 moveDmgs[MAX_MON_MOVES];

    for (i = 0; sDiscouragedPowerfulMoveEffects[i] != 0xFFFF; i++)
    {
        if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].effect == sDiscouragedPowerfulMoveEffects[i])
            break;
    }

    if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].power != 0
        && sDiscouragedPowerfulMoveEffects[i] == 0xFFFF)
    {
        for (checkedMove = 0; checkedMove < MAX_MON_MOVES; checkedMove++)
        {
            for (i = 0; sDiscouragedPowerfulMoveEffects[i] != 0xFFFF; i++)
            {
                if (gBattleMoves[gBattleMons[sBattler_AI].moves[checkedMove]].effect == sDiscouragedPowerfulMoveEffects[i])
                    break;
            }

            if (gBattleMons[sBattler_AI].moves[checkedMove] != MOVE_NONE
                && sDiscouragedPowerfulMoveEffects[i] == 0xFFFF
                && gBattleMoves[gBattleMons[sBattler_AI].moves[checkedMove]].power != 0)
            {
                moveDmgs[checkedMove] = AI_THINKING_STRUCT->simulatedDmg[sBattler_AI][gBattlerTarget][checkedMove];
            }
            else
            {
                moveDmgs[checkedMove] = 0;
            }
        }

        for (bestId = 0, i = 0; i < MAX_MON_MOVES; i++)
        {
            if (moveDmgs[i] > moveDmgs[bestId])
                bestId = i;
        }

        currId = AI_THINKING_STRUCT->movesetIndex;
        hp = gBattleMons[gBattlerTarget].hp;
        if (currId == bestId)
            AI_THINKING_STRUCT->funcResult = MOVE_POWER_BEST;
        // Compare percentage difference.
        else if ((moveDmgs[bestId] * 100 / hp) - (moveDmgs[currId] * 100 / hp) <= 10
                 && CompareTwoMoves(gBattleMons[sBattler_AI].moves[bestId], gBattleMons[sBattler_AI].moves[currId]))
            AI_THINKING_STRUCT->funcResult = MOVE_POWER_GOOD;
        else
            AI_THINKING_STRUCT->funcResult = MOVE_POWER_WEAK;
    }
    else
    {
        AI_THINKING_STRUCT->funcResult = MOVE_POWER_DISCOURAGED; // Highly discouraged in terms of power.
    }

    gAIScriptPtr++;
}

static void Cmd_get_last_used_battler_move(void)
{
    if (gAIScriptPtr[1] == AI_USER)
        AI_THINKING_STRUCT->funcResult = gLastMoves[sBattler_AI];
    else
        AI_THINKING_STRUCT->funcResult = gLastMoves[gBattlerTarget];

    gAIScriptPtr += 2;
}

static void Cmd_if_equal_u32(void)
{
    if (T1_READ_32(&gAIScriptPtr[1]) == AI_THINKING_STRUCT->funcResult)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_if_not_equal_u32(void)
{
    if (T1_READ_32(&gAIScriptPtr[1]) != AI_THINKING_STRUCT->funcResult)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_if_user_goes(void)
{
    u32 fasterAI = 0, fasterPlayer = 0, i;
    s8 prioAI, prioPlayer;

    // Check move priorities first.
    prioAI = GetMovePriority(sBattler_AI, AI_THINKING_STRUCT->moveConsidered);
    SaveBattlerData(gBattlerTarget);
    SetBattlerData(gBattlerTarget);
    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (gBattleMons[gBattlerTarget].moves[i] == 0 || gBattleMons[gBattlerTarget].moves[i] == 0xFFFF)
            continue;

        prioPlayer = GetMovePriority(gBattlerTarget, gBattleMons[gBattlerTarget].moves[i]);
        if (prioAI > prioPlayer)
            fasterAI++;
        else if (prioPlayer > prioAI)
            fasterPlayer++;
    }
    RestoreBattlerData(gBattlerTarget);

    if (fasterAI > fasterPlayer)
    {
        if (gAIScriptPtr[1] == 0)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
    }
    else if (fasterAI < fasterPlayer)
    {
        if (gAIScriptPtr[1] == 1)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
    }
    else
    {
        // Priorities are the same(at least comparing to moves the AI is aware of), decide by speed.
        if (GetWhoStrikesFirst(sBattler_AI, gBattlerTarget, TRUE) == gAIScriptPtr[1])
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
    }
}

static void Cmd_has_priority_move(void)
{
    u8 i;
    bool8 found = FALSE;
    u32 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    SaveBattlerData(battlerId);
    SetBattlerData(battlerId);
    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        u16 move = gBattleMons[battlerId].moves[i];

        if (move == 0 || move == 0xFFFF)
            continue;

        if (gBattleMoves[move].power > 0 && GetMovePriority(battlerId, move) > 0)
        {
            found = TRUE;
            break;
        }
    }
    RestoreBattlerData(battlerId);

    if (found)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_nullsub_2B(void)
{
}

static s32 CountUsablePartyMons(u8 battlerId)
{
    s32 battlerOnField1, battlerOnField2, i, ret;
    struct Pokemon *party;

    if (GET_BATTLER_SIDE2(battlerId) == B_SIDE_PLAYER)
        party = gPlayerParty;
    else
        party = gEnemyParty;

    if (gBattleTypeFlags & BATTLE_TYPE_DOUBLE)
    {
        battlerOnField1 = gBattlerPartyIndexes[battlerId];
        battlerOnField2 = gBattlerPartyIndexes[GetBattlerAtPosition(GetBattlerPosition(battlerId) ^ BIT_FLANK)];
    }
    else // In singles there's only one battlerId by side.
    {
        battlerOnField1 = gBattlerPartyIndexes[battlerId];
        battlerOnField2 = gBattlerPartyIndexes[battlerId];
    }

    ret = 0;
    for (i = 0; i < PARTY_SIZE; i++)
    {
        if (i != battlerOnField1 && i != battlerOnField2
         && GetMonData(&party[i], MON_DATA_HP) != 0
         && GetMonData(&party[i], MON_DATA_SPECIES_EGG) != SPECIES_NONE
         && GetMonData(&party[i], MON_DATA_SPECIES_EGG) != SPECIES_EGG)
        {
            ret++;
        }
    }

    return ret;
}

static void Cmd_count_usable_party_mons(void)
{
    AI_THINKING_STRUCT->funcResult = CountUsablePartyMons(BattleAI_GetWantedBattler(gAIScriptPtr[1]));
    gAIScriptPtr += 2;
}

static void Cmd_get_considered_move(void)
{
    AI_THINKING_STRUCT->funcResult = AI_THINKING_STRUCT->moveConsidered;
    gAIScriptPtr += 1;
}

static void Cmd_get_considered_move_effect(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->moveConsidered].effect;
    gAIScriptPtr += 1;
}

static s32 AI_GetAbility(u32 battlerId, bool32 guess)
{
    // The AI knows its own ability.
    if (IsBattlerAIControlled(battlerId))
        return gBattleMons[battlerId].ability;

    if (BATTLE_HISTORY->abilities[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]] != 0)
        return BATTLE_HISTORY->abilities[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]];

    // Abilities that prevent fleeing.
    if (gBattleMons[battlerId].ability == ABILITY_SHADOW_TAG
    || gBattleMons[battlerId].ability == ABILITY_MAGNET_PULL
    || gBattleMons[battlerId].ability == ABILITY_ARENA_TRAP)
        return gBattleMons[battlerId].ability;

    if (gBaseStats[gBattleMons[battlerId].species].abilities[0] == gBaseStats[gBattleMons[battlerId].species].abilities[1]
    && gBaseStats[gBattleMons[battlerId].species].abilities[2] == ABILITY_NONE)
    {
        return gBaseStats[gBattleMons[battlerId].species].abilities[0]; // It's definitely ability 1.
    }
    else if (guess)
    {
        if (gBaseStats[gBattleMons[battlerId].species].abilities[2] == ABILITY_NONE)
        {
            return gBaseStats[gBattleMons[battlerId].species].abilities[Random() & 1];
        }
        else
        {
            return gBaseStats[gBattleMons[battlerId].species].abilities[Random() % 3];
        }
    }

    return -1; // Unknown.
}

static void Cmd_get_ability(void)
{
    AI_THINKING_STRUCT->funcResult = AI_GetAbility(BattleAI_GetWantedBattler(gAIScriptPtr[1]), TRUE);
    gAIScriptPtr += 2;
}

static void Cmd_check_ability(void)
{
    u32 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u32 ability = AI_GetAbility(battlerId, FALSE);

    if (ability == -1)
        AI_THINKING_STRUCT->funcResult = 2; // Unable to answer.
    else if (ability == gAIScriptPtr[2])
        AI_THINKING_STRUCT->funcResult = 1; // Pokemon has the ability we wanted to check.
    else
        AI_THINKING_STRUCT->funcResult = 0; // Pokemon doesn't have the ability we wanted to check.

    gAIScriptPtr += 3;
}

static void Cmd_get_highest_type_effectiveness(void)
{
    s32 i;
    u8 *dynamicMoveType;

    gBattleStruct->dynamicMoveType = 0;
    gMoveResultFlags = 0;
    AI_THINKING_STRUCT->funcResult = 0;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        gCurrentMove = gBattleMons[sBattler_AI].moves[i];
        if (gCurrentMove != MOVE_NONE)
        {
            u32 effectivenessMultiplier = AI_GetTypeEffectiveness(gCurrentMove, sBattler_AI, gBattlerTarget);

            switch (effectivenessMultiplier)
            {
            case UQ_4_12(0.0):
            default:
                gBattleMoveDamage = AI_EFFECTIVENESS_x0;
                break;
            case UQ_4_12(0.25):
                gBattleMoveDamage = AI_EFFECTIVENESS_x0_25;
                break;
            case UQ_4_12(0.5):
                gBattleMoveDamage = AI_EFFECTIVENESS_x0_5;
                break;
            case UQ_4_12(1.0):
                gBattleMoveDamage = AI_EFFECTIVENESS_x1;
                break;
            case UQ_4_12(2.0):
                gBattleMoveDamage = AI_EFFECTIVENESS_x2;
                break;
            case UQ_4_12(4.0):
                gBattleMoveDamage = AI_EFFECTIVENESS_x4;
                break;
            }

            if (AI_THINKING_STRUCT->funcResult < gBattleMoveDamage)
                AI_THINKING_STRUCT->funcResult = gBattleMoveDamage;
        }
    }

    gAIScriptPtr += 1;
}

static void Cmd_if_type_effectiveness(void)
{
    u8 damageVar;
    u32 effectivenessMultiplier;

    gBattleStruct->dynamicMoveType = 0;
    gMoveResultFlags = 0;
    gCurrentMove = AI_THINKING_STRUCT->moveConsidered;

    effectivenessMultiplier = AI_GetTypeEffectiveness(gCurrentMove, sBattler_AI, gBattlerTarget);
    switch (effectivenessMultiplier)
    {
    case UQ_4_12(0.0):
    default:
        damageVar = AI_EFFECTIVENESS_x0;
        break;
    case UQ_4_12(0.25):
        damageVar = AI_EFFECTIVENESS_x0_25;
        break;
    case UQ_4_12(0.5):
        damageVar = AI_EFFECTIVENESS_x0_5;
        break;
    case UQ_4_12(1.0):
        damageVar = AI_EFFECTIVENESS_x1;
        break;
    case UQ_4_12(2.0):
        damageVar = AI_EFFECTIVENESS_x2;
        break;
    case UQ_4_12(4.0):
        damageVar = AI_EFFECTIVENESS_x4;
        break;
    }

    if (damageVar == gAIScriptPtr[1])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_nullsub_32(void)
{
}

static void Cmd_nullsub_33(void)
{
}

static void Cmd_if_status_in_party(void)
{
    struct Pokemon *party;
    s32 i;
    u32 statusToCompareTo;
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    party = (GET_BATTLER_SIDE2(battlerId) == B_SIDE_PLAYER) ? gPlayerParty : gEnemyParty;

    statusToCompareTo = T1_READ_32(gAIScriptPtr + 2);

    for (i = 0; i < PARTY_SIZE; i++)
    {
        u16 species = GetMonData(&party[i], MON_DATA_SPECIES);
        u16 hp = GetMonData(&party[i], MON_DATA_HP);
        u32 status = GetMonData(&party[i], MON_DATA_STATUS);

        if (species != SPECIES_NONE && species != SPECIES_EGG && hp != 0 && status == statusToCompareTo)
        {
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
            return;
        }
    }

    gAIScriptPtr += 10;
}

static void Cmd_if_status_not_in_party(void)
{
    struct Pokemon *party;
    s32 i;
    u32 statusToCompareTo;
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    party = (GET_BATTLER_SIDE2(battlerId) == B_SIDE_PLAYER) ? gPlayerParty : gEnemyParty;

    statusToCompareTo = T1_READ_32(gAIScriptPtr + 2);

    for (i = 0; i < PARTY_SIZE; i++)
    {
        u16 species = GetMonData(&party[i], MON_DATA_SPECIES);
        u16 hp = GetMonData(&party[i], MON_DATA_HP);
        u32 status = GetMonData(&party[i], MON_DATA_STATUS);

        if (species != SPECIES_NONE && species != SPECIES_EGG && hp != 0 && status == statusToCompareTo)
        {
            gAIScriptPtr += 10;
            return;
        }
    }

    gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
}

static void Cmd_get_weather(void)
{
    if (gBattleWeather & WEATHER_RAIN_ANY)
        AI_THINKING_STRUCT->funcResult = AI_WEATHER_RAIN;
    else if (gBattleWeather & WEATHER_SANDSTORM_ANY)
        AI_THINKING_STRUCT->funcResult = AI_WEATHER_SANDSTORM;
    else if (gBattleWeather & WEATHER_SUN_ANY)
        AI_THINKING_STRUCT->funcResult = AI_WEATHER_SUN;
    else if (gBattleWeather & WEATHER_HAIL_ANY)
        AI_THINKING_STRUCT->funcResult = AI_WEATHER_HAIL;
    else
        AI_THINKING_STRUCT->funcResult = AI_WEATHER_NONE;

    gAIScriptPtr += 1;
}

static void Cmd_if_effect(void)
{
    if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].effect == T1_READ_16(gAIScriptPtr + 1))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_not_effect(void)
{
    if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].effect != T1_READ_16(gAIScriptPtr + 1))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_stat_level_less_than(void)
{
    u32 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    if (gBattleMons[battlerId].statStages[gAIScriptPtr[2]] < gAIScriptPtr[3])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
    else
        gAIScriptPtr += 8;
}

static void Cmd_if_stat_level_more_than(void)
{
    u32 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    if (gBattleMons[battlerId].statStages[gAIScriptPtr[2]] > gAIScriptPtr[3])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
    else
        gAIScriptPtr += 8;
}

static void Cmd_if_stat_level_equal(void)
{
    u32 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    if (gBattleMons[battlerId].statStages[gAIScriptPtr[2]] == gAIScriptPtr[3])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
    else
        gAIScriptPtr += 8;
}

static void Cmd_if_stat_level_not_equal(void)
{
    u32 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    if (gBattleMons[battlerId].statStages[gAIScriptPtr[2]] != gAIScriptPtr[3])
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
    else
        gAIScriptPtr += 8;
}

static void Cmd_if_can_faint(void)
{
    s32 dmg;

    if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].power == 0)
    {
        gAIScriptPtr += 5;
        return;
    }

    dmg = AI_THINKING_STRUCT->simulatedDmg[sBattler_AI][gBattlerTarget][AI_THINKING_STRUCT->movesetIndex];
    if (gBattleMons[gBattlerTarget].hp <= dmg)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
    else
        gAIScriptPtr += 5;
}

static void Cmd_if_cant_faint(void)
{
    s32 dmg;

    if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].power < 2)
    {
        gAIScriptPtr += 5;
        return;
    }

    dmg = AI_THINKING_STRUCT->simulatedDmg[sBattler_AI][gBattlerTarget][AI_THINKING_STRUCT->movesetIndex];
    if (gBattleMons[gBattlerTarget].hp > dmg)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
    else
        gAIScriptPtr += 5;
}

static void Cmd_if_has_move(void)
{
    s32 i;
    const u16 *movePtr = (u16 *)(gAIScriptPtr + 2);

    switch (gAIScriptPtr[1])
    {
    case AI_USER:
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if (gBattleMons[sBattler_AI].moves[i] == *movePtr)
                break;
        }
        if (i == MAX_MON_MOVES)
            gAIScriptPtr += 8;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
        break;
    case AI_USER_PARTNER:
        if (gBattleMons[sBattler_AI ^ BIT_FLANK].hp == 0)
        {
            gAIScriptPtr += 8;
            break;
        }
        else
        {
            for (i = 0; i < MAX_MON_MOVES; i++)
            {
                if (gBattleMons[sBattler_AI ^ BIT_FLANK].moves[i] == *movePtr)
                    break;
            }
        }
        if (i == MAX_MON_MOVES)
            gAIScriptPtr += 8;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
        break;
    case AI_TARGET:
    case AI_TARGET_PARTNER:
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if (BATTLE_HISTORY_USED_MOVES(gBattlerTarget).moves[i] == *movePtr)
                break;
        }
        if (i == MAX_MON_MOVES)
            gAIScriptPtr += 8;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
        break;
    }
}

static void Cmd_if_doesnt_have_move(void)
{
    s32 i;
    const u16 *movePtr = (u16 *)(gAIScriptPtr + 2);

    switch(gAIScriptPtr[1])
    {
    case AI_USER:
    case AI_USER_PARTNER: // UB: no separate check for user partner.
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if (gBattleMons[sBattler_AI].moves[i] == *movePtr)
                break;
        }
        if (i != MAX_MON_MOVES)
            gAIScriptPtr += 8;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
        break;
    case AI_TARGET:
    case AI_TARGET_PARTNER:
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if (BATTLE_HISTORY_USED_MOVES(gBattlerTarget).moves[i] == *movePtr)
                break;
        }
        if (i != MAX_MON_MOVES)
            gAIScriptPtr += 8;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
        break;
    }
}

static void Cmd_if_has_move_with_effect(void)
{
    s32 i;

    switch (gAIScriptPtr[1])
    {
    case AI_USER:
    case AI_USER_PARTNER:
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if (gBattleMons[sBattler_AI].moves[i] != 0 && gBattleMoves[gBattleMons[sBattler_AI].moves[i]].effect == gAIScriptPtr[2])
                break;
        }
        if (i == MAX_MON_MOVES)
            gAIScriptPtr += 7;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
        break;
    case AI_TARGET:
    case AI_TARGET_PARTNER:
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if (gBattleMons[gBattlerTarget].moves[i] != 0 && gBattleMoves[BATTLE_HISTORY_USED_MOVES(gBattlerTarget).moves[i]].effect == gAIScriptPtr[2])
                break;
        }
        if (i == MAX_MON_MOVES)
            gAIScriptPtr += 7;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
        break;
    }
}

static void Cmd_if_doesnt_have_move_with_effect(void)
{
    s32 i;

    switch (gAIScriptPtr[1])
    {
    case AI_USER:
    case AI_USER_PARTNER:
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if(gBattleMons[sBattler_AI].moves[i] != 0 && gBattleMoves[gBattleMons[sBattler_AI].moves[i]].effect == gAIScriptPtr[2])
                break;
        }
        if (i != MAX_MON_MOVES)
            gAIScriptPtr += 7;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
        break;
    case AI_TARGET:
    case AI_TARGET_PARTNER:
        for (i = 0; i < MAX_MON_MOVES; i++)
        {
            if (BATTLE_HISTORY_USED_MOVES(gBattlerTarget).moves[i] && gBattleMoves[BATTLE_HISTORY_USED_MOVES(gBattlerTarget).moves[i]].effect == gAIScriptPtr[2])
                break;
        }
        if (i != MAX_MON_MOVES)
            gAIScriptPtr += 7;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
        break;
    }
}

static void Cmd_if_any_move_disabled_or_encored(void)
{
    u8 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    if (gAIScriptPtr[2] == 0)
    {
        if (gDisableStructs[battlerId].disabledMove == MOVE_NONE)
            gAIScriptPtr += 7;
        else
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    }
    else if (gAIScriptPtr[2] != 1)
    {
        gAIScriptPtr += 7;
    }
    else
    {
        if (gDisableStructs[battlerId].encoredMove != MOVE_NONE)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
        else
            gAIScriptPtr += 7;
    }
}

static void Cmd_if_curr_move_disabled_or_encored(void)
{
    switch (gAIScriptPtr[1])
    {
    case 0:
        if (gDisableStructs[gActiveBattler].disabledMove == AI_THINKING_STRUCT->moveConsidered)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
        break;
    case 1:
        if (gDisableStructs[gActiveBattler].encoredMove == AI_THINKING_STRUCT->moveConsidered)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
        break;
    default:
        gAIScriptPtr += 6;
        break;
    }
}

static void Cmd_flee(void)
{
    AI_THINKING_STRUCT->aiAction |= (AI_ACTION_DONE | AI_ACTION_FLEE | AI_ACTION_DO_NOT_ATTACK);
}

static void Cmd_if_random_safari_flee(void)
{
    u8 safariFleeRate = gBattleStruct->safariEscapeFactor * 5; // Safari flee rate, from 0-20.

    if ((u8)(Random() % 100) < safariFleeRate)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
    else
        gAIScriptPtr += 5;
}

static void Cmd_watch(void)
{
    AI_THINKING_STRUCT->aiAction |= (AI_ACTION_DONE | AI_ACTION_WATCH | AI_ACTION_DO_NOT_ATTACK);
}

static void Cmd_get_hold_effect(void)
{
    u32 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (!IsBattlerAIControlled(battlerId))
        AI_THINKING_STRUCT->funcResult = BATTLE_HISTORY->itemEffects[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]];
    else
        AI_THINKING_STRUCT->funcResult = GetBattlerHoldEffect(battlerId, FALSE);

    gAIScriptPtr += 2;
}

static void Cmd_if_holds_item(void)
{
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u16 item;

    if ((battlerId & BIT_SIDE) == (sBattler_AI & BIT_SIDE))
        item = gBattleMons[battlerId].item;
    else
        item = BATTLE_HISTORY->itemEffects[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]];

    if (T1_READ_16(gAIScriptPtr + 2) == item)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 4);
    else
        gAIScriptPtr += 8;
}

static void Cmd_get_gender(void)
{
    u8 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    AI_THINKING_STRUCT->funcResult = GetGenderFromSpeciesAndPersonality(gBattleMons[battlerId].species, gBattleMons[battlerId].personality);

    gAIScriptPtr += 2;
}

static void Cmd_is_first_turn_for(void)
{
    u8 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    AI_THINKING_STRUCT->funcResult = gDisableStructs[battlerId].isFirstTurn;

    gAIScriptPtr += 2;
}

static void Cmd_get_stockpile_count(void)
{
    u8 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    AI_THINKING_STRUCT->funcResult = gDisableStructs[battlerId].stockpileCounter;

    gAIScriptPtr += 2;
}

static void Cmd_is_double_battle(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleTypeFlags & BATTLE_TYPE_DOUBLE;

    gAIScriptPtr += 1;
}

static void Cmd_get_used_held_item(void)
{
    u8 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    AI_THINKING_STRUCT->funcResult = gBattleStruct->usedHeldItems[battlerId];

    gAIScriptPtr += 2;
}

static void Cmd_get_move_type_from_result(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->funcResult].type;

    gAIScriptPtr += 1;
}

static void Cmd_get_move_power_from_result(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->funcResult].power;

    gAIScriptPtr += 1;
}

static void Cmd_get_move_effect_from_result(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->funcResult].effect;

    gAIScriptPtr += 1;
}

static void Cmd_get_protect_count(void)
{
    u8 battlerId;

    if (gAIScriptPtr[1] == AI_USER)
        battlerId = sBattler_AI;
    else
        battlerId = gBattlerTarget;

    AI_THINKING_STRUCT->funcResult = gDisableStructs[battlerId].protectUses;

    gAIScriptPtr += 2;
}

static void Cmd_if_move_flag(void)
{
    u32 flag = T1_READ_32(gAIScriptPtr + 1);

    if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].flags & flag)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_if_field_status(void)
{
    u32 fieldFlags = T1_READ_32(gAIScriptPtr + 1);

    if (gFieldStatuses & fieldFlags)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    else
        gAIScriptPtr += 9;
}

static void Cmd_get_move_accuracy(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->moveConsidered].accuracy;

    gAIScriptPtr++;
}

static void Cmd_call_if_eq(void)
{
    if (AI_THINKING_STRUCT->funcResult == T1_READ_16(gAIScriptPtr + 1))
    {
        AIStackPushVar(gAIScriptPtr + 7);
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    }
    else
    {
        gAIScriptPtr += 7;
    }
}

static void Cmd_call_if_move_flag(void)
{
    u32 flag = T1_READ_32(gAIScriptPtr + 1);

    if (gBattleMoves[AI_THINKING_STRUCT->moveConsidered].flags & flag)
    {
        AIStackPushVar(gAIScriptPtr + 9);
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 5);
    }
    else
    {
        gAIScriptPtr += 9;
    }
}

static void Cmd_nullsub_57(void)
{
}

static void Cmd_call(void)
{
    AIStackPushVar(gAIScriptPtr + 5);
    gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
}

static void Cmd_goto(void)
{
    gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
}

static void Cmd_end(void)
{
    if (AIStackPop() == 0)
        AI_THINKING_STRUCT->aiAction |= AI_ACTION_DONE;
}

static void Cmd_if_level_cond(void)
{
    switch (gAIScriptPtr[1])
    {
    case 0: // greater than
        if (gBattleMons[sBattler_AI].level > gBattleMons[gBattlerTarget].level)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
        break;
    case 1: // less than
        if (gBattleMons[sBattler_AI].level < gBattleMons[gBattlerTarget].level)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
        break;
    case 2: // equal
        if (gBattleMons[sBattler_AI].level == gBattleMons[gBattlerTarget].level)
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
        else
            gAIScriptPtr += 6;
        break;
    }
}

static void Cmd_if_target_taunted(void)
{
    if (gDisableStructs[gBattlerTarget].tauntTimer != 0)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
    else
        gAIScriptPtr += 5;
}

static void Cmd_if_target_not_taunted(void)
{
    if (gDisableStructs[gBattlerTarget].tauntTimer == 0)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
    else
        gAIScriptPtr += 5;
}

static void Cmd_if_target_is_ally(void)
{
    if ((sBattler_AI & BIT_SIDE) == (gBattlerTarget & BIT_SIDE))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
    else
        gAIScriptPtr += 5;
}

static void Cmd_if_flash_fired(void)
{
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (gBattleResources->flags->flags[battlerId] & RESOURCE_FLAG_FLASH_FIRE)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void AIStackPushVar(const u8 *var)
{
    gBattleResources->AI_ScriptsStack->ptr[gBattleResources->AI_ScriptsStack->size++] = var;
}

static void AIStackPushVar_cursor(void)
{
    gBattleResources->AI_ScriptsStack->ptr[gBattleResources->AI_ScriptsStack->size++] = gAIScriptPtr;
}

static bool8 AIStackPop(void)
{
    if (gBattleResources->AI_ScriptsStack->size != 0)
    {
        --gBattleResources->AI_ScriptsStack->size;
        gAIScriptPtr = gBattleResources->AI_ScriptsStack->ptr[gBattleResources->AI_ScriptsStack->size];
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

static void Cmd_get_ally_chosen_move(void)
{
    u8 partnerBattler = BATTLE_PARTNER(sBattler_AI);
    if (!IsBattlerAlive(partnerBattler) || !IsBattlerAIControlled(partnerBattler))
        AI_THINKING_STRUCT->funcResult = 0;
    else if (partnerBattler > sBattler_AI) // Battler with the lower id chooses the move first.
        AI_THINKING_STRUCT->funcResult = 0;
    else
        AI_THINKING_STRUCT->funcResult = gBattleMons[partnerBattler].moves[gBattleStruct->chosenMovePositions[partnerBattler]];

    gAIScriptPtr++;
}

static void Cmd_if_has_no_attacking_moves(void)
{
    s32 i;
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    if (IsBattlerAIControlled(battlerId))
    {
        for (i = 0; i < 4; i++)
        {
            if (gBattleMons[battlerId].moves[i] != 0 && gBattleMoves[gBattleMons[battlerId].moves[i]].power != 0)
                break;
        }
    }
    else
    {
        for (i = 0; i < 4; i++)
        {
            if (BATTLE_HISTORY_USED_MOVES(battlerId).moves[i] != 0 && gBattleMoves[BATTLE_HISTORY_USED_MOVES(battlerId).moves[i]].power != 0)
                break;
        }
    }

    if (i == 4)
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_get_hazards_count(void)
{
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u8 side = GET_BATTLER_SIDE2(battlerId);

    switch (T1_READ_16(gAIScriptPtr + 2))
    {
    case EFFECT_SPIKES:
        AI_THINKING_STRUCT->funcResult = gSideTimers[side].spikesAmount;
        break;
    case EFFECT_TOXIC_SPIKES:
        AI_THINKING_STRUCT->funcResult = gSideTimers[side].toxicSpikesAmount;
        break;
    }

    gAIScriptPtr += 4;
}

static void Cmd_if_doesnt_hold_berry(void)
{
    u8 battlerId = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u16 item;

    if (IsBattlerAIControlled(battlerId))
        item = gBattleMons[battlerId].item;
    else
        item = BATTLE_HISTORY->itemEffects[GET_BATTLER_SIDE2(battlerId)][gBattlerPartyIndexes[battlerId]];

    if (ItemId_GetPocket(item) == POCKET_BERRIES)
        gAIScriptPtr += 6;
    else
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
}

static void Cmd_if_share_type(void)
{
    u8 battler1 = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u8 battler2 = BattleAI_GetWantedBattler(gAIScriptPtr[2]);

    if (DoBattlersShareType(battler1, battler2))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_cant_use_last_resort(void)
{
    u8 battler = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (CanUseLastResort(battler))
        gAIScriptPtr += 6;
    else
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
}

static bool32 HasMoveWithSplit(u32 battler, u32 split)
{
    s32 i;
    u16 *moves;

    if (IsBattlerAIControlled(battler) || IsBattlerAIControlled(BATTLE_PARTNER(battler)))
        moves = gBattleMons[battler].moves;
    else
        moves = BATTLE_HISTORY_USED_MOVES(battler).moves;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (moves[i] != MOVE_NONE && moves[i] != 0xFFFF && gBattleMoves[moves[i]].split == split)
            return TRUE;
    }

    return FALSE;
}

static void Cmd_if_has_move_with_split(void)
{
    if (HasMoveWithSplit(BattleAI_GetWantedBattler(gAIScriptPtr[1]), gAIScriptPtr[2]))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

static void Cmd_if_has_no_move_with_split(void)
{
    if (!HasMoveWithSplit(BattleAI_GetWantedBattler(gAIScriptPtr[1]), gAIScriptPtr[2]))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

// This function checks if all physical/special moves are either unusable or unreasonable to use.
// Consider a pokemon boosting their attack against a ghost pokemon having only normal-type physical attacks.
static bool32 MovesWithSplitUnusable(u32 attacker, u32 target, u32 split)
{
    s32 i, moveType;
    u16 *moves;
    u32 usable = 0;
    u32 unusable = CheckMoveLimitations(attacker, 0, 0xFF);

    if (IsBattlerAIControlled(attacker))
        moves = gBattleMons[attacker].moves;
    else
        moves = BATTLE_HISTORY_USED_MOVES(attacker).moves;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (moves[i] != MOVE_NONE
             && moves[i] != 0xFFFF
             && gBattleMoves[moves[i]].split == split
             && !(unusable & gBitTable[i]))
        {
            SetTypeBeforeUsingMove(moves[i], attacker);
            GET_MOVE_TYPE(moves[i], moveType);
            if (CalcTypeEffectivenessMultiplier(moves[i], moveType, attacker, target, FALSE) != 0)
                usable |= gBitTable[i];
        }
    }

    return (usable == 0);
}

static void Cmd_if_physical_moves_unusable(void)
{
    if (MovesWithSplitUnusable(BattleAI_GetWantedBattler(gAIScriptPtr[1]), BattleAI_GetWantedBattler(gAIScriptPtr[2]), SPLIT_PHYSICAL))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
    else
        gAIScriptPtr += 7;
}

// Check if target has means to faint ai mon.
static void Cmd_if_ai_can_go_down(void)
{
    s32 i, dmg;
    u32 unusable = CheckMoveLimitations(gBattlerTarget, 0, 0xFF & ~MOVE_LIMITATION_PP);
    u16 *moves = BATTLE_HISTORY_USED_MOVES(gBattlerTarget).moves;

    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (moves[i] != MOVE_NONE && moves[i] != 0xFFFF && !(unusable & gBitTable[i])
            && AI_CalcDamage(moves[i], gBattlerTarget, sBattler_AI) >= gBattleMons[sBattler_AI].hp)
        {
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 1);
            return;
        }
    }

    gAIScriptPtr += 5;
}

static void Cmd_if_cant_use_belch(void)
{
    u32 battler = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (gBattleStruct->ateBerry[battler & BIT_SIDE] & gBitTable[gBattlerPartyIndexes[battler]])
        gAIScriptPtr += 6;
    else
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
}

static void Cmd_if_has_move_with_type(void)
{
    u32 i, moveType, battler = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u16 *moves;

    if (IsBattlerAIControlled(battler))
        moves = gBattleMons[battler].moves;
    else
        moves = BATTLE_HISTORY_USED_MOVES(battler).moves;

    for (i = 0; i < 4; i++)
    {
        if (moves[i] == MOVE_NONE)
            continue;

        SetTypeBeforeUsingMove(moves[i], battler);
        GET_MOVE_TYPE(moves[i], moveType);
        if (moveType == gAIScriptPtr[2])
            break;
    }

    if (i == 4)
        gAIScriptPtr += 7;
    else
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 3);
}

static void Cmd_if_has_move_with_flag(void)
{
    u32 i, flag, battler = BattleAI_GetWantedBattler(gAIScriptPtr[1]);
    u16 *moves;

    if (IsBattlerAIControlled(battler))
        moves = gBattleMons[battler].moves;
    else
        moves = BATTLE_HISTORY_USED_MOVES(battler).moves;

    flag = T1_READ_32(gAIScriptPtr + 2);
    for (i = 0; i < 4; i++)
    {
        if (moves[i] != MOVE_NONE && gBattleMoves[moves[i]].flags & flag)
        {
            gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 6);
            return;
        }
    }

    gAIScriptPtr += 10;
}

static void Cmd_if_no_move_used(void)
{
    u32 i, battler = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (!IsBattlerAIControlled(battler))
    {
        for (i = 0; i < 4; i++)
        {
            if (BATTLE_HISTORY_USED_MOVES(battler).moves[i] != 0 && BATTLE_HISTORY_USED_MOVES(battler).moves[i] != 0xFFFF)
            {
                gAIScriptPtr += 6;
                return;
            }
        }
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    }
    else
    {
        gAIScriptPtr += 6;
    }
}

static void Cmd_if_battler_absent(void)
{
    u32 battler = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (!IsBattlerAlive(battler))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_is_grounded(void)
{
    u32 battler = BattleAI_GetWantedBattler(gAIScriptPtr[1]);

    if (IsBattlerGrounded(battler))
        gAIScriptPtr = T1_READ_PTR(gAIScriptPtr + 2);
    else
        gAIScriptPtr += 6;
}

static void Cmd_get_best_dmg_hp_percent(void)
{
    int i, bestDmg;

    bestDmg = 0;
    for (i = 0; i < MAX_MON_MOVES; i++)
    {
        if (gBattleResources->ai->simulatedDmg[sBattler_AI][gBattlerTarget][i] > bestDmg)
            bestDmg = gBattleResources->ai->simulatedDmg[sBattler_AI][gBattlerTarget][i];
    }

    gBattleResources->ai->funcResult = (bestDmg * 100) / gBattleMons[gBattlerTarget].maxHP;
    gAIScriptPtr++;
}

static void Cmd_get_curr_dmg_hp_percent(void)
{
    int bestDmg = gBattleResources->ai->simulatedDmg[sBattler_AI][gBattlerTarget][AI_THINKING_STRUCT->movesetIndex];

    gBattleResources->ai->funcResult = (bestDmg * 100) / gBattleMons[gBattlerTarget].maxHP;
    gAIScriptPtr++;
}

static void Cmd_get_move_split_from_result(void)
{
    AI_THINKING_STRUCT->funcResult = gBattleMoves[AI_THINKING_STRUCT->funcResult].type;

    gAIScriptPtr += 1;
}
