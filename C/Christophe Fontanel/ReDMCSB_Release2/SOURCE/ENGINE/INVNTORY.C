#include "DEFS.H"

/*_Global variables_*/
BOOLEAN G420_B_MousePointerHiddenToDrawChangedObjectIconOnScreen;
int G421_i_ObjectDescriptionTextX;
int G422_i_ObjectDescriptionTextY;
int G423_i_InventoryChampionOrdinal;
int G424_i_PanelContent = C0_PANEL_FOOD_WATER_POISONED;
THING G425_aT_ChestSlots[8];
THING G426_T_OpenChest = C0xFFFF_THING_NONE;
#ifndef NOCOPYPROTECTION
char G427_ac_CodePatch5_COPYPROTECTIONE[68];
#endif
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
char* G428_apc_SkillLevelNames[15] = { "NEOPHYTE", "NOVICE", "APPRENTICE", "JOURNEYMAN",
                                       "CRAFTSMAN", "ARTISAN", "ADEPT", "EXPERT",
                                       "` MASTER", "a MASTER", "b MASTER", "c MASTER",
                                       "d MASTER", "e MASTER", "ARCHMASTER" };
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
char* G428_apc_SkillLevelNames[15] = { "ANFANGER", "NEULING", "LEHRLING", "ARBEITER",
                                       "GESELLE", "HANDWERKR", "FACHMANN", "EXPERTE",
                                       "` MEISTER", "a MEISTER", "b MEISTER", "c MEISTER",
                                       "d MEISTER", "e MEISTER", "ERZMEISTR" };
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
char* G428_apc_SkillLevelNames[15] = { "NEOPHYTE", "NOVICE", "APPRENTI", "COMPAGNON",
                                       "ARTISAN", "PATRON", "ADEPTE", "EXPERT",
                                       "MAITRE '", "MAITRE a", "MAITRE b", "MAITRE c",
                                       "MAITRE d", "MAITRE e", "SUR-MAITRE" };
#endif
#ifndef NOCOPYPROTECTION
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_04_IMPROVEMENT */
char* G429_apc_Graphic21Result_COPYPROTECTIONE[3] = { (char*)&G293_ai_FuzzyBits_COPYPROTECTIONE,
                                                 (char*)&G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE,
                                                 (char*)&G418_l_LastEvent22Time_COPYPROTECTIONE };
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT */
char* G429_apc_Graphic21Result_COPYPROTECTIONE[4] = { (char*)&G293_ai_FuzzyBits_COPYPROTECTIONE,
                                                 (char*)&G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE,
                                                 (char*)&G418_l_LastEvent22Time_COPYPROTECTIONE,
                                                 (char*)&G068_i_CheckLastEvent22Time_COPYPROTECTIONE }; /* Set to 0 by graphic #21 or by F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits */
#endif
#endif

overlay "player"

VOID F332_xxxx_INVENTORY_DrawIconToViewport(P689_i_IconIndex, P690_i_X, P691_i_Y)
int P689_i_IconIndex;
int P690_i_X;
int P691_i_Y;
{
        BOX_WORD L1015_s_Box;
        unsigned char* L1016_puc_Bitmap_Icon;


        L1016_puc_Bitmap_Icon = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(16, 16), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        L1015_s_Box.X2 = (L1015_s_Box.X1 = P690_i_X) + 15;
        L1015_s_Box.Y2 = (L1015_s_Box.Y1 = P691_i_Y) + 15;
        F036_aA19_OBJECT_ExtractIconFromBitmap(P689_i_IconIndex, L1016_puc_Bitmap_Icon);
        F020_aAA5_MAIN_BlitToViewport(L1016_puc_Bitmap_Icon, &L1015_s_Box, C008_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        F469_rzzz_MEMORY_FreeAtHeapTop((long)M75_BITMAP_BYTE_COUNT(16, 16));
}

VOID F333_xxxx_INVENTORY_OpenAndDrawChest(P692_T_Thing, P693_ps_Container, P694_B_PressingEye)
THING P692_T_Thing;
register CONTAINER* P693_ps_Container;
BOOLEAN P694_B_PressingEye;
{
        register int L1017_i_ChestSlotIndex;
        register THING L1018_T_Thing;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_14_FIX Useless code removed */
        register int L1020_i_Unreferenced; /* BUG0_00 Useless code */
        register int L1021_i_Unreferenced; /* BUG0_00 Useless code */
        char L1022_ac_Unreferenced[40]; /* BUG0_00 Useless code */
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_08_FIX */
        register int L1019_i_ThingCount;
#endif


#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_27_FIX Avoids opening a chest that is already open. In previous versions, this can occur when an object that has a modifier on a champion statistic (as applied by F299_xxxx_CHAMPION_ApplyObjectModifiersToStatistics) is placed in an appropriate slot or removed from that slot (for example placing Crown Of Nerra on the head or a Moonstone around the neck). This causes a refresh of the chest contents on screen where objects in the chest are reorganized so that there is no empty slot between them */
        if (G426_T_OpenChest == P692_T_Thing) {
                return;
        }
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_09_FIX If another chest is already open, close it before opening the specified one */
        if (G426_T_OpenChest != C0xFFFF_THING_NONE) {
                F334_akzz_INVENTORY_CloseChest();
        }
#endif
        G426_T_OpenChest = P692_T_Thing;
        if (!P694_B_PressingEye) {
                F038_AA07_OBJECT_DrawIconInSlotBox(C09_SLOT_BOX_INVENTORY_ACTION_HAND, C145_ICON_CONTAINER_CHEST_OPEN);
        }
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C025_GRAPHIC_PANEL_OPEN_CHEST), &G032_s_Graphic562_Box_Panel, C072_BYTE_WIDTH, C08_COLOR_RED);
        L1017_i_ChestSlotIndex = 0;
        L1018_T_Thing = P693_ps_Container->Slot;
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_08_FIX */
        L1019_i_ThingCount = 0;
#endif
        while (L1018_T_Thing != C0xFFFE_THING_ENDOFLIST) {
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_08_FIX Make sure that no more than the first 8 objects in a chest are drawn */
                if (++L1019_i_ThingCount > 8) {
                        break;
                }
#endif
                F038_AA07_OBJECT_DrawIconInSlotBox(L1017_i_ChestSlotIndex + C38_SLOT_BOX_CHEST_FIRST_SLOT, F033_aaaz_OBJECT_GetIconIndex(L1018_T_Thing));
                G425_aT_ChestSlots[L1017_i_ChestSlotIndex++] = L1018_T_Thing;
                L1018_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L1018_T_Thing);
        }
        while (L1017_i_ChestSlotIndex < 8) {
                F038_AA07_OBJECT_DrawIconInSlotBox(L1017_i_ChestSlotIndex + C38_SLOT_BOX_CHEST_FIRST_SLOT, CM1_ICON_NONE);
                G425_aT_ChestSlots[L1017_i_ChestSlotIndex++] = C0xFFFF_THING_NONE;
        }
}

VOID F334_akzz_INVENTORY_CloseChest()
{
        register THING L1023_T_Thing;
        register THING L1024_T_PreviousThing;
        register int L1025_i_ChestSlotIndex;
        register BOOLEAN L1026_B_ProcessFirstChestSlot;
        register CONTAINER* L1027_ps_Container;
        register GENERIC* L1028_ps_Generic;


        L1026_B_ProcessFirstChestSlot = TRUE;
        if (G426_T_OpenChest == C0xFFFF_THING_NONE) {
                return;
        }
        L1027_ps_Container = (CONTAINER*)F156_afzz_DUNGEON_GetThingData(G426_T_OpenChest);
        G426_T_OpenChest = C0xFFFF_THING_NONE;
        L1027_ps_Container->Slot = C0xFFFE_THING_ENDOFLIST;
        for(L1025_i_ChestSlotIndex = 0; L1025_i_ChestSlotIndex < 8; L1025_i_ChestSlotIndex++) {
                if ((L1023_T_Thing = G425_aT_ChestSlots[L1025_i_ChestSlotIndex]) != C0xFFFF_THING_NONE) {
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_09_FIX Make sure things are erased in chest slots */
                        G425_aT_ChestSlots[L1025_i_ChestSlotIndex] = C0xFFFF_THING_NONE;
#endif
                        if (L1026_B_ProcessFirstChestSlot) {
                                L1026_B_ProcessFirstChestSlot = FALSE;
                                L1028_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L1023_T_Thing);
                                L1028_ps_Generic->Next = C0xFFFE_THING_ENDOFLIST;
                                L1027_ps_Container->Slot = L1024_T_PreviousThing = L1023_T_Thing;
                        } else {
                                F163_amzz_DUNGEON_LinkThingToList(L1023_T_Thing, L1024_T_PreviousThing, CM1_MAPX_NOT_ON_A_SQUARE, 0);
                                L1024_T_PreviousThing = L1023_T_Thing;
                        }
                }
        }
}

