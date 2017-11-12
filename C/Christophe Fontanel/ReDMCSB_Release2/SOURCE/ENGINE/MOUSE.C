#include "DEFS.H"

/*_Global variables_*/
int G587_i_HideMousePointerRequestCount = 1;
int G588_i_MouseButtonsStatus;
int G589_i_MousePointerHotspotX;
int G590_i_MousePointerHotspotY;
long G591_l_MousePointerYX;
BOOLEAN G592_B_BuildMousePointerScreenAreaRequested;
BOOLEAN G593_B_BuildMousePointerScreenAreaCompleted;
BOOLEAN G594_B_BuildMousePointerScreenAreaRequestedInMouseException;
BOOLEAN G595_B_MousePointerVisible;
BOOLEAN G596_B_NoDrawInVerticalBlankWhileHidingMousePointer;
BOOLEAN G597_B_IgnoreMouseMovements;
BOOLEAN G598_B_MousePointerBitmapUpdated = TRUE;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_09_OPTIMIZATION Variables reordered */
int G603_i_MousePointerScreenAreaCurrentX;
int G604_i_MousePointerScreenAreaCurrentY;
#endif
unsigned int G599_ui_UseChampionIconOrdinalAsMousePointerBitmap; /* If non zero then the mouse pointer bitmap is a champion icon */
BOOLEAN G600_B_UseObjectAsMousePointerBitmap; /* If true and G599_ui_UseChampionIconOrdinalAsMousePointerBitmap = 0 then the mouse pointer bitmap is an object icon */
BOOLEAN G601_B_UseHandAsMousePointerBitmap; /* If true and G600_B_UseObjectAsMousePointerBitmap = FALSE and G599_ui_UseChampionIconOrdinalAsMousePointerBitmap = 0 then the mouse pointer bitmap is the hand else it is the arrow */
BOOLEAN G602_B_CurrentMousePointerIsObject = FALSE;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_09_OPTIMIZATION Variables reordered */
int G603_i_MousePointerScreenAreaCurrentX;
int G604_i_MousePointerScreenAreaCurrentY;
#endif
int G605_i_MousePointerBitmapHotspotX;
int G606_i_MousePointerBitmapHotspotY;
int G607_i_MousePointerScreenAreaNextX;
int G608_i_MousePointerScreenAreaNextY;
int G609_i_MousePointerAreaLastLineIndex;
unsigned int G610_ui_MousePointerAreaUnitWidth;
unsigned char* G611_puc_Bitmap_MousePointerArea;
unsigned char* G612_puc_Bitmap_MousePointerAreaCustom;
unsigned char* G613_puc_Bitmap_MousePointerOriginalColorsChampionIcon;
unsigned char* G614_puc_Bitmap_MousePointerModifiedColorsChampionIcon;
unsigned char* G615_puc_Bitmap_MousePointerOriginalColorsObject;
unsigned char* G616_puc_Bitmap_MousePointerModifiedColorsObject;
unsigned char* G617_puc_Bitmap_MousePointerScreenArea;
unsigned char* G618_puc_Bitmap_MousePointerHiddenScreenArea;


overlay "main"

VOID F066_aalz_MOUSE_Initialize()
{
        register KBDVECS* L0049_ps_Kbdvecs;
#ifdef C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE /* CHANGE5_01_FIX Useless code removed */
        int L0050_i_Unreferenced; /* BUG0_00 Useless code */
#endif


        G616_puc_Bitmap_MousePointerModifiedColorsObject = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 18), C1_ALLOCATION_PERMANENT);
        G615_puc_Bitmap_MousePointerOriginalColorsObject = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 18), C1_ALLOCATION_PERMANENT);
        G614_puc_Bitmap_MousePointerModifiedColorsChampionIcon = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 16), C1_ALLOCATION_PERMANENT);
        G613_puc_Bitmap_MousePointerOriginalColorsChampionIcon = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 16), C1_ALLOCATION_PERMANENT);
        G612_puc_Bitmap_MousePointerAreaCustom = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(48, 18), C1_ALLOCATION_PERMANENT);
        G618_puc_Bitmap_MousePointerHiddenScreenArea = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(48, 18), C1_ALLOCATION_PERMANENT);
        G589_i_MousePointerHotspotX = 251; /* These coordinates place the mouse pointer over the 'Enter' button on the entrance screen */
        G590_i_MousePointerHotspotY = 51;
        L0049_ps_Kbdvecs = (KBDVECS*)Kbdvbase();
        L0049_ps_Kbdvecs->mousevec = (SUBROUTINE)&S075_aaak_MOUSE_Exception70Handler_IKBD_MIDI_MouseStatus;
}

