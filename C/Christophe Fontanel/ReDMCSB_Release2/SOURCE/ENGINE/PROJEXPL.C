#include "DEFS.H"

/*_Global variables_*/
long G361_l_LastCreatureAttackTime = -200;
long G362_l_LastPartyMovementTime;
int G363_i_SecondaryDirectionToOrFromParty;
int G364_i_CreatureDamageOutcome;
BOOLEAN G365_B_CreateLauncherProjectile;
int G366_i_ProjectilePoisonAttack;
int G367_i_ProjectileAttackType;
#ifndef NOCOPYPROTECTION
char* G368_apc_CodePatches_COPYPROTECTIONE[6] = { &G585_ac_CodePatch0_COPYPROTECTIONE,
                                                  &G344_ac_CodePatch1_COPYPROTECTIONE,
                                                  &G533_ac_CodePatch2_COPYPROTECTIONE,
                                                  &G408_ac_CodePatch3_COPYPROTECTIONE,
                                                  &G393_ac_CodePatch4_COPYPROTECTIONE,
                                                  &G427_ac_CodePatch5_COPYPROTECTIONE };
#endif


overlay "timeline"

VOID F212_mzzz_PROJECTILE_Create(P433_T_Thing, P434_i_MapX, P435_i_MapY, P436_ui_Cell, P437_i_Direction, P438_uc_KineticEnergy, P439_uc_Attack, P440_uc_StepEnergy)
register THING P433_T_Thing;
int P434_i_MapX;
int P435_i_MapY;
unsigned int P436_ui_Cell;
int P437_i_Direction;
unsigned char P438_uc_KineticEnergy;
unsigned char P439_uc_Attack;
unsigned char P440_uc_StepEnergy;
{
        register THING L0466_T_ProjectileThing;
        register PROJECTILE* L0467_ps_Projectile;
        EVENT L0468_s_Event;


        if ((L0466_T_ProjectileThing = F166_szzz_DUNGEON_GetUnusedThing(C14_THING_TYPE_PROJECTILE)) == C0xFFFF_THING_NONE) { /* BUG0_16 If the game cannot create a projectile thing because it has run out of such things (60 maximum) then the object being thrown/shot/launched is orphaned. If the game has run out of projectile things it will try to remove a projectile from elsewhere in the dungeon, except in an area of 11x11 squares centered around the party (to make sure the player cannot actually see the thing disappear on screen) */
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_00_FIX Place object on the floor if the projectile cannot be created */
                if (M12_TYPE(P433_T_Thing) != C15_THING_TYPE_EXPLOSION) {
                        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(M15_THING_WITH_NEW_CELL(P433_T_Thing, P436_ui_Cell), CM1_MAPX_NOT_ON_A_SQUARE, 0, P434_i_MapX, P435_i_MapY);
                }
#endif
                return;
        }
        L0466_T_ProjectileThing = M15_THING_WITH_NEW_CELL(L0466_T_ProjectileThing, P436_ui_Cell);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0467_ps_Projectile = &((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(L0466_T_ProjectileThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0467_ps_Projectile = (PROJECTILE*)F156_afzz_DUNGEON_GetThingData(L0466_T_ProjectileThing);
#endif
        L0467_ps_Projectile->Slot = P433_T_Thing;
        L0467_ps_Projectile->KineticEnergy = F024_aatz_MAIN_GetMinimumValue(P438_uc_KineticEnergy, 255);
        L0467_ps_Projectile->Attack = P439_uc_Attack;
        F163_amzz_DUNGEON_LinkThingToList(L0466_T_ProjectileThing, 0, P434_i_MapX, P435_i_MapY); /* Projectiles are added on the square and not 'moved' onto the square. In the case of a projectile launcher sensor, this means that the new projectile traverses the square in front of the launcher without any trouble: there is no impact if it is a wall, the projectile direction is not changed if it is a teleporter. Impacts with creatures and champions are still processed */
        M33_SET_MAP_AND_TIME(L0468_s_Event.Map_Time, G272_i_CurrentMapIndex, G313_ul_GameTime + 1);
        if (G365_B_CreateLauncherProjectile) {
                L0468_s_Event.A.A.Type = C49_EVENT_MOVE_PROJECTILE; /* Launcher projectiles can impact immediately */
        } else {
                L0468_s_Event.A.A.Type = C48_EVENT_MOVE_PROJECTILE_IGNORE_IMPACTS; /* Projectiles created by champions or creatures ignore impacts on their first movement */
        }
        L0468_s_Event.A.A.Priority = 0;
        L0468_s_Event.B.Slot = L0466_T_ProjectileThing;
        L0468_s_Event.C.Projectile.MapX = P434_i_MapX;
        L0468_s_Event.C.Projectile.MapY = P435_i_MapY;
        L0468_s_Event.C.Projectile.StepEnergy = P440_uc_StepEnergy;
        L0468_s_Event.C.Projectile.Direction = P437_i_Direction;
        L0467_ps_Projectile->EventIndex = F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0468_s_Event);
}

VOID F213_hzzz_EXPLOSION_Create(P441_T_ExplosionThing, P442_ui_Attack, P443_ui_MapXCombo, P444_ui_MapYCombo, P445_ui_Cell)
THING P441_T_ExplosionThing;
register unsigned int P442_ui_Attack;
register unsigned int P443_ui_MapXCombo;
#define AP443_ui_ProjectileMapX P443_ui_MapXCombo
register unsigned int P444_ui_MapYCombo;
#define AP444_ui_ProjectileMapY P444_ui_MapYCombo
unsigned int P445_ui_Cell;
{
        register int L0469_i_CreatureFireResistance;
        register EXPLOSION* L0470_ps_Explosion;
        register CREATURE_INFO* L0471_ps_CreatureInfo;
        GROUP* L0472_ps_Group;
        THING L0473_T_Thing;
        int L0474_i_ProjectileTargetMapX;
        int L0475_i_ProjectileTargetMapY;
        EVENT L0476_s_Event;


        if ((L0473_T_Thing = F166_szzz_DUNGEON_GetUnusedThing(C15_THING_TYPE_EXPLOSION)) == C0xFFFF_THING_NONE) {
                return;
        }
        L0470_ps_Explosion = &((EXPLOSION*)G284_apuc_ThingData[C15_THING_TYPE_EXPLOSION])[M13_INDEX(L0473_T_Thing)];
        if (P443_ui_MapXCombo <= 255) {
                L0474_i_ProjectileTargetMapX = P443_ui_MapXCombo;
                L0475_i_ProjectileTargetMapY = P444_ui_MapYCombo;
        } else {
                L0474_i_ProjectileTargetMapX = P443_ui_MapXCombo & 0x00FF;
                L0475_i_ProjectileTargetMapY = P444_ui_MapYCombo & 0x00FF;
                AP443_ui_ProjectileMapX >>= 8;
                AP443_ui_ProjectileMapX--;
                AP444_ui_ProjectileMapY >>= 8;
        }
        if (P445_ui_Cell == C255_SINGLE_CENTERED_CREATURE) {
                L0470_ps_Explosion->Centered = TRUE;
        } else {
                L0470_ps_Explosion->Centered = FALSE;
                L0473_T_Thing = M15_THING_WITH_NEW_CELL(L0473_T_Thing, P445_ui_Cell);
        }
        L0470_ps_Explosion->Type = P441_T_ExplosionThing - C0xFF80_THING_FIRST_EXPLOSION;
        L0470_ps_Explosion->Attack = P442_ui_Attack;
        if (P441_T_ExplosionThing < C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL) {
                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND((P442_ui_Attack > 80) ? C05_SOUND_STRONG_EXPLOSION : C20_SOUND_WEAK_EXPLOSION, AP443_ui_ProjectileMapX, AP444_ui_ProjectileMapY, C01_MODE_PLAY_IF_PRIORITIZED);
        } else {
                if (P441_T_ExplosionThing != C0xFFA8_THING_EXPLOSION_SMOKE) {
                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C13_SOUND_SPELL, AP443_ui_ProjectileMapX, AP444_ui_ProjectileMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                }
        }
        F163_amzz_DUNGEON_LinkThingToList(L0473_T_Thing, 0, AP443_ui_ProjectileMapX, AP444_ui_ProjectileMapY);
        M33_SET_MAP_AND_TIME(L0476_s_Event.Map_Time, G272_i_CurrentMapIndex, G313_ul_GameTime + ((P441_T_ExplosionThing == C0xFFE4_THING_EXPLOSION_REBIRTH_STEP1) ? 5 : 1));
        L0476_s_Event.A.A.Type = C25_EVENT_EXPLOSION;
        L0476_s_Event.A.A.Priority = 0;
        L0476_s_Event.C.Slot = L0473_T_Thing;
        L0476_s_Event.B.Location.MapX = AP443_ui_ProjectileMapX;
        L0476_s_Event.B.Location.MapY = AP444_ui_ProjectileMapY;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0476_s_Event);
        if ((P441_T_ExplosionThing == C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT) || (P441_T_ExplosionThing == C0xFF80_THING_EXPLOSION_FIREBALL)) {
                AP443_ui_ProjectileMapX = L0474_i_ProjectileTargetMapX;
                AP444_ui_ProjectileMapY = L0475_i_ProjectileTargetMapY;
                P442_ui_Attack = (P442_ui_Attack >> 1) + 1;
                P442_ui_Attack += M02_RANDOM(P442_ui_Attack) + 1;
                if ((P441_T_ExplosionThing == C0xFF80_THING_EXPLOSION_FIREBALL) || (P442_ui_Attack >>= 1)) {
                        if ((G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (AP443_ui_ProjectileMapX == G306_i_PartyMapX) && (AP444_ui_ProjectileMapY == G307_i_PartyMapY)) {
                                F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount(P442_ui_Attack, MASK0x0001_READY_HAND | MASK0x0002_ACTION_HAND | MASK0x0004_HEAD | MASK0x0008_TORSO | MASK0x0010_LEGS | MASK0x0020_FEET, C1_ATTACK_FIRE);
                                return;
                        }
                        if ((L0473_T_Thing = F175_gzzz_GROUP_GetThing(AP443_ui_ProjectileMapX, AP444_ui_ProjectileMapY)) != C0xFFFE_THING_ENDOFLIST) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                L0472_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L0473_T_Thing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                L0472_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0473_T_Thing);
#endif
                                L0471_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[L0472_ps_Group->Type];
                                if ((L0469_i_CreatureFireResistance = M60_FIRE_RESISTANCE(L0471_ps_CreatureInfo->Resistances)) != C15_IMMUNE_TO_FIRE) {
                                        if (M07_GET(L0471_ps_CreatureInfo->Attributes, MASK0x0040_NON_MATERIAL)) {
                                                P442_ui_Attack >>= 2;
                                        }
                                        if ((P442_ui_Attack -= M02_RANDOM((L0469_i_CreatureFireResistance << 1) + 1)) > 0) {
                                                G364_i_CreatureDamageOutcome = F191_aayz_GROUP_GetDamageAllCreaturesOutcome(L0472_ps_Group, AP443_ui_ProjectileMapX, AP444_ui_ProjectileMapY, P442_ui_Attack, TRUE);
                                        }
                                }
                        }
                }
        }
}