VOID F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString(P695_pc_String)
char* P695_pc_String;
{
        register BOOLEAN L1029_B_SeveralLines;
        register char* L1030_pc_StringLine;
        register char* L1031_pc_String;
        char L1032_ac_String[128];


        if (P695_pc_String[0] == '\f') { /* Form feed */
                P695_pc_String++;
                G421_i_ObjectDescriptionTextX = 108;
                G422_i_ObjectDescriptionTextY = 59;
        }
        if (P695_pc_String[0]) {
                strcpy(L1032_ac_String, P695_pc_String);
                L1030_pc_StringLine = L1032_ac_String;
                L1029_B_SeveralLines = FALSE;
                while (*L1030_pc_StringLine) {
                        if (strlen(L1030_pc_StringLine) > 18) { /* If string is too long to fit on one line */
                                L1031_pc_String = &L1030_pc_StringLine[17];
                                while (*L1031_pc_String != ' ') { /* Go back to the last space character */
                                        L1031_pc_String--;
                                }
                                *L1031_pc_String = '\0'; /* and split the string there */
                                L1029_B_SeveralLines = TRUE;
                        }
                        F052_aaoz_TEXT_PrintToViewport(G421_i_ObjectDescriptionTextX, G422_i_ObjectDescriptionTextY, C13_COLOR_LIGHTEST_GRAY, L1030_pc_StringLine);
                        G422_i_ObjectDescriptionTextY += 7;
                        if (L1029_B_SeveralLines) {
                                L1029_B_SeveralLines = FALSE;
                                L1030_pc_StringLine = ++L1031_pc_String;
                        } else {
                                *L1030_pc_StringLine = '\0';
                        }
                }
        }
}

VOID F336_xxxx_INVENTORY_DrawPanel_BuildObjectAttributesString(P696_i_PotentialAttributesMask, P697_i_ActualAttributesMask, P698_ppc_AttributeStrings, P699_pc_StringDestination, P700_pc_StringPrefix, P701_pc_StringSuffix)
register int P696_i_PotentialAttributesMask;
register int P697_i_ActualAttributesMask;
register char** P698_ppc_AttributeStrings;
register char* P699_pc_StringDestination;
char* P700_pc_StringPrefix;
char* P701_pc_StringSuffix;
{
        register unsigned int L1033_ui_StringIndex;
        register int L1034_i_AttributeMask;
        unsigned int L1035_ui_IdenticalBitCount;


        L1035_ui_IdenticalBitCount = 0;
        for(L1033_ui_StringIndex = 0, L1034_i_AttributeMask = 1; L1033_ui_StringIndex < 16; L1033_ui_StringIndex++, L1034_i_AttributeMask <<= 1) {
                if (L1034_i_AttributeMask & P696_i_PotentialAttributesMask & P697_i_ActualAttributesMask) {
                        L1035_ui_IdenticalBitCount++;
                }
        }
        if (L1035_ui_IdenticalBitCount == 0) {
                *P699_pc_StringDestination = '\0';
                return;
        }
        strcpy(P699_pc_StringDestination, P700_pc_StringPrefix);
        for(L1033_ui_StringIndex = 0, L1034_i_AttributeMask = 1; L1033_ui_StringIndex < 16; L1033_ui_StringIndex++, L1034_i_AttributeMask <<= 1) {
                if (L1034_i_AttributeMask & P696_i_PotentialAttributesMask & P697_i_ActualAttributesMask) {
                        strcat(P699_pc_StringDestination, P698_ppc_AttributeStrings[L1033_ui_StringIndex]);
                        if (L1035_ui_IdenticalBitCount-- > 2) {
                                strcat(P699_pc_StringDestination, ", ");
                        } else {
                                if (L1035_ui_IdenticalBitCount == 1) {
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                        strcat(P699_pc_StringDestination, " AND ");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                        strcat(P699_pc_StringDestination, " UND ");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                        strcat(P699_pc_StringDestination, " ET ");
#endif
                                }
                        }
                }
        }
        strcat(P699_pc_StringDestination, P701_pc_StringSuffix);
}

VOID F337_akzz_INVENTORY_SetDungeonViewPalette()
{
        register int L1036_i_TotalLightAmount;
        register unsigned int L1037_ui_TorchLightAmountMultiplier;
        register int L1038_i_Counter;
        register int L1039_i_Multiple;
#define A1039_i_SlotIndex    L1039_i_Multiple
#define A1039_i_PaletteIndex L1039_i_Multiple
#define A1039_i_Counter      L1039_i_Multiple
        register int* L1040_pi_Multiple;
#define A1040_pi_TorchLightPower L1040_pi_Multiple
#define A1040_pi_LightAmount     L1040_pi_Multiple
        register int* L1041_pi_TorchLightPower;
        WEAPON* L1042_ps_Weapon;
        CHAMPION* L1043_ps_Champion;
        unsigned int L1044_ui_Multiple;
#define A1044_T_Thing            L1044_ui_Multiple
#define A1044_ui_TorchLightPower L1044_ui_Multiple
        int L1045_ai_TorchesLightPower[8];


        if (G269_ps_CurrentMap->C.Difficulty == 0) {
                G304_i_DungeonViewPaletteIndex = 0; /* Brightest color palette index */
        } else {
                /* Get torch light power from both hands of each champion in the party */
                L1038_i_Counter = 4; /* BUG0_01 Coding error without consequence. The hands of four champions are inspected even if there are less champions in the party. No consequence as the data in unused champions is set to 0 and F032_aaaY_OBJECT_GetType then returns -1 */
                L1043_ps_Champion = G407_s_Party.Champions;
                A1040_pi_TorchLightPower = L1045_ai_TorchesLightPower;
                while (L1038_i_Counter--) {
                        A1039_i_SlotIndex = C01_SLOT_ACTION_HAND + 1;
                        while (A1039_i_SlotIndex--) {
                                if ((F032_aaaY_OBJECT_GetType(A1044_T_Thing = L1043_ps_Champion->Slots[A1039_i_SlotIndex]) >= C004_ICON_WEAPON_TORCH_UNLIT) &&
                                    (F032_aaaY_OBJECT_GetType(A1044_T_Thing = L1043_ps_Champion->Slots[A1039_i_SlotIndex]) <= C007_ICON_WEAPON_TORCH_LIT)) {
                                        L1042_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(A1044_T_Thing);
                                        *A1040_pi_TorchLightPower = L1042_ps_Weapon->ChargeCount;
                                } else {
                                        *A1040_pi_TorchLightPower = 0;
                                }
                                A1040_pi_TorchLightPower++;
                        }
                        L1043_ps_Champion++;
                }
                /* Sort torch light power values so that the four highest values are in the first four entries in the array L1045_ai_TorchesLightPower in decreasing order. The last four entries contain the smallest values but they are not sorted */
                A1040_pi_TorchLightPower = L1045_ai_TorchesLightPower;
                for(A1039_i_Counter = 0; A1039_i_Counter != 4; A1039_i_Counter++) {
                        L1038_i_Counter = 7 - A1039_i_Counter;
                        L1041_pi_TorchLightPower = &L1045_ai_TorchesLightPower[A1039_i_Counter + 1];
                        while (L1038_i_Counter--) {
                                if (*L1041_pi_TorchLightPower > *A1040_pi_TorchLightPower) {
                                        A1044_ui_TorchLightPower = *L1041_pi_TorchLightPower;
                                        *L1041_pi_TorchLightPower = *A1040_pi_TorchLightPower;
                                        *A1040_pi_TorchLightPower = A1044_ui_TorchLightPower;
                                }
                                L1041_pi_TorchLightPower++;
                        }
                        A1040_pi_TorchLightPower++;
                }
                /* Get total light amount provided by the four torches with the highest light power values and by the fifth torch in the array which may be any one of the four torches with the smallest ligh power values */
                L1037_ui_TorchLightAmountMultiplier = 6;
                A1039_i_Counter = 5;
                L1036_i_TotalLightAmount = 0;
                A1040_pi_TorchLightPower = L1045_ai_TorchesLightPower;
                while (A1039_i_Counter--) {
                        if (*A1040_pi_TorchLightPower) {
                                L1036_i_TotalLightAmount += (G039_ai_Graphic562_LightPowerToLightAmount[*A1040_pi_TorchLightPower] << L1037_ui_TorchLightAmountMultiplier) >> 6;
                                L1037_ui_TorchLightAmountMultiplier = F025_aatz_MAIN_GetMaximumValue(0, L1037_ui_TorchLightAmountMultiplier - 1);
                        }
                        A1040_pi_TorchLightPower++;
                }
                L1036_i_TotalLightAmount += G407_s_Party.MagicalLightAmount;
                /* Select palette corresponding to the total light amount */
                A1040_pi_LightAmount = G040_ai_Graphic562_PaletteIndexToLightAmount;
                if (L1036_i_TotalLightAmount > 0) {
                        A1039_i_PaletteIndex = 0; /* Brightest color palette index */
                        while (*A1040_pi_LightAmount++ > L1036_i_TotalLightAmount) {
                                A1039_i_PaletteIndex++;
                        }
                } else {
                        A1039_i_PaletteIndex = 5; /* Darkest color palette index */
                }
                G304_i_DungeonViewPaletteIndex = A1039_i_PaletteIndex;
        }
        G342_B_RefreshDungeonViewPaletteRequested = TRUE;
}

