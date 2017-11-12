#include "DEFS.H"

/*_Global variables_*/
ACTIVE_GROUP* G375_ps_ActiveGroups;
unsigned int G376_ui_MaximumActiveGroupCount;
unsigned int G377_ui_CurrentActiveGroupCount = 0;
int G378_i_CurrentGroupMapX;
int G379_i_CurrentGroupMapY;
THING G380_T_CurrentGroupThing;
unsigned int G381_ui_CurrentGroupDistanceToParty;
int G382_i_CurrentGroupPrimaryDirectionToParty;
int G383_i_CurrentGroupSecondaryDirectionToParty;
char G384_ac_GroupMovementTestedDirections[4];
char G385_ac_FluxCages[4];
unsigned int G386_ui_FluxCageCount;
BOOLEAN G387_B_GroupMovementBlockedByWallStairsPitFakeWallFluxcageTeleporter;
THING G388_T_GroupMovementBlockedByGroupThing;
BOOLEAN G389_B_GroupMovementBlockedByDoor;
BOOLEAN G390_B_GroupMovementBlockedByParty;
int G391_i_DropMovingCreatureFixedPossessionsCellCount;
unsigned char G392_auc_DropMovingCreatureFixedPossessionsCells[4];
#ifndef NOCOPYPROTECTION
char G393_ac_CodePatch4_COPYPROTECTIONE[68];
#endif


overlay "dunman"

THING F175_gzzz_GROUP_GetThing(P323_i_MapX, P324_i_MapY)
int P323_i_MapX;
int P324_i_MapY;
{
        register THING L0317_T_Thing;


        for(L0317_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P323_i_MapX, P324_i_MapY); (L0317_T_Thing != C0xFFFE_THING_ENDOFLIST) && (M12_TYPE(L0317_T_Thing) != C04_THING_TYPE_GROUP); L0317_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0317_T_Thing));
        return L0317_T_Thing;
}

int F176_avzz_GROUP_GetCreatureOrdinalInCell(P325_ps_Group, P326_ui_Cell)
register GROUP* P325_ps_Group;
register unsigned int P326_ui_Cell;
{
        register unsigned char L0318_uc_GroupCells;
        register unsigned char L0319_uc_CreatureIndex;
        register unsigned char L0320_uc_CreatureCell;


        if ((L0318_uc_GroupCells = F145_rzzz_DUNGEON_GetGroupCells(P325_ps_Group, G272_i_CurrentMapIndex)) == C255_SINGLE_CENTERED_CREATURE) { /* A single centered creature in the group is present on all cells */
                return M00_INDEX_TO_ORDINAL(0);
        }
        L0319_uc_CreatureIndex = P325_ps_Group->Count;
        if (M07_GET(G243_as_Graphic559_CreatureInfo[P325_ps_Group->Type].Attributes, MASK0x0003_SIZE) == C1_SIZE_HALF_SQUARE) {
                if ((F147_aawz_DUNGEON_GetGroupDirections(P325_ps_Group, G272_i_CurrentMapIndex) & 0x0001) == (P326_ui_Cell & 0x0001)) {
                        P326_ui_Cell = M20_PREVIOUS(P326_ui_Cell);
                }
                do {
                        if (((L0320_uc_CreatureCell = M50_CREATURE_VALUE(L0318_uc_GroupCells, L0319_uc_CreatureIndex)) == P326_ui_Cell) || (L0320_uc_CreatureCell == M17_NEXT(P326_ui_Cell))) {
                                return M00_INDEX_TO_ORDINAL(L0319_uc_CreatureIndex);
                        }
                } while (L0319_uc_CreatureIndex--);
        } else {
                do {
                        if (M50_CREATURE_VALUE(L0318_uc_GroupCells, L0319_uc_CreatureIndex) == P326_ui_Cell) {
                                return M00_INDEX_TO_ORDINAL(L0319_uc_CreatureIndex);
                        }
                } while (L0319_uc_CreatureIndex--);
        }
        return 0;
}

int F177_aszz_GROUP_GetMeleeTargetCreatureOrdinal(P327_i_GroupMapX, P328_i_GroupMapY, P329_i_PartyMapX, P330_i_PartyMapY, P331_ui_ChampionCell)
int P327_i_GroupMapX;
int P328_i_GroupMapY;
int P329_i_PartyMapX;
int P330_i_PartyMapY;
unsigned int P331_ui_ChampionCell;
{
        register unsigned int L0321_ui_Counter;
        register int L0322_i_CreatureOrdinal;
        register THING L0323_T_GroupThing;
        register GROUP* L0324_ps_Group;
        unsigned char L0325_auc_OrderedCellsToAttack[4];


        if ((L0323_T_GroupThing = F175_gzzz_GROUP_GetThing(P327_i_GroupMapX, P328_i_GroupMapY)) == C0xFFFE_THING_ENDOFLIST) {
                return 0;
        }
        L0324_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0323_T_GroupThing);
        F229_hzzz_GROUP_SetOrderedCellsToAttack(L0325_auc_OrderedCellsToAttack, P327_i_GroupMapX, P328_i_GroupMapY, P329_i_PartyMapX, P330_i_PartyMapY, P331_ui_ChampionCell);
        L0321_ui_Counter = 0;
        while () {
                if (L0322_i_CreatureOrdinal = F176_avzz_GROUP_GetCreatureOrdinalInCell(L0324_ps_Group, L0325_auc_OrderedCellsToAttack[L0321_ui_Counter])) {
                        return L0322_i_CreatureOrdinal;
                }
                L0321_ui_Counter++;
        }
}

unsigned int F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(P332_ui_GroupValue, P333_ui_CreatureIndex, P334_ui_CreatureValue)
unsigned int P332_ui_GroupValue;
register unsigned int P333_ui_CreatureIndex;
register unsigned int P334_ui_CreatureValue;
{
        P334_ui_CreatureValue &= 0x0003;
        P334_ui_CreatureValue <<= (P333_ui_CreatureIndex <<= 1);
        return P334_ui_CreatureValue | (P332_ui_GroupValue & ~(3 << P333_ui_CreatureIndex));
}

long F179_xxxx_GROUP_GetCreatureAspectUpdateTime(P335_ps_ActiveGroup, P336_i_CreatureIndex, P337_B_IsAttacking)
register ACTIVE_GROUP* P335_ps_ActiveGroup;
register int P336_i_CreatureIndex;
BOOLEAN P337_B_IsAttacking;
{
        register unsigned int L0326_ui_Multiple;
#define A0326_ui_Aspect         L0326_ui_Multiple
#define A0326_ui_AnimationTicks L0326_ui_Multiple
        register unsigned int L0327_ui_CreatureGraphicInfo;
        register int L0328_i_Offset;
        register GROUP* L0329_ps_Group;
        BOOLEAN L0330_B_ProcessGroup;
        int L0331_i_CreatureType;


        L0329_ps_Group = &(((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[P335_ps_ActiveGroup->GroupThingIndex]);
        L0327_ui_CreatureGraphicInfo = G243_as_Graphic559_CreatureInfo[L0331_i_CreatureType = L0329_ps_Group->Type].GraphicInfo;
        if (L0330_B_ProcessGroup = (P336_i_CreatureIndex < 0)) { /* If the creature index is negative then all creatures in the group are processed */
                P336_i_CreatureIndex = L0329_ps_Group->Count;
        }
        do {
                A0326_ui_Aspect = P335_ps_ActiveGroup->Aspect[P336_i_CreatureIndex];
                A0326_ui_Aspect &= MASK0x0080_IS_ATTACKING | MASK0x0040_FLIP_BITMAP;
                if (L0328_i_Offset = M52_MAXIMUM_HORIZONTAL_OFFSET(L0327_ui_CreatureGraphicInfo)) {
                        L0328_i_Offset = M02_RANDOM(L0328_i_Offset);
                        if (M05_RANDOM(2)) {
                                L0328_i_Offset = (-L0328_i_Offset) & 0x0007;
                        }
                        M24_SET_HORIZONTAL_OFFSET(A0326_ui_Aspect, L0328_i_Offset);
                }
                if (L0328_i_Offset = M53_MAXIMUM_VERTICAL_OFFSET(L0327_ui_CreatureGraphicInfo)) {
                        L0328_i_Offset = M02_RANDOM(L0328_i_Offset);
                        if (M05_RANDOM(2)) {
                                L0328_i_Offset = (-L0328_i_Offset) & 0x0007;
                        }
                        M25_SET_VERTICAL_OFFSET(A0326_ui_Aspect, L0328_i_Offset);
                }
                if (P337_B_IsAttacking) {
                        if (M07_GET(L0327_ui_CreatureGraphicInfo, MASK0x0200_FLIP_ATTACK)) {
                                if (M07_GET(A0326_ui_Aspect, MASK0x0080_IS_ATTACKING) && (L0331_i_CreatureType == C18_CREATURE_ANIMATED_ARMOUR_DETH_KNIGHT)) {
                                        if (M05_RANDOM(2)) {
                                                M10_TOGGLE(A0326_ui_Aspect, MASK0x0040_FLIP_BITMAP);
                                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C16_SOUND_COMBAT, G378_i_CurrentGroupMapX, G379_i_CurrentGroupMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                        }
                                } else {
                                        if (!M07_GET(A0326_ui_Aspect, MASK0x0080_IS_ATTACKING) || !M07_GET(L0327_ui_CreatureGraphicInfo, MASK0x0400_FLIP_DURING_ATTACK)) {
                                                if (M05_RANDOM(2)) {
                                                        M08_SET(A0326_ui_Aspect, MASK0x0040_FLIP_BITMAP);
                                                } else {
                                                        M09_CLEAR(A0326_ui_Aspect, MASK0x0040_FLIP_BITMAP);
                                                }
                                        }
                                }
                        } else {
                                M09_CLEAR(A0326_ui_Aspect, MASK0x0040_FLIP_BITMAP);
                        }
                        M08_SET(A0326_ui_Aspect, MASK0x0080_IS_ATTACKING);
                } else {
                        if (M07_GET(L0327_ui_CreatureGraphicInfo, MASK0x0004_FLIP_NON_ATTACK)) {
                                if (M05_RANDOM(2)) {
                                        M08_SET(A0326_ui_Aspect, MASK0x0040_FLIP_BITMAP);
                                } else {
                                        M09_CLEAR(A0326_ui_Aspect, MASK0x0040_FLIP_BITMAP);
                                }
                        } else {
                                M09_CLEAR(A0326_ui_Aspect, MASK0x0040_FLIP_BITMAP);
                        }
                        M09_CLEAR(A0326_ui_Aspect, MASK0x0080_IS_ATTACKING);
                }
                P335_ps_ActiveGroup->Aspect[P336_i_CreatureIndex] = A0326_ui_Aspect;
        } while (L0330_B_ProcessGroup && (P336_i_CreatureIndex--));
        A0326_ui_AnimationTicks = G243_as_Graphic559_CreatureInfo[L0329_ps_Group->Type].AnimationTicks;
        return G313_ul_GameTime + (P337_B_IsAttacking ? M64_NEXT_ATTACK_ASPECT_UPDATE_TICKS(A0326_ui_AnimationTicks) : M63_NEXT_NON_ATTACK_ASPECT_UPDATE_TICKS(A0326_ui_AnimationTicks)) + M05_RANDOM(2);
}

VOID F180_hzzz_GROUP_StartWandering(P338_i_MapX, P339_i_MapY)
int P338_i_MapX;
int P339_i_MapY;
{
        register GROUP* L0332_ps_Group;
        EVENT L0333_s_Event;


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0332_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(F175_gzzz_GROUP_GetThing(P338_i_MapX, P339_i_MapY))];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0332_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(F175_gzzz_GROUP_GetThing(P338_i_MapX, P339_i_MapY));
#endif
        if (L0332_ps_Group->Behavior >= C4_BEHAVIOR_USELESS) {
                L0332_ps_Group->Behavior = C0_BEHAVIOR_WANDER;
        }
        M33_SET_MAP_AND_TIME(L0333_s_Event.Map_Time, G272_i_CurrentMapIndex, (G313_ul_GameTime + 1));
        L0333_s_Event.A.A.Type = C37_EVENT_UPDATE_BEHAVIOR_GROUP;
        L0333_s_Event.A.A.Priority = 255 - G243_as_Graphic559_CreatureInfo[L0332_ps_Group->Type].MovementTicks; /* The fastest creatures (with small MovementTicks value) get higher event priority */
        L0333_s_Event.C.Ticks = 0;
        L0333_s_Event.B.Location.MapX = P338_i_MapX;
        L0333_s_Event.B.Location.MapY = P339_i_MapY;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0333_s_Event);
}

VOID F181_czzz_GROUP_DeleteEvents(P340_i_MapX, P341_i_MapY)
register int P340_i_MapX;
register int P341_i_MapY;
{
        register int L0334_i_EventIndex;
        register unsigned int L0335_ui_EventType;
        register EVENT* L0336_ps_Event;


#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
        L0334_i_EventIndex = 0, L0336_ps_Event = G370_ps_Events;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
        L0336_ps_Event = G370_ps_Events;
        L0334_i_EventIndex = 0;
#endif
        while (L0334_i_EventIndex < G369_ui_EventMaximumCount) {
                if ((M29_MAP(L0336_ps_Event->Map_Time) == G272_i_CurrentMapIndex) &&
                    ((L0335_ui_EventType = L0336_ps_Event->A.A.Type) > C29_EVENT_GROUP_REACTION_DANGER_ON_SQUARE - 1) && (L0335_ui_EventType < C41_EVENT_UPDATE_BEHAVIOR_CREATURE_3 + 1) &&
                    (L0336_ps_Event->B.Location.MapX == P340_i_MapX) && (L0336_ps_Event->B.Location.MapY == P341_i_MapY)) {
                        F237_rzzz_TIMELINE_DeleteEvent(L0334_i_EventIndex);
                }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                L0336_ps_Event++, L0334_i_EventIndex++;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                L0336_ps_Event++;
                L0334_i_EventIndex++;
#endif
        }
}

VOID F182_aqzz_GROUP_StopAttacking(P342_ps_ActiveGroup, P343_i_MapX, P344_i_MapY)
ACTIVE_GROUP* P342_ps_ActiveGroup;
int P343_i_MapX;
int P344_i_MapY;
{
        register int L0337_i_CreatureIndex;


        L0337_i_CreatureIndex = 0;
        while (L0337_i_CreatureIndex < 4) {
                M09_CLEAR(P342_ps_ActiveGroup->Aspect[L0337_i_CreatureIndex++], MASK0x0080_IS_ATTACKING);
        }
        F181_czzz_GROUP_DeleteEvents(P343_i_MapX, P344_i_MapY);
}

VOID F183_kzzz_GROUP_AddActiveGroup(P345_T_GroupThing, P346_i_MapX, P347_i_MapY)
THING P345_T_GroupThing;
int P346_i_MapX;
int P347_i_MapY;
{
        register int L0338_i_Unreferenced; /* BUG0_00 Useless code */
        register unsigned int L0339_ui_CreatureIndex;
        register GROUP* L0340_ps_Group;
        register ACTIVE_GROUP* L0341_ps_ActiveGroup;
        long L0342_l_Unreferenced; /* BUG0_00 Useless code */
        BOOLEAN L0343_B_HalfSquareSizedCreature_Useless; /* BUG0_00 Useless code */
        int L0344_i_ActiveGroupIndex;


        L0341_ps_ActiveGroup = G375_ps_ActiveGroups;
        L0344_i_ActiveGroupIndex = 0;
        while (L0341_ps_ActiveGroup->GroupThingIndex >= 0) {
                if (++L0344_i_ActiveGroupIndex >= G376_ui_MaximumActiveGroupCount) {
                        return; /* BUG0_11 Data corruption in memory. Each group located on the same map as the party has additional associated data but there is only provision for 60 instances (G376_ui_MaximumActiveGroupCount). If there are more groups at the same time then some of them do not get their instance and when the game accesses this information it will corrupt other data in memory (either the instance of another group, parts of the timeline or events). This situation cannot occur in the original Dungeon Master and Chaos Strikes Back dungeons for the following reasons (but it may occur in custom dungeons if they are not designed carefully): there is no map with already more than 60 groups in the original dungeons and none of the following 3 possible ways to move a group into a map can increase the number of instances above the maximum of 60:
                        - A group generator sensor is triggered: the game never generates a group on the party map if there are less than 5 instances available. This limits the actual number of groups on a map to 55 in most cases.
                        - A group falls through a pit from the map above (the creature type must be allowed on the target map): a group will never willingly move to an open pit square. It may move to a closed pit square and fall if the pit is then open (either automatically or triggered by the party on the map below). There are no such pits in the original dungeons.
                        - A group is teleported from another map (the creature type must be allowed on the target map): in the original dungeons, all teleporters whose scope include groups and target another map are either inaccessible to groups or the groups are not allowed on the target map. The only exception is for some Gigglers in the Chaos Strikes Back dungeon but there are not enough to use the 5 reserved instances.

                        This code returns immediately if all ACTIVE_GROUP entries are already in use, which avoids an out of bounds access into G375_ps_ActiveGroups below (through L0341_ps_ActiveGroup). However in this case the specified group ends up without an associated ACTIVE_GROUP structure which is assumed everywhere in the code to be present for groups on the same map as the party. If there are more than 60 groups on the party map at any given time then this will corrupt memory (in G370_ps_Events and G371_pi_Timeline allocated in F233_wzzz_TIMELINE_Initialize before G375_ps_ActiveGroups) because of read and write operations at incorrect memory addresses (the 'Cells' value of the GROUP will be used as an index in G375_ps_ActiveGroups even though that value was not replaced by the index of an ACTIVE_GROUP in this function) */
                }
                L0341_ps_ActiveGroup++;
        }
        G377_ui_CurrentActiveGroupCount++;
        L0340_ps_Group = ((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP]) + (L0341_ps_ActiveGroup->GroupThingIndex = M13_INDEX(P345_T_GroupThing));
        L0341_ps_ActiveGroup->Cells = L0340_ps_Group->Cells;
        L0340_ps_Group->ActiveGroupIndex = L0344_i_ActiveGroupIndex;
        L0341_ps_ActiveGroup->PriorMapX = L0341_ps_ActiveGroup->HomeMapX = P346_i_MapX;
        L0341_ps_ActiveGroup->PriorMapY = L0341_ps_ActiveGroup->HomeMapY = P347_i_MapY;
        L0341_ps_ActiveGroup->LastMoveTime = G313_ul_GameTime - 127;
        L0343_B_HalfSquareSizedCreature_Useless = (M07_GET(G243_as_Graphic559_CreatureInfo[L0340_ps_Group->Type].Attributes, MASK0x0003_SIZE) == C1_SIZE_HALF_SQUARE); /* BUG0_00 Useless code */
        L0339_ui_CreatureIndex = L0340_ps_Group->Count;
        do {
                L0341_ps_ActiveGroup->Directions = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0341_ps_ActiveGroup->Directions, L0339_ui_CreatureIndex, L0340_ps_Group->Direction);
                L0341_ps_ActiveGroup->Aspect[L0339_ui_CreatureIndex] = 0;
        } while (L0339_ui_CreatureIndex--);
        F179_xxxx_GROUP_GetCreatureAspectUpdateTime(L0341_ps_ActiveGroup, CM1_WHOLE_CREATURE_GROUP, FALSE);
}