VOID F214_pzzz_PROJECTILE_DeleteEvent(P446_T_Thing)
THING P446_T_Thing;
{
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        F237_rzzz_TIMELINE_DeleteEvent(((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(P446_T_Thing)].EventIndex);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        PROJECTILE* L0477_ps_Projectile;


        L0477_ps_Projectile = (PROJECTILE*)F156_afzz_DUNGEON_GetThingData(P446_T_Thing);
        F237_rzzz_TIMELINE_DeleteEvent(L0477_ps_Projectile->EventIndex);
#endif
}

VOID F215_lzzz_PROJECTILE_Delete(P447_T_ProjectileThing, P448_pT_GroupSlot, P449_i_MapX, P450_i_MapY)
THING P447_T_ProjectileThing;
THING* P448_pT_GroupSlot; /* When not NULL, the projectile associated thing is linked to the list of group possessions. This is used for creatures that keep some weapons thrown at them (Daggers, Arrow, Slayer, Poison Dart and Throwing Star) */
int P449_i_MapX; /* If P448_pT_GroupSlot is NULL then the projectile associated thing is moved to the specified square */
int P450_i_MapY;
{
        register THING L0478_T_PreviousThing;
        register THING L0479_T_Thing;
        register PROJECTILE* L0480_ps_Projectile;
        GENERIC* L0481_ps_Generic;
        char L0482_ac_Unreferenced[10]; /* BUG0_00 Useless code */


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0480_ps_Projectile = &((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(P447_T_ProjectileThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0480_ps_Projectile = (PROJECTILE*)F156_afzz_DUNGEON_GetThingData(P447_T_ProjectileThing);
#endif
        if (M12_TYPE(L0479_T_Thing = L0480_ps_Projectile->Slot) != C15_THING_TYPE_EXPLOSION) {
                if (P448_pT_GroupSlot != NULL) {
                        if ((L0478_T_PreviousThing = *P448_pT_GroupSlot) == C0xFFFE_THING_ENDOFLIST) {
                                L0481_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L0479_T_Thing);
                                L0481_ps_Generic->Next = C0xFFFE_THING_ENDOFLIST;
                                *P448_pT_GroupSlot = L0479_T_Thing;
                        } else {
                                F163_amzz_DUNGEON_LinkThingToList(L0479_T_Thing, L0478_T_PreviousThing, CM1_MAPX_NOT_ON_A_SQUARE, 0);
                        }
                } else {
                        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(M14_TYPE_AND_INDEX(L0479_T_Thing) | M07_GET(P447_T_ProjectileThing, MASK0xC000_THING_CELL), CM2_MAPX_PROJECTILE_ASSOCIATED_OBJECT, 0, P449_i_MapX, P450_i_MapY);
                }
        }
        L0480_ps_Projectile->Next = C0xFFFF_THING_NONE;
}

unsigned int F216_xxxx_PROJECTILE_GetImpactAttack(P451_ps_Projectile, P452_T_Thing)
register PROJECTILE* P451_ps_Projectile;
register THING P452_T_Thing;
{
        register unsigned int L0483_ui_Multiple;
#define A0483_ui_ThingType L0483_ui_Multiple
#define A0483_ui_Attack    L0483_ui_Multiple
        register int L0484_i_KineticEnergy;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        register WEAPON_INFO* L0485_ps_WeaponInfo;
#endif


        G366_i_ProjectilePoisonAttack = 0;
        G367_i_ProjectileAttackType = C3_ATTACK_BLUNT;
        L0484_i_KineticEnergy = P451_ps_Projectile->KineticEnergy;
        if ((A0483_ui_ThingType = M12_TYPE(P452_T_Thing)) != C15_THING_TYPE_EXPLOSION) {
                if (A0483_ui_ThingType == C05_THING_TYPE_WEAPON) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        A0483_ui_Attack = G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(P452_T_Thing)].Type].KineticEnergy;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0485_ps_WeaponInfo = F158_ayzz_DUNGEON_GetWeaponInfo(P452_T_Thing);
                        A0483_ui_Attack = L0485_ps_WeaponInfo->KineticEnergy;
#endif
                        G367_i_ProjectileAttackType = C3_ATTACK_BLUNT;
                } else {
                        A0483_ui_Attack = M04_RANDOM(4);
                }
                A0483_ui_Attack += F140_yzzz_DUNGEON_GetObjectWeight(P452_T_Thing) >> 1;
        } else {
                if (P452_T_Thing == C0xFF81_THING_EXPLOSION_SLIME) {
                        A0483_ui_Attack = M03_RANDOM(16);
                        G366_i_ProjectilePoisonAttack = A0483_ui_Attack + 10;
                        A0483_ui_Attack += M03_RANDOM(32);
                } else {
                        if (P452_T_Thing >= C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL) {
                                G367_i_ProjectileAttackType = C5_ATTACK_MAGIC;
                                if (P452_T_Thing == C0xFF86_THING_EXPLOSION_POISON_BOLT) {
                                        G366_i_ProjectilePoisonAttack = L0484_i_KineticEnergy;
                                        return 1;
                                }
                                return 0;
                        }
                        G367_i_ProjectileAttackType = C1_ATTACK_FIRE;
                        A0483_ui_Attack = M03_RANDOM(16) + M03_RANDOM(16) + 10;
                        if (P452_T_Thing == C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT) {
                                G367_i_ProjectileAttackType = C7_ATTACK_LIGHTNING;
                                A0483_ui_Attack *= 5;
                        }
                }
        }
        A0483_ui_Attack = ((A0483_ui_Attack + L0484_i_KineticEnergy) >> 4) + 1;
        A0483_ui_Attack += M02_RANDOM((A0483_ui_Attack >> 1) + 1) + M04_RANDOM(4);
        A0483_ui_Attack = F025_aatz_MAIN_GetMaximumValue(A0483_ui_Attack >> 1, A0483_ui_Attack - (32 - (P451_ps_Projectile->Attack >> 3)));
        return A0483_ui_Attack;
}

