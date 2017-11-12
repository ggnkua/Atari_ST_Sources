#include "DEFS.H"

/*_Global variables_*/
int G233_ai_Graphic559_DirectionToStepEastCount[4];
int G234_ai_Graphic559_DirectionToStepNorthCount[4];
unsigned char G235_auc_Graphic559_ThingDataByteCount[16];
unsigned char G236_auc_Graphic559_AdditionalThingCounts[16];
OBJECT_INFO G237_as_Graphic559_ObjectInfo[180];
WEAPON_INFO G238_as_Graphic559_WeaponInfo[46];
ARMOUR_INFO G239_as_Graphic559_ArmourInfo[58];
int G240_i_Graphic559_State_COPYPROTECTIOND; /* This variable is necessary even if NOCOPYPROTECTION is defined because a value is loaded for it from graphic #559 */
char G241_ac_Graphic559_JunkInfo[53];
int G242_ai_Graphic559_FoodAmounts[8];
CREATURE_INFO G243_as_Graphic559_CreatureInfo[C027_CREATURE_TYPE_COUNT];
unsigned char G244_auc_Graphic559_CreatureAttackSounds[8];
unsigned int G245_aui_Graphic559_FixedPossessionsCreature12Skeleton[3];
unsigned int G246_aui_Graphic559_FixedPossessionsCreature09StoneGolem[2];
unsigned int G247_aui_Graphic559_FixedPossessionsCreature16Trolin_Antman[2];
unsigned int G248_aui_Graphic559_FixedPossessionsCreature18AnimatedArmour_DethKnight[7];
unsigned int G249_aui_Graphic559_FixedPossessionsCreature07Rock_RockPile[5];
unsigned int G250_aui_Graphic559_FixedPossessionsCreature04PainRat_Hellhound[3];
unsigned int G251_aui_Graphic559_FixedPossessionsCreature06Screamer[3];
unsigned int G252_aui_Graphic559_FixedPossessionsCreature15MagentaWorm_Worm[4];
unsigned int G253_aui_Graphic559_FixedPossessionsCreature24RedDragon[11];
DOOR_INFO G254_as_Graphic559_DoorInfo[4];
char G255_aac_Graphic559_MessageAndScrollEscapeReplacementStrings[32][8];
char G256_aac_Graphic559_EscapeReplacementCharacters[32][2];
char G257_aac_Graphic559_InscriptionEscapeReplacementStrings[32][8];
unsigned char G258_auc_Graphic559_GroupDirections[4];
int G259_i_Graphic559Anchor;
unsigned int* G260_pui_DungeonTextData;
unsigned char G261_auc_CurrentMapWallOrnamentIndices[15];
unsigned char G262_auc_CurrentMapFloorOrnamentIndices[15];
unsigned char G263_auc_CurrentMapDoorOrnamentIndices[17];
unsigned char* G264_puc_CurrentMapAllowedCreatureTypes;
int G265_i_CurrentMapInscriptionWallOrnamentIndex;
int G266_i_CurrentMapViAltarWallOrnamentIndex;
int G267_ai_CurrentMapAlcoveOrnamentIndices[C003_ALCOVE_ORNAMENT_COUNT];
int G268_ai_CurrentMapFountainOrnamentIndices[C001_FOUNTAIN_ORNAMENT_COUNT];
MAP* G269_ps_CurrentMap;
unsigned int* G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount; /* Pointer to value in G280_pui_DungeonColumnsCumulativeSquareThingCount for the first column of the current map */
unsigned char** G271_ppuc_CurrentMapData;
int G272_i_CurrentMapIndex = CM1_MAP_INDEX_NONE;
int G273_i_CurrentMapWidth;
int G274_i_CurrentMapHeight;
DOOR_INFO G275_as_CurrentMapDoorInfo[2];
unsigned char* G276_puc_DungeonRawMapData;
MAP* G277_ps_DungeonMaps;
DUNGEON_HEADER* G278_ps_DungeonHeader;
unsigned char*** G279_pppuc_DungeonMapData;
unsigned int* G280_pui_DungeonColumnsCumulativeSquareThingCount; /* For each column of each map in the dungeon, cumulative count of things in G283_pT_SquareFirstThings present in preceding columns */
int* G281_pi_DungeonMapsFirstColumnIndex;
unsigned int G282_ui_DungeonColumnCount;
THING* G283_pT_SquareFirstThings;
unsigned char* G284_apuc_ThingData[16];


overlay "dunman"

BOOLEAN F139_aqzz_DUNGEON_IsCreatureAllowedOnMap(P234_T_Thing, P235_ui_MapIndex)
THING P234_T_Thing;
unsigned int P235_ui_MapIndex;
{
        register int L0234_i_Counter;
        register int L0235_i_CreatureType;
        register unsigned char* L0236_puc_Multiple;
#define A0236_puc_Group               L0236_puc_Multiple
#define A0236_puc_AllowedCreatureType L0236_puc_Multiple
        register MAP* L0237_ps_Map;


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0235_i_CreatureType = ((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P234_T_Thing)].Type;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        A0236_puc_Group = F156_afzz_DUNGEON_GetThingData(P234_T_Thing);
        L0235_i_CreatureType = ((GROUP*)A0236_puc_Group)->Type;
#endif
        L0237_ps_Map = &G277_ps_DungeonMaps[P235_ui_MapIndex];
        A0236_puc_AllowedCreatureType = G279_pppuc_DungeonMapData[P235_ui_MapIndex][L0237_ps_Map->A.Width] + L0237_ps_Map->A.Height + 1;
        for(L0234_i_Counter = L0237_ps_Map->C.CreatureTypeCount; L0234_i_Counter > 0; L0234_i_Counter--) {
                if (*A0236_puc_AllowedCreatureType++ == L0235_i_CreatureType) {
                        return TRUE;
                }
        }
        return FALSE;
}

unsigned int F140_yzzz_DUNGEON_GetObjectWeight(P236_T_Thing)
register THING P236_T_Thing;
{
        register JUNK* L0238_ps_Junk;
        register unsigned int L0239_ui_Weight;


        if (P236_T_Thing == C0xFFFF_THING_NONE) {
                return 0;
        }
        L0238_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(P236_T_Thing);
        switch M12_TYPE(P236_T_Thing) {
                case C05_THING_TYPE_WEAPON:
                        L0239_ui_Weight = G238_as_Graphic559_WeaponInfo[((WEAPON*)L0238_ps_Junk)->Type].Weight;
                        break;
                case C06_THING_TYPE_ARMOUR:
                        L0239_ui_Weight = G239_as_Graphic559_ArmourInfo[((ARMOUR*)L0238_ps_Junk)->Type].Weight;
                        break;
                case C10_THING_TYPE_JUNK:
                        L0239_ui_Weight = G241_ac_Graphic559_JunkInfo[L0238_ps_Junk->Type];
                        if (L0238_ps_Junk->Type == C01_JUNK_WATERSKIN) {
                               L0239_ui_Weight += L0238_ps_Junk->ChargeCount << 1;
                        }
                        break;
                case C09_THING_TYPE_CONTAINER:
                        L0239_ui_Weight = 50;
                        for(P236_T_Thing = ((CONTAINER*)L0238_ps_Junk)->Slot; P236_T_Thing != C0xFFFE_THING_ENDOFLIST; P236_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P236_T_Thing)) {
                                L0239_ui_Weight += F140_yzzz_DUNGEON_GetObjectWeight(P236_T_Thing);
                        }
                        break;
                case C08_THING_TYPE_POTION:
                        if (((POTION*)L0238_ps_Junk)->Type == C20_POTION_EMPTY_FLASK) {
                                L0239_ui_Weight = 1;
                        } else {
                                L0239_ui_Weight = 3;
                        }
                        break;
                case C07_THING_TYPE_SCROLL:
                        L0239_ui_Weight = 1;
        }
        return L0239_ui_Weight;
}

int F141_anzz_DUNGEON_GetObjectInfoIndex(P237_T_Thing)
THING P237_T_Thing;
{
        register GENERIC* L0240_ps_Generic;


        L0240_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(P237_T_Thing);
        switch M12_TYPE(P237_T_Thing) {
                case C07_THING_TYPE_SCROLL:
                        return C000_OBJECT_INFO_INDEX_FIRST_SCROLL;
                case C09_THING_TYPE_CONTAINER:
                        return C001_OBJECT_INFO_INDEX_FIRST_CONTAINER + ((CONTAINER*)L0240_ps_Generic)->Type;
                case C10_THING_TYPE_JUNK:
                        return C127_OBJECT_INFO_INDEX_FIRST_JUNK + ((JUNK*)L0240_ps_Generic)->Type;
                case C05_THING_TYPE_WEAPON:
                        return C023_OBJECT_INFO_INDEX_FIRST_WEAPON + ((WEAPON*)L0240_ps_Generic)->Type;
                case C06_THING_TYPE_ARMOUR:
                        return C069_OBJECT_INFO_INDEX_FIRST_ARMOUR + ((ARMOUR*)L0240_ps_Generic)->Type;
                case C08_THING_TYPE_POTION:
                        return C002_OBJECT_INFO_INDEX_FIRST_POTION + ((POTION*)L0240_ps_Generic)->Type;
                default:
                        return -1;
        }
}