VOID F184_ahzz_GROUP_RemoveActiveGroup(P348_i_ActiveGroupIndex)
int P348_i_ActiveGroupIndex;
{
        register int L0345_i_Unreferenced; /* BUG0_00 Useless code */
        register int L0346_i_Unreferenced; /* BUG0_00 Useless code */
        register ACTIVE_GROUP* L0347_ps_ActiveGroup;
        register GROUP* L0348_ps_Group;


        if ((P348_i_ActiveGroupIndex > G376_ui_MaximumActiveGroupCount) || (G375_ps_ActiveGroups[P348_i_ActiveGroupIndex].GroupThingIndex < 0)) {
                return;
        }
        L0347_ps_ActiveGroup = &G375_ps_ActiveGroups[P348_i_ActiveGroupIndex];
        L0348_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[L0347_ps_ActiveGroup->GroupThingIndex];
        G377_ui_CurrentActiveGroupCount--;
        L0348_ps_Group->Cells = L0347_ps_ActiveGroup->Cells;
        L0348_ps_Group->Direction = M21_NORMALIZE(L0347_ps_ActiveGroup->Directions);
        if (L0348_ps_Group->Behavior >= C4_BEHAVIOR_USELESS) {
                L0348_ps_Group->Behavior = C0_BEHAVIOR_WANDER;
        }
        L0347_ps_ActiveGroup->GroupThingIndex = -1;
}

THING F185_auzz_GROUP_GetGenerated(P349_i_CreatureType, P350_i_HealthMultiplier, P351_i_CreatureCount, P352_i_Direction, P353_i_MapX, P354_i_MapY)
int P349_i_CreatureType;
int P350_i_HealthMultiplier;
int P351_i_CreatureCount;
int P352_i_Direction;
int P353_i_MapX;
int P354_i_MapY;
{
        register THING L0349_T_GroupThing;
        register unsigned int L0350_ui_BaseHealth;
        register unsigned int L0351_ui_Cell;
        register unsigned int L0352_ui_GroupCells;
        register GROUP* L0353_ps_Group;
        register CREATURE_INFO* L0354_ps_CreatureInfo;
        BOOLEAN L0355_B_SeveralCreaturesInGroup;


        if (((G377_ui_CurrentActiveGroupCount >= (G376_ui_MaximumActiveGroupCount - 5)) && (G272_i_CurrentMapIndex == G309_i_PartyMapIndex)) || ((L0349_T_GroupThing = F166_szzz_DUNGEON_GetUnusedThing(C04_THING_TYPE_GROUP)) == C0xFFFF_THING_NONE)) {
                return C0xFFFF_THING_NONE;
        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0353_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L0349_T_GroupThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0353_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0349_T_GroupThing);
#endif
        L0353_ps_Group->Slot = C0xFFFE_THING_ENDOFLIST;
        L0353_ps_Group->DoNotDiscard = FALSE;
        L0353_ps_Group->Direction = P352_i_Direction;
        L0353_ps_Group->Count = P351_i_CreatureCount;
        if (L0355_B_SeveralCreaturesInGroup = P351_i_CreatureCount) {
                L0351_ui_Cell = M04_RANDOM(4);
        } else {
                L0352_ui_GroupCells = C255_SINGLE_CENTERED_CREATURE;
        }
        L0354_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[L0353_ps_Group->Type = P349_i_CreatureType];
        L0350_ui_BaseHealth = L0354_ps_CreatureInfo->BaseHealth;
        do {
                L0353_ps_Group->Health[P351_i_CreatureCount] = (L0350_ui_BaseHealth * P350_i_HealthMultiplier) + M02_RANDOM((L0350_ui_BaseHealth >> 2) + 1);
                if (L0355_B_SeveralCreaturesInGroup) {
                        L0352_ui_GroupCells = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0352_ui_GroupCells, P351_i_CreatureCount, L0351_ui_Cell++);
                        if (M07_GET(L0354_ps_CreatureInfo->Attributes, MASK0x0003_SIZE) == C1_SIZE_HALF_SQUARE) {
                                L0351_ui_Cell++;
                        }
                        L0351_ui_Cell &= 0x0003;
                }
        } while (P351_i_CreatureCount--);
        L0353_ps_Group->Cells = L0352_ui_GroupCells;
        if (F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0349_T_GroupThing, CM1_MAPX_NOT_ON_A_SQUARE, 0, P353_i_MapX, P354_i_MapY)) { /* If F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE returns TRUE then the group was either killed by a projectile impact (in which case the thing data was marked as unused) or the party is on the destination square and an event is created to move the creature into the dungeon later (in which case the thing is referenced in the event) */
                return C0xFFFF_THING_NONE;
        }
        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, P353_i_MapX, P354_i_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
        return L0349_T_GroupThing;
}

VOID F186_xxxx_GROUP_DropCreatureFixedPossessions(P355_i_CreatureType, P356_i_MapX, P357_i_MapY, P358_ui_Cell, P359_i_Mode) /* Drop fixed possessions for a single creature in a group */
int P355_i_CreatureType;
int P356_i_MapX;
int P357_i_MapY;
unsigned int P358_ui_Cell;
int P359_i_Mode;
{
        register unsigned int L0356_ui_FixedPossession;
        register int L0357_i_ThingType;
        register THING L0358_T_Thing;
        register unsigned int* L0359_pui_FixedPossessions;
        register WEAPON* L0360_ps_Weapon;
        BOOLEAN L0361_B_Cursed;
        BOOLEAN L0362_B_WeaponDropped;


        L0361_B_Cursed = FALSE;
        L0362_B_WeaponDropped = FALSE;
        switch (P355_i_CreatureType) {
                default:
                        return;
                case C12_CREATURE_SKELETON:
                        L0359_pui_FixedPossessions = G245_aui_Graphic559_FixedPossessionsCreature12Skeleton;
                        break;
                case C09_CREATURE_STONE_GOLEM:
                        L0359_pui_FixedPossessions = G246_aui_Graphic559_FixedPossessionsCreature09StoneGolem;
                        break;
                case C16_CREATURE_TROLIN_ANTMAN:
                        L0359_pui_FixedPossessions = G247_aui_Graphic559_FixedPossessionsCreature16Trolin_Antman;
                        break;
                case C18_CREATURE_ANIMATED_ARMOUR_DETH_KNIGHT:
                        L0361_B_Cursed = TRUE;
                        L0359_pui_FixedPossessions = G248_aui_Graphic559_FixedPossessionsCreature18AnimatedArmour_DethKnight;
                        break;
                case C07_CREATURE_ROCK_ROCKPILE:
                        L0359_pui_FixedPossessions = G249_aui_Graphic559_FixedPossessionsCreature07Rock_RockPile;
                        break;
                case C04_CREATURE_PAIN_RAT_HELLHOUND:
                        L0359_pui_FixedPossessions = G250_aui_Graphic559_FixedPossessionsCreature04PainRat_Hellhound;
                        break;
                case C06_CREATURE_SCREAMER:
                        L0359_pui_FixedPossessions = G251_aui_Graphic559_FixedPossessionsCreature06Screamer;
                        break;
                case C15_CREATURE_MAGENTA_WORM_WORM:
                        L0359_pui_FixedPossessions = G252_aui_Graphic559_FixedPossessionsCreature15MagentaWorm_Worm;
                        break;
                case C24_CREATURE_RED_DRAGON:
                        L0359_pui_FixedPossessions = G253_aui_Graphic559_FixedPossessionsCreature24RedDragon;
        }
        while (L0356_ui_FixedPossession = *L0359_pui_FixedPossessions++) {
                if (M07_GET(L0356_ui_FixedPossession, MASK0x8000_RANDOM_DROP) && M05_RANDOM(2)) {
                        continue;
                }
                if (M09_CLEAR(L0356_ui_FixedPossession, MASK0x8000_RANDOM_DROP) >= C127_OBJECT_INFO_INDEX_FIRST_JUNK) {
                        L0357_i_ThingType = C10_THING_TYPE_JUNK;
                        L0356_ui_FixedPossession -= C127_OBJECT_INFO_INDEX_FIRST_JUNK;
                } else {
                        if (L0356_ui_FixedPossession >= C069_OBJECT_INFO_INDEX_FIRST_ARMOUR) {
                                L0357_i_ThingType = C06_THING_TYPE_ARMOUR;
                                L0356_ui_FixedPossession -= C069_OBJECT_INFO_INDEX_FIRST_ARMOUR;
                        } else {
                                L0362_B_WeaponDropped = TRUE;
                                L0357_i_ThingType = C05_THING_TYPE_WEAPON;
                                L0356_ui_FixedPossession -= C023_OBJECT_INFO_INDEX_FIRST_WEAPON;
                        }
                }
                if ((L0358_T_Thing = F166_szzz_DUNGEON_GetUnusedThing(L0357_i_ThingType)) == C0xFFFF_THING_NONE) {
                        continue;
                }
                L0360_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(L0358_T_Thing);
                L0360_ps_Weapon->Type = L0356_ui_FixedPossession; /* The same pointer type is used no matter the actual type C05_THING_TYPE_WEAPON, C06_THING_TYPE_ARMOUR or C10_THING_TYPE_JUNK */
                L0360_ps_Weapon->Cursed = L0361_B_Cursed;
                L0358_T_Thing = M15_THING_WITH_NEW_CELL(L0358_T_Thing, ((P358_ui_Cell == C255_SINGLE_CENTERED_CREATURE) || !M04_RANDOM(4)) ? M04_RANDOM(4) : P358_ui_Cell);
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0358_T_Thing, CM1_MAPX_NOT_ON_A_SQUARE, 0, P356_i_MapX, P357_i_MapY);
        }
        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(L0362_B_WeaponDropped ? C00_SOUND_METALLIC_THUD : C04_SOUND_WOODEN_THUD, P356_i_MapX, P357_i_MapY, P359_i_Mode);
}

VOID F187_czzz_GROUP_DropMovingCreatureFixedPossessions(P360_T_Thing, P361_i_MapX, P362_i_MapY)
THING P360_T_Thing;
int P361_i_MapX;
int P362_i_MapY;
{
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        GROUP* L0363_ps_Group;
#endif
        int L0364_i_CreatureType;


        if (G391_i_DropMovingCreatureFixedPossessionsCellCount) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0364_i_CreatureType = ((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P360_T_Thing)].Type;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0363_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(P360_T_Thing);
                L0364_i_CreatureType = L0363_ps_Group->Type;
#endif
                while (G391_i_DropMovingCreatureFixedPossessionsCellCount) {
                        F186_xxxx_GROUP_DropCreatureFixedPossessions(L0364_i_CreatureType, P361_i_MapX, P362_i_MapY, G392_auc_DropMovingCreatureFixedPossessionsCells[--G391_i_DropMovingCreatureFixedPossessionsCellCount], C02_MODE_PLAY_ONE_TICK_LATER);
                }
        }
}

VOID F188_aozz_GROUP_DropGroupPossessions(P363_i_MapX, P364_i_MapY, P365_T_GroupThing, P366_i_Mode) /* Drop fixed possessions for each creature in the group and also the group possessions */
register int P363_i_MapX;
register int P364_i_MapY;
THING P365_T_GroupThing;
int P366_i_Mode;
{
        register THING L0365_T_CurrentThing;
        register THING L0366_T_NextThing;
        register GROUP* L0367_ps_Group;
        int L0368_i_CreatureType;
        int L0369_i_CreatureIndex;
        unsigned int L0370_ui_GroupCells;
        BOOLEAN L0371_B_WeaponDropped;


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0367_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P365_T_GroupThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0367_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(P365_T_GroupThing);
#endif
        if ((P366_i_Mode >= C00_MODE_PLAY_IMMEDIATELY) && M07_GET(G243_as_Graphic559_CreatureInfo[L0368_i_CreatureType = L0367_ps_Group->Type].Attributes, MASK0x0200_DROP_FIXED_POSSESSIONS)) {
                L0369_i_CreatureIndex = L0367_ps_Group->Count;
                L0370_ui_GroupCells = F145_rzzz_DUNGEON_GetGroupCells(L0367_ps_Group, G272_i_CurrentMapIndex);
                do {
                        F186_xxxx_GROUP_DropCreatureFixedPossessions(L0368_i_CreatureType, P363_i_MapX, P364_i_MapY, (L0370_ui_GroupCells == C255_SINGLE_CENTERED_CREATURE) ? C255_SINGLE_CENTERED_CREATURE : M50_CREATURE_VALUE(L0370_ui_GroupCells, L0369_i_CreatureIndex), P366_i_Mode);
                } while (L0369_i_CreatureIndex--);
        }
        if ((L0365_T_CurrentThing = L0367_ps_Group->Slot) != C0xFFFE_THING_ENDOFLIST) {
                L0371_B_WeaponDropped = FALSE;
                do {
                        L0366_T_NextThing = F159_rzzz_DUNGEON_GetNextThing(L0365_T_CurrentThing);
                        L0365_T_CurrentThing = M15_THING_WITH_NEW_CELL(L0365_T_CurrentThing, M04_RANDOM(4));
                        if (M12_TYPE(L0365_T_CurrentThing) == C05_THING_TYPE_WEAPON) {
                                L0371_B_WeaponDropped = TRUE;
                        }
                        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0365_T_CurrentThing, CM1_MAPX_NOT_ON_A_SQUARE, 0, P363_i_MapX, P364_i_MapY);
                } while ((L0365_T_CurrentThing = L0366_T_NextThing) != C0xFFFE_THING_ENDOFLIST);
                if (P366_i_Mode >= C00_MODE_PLAY_IMMEDIATELY) {
                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(L0371_B_WeaponDropped ? C00_SOUND_METALLIC_THUD : C04_SOUND_WOODEN_THUD, P363_i_MapX, P364_i_MapY, P366_i_Mode);
                }
        }
}

VOID F189_awzz_GROUP_Delete(P367_i_MapX, P368_i_MapY)
int P367_i_MapX;
int P368_i_MapY;
{
        register THING L0372_T_GroupThing;
        register GROUP* L0373_ps_Group;


        if ((L0372_T_GroupThing = F175_gzzz_GROUP_GetThing(P367_i_MapX, P368_i_MapY)) == C0xFFFE_THING_ENDOFLIST) {
                return;
        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0373_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L0372_T_GroupThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0373_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0372_T_GroupThing);
#endif
        F008_aA19_MAIN_ClearBytes(L0373_ps_Group->Health, sizeof(L0373_ps_Group->Health));
        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0372_T_GroupThing, P367_i_MapX, P368_i_MapY, CM1_MAPX_NOT_ON_A_SQUARE, 0);
        L0373_ps_Group->Next = C0xFFFF_THING_NONE;
        if (G272_i_CurrentMapIndex == G309_i_PartyMapIndex) {
                G375_ps_ActiveGroups[L0373_ps_Group->ActiveGroupIndex].GroupThingIndex = -1;
                G377_ui_CurrentActiveGroupCount--;
        }
        F181_czzz_GROUP_DeleteEvents(P367_i_MapX, P368_i_MapY);
}