BOOLEAN F217_xxxx_PROJECTILE_HasImpactOccured(P453_i_ImpactType, P454_i_MapXCombo, P455_i_MapYCombo, P456_i_Cell, P457_i_ProjectileThing)
int P453_i_ImpactType;
int P454_i_MapXCombo;
#define AP454_i_ProjectileTargetMapX P454_i_MapXCombo
int P455_i_MapYCombo;
#define AP455_i_ProjectileTargetMapY P455_i_MapYCombo
int P456_i_Cell;
#define AP456_i_ChampionIndex P456_i_Cell
int P457_i_ProjectileThing;
{
        register THING L0486_T_ProjectileAssociatedThing;
        register int L0487_i_Multiple;
#define A0487_i_DoorState  L0487_i_Multiple
#define A0487_i_IconIndex  L0487_i_Multiple
#define A0487_i_Outcome    L0487_i_Multiple
#define A0487_i_WeaponType L0487_i_Multiple
        register int L0488_i_Attack;
        register int L0489_i_ChampionAttack;
        register PROJECTILE* L0490_ps_Projectile;
        register GROUP* L0491_ps_Group;
        POTION* L0492_ps_Potion;
        CREATURE_INFO* L0493_ps_CreatureInfo;
        DOOR* L0494_ps_Door;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        WEAPON* L0495_ps_Weapon;
#endif
        unsigned int* L0496_pui_CreatureHealth;
        THING* L0497_pT_GroupSlot;
        THING L0498_T_ExplosionThing;
        int L0499_i_ProjectileMapX;
        int L0500_i_ProjectileMapY;
        int L0501_i_MapXCombo;
        int L0502_i_MapYCombo;
        unsigned char L0503_uc_Square;
        char L0504_ac_Unreferenced[10]; /* BUG0_00 Useless code */
        BOOLEAN L0505_B_CreateExplosionOnImpact;
        int L0506_i_Unreferenced; /* BUG0_00 Useless code */
        unsigned int L0507_ui_Multiple;
#define A0507_ui_ExplosionAttack L0507_ui_Multiple
#define A0507_ui_SoundIndex      L0507_ui_Multiple
        int L0508_i_PotionPower;
        BOOLEAN L0509_B_RemovePotion;
        int L0510_i_ProjectileAssociatedThingType;
        int L0511_i_CreatureType;
        int L0512_i_CreatureIndex;


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0490_ps_Projectile = &((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(P457_i_ProjectileThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0490_ps_Projectile = (PROJECTILE*)F156_afzz_DUNGEON_GetThingData(P457_i_ProjectileThing);
#endif
        L0501_i_MapXCombo = P454_i_MapXCombo;
        L0502_i_MapYCombo = P455_i_MapYCombo;
        L0509_B_RemovePotion = FALSE;
        G364_i_CreatureDamageOutcome = C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP;
        if ((L0510_i_ProjectileAssociatedThingType = M12_TYPE(L0486_T_ProjectileAssociatedThing = L0490_ps_Projectile->Slot)) == C08_THING_TYPE_POTION) {
                L0491_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0486_T_ProjectileAssociatedThing);
                switch (((POTION*)L0491_ps_Group)->Type) {
                        case C03_POTION_VEN_POTION:
                                L0498_T_ExplosionThing = C0xFF87_THING_EXPLOSION_POISON_CLOUD;
                                goto T217_004;
                        case C19_POTION_FUL_BOMB:
                                L0498_T_ExplosionThing = C0xFF80_THING_EXPLOSION_FIREBALL;
                                T217_004:
                                L0509_B_RemovePotion = TRUE;
                                L0508_i_PotionPower = ((POTION*)L0491_ps_Group)->Power;
                                L0492_ps_Potion = (POTION*)L0491_ps_Group;
                }
        }
        L0505_B_CreateExplosionOnImpact = (L0510_i_ProjectileAssociatedThingType == C15_THING_TYPE_EXPLOSION) && (L0486_T_ProjectileAssociatedThing != C0xFF81_THING_EXPLOSION_SLIME) && (L0486_T_ProjectileAssociatedThing != C0xFF86_THING_EXPLOSION_POISON_BOLT);
        L0497_pT_GroupSlot = NULL;
        L0489_i_ChampionAttack = 0;
        if (P454_i_MapXCombo <= 255) {
                L0499_i_ProjectileMapX = P454_i_MapXCombo;
                L0500_i_ProjectileMapY = P455_i_MapYCombo;
        } else {
                L0499_i_ProjectileMapX = (P454_i_MapXCombo >> 8) - 1;
                L0500_i_ProjectileMapY = (P455_i_MapYCombo >> 8);
                AP454_i_ProjectileTargetMapX &= 0x00FF;
                AP455_i_ProjectileTargetMapY &= 0x00FF;
        }
        switch (P453_i_ImpactType) {
                case C04_ELEMENT_DOOR:
                        A0487_i_DoorState = M36_DOOR_STATE(L0503_uc_Square = G271_ppuc_CurrentMapData[AP454_i_ProjectileTargetMapX][AP455_i_ProjectileTargetMapY]);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0494_ps_Door = &((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY))];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0494_ps_Door = (DOOR*)F157_rzzz_DUNGEON_GetSquareFirstThingData(AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY);
#endif
                        if ((A0487_i_DoorState != C5_DOOR_STATE_DESTROYED) && (L0486_T_ProjectileAssociatedThing == C0xFF84_THING_EXPLOSION_OPEN_DOOR)) {
                                if (L0494_ps_Door->Button) {
                                        F268_fzzz_SENSOR_AddEvent(C10_EVENT_DOOR, AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY, 0, C02_EFFECT_TOGGLE, G313_ul_GameTime + 1);
                                }
                                break;
                        }
                        if ((A0487_i_DoorState == C5_DOOR_STATE_DESTROYED) ||
                            (A0487_i_DoorState <= C1_DOOR_STATE_CLOSED_ONE_FOURTH) ||
                            (M07_GET(G275_as_CurrentMapDoorInfo[L0494_ps_Door->Type].Attributes, MASK0x0002_PROJECTILES_CAN_PASS_THROUGH) &&
                             ((L0510_i_ProjectileAssociatedThingType == C15_THING_TYPE_EXPLOSION) ?
                                (L0486_T_ProjectileAssociatedThing >= C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL) :
                                ((L0490_ps_Projectile->Attack > M03_RANDOM(128)) &&
                                 M07_GET(G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(L0486_T_ProjectileAssociatedThing)].AllowedSlots, MASK0x0100_POUCH_PASS_AND_THROUGH_DOORS)
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_04_IMPROVEMENT Keys cannot pass through a closed door anymore. In previous versions, this could prevent the player from completing the game when throwing a required key through a locked door */
                                 && ((L0510_i_ProjectileAssociatedThingType != C10_THING_TYPE_JUNK) ||
                                  ((A0487_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L0486_T_ProjectileAssociatedThing)) < 0) ||
                                  (!((A0487_i_IconIndex >= C176_ICON_JUNK_IRON_KEY) && (A0487_i_IconIndex <= C191_ICON_JUNK_MASTER_KEY))))
#endif
                                 )))) {
                                return FALSE;
                        }
                        L0488_i_Attack = F216_xxxx_PROJECTILE_GetImpactAttack(L0490_ps_Projectile, L0486_T_ProjectileAssociatedThing) + 1;
                        F232_dzzz_GROUP_IsDoorDestroyedByAttack(AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY, L0488_i_Attack + M02_RANDOM(L0488_i_Attack), FALSE, 0);
                        break;
                case CM2_ELEMENT_CHAMPION:
                        if ((AP456_i_ChampionIndex = F285_szzz_CHAMPION_GetIndexInCell(P456_i_Cell)) < 0) {
                                return FALSE;
                        }
                        L0489_i_ChampionAttack = L0488_i_Attack = F216_xxxx_PROJECTILE_GetImpactAttack(L0490_ps_Projectile, L0486_T_ProjectileAssociatedThing);
                        break;
                case CM1_ELEMENT_CREATURE:
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0491_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(F175_gzzz_GROUP_GetThing(AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY))];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0491_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(F175_gzzz_GROUP_GetThing(AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY));
#endif
                        if (!(L0512_i_CreatureIndex = F176_avzz_GROUP_GetCreatureOrdinalInCell(L0491_ps_Group, P456_i_Cell))) {
                                return FALSE;
                        }
                        L0512_i_CreatureIndex--;
                        L0493_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[L0511_i_CreatureType = L0491_ps_Group->Type];
                        if ((L0486_T_ProjectileAssociatedThing == C0xFF80_THING_EXPLOSION_FIREBALL) && (L0511_i_CreatureType == C11_CREATURE_BLACK_FLAME)) {
                                L0496_pui_CreatureHealth = &L0491_ps_Group->Health[L0512_i_CreatureIndex];
                                *L0496_pui_CreatureHealth = F024_aatz_MAIN_GetMinimumValue(1000, *L0496_pui_CreatureHealth + F216_xxxx_PROJECTILE_GetImpactAttack(L0490_ps_Projectile, L0486_T_ProjectileAssociatedThing));
                                goto T217_044;
                        }
                        if (M07_GET(L0493_ps_CreatureInfo->Attributes, MASK0x0040_NON_MATERIAL) && (L0486_T_ProjectileAssociatedThing != C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL)) {
                                return FALSE;
                        }
                        if (L0488_i_Attack = (unsigned int)((unsigned long)F216_xxxx_PROJECTILE_GetImpactAttack(L0490_ps_Projectile, L0486_T_ProjectileAssociatedThing) << 6) / L0493_ps_CreatureInfo->Defense) {
                                if ((A0487_i_Outcome = F190_zzzz_GROUP_GetDamageCreatureOutcome(L0491_ps_Group, L0512_i_CreatureIndex, AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY, L0488_i_Attack + F192_ayzz_GROUP_GetResistanceAdjustedPoisonAttack(L0511_i_CreatureType, G366_i_ProjectilePoisonAttack), TRUE)) != C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP) {
                                        F209_xzzz_GROUP_ProcessEvents29to41(AP454_i_ProjectileTargetMapX, AP455_i_ProjectileTargetMapY, CM2_EVENT_CREATE_REACTION_EVENT_30_HIT_BY_PROJECTILE, 0);
                                }
                                G364_i_CreatureDamageOutcome = A0487_i_Outcome;
                                if (!L0505_B_CreateExplosionOnImpact &&
                                    (A0487_i_Outcome == C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP) &&
                                    (L0510_i_ProjectileAssociatedThingType == C05_THING_TYPE_WEAPON) &&
                                    M07_GET(L0493_ps_CreatureInfo->Attributes, MASK0x0400_KEEP_THROWN_SHARP_WEAPONS)) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                        A0487_i_WeaponType = ((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(L0486_T_ProjectileAssociatedThing)].Type;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                        L0495_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(L0486_T_ProjectileAssociatedThing);
                                        A0487_i_WeaponType = L0495_ps_Weapon->Type;
#endif
                                        if ((A0487_i_WeaponType == C08_WEAPON_DAGGER) || (A0487_i_WeaponType == C27_WEAPON_ARROW) || (A0487_i_WeaponType == C28_WEAPON_SLAYER) || (A0487_i_WeaponType == C31_WEAPON_POISON_DART) || (A0487_i_WeaponType == C32_WEAPON_THROWING_STAR)) {
                                                L0497_pT_GroupSlot = &L0491_ps_Group->Slot;
                                        }
                                }
                        }
        }
        if (L0489_i_ChampionAttack && F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(AP456_i_ChampionIndex, L0488_i_Attack, MASK0x0004_HEAD | MASK0x0008_TORSO, G367_i_ProjectileAttackType) && G366_i_ProjectilePoisonAttack && M05_RANDOM(2)) {
                F322_lzzz_CHAMPION_Poison(AP456_i_ChampionIndex, G366_i_ProjectilePoisonAttack);
        }
        if (L0505_B_CreateExplosionOnImpact || L0509_B_RemovePotion) {
                if (L0509_B_RemovePotion) {
                        L0486_T_ProjectileAssociatedThing = L0498_T_ExplosionThing;
                        A0507_ui_ExplosionAttack = L0508_i_PotionPower;
                } else {
                        A0507_ui_ExplosionAttack = L0490_ps_Projectile->KineticEnergy;
                }
                if ((L0486_T_ProjectileAssociatedThing == C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT) && !(A0507_ui_ExplosionAttack >>= 1)) {
                        goto T217_044;
                }
                F213_hzzz_EXPLOSION_Create(L0486_T_ProjectileAssociatedThing, A0507_ui_ExplosionAttack, L0501_i_MapXCombo, L0502_i_MapYCombo, (L0486_T_ProjectileAssociatedThing == C0xFF87_THING_EXPLOSION_POISON_CLOUD) ? C255_SINGLE_CENTERED_CREATURE : P456_i_Cell);
        } else {
                if (M12_TYPE(L0486_T_ProjectileAssociatedThing) == C05_THING_TYPE_WEAPON) {
                        A0507_ui_SoundIndex = C00_SOUND_METALLIC_THUD;
                } else {
                        if (L0486_T_ProjectileAssociatedThing == C0xFF86_THING_EXPLOSION_POISON_BOLT) {
                                A0507_ui_SoundIndex = C13_SOUND_SPELL;
                        } else {
                                A0507_ui_SoundIndex = C04_SOUND_WOODEN_THUD;
                        }
                }
                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(A0507_ui_SoundIndex, L0499_i_ProjectileMapX, L0500_i_ProjectileMapY, C01_MODE_PLAY_IF_PRIORITIZED);
        }
        T217_044:
        if (L0509_B_RemovePotion) {
                L0492_ps_Potion->Next = C0xFFFF_THING_NONE;
                L0490_ps_Projectile->Slot = L0498_T_ExplosionThing;
        }
        F164_dzzz_DUNGEON_UnlinkThingFromList(P457_i_ProjectileThing, 0, L0499_i_ProjectileMapX, L0500_i_ProjectileMapY);
        F215_lzzz_PROJECTILE_Delete(P457_i_ProjectileThing, L0497_pT_GroupSlot, L0499_i_ProjectileMapX, L0500_i_ProjectileMapY);
        return TRUE;
}