/* Returns a negative value (PROJECTIL_ASPECT ordinal) or positive value (OBJECT_ASPECT index) */
int F142_aqzz_DUNGEON_GetProjectileAspect(P238_T_Thing)
register THING P238_T_Thing;
{
        register int L0241_i_ThingType;
        register int L0242_i_ProjectileAspectOrdinal;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        register WEAPON_INFO* L0243_ps_WeaponInfo;
#endif


        if ((L0241_i_ThingType = M12_TYPE(P238_T_Thing)) == C15_THING_TYPE_EXPLOSION) {
                if (P238_T_Thing == C0xFF80_THING_EXPLOSION_FIREBALL) {
                        return -M00_INDEX_TO_ORDINAL(C10_PROJECTILE_ASPECT_EXPLOSION_FIREBALL);
                }
                if (P238_T_Thing == C0xFF81_THING_EXPLOSION_SLIME) {
                        return -M00_INDEX_TO_ORDINAL(C12_PROJECTILE_ASPECT_EXPLOSION_SLIME);
                }
                if (P238_T_Thing == C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT) {
                        return -M00_INDEX_TO_ORDINAL(C03_PROJECTILE_ASPECT_EXPLOSION_LIGHTNING_BOLT);
                }
                if ((P238_T_Thing == C0xFF86_THING_EXPLOSION_POISON_BOLT) || (P238_T_Thing == C0xFF87_THING_EXPLOSION_POISON_CLOUD)) {
                        return -M00_INDEX_TO_ORDINAL(C13_PROJECTILE_ASPECT_EXPLOSION_POISON_BOLT_POISON_CLOUD);
                }
                return -M00_INDEX_TO_ORDINAL(C11_PROJECTILE_ASPECT_EXPLOSION_DEFAULT);
        } else {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                if ((L0241_i_ThingType == C05_THING_TYPE_WEAPON) && (L0242_i_ProjectileAspectOrdinal = M66_PROJECTILE_ASPECT_ORDINAL(G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(P238_T_Thing)].Type].Attributes))) {
                        return -L0242_i_ProjectileAspectOrdinal;
                }
                return G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(P238_T_Thing)].ObjectAspectIndex;
        }
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                if (L0241_i_ThingType == C05_THING_TYPE_WEAPON) {
                        L0243_ps_WeaponInfo = F158_ayzz_DUNGEON_GetWeaponInfo(P238_T_Thing);
                        if (L0242_i_ProjectileAspectOrdinal = M66_PROJECTILE_ASPECT_ORDINAL(L0243_ps_WeaponInfo->Attributes)) {
                                return -L0242_i_ProjectileAspectOrdinal;
                        }
                }
        }
        return G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(P238_T_Thing)].ObjectAspectIndex;
#endif
}

unsigned int F143_mzzz_DUNGEON_GetArmourDefense(P239_ps_ArmourInfo, P240_B_UseSharpDefense)
register ARMOUR_INFO* P239_ps_ArmourInfo;
BOOLEAN P240_B_UseSharpDefense;
{
        register unsigned int L0244_ui_Defense;


        L0244_ui_Defense = P239_ps_ArmourInfo->Defense;
        if (P240_B_UseSharpDefense) {
                L0244_ui_Defense = F030_aaaW_MAIN_GetScaledProduct(L0244_ui_Defense, 3, M07_GET(P239_ps_ArmourInfo->Attributes, MASK0x0007_SHARP_DEFENSE) + 4);
        }
        return L0244_ui_Defense;
}

unsigned int F144_amzz_DUNGEON_GetCreatureAttributes(P241_T_Thing)
THING P241_T_Thing;
{
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        return G243_as_Graphic559_CreatureInfo[((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(P241_T_Thing)].Type].Attributes;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        GROUP* L0245_ps_Group;


        L0245_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(P241_T_Thing);
        return G243_as_Graphic559_CreatureInfo[L0245_ps_Group->Type].Attributes;
#endif
}

unsigned int F145_rzzz_DUNGEON_GetGroupCells(P242_ps_Group, P243_ui_MapIndex)
GROUP* P242_ps_Group;
unsigned int P243_ui_MapIndex;
{
        register unsigned char L0246_uc_Cells;


        L0246_uc_Cells = P242_ps_Group->Cells;
        if (P243_ui_MapIndex == G309_i_PartyMapIndex) {
                L0246_uc_Cells = G375_ps_ActiveGroups[L0246_uc_Cells].Cells;
        }
        return L0246_uc_Cells;
}

VOID F146_aczz_DUNGEON_SetGroupCells(P244_ps_Group, P245_ui_Cells, P246_ui_MapIndex)
GROUP* P244_ps_Group;
unsigned int P245_ui_Cells;
unsigned int P246_ui_MapIndex;
{
        if (P246_ui_MapIndex == G309_i_PartyMapIndex) {
                G375_ps_ActiveGroups[P244_ps_Group->ActiveGroupIndex].Cells = P245_ui_Cells;
        } else {
                P244_ps_Group->Cells = P245_ui_Cells;
        }
}

unsigned int F147_aawz_DUNGEON_GetGroupDirections(P247_ps_Group, P248_ui_MapIndex)
GROUP* P247_ps_Group;
unsigned int P248_ui_MapIndex;
{
        if (P248_ui_MapIndex == G309_i_PartyMapIndex) {
                return G375_ps_ActiveGroups[P247_ps_Group->ActiveGroupIndex].Directions;
        }
        return G258_auc_Graphic559_GroupDirections[P247_ps_Group->Direction];
}

VOID F148_aayz_DUNGEON_SetGroupDirections(P249_ps_Group, P250_ui_Directions, P251_ui_MapIndex)
GROUP* P249_ps_Group;
unsigned int P250_ui_Directions;
unsigned int P251_ui_MapIndex;
{
        if (P251_ui_MapIndex == G309_i_PartyMapIndex) {
                G375_ps_ActiveGroups[P249_ps_Group->ActiveGroupIndex].Directions = P250_ui_Directions;
        } else {
                P249_ps_Group->Direction = M21_NORMALIZE(P250_ui_Directions);
        }
}

BOOLEAN F149_aawz_DUNGEON_IsWallOrnamentAnAlcove(P252_i_WallOrnamentIndex)
int P252_i_WallOrnamentIndex;
{
        register int L0247_i_Counter;


        if (P252_i_WallOrnamentIndex >= 0) {
                for(L0247_i_Counter = 0; L0247_i_Counter < C003_ALCOVE_ORNAMENT_COUNT; L0247_i_Counter++) {
                        if (G267_ai_CurrentMapAlcoveOrnamentIndices[L0247_i_Counter] == P252_i_WallOrnamentIndex) {
                                return TRUE;
                        }
                }
        }
        return FALSE;
}

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
VOID F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P253_i_Direction, P254_i_StepsForwardCount, P255_i_StepsRightCount, P256_pi_MapX, P257_pi_MapY)
register int P253_i_Direction;
register int P254_i_StepsForwardCount;
register int P255_i_StepsRightCount;
register int* P256_pi_MapX;
register int* P257_pi_MapY;
{
        *P256_pi_MapX += G233_ai_Graphic559_DirectionToStepEastCount[P253_i_Direction] * P254_i_StepsForwardCount, *P257_pi_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[P253_i_Direction] * P254_i_StepsForwardCount;
        P253_i_Direction = P253_i_Direction + 1;
        P253_i_Direction = M21_NORMALIZE(P253_i_Direction); /* Simulate turning right */
        *P256_pi_MapX += G233_ai_Graphic559_DirectionToStepEastCount[P253_i_Direction] * P255_i_StepsRightCount, *P257_pi_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[P253_i_Direction] * P255_i_StepsRightCount;
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
VOID F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P253_i_Direction, P254_i_StepsForwardCount, P255_i_StepsRightCount, P256_pi_MapX, P257_pi_MapY)
int P253_i_Direction;
int P254_i_StepsForwardCount;
int P255_i_StepsRightCount;
register int* P256_pi_MapX;
register int* P257_pi_MapY;
{
        asm {
                lea     G233_ai_Graphic559_DirectionToStepEastCount(A4),A0
                lea     G234_ai_Graphic559_DirectionToStepNorthCount(A4),A1
                move.w  P253_i_Direction(A6),D0
                add.w   D0,D0
                move.w  P254_i_StepsForwardCount(A6),D1
                move.w  D1,D2
                muls    0(A0,D0.w),D1
                add.w   D1,(P256_pi_MapX)               /* Update P256_pi_MapX with G233_ai_Graphic559_DirectionToStepEastCount value associated to P254_i_StepsForwardCount */
                muls    0(A1,D0.w),D2
                add.w   D2,(P257_pi_MapY)               /* Update P257_pi_MapY with G234_ai_Graphic559_DirectionToStepNorthCount value associated to P254_i_StepsForwardCount */
                addq.w  #2,D0                           /* Simulate turning right */
                andi.w  #7,D0
                move.w  P255_i_StepsRightCount(A6),D1
                move.w  D1,D2
                muls    0(A0,D0.w),D1
                add.w   D1,(P256_pi_MapX)               /* Update P256_pi_MapX with G233_ai_Graphic559_DirectionToStepEastCount value associated to P255_i_StepsRightCount */
                muls    0(A1,D0.w),D2
                add.w   D2,(P257_pi_MapY)               /* Update P257_pi_MapY with G234_ai_Graphic559_DirectionToStepNorthCount value associated to P255_i_StepsRightCount */
        }
}
#endif