VOID F338_atzz_INVENTORY_DecreaseTorchesLightPower_COPYPROTECTIONE()
{
        register int L1046_i_ChampionCount;
        register int L1047_i_SlotIndex;
        register BOOLEAN L1048_B_TorchChargeCountChanged;
        register int L1049_i_IconIndex;
        register CHAMPION* L1050_ps_Champion;
        register WEAPON* L1051_ps_Weapon;


        L1048_B_TorchChargeCountChanged = FALSE;
        L1046_i_ChampionCount = G305_ui_PartyChampionCount;
        if (G299_ui_CandidateChampionOrdinal) {
                L1046_i_ChampionCount--;
        }
        L1050_ps_Champion = G407_s_Party.Champions;
        while (L1046_i_ChampionCount--) {
                L1047_i_SlotIndex = C01_SLOT_ACTION_HAND + 1;
                while (L1047_i_SlotIndex--) {
                        L1049_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L1050_ps_Champion->Slots[L1047_i_SlotIndex]);
                        if ((L1049_i_IconIndex >= C004_ICON_WEAPON_TORCH_UNLIT) && (L1049_i_IconIndex <= C007_ICON_WEAPON_TORCH_LIT)) {
                                L1051_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(L1050_ps_Champion->Slots[L1047_i_SlotIndex]);
                                if (L1051_ps_Weapon->ChargeCount) {
                                        if ((--L1051_ps_Weapon->ChargeCount) == 0) {
                                                L1051_ps_Weapon->DoNotDiscard = FALSE;
                                        }
                                        L1048_B_TorchChargeCountChanged = TRUE;
                                }
                        }
                }
                L1050_ps_Champion++;
        }
#ifndef NOCOPYPROTECTION
        if (G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE != C00136_TRUE) {
                F137_pzzz_COPYPROTECTIONEF_PatchFunctionWithHiddenCodeLauncher(&F331_auzz_CHAMPION_ApplyTimeEffects_COPYPROTECTIONF, &F489_ayzz_MEMORY_GetNativeBitmapOrGraphic, C021_GRAPHIC_CHECK_FUZZY_BITS_SECTOR_7, &G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE[-94] + 94, &G429_apc_Graphic21Result_COPYPROTECTIONE, G368_apc_CodePatches_COPYPROTECTIONE, 6);
                G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE = C00136_TRUE;
        }
#endif
        if (L1048_B_TorchChargeCountChanged) {
                F337_akzz_INVENTORY_SetDungeonViewPalette();
                F296_aizz_CHAMPION_DrawChangedObjectIcons();
        }
}

VOID F339_xxxx_INVENTORY_DrawPanel_ArrowOrEye(P702_B_PressingEye)
BOOLEAN P702_B_PressingEye;
{
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(P702_B_PressingEye ? C019_GRAPHIC_EYE_FOR_OBJECT_DESCRIPTION : C018_GRAPHIC_ARROW_FOR_CHEST_CONTENT), &G033_s_Graphic562_Box_ArrowOrEye, C008_BYTE_WIDTH, C08_COLOR_RED);
}

VOID F340_xxxx_INVENTORY_DrawPanel_ScrollTextLine(P703_i_Y, P704_pc_String)
int P703_i_Y;
register char* P704_pc_String;
{
        register char* L1052_pc_Character;


        L1052_pc_Character = P704_pc_String;
        while (*L1052_pc_Character) {
                if ((*L1052_pc_Character >= 'A') && (*L1052_pc_Character <= 'Z')) {
                        *L1052_pc_Character++ -= 64; /* Do not use default characters in font but rather special characters for scrolls */
                        continue;
                }
#ifdef C24_COMPILE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE5_03_IMPROVEMENT More characters are replaced by variants for scroll texts. This only includes a single quote character which is also added to the font graphic */
                if (*L1052_pc_Character >= '{') { /* '{' is ASCII 123 */
                        *L1052_pc_Character++ -= 96;
                        continue;
                }
#endif
                L1052_pc_Character++;
        }
        F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 162 - ((6 * strlen(P704_pc_String)) >> 1), P703_i_Y, C00_COLOR_BLACK, C15_COLOR_WHITE, P704_pc_String); /* Center text horizontally */
}

VOID F341_xxxx_INVENTORY_DrawPanel_Scroll(P705_ps_Scroll)
SCROLL* P705_ps_Scroll;
{
        register int L1053_i_Multiple;
#define A1053_i_LineCount L1053_i_Multiple
#define A1053_i_Y         L1053_i_Multiple
        register char* L1054_pc_Character;
        register char* L1055_pc_Character;
        char L1056_ac_StringFirstLine[260];


        F168_ajzz_DUNGEON_DecodeText(L1056_ac_StringFirstLine, P705_ps_Scroll->TextThingIndex, C2_TEXT_TYPE_SCROLL | MASK0x8000_DECODE_EVEN_IF_INVISIBLE);
        L1055_pc_Character = L1056_ac_StringFirstLine;
        while (*L1055_pc_Character && (*L1055_pc_Character != '\n')) { /* New line */
                L1055_pc_Character++;
        }
        *L1055_pc_Character = '\0'; /* Mark the end of the first line */
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C023_GRAPHIC_PANEL_OPEN_SCROLL), &G032_s_Graphic562_Box_Panel, C072_BYTE_WIDTH, C08_COLOR_RED);
        A1053_i_LineCount = 1;
        L1055_pc_Character++;
        L1054_pc_Character = (char*)L1055_pc_Character; /* First character of second line */
        while (*L1054_pc_Character) { /* BUG0_47 Graphical glitch when you open a scroll. If there is a single line of text in a scroll (with no carriage return) then L1054_pc_Character points to undefined data. This may result in a graphical glitch and also corrupt other memory. This is not an issue in the original dungeons where all scrolls contain at least one carriage return character */
                if (*L1054_pc_Character == '\n') { /* New line */
                        A1053_i_LineCount++;
                }
                L1054_pc_Character++;
        }
        if (*(L1054_pc_Character - 1) != '\n') { /* New line */
                A1053_i_LineCount++;
        } else {
                if (*(L1054_pc_Character - 2) == '\n') { /* New line */
                        A1053_i_LineCount--;
                }
        }
        A1053_i_Y = 92 - ((7 * A1053_i_LineCount) / 2); /* Center text vertically */
        F340_xxxx_INVENTORY_DrawPanel_ScrollTextLine(A1053_i_Y, L1056_ac_StringFirstLine);
        L1054_pc_Character = L1055_pc_Character;
        while (*L1054_pc_Character) {
                A1053_i_Y += 7;
                while (*L1055_pc_Character && (*L1055_pc_Character != '\n')) { /* New line */
                        L1055_pc_Character++;
                }
                if (!(*L1055_pc_Character)) {
                        L1055_pc_Character[1] = '\0';
                }
                *L1055_pc_Character++ = '\0';
                F340_xxxx_INVENTORY_DrawPanel_ScrollTextLine(A1053_i_Y, L1054_pc_Character);
                L1054_pc_Character = L1055_pc_Character;
        }
}