int F218_ezzz_PROJECTILE_GetImpactCount(P458_i_ImpactType, P459_i_MapX, P460_i_MapY, P461_i_Cell)
int P458_i_ImpactType;
int P459_i_MapX;
int P460_i_MapY;
register int P461_i_Cell;
{
        register THING L0513_T_Thing;
        register int L0514_i_ImpactCount;


        L0514_i_ImpactCount = 0;
        G364_i_CreatureDamageOutcome = C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP;
        T218_001:
        for(L0513_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P459_i_MapX, P460_i_MapY); L0513_T_Thing != C0xFFFE_THING_ENDOFLIST; L0513_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0513_T_Thing)) {
                if ((M12_TYPE(L0513_T_Thing) == C14_THING_TYPE_PROJECTILE) &&
                    (M11_CELL(L0513_T_Thing) == P461_i_Cell) &&
                    F217_xxxx_PROJECTILE_HasImpactOccured(P458_i_ImpactType, P459_i_MapX, P460_i_MapY, P461_i_Cell, L0513_T_Thing)) {
                        F214_pzzz_PROJECTILE_DeleteEvent(L0513_T_Thing);
                        L0514_i_ImpactCount++;
                        if ((P458_i_ImpactType == CM1_ELEMENT_CREATURE) && (G364_i_CreatureDamageOutcome == C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP)) {
                                break;
                        }
                        goto T218_001;
                }
        }
        return L0514_i_ImpactCount;
}