unsigned char F151_rzzz_DUNGEON_GetSquare(P258_i_MapX, P259_i_MapY)
register int P258_i_MapX;
register int P259_i_MapY;
{
        register int L0248_i_Multiple;
#define A0248_B_IsMapXInBounds L0248_i_Multiple
#define A0248_i_SquareType     L0248_i_Multiple
        register int L0249_i_Multiple;
#define A0249_B_IsMapYInBounds L0249_i_Multiple
#define A0249_i_SquareType     L0249_i_Multiple


        A0249_B_IsMapYInBounds = (P259_i_MapY >= 0) && (P259_i_MapY < G274_i_CurrentMapHeight);
        if ((A0248_B_IsMapXInBounds = (P258_i_MapX >= 0) && (P258_i_MapX < G273_i_CurrentMapWidth)) && A0249_B_IsMapYInBounds) {
                return G271_ppuc_CurrentMapData[P258_i_MapX][P259_i_MapY];
        }
        /* If processing goes below this line then either P258_i_MapX or P259_i_MapY is out of the map bounds and the returned square type will be C00_ELEMENT_WALL. The use of uninitialized variables in conditions does not have any visible consequence */
        if (A0249_B_IsMapYInBounds) {
                if (((P258_i_MapX == -1) && ((A0249_i_SquareType = M34_SQUARE_TYPE(G271_ppuc_CurrentMapData[0][P259_i_MapY])) == C01_ELEMENT_CORRIDOR)) || (A0249_i_SquareType == C02_ELEMENT_PIT)) { /* BUG0_01 Use of uninitialized variable A0249_i_SquareType in comparison (A0249_i_SquareType == C02_ELEMENT_PIT) if P258_i_MapX != -1. No consequence here as A0249_i_SquareType = A0249_B_IsMapYInBounds = 0 (FALSE) or 1 (TRUE) and thus cannot be equal to 2 (C02_ELEMENT_PIT) */
                        return M35_SQUARE(C00_ELEMENT_WALL, MASK0x0004_WALL_EAST_RANDOM_ORNAMENT_ALLOWED);
                }
                if (((P258_i_MapX == G273_i_CurrentMapWidth) && ((A0249_i_SquareType = M34_SQUARE_TYPE(G271_ppuc_CurrentMapData[G273_i_CurrentMapWidth - 1][P259_i_MapY])) == C01_ELEMENT_CORRIDOR)) || (A0249_i_SquareType == C02_ELEMENT_PIT)) { /* BUG0_01 Use of uninitialized variable A0249_i_SquareType in comparison (A0249_i_SquareType == C02_ELEMENT_PIT) if P258_i_MapX != G273_i_CurrentMapWidth. If P258_i_MapX == -1 then A0249_i_SquareType contains the square type from the previous test: no consequence here as A0249_i_SquareType cannot be equal to 2 (C02_ELEMENT_PIT) otherwise the previous test would have succeeded and the function would have returned. If P258_i_MapX != -1 then A0249_i_SquareType = A0249_B_IsMapYInBounds = 0 (FALSE) or 1 (TRUE): no consequence as it cannot be equal to 2 (C02_ELEMENT_PIT) */
                        return M35_SQUARE(C00_ELEMENT_WALL, MASK0x0001_WALL_WEST_RANDOM_ORNAMENT_ALLOWED);
                }
        } else {
                if (A0248_B_IsMapXInBounds) {
                        if (((P259_i_MapY == -1) && ((A0248_i_SquareType = M34_SQUARE_TYPE(G271_ppuc_CurrentMapData[P258_i_MapX][0])) == C01_ELEMENT_CORRIDOR)) || (A0248_i_SquareType == C02_ELEMENT_PIT)) { /* BUG0_01 Use of uninitialized variable A0248_i_SquareType in comparison (A0248_i_SquareType == C02_ELEMENT_PIT) if P259_i_MapY != -1. If the value of register D5 (storing A0248_i_SquareType) is 2 before the function call then the condition is true and if P259_i_MapY == G274_i_CurrentMapHeight then this can prevent a wall on the south border of the map to allow a random ornament on its north side. No consequence as the only case where this would have a consequence is in F172_awzz_DUNGEON_SetSquareAspect where register D5 contains the same value as P259_i_MapY so it is not possible to have both A0248_i_SquareType == 2 and P259_i_MapY == G274_i_CurrentMapHeight */
                                return M35_SQUARE(C00_ELEMENT_WALL, MASK0x0002_WALL_SOUTH_RANDOM_ORNAMENT_ALLOWED);
                        }
                        if (((P259_i_MapY == G274_i_CurrentMapHeight) && ((A0248_i_SquareType = M34_SQUARE_TYPE(G271_ppuc_CurrentMapData[P258_i_MapX][G274_i_CurrentMapHeight - 1])) == C01_ELEMENT_CORRIDOR)) || (A0248_i_SquareType == C02_ELEMENT_PIT)) { /* BUG0_01 Use of uninitialized variable A0248_i_SquareType in comparison (A0248_i_SquareType == C02_ELEMENT_PIT) if P259_i_MapY != G274_i_CurrentMapHeight. If P259_i_MapY == -1 then A0248_i_SquareType contains the square type from the previous test: no consequence here as A0248_i_SquareType cannot be equal to 2 (C02_ELEMENT_PIT) otherwise the previous test would have succeeded and the function would have returned. If P259_i_MapY != -1 then A0248_i_SquareType contains the value of D5 before the function call which cannot be 2 (see previous condition) */
                                return M35_SQUARE(C00_ELEMENT_WALL, MASK0x0008_WALL_NORTH_RANDOM_ORNAMENT_ALLOWED);
                        }
                }
        }
        return M35_SQUARE(C00_ELEMENT_WALL, 0);
}

unsigned char F152_xxxx_DUNGEON_GetRelativeSquare(P260_i_Direction, P261_i_StepsForwardCount, P262_i_StepsRightCount, P263_i_MapX, P264_i_MapY)
int P260_i_Direction;
int P261_i_StepsForwardCount;
int P262_i_StepsRightCount;
int P263_i_MapX;
int P264_i_MapY;
{
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P260_i_Direction, P261_i_StepsForwardCount, P262_i_StepsRightCount, &P263_i_MapX, &P264_i_MapY);
        return F151_rzzz_DUNGEON_GetSquare(P263_i_MapX, P264_i_MapY);
}

int F153_yzzz_DUNGEON_GetRelativeSquareType(P265_i_Direction, P266_i_StepsForwardCount, P267_i_StepsRightCount, P268_i_MapX, P269_i_MapY)
int P265_i_Direction;
int P266_i_StepsForwardCount;
int P267_i_StepsRightCount;
int P268_i_MapX;
int P269_i_MapY;
{
        return M34_SQUARE_TYPE(F152_xxxx_DUNGEON_GetRelativeSquare(P265_i_Direction, P266_i_StepsForwardCount, P267_i_StepsRightCount, P268_i_MapX, P269_i_MapY));
}

int F154_afzz_DUNGEON_GetLocationAfterLevelChange(P270_i_MapIndex, P271_i_LevelDelta, P272_pi_MapX, P273_pi_MapY)
int P270_i_MapIndex;
int P271_i_LevelDelta;
int* P272_pi_MapX;
int* P273_pi_MapY;
{
        register int L0250_i_NewMapX;
        register int L0251_i_NewMapY;
        register int L0252_i_NewLevel;
        register int L0253_i_Offset;
        register MAP* L0254_ps_Map;
        int L0255_i_TargetMapIndex;


        if (G309_i_PartyMapIndex == C255_MAP_INDEX_ENTRANCE) {
                return CM1_MAP_INDEX_NONE;
        }
        L0254_ps_Map = G277_ps_DungeonMaps + P270_i_MapIndex;
        L0250_i_NewMapX = L0254_ps_Map->OffsetMapX + *P272_pi_MapX;
        L0251_i_NewMapY = L0254_ps_Map->OffsetMapY + *P273_pi_MapY;
        L0252_i_NewLevel = L0254_ps_Map->A.Level + P271_i_LevelDelta;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
        L0255_i_TargetMapIndex = 0, L0254_ps_Map = G277_ps_DungeonMaps;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
        L0254_ps_Map = G277_ps_DungeonMaps;
        L0255_i_TargetMapIndex = 0;
#endif
        while (L0255_i_TargetMapIndex < G278_ps_DungeonHeader->MapCount) {
                if ((L0254_ps_Map->A.Level == L0252_i_NewLevel) && (L0250_i_NewMapX >= (L0253_i_Offset = L0254_ps_Map->OffsetMapX)) && (L0250_i_NewMapX <= (L0253_i_Offset + L0254_ps_Map->A.Width)) && (L0251_i_NewMapY >= (L0253_i_Offset = L0254_ps_Map->OffsetMapY)) && (L0251_i_NewMapY <= (L0253_i_Offset + L0254_ps_Map->A.Height))) {
                        *P273_pi_MapY = L0251_i_NewMapY - L0253_i_Offset;
                        *P272_pi_MapX = L0250_i_NewMapX - L0254_ps_Map->OffsetMapX;
                        return L0255_i_TargetMapIndex;
                }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                L0255_i_TargetMapIndex++, L0254_ps_Map++;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                L0254_ps_Map++;
                L0255_i_TargetMapIndex++;
#endif
        }
        return CM1_MAP_INDEX_NONE;
}

