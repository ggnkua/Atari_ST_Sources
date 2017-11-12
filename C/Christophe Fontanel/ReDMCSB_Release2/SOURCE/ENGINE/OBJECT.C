#include "DEFS.H"

/*_Global variables_*/
char* G352_apc_ObjectNames[C199_OBJECT_NAME_COUNT];


overlay "main"

VOID F031_aAA2_OBJECT_LoadNames()
{
        register char* L0001_pc_ObjectNames;
        register unsigned char* L0002_puc_Graphic;
        register unsigned int L0003_ui_ObjectNameIndex;


        G412_puc_Bitmap_ObjectIconForMousePointer = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(16, 16), C1_ALLOCATION_PERMANENT);
        L0001_pc_ObjectNames = (char*)F468_ozzz_MEMORY_Allocate((long)(F494_ozzz_MEMORY_GetGraphicDecompressedByteCount(C556_GRAPHIC_OBJECT_NAMES) + C199_OBJECT_NAME_COUNT), C1_ALLOCATION_PERMANENT);
        L0002_puc_Graphic = F468_ozzz_MEMORY_Allocate((long)(C199_OBJECT_NAME_COUNT * C014_OBJECT_NAME_MAXIMUM_LENGTH), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C556_GRAPHIC_OBJECT_NAMES, L0002_puc_Graphic); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 4 parameters. No consequence because the missing parameters are not used when MASK0x8000_NOT_EXPANDED is specified */
        for(L0003_ui_ObjectNameIndex = 0; L0003_ui_ObjectNameIndex < C199_OBJECT_NAME_COUNT; L0003_ui_ObjectNameIndex++) {
                G352_apc_ObjectNames[L0003_ui_ObjectNameIndex] = L0001_pc_ObjectNames;
                while (!(*L0002_puc_Graphic & 0x80)) { /* The last character of each object name has bit 7 set */
                        *L0001_pc_ObjectNames++ = *L0002_puc_Graphic++; /* Write characters until last character is found */
                }
                *L0001_pc_ObjectNames++ = *L0002_puc_Graphic++ & 0x7F; /* Write last character without bit 7 */
                *L0001_pc_ObjectNames++ = '\0'; /* Write string termination */
        }
        F469_rzzz_MEMORY_FreeAtHeapTop((long)(C199_OBJECT_NAME_COUNT * C014_OBJECT_NAME_MAXIMUM_LENGTH));
}

int F032_aaaY_OBJECT_GetType(P039_T_Thing)
THING P039_T_Thing;
{
        register int L0004_i_Multiple;
#define A0004_i_ObjectInfoIndex L0004_i_Multiple
#define A0004_i_ObjectType      L0004_i_Multiple


        if (P039_T_Thing == C0xFFFF_THING_NONE) {
                return CM1_ICON_NONE;
        }
        A0004_i_ObjectInfoIndex = F141_anzz_DUNGEON_GetObjectInfoIndex(P039_T_Thing);
        if (A0004_i_ObjectInfoIndex != -1) {
                A0004_i_ObjectType = G237_as_Graphic559_ObjectInfo[A0004_i_ObjectInfoIndex].Type;
        }
        return A0004_i_ObjectType;
}

int F033_aaaz_OBJECT_GetIconIndex(P040_T_Thing)
THING P040_T_Thing;
{
        register int L0005_i_IconIndex;
        register JUNK* L0006_ps_Junk;


        if ((L0005_i_IconIndex = F032_aaaY_OBJECT_GetType(P040_T_Thing)) != CM1_ICON_NONE) {
                if (((L0005_i_IconIndex < C032_ICON_WEAPON_DAGGER) && (L0005_i_IconIndex >= C000_ICON_JUNK_COMPASS_NORTH)) ||
                    ((L0005_i_IconIndex >= C148_ICON_POTION_MA_POTION_MON_POTION) && (L0005_i_IconIndex <= C163_ICON_POTION_WATER_FLASK)) ||
                    (L0005_i_IconIndex == C195_ICON_POTION_EMPTY_FLASK)) {
                        L0006_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(P040_T_Thing);
                        switch (L0005_i_IconIndex) {
                                case C000_ICON_JUNK_COMPASS_NORTH:
                                        L0005_i_IconIndex += G308_i_PartyDirection;
                                        break;
                                case C004_ICON_WEAPON_TORCH_UNLIT:
                                        if (((WEAPON*)L0006_ps_Junk)->Lit) {
                                                L0005_i_IconIndex += G029_auc_Graphic562_ChargeCountToTorchType[((WEAPON*)L0006_ps_Junk)->ChargeCount];
                                        }
                                        break;
                                case C030_ICON_SCROLL_SCROLL_OPEN:
                                        if (((SCROLL*)L0006_ps_Junk)->Closed) {
                                                L0005_i_IconIndex++;
                                        }
                                        break;
                                case C008_ICON_JUNK_WATER:
                                case C012_ICON_JUNK_ILLUMULET_UNEQUIPPED:
                                case C010_ICON_JUNK_JEWEL_SYMAL_UNEQUIPPED:
                                        if (L0006_ps_Junk->ChargeCount) {
                                                L0005_i_IconIndex++;
                                        }
                                        break;
                                case C023_ICON_WEAPON_BOLT_BLADE_STORM_EMPTY:
                                case C014_ICON_WEAPON_FLAMITT_EMPTY:
                                case C018_ICON_WEAPON_STORMRING_EMPTY:
                                case C025_ICON_WEAPON_FURY_RA_BLADE_EMPTY:
                                case C016_ICON_WEAPON_EYE_OF_TIME_EMPTY:
                                case C020_ICON_WEAPON_STAFF_OF_CLAWS_EMPTY:
                                        if (((WEAPON*)L0006_ps_Junk)->ChargeCount) {
                                                L0005_i_IconIndex++;
                                        }
                        }
                }
        }
        return L0005_i_IconIndex;
}

