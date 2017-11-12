#include "DEFS.H"

/*_Global variables_*/
int G397_i_MoveResultMapX;
int G398_i_MoveResultMapY;
unsigned int G399_ui_MoveResultMapIndex;
int G400_i_MoveResultDirection;
unsigned int G401_ui_MoveResultCell;
BOOLEAN G402_B_UseRopeToClimbDownPit;


overlay "timeline"

int F262_xxxx_MOVE_GetTeleporterRotatedGroupResult(P541_ps_Teleporter, P542_T_GroupThing, P543_ui_MapIndex)
register TELEPORTER* P541_ps_Teleporter;
register THING P542_T_GroupThing;
unsigned int P543_ui_MapIndex;
{
        register int L0683_i_Rotation;
        register unsigned int L0684_ui_GroupDirections;
        register unsigned int L0685_ui_UpdatedGroupDirections;
        register GROUP* L0686_ps_Group;
        unsigned int L0687_ui_UpdatedGroupCells;
        int L0688_i_CreatureIndex;
        BOOLEAN L0689_B_AbsoluteRotation;
        unsigned int L0690_ui_GroupCells;
        int L0691_i_CreatureSize;
        int L0692_i_RelativeRotation;


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0686_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P542_T_GroupThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0686_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(P542_T_GroupThing);
#endif
        L0683_i_Rotation = P541_ps_Teleporter->A.Rotation;
        L0684_ui_GroupDirections = F147_aawz_DUNGEON_GetGroupDirections(L0686_ps_Group, P543_ui_MapIndex);
        if (L0689_B_AbsoluteRotation = P541_ps_Teleporter->A.AbsoluteRotation) {
                L0685_ui_UpdatedGroupDirections = L0683_i_Rotation;
        } else {
                L0685_ui_UpdatedGroupDirections = M21_NORMALIZE(L0684_ui_GroupDirections + L0683_i_Rotation);
        }
        if ((L0687_ui_UpdatedGroupCells = F145_rzzz_DUNGEON_GetGroupCells(L0686_ps_Group, P543_ui_MapIndex)) != C255_SINGLE_CENTERED_CREATURE) {
                L0690_ui_GroupCells = L0687_ui_UpdatedGroupCells;
                L0691_i_CreatureSize = M07_GET(G243_as_Graphic559_CreatureInfo[L0686_ps_Group->Type].Attributes, MASK0x0003_SIZE);
                L0692_i_RelativeRotation = M21_NORMALIZE(4 + L0685_ui_UpdatedGroupDirections - L0684_ui_GroupDirections);
                for(L0688_i_CreatureIndex = 0; L0688_i_CreatureIndex <= L0686_ps_Group->Count; L0688_i_CreatureIndex++) {
                        L0685_ui_UpdatedGroupDirections = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0685_ui_UpdatedGroupDirections, L0688_i_CreatureIndex, L0689_B_AbsoluteRotation ? L0683_i_Rotation : M21_NORMALIZE(L0684_ui_GroupDirections + L0683_i_Rotation));
                        if ((L0691_i_CreatureSize == C0_SIZE_QUARTER_SQUARE) && (L0692_i_RelativeRotation = !L0689_B_AbsoluteRotation)) {
                                L0692_i_RelativeRotation = L0683_i_Rotation;
                        }
                        if (L0692_i_RelativeRotation) {
                                L0687_ui_UpdatedGroupCells = F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue(L0687_ui_UpdatedGroupCells, L0688_i_CreatureIndex, M21_NORMALIZE(L0690_ui_GroupCells + L0692_i_RelativeRotation));
                        }
                        L0684_ui_GroupDirections >>= 2;
                        L0690_ui_GroupCells >>= 2;
                }
        }
        F148_aayz_DUNGEON_SetGroupDirections(L0686_ps_Group, L0685_ui_UpdatedGroupDirections, P543_ui_MapIndex);
        F146_aczz_DUNGEON_SetGroupCells(L0686_ps_Group, L0687_ui_UpdatedGroupCells, P543_ui_MapIndex);
        if ((P543_ui_MapIndex == G309_i_PartyMapIndex) && (L0686_ps_Group->Behavior == C6_BEHAVIOR_ATTACK)) {
                return L0686_ps_Group->ActiveGroupIndex + 2;
        }
        return 1;
}

THING F263_xxxx_MOVE_GetTeleporterRotatedProjectileThing(P544_ps_Teleporter, P545_T_ProjectileThing)
TELEPORTER* P544_ps_Teleporter;
register THING P545_T_ProjectileThing;
{
        register int L0693_i_UpdatedDirection;
        register int L0694_i_Rotation;


        L0693_i_UpdatedDirection = G400_i_MoveResultDirection;
        L0694_i_Rotation = P544_ps_Teleporter->A.Rotation;
        if (P544_ps_Teleporter->A.AbsoluteRotation) {
                L0693_i_UpdatedDirection = L0694_i_Rotation;
        } else {
                L0693_i_UpdatedDirection = M21_NORMALIZE(L0693_i_UpdatedDirection + L0694_i_Rotation);
                P545_T_ProjectileThing = M15_THING_WITH_NEW_CELL(P545_T_ProjectileThing, M21_NORMALIZE(M11_CELL(P545_T_ProjectileThing) + L0694_i_Rotation));
        }
        G400_i_MoveResultDirection = L0693_i_UpdatedDirection;
        return P545_T_ProjectileThing;
}

BOOLEAN F264_avzz_MOVE_IsLevitating(P546_T_Thing)
register THING P546_T_Thing;
{
        register int L0695_i_ThingType;


        if ((L0695_i_ThingType = M12_TYPE(P546_T_Thing)) == C04_THING_TYPE_GROUP) {
                return M07_GET(F144_amzz_DUNGEON_GetCreatureAttributes(P546_T_Thing), MASK0x0020_LEVITATION);
        }
        if (L0695_i_ThingType == C14_THING_TYPE_PROJECTILE) { /* BUG0_26 An explosion may fall in a pit. If a pit is opened while there is an explosion above then the explosion falls into the pit in F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE. Explosions are not considered as levitating so they are moved when the pit is opened. This function should return TRUE for explosions */
                return TRUE;
        }
        return FALSE;
}