VOID F067_aaat_MOUSE_SetPointerToNormal(P092_i_MousePointer)
int P092_i_MousePointer;
{
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        G600_B_UseObjectAsMousePointerBitmap = FALSE;
        G601_B_UseHandAsMousePointerBitmap = (P092_i_MousePointer == C1_POINTER_HAND);
        G598_B_MousePointerBitmapUpdated = TRUE;
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F068_aagz_MOUSE_SetPointerToObject(P093_puc_Bitmap_Object)
register unsigned char* P093_puc_Bitmap_Object;
{
        register unsigned char* L0051_puc_Bitmap;
        static BOX_BYTE G619_s_Box_MousePointer_ObjectShadow = { 2, 17, 2, 17 };
        static BOX_BYTE G620_s_Box_MousePointer_Object = { 0, 15, 0, 15 };


        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        G600_B_UseObjectAsMousePointerBitmap = TRUE;
        G601_B_UseHandAsMousePointerBitmap = FALSE;
        G598_B_MousePointerBitmapUpdated = TRUE;
        G578_B_UseByteBoxCoordinates = TRUE;
        L0051_puc_Bitmap = G616_puc_Bitmap_MousePointerModifiedColorsObject;
        F134_zzzz_VIDEO_FillBitmap(L0051_puc_Bitmap, C12_COLOR_DARKEST_GRAY, M76_BITMAP_UNIT_COUNT(32, 18));
        F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(P093_puc_Bitmap_Object, G618_puc_Bitmap_MousePointerHiddenScreenArea, 16, 16, 16, 16, G045_auc_Graphic562_PaletteChanges_MousePointerIconShadow);
        F132_xzzz_VIDEO_Blit(G618_puc_Bitmap_MousePointerHiddenScreenArea, L0051_puc_Bitmap, &G619_s_Box_MousePointer_ObjectShadow, 0, 0, C008_BYTE_WIDTH, C016_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        F007_aAA7_MAIN_CopyBytes(L0051_puc_Bitmap, G615_puc_Bitmap_MousePointerOriginalColorsObject, M75_BITMAP_BYTE_COUNT(32, 18));
        F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(P093_puc_Bitmap_Object, G618_puc_Bitmap_MousePointerHiddenScreenArea, 16, 16, 16, 16, G044_auc_Graphic562_PaletteChanges_MousePointerIcon);
        F132_xzzz_VIDEO_Blit(G618_puc_Bitmap_MousePointerHiddenScreenArea, L0051_puc_Bitmap, &G620_s_Box_MousePointer_Object, 0, 0, C008_BYTE_WIDTH, C016_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
        F132_xzzz_VIDEO_Blit(P093_puc_Bitmap_Object, G615_puc_Bitmap_MousePointerOriginalColorsObject, &G620_s_Box_MousePointer_Object, 0, 0, C008_BYTE_WIDTH, C016_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F069_aaaL_MOUSE_SetPointer()
{
        if (G415_B_LeaderEmptyHanded) {
                F067_aaat_MOUSE_SetPointerToNormal((G411_i_LeaderIndex == CM1_CHAMPION_NONE) ? C0_POINTER_ARROW : C1_POINTER_HAND);
        } else {
                F068_aagz_MOUSE_SetPointerToObject(G412_puc_Bitmap_ObjectIconForMousePointer);
        }
}

VOID F070_aajz_MOUSE_ProcessCommands125To128_ClickOnChampionIcon(P094_i_ChampionIconIndex)
register int P094_i_ChampionIconIndex;
{
        register int L0052_i_ChampionIconIndex;
        register int L0053_i_ChampionIndex;
        register int L0054_i_ChampionIndex;
        register int* L0055_pi_ChampionIconBox;
        register unsigned char* L0056_puc_Bitmap;
        static BOX_WORD G621_s_Box_MousePointer_ChampionIconShadow = { 2, 20, 2, 15 };
        static BOX_WORD G622_s_Box_MousePointer_ChampionIcon = { 0, 18, 0, 13 };


        if (!G599_ui_UseChampionIconOrdinalAsMousePointerBitmap) {
                if (F285_szzz_CHAMPION_GetIndexInCell(M21_NORMALIZE(P094_i_ChampionIconIndex + G308_i_PartyDirection)) == CM1_CHAMPION_NONE) {
                        return;
                }
                G598_B_MousePointerBitmapUpdated = TRUE;
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                G578_B_UseByteBoxCoordinates = FALSE;
                L0056_puc_Bitmap = G614_puc_Bitmap_MousePointerModifiedColorsChampionIcon;
                F134_zzzz_VIDEO_FillBitmap(L0056_puc_Bitmap, C12_COLOR_DARKEST_GRAY, M76_BITMAP_UNIT_COUNT(32, 16));
                L0055_pi_ChampionIconBox = &G054_ai_Graphic562_Box_ChampionIcons[P094_i_ChampionIconIndex << 2];
                F132_xzzz_VIDEO_Blit(G348_pl_Bitmap_LogicalScreenBase, L0056_puc_Bitmap, &G621_s_Box_MousePointer_ChampionIconShadow, *L0055_pi_ChampionIconBox, *(L0055_pi_ChampionIconBox + 2), C160_BYTE_WIDTH_SCREEN, C016_BYTE_WIDTH, C00_COLOR_BLACK);
                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0056_puc_Bitmap, L0056_puc_Bitmap, 32, 16, 32, 16, G045_auc_Graphic562_PaletteChanges_MousePointerIconShadow);
                F007_aAA7_MAIN_CopyBytes(L0056_puc_Bitmap, G613_puc_Bitmap_MousePointerOriginalColorsChampionIcon, M75_BITMAP_BYTE_COUNT(32, 16));
                F132_xzzz_VIDEO_Blit(G348_pl_Bitmap_LogicalScreenBase, G613_puc_Bitmap_MousePointerOriginalColorsChampionIcon, &G622_s_Box_MousePointer_ChampionIcon, *L0055_pi_ChampionIconBox, *(L0055_pi_ChampionIconBox + 2), C160_BYTE_WIDTH_SCREEN, C016_BYTE_WIDTH, C00_COLOR_BLACK);
                L0056_puc_Bitmap = G618_puc_Bitmap_MousePointerHiddenScreenArea;
                F134_zzzz_VIDEO_FillBitmap(L0056_puc_Bitmap, C12_COLOR_DARKEST_GRAY, M76_BITMAP_UNIT_COUNT(32, 16));
                F132_xzzz_VIDEO_Blit(G348_pl_Bitmap_LogicalScreenBase, L0056_puc_Bitmap, &G622_s_Box_MousePointer_ChampionIcon, *L0055_pi_ChampionIconBox, *(L0055_pi_ChampionIconBox + 2), C160_BYTE_WIDTH_SCREEN, C016_BYTE_WIDTH, C00_COLOR_BLACK);
                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0056_puc_Bitmap, L0056_puc_Bitmap, 32, 14, 32, 14, G044_auc_Graphic562_PaletteChanges_MousePointerIcon);
                F132_xzzz_VIDEO_Blit(L0056_puc_Bitmap, G614_puc_Bitmap_MousePointerModifiedColorsChampionIcon, &G622_s_Box_MousePointer_ChampionIcon, 0, 0, C016_BYTE_WIDTH, C016_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, L0055_pi_ChampionIconBox, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                F078_xzzz_MOUSE_ShowPointer();
                G599_ui_UseChampionIconOrdinalAsMousePointerBitmap = M00_INDEX_TO_ORDINAL(P094_i_ChampionIconIndex);
                return;
        }
        G598_B_MousePointerBitmapUpdated = TRUE;
        L0052_i_ChampionIconIndex = M01_ORDINAL_TO_INDEX(G599_ui_UseChampionIconOrdinalAsMousePointerBitmap);
        G599_ui_UseChampionIconOrdinalAsMousePointerBitmap = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
        L0054_i_ChampionIndex = F285_szzz_CHAMPION_GetIndexInCell(M21_NORMALIZE(L0052_i_ChampionIconIndex + G308_i_PartyDirection));
        G407_s_Party.Champions[L0054_i_ChampionIndex].Direction = G308_i_PartyDirection;
        if (L0052_i_ChampionIconIndex == P094_i_ChampionIconIndex) {
                M08_SET(G407_s_Party.Champions[L0054_i_ChampionIndex].Attributes, MASK0x0400_ICON);
                F292_arzz_CHAMPION_DrawState(L0054_i_ChampionIndex);
                return;
        }
        L0053_i_ChampionIndex = F285_szzz_CHAMPION_GetIndexInCell(M21_NORMALIZE(P094_i_ChampionIconIndex + G308_i_PartyDirection));
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        if (L0053_i_ChampionIndex >= 0) {
                G407_s_Party.Champions[L0053_i_ChampionIndex].Cell = M21_NORMALIZE(L0052_i_ChampionIconIndex + G308_i_PartyDirection);
                M08_SET(G407_s_Party.Champions[L0053_i_ChampionIndex].Attributes, MASK0x0400_ICON);
                F292_arzz_CHAMPION_DrawState(L0053_i_ChampionIndex);
        } else {
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G054_ai_Graphic562_Box_ChampionIcons[L0052_i_ChampionIconIndex << 2], C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
        }
        G407_s_Party.Champions[L0054_i_ChampionIndex].Cell = M21_NORMALIZE(P094_i_ChampionIconIndex + G308_i_PartyDirection);
        M08_SET(G407_s_Party.Champions[L0054_i_ChampionIndex].Attributes, MASK0x0400_ICON);
        F292_arzz_CHAMPION_DrawState(L0054_i_ChampionIndex);
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F071_xxxx_MOUSE_DropChampionIcon()
{
        register BOOLEAN L0057_B_UseByteBoxCoordinatesBackup;
        register int L0058_i_ChampionIconIndex;


        L0058_i_ChampionIconIndex = M01_ORDINAL_TO_INDEX(G599_ui_UseChampionIconOrdinalAsMousePointerBitmap);
        G599_ui_UseChampionIconOrdinalAsMousePointerBitmap = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
        G598_B_MousePointerBitmapUpdated = TRUE;
        G587_i_HideMousePointerRequestCount++;
        if (G587_i_HideMousePointerRequestCount == 1) {
                G594_B_BuildMousePointerScreenAreaRequestedInMouseException = FALSE;
                G592_B_BuildMousePointerScreenAreaRequested = FALSE;
                G593_B_BuildMousePointerScreenAreaCompleted = FALSE;
                if (G595_B_MousePointerVisible != FALSE) {
                        G595_B_MousePointerVisible = FALSE;
                        S072_xxxx_MOUSE_DrawPointerHiddenScreenArea();
                }
        }
        L0057_B_UseByteBoxCoordinatesBackup = G578_B_UseByteBoxCoordinates;
        F021_a002_MAIN_BlitToScreen(G613_puc_Bitmap_MousePointerOriginalColorsChampionIcon, &G054_ai_Graphic562_Box_ChampionIcons[L0058_i_ChampionIconIndex << 2], C016_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
        G578_B_UseByteBoxCoordinates = L0057_B_UseByteBoxCoordinatesBackup;
        G587_i_HideMousePointerRequestCount--;
        asm {
                bne.s   T071_002_Return         /* Branch if G587_i_HideMousePointerRequestCount is not 0 */
        }
        G592_B_BuildMousePointerScreenAreaRequested = TRUE;
        G594_B_BuildMousePointerScreenAreaRequestedInMouseException = TRUE;
        T071_002_Return: ;
}

asm { /* This asm section compiles correctly but the Megamax C disassembler fails inside this code and enters an infinite loop */
        S072_xxxx_MOUSE_DrawPointerHiddenScreenArea:
                movem.l D0-D5/A0-A1,-(A7)
                movea.l G617_puc_Bitmap_MousePointerScreenArea(A4),A0
                movea.l G618_puc_Bitmap_MousePointerHiddenScreenArea(A4),A1  /* This is a 432 bytes buffer. The hidden pixels area has 18 lines of 48 pixels = 18 * 24 = 432 bytes. The width is 48 pixels because the mouse pointer is 18x18 pixels large so it it possible that it is across three units (each unit is 16 pixels = 8 bytes) */
                movem.l (A1)+,D0-D5 /* Here are 18 copy operations of 24 bytes (6 registers of 4 bytes each) = 432 bytes */
                movem.l D0-D5,(A0)  /* BUG0_01 Memory after the screen memory is overwritten when drawing the mouse pointer when it is located at the bottom of the screen. This has no consequence because the screen memory is located at the end of the RAM */
                movem.l (A1)+,D0-D5
                movem.l D0-D5,160(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,320(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,480(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,640(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,800(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,960(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,1120(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,1280(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,1440(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,1600(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,1760(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,1920(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,2080(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,2240(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,2400(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,2560(A0)
                movem.l (A1)+,D0-D5
                movem.l D0-D5,2720(A0)
                movem.l (A7)+,D0-D5/A0-A1
                rts
}

VOID F073_xxxx_MOUSE_BuildPointerScreenArea()
{
        register unsigned long L0059_ul_X;
        register unsigned long L0060_ul_Y;
        register int L0061_i_Height;
        register int L0062_i_PixelWidth;
        register unsigned char* L0063_puc_Bitmap_ModifiedColors;
        register unsigned char* L0064_puc_Bitmap_OriginalColors;
        BOX_BYTE L0065_s_Box;
        BOOLEAN L0066_B_UseByteBoxCoordinatesBackup;
        int L0067_i_MousePointerRightPadding;
        unsigned char* L0068_puc_Bitmap;


        G611_puc_Bitmap_MousePointerArea = G612_puc_Bitmap_MousePointerAreaCustom;
        L0066_B_UseByteBoxCoordinatesBackup = G578_B_UseByteBoxCoordinates;
        G578_B_UseByteBoxCoordinates = TRUE;
        L0059_ul_X = G591_l_MousePointerYX; /* The least significant word is the X coordinate. The most significant word is the Y coordinate */
        L0060_ul_Y = L0059_ul_X;
        asm {
                        swap    L0060_ul_Y
                        move.w  L0059_ul_X,G607_i_MousePointerScreenAreaNextX(A4)
                        move.w  L0060_ul_Y,G608_i_MousePointerScreenAreaNextY(A4)
                        tst.w   G599_ui_UseChampionIconOrdinalAsMousePointerBitmap(A4)
                        bne     T073_008                                                                /* If a champion icon is being dragged and dropped */
                        lea     G042_auc_Graphic562_Bitmap_ArrowPointer(A4),L0063_puc_Bitmap_ModifiedColors
                        move.w  #6,L0067_i_MousePointerRightPadding(A6)                                 /* The arrow mouse pointer visible width is 10 pixels. 6 pixels of padding on the right in the source 16x16 bitmap */
                        move.w  #FALSE,G602_B_CurrentMousePointerIsObject(A4)
                        cmpi.w  #169,L0060_ul_Y
                        bge.s   T073_003                                                                /* Branch if L0060_ul_Y >= 169 (signed comparison). If mouse pointer is over the message area on the bottom of the screen (Arrow mouse pointer is used over this area) */
                        cmpi.w  #274,L0059_ul_X
                        bge.s   T073_003                                                                /* Branch if L0059_ul_X >= 274 (signed comparison). If mouse pointer is over the champion icons at the top right corner of the screen  (Arrow mouse pointer is used over this area) */
                        cmpi.w  #28,L0060_ul_Y
                        ble.s   T073_001                                                                /* Branch if L0060_ul_Y <= 28 (signed comparison). If mouse pointer is over the champion status boxes on top of the screen  (Hand mouse pointer is used over this area, except over champion names) */
                        cmpi.w  #224,L0059_ul_X
                        bge.s   T073_003                                                                /* Branch if L0059_ul_X >= 224 (signed comparison). If mouse pointer is over the menus area at the right of the viewport (Arrow mouse pointer is used over this area) */
                        bra.s   T073_002                                                                /* If no conditions were true, the Arrow mouse pointer is used */
                T073_001:
                        moveq   #0,L0062_i_PixelWidth
                        move.w  L0059_ul_X,L0062_i_PixelWidth                                           /* Mouse pointer X coordinate */
                        divu    #C69_CHAMPION_STATUS_BOX_SPACING,L0062_i_PixelWidth                     /* L0062_i_PixelWidth is now the champion status box index over which the mouse pointer is located */
                        move.w  L0062_i_PixelWidth,L0061_i_Height
                        cmp.w   G305_ui_PartyChampionCount(A4),L0061_i_Height
                        bge.s   T073_002                                                                /* If the mouse pointer is over an area without any champion status box (then use Hand mouse pointer) */
                        swap    L0062_i_PixelWidth                                                      /* Swap the quotient and remainder words */
                        cmpi.w  #42,L0062_i_PixelWidth
                        bgt.s   T073_002                                                                /* If remainder of division > 42 (then use Arrow mouse pointer, else use Hand mouse pointer). The width of a champion name is 42 pixels on the champion panel */
                        addq.w  #1,L0061_i_Height
                        cmp.w   G423_i_InventoryChampionOrdinal(A4),L0061_i_Height
                        beq.s   T073_003
                        cmpi.w  #6,L0060_ul_Y
                        ble.s   T073_003                                                                /* If mouse pointer is over a champion name. The height of a champion name in a champion panel is 6 pixels */
                T073_002:
                        tst.w   G600_B_UseObjectAsMousePointerBitmap(A4)
                        bne     T073_006                                                                /* If the mouse pointer is a custom bitmap */
                        tst.w   G601_B_UseHandAsMousePointerBitmap(A4)
                        beq.s   T073_003                                                                /* If the mouse pointer is the arrow */
                        lea     G043_auc_Graphic562_Bitmap_HandPointer(A4),L0063_puc_Bitmap_ModifiedColors
                        move.w  #0,L0067_i_MousePointerRightPadding(A6)                                 /* The hand mouse pointer visible width is 16 pixels. No padding on the right in the source 16x16 pixels bitmap */
        }
        T073_003:
        G609_i_MousePointerAreaLastLineIndex = 15;
        G605_i_MousePointerBitmapHotspotX = 0;
        G606_i_MousePointerBitmapHotspotY = 0;
        asm {
                        andi.w  #0x000F,L0059_ul_X
                        beq.s   T073_004                                                                /* If X coordinate of mouse pointer is aligned on a unit (16 pixels) */
                        move.w  #2,G610_ui_MousePointerAreaUnitWidth(A4)
                        cmp.w   L0067_i_MousePointerRightPadding(A6),L0059_ul_X
                        bgt.s   T073_005                                                                /* If new mouse X coordinate in the mouse pointer area is far enough on the right, the mouse pointer is over two units (16 pixels = 8 bytes) */
                        move.w  #1,G610_ui_MousePointerAreaUnitWidth(A4)
                        bra.s   T073_005
                T073_004:
                        move.w  #1,G610_ui_MousePointerAreaUnitWidth(A4)
                        move.l  L0063_puc_Bitmap_ModifiedColors,G611_puc_Bitmap_MousePointerArea(A4)    /* Arrow or Hand mouse pointer bitmap */
                        bra     T073_016
        }
        T073_005:
        F134_zzzz_VIDEO_FillBitmap(G612_puc_Bitmap_MousePointerAreaCustom, C12_COLOR_DARKEST_GRAY, G610_ui_MousePointerAreaUnitWidth << 4);
        L0065_s_Box.X2 = (L0065_s_Box.X1 = L0059_ul_X) + 15;
        L0065_s_Box.Y1 = 0;
        L0065_s_Box.Y2 = 15;
        F132_xzzz_VIDEO_Blit(L0063_puc_Bitmap_ModifiedColors, G612_puc_Bitmap_MousePointerAreaCustom, &L0065_s_Box, 0, 0, C008_BYTE_WIDTH, G610_ui_MousePointerAreaUnitWidth << 3, CM1_COLOR_NO_TRANSPARENCY);
        goto T073_016;
        T073_006:
        G602_B_CurrentMousePointerIsObject = TRUE;
        G609_i_MousePointerAreaLastLineIndex = 17;
        G610_ui_MousePointerAreaUnitWidth = 2;
        G605_i_MousePointerBitmapHotspotX = 8;
        G606_i_MousePointerBitmapHotspotY = 8;
        asm {
                        moveq   #18,L0061_i_Height      /* Height of mouse pointer bitmap */
                        moveq   #17,L0062_i_PixelWidth  /* Width of mouse pointer bitmap - 1 */
        }
        L0063_puc_Bitmap_ModifiedColors = G616_puc_Bitmap_MousePointerModifiedColorsObject;
        L0064_puc_Bitmap_OriginalColors = G615_puc_Bitmap_MousePointerOriginalColorsObject;
        L0068_puc_Bitmap = L0064_puc_Bitmap_OriginalColors;
        asm {
                        subq.w  #8,L0059_ul_X
                        andi.w  #0x000F,L0059_ul_X
                        cmpi.w  #15,L0059_ul_X
                        bne.s   T073_007
                        move.w  #3,G610_ui_MousePointerAreaUnitWidth(A4)
                T073_007:
                        subi.w  #19,L0060_ul_Y
                        ble     T073_014                /* If mouse pointer is not over the middle of the screen */
                        bra.s   T073_010
        }
        T073_008:
        G609_i_MousePointerAreaLastLineIndex = 15;
        G610_ui_MousePointerAreaUnitWidth = 2;
        G605_i_MousePointerBitmapHotspotX = 9;
        G606_i_MousePointerBitmapHotspotY = 7;
        L0061_i_Height = 16;
        L0062_i_PixelWidth = 20;
        L0063_puc_Bitmap_ModifiedColors = G614_puc_Bitmap_MousePointerModifiedColorsChampionIcon;
        L0064_puc_Bitmap_OriginalColors = G613_puc_Bitmap_MousePointerOriginalColorsChampionIcon;
        L0068_puc_Bitmap = L0064_puc_Bitmap_OriginalColors;
        asm {
                        subi.w  #9,L0059_ul_X
                        andi.w  #0x000F,L0059_ul_X
                        cmpi.w  #12,L0059_ul_X
                        blt.s   T073_009                                                /* Mouse pointer visible width is 21 pixels */
                        move.w  #3,G610_ui_MousePointerAreaUnitWidth(A4)
                T073_009:
                        subi.w  #20,L0060_ul_Y
                        ble     T073_014
                T073_010:
                        tst.w   G322_B_PaletteSwitchingEnabled(A4)                      /* Start here if mouse pointer is over the middle of the screen */
                        beq     T073_014                                                /* If palette switching is disabled (dungeon view is not on screen) */
                        cmp.w   L0061_i_Height,L0060_ul_Y
                        blt.s   T073_011_MousePointerAcrossPaletteAreas
                        move.l  L0063_puc_Bitmap_ModifiedColors,L0068_puc_Bitmap(A6)
                        bra     T073_014
        }
        T073_011_MousePointerAcrossPaletteAreas: /* The mouse pointer is a mix of original colors and modified colors */
        if (!(int)L0059_ul_X) {
                L0059_ul_X = (L0061_i_Height - (int)L0060_ul_Y) << 4;
                F007_aAA7_MAIN_CopyBytes(L0064_puc_Bitmap_OriginalColors, G612_puc_Bitmap_MousePointerAreaCustom, (int)L0059_ul_X);
                F007_aAA7_MAIN_CopyBytes((unsigned long)L0063_puc_Bitmap_ModifiedColors + (int)L0059_ul_X, (unsigned long)G612_puc_Bitmap_MousePointerAreaCustom + (int)L0059_ul_X, (int)L0060_ul_Y << 4);
        } else {
                F134_zzzz_VIDEO_FillBitmap(G612_puc_Bitmap_MousePointerAreaCustom, C12_COLOR_DARKEST_GRAY, G610_ui_MousePointerAreaUnitWidth * L0061_i_Height);
                L0060_ul_Y = L0061_i_Height - (int)L0060_ul_Y;
                L0065_s_Box.X2 = (L0065_s_Box.X1 = L0059_ul_X) + L0062_i_PixelWidth;
                L0065_s_Box.Y1 = 0;
                L0065_s_Box.Y2 = (int)L0060_ul_Y - 1;
                F132_xzzz_VIDEO_Blit(L0064_puc_Bitmap_OriginalColors, G612_puc_Bitmap_MousePointerAreaCustom, &L0065_s_Box, 0, 0, C016_BYTE_WIDTH, G610_ui_MousePointerAreaUnitWidth << 3, CM1_COLOR_NO_TRANSPARENCY);
                L0065_s_Box.Y1 = L0060_ul_Y;
                L0065_s_Box.Y2 = L0061_i_Height - 1;
                F132_xzzz_VIDEO_Blit(L0063_puc_Bitmap_ModifiedColors, G612_puc_Bitmap_MousePointerAreaCustom, &L0065_s_Box, 0, (int)L0060_ul_Y, C016_BYTE_WIDTH, G610_ui_MousePointerAreaUnitWidth << 3, CM1_COLOR_NO_TRANSPARENCY);
        }
        goto T073_016;
        T073_014:
        if (!(int)L0059_ul_X) {
                G611_puc_Bitmap_MousePointerArea = L0068_puc_Bitmap;
        } else {
                L0065_s_Box.X2 = (L0065_s_Box.X1 = L0059_ul_X) + L0062_i_PixelWidth;
                L0065_s_Box.Y1 = 0;
                L0065_s_Box.Y2 = L0061_i_Height - 1;
                F134_zzzz_VIDEO_FillBitmap(G612_puc_Bitmap_MousePointerAreaCustom, C12_COLOR_DARKEST_GRAY, G610_ui_MousePointerAreaUnitWidth * L0061_i_Height);
                F132_xzzz_VIDEO_Blit(L0068_puc_Bitmap, G612_puc_Bitmap_MousePointerAreaCustom, &L0065_s_Box, 0, 0, C016_BYTE_WIDTH, G610_ui_MousePointerAreaUnitWidth << 3, CM1_COLOR_NO_TRANSPARENCY);
        }
        T073_016:
        G578_B_UseByteBoxCoordinates = L0066_B_UseByteBoxCoordinatesBackup;
}

VOID F074_xxxx_MOUSE_DrawPointerScreenArea()
{
        asm {
                S074_xxxx_MOUSE_DrawPointerScreenArea:
                        movem.l D0-D7/A0-A2,-(A7)
                        move.w  #TRUE,G595_B_MousePointerVisible(A4)
                        move.w  G607_i_MousePointerScreenAreaNextX(A4),D6
                        move.w  G608_i_MousePointerScreenAreaNextY(A4),D7
                        move.w  D6,G603_i_MousePointerScreenAreaCurrentX(A4)
                        move.w  D7,G604_i_MousePointerScreenAreaCurrentY(A4)
                        moveq   #0,D2
                        sub.w   G605_i_MousePointerBitmapHotspotX(A4),D6
                        bpl.s   T074_001
                        moveq   #0,D6                                                   /* Minimum X coordinate allowed for the mouse pointer screen area, in bytes */
                        moveq   #0,D1
                        moveq   #1,D2
                        bra.s   T074_003
                T074_001:
                        cmpi.w  #272,D6
                        bmi.s   T074_002                                                /* If mouse pointer area is fully visible horizontally on screen 272 + 48 = 320 */
                        move.w  #136,D1                                                 /* Maximum X coordinate allowed for the mouse pointer screen area, in bytes (136 * 2 = 272) */
                        bra.s   T074_004
                T074_002:
                        move.w  D6,D1
                T074_003:
                        andi.w  #0xFFF0,D1                                              /* X coordinate of the first 16 pixels block containing the resulting coordinate */
                        lsr.w   #1,D1                                                   /* X coordinate, in bytes, of the first 16 pixels block containing the resulting coordinate */
                T074_004:
                        swap    D2
                        sub.w   G606_i_MousePointerBitmapHotspotY(A4),D7
                        bpl.s   T074_005
                        move.w  D7,D2
                        moveq   #0,D7                                                   /* Minimum Y coordinate allowed for the mouse pointer screen area, in bytes */
                        neg.w   D2
                        bra.s   T074_007
                T074_005:
                        cmpi.w  #182,D7
                        bmi.s   T074_006                                                /* Branch if D7 < 182. If mouse pointer area is fully visible vertically on screen 182 + 18 = 200 */
                        addi.w  #29120,D1                                               /* Maximum Y coordinate allowed for the mouse pointer screen area, in bytes (182 * 160 = 29120) */
                        bra.s   T074_007
                T074_006:
                        move.w  D7,D0
                        lsl.w   #5,D0
                        add.w   D0,D1
                        add.w   D0,D0
                        add.w   D0,D0
                        add.w   D0,D1                                                   /* D1 = D1 + (D7 * 160) */
                T074_007:
                        movea.l D2,A2                                                   /* Backup D2 into A2 */
                        movea.w D1,A0
                        adda.l  G348_pl_Bitmap_LogicalScreenBase(A4),A0
                        move.l  A0,G617_puc_Bitmap_MousePointerScreenArea(A4)
                        movea.l G618_puc_Bitmap_MousePointerHiddenScreenArea(A4),A1     /* This is a 432 bytes buffer. Below are 18 copy operations of 24 bytes (6 registers of 4 bytes each) = 432 bytes */
                        lea     432(A1),A1                                              /* Copy screen area to G618_puc_Bitmap_MousePointerHiddenScreenArea */
                        movem.l 2720(A0),D0-D5                                          /* BUG0_01 Memory after the screen memory is overwritten when drawing the mouse pointer when it is located at the bottom of the screen. This has no consequence because the screen memory is located at the end of the RAM */
                        movem.l D0-D5,-(A1)
                        movem.l 2560(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 2400(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 2240(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 2080(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 1920(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 1760(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 1600(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 1440(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 1280(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 1120(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 960(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 800(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 640(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 480(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 320(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l 160(A0),D0-D5
                        movem.l D0-D5,-(A1)
                        movem.l (A0),D0-D5
                        movem.l D0-D5,-(A1)
                        move.w  G609_i_MousePointerAreaLastLineIndex(A4),D0
                        move.w  G610_ui_MousePointerAreaUnitWidth(A4),D1
                        movea.l G611_puc_Bitmap_MousePointerArea(A4),A1
                        move.w  A2,D2                                                   /* Restore D2 from A2 */
                        beq.s   T074_008
                        sub.w   D2,D0
                        mulu.w  D1,D2
                        lsl.w   #3,D2
                        adda.w  D2,A1
                        bra.s   T074_009
                T074_008:
                        move.w  D0,D3
                        add.w   D7,D3
                        subi.w  #200,D3
                        bmi.s   T074_009
                        sub.w   D3,D0
                T074_009:
                        move.l  A2,D2
                        swap    D2
                        tst.w   D2
                        beq.s   T074_012
                T074_010:
                        subq.w  #2,D1
                        bne.s   T074_011
                        lea     T074_020(PC),A2
                        move.w  #152,D5
                        bra.s   T074_016
                T074_011:
                        lea     T074_018(PC),A2
                        move.w  #144,D5
                        bra.s   T074_016
                T074_012:
                        move.w  D1,D3
                        lsl.w   #4,D3
                        add.w   D6,D3
                        subi.w  #336,D3
                        bmi.s   T074_013
                        subq.l  #8,A1
                        bra.s   T074_010
                T074_013:
                        subq.w  #2,D1
                        bpl.s   T074_014
                        lea     T074_021(PC),A2
                        move.w  #152,D5
                        bra.s   T074_016
                T074_014:
                        bne.s   T074_015
                        lea     T074_019(PC),A2
                        move.w  #144,D5
                        bra.s   T074_016
                T074_015:
                        lea     T074_017(PC),A2
                        move.w  #136,D5
                T074_016:
                        andi.w  #0xFFF0,D6
                        lsr.w   #1,D6
                        lsl.w   #5,D7
                        add.w   D7,D6
                        add.w   D7,D7
                        add.w   D7,D7
                        add.w   D7,D6                                                   /* D6 = D6 + 160 * D7 */
                        movea.w D6,A0
                        adda.l  G348_pl_Bitmap_LogicalScreenBase(A4),A0
                        move.w  D0,D7
                        jmp     (A2)
                T074_017:
                        movem.w (A1),D0-D3
                        move.w  D2,D4
                        and.w   D3,D4
                        not.w   D4
                        or.w    D0,D4
                        or.w    D1,D4
                        swap    D0
                        move.w  D1,D0
                        swap    D2
                        move.w  D3,D2
                        move.w  D4,D3
                        swap    D4
                        move.w  D3,D4
                        and.l   D4,D0
                        and.l   D4,D2
                        not.l   D4
                        and.l   D4,(A0)
                        or.l    D0,(A0)+
                        and.l   D4,(A0)
                        or.l    D2,(A0)+
                T074_018:
                        addq.l  #8,A1
                T074_019:
                        movem.w (A1),D0-D3
                        move.w  D2,D4
                        and.w   D3,D4
                        not.w   D4
                        or.w    D0,D4
                        or.w    D1,D4
                        swap    D0
                        move.w  D1,D0
                        swap    D2
                        move.w  D3,D2
                        move.w  D4,D3
                        swap    D4
                        move.w  D3,D4
                        and.l   D4,D0
                        and.l   D4,D2
                        not.l   D4
                        and.l   D4,(A0)
                        or.l    D0,(A0)+
                        and.l   D4,(A0)
                        or.l    D2,(A0)+
                T074_020:
                        addq.l  #8,A1
                T074_021:
                        movem.w (A1)+,D0-D3
                        move.w  D2,D4
                        and.w   D3,D4
                        not.w   D4
                        or.w    D0,D4
                        or.w    D1,D4
                        swap    D0
                        move.w  D1,D0
                        swap    D2
                        move.w  D3,D2
                        move.w  D4,D3
                        swap    D4
                        move.w  D3,D4
                        and.l   D4,D0
                        and.l   D4,D2
                        not.l   D4
                        and.l   D4,(A0)
                        or.l    D0,(A0)+
                        and.l   D4,(A0)
                        or.l    D2,(A0)+
                        adda.w  D5,A0
                        subq.w  #1,D7
                        bmi.s   T074_022_Return
                        jmp     (A2)
                T074_022_Return:
                        movem.l (A7)+,D0-D7/A0-A2
                        rts
        }
}

VOID F075_xxxx_MOUSE_Exception70Handler_IKBD_MIDI_MouseStatus()
{
        asm {
                S075_aaak_MOUSE_Exception70Handler_IKBD_MIDI_MouseStatus:
                        movem.l D0/A4,-(A7)
                        movea.l V011_1_xxx_RegisterA4Backup(PC),A4                              /* Restore A4 */
                        move.b  (A0),D0                                                         /* Get current mouse status (from the IKBD keyboard controller) */
                        andi.w  #0x0003,D0                                                      /* These bits give the status of each mouse button (bit 0 for right button, bit 1 for left button) */
                        cmp.w   G588_i_MouseButtonsStatus(A4),D0
                        beq.s   T075_001                                                        /* If the state of mouse buttons has not changed since last time */
                        move.l  A5,-(A7)
                        movea.l V012_1_xxx_RegisterA5Backup(PC),A5                              /* Restore A5 (address of the JUMPTABLE) */
                        jsr     S076_aaal_MOUSE_OnMouseButtonsStatusChange(PC)
                        movea.l (A7)+,A5
                T075_001:
                        tst.w   G597_B_IgnoreMouseMovements(A4)
                        bne.s   T075_008_Return
                        move.b  1(A0),D0                                                        /* DeltaX. A signed byte from the IKBD keyboard controller describing the accumulated motion */
                        ext.w   D0
                        beq.s   T075_004                                                        /* If there was no motion on the X axis since last time */
                        add.w   G589_i_MousePointerHotspotX(A4),D0
                        bpl.s   T075_002
                        clr.w   D0                                                              /* The minimum possible value is 0 */
                T075_002:
                        cmpi.w  #319,D0
                        ble.s   T075_003
                        move.w  #319,D0                                                         /* The maximum possible value is 319 */
                T075_003:
                        move.w  D0,G589_i_MousePointerHotspotX(A4)
                T075_004:
                        move.b  2(A0),D0                                                        /* DeltaY. A signed byte from the IKBD keyboard controller describing the accumulated motion */
                        ext.w   D0
                        beq.s   T075_007
                        add.w   G590_i_MousePointerHotspotY(A4),D0
                        bpl.s   T075_005
                        clr.w   D0                                                              /* The minimum possible value is 0 */
                T075_005:
                        cmpi.w  #199,D0
                        ble.s   T075_006
                        move.w  #199,D0                                                         /* The maximum possible value is 199 */
                T075_006:
                        move.w  D0,G590_i_MousePointerHotspotY(A4)
                T075_007:
                        tst.w   G594_B_BuildMousePointerScreenAreaRequestedInMouseException(A4)
                        beq.s   T075_008_Return
                        move.w  #TRUE,G592_B_BuildMousePointerScreenAreaRequested(A4)
                T075_008_Return:
                        movem.l (A7)+,D0/A4
                        rts
        }
}
VOID F076_xxxx_MOUSE_OnMouseButtonsStatusChange()
{
        static BOOLEAN G623_B_Mouse_OnButtonsStatusChangeSemaphore = FALSE;


        asm {
                S076_aaal_MOUSE_OnMouseButtonsStatusChange:
                        tas     G623_B_Mouse_OnButtonsStatusChangeSemaphore(A4)         /* This instruction makes sure that a click on a button will be processed only once */
                        beq.s   T076_001                                                /* Branch if the value WAS 0 before the tas instruction. If a mouse click is not already being processed */
                        rts
                T076_001:
                        movem.l D0-D3/A0-A1,-(A7)
                        tst.w   G588_i_MouseButtonsStatus(A4)
                        beq.s   T076_002                                                /* If no buttons were pressed in the previous status (as the status has changed, it means a button was pressed) */
                        tst.w   D0
                        bne.s   T076_005                                                /* If a button is pressed in the current status */
                T076_002:
                        move.w  D0,G588_i_MouseButtonsStatus(A4)                        /* Update variable with new buttons status */
                        beq.s   T076_003                                                /* If no buttons are pressed in the current status (as the status has changed, it means a button was released) */
                        move.l  G590_i_MousePointerHotspotY(A4),D1                      /* Current mouse pointer absolute coordinates (moving a long moves both words for X and Y coordinates) The least significant word of D1 contains the X coordinate */
                        move.l  D1,D2
                        swap    D2                                                      /* The least significant word of D2 now contains the Y coordinates */
                        move.w  D0,-(A7)
                        move.w  D2,-(A7)
                        move.w  D1,-(A7)
                        jsr     F359_hzzz_COMMAND_ProcessClick_COPYPROTECTIONC(PC)
                        addq.l  #6,A7
                        bra.s   T076_005
                T076_003:
                        tst.w   G331_B_PressingEye(A4)
                        beq.s   T076_004                                                /* If the player is not pressing the Eye icon */
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_02_FIX Do not clear G331_B_PressingEye immediately when the mouse button is released so that its value cannot change while processing F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC. G331_B_PressingEye is now cleared in F002_xxxx_MAIN_GameLoop_COPYPROTECTIONDF */
                        clr.w   G331_B_PressingEye(A4)
#endif
                        clr.w   G597_B_IgnoreMouseMovements(A4)                         /* As the button has been released, mouse movements should not be ignored anymore */
                        move.w  #TRUE,G332_B_StopPressingEye(A4)                        /* This will instruct the main loop to stop pressing eye */
                        bra.s   T076_005
                T076_004:
                        tst.w   G333_B_PressingMouth(A4)
                        beq.s   T076_005                                                /* If the player is not pressing the Mouth icon */
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_02_FIX Do not clear G333_B_PressingMouth immediately when the mouse button is released so that its value cannot change while processing F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC. G333_B_PressingMouth is now cleared in F002_xxxx_MAIN_GameLoop_COPYPROTECTIONDF */
                        clr.w   G333_B_PressingMouth(A4)
#endif
                        clr.w   G597_B_IgnoreMouseMovements(A4)                         /* As the button has been released, mouse movements should not be ignored anymore */
                        move.w  #TRUE,G334_B_StopPressingMouth(A4)                      /* This will instruct the main loop to stop pressing mouth */
                T076_005:
                        clr.w   G623_B_Mouse_OnButtonsStatusChangeSemaphore(A4)         /* Clear semaphore to mark the end of the processing of the buttons status change */
                        movem.l (A7)+,D0-D3/A0-A1
                        rts
        }
}

VOID F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE()
{
        if (G587_i_HideMousePointerRequestCount++ == 0) {
                G596_B_NoDrawInVerticalBlankWhileHidingMousePointer = TRUE;
                G594_B_BuildMousePointerScreenAreaRequestedInMouseException = FALSE;
                G592_B_BuildMousePointerScreenAreaRequested = FALSE;
                G593_B_BuildMousePointerScreenAreaCompleted = FALSE;
                if (G595_B_MousePointerVisible != FALSE) {
                        G595_B_MousePointerVisible = FALSE;
                        S072_xxxx_MOUSE_DrawPointerHiddenScreenArea();
                }
                G596_B_NoDrawInVerticalBlankWhileHidingMousePointer = FALSE;
        }
#ifndef NOCOPYPROTECTION
        if ((G488_i_Graphic560_RequestCheckFuzzyBitCount_COPYPROTECTIONE != C12777_FALSE) && !F356_ozzz_COPYPROTECTIONE_IsSector7Valid_ByteValuesAndFuzzyBitCount(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE)) {
                G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE = C01113_TRUE;
        }
#endif
}

VOID F078_xzzz_MOUSE_ShowPointer()
{
        if (G587_i_HideMousePointerRequestCount-- == 1) {
                G592_B_BuildMousePointerScreenAreaRequested = G594_B_BuildMousePointerScreenAreaRequestedInMouseException = TRUE;
        }
}