int F190_zzzz_GROUP_GetDamageCreatureOutcome(P369_ps_Group, P370_ui_CreatureIndex, P371_i_MapX, P372_i_MapY, P373_i_Damage, P374_B_NotMoving)
register GROUP* P369_ps_Group;
unsigned int P370_ui_CreatureIndex;
register int P371_i_MapX;
register int P372_i_MapY;
int P373_i_Damage;
BOOLEAN P374_B_NotMoving; /* When a creature is killed while not moving then possessions are dropped in this function on the current map. When a creature is killed while moving (like falling in a pit) then possessions are not dropped in this function but rather in F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE on the destination map which may be different from the current (source) map */
{
        register unsigned int L0374_ui_Multiple;
#define A0374_ui_EventIndex    L0374_ui_Multiple
#define A0374_ui_CreatureIndex L0374_ui_Multiple
#define A0374_ui_CreatureSize  L0374_ui_Multiple
#define A0374_ui_Attack        L0374_ui_Multiple
        register unsigned int L0375_ui_Multiple;
#define A0375_ui_Outcome           L0375_ui_Multiple
#define A0375_ui_EventType         L0375_ui_Multiple
#define A0375_ui_NextCreatureIndex L0375_ui_Multiple
        register CREATURE_INFO* L0376_ps_CreatureInfo;
        EVENT* L0377_ps_Event;
        ACTIVE_GROUP* L0378_ps_ActiveGroup;
        unsigned int L0379_ui_CreatureCount;
        int L0380_i_Multiple;
#define A0380_i_CreatureType   L0380_i_Multiple
#define A0380_i_FearResistance L0380_i_Multiple
        unsigned int L0381_ui_GroupCells;
        unsigned int L0382_ui_GroupDirections;
        BOOLEAN L0383_B_CurrentMapIsPartyMap;
        unsigned int L0384_ui_Cell;


        L0376_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[A0380_i_CreatureType = P369_ps_Group->Type];
        if (M07_GET(L0376_ps_CreatureInfo->Attributes, MASK0x2000_ARCHENEMY)) { /* Lord Chaos cannot be damaged */
        } else {
                if (P369_ps_Group->Health[P370_ui_CreatureIndex] <= P373_i_Damage) {
                        L0381_ui_GroupCells = F145_rzzz_DUNGEON_GetGroupCells(P369_ps_Group, G272_i_CurrentMapIndex);
                        L0384_ui_Cell = (L0381_ui_GroupCells == C255_SINGLE_CENTERED_CREATURE) ? C255_SINGLE_CENTERED_CREATURE : M50_CREATURE_VALUE(L0381_ui_GroupCells, P370_ui_CreatureIndex);
                        if (!(L0379_ui_CreatureCount = P369_ps_Group->Count)) { /* If there is a single creature in the group */
                                if (P374_B_NotMoving) {
                                        F188_aozz_GROUP_DropGroupPossessions(P371_i_MapX, P372_i_MapY, F175_gzzz_GROUP_GetThing(P371_i_MapX, P372_i_MapY), C02_MODE_PLAY_ONE_TICK_LATER);
                                        F189_awzz_GROUP_Delete(P371_i_MapX, P372_i_MapY);
                                }
                                A0375_ui_Outcome = C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP;
                        } else { /* If there are several creatures in the group */
                                L0382_ui_GroupDirections = F147_aawz_DUNGEON_GetGroupDirections(P369_ps_Group, G272_i_CurrentMapIndex);
                                if (M07_GET(L0376_ps_CreatureInfo->Attributes, MASK0x0200_DROP_FIXED_POSSESSIONS)) {
                                        if (P374_B_NotMoving) {
                                                F186_xxxx_GROUP_DropCreatureFixedPossessions(A0380_i_CreatureType, P371_i_MapX, P372_i_MapY, L0384_ui_Cell, C02_MODE_PLAY_ONE_TICK_LATER);
                                        } else {
                                                G392_auc_DropMovingCreatureFixedPossessionsCells[G391_i_DropMovingCreatureFixedPossessionsCellCount++] = L0384_ui_Cell;
                                        }
                                }
                                if (L0383_B_CurrentMapIsPartyMap = (G272_i_CurrentMapIndex == G309_i_PartyMapIndex)) {
                                        L0378_ps_ActiveGroup = &G375_ps_ActiveGroups[P369_ps_Group->ActiveGroupIndex];
                                }
                                if (P369_ps_Group->Behavior == C6_BEHAVIOR_ATTACK) {
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                                        A0374_ui_EventIndex = 0, L0377_ps_Event = G370_ps_Events;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                                        L0377_ps_Event = G370_ps_Events;
                                        A0374_ui_EventIndex = 0;
#endif
                                        while (A0374_ui_EventIndex < G369_ui_EventMaximumCount) {
                                                if ((M29_MAP(L0377_ps_Event->Map_Time) == G272_i_CurrentMapIndex) &&
                                                    (L0377_ps_Event->B.Location.MapX == P371_i_MapX) &&
                                                    (L0377_ps_Event->B.Location.MapY == P372_i_MapY) &&
                                                    ((A0375_ui_EventType = L0377_ps_Event->A.A.Type) > C32_EVENT_UPDATE_ASPECT_GROUP) &&
                                                    (A0375_ui_EventType < C41_EVENT_UPDATE_BEHAVIOR_CREATURE_3 + 1)) {
                                                        if (A0375_ui_EventType < C37_EVENT_UPDATE_BEHAVIOR_GROUP) {
                                                                A0375_ui_EventType -= C33_EVENT_UPDATE_ASPECT_CREATURE_0; /* Get creature index for events 33 to 36 */
                                                        } else {
                                                                A0375_ui_EventType -= C38_EVENT_UPDATE_BEHAVIOR_CREATURE_0; /* Get creature index for events 38 to 41 */
                                                        }
                                                        if (A0375_ui_NextCreatureIndex == P370_ui_CreatureIndex) {
                                                                F237_rzzz_TIMELINE_DeleteEvent(A0374_ui_EventIndex);
                                                        } else {
                                                                if (A0375_ui_NextCreatureIndex > P370_ui_CreatureIndex) {
                                                                        L0377_ps_Event->A.A.Type -= 1;
                                                                        F236_pzzz_TIMELINE_FixChronology(F235_bzzz_TIMELINE_GetIndex(A0374_ui_EventIndex));
                                                                }
                                                        }
                                                }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                                                L0377_ps_Event++, A0374_ui_EventIndex++;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                                                L0377_ps_Event++;
                                                A0374_ui_EventIndex++;
#endif
                                        }
                                        if (L0383_B_CurrentMapIsPartyMap && ((A0380_i_FearResistance = M57_FEAR_RESISTANCE(L0376_ps_CreatureInfo->Properties)) != C15_IMMUNE_TO_FEAR) && ((A0380_i_FearResistance += L0379_ui_CreatureCount - 1) < (M03_RANDOM(16)))) { /* Test if the death of a creature frigthens the remaining creatures in the group */
                                                L0378_ps_ActiveGroup->DelayFleeingFromTarget = M02_RANDOM(100 - (A0380_i_FearResistance << 2)) + 20;
                                                P369_ps_Group->Behavior = C5_BEHAVIOR_FLEE;
                                        }
                                }
                                for(A0375_ui_NextCreatureIndex = A0374_ui_CreatureIndex = P370_ui_CreatureIndex; A0374_ui_CreatureIndex < L0379_ui_CreatureCount; A0374_ui_CreatureIndex++) {
                                        A0375_ui_NextCreatureIndex++;
                                        P369_ps_Group->Health[A0374_ui_CreatureIndex] = P369_ps_Group->Health[A0375_ui_NextCreatureIndex];
                                        L0382_ui_GroupDirections = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0382_ui_GroupDirections, A0374_ui_CreatureIndex, M50_CREATURE_VALUE(L0382_ui_GroupDirections, A0375_ui_NextCreatureIndex));
                                        L0381_ui_GroupCells = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0381_ui_GroupCells, A0374_ui_CreatureIndex, M50_CREATURE_VALUE(L0381_ui_GroupCells, A0375_ui_NextCreatureIndex));
                                        if (L0383_B_CurrentMapIsPartyMap) {
                                                L0378_ps_ActiveGroup->Aspect[A0374_ui_CreatureIndex] = L0378_ps_ActiveGroup->Aspect[A0375_ui_NextCreatureIndex];
                                        }
                                }
                                L0381_ui_GroupCells &= 0x003F;
                                F146_aczz_DUNGEON_SetGroupCells(P369_ps_Group, L0381_ui_GroupCells, G272_i_CurrentMapIndex);
                                F148_aayz_DUNGEON_SetGroupDirections(P369_ps_Group, L0382_ui_GroupDirections, G272_i_CurrentMapIndex);
                                P369_ps_Group->Count--;
                                A0375_ui_Outcome = C1_OUTCOME_KILLED_SOME_CREATURES_IN_GROUP;
                        }
                        if ((A0374_ui_CreatureSize = M07_GET(L0376_ps_CreatureInfo->Attributes, MASK0x0003_SIZE)) == C0_SIZE_QUARTER_SQUARE) {
                                A0374_ui_Attack = 110;
                        } else {
                                if (A0374_ui_CreatureSize == C1_SIZE_HALF_SQUARE) {
                                        A0374_ui_Attack = 190;
                                } else {
                                        A0374_ui_Attack = 255;
                                }
                        }
                        F213_hzzz_EXPLOSION_Create(C0xFFA8_THING_EXPLOSION_SMOKE, A0374_ui_Attack, P371_i_MapX, P372_i_MapY, L0384_ui_Cell); /* BUG0_66 Smoke is placed on the source map instead of the destination map when a creature dies by falling through a pit. The game has a special case to correctly drop the creature possessions on the destination map but there is no such special case for the smoke. Note that the death must be caused by the damage of the fall (there is no smoke if the creature is removed because its type is not allowed on the destination map). However this bug has no visible consequence because of BUG0_26: the smoke explosion falls in the pit right after being placed in the dungeon and before being drawn on screen so it is only visible on the destination square */
                        return A0375_ui_Outcome;
                }
                if (P373_i_Damage > 0) {
                        P369_ps_Group->Health[P370_ui_CreatureIndex] -= P373_i_Damage;
                }
        }
        return C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP;
}

int F191_aayz_GROUP_GetDamageAllCreaturesOutcome(P375_ps_Group, P376_i_MapX, P377_i_MapY, P378_i_Attack, P379_B_NotMoving)
register GROUP* P375_ps_Group;
int P376_i_MapX;
int P377_i_MapY;
register int P378_i_Attack;
BOOLEAN P379_B_NotMoving;
{
        register int L0385_i_RandomAttack;
        int L0386_i_CreatureIndex;
        int L0387_i_Outcome;
        BOOLEAN L0388_B_KilledSomeCreatures;
        BOOLEAN L0389_B_KilledAllCreatures;


        L0388_B_KilledSomeCreatures = FALSE;
        L0389_B_KilledAllCreatures = TRUE;
        G391_i_DropMovingCreatureFixedPossessionsCellCount = 0;
        if (P378_i_Attack > 0) {
                L0386_i_CreatureIndex = P375_ps_Group->Count;
                P378_i_Attack -= (L0385_i_RandomAttack = (P378_i_Attack >> 3) + 1);
                L0385_i_RandomAttack <<= 1;
                do {
                        L0389_B_KilledAllCreatures = (L0387_i_Outcome = F190_zzzz_GROUP_GetDamageCreatureOutcome(P375_ps_Group, L0386_i_CreatureIndex, P376_i_MapX, P377_i_MapY, P378_i_Attack + M02_RANDOM(L0385_i_RandomAttack), P379_B_NotMoving)) && L0389_B_KilledAllCreatures;
                        L0388_B_KilledSomeCreatures = L0388_B_KilledSomeCreatures || L0387_i_Outcome;
                } while (L0386_i_CreatureIndex--);
                if (L0389_B_KilledAllCreatures) {
                        return C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP;
                }
                if (L0388_B_KilledSomeCreatures) {
                        return C1_OUTCOME_KILLED_SOME_CREATURES_IN_GROUP;
                }
                return C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP;
        } else {
                return C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP;
        }
}

int F192_ayzz_GROUP_GetResistanceAdjustedPoisonAttack(P380_i_CreatureType, P381_i_PoisonAttack)
int P380_i_CreatureType;
int P381_i_PoisonAttack;
{
        register int L0390_i_PoisonResistance;


        if (!P381_i_PoisonAttack || ((L0390_i_PoisonResistance = M61_POISON_RESISTANCE(G243_as_Graphic559_CreatureInfo[P380_i_CreatureType].Resistances)) == C15_IMMUNE_TO_POISON)) {
                return 0;
        }
        return ((P381_i_PoisonAttack + M04_RANDOM(4)) << 3) / ++L0390_i_PoisonResistance;
}

VOID F193_xxxx_GROUP_StealFromChampion(P382_ps_Group, P383_i_ChampionIndex)
register GROUP* P382_ps_Group;
int P383_i_ChampionIndex;
{
        register int L0391_i_Percentage;
        register int L0392_i_StealFromSlotIndex;
        register unsigned int L0393_ui_Counter;
        register THING L0394_T_Thing;
        register CHAMPION* L0395_ps_Champion;
        BOOLEAN L0396_B_ObjectStolen;
        static unsigned char G394_auc_StealFromSlotIndices[8]; /* Initialized with 0 bytes by C loader */


        L0396_B_ObjectStolen = FALSE;
        L0391_i_Percentage = 100 - F311_wzzz_CHAMPION_GetDexterity(L0395_ps_Champion = &G407_s_Party.Champions[P383_i_ChampionIndex]);
        L0393_ui_Counter = M03_RANDOM(8);
        while ((L0391_i_Percentage > 0) && !F308_vzzz_CHAMPION_IsLucky(L0395_ps_Champion, L0391_i_Percentage)) {
                if ((L0392_i_StealFromSlotIndex = G394_auc_StealFromSlotIndices[L0393_ui_Counter]) == C13_SLOT_BACKPACK_LINE1_1) {
                        L0392_i_StealFromSlotIndex += M02_RANDOM(17); /* Select a random slot in the backpack */
                }
                if (((L0394_T_Thing = L0395_ps_Champion->Slots[L0392_i_StealFromSlotIndex]) != C0xFFFF_THING_NONE)) {
                        L0396_B_ObjectStolen = TRUE;
                        L0394_T_Thing = F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P383_i_ChampionIndex, L0392_i_StealFromSlotIndex);
                        if (P382_ps_Group->Slot == C0xFFFE_THING_ENDOFLIST) {
                                P382_ps_Group->Slot = L0394_T_Thing; /* BUG0_12 An object is cloned and appears at two different locations in the dungeon and/or inventory. The game may crash when interacting with this object. If a Giggler with no possessions steals an object that was previously in a chest and was not the last object in the chest then the objects that followed it are cloned. In the chest, the object is part of a linked list of objects that is not reset when the object is removed from the chest and placed in the inventory (but not in the dungeon), nor when it is stolen and added as the first Giggler possession. If the Giggler already has a possession before stealing the object then this does not create a cloned object.
                                The following statement is missing: L0394_T_Thing->Next = C0xFFFE_THING_ENDOFLIST;
                                This creates cloned things if L0394_T_Thing->Next is not C0xFFFE_THING_ENDOFLIST which is the case when the object comes from a chest in which it was not the last object */
                        } else {
                                F163_amzz_DUNGEON_LinkThingToList(L0394_T_Thing, P382_ps_Group->Slot, CM1_MAPX_NOT_ON_A_SQUARE, 0);
                        }
                        F292_arzz_CHAMPION_DrawState(P383_i_ChampionIndex);
                }
                ++L0393_ui_Counter;
                L0393_ui_Counter &= 0x0007;
                L0391_i_Percentage -= 20;
        }
        if (!M03_RANDOM(8) || (L0396_B_ObjectStolen && M05_RANDOM(2))) {
                G375_ps_ActiveGroups[P382_ps_Group->ActiveGroupIndex].DelayFleeingFromTarget = M03_RANDOM(64) + 20;
                P382_ps_Group->Behavior = C5_BEHAVIOR_FLEE;
        }
}

VOID F194_hzzz_GROUP_RemoveAllActiveGroups()
{
        register int L0397_i_ActiveGroupIndex;


        L0397_i_ActiveGroupIndex = 0;
        while (G377_ui_CurrentActiveGroupCount > 0) {
                if (G375_ps_ActiveGroups[L0397_i_ActiveGroupIndex].GroupThingIndex >= 0) {
                        F184_ahzz_GROUP_RemoveActiveGroup(L0397_i_ActiveGroupIndex);
                }
                L0397_i_ActiveGroupIndex++;
        }
}