VOID F265_xxxx_MOVE_CreateEvent60To61_MoveGroup(P547_T_GroupThing, P548_i_MapX, P549_i_MapY, P550_i_MapIndex, P551_B_Audible)
register THING P547_T_GroupThing;
int P548_i_MapX;
int P549_i_MapY;
int P550_i_MapIndex;
BOOLEAN P551_B_Audible;
{
        EVENT L0696_s_Event;


        M33_SET_MAP_AND_TIME(L0696_s_Event.Map_Time, P550_i_MapIndex, G313_ul_GameTime + 5);
        L0696_s_Event.A.A.Type = P551_B_Audible ? C61_EVENT_MOVE_GROUP_AUDIBLE : C60_EVENT_MOVE_GROUP_SILENT;
        L0696_s_Event.A.A.Priority = 0;
        L0696_s_Event.B.Location.MapX = P548_i_MapX;
        L0696_s_Event.B.Location.MapY = P549_i_MapY;
        L0696_s_Event.C.Slot = P547_T_GroupThing;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0696_s_Event);
}

/* This function processes projectile impacts when moving the party or a group. It return TRUE only if a group was killed by a projectile impact */
BOOLEAN F266_xxxx_MOVE_IsKilledByProjectileImpact(P552_i_SourceMapX, P553_i_SourceMapY, P554_i_DestinationMapX, P555_i_DestinationMapY, P556_T_Thing)
int P552_i_SourceMapX;
int P553_i_SourceMapY;
int P554_i_DestinationMapX;
int P555_i_DestinationMapY;
THING P556_T_Thing; /* Must be the party or a group */
{
        register THING L0697_T_Thing;
        register int L0698_i_Unreferenced; /* BUG0_00 Useless code */
        register unsigned int L0699_ui_Multiple;
#define A0699_ui_Cell                      L0699_ui_Multiple
#define A0699_ui_PrimaryDirection          L0699_ui_Multiple
#define A0699_ui_ChampionOrCreatureOrdinal L0699_ui_Multiple
        register int L0700_i_Multiple;
#define A0700_B_CreatureAlive      L0700_i_Multiple
#define A0700_i_Distance           L0700_i_Multiple
#define A0700_i_SecondaryDirection L0700_i_Multiple
        register GROUP* L0701_ps_Group;
        int L0702_i_ImpactType;
        BOOLEAN L0703_B_CheckDestinationSquareProjectileImpacts;
        int L0704_i_ProjectileMapX;
        int L0705_i_ProjectileMapY;
        unsigned char L0706_auc_IntermediaryChampionOrCreatureOrdinalInCell[4]; /* This array is used only when moving between two adjacent squares and is used to test projectile impacts when the party or group is in the 'intermediary' step between the two squares. Without this test, in the example below no impact would be detected. In this example, the party moves from the source square on the left (which contains a single champion at cell 2) to the destination square on the right (which contains a single projectile at cell 3).
        Party:      Projectiles on target square:   Incorrect result without the test for the intermediary step (the champion would have passed through the projectile without impact):
        00    ->    00                         00
        01          P0                         P1 */
        unsigned char L0707_auc_ChampionOrCreatureOrdinalInCell[4]; /* This array has an entry for each cell on the source square, containing the ordinal of the champion or creature (0 if there is no champion or creature at this cell) */


        L0703_B_CheckDestinationSquareProjectileImpacts = FALSE;
        F008_aA19_MAIN_ClearBytes(L0707_auc_ChampionOrCreatureOrdinalInCell, sizeof(L0707_auc_ChampionOrCreatureOrdinalInCell));
        if (P556_T_Thing == C0xFFFF_THING_PARTY) {
                L0702_i_ImpactType = CM2_ELEMENT_CHAMPION;
                for(A0699_ui_Cell = C00_CELL_NORTHWEST; A0699_ui_Cell < C03_CELL_SOUTHWEST + 1; A0699_ui_Cell++) {
                        if (F285_szzz_CHAMPION_GetIndexInCell(A0699_ui_Cell) >= 0) {
                                L0707_auc_ChampionOrCreatureOrdinalInCell[A0699_ui_Cell] = M00_INDEX_TO_ORDINAL(A0699_ui_Cell);
                        }
                }
        } else {
                L0702_i_ImpactType = CM1_ELEMENT_CREATURE;
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0701_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P556_T_Thing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0701_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(P556_T_Thing);
#endif
                for(A0699_ui_Cell = C00_CELL_NORTHWEST, A0700_B_CreatureAlive = FALSE; A0699_ui_Cell < C03_CELL_SOUTHWEST + 1; A0699_ui_Cell++) {
                        A0700_B_CreatureAlive |= L0701_ps_Group->Health[A0699_ui_Cell];
                        if (F176_avzz_GROUP_GetCreatureOrdinalInCell(L0701_ps_Group, A0699_ui_Cell)) {
                                L0707_auc_ChampionOrCreatureOrdinalInCell[A0699_ui_Cell] = M00_INDEX_TO_ORDINAL(A0699_ui_Cell);
                        }
                }
                if (!A0700_B_CreatureAlive) {
                        return FALSE;
                }
        }
        if ((P554_i_DestinationMapX >= 0) && (((((A0700_i_Distance = P552_i_SourceMapX - P554_i_DestinationMapX) < 0) ? -A0700_i_Distance : A0700_i_Distance) + (((A0700_i_Distance = P553_i_SourceMapY - P555_i_DestinationMapY) < 0) ? -A0700_i_Distance : A0700_i_Distance)) == 1)) { /* If source and destination squares are adjacent (if party or group is not being teleported) */
                A0699_ui_PrimaryDirection = F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource(P552_i_SourceMapX, P553_i_SourceMapY, P554_i_DestinationMapX, P555_i_DestinationMapY);
                A0700_i_SecondaryDirection = M17_NEXT(A0699_ui_PrimaryDirection);
                F008_aA19_MAIN_ClearBytes(L0706_auc_IntermediaryChampionOrCreatureOrdinalInCell, sizeof(L0706_auc_IntermediaryChampionOrCreatureOrdinalInCell));
                if (L0706_auc_IntermediaryChampionOrCreatureOrdinalInCell[M19_PREVIOUS(A0699_ui_PrimaryDirection)] = L0707_auc_ChampionOrCreatureOrdinalInCell[A0699_ui_PrimaryDirection]) {
                        L0703_B_CheckDestinationSquareProjectileImpacts = TRUE;
                }
                if (L0706_auc_IntermediaryChampionOrCreatureOrdinalInCell[M17_NEXT(A0700_i_SecondaryDirection)] = L0707_auc_ChampionOrCreatureOrdinalInCell[A0700_i_SecondaryDirection]) {
                        L0703_B_CheckDestinationSquareProjectileImpacts = TRUE;
                }
                if (!L0707_auc_ChampionOrCreatureOrdinalInCell[A0699_ui_PrimaryDirection]) {
                        L0707_auc_ChampionOrCreatureOrdinalInCell[A0699_ui_PrimaryDirection] = L0707_auc_ChampionOrCreatureOrdinalInCell[M19_PREVIOUS(A0699_ui_PrimaryDirection)];
                }
                if (!L0707_auc_ChampionOrCreatureOrdinalInCell[A0700_i_SecondaryDirection]) {
                        L0707_auc_ChampionOrCreatureOrdinalInCell[A0700_i_SecondaryDirection] = L0707_auc_ChampionOrCreatureOrdinalInCell[M17_NEXT(A0700_i_SecondaryDirection)];
                }
        }
        L0704_i_ProjectileMapX = P552_i_SourceMapX; /* Check impacts with projectiles on the source square */
        L0705_i_ProjectileMapY = P553_i_SourceMapY;
        T266_017_CheckProjectileImpacts:
        for(L0697_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(L0704_i_ProjectileMapX, L0705_i_ProjectileMapY); L0697_T_Thing != C0xFFFE_THING_ENDOFLIST; L0697_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0697_T_Thing)) {
                if ((M12_TYPE(L0697_T_Thing) == C14_THING_TYPE_PROJECTILE) &&
                    (G370_ps_Events[(((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(L0697_T_Thing)]).EventIndex].A.A.Type != C48_EVENT_MOVE_PROJECTILE_IGNORE_IMPACTS) && (A0699_ui_ChampionOrCreatureOrdinal = L0707_auc_ChampionOrCreatureOrdinalInCell[M11_CELL(L0697_T_Thing)]) &&
                    F217_xxxx_PROJECTILE_HasImpactOccured(L0702_i_ImpactType, P552_i_SourceMapX, P553_i_SourceMapY, M01_ORDINAL_TO_INDEX(A0699_ui_ChampionOrCreatureOrdinal), L0697_T_Thing)) {
                        F214_pzzz_PROJECTILE_DeleteEvent(L0697_T_Thing);
                        if (G364_i_CreatureDamageOutcome == C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP) {
                                return TRUE;
                        }
                        goto T266_017_CheckProjectileImpacts;
                }
        }
        if (L0703_B_CheckDestinationSquareProjectileImpacts) {
                P552_i_SourceMapX |= ((L0704_i_ProjectileMapX = P554_i_DestinationMapX) + 1) << 8; /* Check impacts with projectiles on the destination square */
                P553_i_SourceMapY |= (L0705_i_ProjectileMapY = P555_i_DestinationMapY) << 8;
                F007_aAA7_MAIN_CopyBytes(L0706_auc_IntermediaryChampionOrCreatureOrdinalInCell, L0707_auc_ChampionOrCreatureOrdinalInCell, sizeof(L0707_auc_ChampionOrCreatureOrdinalInCell));
                L0703_B_CheckDestinationSquareProjectileImpacts = FALSE;
                goto T266_017_CheckProjectileImpacts;
        }
        return FALSE;
}