VOID F034_aaau_OBJECT_DrawLeaderHandObjectName(P041_T_Thing)
register THING P041_T_Thing;
{
        register int L0007_i_IconIndex;
        register char* L0008_pc_ObjectName;
        register JUNK* L0009_ps_Junk;
        char L0010_ac_ObjectName[16];


        L0007_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(P041_T_Thing);
        if (L0007_i_IconIndex == C147_ICON_JUNK_CHAMPION_BONES) {
                L0009_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(P041_T_Thing);
#ifdef C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE /* CHANGE5_00_LOCALIZATION Translation to French language */
                strcpy(L0010_ac_ObjectName, G407_s_Party.Champions[L0009_ps_Junk->ChargeCount].Name);
                strcat(L0010_ac_ObjectName, " ");
                strcat(L0010_ac_ObjectName, G352_apc_ObjectNames[L0007_i_IconIndex]);
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                strcpy(L0010_ac_ObjectName, G352_apc_ObjectNames[L0007_i_IconIndex]); /* No space is added between the strings as the space is included directly in the object name */
                strcat(L0010_ac_ObjectName, G407_s_Party.Champions[L0009_ps_Junk->ChargeCount].Name);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_07_LOCALIZATION Translation to English language (differences with original Dungeon Master) */
                strcpy(L0010_ac_ObjectName, G407_s_Party.Champions[L0009_ps_Junk->ChargeCount].Name); /* BUG7_00 When holding a champion's dead bones in hand, a space character is missing between the champion name and the object name */
                strcat(L0010_ac_ObjectName, G352_apc_ObjectNames[L0007_i_IconIndex]);
#endif
                L0008_pc_ObjectName = L0010_ac_ObjectName;
        } else {
                L0008_pc_ObjectName = (char*)G352_apc_ObjectNames[L0007_i_IconIndex];
        }
        F041_aadZ_TEXT_PrintWithTrailingSpaces(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, 233, 37, C04_COLOR_CYAN, C00_COLOR_BLACK, L0008_pc_ObjectName, C014_OBJECT_NAME_MAXIMUM_LENGTH);
}

VOID F035_aaaw_OBJECT_ClearLeaderHandObjectName()
{
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G028_s_Graphic562_Box_LeaderHandObjectName, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
}

VOID F036_aA19_OBJECT_ExtractIconFromBitmap(P042_ui_IconIndex, P043_pl_Bitmap)
register unsigned int P042_ui_IconIndex;
register long* P043_pl_Bitmap;
{
        register unsigned int L0011_ui_Counter;
        register long* L0012_pl_Bitmap_Icon;


        for(L0011_ui_Counter = 0; L0011_ui_Counter < 7; L0011_ui_Counter++) {
                if (G026_ai_Graphic562_IconGraphicFirstIconIndex[L0011_ui_Counter] > P042_ui_IconIndex) {
                        break;
                }
        }
        L0012_pl_Bitmap_Icon = (long*)F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C042_GRAPHIC_OBJECT_ICONS_000_TO_031 + --L0011_ui_Counter);
        P042_ui_IconIndex -= G026_ai_Graphic562_IconGraphicFirstIconIndex[L0011_ui_Counter];
        L0012_pl_Bitmap_Icon += (((P042_ui_IconIndex & 0x0FF0) << 5) + ((P042_ui_IconIndex & 0x000F) << 1));
        for(L0011_ui_Counter = 0; L0011_ui_Counter < 16; L0011_ui_Counter++) {
                *P043_pl_Bitmap++ = *L0012_pl_Bitmap_Icon++;
                *P043_pl_Bitmap++ = *L0012_pl_Bitmap_Icon;
                L0012_pl_Bitmap_Icon += 31;
        }
}