VOID F219_xxxx_PROJECTILE_ProcessEvents48To49_Projectile(P462_ps_Event)
EVENT* P462_ps_Event;
{
        register THING L0515_T_ProjectileThingNewCell;
        register unsigned int L0516_ui_Multiple;
#define A0516_ui_StepEnergy L0516_ui_Multiple
#define A0516_ui_Square     L0516_ui_Multiple
        register int L0517_i_ProjectileDirection;
        register unsigned int L0518_ui_Cell;
        register EVENT* L0519_ps_Event;
        register PROJECTILE* L0520_ps_Projectile;
        THING L0521_T_ProjectileThing;
        BOOLEAN L0522_B_ProjectileMovesToOtherSquare;
        int L0523_i_DestinationMapX;
        int L0524_i_DestinationMapY;
        int L0525_i_SourceMapX;
        int L0526_i_SourceMapY;
        EVENT L0527_s_Event;


        L0527_s_Event = *P462_ps_Event;
        L0519_ps_Event = &L0527_s_Event;
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0520_ps_Projectile = &((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(L0521_T_ProjectileThing = L0515_T_ProjectileThingNewCell = L0519_ps_Event->B.Slot)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0520_ps_Projectile = (PROJECTILE*)F156_afzz_DUNGEON_GetThingData(L0521_T_ProjectileThing = L0515_T_ProjectileThingNewCell = L0519_ps_Event->B.Slot);
#endif
        L0523_i_DestinationMapX = L0519_ps_Event->C.Projectile.MapX;
        L0524_i_DestinationMapY = L0519_ps_Event->C.Projectile.MapY;
        if (L0519_ps_Event->A.A.Type == C48_EVENT_MOVE_PROJECTILE_IGNORE_IMPACTS) {
                L0519_ps_Event->A.A.Type = C49_EVENT_MOVE_PROJECTILE;
        } else {
                L0518_ui_Cell = M11_CELL(L0515_T_ProjectileThingNewCell);
                if ((G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (L0523_i_DestinationMapX == G306_i_PartyMapX) && (L0524_i_DestinationMapY == G307_i_PartyMapY) && F217_xxxx_PROJECTILE_HasImpactOccured(CM2_ELEMENT_CHAMPION, L0523_i_DestinationMapX, L0524_i_DestinationMapY, L0518_ui_Cell, L0515_T_ProjectileThingNewCell)) {
                        return;
                }
                if ((F175_gzzz_GROUP_GetThing(L0523_i_DestinationMapX, L0524_i_DestinationMapY) != C0xFFFE_THING_ENDOFLIST) && F217_xxxx_PROJECTILE_HasImpactOccured(CM1_ELEMENT_CREATURE, L0523_i_DestinationMapX, L0524_i_DestinationMapY, L0518_ui_Cell, L0521_T_ProjectileThing)) {
                        return;
                }
                if (L0520_ps_Projectile->KineticEnergy <= (A0516_ui_StepEnergy = L0519_ps_Event->C.Projectile.StepEnergy)) {
                        F164_dzzz_DUNGEON_UnlinkThingFromList(L0515_T_ProjectileThingNewCell = L0521_T_ProjectileThing, 0, L0523_i_DestinationMapX, L0524_i_DestinationMapY);
                        F215_lzzz_PROJECTILE_Delete(L0515_T_ProjectileThingNewCell, NULL, L0523_i_DestinationMapX, L0524_i_DestinationMapY);
                        return;
                }
                L0520_ps_Projectile->KineticEnergy -= A0516_ui_StepEnergy;
                if (L0520_ps_Projectile->Attack < A0516_ui_StepEnergy) {
                        L0520_ps_Projectile->Attack = 0;
                } else {
                        L0520_ps_Projectile->Attack -= A0516_ui_StepEnergy;
                }
        }
        if (L0522_B_ProjectileMovesToOtherSquare = ((L0517_i_ProjectileDirection = L0519_ps_Event->C.Projectile.Direction) == (L0518_ui_Cell = M11_CELL(L0515_T_ProjectileThingNewCell = L0519_ps_Event->B.Slot))) || (M17_NEXT(L0517_i_ProjectileDirection) == (int)L0518_ui_Cell)) {
                        L0525_i_SourceMapX = L0523_i_DestinationMapX;
                        L0526_i_SourceMapY = L0524_i_DestinationMapY;
                        L0523_i_DestinationMapX += G233_ai_Graphic559_DirectionToStepEastCount[L0517_i_ProjectileDirection], L0524_i_DestinationMapY += G234_ai_Graphic559_DirectionToStepNorthCount[L0517_i_ProjectileDirection];
                        if ((M34_SQUARE_TYPE(A0516_ui_Square = F151_rzzz_DUNGEON_GetSquare(L0523_i_DestinationMapX, L0524_i_DestinationMapY)) == C00_ELEMENT_WALL) ||
                            ((M34_SQUARE_TYPE(A0516_ui_Square) == C06_ELEMENT_FAKEWALL) && !M07_GET(A0516_ui_Square, (MASK0x0001_FAKEWALL_IMAGINARY | MASK0x0004_FAKEWALL_OPEN))) ||
                            ((M34_SQUARE_TYPE(A0516_ui_Square) == C03_ELEMENT_STAIRS) && (M34_SQUARE_TYPE(G271_ppuc_CurrentMapData[L0525_i_SourceMapX][L0526_i_SourceMapY]) == C03_ELEMENT_STAIRS))) {
                                if (F217_xxxx_PROJECTILE_HasImpactOccured(M34_SQUARE_TYPE(A0516_ui_Square), L0525_i_SourceMapX, L0526_i_SourceMapY, L0518_ui_Cell, L0515_T_ProjectileThingNewCell)) {
                                        return;
                                }
                        }
        }
        if ((L0517_i_ProjectileDirection & 0x0001) == (L0518_ui_Cell & 0x0001)) {
                L0518_ui_Cell--;
        } else {
                L0518_ui_Cell++;
        }
        L0515_T_ProjectileThingNewCell = M15_THING_WITH_NEW_CELL(L0515_T_ProjectileThingNewCell, L0518_ui_Cell &= 0x0003);
        if (L0522_B_ProjectileMovesToOtherSquare) {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0515_T_ProjectileThingNewCell, L0525_i_SourceMapX, L0526_i_SourceMapY, L0523_i_DestinationMapX, L0524_i_DestinationMapY);
                L0519_ps_Event->C.Projectile.MapX = G397_i_MoveResultMapX;
                L0519_ps_Event->C.Projectile.MapY = G398_i_MoveResultMapY;
                L0519_ps_Event->C.Projectile.Direction = G400_i_MoveResultDirection;
                L0515_T_ProjectileThingNewCell = M15_THING_WITH_NEW_CELL(L0515_T_ProjectileThingNewCell, G401_ui_MoveResultCell);
                M31_SET_MAP(L0519_ps_Event->Map_Time, G399_ui_MoveResultMapIndex);
        } else {
                if ((M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(L0523_i_DestinationMapX, L0524_i_DestinationMapY)) == C04_ELEMENT_DOOR) && F217_xxxx_PROJECTILE_HasImpactOccured(C04_ELEMENT_DOOR, L0523_i_DestinationMapX, L0524_i_DestinationMapY, L0518_ui_Cell, L0521_T_ProjectileThing)) {
                        return;
                }
                F164_dzzz_DUNGEON_UnlinkThingFromList(L0515_T_ProjectileThingNewCell, 0, L0523_i_DestinationMapX, L0524_i_DestinationMapY);
                F163_amzz_DUNGEON_LinkThingToList(L0515_T_ProjectileThingNewCell, 0, L0523_i_DestinationMapX, L0524_i_DestinationMapY);
        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_20_IMPROVEMENT */
        L0519_ps_Event->Map_Time += (G272_i_CurrentMapIndex == G309_i_PartyMapIndex) ? 1 : 3;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_20_IMPROVEMENT Projectiles now move at the same speed on all maps instead of moving slower on maps other than the party map */
        L0519_ps_Event->Map_Time++;
#endif
        L0519_ps_Event->B.Slot = L0515_T_ProjectileThingNewCell;
        L0520_ps_Projectile->EventIndex = F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(L0519_ps_Event);
}

VOID F220_xxxx_EXPLOSION_ProcessEvent25_Explosion(P463_ps_Event)
register EVENT* P463_ps_Event;
{
        register unsigned int L0528_ui_MapX;
        register unsigned int L0529_ui_MapY;
        register int L0530_i_Attack;
        register int L0531_i_Multiple;
#define A0531_i_SquareType    L0531_i_Multiple
#define A0531_i_CreatureCount L0531_i_Multiple
        register EXPLOSION* L0532_ps_Explosion;
        GROUP* L0533_ps_Group;
        CREATURE_INFO* L0534_ps_CreatureInfo;
        THING L0535_T_GroupThing;
        THING L0536_T_ExplosionThing;
        int L0537_i_Multiple;
#define A0537_i_CreatureType                L0537_i_Multiple
#define A0537_i_NonMaterialAdditionalAttack L0537_i_Multiple
        BOOLEAN L0538_B_ExplosionOnPartySquare;
        EVENT L0539_s_Event;


        L0528_ui_MapX = P463_ps_Event->B.Location.MapX;
        L0529_ui_MapY = P463_ps_Event->B.Location.MapY;
        L0532_ps_Explosion = &((EXPLOSION*)G284_apuc_ThingData[C15_THING_TYPE_EXPLOSION])[M13_INDEX(P463_ps_Event->C.Slot)];
        A0531_i_SquareType = M34_SQUARE_TYPE(G271_ppuc_CurrentMapData[L0528_ui_MapX][L0529_ui_MapY]);
        L0538_B_ExplosionOnPartySquare = (G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (L0528_ui_MapX == G306_i_PartyMapX) && (L0529_ui_MapY == G307_i_PartyMapY);
        if ((L0535_T_GroupThing = F175_gzzz_GROUP_GetThing(L0528_ui_MapX, L0529_ui_MapY)) != C0xFFFE_THING_ENDOFLIST) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0533_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L0535_T_GroupThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0533_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0535_T_GroupThing);
#endif
                L0534_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[A0537_i_CreatureType = L0533_ps_Group->Type];
        }
        if ((L0536_T_ExplosionThing = C0xFF80_THING_FIRST_EXPLOSION + L0532_ps_Explosion->Type) == C0xFF87_THING_EXPLOSION_POISON_CLOUD) {
                L0530_i_Attack = F025_aatz_MAIN_GetMaximumValue(1, F024_aatz_MAIN_GetMinimumValue(L0532_ps_Explosion->Attack >> 5, 4) + M05_RANDOM(2)); /* Value between 1 and 5 */
        } else {
                L0530_i_Attack = (L0532_ps_Explosion->Attack >> 1) + 1;
                L0530_i_Attack += M02_RANDOM(L0530_i_Attack) + 1;
        }
        switch (L0536_T_ExplosionThing) {
                case C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT:
                        if (!(L0530_i_Attack >>= 1)) {
                                break;
                        }
                case C0xFF80_THING_EXPLOSION_FIREBALL:
                        if (A0531_i_SquareType == C04_ELEMENT_DOOR) {
                                F232_dzzz_GROUP_IsDoorDestroyedByAttack(L0528_ui_MapX, L0529_ui_MapY, L0530_i_Attack, TRUE, 0);
                        }
                        break;
                case C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL:
                        if ((L0535_T_GroupThing != C0xFFFE_THING_ENDOFLIST) && M07_GET(L0534_ps_CreatureInfo->Attributes, MASK0x0040_NON_MATERIAL)) {
                                if ((A0537_i_CreatureType == C19_CREATURE_MATERIALIZER_ZYTAZ) && (G272_i_CurrentMapIndex == G309_i_PartyMapIndex)) {
                                        L0530_i_Attack -= (A0537_i_NonMaterialAdditionalAttack = L0530_i_Attack >> 3);
                                        A0537_i_NonMaterialAdditionalAttack <<= 1;
                                        A0537_i_NonMaterialAdditionalAttack++;
                                        A0531_i_CreatureCount = L0533_ps_Group->Count;
                                        do {
                                                if (M07_GET(G375_ps_ActiveGroups[L0533_ps_Group->ActiveGroupIndex].Aspect[A0531_i_CreatureCount], MASK0x0080_IS_ATTACKING)) { /* Materializer / Zytaz can only be damaged while they are attacking */
                                                        F190_zzzz_GROUP_GetDamageCreatureOutcome(L0533_ps_Group, A0531_i_CreatureCount, L0528_ui_MapX, L0529_ui_MapY, L0530_i_Attack + M02_RANDOM(A0537_i_NonMaterialAdditionalAttack) + M04_RANDOM(4), TRUE);
                                                }
                                        } while (--A0531_i_CreatureCount >= 0);
                                } else {
                                        F191_aayz_GROUP_GetDamageAllCreaturesOutcome(L0533_ps_Group, L0528_ui_MapX, L0529_ui_MapY, L0530_i_Attack, TRUE);
                                }
                        }
                        break;
                case C0xFFE4_THING_EXPLOSION_REBIRTH_STEP1:
                        L0532_ps_Explosion->Type++;
                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C05_SOUND_STRONG_EXPLOSION, L0528_ui_MapX, L0529_ui_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
                        goto T220_026;
                case C0xFFA8_THING_EXPLOSION_SMOKE:
                        if (L0532_ps_Explosion->Attack > 55) {
                                L0532_ps_Explosion->Attack -= 40;
                                goto T220_026;
                        }
                        break;
                case C0xFF87_THING_EXPLOSION_POISON_CLOUD:
                        if (L0538_B_ExplosionOnPartySquare) {
                                F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount(L0530_i_Attack, MASK0x0000_NO_WOUND, C0_ATTACK_NORMAL);
                        } else {
                                if ((L0535_T_GroupThing != C0xFFFE_THING_ENDOFLIST) && (L0530_i_Attack = F192_ayzz_GROUP_GetResistanceAdjustedPoisonAttack(A0537_i_CreatureType, L0530_i_Attack)) && (F191_aayz_GROUP_GetDamageAllCreaturesOutcome(L0533_ps_Group, L0528_ui_MapX, L0529_ui_MapY, L0530_i_Attack, TRUE) != C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP) && (L0530_i_Attack > 2)) {
                                        F209_xzzz_GROUP_ProcessEvents29to41(L0528_ui_MapX, L0529_ui_MapY, CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE, 0);
                                }
                        }
                        if (L0532_ps_Explosion->Attack >= 6) {
                                L0532_ps_Explosion->Attack -= 3;
                                T220_026:
                                L0539_s_Event = *P463_ps_Event;
                                L0539_s_Event.Map_Time++;
                                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0539_s_Event);
                                return;
                        }
        }
        F164_dzzz_DUNGEON_UnlinkThingFromList(P463_ps_Event->C.Slot, 0, L0528_ui_MapX, L0529_ui_MapY);
        L0532_ps_Explosion->Next = C0xFFFF_THING_NONE;
}