/* Returns 0 (FALSE) if the thing was moved successfully. Returns non 0 (TRUE or > 1) if the specified thing is a group and the ACTIVE_GROUP has been refreshed or removed which occurs when the group was blocked by the party (the group is then removed from the dungeon and an event is created to move the group back in the dungeon later), killed during movement or teleported, or entered or leaved the party map */
BOOLEAN F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(P557_T_Thing, P558_i_SourceMapX, P559_i_SourceMapY, P560_i_DestinationMapX, P561_i_DestinationMapY)
register THING P557_T_Thing;
int P558_i_SourceMapX; /* If P558_i_SourceMapX is negative (CM1_MAPX_NOT_ON_A_SQUARE or CM2_MAPX_PROJECTILE_ASSOCIATED_OBJECT) then place the thing on the destination square. If placing a projectile associated object (CM2_MAPX_PROJECTILE_ASSOCIATED_OBJECT) on a teleporter square with an absolute rotation then ignore the rotation */
int P559_i_SourceMapY;
int P560_i_DestinationMapX; /* If P560_i_DestinationMapX is negative, then remove the thing from the source square */
int P561_i_DestinationMapY;
{
        register int L0708_i_Multiple;
#define A0708_i_DestinationSquare L0708_i_Multiple
#define A0708_i_ScentIndex        L0708_i_Multiple
#define A0708_i_ActiveGroupIndex  L0708_i_Multiple
        register int L0709_i_Multiple;
#define A0709_i_DestinationSquareType L0709_i_Multiple
#define A0709_i_ChampionIndex         L0709_i_Multiple
        register int L0710_i_ThingType;
        register CHAMPION* L0711_ps_Champion;
        register TELEPORTER* L0712_ps_Teleporter;
        BOOLEAN L0713_B_ThingLevitates;
        unsigned int L0714_ui_MapIndexSource;
        unsigned int L0715_ui_MapIndexDestination;
        int L0716_i_Direction;
        unsigned int L0717_ui_ThingCell;
        int L0718_i_RequiredTeleporterScope;
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_04_FIX */
        int L0719_i_TraversedPitCount;
#endif
        unsigned int L0720_ui_MoveGroupResult;
        BOOLEAN L0721_B_GroupOnPartyMap;
        BOOLEAN L0722_B_FallKilledGroup;
        BOOLEAN L0723_B_DrawDungeonViewWhileFalling;
        BOOLEAN L0724_B_DestinationIsTeleporterTarget;
        BOOLEAN L0725_B_PartySquare;
        BOOLEAN L0726_B_Audible;
        unsigned int L0727_ui_Multiple;
#define A0727_ui_ThingCell L0727_ui_Multiple
#define A0727_ui_Outcome   L0727_ui_Multiple
#define A0727_ui_Backup    L0727_ui_Multiple
        int L0728_i_ChainedMoveCount;


        L0710_i_ThingType = CM1_THING_TYPE_PARTY;
        L0713_B_ThingLevitates = FALSE;
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_04_FIX */
        L0719_i_TraversedPitCount = 0;
#endif
        L0720_ui_MoveGroupResult = 0;
        L0721_B_GroupOnPartyMap = FALSE;
        L0722_B_FallKilledGroup = FALSE;
        L0723_B_DrawDungeonViewWhileFalling = FALSE;
        L0724_B_DestinationIsTeleporterTarget = FALSE;
        L0725_B_PartySquare = FALSE;
        L0726_B_Audible = FALSE;
        if (P557_T_Thing != C0xFFFF_THING_PARTY) {
                L0710_i_ThingType = M12_TYPE(P557_T_Thing);
                L0717_ui_ThingCell = M11_CELL(P557_T_Thing);
                L0713_B_ThingLevitates = F264_avzz_MOVE_IsLevitating(P557_T_Thing);
        }
        /* If moving the party or a creature on the party map from a dungeon square then check for a projectile impact */
        if ((P558_i_SourceMapX >= 0) && ((P557_T_Thing == C0xFFFF_THING_PARTY) || ((L0710_i_ThingType == C04_THING_TYPE_GROUP) && (G272_i_CurrentMapIndex == G309_i_PartyMapIndex)))) {
                if (F266_xxxx_MOVE_IsKilledByProjectileImpact(P558_i_SourceMapX, P559_i_SourceMapY, P560_i_DestinationMapX, P561_i_DestinationMapY, P557_T_Thing)) {
                        return TRUE; /* The specified group thing cannot be moved because it was killed by a projectile impact */
                }
        }
        if (P560_i_DestinationMapX >= 0) {
                L0714_ui_MapIndexSource = L0715_ui_MapIndexDestination = G272_i_CurrentMapIndex;
                L0721_B_GroupOnPartyMap = (L0714_ui_MapIndexSource == G309_i_PartyMapIndex) && (P558_i_SourceMapX >= 0);
                if (P557_T_Thing == C0xFFFF_THING_PARTY) {
                        G306_i_PartyMapX = P560_i_DestinationMapX;
                        G307_i_PartyMapY = P561_i_DestinationMapY;
                        L0718_i_RequiredTeleporterScope = MASK0x0002_SCOPE_OBJECTS_OR_PARTY;
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_06_FIX The dungeon view is drawn during a fall while the party is sleeping */
                        L0723_B_DrawDungeonViewWhileFalling = !G423_i_InventoryChampionOrdinal; /* BUG0_27 If a pit opens under the party while it is sleeping then the dungeon view is drawn during the fall without the floor and ceiling, even though it should not be visible at all until the party wakes up at the end of the fall */
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_06_FIX The dungeon view is not drawn during a fall while the party is sleeping */
                        L0723_B_DrawDungeonViewWhileFalling = !G423_i_InventoryChampionOrdinal && !G300_B_PartyIsSleeping;
#endif
                        L0716_i_Direction = G308_i_PartyDirection;
                } else {
                        if (L0710_i_ThingType == C04_THING_TYPE_GROUP) {
                                L0718_i_RequiredTeleporterScope = MASK0x0001_SCOPE_CREATURES;
                        } else {
                                L0718_i_RequiredTeleporterScope = (MASK0x0001_SCOPE_CREATURES | MASK0x0002_SCOPE_OBJECTS_OR_PARTY);
                        }
                }
                if (L0710_i_ThingType == C14_THING_TYPE_PROJECTILE) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        G400_i_MoveResultDirection = (G370_ps_Events[((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(P557_T_Thing)].EventIndex]).C.Projectile.Direction;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0712_ps_Teleporter = (TELEPORTER*)F156_afzz_DUNGEON_GetThingData(P557_T_Thing);
                        G400_i_MoveResultDirection = (G370_ps_Events[((PROJECTILE*)L0712_ps_Teleporter)->EventIndex]).C.Projectile.Direction;
#endif
                }
                L0728_i_ChainedMoveCount = 1000; /* No more than 1000 chained moves at once (in a chain of teleporters and pits for example) */
                while (--L0728_i_ChainedMoveCount) {
                        A0708_i_DestinationSquare = G271_ppuc_CurrentMapData[P560_i_DestinationMapX][P561_i_DestinationMapY];
                        if ((A0709_i_DestinationSquareType = M34_SQUARE_TYPE(A0708_i_DestinationSquare)) == C05_ELEMENT_TELEPORTER) {
                                if (!M07_GET(A0708_i_DestinationSquare, MASK0x0008_TELEPORTER_OPEN)) {
                                        break;
                                }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                L0712_ps_Teleporter = (TELEPORTER*)F156_afzz_DUNGEON_GetThingData(F161_szzz_DUNGEON_GetSquareFirstThing(P560_i_DestinationMapX, P561_i_DestinationMapY));
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                L0712_ps_Teleporter = (TELEPORTER*)F157_rzzz_DUNGEON_GetSquareFirstThingData(P560_i_DestinationMapX, P561_i_DestinationMapY);
#endif
                                if ((L0712_ps_Teleporter->A.Scope == MASK0x0001_SCOPE_CREATURES) && (L0710_i_ThingType != C04_THING_TYPE_GROUP)) {
                                        break;
                                }
                                if ((L0718_i_RequiredTeleporterScope != (MASK0x0001_SCOPE_CREATURES | MASK0x0002_SCOPE_OBJECTS_OR_PARTY)) && !M07_GET(L0712_ps_Teleporter->A.Scope, L0718_i_RequiredTeleporterScope)) {
                                        break;
                                }
                                L0724_B_DestinationIsTeleporterTarget = (P560_i_DestinationMapX == L0712_ps_Teleporter->A.TargetMapX) && (P561_i_DestinationMapY == L0712_ps_Teleporter->A.TargetMapY) && (L0715_ui_MapIndexDestination == L0712_ps_Teleporter->B.TargetMapIndex);
                                P560_i_DestinationMapX = L0712_ps_Teleporter->A.TargetMapX;
                                P561_i_DestinationMapY = L0712_ps_Teleporter->A.TargetMapY;
                                L0726_B_Audible = L0712_ps_Teleporter->A.Audible;
                                F173_gzzz_DUNGEON_SetCurrentMap(L0715_ui_MapIndexDestination = L0712_ps_Teleporter->B.TargetMapIndex);
                                if (P557_T_Thing == C0xFFFF_THING_PARTY) {
                                        G306_i_PartyMapX = P560_i_DestinationMapX;
                                        G307_i_PartyMapY = P561_i_DestinationMapY;
                                        if (L0712_ps_Teleporter->A.Audible) {
                                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, G306_i_PartyMapX, G307_i_PartyMapY, C00_MODE_PLAY_IMMEDIATELY);
                                        }
                                        L0723_B_DrawDungeonViewWhileFalling &= G661_B_LargeHeapMemory;
                                        if (L0712_ps_Teleporter->A.AbsoluteRotation) {
                                                F284_czzz_CHAMPION_SetPartyDirection(L0712_ps_Teleporter->A.Rotation);
                                        } else {
                                                F284_czzz_CHAMPION_SetPartyDirection(M21_NORMALIZE(G308_i_PartyDirection + L0712_ps_Teleporter->A.Rotation));
                                        }
                                } else {
                                        if (L0710_i_ThingType == C04_THING_TYPE_GROUP) {
                                                if (L0712_ps_Teleporter->A.Audible) {
                                                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, P560_i_DestinationMapX, P561_i_DestinationMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                                }
                                                L0720_ui_MoveGroupResult = F262_xxxx_MOVE_GetTeleporterRotatedGroupResult(L0712_ps_Teleporter, P557_T_Thing, L0714_ui_MapIndexSource);
                                        } else {
                                                if (L0710_i_ThingType == C14_THING_TYPE_PROJECTILE) {
                                                        P557_T_Thing = F263_xxxx_MOVE_GetTeleporterRotatedProjectileThing(L0712_ps_Teleporter, P557_T_Thing);
                                                } else {
                                                        if (!(L0712_ps_Teleporter->A.AbsoluteRotation) && (P558_i_SourceMapX != CM2_MAPX_PROJECTILE_ASSOCIATED_OBJECT)) {
                                                                P557_T_Thing = M15_THING_WITH_NEW_CELL(P557_T_Thing, M21_NORMALIZE(M11_CELL(P557_T_Thing) + L0712_ps_Teleporter->A.Rotation));
                                                        }
                                                }
                                        }
                                }
                                if (L0724_B_DestinationIsTeleporterTarget) {
                                        break;
                                }
                        } else {
                                if ((A0709_i_DestinationSquareType == C02_ELEMENT_PIT) && !L0713_B_ThingLevitates && M07_GET(A0708_i_DestinationSquare, MASK0x0008_PIT_OPEN) && !M07_GET(A0708_i_DestinationSquare, MASK0x0001_PIT_IMAGINARY)) {
                                        if (L0723_B_DrawDungeonViewWhileFalling && !G402_B_UseRopeToClimbDownPit) {
                                                L0723_B_DrawDungeonViewWhileFalling = G661_B_LargeHeapMemory;
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_04_FIX Graphics for each traversed map are loaded before drawing the dungeon view while falling so that the dungeon view is drawn with appropriate graphics */
                                                if (L0719_i_TraversedPitCount) {
                                                        F174_aozz_DUNGEON_SetCurrentMapAndPartyMap(L0715_ui_MapIndexDestination);
                                                        F096_qzzz_DUNGEONVIEW_LoadCurrentMapGraphics_COPYPROTECTIONDF();
                                                }
                                                L0719_i_TraversedPitCount++;
#endif
                                                F128_rzzz_DUNGEONVIEW_Draw_COPYPROTECTIONF(G308_i_PartyDirection, P560_i_DestinationMapX, P561_i_DestinationMapY); /* BUG0_28 When falling through multiple pits the dungeon view is updated to show each traversed map but the graphics used for creatures, wall and floor ornaments may not be correct. The dungeon view is drawn for each map by using the graphics loaded for the source map. Therefore the graphics for creatures, wall and floor ornaments may not look like what they should */
                                                /* BUG0_71 Some timings are too short on fast computers. When the party falls in a series of pits, the dungeon view is refreshed too quickly because the execution speed is not limited */
                                                /* BUG0_01 While drawing creatures the engine will read invalid ACTIVE_GROUP data in G375_ps_ActiveGroups because the data is for the creatures on the source map and not the map being drawn. The only consequence is that creatures may be drawn with incorrect bitmaps and/or directions */
                                        }
                                        L0715_ui_MapIndexDestination = F154_afzz_DUNGEON_GetLocationAfterLevelChange(L0715_ui_MapIndexDestination, 1, &P560_i_DestinationMapX, &P561_i_DestinationMapY);
                                        F173_gzzz_DUNGEON_SetCurrentMap(L0715_ui_MapIndexDestination);
                                        if (P557_T_Thing == C0xFFFF_THING_PARTY) {
                                                G306_i_PartyMapX = P560_i_DestinationMapX;
                                                G307_i_PartyMapY = P561_i_DestinationMapY;
                                                if (G305_ui_PartyChampionCount > 0) {
                                                        if (G402_B_UseRopeToClimbDownPit) {
                                                                for(A0709_i_ChampionIndex = C00_CHAMPION_FIRST, L0711_ps_Champion = G407_s_Party.Champions; A0709_i_ChampionIndex < G305_ui_PartyChampionCount; A0709_i_ChampionIndex++, L0711_ps_Champion++) {
                                                                        if (L0711_ps_Champion->CurrentHealth) {
                                                                                F325_bzzz_CHAMPION_DecrementStamina(A0709_i_ChampionIndex, ((L0711_ps_Champion->Load * 25) / F309_awzz_CHAMPION_GetMaximumLoad(L0711_ps_Champion)) + 1);
                                                                        }
                                                                }
                                                        } else {
                                                                if (F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount(20, MASK0x0010_LEGS | MASK0x0020_FEET, C2_ATTACK_SELF)) {
                                                                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C06_SOUND_SCREAM, G306_i_PartyMapX, G307_i_PartyMapY, C00_MODE_PLAY_IMMEDIATELY);
                                                                }
                                                        }
                                                }
                                                G402_B_UseRopeToClimbDownPit = FALSE;
                                        } else {
                                                if (L0710_i_ThingType == C04_THING_TYPE_GROUP) {
                                                        F173_gzzz_DUNGEON_SetCurrentMap(L0714_ui_MapIndexSource);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                                        A0727_ui_Outcome = F191_aayz_GROUP_GetDamageAllCreaturesOutcome(&((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P557_T_Thing)], P558_i_SourceMapX, P559_i_SourceMapY, 20, FALSE);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                                        A0727_ui_Outcome = F191_aayz_GROUP_GetDamageAllCreaturesOutcome((GROUP*)F156_afzz_DUNGEON_GetThingData(P557_T_Thing), P558_i_SourceMapX, P559_i_SourceMapY, 20, FALSE);
#endif
                                                        F173_gzzz_DUNGEON_SetCurrentMap(L0715_ui_MapIndexDestination);
                                                        if (L0722_B_FallKilledGroup = (A0727_ui_Outcome == C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP)) {
                                                                break;
                                                        }
                                                        if (A0727_ui_Outcome == C1_OUTCOME_KILLED_SOME_CREATURES_IN_GROUP) {
                                                                F187_czzz_GROUP_DropMovingCreatureFixedPossessions(P557_T_Thing, P560_i_DestinationMapX, P561_i_DestinationMapY);
                                                        }
                                                }
                                        }
                                } else {
                                        if ((A0709_i_DestinationSquareType == C03_ELEMENT_STAIRS) && (P557_T_Thing != C0xFFFF_THING_PARTY) && (L0710_i_ThingType != C14_THING_TYPE_PROJECTILE)) {
                                                if (!M07_GET(A0708_i_DestinationSquare, MASK0x0004_STAIRS_UP)) {
                                                        L0715_ui_MapIndexDestination = F154_afzz_DUNGEON_GetLocationAfterLevelChange(L0715_ui_MapIndexDestination, 1, &P560_i_DestinationMapX, &P561_i_DestinationMapY);
                                                        F173_gzzz_DUNGEON_SetCurrentMap(L0715_ui_MapIndexDestination);
                                                }
                                                L0716_i_Direction = F155_ahzz_DUNGEON_GetStairsExitDirection(P560_i_DestinationMapX, P561_i_DestinationMapY);
                                                P560_i_DestinationMapX += G233_ai_Graphic559_DirectionToStepEastCount[L0716_i_Direction], P561_i_DestinationMapY += G234_ai_Graphic559_DirectionToStepNorthCount[L0716_i_Direction];
                                                L0716_i_Direction = M18_OPPOSITE(L0716_i_Direction);
                                                A0727_ui_ThingCell = M11_CELL(P557_T_Thing);
                                                A0727_ui_ThingCell = M21_NORMALIZE((((A0727_ui_ThingCell - L0716_i_Direction + 1) & 0x0002) >> 1) + L0716_i_Direction);
                                                P557_T_Thing = M15_THING_WITH_NEW_CELL(P557_T_Thing, A0727_ui_ThingCell);
                                        } else {
                                                break;
                                        }
                                }
                        }
                }
                if ((L0710_i_ThingType == C04_THING_TYPE_GROUP) && (L0722_B_FallKilledGroup || !F139_aqzz_DUNGEON_IsCreatureAllowedOnMap(P557_T_Thing, L0715_ui_MapIndexDestination))) {
                        F187_czzz_GROUP_DropMovingCreatureFixedPossessions(P557_T_Thing, P560_i_DestinationMapX, P561_i_DestinationMapY);
                        F188_aozz_GROUP_DropGroupPossessions(P560_i_DestinationMapX, P561_i_DestinationMapY, P557_T_Thing, C02_MODE_PLAY_ONE_TICK_LATER);
                        F173_gzzz_DUNGEON_SetCurrentMap(L0714_ui_MapIndexSource);
                        if (P558_i_SourceMapX >= 0) {
                                F189_awzz_GROUP_Delete(P558_i_SourceMapX, P559_i_SourceMapY);
                        }
                        return TRUE; /* The specified group thing cannot be moved because it was killed by a fall or because it is not allowed on the destination map */
                }