int F155_ahzz_DUNGEON_GetStairsExitDirection(P274_i_MapX, P275_i_MapY)
register int P274_i_MapX;
register int P275_i_MapY;
{
        register int L0256_i_SquareType;
        register BOOLEAN L0257_B_NorthSouthOrientedStairs;


        if (L0257_B_NorthSouthOrientedStairs = !M07_GET(F151_rzzz_DUNGEON_GetSquare(P274_i_MapX, P275_i_MapY), MASK0x0008_STAIRS_NORTH_SOUTH_ORIENTATION)) {
                P274_i_MapX = P274_i_MapX + G233_ai_Graphic559_DirectionToStepEastCount[C1_DIRECTION_EAST];
                P275_i_MapY = P275_i_MapY + G234_ai_Graphic559_DirectionToStepNorthCount[C1_DIRECTION_EAST];
        } else {
                P274_i_MapX = P274_i_MapX + G233_ai_Graphic559_DirectionToStepEastCount[C0_DIRECTION_NORTH];
                P275_i_MapY = P275_i_MapY + G234_ai_Graphic559_DirectionToStepNorthCount[C0_DIRECTION_NORTH];
        }
        return ((((L0256_i_SquareType = M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(P274_i_MapX, P275_i_MapY))) == C00_ELEMENT_WALL) || (L0256_i_SquareType == C03_ELEMENT_STAIRS)) << 1) + L0257_B_NorthSouthOrientedStairs;
}

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
unsigned char* F156_afzz_DUNGEON_GetThingData(P276_T_Thing)
register THING P276_T_Thing;
{
        return G284_apuc_ThingData[M12_TYPE(P276_T_Thing)] + (M13_INDEX(P276_T_Thing) * G235_auc_Graphic559_ThingDataByteCount[M12_TYPE(P276_T_Thing)]);
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
unsigned char* F156_afzz_DUNGEON_GetThingData(P276_T_Thing)
THING P276_T_Thing;
{
        asm {
                move.w  P276_T_Thing(A6),D3
                move.w  D3,D2
                andi.w  #0x03FF,D3                              /* Thing index */
                lsr.w   #2,D2
                lsr.w   #8,D2
                andi.w  #0x000F,D2                              /* Thing category */
                lea     G235_auc_Graphic559_ThingDataByteCount(A4),A0
                moveq   #0,D0
                move.b  0(A0,D2.w),D0                           /* Thing data byte count */
                mulu.w  D3,D0
                lea     G284_apuc_ThingData(A4),A0
                asl.w   #2,D2
                add.l   0(A0,D2.w),D0                           /* Address of thing data */
        }
}
#endif

#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
unsigned char* F157_rzzz_DUNGEON_GetSquareFirstThingData(P277_i_MapX, P278_i_MapY)
int P277_i_MapX;
int P278_i_MapY;
{
        return F156_afzz_DUNGEON_GetThingData(F161_szzz_DUNGEON_GetSquareFirstThing(P277_i_MapX, P278_i_MapY));
}

WEAPON_INFO* F158_ayzz_DUNGEON_GetWeaponInfo(P279_T_Thing)
THING P279_T_Thing;
{
        WEAPON* L0258_ps_Weapon;


        L0258_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(P279_T_Thing);
        return &G238_as_Graphic559_WeaponInfo[L0258_ps_Weapon->Type];
}
#endif

THING F159_rzzz_DUNGEON_GetNextThing(P280_T_Thing)
THING P280_T_Thing;
{
        GENERIC* L0259_ps_Generic;


        L0259_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(P280_T_Thing);
        return L0259_ps_Generic->Next;
}

int F160_xxxx_DUNGEON_GetSquareFirstThingIndex(P281_i_MapX, P282_i_MapY)
register int P281_i_MapX;
register int P282_i_MapY;
{
        register unsigned int L0260_ui_ThingIndex;
        register int L0261_i_MapY;
        register unsigned char* L0262_puc_Square;


        L0262_puc_Square = G271_ppuc_CurrentMapData[P281_i_MapX];
        if ((P281_i_MapX < 0) || (P281_i_MapX >= G273_i_CurrentMapWidth) || (P282_i_MapY < 0) || (P282_i_MapY >= G274_i_CurrentMapHeight) || !M07_GET(L0262_puc_Square[P282_i_MapY], MASK0x0010_THING_LIST_PRESENT)) {
                return -1;
        }
        L0261_i_MapY = 0;
        L0260_ui_ThingIndex = G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount[P281_i_MapX];
        while (L0261_i_MapY++ != P282_i_MapY) {
                if (M07_GET(*L0262_puc_Square++, MASK0x0010_THING_LIST_PRESENT)) {
                        L0260_ui_ThingIndex++;
                }
        }
        return L0260_ui_ThingIndex;
}

THING F161_szzz_DUNGEON_GetSquareFirstThing(P283_i_MapX, P284_i_MapY)
int P283_i_MapX;
int P284_i_MapY;
{
        int L0263_i_SquareFirstThingIndex;


        if ((L0263_i_SquareFirstThingIndex = F160_xxxx_DUNGEON_GetSquareFirstThingIndex(P283_i_MapX, P284_i_MapY)) == -1) {
                return C0xFFFE_THING_ENDOFLIST;
        }
        return G283_pT_SquareFirstThings[L0263_i_SquareFirstThingIndex];
}

THING F162_afzz_DUNGEON_GetSquareFirstObject(P285_i_MapX, P286_i_MapY)
int P285_i_MapX;
int P286_i_MapY;
{
        register THING L0264_T_Thing;


        L0264_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P285_i_MapX, P286_i_MapY);
        while ((L0264_T_Thing != C0xFFFE_THING_ENDOFLIST) && (M12_TYPE(L0264_T_Thing) < C04_THING_TYPE_GROUP)) {
                L0264_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0264_T_Thing);
        }
        return L0264_T_Thing;
}

VOID F163_amzz_DUNGEON_LinkThingToList(P287_T_ThingToLink, P288_T_ThingInList, P289_i_MapX, P290_i_MapY)
THING P287_T_ThingToLink; /* This thing is linked at the end of the thing list and is made the last thing (It is not possible to link a list of things to another list) */
THING P288_T_ThingInList; /* Any thing currently in the list. The function searches for the last thing in the list before linking the new thing */
register int P289_i_MapX;
register int P290_i_MapY;
{
        register THING L0265_T_Thing;
        register int L0266_i_Multiple;
#define A0266_i_Column                L0266_i_Multiple
#define A0266_i_SquareFirstThingIndex L0266_i_Multiple
        register THING* L0267_pT_Thing;
        register unsigned char* L0268_puc_Square;
        GENERIC* L0269_ps_Generic;
        unsigned int L0270_ui_MapY;


        if (P287_T_ThingToLink == C0xFFFE_THING_ENDOFLIST) {
                return;
        }
        L0269_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(P287_T_ThingToLink);
        L0269_ps_Generic->Next = C0xFFFE_THING_ENDOFLIST;
        /* If P289_i_MapX >= 0 then the thing is linked to the list of things on the specified square else it is linked at the end of the specified thing list */
        if (P289_i_MapX >= 0) {
                L0268_puc_Square = &G271_ppuc_CurrentMapData[P289_i_MapX][P290_i_MapY];
                if (M07_GET(*L0268_puc_Square, MASK0x0010_THING_LIST_PRESENT)) {
                        P288_T_ThingInList = F161_szzz_DUNGEON_GetSquareFirstThing(P289_i_MapX, P290_i_MapY);
                } else {
                        M08_SET(*L0268_puc_Square, MASK0x0010_THING_LIST_PRESENT);
                        L0267_pT_Thing = G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount + P289_i_MapX + 1;
                        A0266_i_Column = G282_ui_DungeonColumnCount - (G281_pi_DungeonMapsFirstColumnIndex[G272_i_CurrentMapIndex] + P289_i_MapX) - 1;
                        while (A0266_i_Column--) { /* For each column starting from and after the column containing the square where the thing is added */
                                (*L0267_pT_Thing++)++; /* Increment the cumulative first thing count */
                        }
                        L0270_ui_MapY = 0;
                        L0268_puc_Square -= P290_i_MapY;
                        A0266_i_SquareFirstThingIndex = G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount[P289_i_MapX];
                        while (L0270_ui_MapY++ != P290_i_MapY) {
                                if (M07_GET(*L0268_puc_Square++, MASK0x0010_THING_LIST_PRESENT)) {
                                        A0266_i_SquareFirstThingIndex++;
                                }
                        }
                        L0267_pT_Thing = &G283_pT_SquareFirstThings[A0266_i_SquareFirstThingIndex]; /* BUG0_08 Objects disappear in the dungeon and data is corrupted in memory. The game manages an array of limited size containing the first thing on each square where there is at least one thing. There is no check to stop adding things to this array when it is full and this causes data corruptions in memory. With the original Dungeon Master and Chaos Strikes back dungeons the array is large enough so that most players will not get into trouble, however it is still possible to fill it by placing one thing on as many squares as possible in the dungeon. The number of free slots to store first square things is 676 in DM for Atari ST 1.0a EN, 678 in DM for Atari ST 1.0b EN, 679 in DM for Atari ST 1.1 EN, 1.2 EN, 1.2 GE, 1.3a FR and 1.3b FR, 690 in CSB for Atari ST 2.0 EN and 2.1 EN (each dungeon contains a number of free slots and the game adds 300 more when loading the dungeon).
                        If all THING entries in G283_pT_SquareFirstThings are already used then inserting an additional one will overwrite the word of data in memory that follows the buffer allocated for G283_pT_SquareFirstThings. If inserting a THING at the end of a full G283_pT_SquareFirstThings then A0266_i_SquareFirstThingIndex is out of bounds and the next call will corrupt memory because the specified size will be negative (= large high positive value) */
                        F007_aAA7_MAIN_CopyBytes(L0267_pT_Thing, L0267_pT_Thing + 1, (G278_ps_DungeonHeader->SquareFirstThingCount - A0266_i_SquareFirstThingIndex - 1) << 1);
                        *L0267_pT_Thing = P287_T_ThingToLink;
                        return;
                }
        }
        for(L0265_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P288_T_ThingInList); L0265_T_Thing != C0xFFFE_THING_ENDOFLIST; L0265_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P288_T_ThingInList = L0265_T_Thing));
        L0269_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(P288_T_ThingInList);
        L0269_ps_Generic->Next = P287_T_ThingToLink;
}

VOID F164_dzzz_DUNGEON_UnlinkThingFromList(P291_T_ThingToUnlink, P292_T_ThingInList, P293_i_MapX, P294_i_MapY)
register THING P291_T_ThingToUnlink;
THING P292_T_ThingInList;
int P293_i_MapX;
int P294_i_MapY;
{
        register int L0271_i_SquareFirstThingIndex;
        register int L0272_i_Multiple;
#define A0272_i_SquareFirstThingIndex L0272_i_Multiple
#define A0272_i_Column                L0272_i_Multiple
        register THING L0273_T_Thing;
        register GENERIC* L0274_ps_Generic;
        register THING* L0275_pui_Multiple;
#define A0275_pT_Thing                      L0275_pui_Multiple
#define A0275_pui_CumulativeFirstThingCount L0275_pui_Multiple


        if (P291_T_ThingToUnlink == C0xFFFE_THING_ENDOFLIST) {
                return;
        }
        M09_CLEAR(P291_T_ThingToUnlink, MASK0xC000_THING_CELL);
        if (P293_i_MapX >= 0) {
                L0274_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(P291_T_ThingToUnlink);
                A0275_pT_Thing = &G283_pT_SquareFirstThings[L0271_i_SquareFirstThingIndex = F160_xxxx_DUNGEON_GetSquareFirstThingIndex(P293_i_MapX, P294_i_MapY)]; /* BUG0_01 Coding error without consequence. The engine does not check that there are things at the specified square coordinates. F160_xxxx_DUNGEON_GetSquareFirstThingIndex would return -1 for an empty square. No consequence as the function is never called with the coordinates of an empty square (except in the case of BUG0_59) */
                if ((L0274_ps_Generic->Next == C0xFFFE_THING_ENDOFLIST) && (M14_TYPE_AND_INDEX(*A0275_pT_Thing) == P291_T_ThingToUnlink)) { /* If the thing to unlink is the last thing on the square */
                        M09_CLEAR(G271_ppuc_CurrentMapData[P293_i_MapX][P294_i_MapY], MASK0x0010_THING_LIST_PRESENT);
                        F007_aAA7_MAIN_CopyBytes(A0275_pT_Thing + 1, A0275_pT_Thing, ((A0272_i_SquareFirstThingIndex = G278_ps_DungeonHeader->SquareFirstThingCount - 1) - L0271_i_SquareFirstThingIndex) << 1);
                        G283_pT_SquareFirstThings[A0272_i_SquareFirstThingIndex] = C0xFFFF_THING_NONE;
                        A0275_pui_CumulativeFirstThingCount = G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount + P293_i_MapX + 1;
                        A0272_i_Column = G282_ui_DungeonColumnCount - (G281_pi_DungeonMapsFirstColumnIndex[G272_i_CurrentMapIndex] + P293_i_MapX) - 1;
                        while (A0272_i_Column--) { /* For each column starting from and after the column containing the square where the thing is unlinked */
                                (*A0275_pui_CumulativeFirstThingCount++)--; /* Decrement the cumulative first thing count */
                        }
                        goto T164_011;
                }
                if (M14_TYPE_AND_INDEX(*A0275_pT_Thing) == P291_T_ThingToUnlink) {
                        *A0275_pT_Thing = L0274_ps_Generic->Next;
                        goto T164_011;
                }
                P292_T_ThingInList = *A0275_pT_Thing;
        }
        for(L0273_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P292_T_ThingInList); M14_TYPE_AND_INDEX(L0273_T_Thing) != P291_T_ThingToUnlink; L0273_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P292_T_ThingInList = L0273_T_Thing)) {
                if ((L0273_T_Thing == C0xFFFE_THING_ENDOFLIST) || (L0273_T_Thing == C0xFFFF_THING_NONE)) {
                        goto T164_011;
                }
        }
        L0274_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(P292_T_ThingInList);
        L0274_ps_Generic->Next = F159_rzzz_DUNGEON_GetNextThing(L0273_T_Thing);
        L0274_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(P291_T_ThingToUnlink);
        T164_011:
        L0274_ps_Generic->Next = C0xFFFE_THING_ENDOFLIST;
}