VOID F342_xxxx_INVENTORY_DrawPanel_Object(P706_T_Thing, P707_B_PressingEye)
THING P706_T_Thing;
BOOLEAN P707_B_PressingEye;
{
        register unsigned int L1057_ui_Weight;
        register unsigned int L1058_ui_IconIndex;
        register int L1059_i_PotentialAttributesMask;
        register int L1060_i_ActualAttributesMask;
        register char* L1061_pc_DescriptionString;
        register JUNK* L1062_ps_Junk;
        char L1063_ac_Unreferenced[48]; /* BUG0_00 Useless code */
        char* L1064_apc_AttributeStrings[4];
        char* L1065_pc_RightParenthesis = ")";
        char* L1066_pc_LeftParenthesis = "(";
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
        static char* G430_apc_DirectionNames[4] = { "NORTH", "EAST", "SOUTH", "WEST" };
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
        static char* G430_apc_DirectionNames[4] = { "NORDEN", "OSTEN", "SUEDEN", "WESTEN" };
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
        static char* G430_apc_DirectionNames[4] = { "AU NORD", "A L'EST", "AU SUD", "A L'OUEST" };
#endif
        int L1067_i_ThingType;
        char L1068_ac_String[40];


#ifdef C26_COMPILE_CSB20EN /* CHANGE7_27_FIX The chest is closed and reopened in F333_xxxx_INVENTORY_OpenAndDrawChest only if pressing the eye or mouth and no more when placing an object that has a modifier.
CHANGE8_09_FIX Make sure the chest is always closed. This reintroduces BUG0_48 in CSB21EN */
        if (G331_B_PressingEye || G333_B_PressingMouth) {
#endif
                F334_akzz_INVENTORY_CloseChest(); /* BUG0_48 The contents of a chest are reorganized when an object with a statistic modifier is placed or removed on a champion */
#ifdef C26_COMPILE_CSB20EN /* CHANGE7_27_FIX CHANGE8_09_FIX */
        }
#endif
        L1062_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(P706_T_Thing);
        F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString("\f"); /* Form Feed */
        L1067_i_ThingType = M12_TYPE(P706_T_Thing);
        if (L1067_i_ThingType == C07_THING_TYPE_SCROLL) {
                F341_xxxx_INVENTORY_DrawPanel_Scroll(L1062_ps_Junk);
        } else {
                if (L1067_i_ThingType == C09_THING_TYPE_CONTAINER) {
                        F333_xxxx_INVENTORY_OpenAndDrawChest(P706_T_Thing, L1062_ps_Junk, P707_B_PressingEye);
                } else {
                        L1058_ui_IconIndex = F033_aaaz_OBJECT_GetIconIndex(P706_T_Thing);
                        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C020_GRAPHIC_PANEL_EMPTY), &G032_s_Graphic562_Box_Panel, C072_BYTE_WIDTH, C08_COLOR_RED);
                        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C029_GRAPHIC_OBJECT_DESCRIPTION_CIRCLE), &G034_s_Graphic562_Box_ObjectDescriptionCircle, C016_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
                        if (L1058_ui_IconIndex == C147_ICON_JUNK_CHAMPION_BONES) {
#ifdef C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN /* CHANGE5_00_LOCALIZATION Translation to French language */
                                strcpy(L1068_ac_String, G407_s_Party.Champions[L1062_ps_Junk->ChargeCount].Name);
                                strcat(L1068_ac_String, " ");
                                strcat(L1068_ac_String, G352_apc_ObjectNames[L1058_ui_IconIndex]);
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                strcat(L1068_ac_String, G352_apc_ObjectNames[L1058_ui_IconIndex]); /* BUG5_00 When looking at a champion's dead bones by pressing the eye, the name in the panel only contains the champion name and the object name is missing. This call to strcat and the call to strcpy below were swapped while translating the game to French in order to change the order of words in the final string. However, only the strings should have been swapped and not the function calls */
                                strcat(L1068_ac_String, " ");
                                strcpy(L1068_ac_String, G407_s_Party.Champions[L1062_ps_Junk->ChargeCount].Name);
#endif
                                L1061_pc_DescriptionString = L1068_ac_String;
                        } else {
                                if ((L1067_i_ThingType == C08_THING_TYPE_POTION) && (L1058_ui_IconIndex != C163_ICON_POTION_WATER_FLASK) && (F303_AA09_CHAMPION_GetSkillLevel(M01_ORDINAL_TO_INDEX(G423_i_InventoryChampionOrdinal), C02_SKILL_PRIEST) > 1)) { /* BUG0_49 When examining an 'Empty Flask' the description string shows an undesired symbol. The code contains an exception not to draw the power for 'Water Flask' potions C195_ICON_POTION_EMPTY_FLASK but a similar exception is missing for 'Empty Flask' potions. These are processed like all other potions so that the power symbol is drawn: '_' for an 'Empty Flask' with Power / 40 = 0, or the power symbol of the last potion contained in the Flask: after drinking a potion, the potion type is set to Empty Flask but the potion power is not reset in F349_dzzz_INVENTORY_ProcessCommand70_ClickOnMouth */
                                        L1068_ac_String[0] = '_' + ((POTION*)L1062_ps_Junk)->Power / 40; /* Character '_' precedes the first Symbol in the font. Potions are always created with a minimum power of 40 in F412_xxxx_MENUS_GetChampionSpellCastResult */
                                        L1068_ac_String[1] = ' ';
                                        L1068_ac_String[2] = '\0';
                                        strcat(L1068_ac_String, G352_apc_ObjectNames[L1058_ui_IconIndex]);
                                        L1061_pc_DescriptionString = L1068_ac_String;
                                } else {
                                        L1061_pc_DescriptionString = (char*)G352_apc_ObjectNames[L1058_ui_IconIndex];
                                }
                        }
                        F052_aaoz_TEXT_PrintToViewport(134, 68, C13_COLOR_LIGHTEST_GRAY, L1061_pc_DescriptionString);
                        F332_xxxx_INVENTORY_DrawIconToViewport(L1058_ui_IconIndex, 111, 59);
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1064_apc_AttributeStrings[0] = "CONSUMABLE";
                        L1064_apc_AttributeStrings[1] = "POISONED";
                        L1064_apc_AttributeStrings[2] = "BROKEN";
                        L1064_apc_AttributeStrings[3] = "CURSED";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1064_apc_AttributeStrings[0] = "ESSBAR";
                        L1064_apc_AttributeStrings[1] = "VERGIFTET";
                        L1064_apc_AttributeStrings[2] = "DEFEKT";
                        L1064_apc_AttributeStrings[3] = "VERFLUCHT";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        L1064_apc_AttributeStrings[0] = "COMESTIBLE";
                        L1064_apc_AttributeStrings[1] = "EMPOISONNE";
                        L1064_apc_AttributeStrings[2] = "BRISE";
                        L1064_apc_AttributeStrings[3] = "MAUDIT";
#endif
                        G422_i_ObjectDescriptionTextY = 87;
                        switch (L1067_i_ThingType) {
                                case C05_THING_TYPE_WEAPON:
                                        L1059_i_PotentialAttributesMask = MASK0x0008_DESCRIPTION_CURSED | MASK0x0002_DESCRIPTION_POISONED | MASK0x0004_DESCRIPTION_BROKEN;
                                        L1060_i_ActualAttributesMask = (((WEAPON*)L1062_ps_Junk)->Cursed << 3) | (((WEAPON*)L1062_ps_Junk)->Poisoned << 1) | (((WEAPON*)L1062_ps_Junk)->Broken << 2);
                                        if ((L1058_ui_IconIndex >= C004_ICON_WEAPON_TORCH_UNLIT) && (L1058_ui_IconIndex <= C007_ICON_WEAPON_TORCH_LIT) && (((WEAPON*)L1062_ps_Junk)->ChargeCount == 0)) {
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString("(BURNT OUT)");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString("(AUSGEBRANNT)");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                                F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString("(CONSUME)");
#endif
                                        }
                                        break;
                                case C06_THING_TYPE_ARMOUR:
                                        L1059_i_PotentialAttributesMask = MASK0x0008_DESCRIPTION_CURSED | MASK0x0004_DESCRIPTION_BROKEN;
                                        L1060_i_ActualAttributesMask = (((ARMOUR*)L1062_ps_Junk)->Cursed << 3) | (((ARMOUR*)L1062_ps_Junk)->Broken << 2);
                                        break;
                                case C08_THING_TYPE_POTION:
                                        L1059_i_PotentialAttributesMask = MASK0x0001_DESCRIPTION_CONSUMABLE;
                                        L1060_i_ActualAttributesMask = G237_as_Graphic559_ObjectInfo[C002_OBJECT_INFO_INDEX_FIRST_POTION + ((POTION*)L1062_ps_Junk)->Type].AllowedSlots;
                                        break;
                                case C10_THING_TYPE_JUNK:
                                        if ((L1058_ui_IconIndex >= C008_ICON_JUNK_WATER) && (L1058_ui_IconIndex <= C009_ICON_JUNK_WATERSKIN)) {
                                                L1059_i_PotentialAttributesMask = 0;
                                                switch (L1062_ps_Junk->ChargeCount) {
                                                        case 0:
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(EMPTY)";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(LEER)";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                                                L1061_pc_DescriptionString = "(VIDE)";
#endif
                                                                break;
                                                        case 1:
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(ALMOST EMPTY)";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(FAST LEER)";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                                                L1061_pc_DescriptionString = "(PRESQUE VIDE)";
#endif
                                                                break;
                                                        case 2:
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(ALMOST FULL)";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(FAST VOLL)";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                                                L1061_pc_DescriptionString = "(PRESQUE PLEINE)";
#endif
                                                                break;
                                                        case 3:
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(FULL)";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                                L1061_pc_DescriptionString = "(VOLL)";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                                                L1061_pc_DescriptionString = "(PLEINE)";
#endif
                                                }
                                                F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString(L1061_pc_DescriptionString);
                                        } else {
                                                if ((L1058_ui_IconIndex >= C000_ICON_JUNK_COMPASS_NORTH) && (L1058_ui_IconIndex <= C003_ICON_JUNK_COMPASS_WEST)) {
                                                        L1059_i_PotentialAttributesMask = 0;
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                        strcpy(L1068_ac_String, "PARTY FACING ");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                                        strcpy(L1068_ac_String, "GRUPPE BLICKT NACH ");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                                        strcpy(L1068_ac_String, "GROUPE FACE ");
#endif
                                                        strcat(L1068_ac_String, G430_apc_DirectionNames[L1058_ui_IconIndex]);
                                                        F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString(L1068_ac_String);
                                                } else {
                                                        L1059_i_PotentialAttributesMask = MASK0x0001_DESCRIPTION_CONSUMABLE;
                                                        L1060_i_ActualAttributesMask = G237_as_Graphic559_ObjectInfo[C127_OBJECT_INFO_INDEX_FIRST_JUNK + L1062_ps_Junk->Type].AllowedSlots;
                                                }
                                        }
                        }
                        if (L1059_i_PotentialAttributesMask) {
                                F336_xxxx_INVENTORY_DrawPanel_BuildObjectAttributesString(L1059_i_PotentialAttributesMask, L1060_i_ActualAttributesMask, L1064_apc_AttributeStrings, L1068_ac_String, L1066_pc_LeftParenthesis, L1065_pc_RightParenthesis);
                                F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString(L1068_ac_String);
                        }
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        strcpy(L1068_ac_String, "WEIGHS ");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        strcpy(L1068_ac_String, "WIEGT ");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        strcpy(L1068_ac_String, "PESE ");
#endif
                        L1057_ui_Weight = F140_yzzz_DUNGEON_GetObjectWeight(P706_T_Thing);
                        strcat(L1068_ac_String, F288_xxxx_CHAMPION_GetStringFromInteger(L1057_ui_Weight / 10, FALSE, 3));
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        strcat(L1068_ac_String, ".");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        strcat(L1068_ac_String, ",");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        strcat(L1068_ac_String, "KG,");
#endif
                        L1057_ui_Weight -= (L1057_ui_Weight / 10) * 10;
                        strcat(L1068_ac_String, F288_xxxx_CHAMPION_GetStringFromInteger(L1057_ui_Weight, FALSE, 1));