#ifndef NOCOPYPROTECTION
                if ((L0715_ui_MapIndexDestination > 2) && !(P560_i_DestinationMapX & 0x0007) && !(P561_i_DestinationMapY & 0x0003) && (F413_AA08_COPYPROTECTIONC_GetChecksumEor(&F433_AA39_STARTEND_ProcessCommand140_SaveGame_COPYPROTECTIONCDF) != CHECKSUM_A)) {
                        P560_i_DestinationMapX += P561_i_DestinationMapY;
                        P561_i_DestinationMapY -= P560_i_DestinationMapX;
                }
#endif
                G397_i_MoveResultMapX = P560_i_DestinationMapX;
                G398_i_MoveResultMapY = P561_i_DestinationMapY;
                G399_ui_MoveResultMapIndex = L0715_ui_MapIndexDestination;
                G401_ui_MoveResultCell = M11_CELL(P557_T_Thing);
#ifndef NOCOPYPROTECTION
                if (G022_i_Graphic562_IndirectStopExpiringEvent_COPYPROTECTIONE != C00555_FALSE) {
                        G022_i_Graphic562_IndirectStopExpiringEvent_COPYPROTECTIONE == C00555_FALSE; /* BUG0_00 Useless code */
                        G330_i_StopExpiringEvents_COPYPROTECTIONE++;
                }