THING F165_xxxx_DUNGEON_GetDiscardedThing(P295_ui_ThingType)
unsigned int P295_ui_ThingType;
{
        register unsigned int L0276_ui_MapX;
        register unsigned int L0277_ui_MapY;
        register THING L0278_T_Thing;
        register unsigned int L0279_ui_MapIndex;
        register unsigned char* L0280_puc_Square;
        register THING* L0281_pT_SquareFirstThing;
        GENERIC* L0282_ps_Generic;
        unsigned int L0283_ui_DiscardThingMapIndex;
        int L0284_i_CurrentMapIndex;
        unsigned int L0285_ui_MapWidth;
        unsigned int L0286_ui_MapHeight;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_17_FIX */
        int L0287_i_ThingType;
#endif


        if (P295_ui_ThingType == C15_THING_TYPE_EXPLOSION) {
                return C0xFFFF_THING_NONE;
        }
        L0284_i_CurrentMapIndex = G272_i_CurrentMapIndex;
        if (((L0279_ui_MapIndex = G294_auc_LastDiscardedThingMapIndex[P295_ui_ThingType]) == G309_i_PartyMapIndex) && (++L0279_ui_MapIndex >= G278_ps_DungeonHeader->MapCount)) {
                L0279_ui_MapIndex = 0;
        }
        L0283_ui_DiscardThingMapIndex = L0279_ui_MapIndex;
        do {
                L0285_ui_MapWidth = G277_ps_DungeonMaps[L0279_ui_MapIndex].A.Width;
                L0286_ui_MapHeight = G277_ps_DungeonMaps[L0279_ui_MapIndex].A.Height;
                L0280_puc_Square = G279_pppuc_DungeonMapData[L0279_ui_MapIndex][0];
                L0281_pT_SquareFirstThing = &G283_pT_SquareFirstThings[G280_pui_DungeonColumnsCumulativeSquareThingCount[G281_pi_DungeonMapsFirstColumnIndex[L0279_ui_MapIndex]]];
                for(L0276_ui_MapX = 0; L0276_ui_MapX <= L0285_ui_MapWidth; L0276_ui_MapX++) {
                        for(L0277_ui_MapY = 0; L0277_ui_MapY <= L0286_ui_MapHeight; L0277_ui_MapY++) {
                                if (M07_GET(*L0280_puc_Square++, MASK0x0010_THING_LIST_PRESENT)) {
                                        L0278_T_Thing = *L0281_pT_SquareFirstThing++;
                                        if ((L0279_ui_MapIndex == G309_i_PartyMapIndex) && ((L0276_ui_MapX - G306_i_PartyMapX + 5) <= 10) && ((L0277_ui_MapY - G307_i_PartyMapY + 5) <= 10)) { /* If square is too close to the party */
                                        } else {
                                                do {
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_17_FIX */
                                                        if (M12_TYPE(L0278_T_Thing) == P295_ui_ThingType) { /* BUG0_09 The game may trigger a sensor and cause an undesired effect when discarding a thing from a square. When the game needs to create a new thing but has run out of storage for the corresponding thing type (for example when creating a Screamer Slice after a Screamer is killed) it will try to remove another thing of the same type elsewhere in the dungeon (except things that are explicitly marked as non discardable). If the square where the thing is removed contains a sensor, it may be triggered and cause an undesired effect. For example, discarding a Screamer Slice placed by the player on a pressure plate on the floor may close a door or open a pit which may block the party */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_17_FIX Squares with enabled sensors are ignored when searching for a thing to discard */
                                                        if ((L0287_i_ThingType = M12_TYPE(L0278_T_Thing)) == C03_THING_TYPE_SENSOR) {
                                                                L0282_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L0278_T_Thing);
                                                                if (M39_TYPE((SENSOR*)L0282_ps_Generic)) { /* If sensor is not disabled */
                                                                        break;
                                                                }
                                                        } else {
                                                                if (L0287_i_ThingType == P295_ui_ThingType) {
#endif
                                                                        L0282_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L0278_T_Thing);
                                                                        switch (P295_ui_ThingType) {
                                                                                case C04_THING_TYPE_GROUP:
                                                                                        if (((GROUP*)L0282_ps_Generic)->DoNotDiscard) {
                                                                                                continue;
                                                                                        }
                                                                                case C14_THING_TYPE_PROJECTILE:
                                                                                        F173_gzzz_DUNGEON_SetCurrentMap(L0279_ui_MapIndex);
                                                                                        if (P295_ui_ThingType == C04_THING_TYPE_GROUP) {
                                                                                                F188_aozz_GROUP_DropGroupPossessions(L0276_ui_MapX, L0277_ui_MapY, L0278_T_Thing, CM1_MODE_DO_NOT_PLAY_SOUND);
                                                                                                F189_awzz_GROUP_Delete(L0276_ui_MapX, L0277_ui_MapY);
                                                                                        } else {
                                                                                                F214_pzzz_PROJECTILE_DeleteEvent(L0278_T_Thing);
                                                                                                F164_dzzz_DUNGEON_UnlinkThingFromList(L0278_T_Thing, 0, L0276_ui_MapX, L0277_ui_MapY);
                                                                                                F215_lzzz_PROJECTILE_Delete(L0278_T_Thing, NULL, L0276_ui_MapX, L0277_ui_MapY);
                                                                                        }
                                                                                        break;
                                                                                case C06_THING_TYPE_ARMOUR:
                                                                                        if (((ARMOUR*)L0282_ps_Generic)->DoNotDiscard) {
                                                                                                continue;
                                                                                        }
                                                                                        goto T165_026;
                                                                                case C05_THING_TYPE_WEAPON:
                                                                                        if (((WEAPON*)L0282_ps_Generic)->DoNotDiscard) {
                                                                                                continue;
                                                                                        }
                                                                                        goto T165_026;
                                                                                case C10_THING_TYPE_JUNK:
                                                                                        if (((JUNK*)L0282_ps_Generic)->DoNotDiscard) {
                                                                                                continue;
                                                                                        }
                                                                                        goto T165_026;
                                                                                case C08_THING_TYPE_POTION:
                                                                                        if (((POTION*)L0282_ps_Generic)->DoNotDiscard) {
                                                                                                continue;
                                                                                        }
                                                                                        T165_026:
                                                                                        F173_gzzz_DUNGEON_SetCurrentMap(L0279_ui_MapIndex);
                                                                                        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0278_T_Thing, L0276_ui_MapX, L0277_ui_MapY, CM1_MAPX_NOT_ON_A_SQUARE, 0);
                                                                        }
                                                                        F173_gzzz_DUNGEON_SetCurrentMap(L0284_i_CurrentMapIndex);
                                                                        G294_auc_LastDiscardedThingMapIndex[P295_ui_ThingType] = L0279_ui_MapIndex;
                                                                        return M14_TYPE_AND_INDEX(L0278_T_Thing);
                                                                }
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_17_FIX */
                                                        }
#endif
                                                } while ((L0278_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0278_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
                                        }
                                }
                        }
                }
                if ((L0279_ui_MapIndex == G309_i_PartyMapIndex) || (G278_ps_DungeonHeader->MapCount <= 1)) {
                        G294_auc_LastDiscardedThingMapIndex[P295_ui_ThingType] = L0279_ui_MapIndex;
                        return C0xFFFF_THING_NONE;
                }
                do {
                        if (++L0279_ui_MapIndex >= G278_ps_DungeonHeader->MapCount) {
                                L0279_ui_MapIndex = 0;
                        }
                } while (L0279_ui_MapIndex == G309_i_PartyMapIndex);
                if (L0279_ui_MapIndex == L0283_ui_DiscardThingMapIndex) {
                        L0279_ui_MapIndex = G309_i_PartyMapIndex;
                }
        } while ();
}