#ifdef C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN /* CHANGE5_00_LOCALIZATION Translation to French language */
                        strcat(L1068_ac_String, " KG.");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        strcat(L1068_ac_String, ".");
#endif
                        F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString(L1068_ac_String);
                }
        }
        F339_xxxx_INVENTORY_DrawPanel_ArrowOrEye(P707_B_PressingEye);
}

VOID F343_xxxx_INVENTORY_DrawPanel_HorizontalBar(P708_i_X, P709_i_Y, P710_i_PixelWidth, P711_i_Color)
int P708_i_X;
int P709_i_Y;
int P710_i_PixelWidth;
int P711_i_Color;
{
        BOX_WORD L1069_s_Box;


        L1069_s_Box.X2 = (L1069_s_Box.X1 = P708_i_X) + P710_i_PixelWidth;
        L1069_s_Box.Y2 = (L1069_s_Box.Y1 = P709_i_Y) + 6;
        G578_B_UseByteBoxCoordinates = FALSE;
        F135_xzzz_VIDEO_FillBox(G296_puc_Bitmap_Viewport, &L1069_s_Box, P711_i_Color, C112_BYTE_WIDTH_VIEWPORT);
}

VOID F344_xxxx_INVENTORY_DrawPanel_FoodOrWaterBar(P712_i_Amount, P713_i_Y, P714_i_Color)
register int P712_i_Amount;
int P713_i_Y;
int P714_i_Color;
{
        register int L1070_i_Color;
        register int L1071_i_PixelWidth;


        if (P712_i_Amount < -512) {
                L1070_i_Color = C08_COLOR_RED;
        } else {
                if (P712_i_Amount < 0) {
                        L1070_i_Color = C11_COLOR_YELLOW;
                } else {
                        L1070_i_Color = P714_i_Color;
                }
        }
        L1071_i_PixelWidth = P712_i_Amount + 1024;
        if (L1071_i_PixelWidth == 3072) {
                L1071_i_PixelWidth = 3071;
        }
        L1071_i_PixelWidth >>= 5;
        F343_xxxx_INVENTORY_DrawPanel_HorizontalBar(115, P713_i_Y + 2, L1071_i_PixelWidth, C00_COLOR_BLACK);
        F343_xxxx_INVENTORY_DrawPanel_HorizontalBar(113, P713_i_Y, L1071_i_PixelWidth, L1070_i_Color);
}

VOID F345_xxxx_INVENTORY_DrawPanel_FoodWaterPoisoned()
{
        register int L1072_i_Unreferenced; /* BUG0_00 Useless code */
        register int L1073_i_Unreferenced; /* BUG0_00 Useless code */
        register CHAMPION* L1074_ps_Champion;


        L1074_ps_Champion = &G407_s_Party.Champions[M01_ORDINAL_TO_INDEX(G423_i_InventoryChampionOrdinal)];
        F334_akzz_INVENTORY_CloseChest();
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C020_GRAPHIC_PANEL_EMPTY), &G032_s_Graphic562_Box_Panel, C072_BYTE_WIDTH, C08_COLOR_RED);
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C030_GRAPHIC_FOOD_LABEL), &G035_s_Graphic562_Box_Food, C024_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C031_GRAPHIC_WATER_LABEL), &G036_s_Graphic562_Box_Water, C024_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C030_GRAPHIC_FOOD_LABEL), &G035_s_Graphic562_Box_Food, C032_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C031_GRAPHIC_WATER_LABEL), &G036_s_Graphic562_Box_Water, C032_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C030_GRAPHIC_FOOD_LABEL), &G035_s_Graphic562_Box_Food, C048_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C031_GRAPHIC_WATER_LABEL), &G036_s_Graphic562_Box_Water, C024_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
#endif
        if (L1074_ps_Champion->PoisonEventCount) {
                F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C032_GRAPHIC_POISONED_LABEL), &G037_s_Graphic562_Box_Poisoned, C048_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
        }
        F344_xxxx_INVENTORY_DrawPanel_FoodOrWaterBar(L1074_ps_Champion->Food, 69, C05_COLOR_LIGHT_BROWN);
        F344_xxxx_INVENTORY_DrawPanel_FoodOrWaterBar(L1074_ps_Champion->Water, 92, C14_COLOR_BLUE);
}

VOID F346_xxxx_INVENTORY_DrawPanel_ResurrectReincarnate()
{
        G424_i_PanelContent = C5_PANEL_RESURRECT_REINCARNATE;
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C040_GRAPHIC_PANEL_RESURRECT_REINCARNATE), &G032_s_Graphic562_Box_Panel, C072_BYTE_WIDTH, C06_COLOR_DARK_GREEN);
}

VOID F347_xxxx_INVENTORY_DrawPanel()
{
        register THING L1075_T_Thing;
        register GENERIC* L1076_ps_Generic;


#ifdef C28_COMPILE_CSB21EN /* CHANGE8_09_FIX Make sure the chest is always closed */
        F334_akzz_INVENTORY_CloseChest();
#endif
        if (G299_ui_CandidateChampionOrdinal) {
                F346_xxxx_INVENTORY_DrawPanel_ResurrectReincarnate();
                return;
        }
        L1075_T_Thing = G407_s_Party.Champions[M01_ORDINAL_TO_INDEX(G423_i_InventoryChampionOrdinal)].Slots[C01_SLOT_ACTION_HAND];
        L1076_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L1075_T_Thing);
        G424_i_PanelContent = C0_PANEL_FOOD_WATER_POISONED;
        switch (M12_TYPE(L1075_T_Thing)) {
                case C09_THING_TYPE_CONTAINER:
                        G424_i_PanelContent = C4_PANEL_CHEST;
                        break;
                case C07_THING_TYPE_SCROLL:
                        G424_i_PanelContent = C2_PANEL_SCROLL;
                        break;
                default:
                        L1075_T_Thing = C0xFFFF_THING_NONE;
        }
        if (L1075_T_Thing == C0xFFFF_THING_NONE) {
                F345_xxxx_INVENTORY_DrawPanel_FoodWaterPoisoned();
                return;
        }
        F342_xxxx_INVENTORY_DrawPanel_Object(L1075_T_Thing, FALSE);
}