VOID F195_akzz_GROUP_AddAllActiveGroups()
{
        register unsigned int L0398_ui_MapX;
        register unsigned int L0399_ui_MapY;
        register THING L0400_T_Thing;
        register unsigned char* L0401_puc_Square;
        register THING* L0402_pT_SquareFirstThing;


        L0401_puc_Square = G271_ppuc_CurrentMapData[0];
        L0402_pT_SquareFirstThing = &G283_pT_SquareFirstThings[G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount[0]];
        for(L0398_ui_MapX = 0; L0398_ui_MapX < G273_i_CurrentMapWidth; L0398_ui_MapX++) {
                for(L0399_ui_MapY = 0; L0399_ui_MapY < G274_i_CurrentMapHeight; L0399_ui_MapY++) {
                        if (M07_GET(*L0401_puc_Square++, MASK0x0010_THING_LIST_PRESENT)) {
                                L0400_T_Thing = *L0402_pT_SquareFirstThing++;
                                do {
                                        if (M12_TYPE(L0400_T_Thing) == C04_THING_TYPE_GROUP) {
                                                F181_czzz_GROUP_DeleteEvents(L0398_ui_MapX, L0399_ui_MapY);
                                                F183_kzzz_GROUP_AddActiveGroup(L0400_T_Thing, L0398_ui_MapX, L0399_ui_MapY);
                                                F180_hzzz_GROUP_StartWandering(L0398_ui_MapX, L0399_ui_MapY);
                                                break;
                                        }
                                } while ((L0400_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0400_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
                        }
                }
        }
}

VOID F196_aozz_GROUP_InitializeActiveGroups()
{
        register int L0403_i_ActiveGroupIndex;


        if (G298_B_NewGame) {
                G376_ui_MaximumActiveGroupCount = 60;
        }
        G375_ps_ActiveGroups = (ACTIVE_GROUP*)F468_ozzz_MEMORY_Allocate((long)(G376_ui_MaximumActiveGroupCount * sizeof(ACTIVE_GROUP)), C1_ALLOCATION_PERMANENT);
        L0403_i_ActiveGroupIndex = 0;
        while (L0403_i_ActiveGroupIndex < G376_ui_MaximumActiveGroupCount) {
                G375_ps_ActiveGroups[L0403_i_ActiveGroupIndex++].GroupThingIndex = -1;
        }
}

BOOLEAN F197_xxxx_GROUP_IsViewPartyBlocked(P384_ui_MapX, P385_ui_MapY)
unsigned int P384_ui_MapX;
unsigned int P385_ui_MapY;
{
        register unsigned int L0404_ui_Square;
        register int L0405_i_SquareType;
        register int L0406_i_DoorState;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        register DOOR* L0407_ps_Door;
#endif


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        return (((L0405_i_SquareType = M34_SQUARE_TYPE(L0404_ui_Square = G271_ppuc_CurrentMapData[P384_ui_MapX][P385_ui_MapY])) == C00_ELEMENT_WALL) ||
                ((L0405_i_SquareType == C06_ELEMENT_FAKEWALL) && !M07_GET(L0404_ui_Square, MASK0x0004_FAKEWALL_OPEN)) ||
                ((L0405_i_SquareType == C04_ELEMENT_DOOR) &&
                 (((L0406_i_DoorState = M36_DOOR_STATE(L0404_ui_Square)) == C3_DOOR_STATE_CLOSED_THREE_FOURTH) || (L0406_i_DoorState == C4_DOOR_STATE_CLOSED)) &&
                 !M07_GET(G275_as_CurrentMapDoorInfo[((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(P384_ui_MapX, P385_ui_MapY))].Type].Attributes, MASK0x0001_CREATURES_CAN_SEE_THROUGH))
                );
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        if ((L0405_i_SquareType = M34_SQUARE_TYPE(L0404_ui_Square = G271_ppuc_CurrentMapData[P384_ui_MapX][P385_ui_MapY])) == C04_ELEMENT_DOOR) {
                L0407_ps_Door = (DOOR*)F157_rzzz_DUNGEON_GetSquareFirstThingData(P384_ui_MapX, P385_ui_MapY);
                return (((L0406_i_DoorState = M36_DOOR_STATE(L0404_ui_Square)) == C3_DOOR_STATE_CLOSED_THREE_FOURTH) || (L0406_i_DoorState == C4_DOOR_STATE_CLOSED)) && !M07_GET(G275_as_CurrentMapDoorInfo[L0407_ps_Door->Type].Attributes, MASK0x0001_CREATURES_CAN_SEE_THROUGH);
        }
        return (L0405_i_SquareType == C00_ELEMENT_WALL) || ((L0405_i_SquareType == C06_ELEMENT_FAKEWALL) && !M07_GET(L0404_ui_Square, MASK0x0004_FAKEWALL_OPEN));
#endif
}

BOOLEAN F198_xxxx_GROUP_IsSmellPartyBlocked(P386_ui_MapX, P387_ui_MapY)
unsigned int P386_ui_MapX;
unsigned int P387_ui_MapY;
{
        register unsigned int L0408_ui_Square;
        register int L0409_i_SquareType;


        return ((L0409_i_SquareType = M34_SQUARE_TYPE(L0408_ui_Square = G271_ppuc_CurrentMapData[P386_ui_MapX][P387_ui_MapY])) == C00_ELEMENT_WALL) || ((L0409_i_SquareType == C06_ELEMENT_FAKEWALL) && !M07_GET(L0408_ui_Square, MASK0x0004_FAKEWALL_OPEN));
}

/* Returns 0 if at least one square on the path from source to destination is blocked else returns the distance between the squares */
int F199_xxxx_GROUP_GetDistanceBetweenUnblockedSquares(P388_i_SourceMapX, P389_i_SourceMapY, P390_i_DestinationMapX, P391_i_DestinationMapY, P392_pfB_IsBlockedCallbackFunction)
int P388_i_SourceMapX;
int P389_i_SourceMapY;
int P390_i_DestinationMapX;
int P391_i_DestinationMapY;
register BOOLEAN (*P392_pfB_IsBlockedCallbackFunction)();
{
        register int L0410_i_XAxisStep;
        register int L0411_i_YAxisStep;
        register int L0412_i_Multiple;
#define A0412_i_DistanceX L0412_i_Multiple
#define A0412_i_PathMapX  L0412_i_Multiple
        register int L0413_i_Multiple;
#define A0413_i_DistanceY L0413_i_Multiple
#define A0413_i_PathMapY  L0413_i_Multiple
        int L0414_i_LargestAxisDistance;
        BOOLEAN L0415_B_DistanceXSmallerThanDistanceY;
        int L0416_i_ValueA;
        int L0417_i_ValueB;
        BOOLEAN L0418_B_DistanceXEqualsDistanceY;
        int L0419_i_ValueC;


        if (M38_DISTANCE(P388_i_SourceMapX, P389_i_SourceMapY, P390_i_DestinationMapX, P391_i_DestinationMapY) <= 1) {
                return 1;
        }
        L0415_B_DistanceXSmallerThanDistanceY = (A0412_i_DistanceX = ((A0412_i_DistanceX = P390_i_DestinationMapX - P388_i_SourceMapX) < 0) ? -A0412_i_DistanceX : A0412_i_DistanceX) < (A0413_i_DistanceY = ((A0413_i_DistanceY = P391_i_DestinationMapY - P389_i_SourceMapY) < 0) ? -A0413_i_DistanceY : A0413_i_DistanceY);
        L0418_B_DistanceXEqualsDistanceY = (A0412_i_DistanceX == A0413_i_DistanceY);
        L0410_i_XAxisStep = (A0412_i_PathMapX = P390_i_DestinationMapX) - P388_i_SourceMapX;
        if (L0410_i_XAxisStep > 0) {
                L0410_i_XAxisStep = -1;
        } else {
                L0410_i_XAxisStep = 1;
        }
        L0411_i_YAxisStep = (A0413_i_PathMapY = P391_i_DestinationMapY) - P389_i_SourceMapY;
        if (L0411_i_YAxisStep > 0) {
                L0411_i_YAxisStep = -1;
        } else {
                L0411_i_YAxisStep = 1;
        }
        L0419_i_ValueC = L0415_B_DistanceXSmallerThanDistanceY ? ((L0414_i_LargestAxisDistance = A0413_i_PathMapY - P389_i_SourceMapY) ? ((A0412_i_PathMapX - P388_i_SourceMapX) << 6) / L0414_i_LargestAxisDistance : 128)
                                                               : ((L0414_i_LargestAxisDistance = A0412_i_PathMapX - P388_i_SourceMapX) ? ((A0413_i_PathMapY - P389_i_SourceMapY) << 6) / L0414_i_LargestAxisDistance : 128);
        /* 128 when the creature is on the same row or column as the party */
        do {
                if (L0418_B_DistanceXEqualsDistanceY) {
                        if (((*P392_pfB_IsBlockedCallbackFunction)(A0412_i_PathMapX + L0410_i_XAxisStep, A0413_i_PathMapY) && (*P392_pfB_IsBlockedCallbackFunction)(A0412_i_PathMapX, A0413_i_PathMapY + L0411_i_YAxisStep)) || (*P392_pfB_IsBlockedCallbackFunction)(A0412_i_PathMapX = A0412_i_PathMapX + L0410_i_XAxisStep, A0413_i_PathMapY = A0413_i_PathMapY + L0411_i_YAxisStep)) {
                                return 0;
                        }
                } else {
                        if ((L0416_i_ValueA = ((L0414_i_LargestAxisDistance = (L0415_B_DistanceXSmallerThanDistanceY ? ((L0414_i_LargestAxisDistance = A0413_i_PathMapY - P389_i_SourceMapY) ? ((A0412_i_PathMapX + L0410_i_XAxisStep - P388_i_SourceMapX) << 6) / L0414_i_LargestAxisDistance : 128) : ((L0414_i_LargestAxisDistance = A0412_i_PathMapX + L0410_i_XAxisStep - P388_i_SourceMapX) ? ((A0413_i_PathMapY - P389_i_SourceMapY) << 6) / L0414_i_LargestAxisDistance : 128)) - L0419_i_ValueC) < 0) ? -L0414_i_LargestAxisDistance : L0414_i_LargestAxisDistance) < (L0417_i_ValueB = ((L0414_i_LargestAxisDistance = (L0415_B_DistanceXSmallerThanDistanceY ? ((L0414_i_LargestAxisDistance = A0413_i_PathMapY + L0411_i_YAxisStep - P389_i_SourceMapY) ? ((A0412_i_PathMapX - P388_i_SourceMapX) << 6) / L0414_i_LargestAxisDistance : 128) : ((L0414_i_LargestAxisDistance = A0412_i_PathMapX - P388_i_SourceMapX) ? ((A0413_i_PathMapY + L0411_i_YAxisStep - P389_i_SourceMapY) << 6) / L0414_i_LargestAxisDistance : 128)) - L0419_i_ValueC) < 0) ? -L0414_i_LargestAxisDistance : L0414_i_LargestAxisDistance)) {
                                A0412_i_PathMapX += L0410_i_XAxisStep;
                        } else {
                                A0413_i_PathMapY += L0411_i_YAxisStep;
                        }
                        if ((*P392_pfB_IsBlockedCallbackFunction)(A0412_i_PathMapX, A0413_i_PathMapY) && ((L0416_i_ValueA != L0417_i_ValueB) || (*P392_pfB_IsBlockedCallbackFunction)(A0412_i_PathMapX = A0412_i_PathMapX + L0410_i_XAxisStep, A0413_i_PathMapY = A0413_i_PathMapY - L0411_i_YAxisStep))) {
                                return 0;
                        }
                }
        } while (M38_DISTANCE(A0412_i_PathMapX, A0413_i_PathMapY, P388_i_SourceMapX, P389_i_SourceMapY) > 1);
        return F226_ozzz_GROUP_GetDistanceBetweenSquares(P388_i_SourceMapX, P389_i_SourceMapY, P390_i_DestinationMapX, P391_i_DestinationMapY);
}

int F200_xxxx_GROUP_GetDistanceToVisibleParty(P393_ps_Group, P394_i_CreatureIndex, P395_i_MapX, P396_i_MapY)
register GROUP* P393_ps_Group;
int P394_i_CreatureIndex;
int P395_i_MapX;
int P396_i_MapY;
{
        register int L0420_i_CreatureDirection;
        register int L0421_i_CreatureViewDirectionCount; /* Count of directions to test in L0425_ai_CreatureViewDirections */
        register int L0422_i_Multiple;
#define A0422_i_Counter    L0422_i_Multiple
#define A0422_i_SightRange L0422_i_Multiple
        register unsigned int L0423_ui_GroupDirections;
        register CREATURE_INFO* L0424_ps_CreatureInfo;
        int L0425_ai_CreatureViewDirections[4]; /* List of directions to test */


        L0424_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[P393_ps_Group->Type];
        if (G407_s_Party.Event71Count_Invisibility && !M07_GET(L0424_ps_CreatureInfo->Attributes, MASK0x0800_SEE_INVISIBLE)) {
                return 0;
        }
        if (M07_GET(L0424_ps_CreatureInfo->Attributes, MASK0x0004_SIDE_ATTACK)) { /* If creature can see in all directions */
                goto T200_011;
        }
        L0423_ui_GroupDirections = G375_ps_ActiveGroups[P393_ps_Group->ActiveGroupIndex].Directions;
        if (P394_i_CreatureIndex < 0) { /* Negative index means test if each creature in the group can see the party in their respective direction */
                L0421_i_CreatureViewDirectionCount = 0;
                P394_i_CreatureIndex = P393_ps_Group->Count;
                while (P394_i_CreatureIndex >= 0) {
                        L0420_i_CreatureDirection = M21_NORMALIZE(L0423_ui_GroupDirections >> (P394_i_CreatureIndex << 1));
                        A0422_i_Counter = L0421_i_CreatureViewDirectionCount;
                        while (A0422_i_Counter--) {
                                if (L0425_ai_CreatureViewDirections[A0422_i_Counter] == L0420_i_CreatureDirection) { /* If the creature looks in the same direction as another one in the group */
                                        goto T200_006;
                                }
                        }
                        L0425_ai_CreatureViewDirections[L0421_i_CreatureViewDirectionCount++] = L0420_i_CreatureDirection;
                        T200_006:
                        P394_i_CreatureIndex--;
                }
        } else { /* Positive index means test only if the specified creature in the group can see the party in its direction */
                L0425_ai_CreatureViewDirections[0] = M50_CREATURE_VALUE(L0423_ui_GroupDirections, P394_i_CreatureIndex);
                L0421_i_CreatureViewDirectionCount = 1;
        }
        while (L0421_i_CreatureViewDirectionCount--) {
                if (F227_qzzz_GROUP_IsDestinationVisibleFromSource(L0425_ai_CreatureViewDirections[L0421_i_CreatureViewDirectionCount], P395_i_MapX, P396_i_MapY, G306_i_PartyMapX, G307_i_PartyMapY)) {
                        T200_011:
                        A0422_i_SightRange = M54_SIGHT_RANGE(L0424_ps_CreatureInfo->Ranges);
                        if (!M07_GET(L0424_ps_CreatureInfo->Attributes, MASK0x1000_NIGHT_VISION)) {
                                A0422_i_SightRange -= G304_i_DungeonViewPaletteIndex >> 1;
                        }
                        if (G381_ui_CurrentGroupDistanceToParty > F025_aatz_MAIN_GetMaximumValue(1, A0422_i_SightRange)) {
                                return 0;
                        }
                        return F199_xxxx_GROUP_GetDistanceBetweenUnblockedSquares(P395_i_MapX, P396_i_MapY, G306_i_PartyMapX, G307_i_PartyMapY, &F197_xxxx_GROUP_IsViewPartyBlocked);
                }
        }
        return 0;
}

int F201_xxxx_GROUP_GetSmelledPartyPrimaryDirectionOrdinal(P397_ps_CreatureInfo, P398_i_MapY, P399_i_MapX)
CREATURE_INFO* P397_ps_CreatureInfo;
int P398_i_MapY;
int P399_i_MapX;
{
        register unsigned int L0426_ui_SmellRange;
        register int L0427_i_ScentOrdinal;


        if (!(L0426_ui_SmellRange = M55_SMELL_RANGE(P397_ps_CreatureInfo->Ranges))) {
                return 0;
        }
        if ((((L0426_ui_SmellRange + 1) >> 1) >= G381_ui_CurrentGroupDistanceToParty) && F199_xxxx_GROUP_GetDistanceBetweenUnblockedSquares(P398_i_MapY, P399_i_MapX, G306_i_PartyMapX, G307_i_PartyMapY, &F198_xxxx_GROUP_IsSmellPartyBlocked)) {
                G363_i_SecondaryDirectionToOrFromParty = G383_i_CurrentGroupSecondaryDirectionToParty;
                return M00_INDEX_TO_ORDINAL(G382_i_CurrentGroupPrimaryDirectionToParty);
        }
        if ((L0427_i_ScentOrdinal = F315_arzz_CHAMPION_GetScentOrdinal(P398_i_MapY, P399_i_MapX)) && ((G407_s_Party.ScentStrengths[M01_ORDINAL_TO_INDEX(L0427_i_ScentOrdinal)] + M04_RANDOM(4)) > (30 - (L0426_ui_SmellRange << 1)))) { /* If there is a fresh enough party scent on the group square */
                return M00_INDEX_TO_ORDINAL(F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource(P398_i_MapY, P399_i_MapX, G407_s_Party.Scents[L0427_i_ScentOrdinal].Location.MapX, G407_s_Party.Scents[L0427_i_ScentOrdinal].Location.MapY));
        }
        return 0;
}

BOOLEAN F202_xxxx_GROUP_IsMovementPossible(P400_ps_CreatureInfo, P401_i_MapX, P402_i_MapY, P403_ui_Direction, P404_B_AllowMovementOverImaginaryPitsAndFakeWalls)
register CREATURE_INFO* P400_ps_CreatureInfo;
int P401_i_MapX;
int P402_i_MapY;
unsigned int P403_ui_Direction;
BOOLEAN P404_B_AllowMovementOverImaginaryPitsAndFakeWalls;
{
        register int L0428_i_MapX;
        register int L0429_i_MapY;
        register unsigned int L0430_ui_Square;
        register int L0431_i_SquareType;
        register TELEPORTER* L0432_ps_Teleporter;
        THING L0433_T_Thing;


        G384_ac_GroupMovementTestedDirections[P403_ui_Direction] = TRUE;
        G388_T_GroupMovementBlockedByGroupThing = C0xFFFE_THING_ENDOFLIST;
        G389_B_GroupMovementBlockedByDoor = FALSE;
        G390_B_GroupMovementBlockedByParty = FALSE;
        if (P400_ps_CreatureInfo->MovementTicks == C255_IMMOBILE) {
                return FALSE;
        }
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P403_ui_Direction, 1, 0, &P401_i_MapX, &P402_i_MapY);
        L0428_i_MapX = P401_i_MapX;
        L0429_i_MapY = P402_i_MapY;
        if (G387_B_GroupMovementBlockedByWallStairsPitFakeWallFluxcageTeleporter =
                !(((L0428_i_MapX >= 0) && (L0428_i_MapX < G273_i_CurrentMapWidth)) &&
                ((L0429_i_MapY >= 0) && (L0429_i_MapY < G274_i_CurrentMapHeight)) &&
                ((L0431_i_SquareType = M34_SQUARE_TYPE(L0430_ui_Square = G271_ppuc_CurrentMapData[L0428_i_MapX][L0429_i_MapY])) != C00_ELEMENT_WALL) &&
                (L0431_i_SquareType != C03_ELEMENT_STAIRS) &&
                ((L0431_i_SquareType != C02_ELEMENT_PIT) || (M07_GET(L0430_ui_Square, MASK0x0001_PIT_IMAGINARY) && P404_B_AllowMovementOverImaginaryPitsAndFakeWalls) || !M07_GET(L0430_ui_Square, MASK0x0008_PIT_OPEN) || M07_GET(P400_ps_CreatureInfo->Attributes, MASK0x0020_LEVITATION)) &&
                ((L0431_i_SquareType != C06_ELEMENT_FAKEWALL) || M07_GET(L0430_ui_Square, MASK0x0004_FAKEWALL_OPEN) || (M07_GET(L0430_ui_Square, MASK0x0001_FAKEWALL_IMAGINARY) && P404_B_AllowMovementOverImaginaryPitsAndFakeWalls)))) {
                return FALSE;
        }
        if (M07_GET(P400_ps_CreatureInfo->Attributes, MASK0x2000_ARCHENEMY)) {
                for(L0433_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(L0428_i_MapX, L0429_i_MapY); L0433_T_Thing != C0xFFFE_THING_ENDOFLIST; L0433_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0433_T_Thing)) {
                        if (M12_TYPE(L0433_T_Thing) == C15_THING_TYPE_EXPLOSION) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                if (((EXPLOSION*)G284_apuc_ThingData[C15_THING_TYPE_EXPLOSION])[M13_INDEX(L0433_T_Thing)].Type == C050_EXPLOSION_FLUXCAGE) {
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                L0432_ps_Teleporter = (TELEPORTER*)F156_afzz_DUNGEON_GetThingData(L0433_T_Thing);
                                if (((EXPLOSION*)L0432_ps_Teleporter)->Type == C050_EXPLOSION_FLUXCAGE) {
#endif
                                        G385_ac_FluxCages[P403_ui_Direction] = TRUE;
                                        G386_ui_FluxCageCount++;
                                        G387_B_GroupMovementBlockedByWallStairsPitFakeWallFluxcageTeleporter = TRUE;
                                        return FALSE;
                                }
                        }
                }
        }
        if ((L0431_i_SquareType == C05_ELEMENT_TELEPORTER) && M07_GET(L0430_ui_Square, MASK0x0008_TELEPORTER_OPEN) && (M59_WARINESS(P400_ps_CreatureInfo->Properties) >= 10)) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0432_ps_Teleporter = (TELEPORTER*)F156_afzz_DUNGEON_GetThingData(F161_szzz_DUNGEON_GetSquareFirstThing(L0428_i_MapX, L0429_i_MapY));
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0432_ps_Teleporter = (TELEPORTER*)F157_rzzz_DUNGEON_GetSquareFirstThingData(L0428_i_MapX, L0429_i_MapY);
#endif
                if (M07_GET(L0432_ps_Teleporter->A.Scope, MASK0x0001_SCOPE_CREATURES) && !F139_aqzz_DUNGEON_IsCreatureAllowedOnMap(G380_T_CurrentGroupThing, L0432_ps_Teleporter->B.TargetMapIndex)) {
                        G387_B_GroupMovementBlockedByWallStairsPitFakeWallFluxcageTeleporter = TRUE;
                        return FALSE;
                }
        }
        if (G390_B_GroupMovementBlockedByParty = (G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (L0428_i_MapX == G306_i_PartyMapX) && (L0429_i_MapY == G307_i_PartyMapY)) {
                return FALSE;
        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        if (G389_B_GroupMovementBlockedByDoor = ((L0431_i_SquareType == C04_ELEMENT_DOOR) && !(((M36_DOOR_STATE(L0430_ui_Square)) <= (((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(L0428_i_MapX, L0429_i_MapY))].Vertical ? M51_HEIGHT(P400_ps_CreatureInfo->Attributes) : 1)) || ((M36_DOOR_STATE(L0430_ui_Square)) == C5_DOOR_STATE_DESTROYED) || M07_GET(P400_ps_CreatureInfo->Attributes, MASK0x0040_NON_MATERIAL)))) {
                return FALSE;
        }
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        if (L0431_i_SquareType == C04_ELEMENT_DOOR) {
                L0432_ps_Teleporter = (TELEPORTER*)F157_rzzz_DUNGEON_GetSquareFirstThingData(L0428_i_MapX, L0429_i_MapY);
                if (((M36_DOOR_STATE(L0430_ui_Square)) > (((DOOR*)L0432_ps_Teleporter)->Vertical ? M51_HEIGHT(P400_ps_CreatureInfo->Attributes) : 1)) && ((M36_DOOR_STATE(L0430_ui_Square)) != C5_DOOR_STATE_DESTROYED) && !M07_GET(P400_ps_CreatureInfo->Attributes, MASK0x0040_NON_MATERIAL)) {
                        G389_B_GroupMovementBlockedByDoor = TRUE;
                        return FALSE;
                }
        }
#endif
        return (G388_T_GroupMovementBlockedByGroupThing = F175_gzzz_GROUP_GetThing(L0428_i_MapX, L0429_i_MapY)) == C0xFFFE_THING_ENDOFLIST;
}

int F203_xxxx_GROUP_GetFirstPossibleMovementDirectionOrdinal(P405_ps_CreatureInfo, P406_i_MapX, P407_i_MapY, P408_B_AllowMovementOverImaginaryPitsAndFakeWalls)
CREATURE_INFO* P405_ps_CreatureInfo;
int P406_i_MapX;
int P407_i_MapY;
BOOLEAN P408_B_AllowMovementOverImaginaryPitsAndFakeWalls;
{
        register int L0434_i_Direction;


        for(L0434_i_Direction = C0_DIRECTION_NORTH; L0434_i_Direction <= C3_DIRECTION_WEST; L0434_i_Direction++) {
                if ((!G384_ac_GroupMovementTestedDirections[L0434_i_Direction]) && F202_xxxx_GROUP_IsMovementPossible(P405_ps_CreatureInfo, P406_i_MapX, P407_i_MapY, L0434_i_Direction, P408_B_AllowMovementOverImaginaryPitsAndFakeWalls)) {
                        return M00_INDEX_TO_ORDINAL(L0434_i_Direction);
                }
        }
        return 0;
}

BOOLEAN F204_xxxx_GROUP_IsArchenemyDoubleMovementPossible(P409_ps_CreatureInfo, P410_i_MapX, P411_i_MapY, P412_ui_Direction)
CREATURE_INFO* P409_ps_CreatureInfo;
int P410_i_MapX;
int P411_i_MapY;
register unsigned int P412_ui_Direction;
{
        if (G385_ac_FluxCages[P412_ui_Direction]) {
                return FALSE;
        }
        P410_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[P412_ui_Direction], P411_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[P412_ui_Direction];
        return F202_xxxx_GROUP_IsMovementPossible(P409_ps_CreatureInfo, P410_i_MapX, P411_i_MapY, P412_ui_Direction, FALSE);
}

VOID F205_xxxx_GROUP_SetDirection(P413_ps_ActiveGroup, P414_i_Direction, P415_i_CreatureIndex, P416_B_TwoHalfSquareSizedCreatures)
register ACTIVE_GROUP* P413_ps_ActiveGroup;
register int P414_i_Direction;
register int P415_i_CreatureIndex;
BOOLEAN P416_B_TwoHalfSquareSizedCreatures;
{
        register unsigned int L0435_ui_GroupDirections;
        static long G395_l_TwoHalfSquareSizedCreaturesGroupLastDirectionSetTime; /* These two variables are used to prevent setting direction of half square sized creatures twice at the same game time */
        static ACTIVE_GROUP* G396_ps_TwoHalfSquareSizedCreaturesGroupLastDirectionSetActiveGroup;


        if (P416_B_TwoHalfSquareSizedCreatures && (G313_ul_GameTime == G395_l_TwoHalfSquareSizedCreaturesGroupLastDirectionSetTime) && (P413_ps_ActiveGroup == G396_ps_TwoHalfSquareSizedCreaturesGroupLastDirectionSetActiveGroup)) {
                return;
        }
        if (M21_NORMALIZE(M50_CREATURE_VALUE(L0435_ui_GroupDirections = P413_ps_ActiveGroup->Directions, P415_i_CreatureIndex) - P414_i_Direction) == 2) { /* If current and new direction are opposites then change direction only one step at a time */
                L0435_ui_GroupDirections = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0435_ui_GroupDirections, P415_i_CreatureIndex, P414_i_Direction = M17_NEXT((M06_RANDOM(65536) & 0x0002) + P414_i_Direction));
        } else {
                L0435_ui_GroupDirections = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0435_ui_GroupDirections, P415_i_CreatureIndex, P414_i_Direction);
        }
        if (P416_B_TwoHalfSquareSizedCreatures) {
                L0435_ui_GroupDirections = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0435_ui_GroupDirections, P415_i_CreatureIndex ^ 1, P414_i_Direction); /* Set direction of the second half square sized creature */
                G395_l_TwoHalfSquareSizedCreaturesGroupLastDirectionSetTime = G313_ul_GameTime;
                G396_ps_TwoHalfSquareSizedCreaturesGroupLastDirectionSetActiveGroup = P413_ps_ActiveGroup;
        }
        P413_ps_ActiveGroup->Directions = L0435_ui_GroupDirections;
}