#endif
                L0725_B_PartySquare = (L0715_ui_MapIndexDestination == L0714_ui_MapIndexSource) && (P560_i_DestinationMapX == P558_i_SourceMapX) && (P561_i_DestinationMapY == P559_i_SourceMapY);
                if (L0725_B_PartySquare) {
                        if (P557_T_Thing == C0xFFFF_THING_PARTY) {
                                if (G308_i_PartyDirection == L0716_i_Direction) {
                                        return FALSE;
                                }
                        } else {
                                if ((G401_ui_MoveResultCell == L0717_ui_ThingCell) && (L0710_i_ThingType != C14_THING_TYPE_PROJECTILE)) {
                                        return FALSE;
                                }
                        }
                } else {
                        if ((P557_T_Thing == C0xFFFF_THING_PARTY) && G305_ui_PartyChampionCount) {
                                A0727_ui_Backup = A0708_i_DestinationSquare;
                                for(A0708_i_ScentIndex = G407_s_Party.ScentCount; A0708_i_ScentIndex >= 24; A0708_i_ScentIndex--) {
                                        F316_aizz_CHAMPION_DeleteScent(0);
                                }
                                if (A0708_i_ScentIndex) {
                                        F317_adzz_CHAMPION_AddScentStrength(P558_i_SourceMapX, P559_i_SourceMapY, (int)(G313_ul_GameTime - G362_l_LastPartyMovementTime));
                                }
                                G362_l_LastPartyMovementTime = G313_ul_GameTime;
                                G407_s_Party.ScentCount++;
                                if (G407_s_Party.Event79Count_Footprints) {
                                        G407_s_Party.LastScentIndex = G407_s_Party.ScentCount;
                                }
                                G407_s_Party.Scents[A0708_i_ScentIndex].Location.MapX = P560_i_DestinationMapX;
                                G407_s_Party.Scents[A0708_i_ScentIndex].Location.MapY = P561_i_DestinationMapY;
                                G407_s_Party.Scents[A0708_i_ScentIndex].Location.MapIndex = L0715_ui_MapIndexDestination;
                                G407_s_Party.ScentStrengths[A0708_i_ScentIndex] = 0;
                                F317_adzz_CHAMPION_AddScentStrength(P560_i_DestinationMapX, P561_i_DestinationMapY, MASK0x8000_MERGE_CYCLES | 24);
                                A0708_i_DestinationSquare = A0727_ui_Backup;
                        }
                        if (L0715_ui_MapIndexDestination != L0714_ui_MapIndexSource) {
                                F173_gzzz_DUNGEON_SetCurrentMap(L0714_ui_MapIndexSource);
                        }
                }
        }
        if (P558_i_SourceMapX >= 0) {
                if (P557_T_Thing == C0xFFFF_THING_PARTY) {
                        F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(P558_i_SourceMapX, P559_i_SourceMapY, C0xFFFF_THING_PARTY, L0725_B_PartySquare, FALSE);
                } else {
                        if (L0713_B_ThingLevitates) {
                                F164_dzzz_DUNGEON_UnlinkThingFromList(P557_T_Thing, 0, P558_i_SourceMapX, P559_i_SourceMapY);
                        } else {
                                F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(P558_i_SourceMapX, P559_i_SourceMapY, P557_T_Thing, (G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (P558_i_SourceMapX == G306_i_PartyMapX) && (P559_i_SourceMapY == G307_i_PartyMapY), FALSE);
                        }
                }
        }
        if (P560_i_DestinationMapX >= 0) {
                if (P557_T_Thing == C0xFFFF_THING_PARTY) {
                        F173_gzzz_DUNGEON_SetCurrentMap(L0715_ui_MapIndexDestination);
                        if ((P557_T_Thing = F175_gzzz_GROUP_GetThing(G306_i_PartyMapX, G307_i_PartyMapY)) != C0xFFFE_THING_ENDOFLIST) { /* Delete group if party moves onto its square */
                                F188_aozz_GROUP_DropGroupPossessions(G306_i_PartyMapX, G307_i_PartyMapY, P557_T_Thing, C01_MODE_PLAY_IF_PRIORITIZED);
                                F189_awzz_GROUP_Delete(G306_i_PartyMapX, G307_i_PartyMapY);
                        }
                        if (L0715_ui_MapIndexDestination == L0714_ui_MapIndexSource) {
                                F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(G306_i_PartyMapX, G307_i_PartyMapY, C0xFFFF_THING_PARTY, L0725_B_PartySquare, TRUE);
                        } else {
                                F173_gzzz_DUNGEON_SetCurrentMap(L0714_ui_MapIndexSource);
                                G327_i_NewPartyMapIndex = L0715_ui_MapIndexDestination;
                        }
                } else {
                        if (L0710_i_ThingType == C04_THING_TYPE_GROUP) {
                                F173_gzzz_DUNGEON_SetCurrentMap(L0715_ui_MapIndexDestination);
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                L0712_ps_Teleporter = (TELEPORTER*)F156_afzz_DUNGEON_GetThingData(P557_T_Thing);
                                A0708_i_ActiveGroupIndex = ((GROUP*)L0712_ps_Teleporter)->ActiveGroupIndex;
#endif
                                if (((L0715_ui_MapIndexDestination == G309_i_PartyMapIndex) && (P560_i_DestinationMapX == G306_i_PartyMapX) && (P561_i_DestinationMapY == G307_i_PartyMapY)) || (F175_gzzz_GROUP_GetThing(P560_i_DestinationMapX, P561_i_DestinationMapY) != C0xFFFE_THING_ENDOFLIST)) { /* If a group tries to move to the party square or over another group then create an event to move the group later */
                                        F173_gzzz_DUNGEON_SetCurrentMap(L0714_ui_MapIndexSource);
                                        if (P558_i_SourceMapX >= 0) {
                                                F181_czzz_GROUP_DeleteEvents(P558_i_SourceMapX, P559_i_SourceMapY);
                                        }
                                        if (L0721_B_GroupOnPartyMap) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                                F184_ahzz_GROUP_RemoveActiveGroup(((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P557_T_Thing)].ActiveGroupIndex);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                                F184_ahzz_GROUP_RemoveActiveGroup(A0708_i_ActiveGroupIndex);
#endif
                                        }
                                        F265_xxxx_MOVE_CreateEvent60To61_MoveGroup(P557_T_Thing, P560_i_DestinationMapX, P561_i_DestinationMapY, L0715_ui_MapIndexDestination, L0726_B_Audible);
                                        return TRUE; /* The specified group thing cannot be moved because the party or another group is on the destination square */
                                }
                                if (L0721_B_GroupOnPartyMap && (L0715_ui_MapIndexDestination != G309_i_PartyMapIndex)) { /* If the group leaves the party map */
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                        F184_ahzz_GROUP_RemoveActiveGroup(((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P557_T_Thing)].ActiveGroupIndex);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                        F184_ahzz_GROUP_RemoveActiveGroup(A0708_i_ActiveGroupIndex);
#endif
                                        L0720_ui_MoveGroupResult = TRUE;
                                } else {
                                        if ((L0715_ui_MapIndexDestination == G309_i_PartyMapIndex) && (!L0721_B_GroupOnPartyMap)) { /* If the group arrives on the party map */
                                                F183_kzzz_GROUP_AddActiveGroup(P557_T_Thing, P560_i_DestinationMapX, P561_i_DestinationMapY);
                                                L0720_ui_MoveGroupResult = TRUE;
                                        }
                                }
                                if (L0713_B_ThingLevitates) {
                                        F163_amzz_DUNGEON_LinkThingToList(P557_T_Thing, 0, P560_i_DestinationMapX, P561_i_DestinationMapY);
                                } else {
                                        F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(P560_i_DestinationMapX, P561_i_DestinationMapY, P557_T_Thing, FALSE, TRUE);
                                }
                                if (L0720_ui_MoveGroupResult || (P558_i_SourceMapX < 0)) { /* If group moved from one map to another or if it was just placed on a square */
                                        F180_hzzz_GROUP_StartWandering(P560_i_DestinationMapX, P561_i_DestinationMapY);
                                }
                                F173_gzzz_DUNGEON_SetCurrentMap(L0714_ui_MapIndexSource);
                                if (P558_i_SourceMapX >= 0) {
                                        if (L0720_ui_MoveGroupResult > TRUE) { /* If the group behavior was C6_BEHAVIOR_ATTACK before being teleported from and to the party map */
                                                F182_aqzz_GROUP_StopAttacking(&G375_ps_ActiveGroups[L0720_ui_MoveGroupResult - 2], P558_i_SourceMapX, P559_i_SourceMapY);
                                        } else {
                                                if (L0720_ui_MoveGroupResult) { /* If the group was teleported or leaved the party map or entered the party map */
                                                        F181_czzz_GROUP_DeleteEvents(P558_i_SourceMapX, P559_i_SourceMapY);
                                                }
                                        }
                                }
                                return L0720_ui_MoveGroupResult;
                        }
                        F173_gzzz_DUNGEON_SetCurrentMap(L0715_ui_MapIndexDestination);
                        if (L0710_i_ThingType == C14_THING_TYPE_PROJECTILE) { /* BUG0_29 An explosion can trigger a floor sensor. Explosions do not trigger floor sensors on the square where they are created. However, if an explosion is moved by a teleporter (or by falling into a pit, see BUG0_26) after it was created, it can trigger floor sensors on the destination square. This is because explosions are not considered as levitating in the code, while projectiles are. The condition here should be (L0713_B_ThingLevitates) so that explosions would not start sensor processing on their destination square as they should be Levitating. This would work if F264_avzz_MOVE_IsLevitating returned TRUE for explosions (see BUG0_26) */
                                F163_amzz_DUNGEON_LinkThingToList(P557_T_Thing, 0, P560_i_DestinationMapX, P561_i_DestinationMapY);
                        } else {
                                F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(P560_i_DestinationMapX, P561_i_DestinationMapY, P557_T_Thing, (G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (P560_i_DestinationMapX == G306_i_PartyMapX) && (P561_i_DestinationMapY == G307_i_PartyMapY), TRUE);
                        }
                        F173_gzzz_DUNGEON_SetCurrentMap(L0714_ui_MapIndexSource);
                }
        }
}