VOID F348_xxxx_INVENTORY_AdjustStatisticCurrentValue(P715_ps_Champion, P716_i_StatisticIndex, P717_i_ValueDelta)
register CHAMPION* P715_ps_Champion;
register int P716_i_StatisticIndex;
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
int P717_i_ValueDelta;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
register int P717_i_ValueDelta;
#endif
{
        register int L1077_i_Multiple;
#define A1077_i_CurrentValue L1077_i_Multiple
#define A1077_i_Delta        L1077_i_Multiple


        if (P717_i_ValueDelta >= 0) {
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_14_IMPROVEMENT Halve delta if current value is above 120 */
                if ((A1077_i_CurrentValue = P715_ps_Champion->Statistics[P716_i_StatisticIndex][C1_CURRENT]) > 120) {
                        P717_i_ValueDelta >>= 1;
#ifdef C13_COMPILE_DM11EN /* CHANGE3_13_IMPROVEMENT Halve again delta if current value is above 180 */
                        if (A1077_i_CurrentValue > 180) {
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_13_IMPROVEMENT Halve again delta if current value is above 150 (maximum value is now 170 so the 180 threshold is too high) */
                        if (A1077_i_CurrentValue > 150) {
#endif
                                P717_i_ValueDelta >>= 1;
                        }
                        P717_i_ValueDelta++;
                }
#endif
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_14_IMPROVEMENT Maximum value is 255 */
                A1077_i_Delta = F024_aatz_MAIN_GetMinimumValue(P717_i_ValueDelta, 255 - P715_ps_Champion->Statistics[P716_i_StatisticIndex][C1_CURRENT]);
#endif
#ifdef C13_COMPILE_DM11EN /* CHANGE2_14_IMPROVEMENT Maximum value is 250 */
                A1077_i_Delta = F024_aatz_MAIN_GetMinimumValue(P717_i_ValueDelta, 250 - A1077_i_CurrentValue);
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_13_IMPROVEMENT Maximum value is 170 */
                A1077_i_Delta = F024_aatz_MAIN_GetMinimumValue(P717_i_ValueDelta, 170 - A1077_i_CurrentValue);
#endif
        } else { /* BUG0_00 Useless code. The function is always called with P717_i_ValueDelta having a positive value */
                A1077_i_Delta = F025_aatz_MAIN_GetMaximumValue(P717_i_ValueDelta, P715_ps_Champion->Statistics[P716_i_StatisticIndex][C2_MINIMUM] - P715_ps_Champion->Statistics[P716_i_StatisticIndex][C1_CURRENT]);
        }
        P715_ps_Champion->Statistics[P716_i_StatisticIndex][C1_CURRENT] += A1077_i_Delta;
}

VOID F349_dzzz_INVENTORY_ProcessCommand70_ClickOnMouth()
{
        register THING L1078_T_Thing;
        register unsigned int L1079_ui_IconIndex;
        register int L1080_i_ChampionIndex;
        register BOOLEAN L1081_B_RemoveObjectFromLeaderHand;
        register JUNK* L1082_ps_Junk;
        register CHAMPION* L1083_ps_Champion;
        EVENT L1084_s_Event;
        unsigned int L1085_ui_Multiple;
#define A1085_ui_PotionPower         L1085_ui_Multiple
#define A1085_ui_AdjustedPotionPower L1085_ui_Multiple
#define A1085_ui_Counter             L1085_ui_Multiple
        unsigned int L1086_ui_Counter;
        int L1087_i_Wounds;
        unsigned int L1088_ui_Multiple;
#define A1088_ui_ThingType               L1088_ui_Multiple
#define A1088_ui_Mana                    L1088_ui_Multiple
#define A1088_ui_HealWoundIterationCount L1088_ui_Multiple
        unsigned int L1089_ui_Weight;


        if (G415_B_LeaderEmptyHanded) {
                if (G424_i_PanelContent == C0_PANEL_FOOD_WATER_POISONED) {
                        return;
                }
                G597_B_IgnoreMouseMovements = TRUE;
                G333_B_PressingMouth = TRUE;
                if (!M07_GET(G588_i_MouseButtonsStatus, MASK0x0002_MOUSE_LEFT_BUTTON)) {
                        G597_B_IgnoreMouseMovements = FALSE;
                        G333_B_PressingMouth = FALSE;
                        G334_B_StopPressingMouth = FALSE;
                } else {
                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                        G587_i_HideMousePointerRequestCount = 1;
                        F345_xxxx_INVENTORY_DrawPanel_FoodWaterPoisoned();
                        F097_lzzz_DUNGEONVIEW_DrawViewport(C0_VIEWPORT_NOT_DUNGEON_VIEW);
                }
        } else {
                if (G299_ui_CandidateChampionOrdinal) {
                        return;
                }
                if (!M07_GET(G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(L1078_T_Thing = G414_T_LeaderHandObject)].AllowedSlots, MASK0x0001_MOUTH)) {
                        return;
                }
                L1079_ui_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L1078_T_Thing);
                A1088_ui_ThingType = M12_TYPE(L1078_T_Thing);
                L1089_ui_Weight = F140_yzzz_DUNGEON_GetObjectWeight(L1078_T_Thing);
                L1083_ps_Champion = &G407_s_Party.Champions[L1080_i_ChampionIndex = M01_ORDINAL_TO_INDEX(G423_i_InventoryChampionOrdinal)];
                L1082_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L1078_T_Thing);
                if ((L1079_ui_IconIndex >= C008_ICON_JUNK_WATER) && (L1079_ui_IconIndex <= C009_ICON_JUNK_WATERSKIN)) {
                        if (!(L1082_ps_Junk->ChargeCount)) {
                                return;
                        }
                        L1083_ps_Champion->Water = F024_aatz_MAIN_GetMinimumValue(L1083_ps_Champion->Water + 800, 2048);
                        L1082_ps_Junk->ChargeCount--;
                        L1081_B_RemoveObjectFromLeaderHand = FALSE;
                } else {
                        if (A1088_ui_ThingType == C08_THING_TYPE_POTION) {
                                L1081_B_RemoveObjectFromLeaderHand = FALSE;
                        } else {
                                L1082_ps_Junk->Next = C0xFFFF_THING_NONE;
                                L1081_B_RemoveObjectFromLeaderHand = TRUE;
                        }
                }
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                if (L1081_B_RemoveObjectFromLeaderHand) {
                        F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
                }
                if (A1088_ui_ThingType == C08_THING_TYPE_POTION) {
                        A1085_ui_PotionPower = ((POTION*)L1082_ps_Junk)->Power;
                        L1086_ui_Counter = ((511 - A1085_ui_PotionPower) / (32 + (A1085_ui_PotionPower + 1) / 8)) >> 1;
                        A1085_ui_AdjustedPotionPower = (A1085_ui_PotionPower / 25) + 8; /* Value between 8 and 18 */
                        switch (((POTION*)L1082_ps_Junk)->Type) {
                                case C06_POTION_ROS_POTION:
                                        F348_xxxx_INVENTORY_AdjustStatisticCurrentValue(L1083_ps_Champion, C2_STATISTIC_DEXTERITY, A1085_ui_AdjustedPotionPower);
                                        break;
                                case C07_POTION_KU_POTION:
                                        F348_xxxx_INVENTORY_AdjustStatisticCurrentValue(L1083_ps_Champion, C1_STATISTIC_STRENGTH, (((POTION*)L1082_ps_Junk)->Power / 35) + 5); /* Value between 5 and 12 */
                                        break;
                                case C08_POTION_DANE_POTION:
                                        F348_xxxx_INVENTORY_AdjustStatisticCurrentValue(L1083_ps_Champion, C3_STATISTIC_WISDOM, A1085_ui_AdjustedPotionPower);
                                        break;
                                case C09_POTION_NETA_POTION:
                                        F348_xxxx_INVENTORY_AdjustStatisticCurrentValue(L1083_ps_Champion, C4_STATISTIC_VITALITY, A1085_ui_AdjustedPotionPower);
                                        break;
                                case C10_POTION_ANTIVENIN:
                                        F323_xxxx_CHAMPION_Unpoison(L1080_i_ChampionIndex);
                                        break;
                                case C11_POTION_MON_POTION:
                                        L1083_ps_Champion->CurrentStamina += F024_aatz_MAIN_GetMinimumValue(L1083_ps_Champion->MaximumStamina - L1083_ps_Champion->CurrentStamina, L1083_ps_Champion->MaximumStamina / L1086_ui_Counter);
                                        break;
                                case C12_POTION_YA_POTION:
                                        A1085_ui_AdjustedPotionPower += A1085_ui_AdjustedPotionPower >> 1;
                                        if (L1083_ps_Champion->ShieldDefense > 50) {
                                                A1085_ui_AdjustedPotionPower >>= 2;
                                        }
                                        L1083_ps_Champion->ShieldDefense += A1085_ui_AdjustedPotionPower;
                                        L1084_s_Event.A.A.Type = C72_EVENT_CHAMPION_SHIELD;
                                        M33_SET_MAP_AND_TIME(L1084_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + (A1085_ui_AdjustedPotionPower * A1085_ui_AdjustedPotionPower));
                                        L1084_s_Event.A.A.Priority = L1080_i_ChampionIndex;
                                        L1084_s_Event.B.Defense = A1085_ui_AdjustedPotionPower;
                                        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L1084_s_Event);
                                        M08_SET(L1083_ps_Champion->Attributes, MASK0x1000_STATUS_BOX);
                                        break;
                                case C13_POTION_EE_POTION:
                                        A1088_ui_Mana = F024_aatz_MAIN_GetMinimumValue(900, (L1083_ps_Champion->CurrentMana + A1085_ui_AdjustedPotionPower) + (A1085_ui_AdjustedPotionPower - 8));
                                        if (A1088_ui_Mana > L1083_ps_Champion->MaximumMana) {
                                                A1088_ui_Mana -= (A1088_ui_Mana - F025_aatz_MAIN_GetMaximumValue(L1083_ps_Champion->CurrentMana, L1083_ps_Champion->MaximumMana)) >> 1;
                                        }
                                        L1083_ps_Champion->CurrentMana = A1088_ui_Mana;
                                        break;
                                case C14_POTION_VI_POTION:
                                        A1088_ui_HealWoundIterationCount = F025_aatz_MAIN_GetMaximumValue(1, (((POTION*)L1082_ps_Junk)->Power / 42));
                                        L1083_ps_Champion->CurrentHealth += L1083_ps_Champion->MaximumHealth / L1086_ui_Counter;
                                        if (L1087_i_Wounds = L1083_ps_Champion->Wounds) { /* If the champion is wounded */
                                                L1086_ui_Counter = 10;
                                                do {
                                                        for(A1085_ui_Counter = 0; A1085_ui_Counter < A1088_ui_HealWoundIterationCount; A1085_ui_Counter++) {
                                                                L1083_ps_Champion->Wounds &= M06_RANDOM(65536);
                                                        }
                                                        A1088_ui_HealWoundIterationCount = 1;
                                                } while ((L1087_i_Wounds == L1083_ps_Champion->Wounds) && --L1086_ui_Counter); /* Loop until at least one wound is healed or there are no more heal iterations */
                                        }
                                        M08_SET(L1083_ps_Champion->Attributes, MASK0x0200_LOAD | MASK0x2000_WOUNDS);
                                        break;
                                case C15_POTION_WATER_FLASK:
                                        L1083_ps_Champion->Water = F024_aatz_MAIN_GetMinimumValue(L1083_ps_Champion->Water + 1600, 2048);
                        }
                        ((POTION*)L1082_ps_Junk)->Type = C20_POTION_EMPTY_FLASK;
                } else {
                        if ((L1079_ui_IconIndex >= C168_ICON_JUNK_APPLE) && (L1079_ui_IconIndex < C176_ICON_JUNK_IRON_KEY)) {
                                L1083_ps_Champion->Food = F024_aatz_MAIN_GetMinimumValue(L1083_ps_Champion->Food + G242_ai_Graphic559_FoodAmounts[L1079_ui_IconIndex - C168_ICON_JUNK_APPLE], 2048);
                        }
                }
                if (L1083_ps_Champion->CurrentStamina > L1083_ps_Champion->MaximumStamina) {
                        L1083_ps_Champion->CurrentStamina = L1083_ps_Champion->MaximumStamina;
                }
                if (L1083_ps_Champion->CurrentHealth > L1083_ps_Champion->MaximumHealth) {
                        L1083_ps_Champion->CurrentHealth = L1083_ps_Champion->MaximumHealth;
                }
                if (L1081_B_RemoveObjectFromLeaderHand) {
                        L1086_ui_Counter = 5;
                        while (--L1086_ui_Counter) { /* Animate mouth icon */
                                F037_aA29_OBJECT_DrawIconToScreen(C205_ICON_MOUTH_OPEN + !(L1086_ui_Counter & 0x0001), 56, 46);
                                F022_aaaU_MAIN_Delay(8);
                        }
                } else {
                        F296_aizz_CHAMPION_DrawChangedObjectIcons();
                        G407_s_Party.Champions[G411_i_LeaderIndex].Load += F140_yzzz_DUNGEON_GetObjectWeight(L1078_T_Thing) - L1089_ui_Weight;
                        M08_SET(G407_s_Party.Champions[G411_i_LeaderIndex].Attributes, MASK0x0200_LOAD);
                }
                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C08_SOUND_SWALLOW, G306_i_PartyMapX, G307_i_PartyMapY, C00_MODE_PLAY_IMMEDIATELY);
                M08_SET(L1083_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                if (G424_i_PanelContent == C0_PANEL_FOOD_WATER_POISONED) {
                        M08_SET(L1083_ps_Champion->Attributes, MASK0x0800_PANEL);
                }
                F292_arzz_CHAMPION_DrawState(L1080_i_ChampionIndex);
                F078_xzzz_MOUSE_ShowPointer();
        }
}