/* Sets direction of at least one creature in the group */
VOID F206_xxxx_GROUP_SetDirectionGroup(P417_ps_ActiveGroup, P418_i_Direction, P419_i_CreatureIndex, P420_i_CreatureSize)
ACTIVE_GROUP* P417_ps_ActiveGroup;
int P418_i_Direction;
register int P419_i_CreatureIndex;
int P420_i_CreatureSize;
{
        register BOOLEAN L0436_B_TwoHalfSquareSizedCreatures;


        if (L0436_B_TwoHalfSquareSizedCreatures = P419_i_CreatureIndex && (P420_i_CreatureSize == C1_SIZE_HALF_SQUARE)) {
                P419_i_CreatureIndex--;
        }
        do {
                if (!P419_i_CreatureIndex || M05_RANDOM(2)) {
                        F205_xxxx_GROUP_SetDirection(P417_ps_ActiveGroup, P418_i_Direction, P419_i_CreatureIndex, L0436_B_TwoHalfSquareSizedCreatures);
                }
        } while (P419_i_CreatureIndex--);
}

BOOLEAN F207_xxxx_GROUP_IsCreatureAttacking(P421_ps_Group, P422_i_MapX, P423_i_MapY, P424_i_CreatureIndex)
register GROUP* P421_ps_Group;
int P422_i_MapX;
int P423_i_MapY;
int P424_i_CreatureIndex;
{
        register unsigned int L0437_ui_Multiple;
#define A0437_ui_CreatureType L0437_ui_Multiple
#define A0437_T_Thing         L0437_ui_Multiple
        register unsigned int L0438_ui_PrimaryDirectionToParty;
        register int L0439_i_Multiple;
#define A0439_i_GroupCells    L0439_i_Multiple
#define A0439_i_TargetCell    L0439_i_Multiple
#define A0439_i_ChampionIndex L0439_i_Multiple
        register int L0440_i_Multiple;
#define A0440_i_KineticEnergy      L0440_i_Multiple
#define A0440_i_Counter            L0440_i_Multiple
#define A0440_i_Damage             L0440_i_Multiple
#define A0440_i_AttackSoundOrdinal L0440_i_Multiple
        register CREATURE_INFO* L0441_ps_CreatureInfo;
        CHAMPION* L0442_ps_Champion;
        ACTIVE_GROUP L0443_s_ActiveGroup;


        G361_l_LastCreatureAttackTime = G313_ul_GameTime;
        L0443_s_ActiveGroup = G375_ps_ActiveGroups[P421_ps_Group->ActiveGroupIndex];
        L0441_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[A0437_ui_CreatureType = P421_ps_Group->Type];
        L0438_ui_PrimaryDirectionToParty = G382_i_CurrentGroupPrimaryDirectionToParty;
        if ((A0439_i_GroupCells = L0443_s_ActiveGroup.Cells) == C255_SINGLE_CENTERED_CREATURE) {
                A0439_i_TargetCell = M05_RANDOM(2);
        } else {
                A0439_i_TargetCell = ((M50_CREATURE_VALUE(A0439_i_GroupCells, P424_i_CreatureIndex) + 5 - L0438_ui_PrimaryDirectionToParty) & 0x0002) >> 1;
        }
        A0439_i_TargetCell += L0438_ui_PrimaryDirectionToParty;
        A0439_i_TargetCell &= 0x0003;
        if ((M56_ATTACK_RANGE(L0441_ps_CreatureInfo->Ranges) > 1) && ((G381_ui_CurrentGroupDistanceToParty > 1) || M05_RANDOM(2))) {
                switch (A0437_ui_CreatureType) {
                        case C14_CREATURE_VEXIRK:
                        case C23_CREATURE_LORD_CHAOS:
                                if (M05_RANDOM(2)) {
                                        A0437_T_Thing = C0xFF80_THING_EXPLOSION_FIREBALL;
                                } else {
                                        switch (M04_RANDOM(4)) {
                                                case 0:
                                                        A0437_T_Thing = C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL;
                                                        break;
                                                case 1:
                                                        A0437_T_Thing = C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT;
                                                        break;
                                                case 2:
                                                        A0437_T_Thing = C0xFF87_THING_EXPLOSION_POISON_CLOUD;
                                                        break;
                                                case 3:
                                                        A0437_T_Thing = C0xFF84_THING_EXPLOSION_OPEN_DOOR;
                                        }
                                }
                                break;
                        case C01_CREATURE_SWAMP_SLIME_SLIME_DEVIL:
                                A0437_T_Thing = C0xFF81_THING_EXPLOSION_SLIME;
                                break;
                        case C03_CREATURE_WIZARD_EYE_FLYING_EYE:
                                if (M03_RANDOM(8)) {
                                        A0437_T_Thing = C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT;
                                } else {
                                        A0437_T_Thing = C0xFF84_THING_EXPLOSION_OPEN_DOOR;
                                }
                                break;
                        case C19_CREATURE_MATERIALIZER_ZYTAZ:
                                if (M05_RANDOM(2)) {
                                        A0437_T_Thing = C0xFF87_THING_EXPLOSION_POISON_CLOUD;
                                        break;
                                }
                        case C22_CREATURE_DEMON:
                        case C24_CREATURE_RED_DRAGON:
                                A0437_T_Thing = C0xFF80_THING_EXPLOSION_FIREBALL;
                } /* BUG0_13 The game may crash when 'Lord Order' or 'Grey Lord' cast spells. This cannot happen with the original dungeons as they do not contain any groups of these types. 'Lord Order' and 'Grey Lord' creatures can cast spells (attack range > 1) but no projectile type is defined for them in the code. If these creatures are present in a dungeon they will cast projectiles containing undefined things because the variable is not initialized */
                A0440_i_KineticEnergy = (L0441_ps_CreatureInfo->Attack >> 2) + 1;
                A0440_i_KineticEnergy += M02_RANDOM(A0440_i_KineticEnergy);
                A0440_i_KineticEnergy += M02_RANDOM(A0440_i_KineticEnergy);
                F212_mzzz_PROJECTILE_Create(A0437_T_Thing, P422_i_MapX, P423_i_MapY, A0439_i_TargetCell, G382_i_CurrentGroupPrimaryDirectionToParty, F026_a003_MAIN_GetBoundedValue(20, A0440_i_KineticEnergy, 255), L0441_ps_CreatureInfo->Dexterity, 8);
        } else {
                if (M07_GET(L0441_ps_CreatureInfo->Attributes, MASK0x0010_ATTACK_ANY_CHAMPION)) {
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                        A0440_i_Counter = 0, A0439_i_ChampionIndex = M04_RANDOM(4);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                        A0439_i_ChampionIndex = M04_RANDOM(4);
                        A0440_i_Counter = 0;
#endif
                        while ((A0440_i_Counter < 4) && !G407_s_Party.Champions[A0439_i_ChampionIndex].CurrentHealth) {
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                                A0440_i_Counter++, A0439_i_ChampionIndex = M17_NEXT(A0439_i_ChampionIndex);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                                A0439_i_ChampionIndex = M17_NEXT(A0439_i_ChampionIndex);
                                A0440_i_Counter++;
#endif
                        }
                        if (A0440_i_Counter == 4) {
                                return FALSE;
                        }
                } else {
                        if ((A0439_i_ChampionIndex = F286_hzzz_CHAMPION_GetTargetChampionIndex(P422_i_MapX, P423_i_MapY, A0439_i_TargetCell)) < 0) {
                                return FALSE;
                        }
                }
                if (A0437_ui_CreatureType == C02_CREATURE_GIGGLER) {
                        F193_xxxx_GROUP_StealFromChampion(P421_ps_Group, A0439_i_ChampionIndex);
                } else {
                        A0440_i_Damage = F230_ezzz_GROUP_GetChampionDamage(P421_ps_Group, A0439_i_ChampionIndex) + 1;
                        L0442_ps_Champion = &G407_s_Party.Champions[A0439_i_ChampionIndex];
                        if (A0440_i_Damage > L0442_ps_Champion->MaximumDamageReceived) {
                                L0442_ps_Champion->MaximumDamageReceived = A0440_i_Damage;
                                L0442_ps_Champion->DirectionMaximumDamageReceived = M18_OPPOSITE(L0438_ui_PrimaryDirectionToParty);
                        }
                }
        }
        if (A0440_i_AttackSoundOrdinal = L0441_ps_CreatureInfo->AttackSoundOrdinal) {
                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(G244_auc_Graphic559_CreatureAttackSounds[--A0440_i_AttackSoundOrdinal], P422_i_MapX, P423_i_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
        }
        return TRUE;
}

VOID F208_xxxx_GROUP_AddEvent(P425_ps_Event, P426_l_Time)
register EVENT* P425_ps_Event;
register long P426_l_Time;
{
        if (P426_l_Time < M30_TIME(P425_ps_Event->Map_Time)) {
                P425_ps_Event->A.A.Type -= 5;
                P425_ps_Event->C.Ticks = M30_TIME(P425_ps_Event->Map_Time) - P426_l_Time;
                M32_SET_TIME(P425_ps_Event->Map_Time, P426_l_Time);
        } else {
                P425_ps_Event->C.Ticks = P426_l_Time - M30_TIME(P425_ps_Event->Map_Time);
        }
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P425_ps_Event);
}