VOID F037_aA29_OBJECT_DrawIconToScreen(P044_i_IconIndex, P045_i_X, P046_i_Y)
int P044_i_IconIndex;
int P045_i_X;
int P046_i_Y;
{
        unsigned char* L0013_puc_Bitmap_Icon;
        BOX_WORD L0014_s_Box;


        L0013_puc_Bitmap_Icon = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(16, 16), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        L0014_s_Box.X2 = (L0014_s_Box.X1 = P045_i_X) + 15;
        L0014_s_Box.Y2 = (L0014_s_Box.Y1 = P046_i_Y) + 15;
        F036_aA19_OBJECT_ExtractIconFromBitmap(P044_i_IconIndex, L0013_puc_Bitmap_Icon);
        F021_a002_MAIN_BlitToScreen(L0013_puc_Bitmap_Icon, &L0014_s_Box, C008_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        F469_rzzz_MEMORY_FreeAtHeapTop((long)M75_BITMAP_BYTE_COUNT(16, 16));
}

VOID F038_AA07_OBJECT_DrawIconInSlotBox(P047_ui_SlotBoxIndex, P048_i_IconIndex)
register unsigned int P047_ui_SlotBoxIndex;
register int P048_i_IconIndex;
{
        register unsigned int L0015_ui_IconGraphicIndex;
        register int L0016_i_ByteWidth;
        register SLOT_BOX* L0017_ps_SlotBox;
        register unsigned char* L0018_puc_Bitmap_Icons;
        BOX_WORD L0019_s_Box;
        unsigned char* L0020_puc_Bitmap_Destination;


        L0017_ps_SlotBox = &G030_as_Graphic562_SlotBoxes[P047_ui_SlotBoxIndex];
        if ((L0017_ps_SlotBox->IconIndex = P048_i_IconIndex) == CM1_ICON_NONE) {
                return;
        }
        L0019_s_Box.X2 = (L0019_s_Box.X1 = L0017_ps_SlotBox->X) + 15;
        L0019_s_Box.Y2 = (L0019_s_Box.Y1 = L0017_ps_SlotBox->Y) + 15;
        for(L0015_ui_IconGraphicIndex = 0; L0015_ui_IconGraphicIndex < 7; L0015_ui_IconGraphicIndex++) {
                if (G026_ai_Graphic562_IconGraphicFirstIconIndex[L0015_ui_IconGraphicIndex] > P048_i_IconIndex) {
                        break;
                }
        }
        L0015_ui_IconGraphicIndex--;
        L0018_puc_Bitmap_Icons = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0015_ui_IconGraphicIndex + C042_GRAPHIC_OBJECT_ICONS_000_TO_031);
        P048_i_IconIndex -= G026_ai_Graphic562_IconGraphicFirstIconIndex[L0015_ui_IconGraphicIndex];
        if (P047_ui_SlotBoxIndex >= C08_SLOT_BOX_INVENTORY_FIRST_SLOT) {
                L0020_puc_Bitmap_Destination = G296_puc_Bitmap_Viewport;
                L0016_i_ByteWidth = C112_BYTE_WIDTH_VIEWPORT;
        } else {
                L0020_puc_Bitmap_Destination = (unsigned char*)G348_pl_Bitmap_LogicalScreenBase;
                L0016_i_ByteWidth = C160_BYTE_WIDTH_SCREEN;
        }
        G578_B_UseByteBoxCoordinates = FALSE, F132_xzzz_VIDEO_Blit(L0018_puc_Bitmap_Icons, L0020_puc_Bitmap_Destination, &L0019_s_Box, (P048_i_IconIndex & 0x000F) << 4, P048_i_IconIndex & 0x0FF0, C128_BYTE_WIDTH, L0016_i_ByteWidth, CM1_COLOR_NO_TRANSPARENCY);
}

int F039_aaaL_OBJECT_GetIconIndexInSlotBox(P049_i_SlotBoxIndex)
int P049_i_SlotBoxIndex;
{
        return G030_as_Graphic562_SlotBoxes[P049_i_SlotBoxIndex].IconIndex;
}