VOID F350_aqzz_INVENTORY_DrawStopPressingMouth()
{
        F347_xxxx_INVENTORY_DrawPanel();
        F097_lzzz_DUNGEONVIEW_DrawViewport(C0_VIEWPORT_NOT_DUNGEON_VIEW);
        G587_i_HideMousePointerRequestCount = 1;
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F351_xxxx_INVENTORY_DrawChampionSkillsAndStatistics()
{
        register unsigned int L1090_ui_Multiple;
#define A1090_ui_SkillIndex     L1090_ui_Multiple
#define A1090_ui_StatisticIndex L1090_ui_Multiple
        register int L1091_i_Y;
        register int L1092_i_Multiple;
#define A1092_i_SkillLevel            L1092_i_Multiple
#define A1092_i_StatisticCurrentValue L1092_i_Multiple
        register int L1093_i_ChampionIndex;
        register CHAMPION* L1094_ps_Champion;
        int L1095_i_StatisticColor;
        unsigned int L1096_ui_StatisticMaximumValue;
        char L1097_ac_String[20];
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_08_OPTIMIZATION */
        static char* G431_apc_StatisticNames[7] = { "L", "STRENGTH   ", "DEXTERITY  ", "WISDOM     ", "VITALITY   ", "ANTI-MAGIC ", "ANTI-FIRE  " };
#endif
#ifdef C20_COMPILE_DM12EN_CSB20EN_CSB21EN /* CHANGE3_08_OPTIMIZATION Trailing space characters removed from strings CHANGE4_00_LOCALIZATION Translation to German language */
        static char* G431_apc_StatisticNames[7] = { "L", "STRENGTH", "DEXTERITY", "WISDOM", "VITALITY", "ANTI-MAGIC", "ANTI-FIRE" };
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
        static char* G431_apc_StatisticNames[7] = { "L", "STAERKE", "FLINKHEIT", "WEISHEIT", "VITALITAET", "ANTI-MAGIE", "ANTI-FEUER" };
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
        static char* G431_apc_StatisticNames[7] = { "L", "FORCE", "DEXTERITE", "SAGESSE", "VITALITE", "ANTI-MAGIE", "ANTI-FEU" };
#endif


        F334_akzz_INVENTORY_CloseChest();
        L1094_ps_Champion = &G407_s_Party.Champions[L1093_i_ChampionIndex = M01_ORDINAL_TO_INDEX(G423_i_InventoryChampionOrdinal)];
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C020_GRAPHIC_PANEL_EMPTY), &G032_s_Graphic562_Box_Panel, C072_BYTE_WIDTH, C08_COLOR_RED);
        L1091_i_Y = 58;
        for(A1090_ui_SkillIndex = C00_SKILL_FIGHTER; A1090_ui_SkillIndex <= C03_SKILL_WIZARD; A1090_ui_SkillIndex++) {
                A1092_i_SkillLevel = F024_aatz_MAIN_GetMinimumValue(16, F303_AA09_CHAMPION_GetSkillLevel(L1093_i_ChampionIndex, A1090_ui_SkillIndex | MASK0x8000_IGNORE_TEMPORARY_EXPERIENCE));
                if (A1092_i_SkillLevel == 1) {
                        continue;
                }
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                strcpy(L1097_ac_String, G428_apc_SkillLevelNames[A1092_i_SkillLevel - 2]);
                strcat(L1097_ac_String, " ");
                strcat(L1097_ac_String, G417_apc_BaseSkillNames[A1090_ui_SkillIndex]);
#endif
#ifdef C22_COMPILE_DM12GE_DM13aFR_DM13bFR /* CHANGE4_00_LOCALIZATION Translation to German language */
                strcpy(L1097_ac_String, G417_apc_BaseSkillNames[A1090_ui_SkillIndex]);
                strcat(L1097_ac_String, " ");
                strcat(L1097_ac_String, G428_apc_SkillLevelNames[A1092_i_SkillLevel - 2]);
#endif
                F052_aaoz_TEXT_PrintToViewport(108, L1091_i_Y, C13_COLOR_LIGHTEST_GRAY, L1097_ac_String);
                L1091_i_Y += 7;
        }
        L1091_i_Y = 86;
        for(A1090_ui_StatisticIndex = C1_STATISTIC_STRENGTH; A1090_ui_StatisticIndex <= C6_STATISTIC_ANTIFIRE; A1090_ui_StatisticIndex++) {
                F052_aaoz_TEXT_PrintToViewport(108, L1091_i_Y, C13_COLOR_LIGHTEST_GRAY, G431_apc_StatisticNames[A1090_ui_StatisticIndex]);
                A1092_i_StatisticCurrentValue = L1094_ps_Champion->Statistics[A1090_ui_StatisticIndex][C1_CURRENT];
                L1096_ui_StatisticMaximumValue = L1094_ps_Champion->Statistics[A1090_ui_StatisticIndex][C0_MAXIMUM];
                if (A1092_i_StatisticCurrentValue < L1096_ui_StatisticMaximumValue) {
                        L1095_i_StatisticColor = C08_COLOR_RED;
                } else {
                        if (A1092_i_StatisticCurrentValue > L1096_ui_StatisticMaximumValue) {
                                L1095_i_StatisticColor = C07_COLOR_LIGHT_GREEN;
                        } else {
                                L1095_i_StatisticColor = C13_COLOR_LIGHTEST_GRAY;
                        }
                }
                F052_aaoz_TEXT_PrintToViewport(174, L1091_i_Y, L1095_i_StatisticColor, F288_xxxx_CHAMPION_GetStringFromInteger(A1092_i_StatisticCurrentValue, TRUE, 3));
                strcpy(L1097_ac_String, "/");
                strcat(L1097_ac_String, F288_xxxx_CHAMPION_GetStringFromInteger(L1096_ui_StatisticMaximumValue, TRUE, 3));
                F052_aaoz_TEXT_PrintToViewport(192, L1091_i_Y, C13_COLOR_LIGHTEST_GRAY, L1097_ac_String);
                L1091_i_Y += 7;
        }
}