THING F166_szzz_DUNGEON_GetUnusedThing(P296_ui_ThingType)
register unsigned int P296_ui_ThingType;
{
        register int L0288_i_ThingIndex;
        register int L0289_i_ThingDataByteCount;
        register int L0290_i_ThingCount;
        register GENERIC* L0291_ps_Generic;
        THING L0292_T_Thing;


#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_18_FIX */
        L0290_i_ThingCount = G278_ps_DungeonHeader->ThingCount[P296_ui_ThingType]; /* BUG0_10 Coding error without consequence. Out of bounds array index. The game reserves a pool of 3 things to make sure it can create 'Bones' objects for dead champions in the party. When the game creates a thing for a dead champion's bones then Bit 15 is set in the requested thing type to indicate that the pool of reserved things can be used. This bit is not cleared before using the thing type as an array index. No consequence because the machine code generated by the Megamax C compiler left shifts the 16 bits value by 1 bit and then keeps the least significant 16 bits, effectively truncating the original and unwanted bit 15. With other compilers or other platforms this may cause an out of bounds array index issue */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_18_FIX Clear bit 15 to get the actual thing type before using the value */
        L0290_i_ThingCount = G278_ps_DungeonHeader->ThingCount[M07_GET(P296_ui_ThingType, MASK0x7FFF_THING_TYPE)];
#endif
        if (P296_ui_ThingType == (MASK0x8000_CHAMPION_BONES | C10_THING_TYPE_JUNK)) {
                P296_ui_ThingType = C10_THING_TYPE_JUNK;
        } else {
                if (P296_ui_ThingType == C10_THING_TYPE_JUNK) {
                        L0290_i_ThingCount -= 3; /* Always keep 3 unused JUNK things for the bones of dead champions */
                }
        }
        L0288_i_ThingIndex = L0290_i_ThingCount;
        L0289_i_ThingDataByteCount = G235_auc_Graphic559_ThingDataByteCount[P296_ui_ThingType] >> 1;
        L0291_ps_Generic = (GENERIC*)G284_apuc_ThingData[P296_ui_ThingType];
        do {
                if (L0291_ps_Generic->Next == C0xFFFF_THING_NONE) { /* If thing data is unused */
                        L0292_T_Thing = (P296_ui_ThingType << 10) | (L0290_i_ThingCount - L0288_i_ThingIndex);
                        break;
                }
                if (--L0288_i_ThingIndex) { /* If there are thing data left to process */
                        L0291_ps_Generic += L0289_i_ThingDataByteCount; /* Proceed to the next thing data */
                } else {
                        if ((L0292_T_Thing = F165_xxxx_DUNGEON_GetDiscardedThing(P296_ui_ThingType)) == C0xFFFF_THING_NONE) {
                                return C0xFFFF_THING_NONE;
                        }
                        L0291_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L0292_T_Thing);
                        break;
                }
        } while ();
        F008_aA19_MAIN_ClearBytes(L0291_ps_Generic, L0289_i_ThingDataByteCount << 1);
        L0291_ps_Generic->Next = C0xFFFE_THING_ENDOFLIST;
        return L0292_T_Thing;
}

THING F167_aozz_DUNGEON_GetObjectForProjectileLauncherOrObjectGenerator(P297_ui_IconIndex)
register unsigned int P297_ui_IconIndex;
{
        register int L0293_i_Type;
        register int L0294_i_ThingType;
        register THING L0295_T_Thing;
        register JUNK* L0296_ps_Junk;


        L0294_i_ThingType = C05_THING_TYPE_WEAPON;
        if ((P297_ui_IconIndex >= C004_ICON_WEAPON_TORCH_UNLIT) && (P297_ui_IconIndex <= C007_ICON_WEAPON_TORCH_LIT)) {
                P297_ui_IconIndex = C004_ICON_WEAPON_TORCH_UNLIT;
        }
        switch (P297_ui_IconIndex) {
                case C054_ICON_WEAPON_ROCK:
                        L0293_i_Type = C30_WEAPON_ROCK;
                        break;
                case C128_ICON_JUNK_BOULDER:
                        L0293_i_Type = C25_JUNK_BOULDER;
                        L0294_i_ThingType = C10_THING_TYPE_JUNK;
                        break;
                case C051_ICON_WEAPON_ARROW:
                        L0293_i_Type = C27_WEAPON_ARROW;
                        break;
                case C052_ICON_WEAPON_SLAYER:
                        L0293_i_Type = C28_WEAPON_SLAYER;
                        break;
                case C055_ICON_WEAPON_POISON_DART:
                        L0293_i_Type = C31_WEAPON_POISON_DART;
                        break;
                case C056_ICON_WEAPON_THROWING_STAR:
                        L0293_i_Type = C32_WEAPON_THROWING_STAR;
                        break;
                case C032_ICON_WEAPON_DAGGER:
                        L0293_i_Type = C08_WEAPON_DAGGER;
                        break;
                case C004_ICON_WEAPON_TORCH_UNLIT:
                        L0293_i_Type = C02_WEAPON_TORCH;
                        break;
                default:
                        return C0xFFFF_THING_NONE;
        }
        if ((L0295_T_Thing = F166_szzz_DUNGEON_GetUnusedThing(L0294_i_ThingType)) == C0xFFFF_THING_NONE) {
                return C0xFFFF_THING_NONE;
        }
        L0296_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L0295_T_Thing);
        L0296_ps_Junk->Type = L0293_i_Type; /* Also works for WEAPON in cases other than Boulder */
        if ((P297_ui_IconIndex == C004_ICON_WEAPON_TORCH_UNLIT) && ((WEAPON*)L0296_ps_Junk)->Lit) { /* BUG0_65 Torches created by object generator or projectile launcher sensors have no charges. Charges are only defined if the Torch is lit which is not possible at the time it is created */
                ((WEAPON*)L0296_ps_Junk)->ChargeCount = 15;
        }
        return L0295_T_Thing;
}

VOID F168_ajzz_DUNGEON_DecodeText(P298_pc_String, P299_T_Thing, P300_i_TextType)
register char* P298_pc_String;
THING P299_T_Thing;
register int P300_i_TextType;
{
        register unsigned int L0297_ui_Codes;
        register unsigned int L0298_ui_CodeCounter;
        register unsigned int L0299_ui_Code;
        register unsigned int* L0300_pui_CodeWord;
        char L0301_c_SeparatorCharacter;
        int L0302_i_EscapeCharacter;
        char* L0303_pc_EscapeReplacementString;
        TEXT L0304_s_Text;


        L0304_s_Text = ((TEXT*)G284_apuc_ThingData[C02_THING_TYPE_TEXT])[M13_INDEX(P299_T_Thing)];
        if ((L0304_s_Text.Visible) || M07_GET(P300_i_TextType, MASK0x8000_DECODE_EVEN_IF_INVISIBLE)) {
                M09_CLEAR(P300_i_TextType, MASK0x8000_DECODE_EVEN_IF_INVISIBLE);
                if (P300_i_TextType == C1_TEXT_TYPE_MESSAGE) {
                        *P298_pc_String++ = '\n'; /* New line */
                        L0301_c_SeparatorCharacter = ' ';
                } else {
                        if (P300_i_TextType == C0_TEXT_TYPE_INSCRIPTION) {
                                L0301_c_SeparatorCharacter = '\200'; /* Octal. Hexadecimal: 0x80 (Megamax C does not support hexadecimal character constants) */
                        } else {
                                L0301_c_SeparatorCharacter = '\n'; /* New line */
                        }
                }
                L0298_ui_CodeCounter = 0;
                L0302_i_EscapeCharacter = 0;
                L0300_pui_CodeWord = G260_pui_DungeonTextData + L0304_s_Text.TextDataWordOffset;
                do {
                        if (!L0298_ui_CodeCounter) {
                                L0297_ui_Codes = *L0300_pui_CodeWord++;
                                L0299_ui_Code = (L0297_ui_Codes >> 10) & 0x001F;
                        } else {
                                if (L0298_ui_CodeCounter == 1) {
                                        L0299_ui_Code = (L0297_ui_Codes >> 5) & 0x001F;
                                } else {
                                        L0299_ui_Code = L0297_ui_Codes & 0x001F;
                                }
                        }
                        L0298_ui_CodeCounter++;
                        L0298_ui_CodeCounter = L0298_ui_CodeCounter % 3;
                        if (L0302_i_EscapeCharacter) {
                                *P298_pc_String = '\0';
                                if (L0302_i_EscapeCharacter == 30) {
                                        if (P300_i_TextType != C0_TEXT_TYPE_INSCRIPTION) {
                                                L0303_pc_EscapeReplacementString = G255_aac_Graphic559_MessageAndScrollEscapeReplacementStrings[L0299_ui_Code];
                                        } else {
                                                L0303_pc_EscapeReplacementString = G257_aac_Graphic559_InscriptionEscapeReplacementStrings[L0299_ui_Code];
                                        }
                                } else {
                                        if (P300_i_TextType != C0_TEXT_TYPE_INSCRIPTION) {
                                                L0303_pc_EscapeReplacementString = G256_aac_Graphic559_EscapeReplacementCharacters[L0299_ui_Code];
                                        } else {
                                                L0303_pc_EscapeReplacementString = G256_aac_Graphic559_EscapeReplacementCharacters[L0299_ui_Code];
                                        }
                                }
                                strcat(P298_pc_String, L0303_pc_EscapeReplacementString);
                                P298_pc_String += strlen(L0303_pc_EscapeReplacementString);
                                L0302_i_EscapeCharacter = 0;
                        } else {
                                if (L0299_ui_Code < 28) {
                                        if (P300_i_TextType != C0_TEXT_TYPE_INSCRIPTION) {
                                                if (L0299_ui_Code == 26) {
                                                        L0299_ui_Code = ' ';
                                                } else {
                                                        if (L0299_ui_Code == 27) {
                                                                L0299_ui_Code = '.';
                                                        } else {
                                                                L0299_ui_Code += 'A';
                                                        }
                                                }
                                        }
                                        *P298_pc_String++ = L0299_ui_Code;
                                } else {
                                        if (L0299_ui_Code == 28) {
                                                *P298_pc_String++ = L0301_c_SeparatorCharacter;
                                        } else {
                                                if (L0299_ui_Code <= 30) { /* Codes 29 and 30 are escape characters */
                                                        L0302_i_EscapeCharacter = L0299_ui_Code;
                                                } else { /* Code 31 marks the end of the text */
                                                        break;
                                                }
                                        }
                                }
                        }
                } while ();
        }
        if (P300_i_TextType == C0_TEXT_TYPE_INSCRIPTION) {
                *P298_pc_String = '\201'; /* Octal. Hexadecimal: 0x81 (Megamax C does not support hexadecimal character constants) */
        } else {
                *P298_pc_String = '\0';
        }
}