VOID F209_xzzz_GROUP_ProcessEvents29to41(P427_i_EventMapX, P428_i_EventMapY, P429_i_EventType, P430_ui_Ticks)
register int P427_i_EventMapX;
register int P428_i_EventMapY;
int P429_i_EventType;
unsigned int P430_ui_Ticks;
{
        register GROUP* L0444_ps_Group;
        register ACTIVE_GROUP* L0445_ps_ActiveGroup;
        register int L0446_i_Multiple;
#define A0446_i_EventType           L0446_i_Multiple
#define A0446_i_Direction           L0446_i_Multiple
#define A0446_i_Ticks               L0446_i_Multiple
#define A0446_i_Distance            L0446_i_Multiple
#define A0446_i_Behavior2Or3        L0446_i_Multiple
#define A0446_i_CreatureAspectIndex L0446_i_Multiple
#define A0446_i_Range               L0446_i_Multiple
#define A0446_i_CreatureAttributes  L0446_i_Multiple
#define A0446_i_Cell                L0446_i_Multiple
#define A0446_i_GroupCellsCriteria  L0446_i_Multiple
        register int L0447_i_Multiple;
#define A0447_i_Behavior           L0447_i_Multiple
#define A0447_i_CreatureIndex      L0447_i_Multiple
#define A0447_i_ReferenceDirection L0447_i_Multiple
#define A0447_i_Ticks              L0447_i_Multiple
        CREATURE_INFO L0448_s_CreatureInfo;
        THING L0449_T_GroupThing;
        int L0450_i_Multiple;
#define A0450_i_DestinationMapX  L0450_i_Multiple
#define A0450_i_DistanceXToParty L0450_i_Multiple
#define A0450_i_TargetMapX       L0450_i_Multiple
        int L0451_i_Multiple;
#define A0451_i_DestinationMapY  L0451_i_Multiple
#define A0451_i_DistanceYToParty L0451_i_Multiple
#define A0451_i_TargetMapY       L0451_i_Multiple
        int L0452_i_DistanceToVisibleParty;
        BOOLEAN L0453_B_NewGroupDirectionFound;
        int L0454_i_PrimaryDirectionToOrFromParty;
        BOOLEAN L0455_B_CurrentEventTypeIsNotUpdateBehavior;
        BOOLEAN L0456_B_AllowMovementOverImaginaryPitsAndFakeWalls;
        BOOLEAN L0457_B_MoveToPriorLocation;
        BOOLEAN L0458_B_SetBehavior7_ApproachAfterReaction;
        int L0459_i_CreatureSize;
        unsigned int L0460_ui_CreatureCount;
        int L0461_i_MovementTicks;
        int L0462_i_TicksSinceLastMove;
        BOOLEAN L0463_B_Archenemy;
        long L0464_l_NextAspectUpdateTime;
        EVENT L0465_s_NextEvent;


        /* If the party is not on the map specified in the event and the event type is not one of 32, 33, 37, 38 then the event is ignored */
        if ((G272_i_CurrentMapIndex != G309_i_PartyMapIndex) && ((A0446_i_EventType = P429_i_EventType) != C37_EVENT_UPDATE_BEHAVIOR_GROUP) && (A0446_i_EventType != C32_EVENT_UPDATE_ASPECT_GROUP) && (A0446_i_EventType != C38_EVENT_UPDATE_BEHAVIOR_CREATURE_0) && (A0446_i_EventType != C33_EVENT_UPDATE_ASPECT_CREATURE_0)) {
                return;
        }
        /* If there is no creature at the location specified in the event then the event is ignored */
        if ((L0449_T_GroupThing = F175_gzzz_GROUP_GetThing(P427_i_EventMapX, P428_i_EventMapY)) == C0xFFFE_THING_ENDOFLIST) {
                return;
        }
        L0444_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0449_T_GroupThing);
        L0448_s_CreatureInfo = G243_as_Graphic559_CreatureInfo[L0444_ps_Group->Type];
        /* Update the event */
        M33_SET_MAP_AND_TIME(L0465_s_NextEvent.Map_Time, G272_i_CurrentMapIndex, G313_ul_GameTime);
        L0465_s_NextEvent.A.A.Priority = 255 - L0448_s_CreatureInfo.MovementTicks; /* The fastest creatures (with small MovementTicks value) get higher event priority */
        L0465_s_NextEvent.B.Location.MapX = P427_i_EventMapX;
        L0465_s_NextEvent.B.Location.MapY = P428_i_EventMapY;
        /* If the creature is not on the party map then try and move the creature in a random direction and place a new event 37 in the timeline for the next creature movement */
        if (G272_i_CurrentMapIndex != G309_i_PartyMapIndex) {
                if (F202_xxxx_GROUP_IsMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = M04_RANDOM(4), FALSE)) { /* BUG0_67 A group that is not on the party map may wrongly move or not move into a teleporter. Normally, a creature type with Wariness >= 10 (Vexirk, Materializer / Zytaz, Demon, Lord Chaos, Red Dragon / Dragon) would only move into a teleporter if the creature type is allowed on the destination map. However, the variable G380_T_CurrentGroupThing identifying the group is not set before being used by F139_aqzz_DUNGEON_IsCreatureAllowedOnMap called by F202_xxxx_GROUP_IsMovementPossible so the check to see if the creature type is allowed may operate on another creature type and thus return an incorrect result, causing the creature to teleport while it should not, or not to teleport while it should */
                        A0450_i_DestinationMapX = P427_i_EventMapX;
                        A0451_i_DestinationMapY = P428_i_EventMapY;
                        A0450_i_DestinationMapX += G233_ai_Graphic559_DirectionToStepEastCount[A0446_i_Direction], A0451_i_DestinationMapY += G234_ai_Graphic559_DirectionToStepNorthCount[A0446_i_Direction];
                        if (F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0449_T_GroupThing, P427_i_EventMapX, P428_i_EventMapY, A0450_i_DestinationMapX, A0451_i_DestinationMapY)) {
                                return;
                        }
                        L0465_s_NextEvent.B.Location.MapX = G397_i_MoveResultMapX;
                        L0465_s_NextEvent.B.Location.MapY = G398_i_MoveResultMapY;
                }
                L0465_s_NextEvent.A.A.Type = C37_EVENT_UPDATE_BEHAVIOR_GROUP;
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_03_IMPROVEMENT */
                A0446_i_Ticks = F025_aatz_MAIN_GetMaximumValue(10, L0448_s_CreatureInfo.MovementTicks << 1); /* Slower group movement when not on the party map */
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_03_IMPROVEMENT Group movements are greatly slowed down on maps far from the party to improve the overall game performance (less events to process) */
                A0446_i_Ticks = F025_aatz_MAIN_GetMaximumValue(F023_aarz_MAIN_GetAbsoluteValue(G272_i_CurrentMapIndex - G309_i_PartyMapIndex) << 4, L0448_s_CreatureInfo.MovementTicks << 1);
#endif
                /* BUG0_68 A group moves or acts with a wrong timing. Event is added below but L0465_s_NextEvent.C.Ticks has not been initialized. No consequence while the group is not on the party map. When the party enters the group map the first group event may have a wrong timing */
                T209_005_AddEventAndReturn:
                L0465_s_NextEvent.Map_Time += A0446_i_Ticks;
                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0465_s_NextEvent);
                return;
        }
        /* If the creature is Lord Chaos then ignore the event if the game is won. Initialize data to analyze Fluxcages */
        if (L0463_B_Archenemy = M07_GET(L0448_s_CreatureInfo.Attributes, MASK0x2000_ARCHENEMY)) {
                if (G302_B_GameWon) {
                        return;
                }
                G386_ui_FluxCageCount = 0;
                (*(long*)&G385_ac_FluxCages) = 0;
        }
        L0445_ps_ActiveGroup = &G375_ps_ActiveGroups[L0444_ps_Group->ActiveGroupIndex];
        if ((L0462_i_TicksSinceLastMove = (unsigned char)G313_ul_GameTime - L0445_ps_ActiveGroup->LastMoveTime) < 0) {
                L0462_i_TicksSinceLastMove += 256;
        }
        if ((L0461_i_MovementTicks = L0448_s_CreatureInfo.MovementTicks) == C255_IMMOBILE) {
                L0461_i_MovementTicks = 100;
        }
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_04_FIX Code moved so that creature reaction events are ignored if life is frozen */
        if (G407_s_Party.FreezeLifeTicks && !L0463_B_Archenemy) { /* If life is frozen and the creature is not Lord Chaos (Lord Chaos is immune to Freeze Life) then reschedule the event later (except for reactions which are ignored when life if frozen) */
                if (P429_i_EventType < 0) {
                        return;
                }
                L0465_s_NextEvent.A.A.Type = P429_i_EventType;
                L0465_s_NextEvent.C.Ticks = P430_ui_Ticks;
                A0446_i_Ticks = 4; /* Retry in 4 ticks */
                goto T209_005_AddEventAndReturn;
        }
#endif
        /* If the specified event type is a 'reaction' instead of a real event from the timeline then create the corresponding reaction event with a delay:
                For event CM1_EVENT_CREATE_REACTION_EVENT_31_PARTY_IS_ADJACENT, the reaction time is 1 tick
                For event CM2_EVENT_CREATE_REACTION_EVENT_30_HIT_BY_PROJECTILE and CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE, the reaction time may be 1 tick or slower: slow moving creatures react more slowly. The more recent is the last creature move, the slower the reaction */
        if (P429_i_EventType < 0) {
                L0465_s_NextEvent.A.A.Type = P429_i_EventType + C32_EVENT_UPDATE_ASPECT_GROUP;
                if ((P429_i_EventType == CM1_EVENT_CREATE_REACTION_EVENT_31_PARTY_IS_ADJACENT) || ((A0446_i_Ticks = ((L0461_i_MovementTicks + 2) >> 2) - L0462_i_TicksSinceLastMove) < 1)) { /* A0446_i_Ticks is the reaction time */
                        A0446_i_Ticks = 1; /* Retry in 1 tick */
                }
                goto T209_005_AddEventAndReturn; /* BUG0_68 A group moves or acts with a wrong timing. Event is added but L0465_s_NextEvent.C.Ticks has not been initialized */
        }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_04_FIX Creature reaction events are not ignored if life is frozen */
/* BUG0_14 While life is frozen, creature reaction events are not ignored as they should. They accumulate and can saturate the timeline. Creature reactions happen after seeing another creature in the group die, being hit by a projectile or a closing door and attacked or bumped into by the party. Each reaction creates an additional event in the timeline and these events are not removed from the timeline while life is frozen by using a Magical Box (except for Lord Chaos which is immune). When events are exhausted, new events are not added to the timeline which can cause many issues (see BUG0_18) */
        if (G407_s_Party.FreezeLifeTicks && !L0463_B_Archenemy) { /* If life is frozen and the creature is not Lord Chaos (Lord Chaos is immune to Freeze Life) then reschedule the event later */
                L0465_s_NextEvent.A.A.Type = P429_i_EventType;
                L0465_s_NextEvent.C.Ticks = P430_ui_Ticks;
                A0446_i_Ticks = 4; /* Retry in 4 ticks */
                goto T209_005_AddEventAndReturn;
        }