VOID F352_aszz_INVENTORY_ProcessCommand71_ClickOnEye()
{
        register int L1098_i_Unreferenced; /* BUG0_00 Useless code */
        register int L1099_i_Unreferenced; /* BUG0_00 Useless code */


        G597_B_IgnoreMouseMovements = TRUE;
        G331_B_PressingEye = TRUE;
        if (!M07_GET(G588_i_MouseButtonsStatus, MASK0x0002_MOUSE_LEFT_BUTTON)) {
                G597_B_IgnoreMouseMovements = FALSE;
                G331_B_PressingEye = FALSE;
                G332_B_StopPressingEye = FALSE;
                return;
        }
        F357_qzzz_COMMAND_DiscardAllInput();
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F022_aaaU_MAIN_Delay(8);
        F332_xxxx_INVENTORY_DrawIconToViewport(C203_ICON_EYE_LOOKING, 12, 13);
        if (G415_B_LeaderEmptyHanded) {
                F351_xxxx_INVENTORY_DrawChampionSkillsAndStatistics();
        } else {
                F035_aaaw_OBJECT_ClearLeaderHandObjectName();
                F342_xxxx_INVENTORY_DrawPanel_Object(G414_T_LeaderHandObject, TRUE);
        }
        F097_lzzz_DUNGEONVIEW_DrawViewport(C0_VIEWPORT_NOT_DUNGEON_VIEW);
}

VOID F353_auzz_INVENTORY_DrawStopPressingEye()
{
        register THING L1100_T_LeaderHandObject;


        F332_xxxx_INVENTORY_DrawIconToViewport(C202_ICON_EYE_NOT_LOOKING, 12, 13);
        F347_xxxx_INVENTORY_DrawPanel();
        F097_lzzz_DUNGEONVIEW_DrawViewport(C0_VIEWPORT_NOT_DUNGEON_VIEW);
        if ((L1100_T_LeaderHandObject = G414_T_LeaderHandObject) != C0xFFFF_THING_NONE) {
                F034_aaau_OBJECT_DrawLeaderHandObjectName(L1100_T_LeaderHandObject);
        }
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F354_szzz_INVENTORY_DrawStatusBoxPortrait(P718_i_ChampionIndex)
int P718_i_ChampionIndex;
{
        BOX_WORD L1101_s_Box;


        G578_B_UseByteBoxCoordinates = FALSE;
        L1101_s_Box.Y1 = 0;
        L1101_s_Box.Y2 = 28;
        L1101_s_Box.X2 = (L1101_s_Box.X1 = (P718_i_ChampionIndex * C69_CHAMPION_STATUS_BOX_SPACING) + 7) + 31; /* There is a 7 pixels left margin in the status box */
        F021_a002_MAIN_BlitToScreen(G407_s_Party.Champions[P718_i_ChampionIndex].Portrait, &L1101_s_Box, C016_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
}

VOID F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(P719_i_ChampionIndex)
register int P719_i_ChampionIndex;
{
        register unsigned int L1102_ui_Multiple;
#define A1102_ui_InventoryChampionOrdinal L1102_ui_Multiple
#define A1102_ui_SlotIndex                L1102_ui_Multiple
        register CHAMPION* L1103_ps_Champion;


        if ((P719_i_ChampionIndex != C04_CHAMPION_CLOSE_INVENTORY) && !G407_s_Party.Champions[P719_i_ChampionIndex].CurrentHealth) {
                return;
        }
        if (G333_B_PressingMouth || G331_B_PressingEye) {
                return;
        }
        G321_B_StopWaitingForPlayerInput = TRUE;
#ifndef NOCOPYPROTECTION
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT */
        if ((G068_i_CheckLastEvent22Time_COPYPROTECTIONE == C00555_TRUE) && ((G313_ul_GameTime - G418_l_LastEvent22Time_COPYPROTECTIONE) > 1000)) {
                G330_i_StopExpiringEvents_COPYPROTECTIONE++;
        }
#endif
#endif
        A1102_ui_InventoryChampionOrdinal = G423_i_InventoryChampionOrdinal;
        if (M00_INDEX_TO_ORDINAL(P719_i_ChampionIndex) == A1102_ui_InventoryChampionOrdinal) {
                P719_i_ChampionIndex = C04_CHAMPION_CLOSE_INVENTORY;
        }
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        if (A1102_ui_InventoryChampionOrdinal) {
                G423_i_InventoryChampionOrdinal = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
                F334_akzz_INVENTORY_CloseChest();
                L1103_ps_Champion = &G407_s_Party.Champions[M01_ORDINAL_TO_INDEX(A1102_ui_InventoryChampionOrdinal)];
                if (L1103_ps_Champion->CurrentHealth && !G299_ui_CandidateChampionOrdinal) {
                        M08_SET(L1103_ps_Champion->Attributes, MASK0x1000_STATUS_BOX);
                        F292_arzz_CHAMPION_DrawState(M01_ORDINAL_TO_INDEX(A1102_ui_InventoryChampionOrdinal));
                }
                if (G300_B_PartyIsSleeping) {
                        F078_xzzz_MOUSE_ShowPointer();
                        return;
                }
                if (P719_i_ChampionIndex == C04_CHAMPION_CLOSE_INVENTORY) {
                        G326_B_RefreshMousePointerInMainLoop = TRUE;
                        F395_pzzz_MENUS_DrawMovementArrows();
                        F078_xzzz_MOUSE_ShowPointer();
                        G442_ps_SecondaryMouseInput = G448_as_Graphic561_SecondaryMouseInput_Movement;
                        G444_ps_SecondaryKeyboardInput = G459_as_Graphic561_SecondaryKeyboardInput_Movement;
                        F357_qzzz_COMMAND_DiscardAllInput();
                        F098_rzzz_DUNGEONVIEW_DrawFloorAndCeiling();
                        return;
                }
        }
        G578_B_UseByteBoxCoordinates = FALSE;
        G423_i_InventoryChampionOrdinal = M00_INDEX_TO_ORDINAL(P719_i_ChampionIndex);
        if (!A1102_ui_InventoryChampionOrdinal) {
                F136_nzzz_VIDEO_ShadeScreenBox(&G002_s_Graphic562_Box_MovementArrows, C00_COLOR_BLACK);
        }
        L1103_ps_Champion = &G407_s_Party.Champions[P719_i_ChampionIndex];
        F488_bzzz_MEMORY_ExpandGraphicToBitmap(C017_GRAPHIC_INVENTORY, G296_puc_Bitmap_Viewport);
        if (G299_ui_CandidateChampionOrdinal) {
                F135_xzzz_VIDEO_FillBox(G296_puc_Bitmap_Viewport, &G041_s_Graphic562_Box_ViewportFloppyZzzCross, C12_COLOR_DARKEST_GRAY, C112_BYTE_WIDTH_VIEWPORT);
        }
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
        F052_aaoz_TEXT_PrintToViewport(5, 116, C13_COLOR_LIGHTEST_GRAY, "HEALTH");
        F052_aaoz_TEXT_PrintToViewport(5, 124, C13_COLOR_LIGHTEST_GRAY, "STAMINA");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
        F052_aaoz_TEXT_PrintToViewport(5, 116, C13_COLOR_LIGHTEST_GRAY, "GESUND");
        F052_aaoz_TEXT_PrintToViewport(5, 124, C13_COLOR_LIGHTEST_GRAY, "KRAFT");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
        F052_aaoz_TEXT_PrintToViewport(5, 116, C13_COLOR_LIGHTEST_GRAY, "SANTE");
        F052_aaoz_TEXT_PrintToViewport(5, 124, C13_COLOR_LIGHTEST_GRAY, "VIGUEUR");
#endif
        F052_aaoz_TEXT_PrintToViewport(5, 132, C13_COLOR_LIGHTEST_GRAY, "MANA");
        for(A1102_ui_SlotIndex = C00_SLOT_READY_HAND; A1102_ui_SlotIndex < C30_SLOT_CHEST_1; A1102_ui_SlotIndex++) {
                F291_xxxx_CHAMPION_DrawSlot(P719_i_ChampionIndex, A1102_ui_SlotIndex);
        }
        M08_SET(L1103_ps_Champion->Attributes, MASK0x4000_VIEWPORT | MASK0x1000_STATUS_BOX | MASK0x0800_PANEL | MASK0x0200_LOAD | MASK0x0100_STATISTICS | MASK0x0080_NAME_TITLE);
        Vsync();
        F292_arzz_CHAMPION_DrawState(P719_i_ChampionIndex);
        G598_B_MousePointerBitmapUpdated = TRUE;
        F078_xzzz_MOUSE_ShowPointer();
        G442_ps_SecondaryMouseInput = G449_as_Graphic561_SecondaryMouseInput_ChampionInventory;
        G444_ps_SecondaryKeyboardInput = NULL;
        F357_qzzz_COMMAND_DiscardAllInput();
}