int F169_xxxx_DUNGEON_GetRandomOrnamentIndex(P301_ui_Value1, P302_ui_Value2, P303_i_Modulo)
unsigned int P301_ui_Value1;
unsigned int P302_ui_Value2;
int P303_i_Modulo;
{
        return ((((P301_ui_Value1 * 31417) >> 1) + (P302_ui_Value2 * 11) + G278_ps_DungeonHeader->OrnamentRandomSeed) >> 2) % P303_i_Modulo; /* Pseudorandom number generator */
}

int F170_xxxx_DUNGEON_GetRandomOrnamentOrdinal(P304_B_RandomOrnamentAllowed, P305_i_OrnamentCount, P306_i_MapX, P307_i_MapY, P308_i_Modulo)
BOOLEAN P304_B_RandomOrnamentAllowed;
int P305_i_OrnamentCount;
int P306_i_MapX;
int P307_i_MapY;
int P308_i_Modulo;
{
        int L0305_i_RandomOrnamentIndex;


        if (P304_B_RandomOrnamentAllowed && ((L0305_i_RandomOrnamentIndex = F169_xxxx_DUNGEON_GetRandomOrnamentIndex(2000 + (P306_i_MapX << 5) + P307_i_MapY, 3000 + (G272_i_CurrentMapIndex << 6) + G273_i_CurrentMapWidth + G274_i_CurrentMapHeight, P308_i_Modulo)) < P305_i_OrnamentCount)) {
                return M00_INDEX_TO_ORDINAL(L0305_i_RandomOrnamentIndex);
        }
        return 0;
}

VOID F171_xxxx_DUNGEON_SetSquareAspectRandomWallOrnamentOrdinals(P309_pi_SquareAspect, P310_B_LeftRandomWallOrnamentAllowed, P311_B_FrontRandomWallOrnamentAllowed, P312_B_RightRandomWallOrnamentAllowed, P313_i_Direction, P314_i_MapX, P315_i_MapY, P316_B_SquareIsFakeWall)
register int* P309_pi_SquareAspect;
BOOLEAN P310_B_LeftRandomWallOrnamentAllowed;
BOOLEAN P311_B_FrontRandomWallOrnamentAllowed;
BOOLEAN P312_B_RightRandomWallOrnamentAllowed;
register int P313_i_Direction;
register int P314_i_MapX;
register int P315_i_MapY;
BOOLEAN P316_B_SquareIsFakeWall;
{
        register int L0306_i_Multiple;
#define A0306_i_RandomWallOrnamentCount L0306_i_Multiple
#define A0306_i_SideIndex               L0306_i_Multiple


        A0306_i_RandomWallOrnamentCount = G269_ps_CurrentMap->B.RandomWallOrnamentCount;
        P309_pi_SquareAspect[C2_RIGHT_WALL_ORNAMENT_ORDINAL] = F170_xxxx_DUNGEON_GetRandomOrnamentOrdinal(P310_B_LeftRandomWallOrnamentAllowed, A0306_i_RandomWallOrnamentCount, P314_i_MapX, ++P315_i_MapY * (M21_NORMALIZE(++P313_i_Direction) + 1), 30);
        P309_pi_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL] = F170_xxxx_DUNGEON_GetRandomOrnamentOrdinal(P311_B_FrontRandomWallOrnamentAllowed, A0306_i_RandomWallOrnamentCount, P314_i_MapX, P315_i_MapY * (M21_NORMALIZE(++P313_i_Direction) + 1), 30);
        P309_pi_SquareAspect[C4_LEFT_WALL_ORNAMENT_ORDINAL] = F170_xxxx_DUNGEON_GetRandomOrnamentOrdinal(P312_B_RightRandomWallOrnamentAllowed, A0306_i_RandomWallOrnamentCount, P314_i_MapX, P315_i_MapY-- * (M21_NORMALIZE(++P313_i_Direction) + 1), 30);
        if (P316_B_SquareIsFakeWall || (P314_i_MapX < 0) || (P314_i_MapX >= G273_i_CurrentMapWidth) || (P315_i_MapY < 0) || (P315_i_MapY >= G274_i_CurrentMapHeight)) { /* If square is a fake wall or is out of map bounds */
                for(A0306_i_SideIndex = C2_RIGHT_WALL_ORNAMENT_ORDINAL; A0306_i_SideIndex <= C4_LEFT_WALL_ORNAMENT_ORDINAL; A0306_i_SideIndex++) { /* Loop to remove any random ornament that is an alcove */
                        if (F149_aawz_DUNGEON_IsWallOrnamentAnAlcove(M01_ORDINAL_TO_INDEX(P309_pi_SquareAspect[A0306_i_SideIndex]))) {
                                P309_pi_SquareAspect[A0306_i_SideIndex] = 0;
                        }
                }
        }
}

VOID F172_awzz_DUNGEON_SetSquareAspect(P317_pi_SquareAspect, P318_i_Direction, P319_i_MapX, P320_i_MapY)
register int* P317_pi_SquareAspect;
register int P318_i_Direction;
#define AP318_i_ThingType P318_i_Direction
register int P319_i_MapX;
register int P320_i_MapY;
{
        register unsigned char L0307_uc_Multiple;
#define A0307_uc_Square            L0307_uc_Multiple
#define A0307_uc_FootprintsAllowed L0307_uc_Multiple
#define A0307_uc_ScentOrdinal      L0307_uc_Multiple
        register SENSOR* L0308_ps_Sensor;
        BOOLEAN L0309_B_LeftRandomWallOrnamentAllowed;
        int L0310_i_Multiple;
#define A0310_B_FrontRandomWallOrnamentAllowed L0310_i_Multiple
#define A0310_i_SideIndex                      L0310_i_Multiple
        BOOLEAN L0311_B_RightRandomWallOrnamentAllowed;
        int L0312_i_ThingType;
        BOOLEAN L0313_B_SquareIsFakeWall;
        THING L0314_T_Thing;


        F008_aA19_MAIN_ClearBytes(P317_pi_SquareAspect, 5 * sizeof(int));
        L0314_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P319_i_MapX, P320_i_MapY);
        A0307_uc_Square = F151_rzzz_DUNGEON_GetSquare(P319_i_MapX, P320_i_MapY);
        switch (P317_pi_SquareAspect[C0_ELEMENT] = M34_SQUARE_TYPE(A0307_uc_Square)) {
                case C00_ELEMENT_WALL:
                        switch (P318_i_Direction) {
                                case C0_DIRECTION_NORTH:
                                        L0309_B_LeftRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0004_WALL_EAST_RANDOM_ORNAMENT_ALLOWED);
                                        A0310_B_FrontRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0002_WALL_SOUTH_RANDOM_ORNAMENT_ALLOWED);
                                        L0311_B_RightRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0001_WALL_WEST_RANDOM_ORNAMENT_ALLOWED);
                                        break;
                                case C1_DIRECTION_EAST:
                                        L0309_B_LeftRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0002_WALL_SOUTH_RANDOM_ORNAMENT_ALLOWED);
                                        A0310_B_FrontRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0001_WALL_WEST_RANDOM_ORNAMENT_ALLOWED);
                                        L0311_B_RightRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0008_WALL_NORTH_RANDOM_ORNAMENT_ALLOWED);
                                        break;
                                case C2_DIRECTION_SOUTH:
                                        L0309_B_LeftRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0001_WALL_WEST_RANDOM_ORNAMENT_ALLOWED);
                                        A0310_B_FrontRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0008_WALL_NORTH_RANDOM_ORNAMENT_ALLOWED);
                                        L0311_B_RightRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0004_WALL_EAST_RANDOM_ORNAMENT_ALLOWED);
                                        break;
                                case C3_DIRECTION_WEST:
                                        L0309_B_LeftRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0008_WALL_NORTH_RANDOM_ORNAMENT_ALLOWED);
                                        A0310_B_FrontRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0004_WALL_EAST_RANDOM_ORNAMENT_ALLOWED);
                                        L0311_B_RightRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0002_WALL_SOUTH_RANDOM_ORNAMENT_ALLOWED);
                        }
                        G289_i_DungeonView_ChampionPortraitOrdinal = 0; /* BUG0_75 Multiple champion portraits are drawn (one at a time) then the game crashes. This variable is only reset to 0 when at least one square in the dungeon view is a wall. If the party is in front of a wall with a champion portrait and the next time the dungeon view is drawn there is no wall square in the view and the square in front of the party is a fake wall with a random ornament then the same champion portrait will be drawn again because the variable was not reset to 0. Each time F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF draws the portrait, G289_i_DungeonView_ChampionPortraitOrdinal is decremented so that the portait is different each time the dungeon view is drawn until the game crashes */
                        L0313_B_SquareIsFakeWall = FALSE;
                        T172_010_ClosedFakeWall:
                        F171_xxxx_DUNGEON_SetSquareAspectRandomWallOrnamentOrdinals(P317_pi_SquareAspect, L0309_B_LeftRandomWallOrnamentAllowed, A0310_B_FrontRandomWallOrnamentAllowed, L0311_B_RightRandomWallOrnamentAllowed, P318_i_Direction, P319_i_MapX, P320_i_MapY, L0313_B_SquareIsFakeWall);
                        while ((L0314_T_Thing != C0xFFFE_THING_ENDOFLIST) && ((L0312_i_ThingType = M12_TYPE(L0314_T_Thing)) <= C03_THING_TYPE_SENSOR)) {
                                if (A0310_i_SideIndex = M21_NORMALIZE(M11_CELL(L0314_T_Thing) - P318_i_Direction)) { /* Invisible on the back wall if 0 */
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                        if (L0312_i_ThingType == C02_THING_TYPE_TEXT) {
                                                if (((TEXT*)G284_apuc_ThingData[C02_THING_TYPE_TEXT])[M13_INDEX(L0314_T_Thing)].Visible) {
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                        L0308_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0314_T_Thing);
                                        if (L0312_i_ThingType == C02_THING_TYPE_TEXT) {
                                                if (((TEXT*)L0308_ps_Sensor)->Visible) {
#endif
                                                        P317_pi_SquareAspect[A0310_i_SideIndex + 1] = G265_i_CurrentMapInscriptionWallOrnamentIndex + 1;
                                                        G290_T_DungeonView_InscriptionThing = L0314_T_Thing; /* BUG0_76 The same text is drawn on multiple sides of a wall square. The engine stores only a single text to draw on a wall in a global variable. Even if different texts are placed on differents sides of the wall, the same text is drawn on each affected side */
                                                }
                                        } else {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                                L0308_ps_Sensor = &((SENSOR*)G284_apuc_ThingData[C03_THING_TYPE_SENSOR])[M13_INDEX(L0314_T_Thing)];
#endif
                                                P317_pi_SquareAspect[A0310_i_SideIndex + 1] = L0308_ps_Sensor->A.OrnamentOrdinal;
                                                if (M39_TYPE(L0308_ps_Sensor) == C127_SENSOR_WALL_CHAMPION_PORTRAIT) {
                                                        G289_i_DungeonView_ChampionPortraitOrdinal = M00_INDEX_TO_ORDINAL(M40_DATA(L0308_ps_Sensor));
                                                }
                                        }
                                }
                                L0314_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0314_T_Thing);
                        }
                        if (L0313_B_SquareIsFakeWall && (G306_i_PartyMapX != P319_i_MapX) && (G307_i_PartyMapY != P320_i_MapY)) {
                                P317_pi_SquareAspect[C1_FIRST_GROUP_OR_OBJECT] = C0xFFFE_THING_ENDOFLIST;
                                return;
                        }
                        break;
                case C02_ELEMENT_PIT:
                        if (M07_GET(A0307_uc_Square, MASK0x0008_PIT_OPEN)) {
                                P317_pi_SquareAspect[C2_PIT_INVISIBLE] = M07_GET(A0307_uc_Square, MASK0x0004_PIT_INVISIBLE);
                                A0307_uc_FootprintsAllowed &= 0x0001;
                        } else {
                                P317_pi_SquareAspect[C0_ELEMENT] = C01_ELEMENT_CORRIDOR;
                                A0307_uc_FootprintsAllowed = TRUE;
                        }
                        goto T172_030_Pit;
                case C06_ELEMENT_FAKEWALL:
                        if (!M07_GET(A0307_uc_Square, MASK0x0004_FAKEWALL_OPEN)) {
                                P317_pi_SquareAspect[C0_ELEMENT] = C00_ELEMENT_WALL;
                                L0309_B_LeftRandomWallOrnamentAllowed = L0311_B_RightRandomWallOrnamentAllowed = A0310_B_FrontRandomWallOrnamentAllowed = M07_GET(A0307_uc_Square, MASK0x0008_FAKEWALL_RANDOM_ORNAMENT_OR_FOOTPRINTS_ALLOWED);
                                L0313_B_SquareIsFakeWall = TRUE;
                                goto T172_010_ClosedFakeWall;
                        }
                        P317_pi_SquareAspect[C0_ELEMENT] = C01_ELEMENT_CORRIDOR;
                        A0307_uc_FootprintsAllowed = M07_GET(A0307_uc_Square, MASK0x0008_FAKEWALL_RANDOM_ORNAMENT_OR_FOOTPRINTS_ALLOWED) ? 8 : 0;
                case C01_ELEMENT_CORRIDOR:
                        P317_pi_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL] = F170_xxxx_DUNGEON_GetRandomOrnamentOrdinal(M07_GET(A0307_uc_Square, MASK0x0008_CORRIDOR_RANDOM_ORNAMENT_ALLOWED), G269_ps_CurrentMap->B.RandomFloorOrnamentCount, P319_i_MapX, P320_i_MapY, 30);
                        T172_029_Teleporter:
                        A0307_uc_FootprintsAllowed = TRUE;
                        T172_030_Pit:
                        while ((L0314_T_Thing != C0xFFFE_THING_ENDOFLIST) && ((AP318_i_ThingType = M12_TYPE(L0314_T_Thing)) <= C03_THING_TYPE_SENSOR)) {
                                if (AP318_i_ThingType == C03_THING_TYPE_SENSOR) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                        P317_pi_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL] = ((SENSOR*)G284_apuc_ThingData[C03_THING_TYPE_SENSOR])[M13_INDEX(L0314_T_Thing)].A.OrnamentOrdinal;
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                        L0308_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0314_T_Thing);
                                        P317_pi_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL] = L0308_ps_Sensor->A.OrnamentOrdinal;