#endif
        A0447_i_Behavior = L0444_ps_Group->Behavior;
        L0460_ui_CreatureCount = L0444_ps_Group->Count;
        L0459_i_CreatureSize = M07_GET(L0448_s_CreatureInfo.Attributes, MASK0x0003_SIZE);
        A0450_i_DistanceXToParty = ((A0446_i_Distance = P427_i_EventMapX - G306_i_PartyMapX) < 0) ? -A0446_i_Distance : A0446_i_Distance;
        A0451_i_DistanceYToParty = ((A0446_i_Distance = P428_i_EventMapY - G307_i_PartyMapY) < 0) ? -A0446_i_Distance : A0446_i_Distance;
        G378_i_CurrentGroupMapX = P427_i_EventMapX;
        G379_i_CurrentGroupMapY = P428_i_EventMapY;
        G380_T_CurrentGroupThing = L0449_T_GroupThing;
        (*(long*)&G384_ac_GroupMovementTestedDirections) = 0;
        G381_ui_CurrentGroupDistanceToParty = F226_ozzz_GROUP_GetDistanceBetweenSquares(P427_i_EventMapX, P428_i_EventMapY, G306_i_PartyMapX, G307_i_PartyMapY);
        G382_i_CurrentGroupPrimaryDirectionToParty = F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource(P427_i_EventMapX, P428_i_EventMapY, G306_i_PartyMapX, G307_i_PartyMapY);
        G383_i_CurrentGroupSecondaryDirectionToParty = G363_i_SecondaryDirectionToOrFromParty;
        L0464_l_NextAspectUpdateTime = 0;
        L0455_B_CurrentEventTypeIsNotUpdateBehavior = TRUE;
        if (P429_i_EventType <= C31_EVENT_GROUP_REACTION_PARTY_IS_ADJACENT) { /* Process Reaction events 29 to 31 */
                switch (P429_i_EventType = P429_i_EventType - C32_EVENT_UPDATE_ASPECT_GROUP) {
                        case CM1_EVENT_CREATE_REACTION_EVENT_31_PARTY_IS_ADJACENT: /* This event is used when the party bumps into a group or attacks a group physically (not with a spell). It causes the creature behavior to change to attack if it is not already attacking the party or fleeing from target */
                                if ((A0447_i_Behavior != C6_BEHAVIOR_ATTACK) && (A0447_i_Behavior != C5_BEHAVIOR_FLEE)) {
                                        F181_czzz_GROUP_DeleteEvents(P427_i_EventMapX, P428_i_EventMapY);
                                        goto T209_044_SetBehavior6_Attack;
                                }
                                L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX;
                                L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY;
                                return;
                        case CM2_EVENT_CREATE_REACTION_EVENT_30_HIT_BY_PROJECTILE: /* This event is used for the reaction of a group after a projectile impacted with one creature in the group (some creatures may have been killed) */
                                if ((A0447_i_Behavior == C6_BEHAVIOR_ATTACK) || (A0447_i_Behavior == C5_BEHAVIOR_FLEE)) { /* If the creature is attacking the party or fleeing from the target then there is no reaction */
                                        return;
                                }
                                if ((A0446_i_Behavior2Or3 = ((A0447_i_Behavior == C3_BEHAVIOR_USELESS) || (A0447_i_Behavior == C2_BEHAVIOR_USELESS))) || (M04_RANDOM(4))) { /* BUG0_00 Useless code. Behavior cannot be 2 nor 3 because these values are never used. The actual condition is thus: if 3/4 chances */
                                        if (!F200_xxxx_GROUP_GetDistanceToVisibleParty(L0444_ps_Group, CM1_WHOLE_CREATURE_GROUP, P427_i_EventMapX, P428_i_EventMapY)) { /* If the group cannot see the party then look in a random direction to try and search for the party */
                                                L0458_B_SetBehavior7_ApproachAfterReaction = L0453_B_NewGroupDirectionFound = FALSE;
                                                goto T209_073_SetDirectionGroup;
                                        }
                                        if (A0446_i_Behavior2Or3 || (M04_RANDOM(4))) { /* BUG0_00 Useless code. Behavior cannot be 2 nor 3 because these values are never used. The actual condition is thus: if 3/4 chances then no reaction */
                                                return;
                                        }
                                } /* No 'break': proceed to instruction after the next 'case' below. Reaction is to move in a random direction to try and avoid other projectiles */
                        case CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE: /* This event is used when some creatures in the group were killed by a Poison Cloud or by a closing door or if Lord Chaos is surrounded by 3 Fluxcages. It causes the creature to move in a random direction to avoid the danger */
                                L0458_B_SetBehavior7_ApproachAfterReaction = (A0447_i_Behavior == C6_BEHAVIOR_ATTACK); /* If the creature behavior is 'Attack' and it has to move to avoid danger then it will change its behavior to 'Approach' after the movement */
                                L0453_B_NewGroupDirectionFound = FALSE;
                                goto T209_058_MoveInRandomDirection;
                }
        }
        if (P429_i_EventType < C37_EVENT_UPDATE_BEHAVIOR_GROUP) { /* Process Update Aspect events 32 to 36 */
                L0465_s_NextEvent.A.A.Type = P429_i_EventType + 5;
                if (F200_xxxx_GROUP_GetDistanceToVisibleParty(L0444_ps_Group, CM1_WHOLE_CREATURE_GROUP, P427_i_EventMapX, P428_i_EventMapY)) {
                        if ((A0447_i_Behavior != C6_BEHAVIOR_ATTACK) && (A0447_i_Behavior != C5_BEHAVIOR_FLEE)) {
                                if (M38_DISTANCE(G306_i_PartyMapX, G307_i_PartyMapY, P427_i_EventMapX, P428_i_EventMapY) <= 1) {
                                        goto T209_044_SetBehavior6_Attack;
                                }
                                if (((A0447_i_Behavior == C0_BEHAVIOR_WANDER) || (A0447_i_Behavior == C3_BEHAVIOR_USELESS)) && (A0447_i_Behavior != C7_BEHAVIOR_APPROACH)) { /* BUG0_00 Useless code. Behavior cannot be 3 because this value is never used. Moreover, the second condition in the && is redundant (if the value is 0 or 3, it cannot be 7). The actual condition is: if (A0447_i_Behavior == C0_BEHAVIOR_WANDER) */
                                        goto T209_054_SetBehavior7_Approach;
                                }
                        }
                        L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX;
                        L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY;
                }
                if (A0447_i_Behavior == C6_BEHAVIOR_ATTACK) {
                        A0446_i_CreatureAspectIndex = P429_i_EventType - C33_EVENT_UPDATE_ASPECT_CREATURE_0; /* Value -1 for event 32, meaning aspect will be updated for all creatures in the group */
                        L0464_l_NextAspectUpdateTime = F179_xxxx_GROUP_GetCreatureAspectUpdateTime(L0445_ps_ActiveGroup, A0446_i_CreatureAspectIndex, M07_GET(L0445_ps_ActiveGroup->Aspect[A0446_i_CreatureAspectIndex], MASK0x0080_IS_ATTACKING));
                        goto T209_136;
                }
                if ((A0450_i_DistanceXToParty > 3) || (A0451_i_DistanceYToParty > 3)) {
                        L0464_l_NextAspectUpdateTime = G313_ul_GameTime + M63_NEXT_NON_ATTACK_ASPECT_UPDATE_TICKS(L0448_s_CreatureInfo.AnimationTicks);
                        goto T209_136;
                }
        } else { /* Process Update Behavior events 37 to 41 */
                L0455_B_CurrentEventTypeIsNotUpdateBehavior = FALSE;
                if (P430_ui_Ticks) {
                        L0464_l_NextAspectUpdateTime = G313_ul_GameTime;
                }
                if (P429_i_EventType == C37_EVENT_UPDATE_BEHAVIOR_GROUP) { /* Process event 37, Update Group Behavior */
                        if ((A0447_i_Behavior == C0_BEHAVIOR_WANDER) || (A0447_i_Behavior == C2_BEHAVIOR_USELESS) || (A0447_i_Behavior == C3_BEHAVIOR_USELESS)) { /* BUG0_00 Useless code. Behavior cannot be 2 nor 3 because these values are never used. The actual condition is: if (A0447_i_Behavior == C0_BEHAVIOR_WANDER) */
                                if (L0452_i_DistanceToVisibleParty = F200_xxxx_GROUP_GetDistanceToVisibleParty(L0444_ps_Group, CM1_WHOLE_CREATURE_GROUP, P427_i_EventMapX, P428_i_EventMapY)) {
                                        if ((L0452_i_DistanceToVisibleParty <= M56_ATTACK_RANGE(L0448_s_CreatureInfo.Ranges)) && ((!A0450_i_DistanceXToParty) || (!A0451_i_DistanceYToParty))) { /* If the creature is in range for attack and on the same row or column as the party on the map */
                                                T209_044_SetBehavior6_Attack:
                                                if (P429_i_EventType == CM2_EVENT_CREATE_REACTION_EVENT_30_HIT_BY_PROJECTILE) {
                                                        F181_czzz_GROUP_DeleteEvents(P427_i_EventMapX, P428_i_EventMapY);
                                                }
                                                L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX;
                                                L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY;
                                                L0444_ps_Group->Behavior = C6_BEHAVIOR_ATTACK;
                                                A0446_i_Direction = G382_i_CurrentGroupPrimaryDirectionToParty;
                                                for(A0447_i_CreatureIndex = L0460_ui_CreatureCount; A0447_i_CreatureIndex >= 0; A0447_i_CreatureIndex--) {
                                                        if ((M50_CREATURE_VALUE(L0445_ps_ActiveGroup->Directions, A0447_i_CreatureIndex) != A0446_i_Direction) &&
                                                            ((!A0447_i_CreatureIndex) || (!M05_RANDOM(2)))) {
                                                                F205_xxxx_GROUP_SetDirection(L0445_ps_ActiveGroup, A0446_i_Direction, A0447_i_CreatureIndex, L0460_ui_CreatureCount && (L0459_i_CreatureSize == C1_SIZE_HALF_SQUARE));
                                                                M32_SET_TIME(L0465_s_NextEvent.Map_Time, G313_ul_GameTime + M04_RANDOM(4) + 2); /* Random delay represents the time for the creature to turn */
                                                        } else {
                                                                M32_SET_TIME(L0465_s_NextEvent.Map_Time, G313_ul_GameTime + 1);
                                                        }
                                                        if (L0455_B_CurrentEventTypeIsNotUpdateBehavior) {
                                                                L0465_s_NextEvent.Map_Time += F024_aatz_MAIN_GetMinimumValue((L0448_s_CreatureInfo.AttackTicks >> 1) + M04_RANDOM(4), P430_ui_Ticks);
                                                        }
                                                        L0465_s_NextEvent.A.A.Type = C38_EVENT_UPDATE_BEHAVIOR_CREATURE_0 + A0447_i_CreatureIndex;
                                                        F208_xxxx_GROUP_AddEvent(&L0465_s_NextEvent, F179_xxxx_GROUP_GetCreatureAspectUpdateTime(L0445_ps_ActiveGroup, A0447_i_CreatureIndex, FALSE));
                                                }
                                                return;
                                        }
                                        if (A0447_i_Behavior != C2_BEHAVIOR_USELESS) { /* BUG0_00 Useless code. Behavior cannot be 2 because this value is never used */
                                                T209_054_SetBehavior7_Approach:
                                                L0444_ps_Group->Behavior = C7_BEHAVIOR_APPROACH;
                                                L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX;
                                                L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY;
                                                L0465_s_NextEvent.Map_Time += 1;
                                                goto T209_134_SetEvent37;
                                        }
                                } else {
                                        if (A0447_i_Behavior == C0_BEHAVIOR_WANDER) {
                                                if (L0454_i_PrimaryDirectionToOrFromParty = F201_xxxx_GROUP_GetSmelledPartyPrimaryDirectionOrdinal(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY)) {
                                                        L0454_i_PrimaryDirectionToOrFromParty--;
                                                        L0456_B_AllowMovementOverImaginaryPitsAndFakeWalls = FALSE;
                                                        goto T209_085_SingleSquareMove;
                                                }
                                                L0453_B_NewGroupDirectionFound = FALSE;
                                                if (M05_RANDOM(2)) {
                                                        T209_058_MoveInRandomDirection:
                                                        A0446_i_Direction = M04_RANDOM(4);
                                                        A0447_i_ReferenceDirection = A0446_i_Direction;
                                                        L0457_B_MoveToPriorLocation = FALSE;
                                                        do {
                                                                A0450_i_DestinationMapX = P427_i_EventMapX;
                                                                A0451_i_DestinationMapY = P428_i_EventMapY;
                                                                A0450_i_DestinationMapX += G233_ai_Graphic559_DirectionToStepEastCount[A0446_i_Direction], A0451_i_DestinationMapY += G234_ai_Graphic559_DirectionToStepNorthCount[A0446_i_Direction];
                                                                if (((L0445_ps_ActiveGroup->PriorMapX != A0450_i_DestinationMapX) ||
                                                                     (L0445_ps_ActiveGroup->PriorMapY != A0451_i_DestinationMapY) ||
                                                                     (L0457_B_MoveToPriorLocation = !M04_RANDOM(4))) /* 1/4 chance of moving back to the square that the creature comes from */
                                                                    && F202_xxxx_GROUP_IsMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction, FALSE)) {
                                                                        T209_061_MoveGroup:
                                                                        if (L0453_B_NewGroupDirectionFound = ((A0447_i_Ticks = (L0461_i_MovementTicks >> 1) - L0462_i_TicksSinceLastMove) <= 0)) {
                                                                                if (F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0449_T_GroupThing, P427_i_EventMapX, P428_i_EventMapY, A0450_i_DestinationMapX, A0451_i_DestinationMapY)) {
                                                                                        return;
                                                                                }
                                                                                L0465_s_NextEvent.B.Location.MapX = G397_i_MoveResultMapX;
                                                                                L0465_s_NextEvent.B.Location.MapY = G398_i_MoveResultMapY;
                                                                                L0445_ps_ActiveGroup->PriorMapX = P427_i_EventMapX;
                                                                                L0445_ps_ActiveGroup->PriorMapY = P428_i_EventMapY;
                                                                                L0445_ps_ActiveGroup->LastMoveTime = G313_ul_GameTime;
                                                                        } else {
                                                                                L0461_i_MovementTicks = A0447_i_Ticks;
                                                                                L0462_i_TicksSinceLastMove = -1;
                                                                        }
                                                                        break;
                                                                }
                                                                if (G390_B_GroupMovementBlockedByParty) {
                                                                        if ((P429_i_EventType != CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE) &&
                                                                            ((L0444_ps_Group->Behavior != C5_BEHAVIOR_FLEE) ||
                                                                            !F203_xxxx_GROUP_GetFirstPossibleMovementDirectionOrdinal(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, FALSE) ||
                                                                            M05_RANDOM(2))) {
                                                                                goto T209_044_SetBehavior6_Attack;
                                                                        }
                                                                        L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX;
                                                                        L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY;
                                                                }
                                                        } while ((A0446_i_Direction = M17_NEXT(A0446_i_Direction)) != A0447_i_ReferenceDirection);
                                                }
                                                if (!L0453_B_NewGroupDirectionFound &&
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_03_FIX Without this additional condition, the game can freeze when you close a door over Lord Chaos (this creates an event -3). This may create an infinite loop between the 'goto T209_089_DoubleSquareMove' here and the 'goto T209_061_MoveGroup' there (if L0453_B_NewGroupDirectionFound = FALSE in the condition at T209_061_MoveGroup:) */
                                                    (L0462_i_TicksSinceLastMove != -1) &&
#endif
                                                    L0463_B_Archenemy &&
                                                    ((P429_i_EventType == CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE) || !M04_RANDOM(4))) { /* BUG0_15 The game hangs when you close a door on Lord Chaos. A condition is missing in the code to manage creatures and this may create an infinite loop between two parts in the code */
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_19_FIX When Lord Chaos senses danger on his square (because of a Poison Cloud, a closing door or 3 surrounding Fluxcages) he teleports in a direction initialized with a random value */
                                                        G363_i_SecondaryDirectionToOrFromParty = M17_NEXT(L0454_i_PrimaryDirectionToOrFromParty = M04_RANDOM(4));
#endif
                                                        goto T209_089_DoubleSquareMove; /* BUG0_69 Memory corruption when you close a door on Lord Chaos. The local variable (L0454_i_PrimaryDirectionToOrFromParty) containing the direction where Lord Chaos tries to move may be used as an array index without being initialized and cause memory corruption */
                                                }
                                                if (L0453_B_NewGroupDirectionFound || ((!M04_RANDOM(4) || (L0452_i_DistanceToVisibleParty <= M55_SMELL_RANGE(L0448_s_CreatureInfo.Ranges))) && (P429_i_EventType != CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE))) {
                                                        T209_073_SetDirectionGroup:
                                                        if (!L0453_B_NewGroupDirectionFound && (L0462_i_TicksSinceLastMove >= 0)) { /* If direction is not found yet then look around in a random direction */
                                                                A0446_i_Direction = M04_RANDOM(4);
                                                        }
                                                        F206_xxxx_GROUP_SetDirectionGroup(L0445_ps_ActiveGroup, A0446_i_Direction, L0460_ui_CreatureCount, L0459_i_CreatureSize);
                                                }
                                                /* If event is CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE or CM2_EVENT_CREATE_REACTION_EVENT_30_HIT_BY_PROJECTILE */
                                                if (P429_i_EventType < CM1_EVENT_CREATE_REACTION_EVENT_31_PARTY_IS_ADJACENT) {
                                                        if (!L0453_B_NewGroupDirectionFound) {
                                                                return;
                                                        }
                                                        if (L0458_B_SetBehavior7_ApproachAfterReaction) {
                                                                L0444_ps_Group->Behavior = C7_BEHAVIOR_APPROACH;
                                                        }
                                                        F182_aqzz_GROUP_StopAttacking(L0445_ps_ActiveGroup, P427_i_EventMapX, P428_i_EventMapY);
                                                }
                                        }
                                }
                        } else {
                                if (A0447_i_Behavior == C7_BEHAVIOR_APPROACH) {
                                        if (L0452_i_DistanceToVisibleParty = F200_xxxx_GROUP_GetDistanceToVisibleParty(L0444_ps_Group, CM1_WHOLE_CREATURE_GROUP, P427_i_EventMapX, P428_i_EventMapY)) {
                                                if ((L0452_i_DistanceToVisibleParty <= M56_ATTACK_RANGE(L0448_s_CreatureInfo.Ranges)) && ((!A0450_i_DistanceXToParty) || (!A0451_i_DistanceYToParty))) { /* If the creature is in range for attack and on the same row or column as the party on the map */
                                                        goto T209_044_SetBehavior6_Attack;
                                                }
                                                T209_081_RunTowardParty:
                                                L0461_i_MovementTicks++;
                                                L0461_i_MovementTicks = L0461_i_MovementTicks >> 1; /* Running speed is half the movement ticks */
                                                A0450_i_TargetMapX = (L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX);
                                                A0451_i_TargetMapY = (L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY);
                                        } else {
                                                T209_082_WalkTowardTarget:
                                                A0450_i_TargetMapX = L0445_ps_ActiveGroup->TargetMapX;
                                                A0451_i_TargetMapY = L0445_ps_ActiveGroup->TargetMapY;
                                                /* If the creature reached its target but the party is not there anymore */
                                                if ((P427_i_EventMapX == A0450_i_TargetMapX) && (P428_i_EventMapY == A0451_i_TargetMapY)) {
                                                        L0453_B_NewGroupDirectionFound = FALSE;
                                                        L0444_ps_Group->Behavior = C0_BEHAVIOR_WANDER;
                                                        goto T209_073_SetDirectionGroup;
                                                }
                                        }
                                        L0456_B_AllowMovementOverImaginaryPitsAndFakeWalls = TRUE;
                                        T209_084_SingleSquareMoveTowardParty:
                                        L0454_i_PrimaryDirectionToOrFromParty = F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource(P427_i_EventMapX, P428_i_EventMapY, A0450_i_TargetMapX, A0451_i_TargetMapY);
                                        T209_085_SingleSquareMove:
                                        if (F202_xxxx_GROUP_IsMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = L0454_i_PrimaryDirectionToOrFromParty, L0456_B_AllowMovementOverImaginaryPitsAndFakeWalls) ||
                                            F202_xxxx_GROUP_IsMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = G363_i_SecondaryDirectionToOrFromParty, L0456_B_AllowMovementOverImaginaryPitsAndFakeWalls && M05_RANDOM(2)) ||
                                            F202_xxxx_GROUP_IsMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = M18_OPPOSITE(A0446_i_Direction), FALSE) ||
                                            (!M04_RANDOM(4) && F202_xxxx_GROUP_IsMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = M18_OPPOSITE(L0454_i_PrimaryDirectionToOrFromParty), FALSE))) {
                                                A0450_i_DestinationMapX = P427_i_EventMapX;
                                                A0451_i_DestinationMapY = P428_i_EventMapY;
                                                A0450_i_DestinationMapX += G233_ai_Graphic559_DirectionToStepEastCount[A0446_i_Direction], A0451_i_DestinationMapY += G234_ai_Graphic559_DirectionToStepNorthCount[A0446_i_Direction];
                                                goto T209_061_MoveGroup;
                                        }
                                        if (L0463_B_Archenemy) {
                                                T209_089_DoubleSquareMove:
                                                F203_xxxx_GROUP_GetFirstPossibleMovementDirectionOrdinal(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, FALSE); /* BUG0_00 Useless code. Returned value is ignored. When Lord Chaos teleports two squares away the ability to move to the first square is ignored which means Lord Chaos can teleport through walls or any other obstacle */
                                                if (F204_xxxx_GROUP_IsArchenemyDoubleMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = L0454_i_PrimaryDirectionToOrFromParty) ||
                                                    F204_xxxx_GROUP_IsArchenemyDoubleMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = G363_i_SecondaryDirectionToOrFromParty) ||
                                                    (G386_ui_FluxCageCount && F204_xxxx_GROUP_IsArchenemyDoubleMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = M18_OPPOSITE(A0446_i_Direction))) ||
                                                    ((G386_ui_FluxCageCount >= 2) && F204_xxxx_GROUP_IsArchenemyDoubleMovementPossible(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, A0446_i_Direction = M18_OPPOSITE(L0454_i_PrimaryDirectionToOrFromParty)))) {
                                                        A0450_i_DestinationMapX = P427_i_EventMapX;
                                                        A0451_i_DestinationMapY = P428_i_EventMapY;
                                                        A0450_i_DestinationMapX += G233_ai_Graphic559_DirectionToStepEastCount[A0446_i_Direction] * 2, A0451_i_DestinationMapY += G234_ai_Graphic559_DirectionToStepNorthCount[A0446_i_Direction] * 2;
                                                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, A0450_i_DestinationMapX, A0451_i_DestinationMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                                        goto T209_061_MoveGroup;
                                                }
                                        }
                                        F206_xxxx_GROUP_SetDirectionGroup(L0445_ps_ActiveGroup, L0454_i_PrimaryDirectionToOrFromParty, L0460_ui_CreatureCount, L0459_i_CreatureSize);
                                } else {
                                        if (A0447_i_Behavior == C5_BEHAVIOR_FLEE) {
                                                T209_094_FleeFromTarget:
                                                L0456_B_AllowMovementOverImaginaryPitsAndFakeWalls = TRUE;
                                                /* If the creature can see the party then update target coordinates */
                                                if (L0452_i_DistanceToVisibleParty = F200_xxxx_GROUP_GetDistanceToVisibleParty(L0444_ps_Group, CM1_WHOLE_CREATURE_GROUP, P427_i_EventMapX, P428_i_EventMapY)) {
                                                        A0450_i_TargetMapX = (L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX);
                                                        A0451_i_TargetMapY = (L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY);
                                                } else {
                                                        if (!(--(L0445_ps_ActiveGroup->DelayFleeingFromTarget))) { /* If the creature is not afraid anymore then stop fleeing from target */
                                                                T209_096_SetBehavior0_Wander:
                                                                L0453_B_NewGroupDirectionFound = FALSE;
                                                                L0444_ps_Group->Behavior = C0_BEHAVIOR_WANDER;
                                                                goto T209_073_SetDirectionGroup;
                                                        }
                                                        if (M05_RANDOM(2)) {
                                                                /* If the creature cannot move and the party is adjacent then stop fleeing */
                                                                if (!F203_xxxx_GROUP_GetFirstPossibleMovementDirectionOrdinal(&L0448_s_CreatureInfo, P427_i_EventMapX, P428_i_EventMapY, FALSE)) {
                                                                        if (M38_DISTANCE(P427_i_EventMapX, P428_i_EventMapY, G306_i_PartyMapX, G307_i_PartyMapY) <= 1) {
                                                                                goto T209_096_SetBehavior0_Wander;
                                                                        }
                                                                }
                                                                /* Set creature target to the home square where the creature was located when the party entered the map */
                                                                A0450_i_TargetMapX = L0445_ps_ActiveGroup->HomeMapX;
                                                                A0451_i_TargetMapY = L0445_ps_ActiveGroup->HomeMapY;
                                                                goto T209_084_SingleSquareMoveTowardParty;
                                                        }
                                                        A0450_i_TargetMapX = L0445_ps_ActiveGroup->TargetMapX;
                                                        A0451_i_TargetMapY = L0445_ps_ActiveGroup->TargetMapY;
                                                }
                                                /* Try and flee from the party (opposite direction) */
                                                L0454_i_PrimaryDirectionToOrFromParty = M18_OPPOSITE(F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource(P427_i_EventMapX, P428_i_EventMapY, A0450_i_TargetMapX, A0451_i_TargetMapY));
                                                G363_i_SecondaryDirectionToOrFromParty = M18_OPPOSITE(G363_i_SecondaryDirectionToOrFromParty);
                                                L0461_i_MovementTicks -= (L0461_i_MovementTicks >> 2);
                                                goto T209_085_SingleSquareMove;
                                        }
                                }
                        }
                } else { /* Process events 38 to 41, Update Creature Behavior */
                        if (A0447_i_Behavior == C5_BEHAVIOR_FLEE) {
                                if (L0460_ui_CreatureCount) {
                                        F182_aqzz_GROUP_StopAttacking(L0445_ps_ActiveGroup, P427_i_EventMapX, P428_i_EventMapY);
                                }
                                goto T209_094_FleeFromTarget;
                        }
                        /* If the creature is attacking, then compute the next aspect update time and the next attack time */
                        if (M07_GET(L0445_ps_ActiveGroup->Aspect[A0447_i_CreatureIndex = P429_i_EventType - C38_EVENT_UPDATE_BEHAVIOR_CREATURE_0], MASK0x0080_IS_ATTACKING)) {
                                L0464_l_NextAspectUpdateTime = F179_xxxx_GROUP_GetCreatureAspectUpdateTime(L0445_ps_ActiveGroup, A0447_i_CreatureIndex, FALSE);
                                L0465_s_NextEvent.Map_Time += ((A0447_i_Ticks = L0448_s_CreatureInfo.AttackTicks) + M04_RANDOM(4) - 1);
                                if (A0447_i_Ticks > 15) {
                                        L0465_s_NextEvent.Map_Time += M03_RANDOM(8) - 2;
                                }
                        } else { /* If the creature is not attacking, then try attacking if possible */
                                if (A0447_i_CreatureIndex > L0460_ui_CreatureCount) { /* Ignore event if it is for a creature that is not in the group */
                                        return;
                                }
                                L0454_i_PrimaryDirectionToOrFromParty = G382_i_CurrentGroupPrimaryDirectionToParty;
                                /* If the party is visible, update the target coordinates */
                                if (L0452_i_DistanceToVisibleParty = F200_xxxx_GROUP_GetDistanceToVisibleParty(L0444_ps_Group, A0447_i_CreatureIndex, P427_i_EventMapX, P428_i_EventMapY)) {
                                        L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX;
                                        L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY;
                                }
                                /* If there is a single creature in the group that is not full square sized and 1/4 chance */
                                if (!L0460_ui_CreatureCount && (L0459_i_CreatureSize != C2_SIZE_FULL_SQUARE) && !((A0446_i_GroupCellsCriteria = M06_RANDOM(65536)) & 0x00C0)) {
                                        if (L0445_ps_ActiveGroup->Cells != C255_SINGLE_CENTERED_CREATURE) {
                                                /* If the creature is not already on the center of the square then change its cell */
                                                if (A0446_i_GroupCellsCriteria & 0x0038) { /* 7/8 chances of changing cell to the center of the square */
                                                        L0445_ps_ActiveGroup->Cells = C255_SINGLE_CENTERED_CREATURE;
                                                } else { /* 1/8 chance of changing cell to the next or previous cell on the square */
                                                        A0446_i_GroupCellsCriteria = M21_NORMALIZE(M21_NORMALIZE(L0445_ps_ActiveGroup->Cells) + ((A0446_i_GroupCellsCriteria & 0x0001) ? 1 : -1));
                                                }
                                        }
                                        /* If 1/8 chance and the creature is not adjacent to the party and is a quarter square sized creature then process projectile impacts and update the creature cell if still alive. When the creature is not in front of the party, it has 7/8 chances of dodging a projectile by moving to another cell or staying in the center of the square */
                                        if (!(A0446_i_GroupCellsCriteria & 0x0038) && (L0452_i_DistanceToVisibleParty != 1) && (L0459_i_CreatureSize == C0_SIZE_QUARTER_SQUARE)) {
                                                if (F218_ezzz_PROJECTILE_GetImpactCount(CM1_ELEMENT_CREATURE, P427_i_EventMapX, P428_i_EventMapY, L0445_ps_ActiveGroup->Cells) && (G364_i_CreatureDamageOutcome == C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP)) { /* This call to F218_ezzz_PROJECTILE_GetImpactCount works fine because there is a single creature in the group so L0445_ps_ActiveGroup->Cells contains only one cell index */
                                                        return;
                                                }
                                                L0445_ps_ActiveGroup->Cells = M21_NORMALIZE(A0446_i_GroupCellsCriteria);
                                        }
                                }
                                /* If the creature can see the party and is looking in the party direction or can attack in all direction */
                                if (L0452_i_DistanceToVisibleParty &&
                                    (M07_GET(L0448_s_CreatureInfo.Attributes, MASK0x0004_SIDE_ATTACK) ||
                                    M50_CREATURE_VALUE(L0445_ps_ActiveGroup->Directions, A0447_i_CreatureIndex) == L0454_i_PrimaryDirectionToOrFromParty)) {
                                        /* If the creature is in range to attack the party and random test succeeds */
                                        if ((L0452_i_DistanceToVisibleParty <= (A0446_i_Range = M56_ATTACK_RANGE(L0448_s_CreatureInfo.Ranges))) &&
                                            (!A0450_i_DistanceXToParty || !A0451_i_DistanceYToParty) &&
                                            (A0446_i_Range <= (M03_RANDOM(16) + 1))) {
                                                if ((A0446_i_Range == 1) &&
                                                    (!M07_GET(A0446_i_CreatureAttributes = L0448_s_CreatureInfo.Attributes, MASK0x0008_PREFER_BACK_ROW) || !M04_RANDOM(4) || !M07_GET(A0446_i_CreatureAttributes, MASK0x0010_ATTACK_ANY_CHAMPION)) &&
                                                    (L0459_i_CreatureSize == C0_SIZE_QUARTER_SQUARE) &&
                                                    (L0445_ps_ActiveGroup->Cells != C255_SINGLE_CENTERED_CREATURE) &&
                                                    ((A0446_i_Cell = M50_CREATURE_VALUE(L0445_ps_ActiveGroup->Cells, A0447_i_CreatureIndex)) != L0454_i_PrimaryDirectionToOrFromParty) &&
                                                    (A0446_i_Cell != M17_NEXT(L0454_i_PrimaryDirectionToOrFromParty))) { /* If the creature cannot cast spells (range = 1) and is not on a cell where it can attack the party directly and is a quarter square sized creature not in the center of the square then the creature moves to another cell and attack does not occur immediately */
                                                        if (!L0460_ui_CreatureCount && M05_RANDOM(2)) {
                                                                L0445_ps_ActiveGroup->Cells = C255_SINGLE_CENTERED_CREATURE;
                                                        } else {
                                                                if ((L0454_i_PrimaryDirectionToOrFromParty & 0x0001) == (A0446_i_Cell & 0x0001)) {
                                                                        A0446_i_Cell--;
                                                                } else {
                                                                        A0446_i_Cell++;
                                                                }
                                                                if (!F176_avzz_GROUP_GetCreatureOrdinalInCell(L0444_ps_Group, A0446_i_Cell = M21_NORMALIZE(A0446_i_Cell)) ||
                                                                    (M05_RANDOM(2) && !F176_avzz_GROUP_GetCreatureOrdinalInCell(L0444_ps_Group, A0446_i_Cell = M18_OPPOSITE(A0446_i_Cell)))) { /* If the selected cell (or the opposite cell) is not already occupied by a creature */
                                                                        if (F218_ezzz_PROJECTILE_GetImpactCount(CM1_ELEMENT_CREATURE, P427_i_EventMapX, P428_i_EventMapY, L0445_ps_ActiveGroup->Cells) && (G364_i_CreatureDamageOutcome == C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP)) { /* BUG0_70 A projectile impact on a creature may be ignored. The function F218_ezzz_PROJECTILE_GetImpactCount to detect projectile impacts when a quarter square sized creature moves inside a group (to another cell on the same square) may fail if there are several creatures in the group because the function expects a single cell index for its last parameter. The function should be called once for each cell where there is a creature */
                                                                                return;
                                                                        }
                                                                        if (G364_i_CreatureDamageOutcome != C1_OUTCOME_KILLED_SOME_CREATURES_IN_GROUP) {
                                                                                L0445_ps_ActiveGroup->Cells = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0445_ps_ActiveGroup->Cells, A0447_i_CreatureIndex, A0446_i_Cell);
                                                                        }
                                                                }
                                                        }
                                                        L0465_s_NextEvent.Map_Time += F025_aatz_MAIN_GetMaximumValue(1, (L0448_s_CreatureInfo.MovementTicks >> 1) + M05_RANDOM(2)); /* Time for the creature to change cell */
                                                        L0465_s_NextEvent.A.A.Type = P429_i_EventType;
                                                        goto T209_135;
                                                }
                                                L0464_l_NextAspectUpdateTime = F179_xxxx_GROUP_GetCreatureAspectUpdateTime(L0445_ps_ActiveGroup, A0447_i_CreatureIndex, F207_xxxx_GROUP_IsCreatureAttacking(L0444_ps_Group, P427_i_EventMapX, P428_i_EventMapY, A0447_i_CreatureIndex));
                                                L0465_s_NextEvent.Map_Time += M62_NEXT_BEHAVIOR_UPDATE_AFTER_ATTACK_TICKS(L0448_s_CreatureInfo.AnimationTicks) + M05_RANDOM(2);
                                        } else {
                                                L0444_ps_Group->Behavior = C7_BEHAVIOR_APPROACH;
                                                if (L0460_ui_CreatureCount) {
                                                        F182_aqzz_GROUP_StopAttacking(L0445_ps_ActiveGroup, P427_i_EventMapX, P428_i_EventMapY);
                                                }
                                                goto T209_081_RunTowardParty;
                                        }
                                } else {
                                        /* If the party is visible, update target coordinates */
                                        if (F200_xxxx_GROUP_GetDistanceToVisibleParty(L0444_ps_Group, CM1_WHOLE_CREATURE_GROUP, P427_i_EventMapX, P428_i_EventMapY)) {
                                                L0445_ps_ActiveGroup->TargetMapX = G306_i_PartyMapX;
                                                L0445_ps_ActiveGroup->TargetMapY = G307_i_PartyMapY;
                                                F205_xxxx_GROUP_SetDirection(L0445_ps_ActiveGroup, L0454_i_PrimaryDirectionToOrFromParty, A0447_i_CreatureIndex, L0460_ui_CreatureCount && (L0459_i_CreatureSize == C1_SIZE_HALF_SQUARE));
                                                L0465_s_NextEvent.Map_Time += 2;
                                                L0464_l_NextAspectUpdateTime = M30_TIME(L0465_s_NextEvent.Map_Time);
                                        } else { /* If the party is not visible, move to the target (last known party location) */
                                                L0444_ps_Group->Behavior = C7_BEHAVIOR_APPROACH;
                                                if (L0460_ui_CreatureCount) {
                                                        F182_aqzz_GROUP_StopAttacking(L0445_ps_ActiveGroup, P427_i_EventMapX, P428_i_EventMapY);
                                                }
                                                goto T209_082_WalkTowardTarget;
                                        }
                                }
                        }
                        L0465_s_NextEvent.A.A.Type = P429_i_EventType;
                        goto T209_136;
                }
                L0465_s_NextEvent.Map_Time += F025_aatz_MAIN_GetMaximumValue(1, M04_RANDOM(4) + L0461_i_MovementTicks - 1);
                T209_134_SetEvent37:
                L0465_s_NextEvent.A.A.Type = C37_EVENT_UPDATE_BEHAVIOR_GROUP;
        }
        T209_135:
        if (!L0464_l_NextAspectUpdateTime) {
                L0464_l_NextAspectUpdateTime = F179_xxxx_GROUP_GetCreatureAspectUpdateTime(L0445_ps_ActiveGroup, CM1_WHOLE_CREATURE_GROUP, FALSE);
        }
        T209_136:
        if (L0455_B_CurrentEventTypeIsNotUpdateBehavior) {
                L0465_s_NextEvent.Map_Time += P430_ui_Ticks;
        } else {
                L0464_l_NextAspectUpdateTime += P430_ui_Ticks;
        }
        F208_xxxx_GROUP_AddEvent(&L0465_s_NextEvent, L0464_l_NextAspectUpdateTime);
}