#endif
                                }
                                L0314_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0314_T_Thing);
                        }
                        goto T172_049_Footprints;
                case C05_ELEMENT_TELEPORTER:
                        P317_pi_SquareAspect[C2_TELEPORTER_VISIBLE] = M07_GET(A0307_uc_Square, MASK0x0008_TELEPORTER_OPEN) && M07_GET(A0307_uc_Square, MASK0x0004_TELEPORTER_VISIBLE);
                        goto T172_029_Teleporter;
                case C03_ELEMENT_STAIRS:
                        P317_pi_SquareAspect[C0_ELEMENT] = ((M07_GET(A0307_uc_Square, MASK0x0008_STAIRS_NORTH_SOUTH_ORIENTATION) >> 3) == M16_IS_ORIENTED_WEST_EAST(P318_i_Direction)) ? C18_ELEMENT_STAIRS_SIDE : C19_ELEMENT_STAIRS_FRONT;
                        P317_pi_SquareAspect[C2_STAIRS_UP] = M07_GET(A0307_uc_Square, MASK0x0004_STAIRS_UP);
                        A0307_uc_FootprintsAllowed = FALSE;
                        goto T172_046_Stairs;
                case C04_ELEMENT_DOOR:
                        if ((M07_GET(A0307_uc_Square, MASK0x0008_DOOR_NORTH_SOUTH_ORIENTATION) >> 3) == M16_IS_ORIENTED_WEST_EAST(P318_i_Direction)) {
                                P317_pi_SquareAspect[C0_ELEMENT] = C16_ELEMENT_DOOR_SIDE;
                        } else {
                                P317_pi_SquareAspect[C0_ELEMENT] = C17_ELEMENT_DOOR_FRONT;
                                P317_pi_SquareAspect[C2_DOOR_STATE] = M36_DOOR_STATE(A0307_uc_Square);
                                P317_pi_SquareAspect[C3_DOOR_THING_INDEX] = M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(P319_i_MapX, P320_i_MapY));
                        }
                        A0307_uc_FootprintsAllowed = TRUE;
                        T172_046_Stairs:
                        while ((L0314_T_Thing != C0xFFFE_THING_ENDOFLIST) && (M12_TYPE(L0314_T_Thing) <= C03_THING_TYPE_SENSOR)) {
                                L0314_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0314_T_Thing);
                        }
                        T172_049_Footprints:
                        if (A0307_uc_FootprintsAllowed && (A0307_uc_ScentOrdinal = F315_arzz_CHAMPION_GetScentOrdinal(P319_i_MapX, P320_i_MapY)) && (--A0307_uc_ScentOrdinal >= G407_s_Party.FirstScentIndex) && (A0307_uc_ScentOrdinal < G407_s_Party.LastScentIndex)) {
                                M08_SET(P317_pi_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], MASK0x8000_FOOTPRINTS);
                        }
        }
        P317_pi_SquareAspect[C1_FIRST_GROUP_OR_OBJECT] = L0314_T_Thing;
}

VOID F173_gzzz_DUNGEON_SetCurrentMap(P321_ui_MapIndex)
register unsigned int P321_ui_MapIndex;
{
        if (G272_i_CurrentMapIndex == P321_ui_MapIndex) {
                return;
        }
        G272_i_CurrentMapIndex = P321_ui_MapIndex;
        G271_ppuc_CurrentMapData = G279_pppuc_DungeonMapData[P321_ui_MapIndex];
        G269_ps_CurrentMap = G277_ps_DungeonMaps + P321_ui_MapIndex;
        G273_i_CurrentMapWidth = G269_ps_CurrentMap->A.Width + 1;
        G274_i_CurrentMapHeight = G269_ps_CurrentMap->A.Height + 1;
        G275_as_CurrentMapDoorInfo[0] = G254_as_Graphic559_DoorInfo[G269_ps_CurrentMap->D.DoorSet0];
        G275_as_CurrentMapDoorInfo[1] = G254_as_Graphic559_DoorInfo[G269_ps_CurrentMap->D.DoorSet1];
        G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount = &G280_pui_DungeonColumnsCumulativeSquareThingCount[G281_pi_DungeonMapsFirstColumnIndex[P321_ui_MapIndex]];
}

VOID F174_aozz_DUNGEON_SetCurrentMapAndPartyMap(P322_i_MapIndex)
register int P322_i_MapIndex;
{
        register int L0315_i_FloorOrnamentCount;
        register unsigned char* L0316_puc_MapMetaData;


        F173_gzzz_DUNGEON_SetCurrentMap(G309_i_PartyMapIndex = P322_i_MapIndex);
        L0316_puc_MapMetaData = G271_ppuc_CurrentMapData[G273_i_CurrentMapWidth - 1] + G274_i_CurrentMapHeight;
        G264_puc_CurrentMapAllowedCreatureTypes = L0316_puc_MapMetaData;
        F007_aAA7_MAIN_CopyBytes(L0316_puc_MapMetaData += G269_ps_CurrentMap->C.CreatureTypeCount, G261_auc_CurrentMapWallOrnamentIndices, G265_i_CurrentMapInscriptionWallOrnamentIndex = G269_ps_CurrentMap->B.WallOrnamentCount);
        F007_aAA7_MAIN_CopyBytes(L0316_puc_MapMetaData += G265_i_CurrentMapInscriptionWallOrnamentIndex, G262_auc_CurrentMapFloorOrnamentIndices, L0315_i_FloorOrnamentCount = G269_ps_CurrentMap->B.FloorOrnamentCount);
        F007_aAA7_MAIN_CopyBytes(L0316_puc_MapMetaData + L0315_i_FloorOrnamentCount, G263_auc_CurrentMapDoorOrnamentIndices, G269_ps_CurrentMap->C.DoorOrnamentCount);
        G261_auc_CurrentMapWallOrnamentIndices[G265_i_CurrentMapInscriptionWallOrnamentIndex] = C0_WALL_ORNAMENT_INSCRIPTION;
}
