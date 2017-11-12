#include "DEFS.H"

/*_Global variables_*/
char G353_ac_StringBuildBuffer[128];
int G354_i_MessageAreaScrollingLineCount = -1;
BOOLEAN G355_B_ScrollMessageArea;
unsigned char* G356_puc_Bitmap_MessageAreaNewRow; /* Width = 320 pixels = 160 bytes, Height = 7 pixels */
unsigned char* G357_puc_InterfaceAndScrollsFont;
int G358_i_MessageAreaCursorRow;
int G359_i_MessageAreaCursorColumn;
long G360_al_MessageAreaRowExpirationTime[4];


overlay "main"

VOID F040_aacZ_TEXT_Print(P050_puc_Bitmap_Destination, P051_ui_ByteWidth, P052_ui_X , P053_ui_Y, P054_i_TextColor, P055_i_BackgroundColor, P056_pc_String)
unsigned char* P050_puc_Bitmap_Destination;
unsigned int P051_ui_ByteWidth;
unsigned int P052_ui_X;
unsigned int P053_ui_Y;
int P054_i_TextColor;
int P055_i_BackgroundColor;
char* P056_pc_String;
{
        asm {
                        movem.l D4-D7/A2-A3,-(A7)
                        movea.l P050_puc_Bitmap_Destination(A6),A3
                        move.w  P052_ui_X(A6),D7
                        move.w  P053_ui_Y(A6),D6
                        move.w  P054_i_TextColor(A6),D5
                        move.w  P055_i_BackgroundColor(A6),D4
                        movea.l P056_pc_String(A6),A0
                        move.b  (A0),D0                                         /* First character of specified string */
                        bne.s   T040_001                                        /* If the string is not empty */
                        bra     T040_043_Return
                T040_001:
                        move.w  D6,D0
                        subq.w  #4,D0
                        mulu.w  P051_ui_ByteWidth(A6),D0                        /* Width is the number of bytes for one line (e.g. '160' for 320 pixels) */
                        adda.w  D0,A3                                           /* Address of the pixel line where printing will start */
                        move.w  D7,D0                                           /* X coordinate */
                        andi.w  #0xFFF0,D0                                      /* Multiple of 16 pixels */
                        lsr.w   #1,D0                                           /* Number of bytes */
                        adda.w  D0,A3                                           /* Address of the first word where printing will start */
                        moveq   #0x0F,D3
                        and.w   D7,D3                                           /* Index of the first bit / pixel to modify in the word */
                        move.w  D5,D1                                           /* Text color */
                        add.w   D5,D5
                        add.w   D1,D5
                        add.w   D5,D5                                           /* 6 * Text color (Each entry in the jumptable below is 6 bytes large) */
                        jmp     2(PC,D5.w)
                T040_002:
                        lea     T040_025_TextColor0(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_010_TextColor1(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_011_TextColor2(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_012_TextColor3(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_013_TextColor4(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_014_TextColor5(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_015_TextColor6(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_016_TextColor7(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_017_TextColor8(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_018_TextColor9(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_019_TextColor10(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_020_TextColor11(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_021_TextColor12(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_022_TextColor13(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_023_TextColor14(PC),A0
                        bra.s   T040_003_SwitchTextColor
                        lea     T040_024_TextColor15(PC),A0
                T040_003_SwitchTextColor:
                        move.w  D4,D1                                           /* Background color */
                        add.w   D4,D4
                        add.w   D1,D4
                        add.w   D4,D4                                           /* 6 * Background color (Each entry in the jumptable below is 6 bytes large) */
                        jmp     2(PC,D4.w)
                T040_004_SwitchBackgroundColor:
                        lea     T040_041_BackgroundColor0(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_026_BackgroundColor1(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_027_BackgroundColor2(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_028_BackgroundColor3(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_029_BackgroundColor4(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_030_BackgroundColor5(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_031_BackgroundColor6(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_032_BackgroundColor7(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_033_BackgroundColor8(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_034_BackgroundColor9(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_035_BackgroundColor10(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_036_BackgroundColor11(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_037_BackgroundColor12(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_038_BackgroundColor13(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_039_BackgroundColor14(PC),A1
                        bra.s   T040_005_Loop
                        lea     T040_040_BackgroundColor15(PC),A1
                T040_005_Loop:
                        moveq   #0,D2
                        movea.l P056_pc_String(A6),A2
                        move.b  (A2),D2                                         /* Next character in the specified string */
                        beq     T040_043_Return                                 /* If this is the end of the string */
                        addq.l  #1,P056_pc_String(A6)                           /* Proceed to the next character in the specified string */
                        movea.l G357_puc_InterfaceAndScrollsFont(A4),A2
                        lea     0(A2,D2.w),A2                                   /* Address of the character in the font (top left corner) */
                        cmp.w   #11,D3                                          /* If bit index to modify in word > 11. If character is across two words (the width of each character is 5 bits per pixels) */
                        bhi.s   T040_006_CharacterSpans2Words
                        moveq   #6,D4
                        move.l  #0x07FF07FF,D2                                  /* Mask with 5 bits clear */
                        ror.l   D3,D2                                           /* Rotate bits in D2 to the right by D3 cells. The bits shifted out to the right are shifted in to the left. Rotate the bits so that the 5 clear bits are cellned correctly */
                        moveq   #0,D5
                        move.l  A3,-(A7)
                        bsr.s   T040_007_PrintCharacter
                        movea.l (A7)+,A3
                        addq.w  #6,D3                                           /* Proceed to the next character cell (5 bits per character + 1 bit for spacing) */
                        cmpi.w  #16,D3
                        bcs.s   T040_005_Loop                                   /* If still in the same word */
                        andi.w  #0x0001,D3                                      /* D3 = 16 or 17 (before). D3 = 0 or 1 (after) */
                        addq.l  #8,A3                                           /* Proceed to the next set of 4 words (16 pixels) */
                        bra.s   T040_005_Loop
                T040_006_CharacterSpans2Words:
                        moveq   #6,D4
                        move.l  A3,-(A7)
                        addq.l  #8,(A7)
                        move.l  A2,-(A7)
                        lsl.w   #2,D3                                           /* D3 is 12..15 (before). D3 is 48..60 (after) */
                        lea     G064_al_Graphic562_PrintTextMasks2-48(A4),A2
                        move.l  0(A2,D3.w),D2
                        lea     G065_al_Graphic562_PrintTextMasks1-48(A4),A2
                        move.l  0(A2,D3.w),-(A7)
                        lsr.w   #2,D3
                        movea.l 4(A7),A2
                        moveq   #0x08,D5
                        bsr.s   T040_007_PrintCharacter
                        move.l  (A7)+,D2
                        movea.l (A7)+,A2
                        movea.l (A7),A3
                        moveq   #0x06,D4
                        moveq   #0x12,D5
                        bsr.s   T040_007_PrintCharacter
                        movea.l (A7)+,A3
                        subi.w  #0x000A,D3
                        bra.s   T040_005_Loop
                T040_007_PrintCharacter:
                        and.l   D2,(A3)
                        and.l   D2,4(A3)
                        moveq   #0,D0
                        move.b  (A2),D0
                        jmp     2(PC,D5.w)
                T040_008:
                        moveq   #0x0B,D1
                        sub.w   D3,D1
                        lsl.w   D1,D0
                        bra.s   T040_009
                        move.w  D3,D1
                        subi.w  #0x000B,D1
                        lsr.w   D1,D0
                        bra.s   T040_009
                        moveq   #0x1B,D1
                        sub.w   D3,D1
                        lsl.w   D1,D0
                T040_009:
                        move.w  D0,D1
                        swap    D1
                        move.w  D0,D1
                        swap    D0
                        moveq   #0,D6
                        moveq   #0,D7
                        jmp     (A0)
                T040_010_TextColor1:
                        move.l  D0,D6
                        bra.s   T040_025_TextColor0
                T040_011_TextColor2:
                        move.w  D1,D6
                        bra.s   T040_025_TextColor0
                T040_012_TextColor3:
                        move.l  D1,D6
                        bra.s   T040_025_TextColor0
                T040_013_TextColor4:
                        move.l  D0,D7
                        bra.s   T040_025_TextColor0
                T040_014_TextColor5:
                        move.l  D0,D6
                        move.l  D0,D7
                        bra.s   T040_025_TextColor0
                T040_015_TextColor6:
                        move.w  D1,D6
                        move.l  D0,D7
                        bra.s   T040_025_TextColor0
                T040_016_TextColor7:
                        move.l  D1,D6
                        move.l  D0,D7
                        bra.s   T040_025_TextColor0
                T040_017_TextColor8:
                        move.w  D1,D7
                        bra.s   T040_025_TextColor0
                T040_018_TextColor9:
                        move.l  D0,D6
                        move.w  D1,D7
                        bra.s   T040_025_TextColor0
                T040_019_TextColor10:
                        move.w  D1,D6
                        move.w  D1,D7
                        bra.s   T040_025_TextColor0
                T040_020_TextColor11:
                        move.l  D1,D6
                        move.w  D1,D7
                        bra.s   T040_025_TextColor0
                T040_021_TextColor12:
                        move.l  D1,D7
                        bra.s   T040_025_TextColor0
                T040_022_TextColor13:
                        move.l  D0,D6
                        move.l  D1,D7
                        bra.s   T040_025_TextColor0
                T040_023_TextColor14:
                        move.w  D1,D6
                        move.l  D1,D7
                        bra.s   T040_025_TextColor0
                T040_024_TextColor15:
                        move.l  D1,D6
                        move.l  D1,D7
                T040_025_TextColor0:
                        or.l    D2,D0
                        not.l   D0
                        clr.w   D0
                        or.l    D2,D1
                        not.l   D1
                        jmp     (A1)
                T040_026_BackgroundColor1:
                        or.l    D0,D6
                        bra.s   T040_041_BackgroundColor0
                T040_027_BackgroundColor2:
                        or.w    D1,D6
                        bra.s   T040_041_BackgroundColor0
                T040_028_BackgroundColor3:
                        or.l    D1,D6
                        bra.s   T040_041_BackgroundColor0
                T040_029_BackgroundColor4:
                        or.l    D0,D7
                        bra.s   T040_041_BackgroundColor0
                T040_030_BackgroundColor5:
                        or.l    D0,D6
                        or.l    D0,D7
                        bra.s   T040_041_BackgroundColor0
                T040_031_BackgroundColor6:
                        or.w    D1,D6
                        or.l    D0,D7
                        bra.s   T040_041_BackgroundColor0
                T040_032_BackgroundColor7:
                        or.l    D1,D6
                        or.l    D0,D7
                        bra.s   T040_041_BackgroundColor0
                T040_033_BackgroundColor8:
                        or.w    D1,D7
                        bra.s   T040_041_BackgroundColor0
                T040_034_BackgroundColor9:
                        or.l    D0,D6
                        or.w    D1,D7
                        bra.s   T040_041_BackgroundColor0
                T040_035_BackgroundColor10:
                        or.w    D1,D6
                        or.w    D1,D7
                        bra.s   T040_041_BackgroundColor0
                T040_036_BackgroundColor11:
                        or.l    D1,D6
                        or.w    D1,D7
                        bra.s   T040_041_BackgroundColor0
                T040_037_BackgroundColor12:
                        or.l    D1,D7
                        bra.s   T040_041_BackgroundColor0
                T040_038_BackgroundColor13:
                        or.l    D0,D6
                        or.l    D1,D7
                        bra.s   T040_041_BackgroundColor0
                T040_039_BackgroundColor14:
                        or.w    D1,D6
                        or.l    D1,D7
                        bra.s   T040_041_BackgroundColor0
                T040_040_BackgroundColor15:
                        or.l    D1,D6
                        or.l    D1,D7
                T040_041_BackgroundColor0:
                        or.l    D6,(A3)
                        or.l    D7,4(A3)
                        subq.w  #1,D4
                        bne.s   T040_042
                        rts
                T040_042:
                        lea     128(A2),A2
                        adda.w  P051_ui_ByteWidth(A6),A3                        /* Width is the number of bytes for one line (e.g. '160' for 320 pixels) */
                        bra     T040_007_PrintCharacter
                T040_043_Return:
                        movem.l (A7)+,D4-D7/A2-A3
        }
}

VOID F041_aadZ_TEXT_PrintWithTrailingSpaces(P057_puc_Bitmap_Destination, P058_i_ByteWidth, P059_i_X, P060_i_Y, P061_i_TextColor, P062_i_BackgroundColor, P063_pc_String, P064_i_StringLength)
unsigned char* P057_puc_Bitmap_Destination;
int P058_i_ByteWidth;
int P059_i_X;
int P060_i_Y;
int P061_i_TextColor;
int P062_i_BackgroundColor;
register char* P063_pc_String;
int P064_i_StringLength;
{
        register int L0021_i_CharacterIndex;
        char L0022_ac_String[80];


        L0021_i_CharacterIndex = 0;
        while (L0022_ac_String[L0021_i_CharacterIndex] = *P063_pc_String++) {
                L0021_i_CharacterIndex++;
        }
        while (L0021_i_CharacterIndex < P064_i_StringLength) {
                L0022_ac_String[L0021_i_CharacterIndex] = ' ';
                L0021_i_CharacterIndex++;
        }
        L0022_ac_String[L0021_i_CharacterIndex] = '\0';
        F040_aacZ_TEXT_Print(P057_puc_Bitmap_Destination, P058_i_ByteWidth, P059_i_X, P060_i_Y, P061_i_TextColor, P062_i_BackgroundColor, L0022_ac_String);
}

VOID F042_xxxx_TEXT_MESSAGEAREA_MoveCursor(P065_i_Column, P066_i_Row)
register int P065_i_Column;
register int P066_i_Row;
{
        if (P065_i_Column < 0) {
                P065_i_Column = 0;
        } else {
                if (P065_i_Column >= 53) {
                        P065_i_Column = 52;
                }
        }
        G359_i_MessageAreaCursorColumn = P065_i_Column;
        if (P066_i_Row < 0) {
                P066_i_Row = 0;
        } else {
                if (P066_i_Row >= 4) {
                        P066_i_Row = 3;
                }
        }
        G358_i_MessageAreaCursorRow = P066_i_Row;
}

VOID F043_aahz_TEXT_MESSAGEAREA_ClearAllRows()
{
        register unsigned int L0023_ui_RowIndex;
        BOX_WORD L0024_s_Box;


        G578_B_UseByteBoxCoordinates = FALSE;
        L0024_s_Box.X1 = 0;
        L0024_s_Box.X2 = 319;
        L0024_s_Box.Y1 = 169;
        L0024_s_Box.Y2 = 199;
        while ((G354_i_MessageAreaScrollingLineCount >= 0) || G355_B_ScrollMessageArea);
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &L0024_s_Box, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
        F078_xzzz_MOUSE_ShowPointer();
        G358_i_MessageAreaCursorRow = 3;
        G359_i_MessageAreaCursorColumn = 0;
        for(L0023_ui_RowIndex = 0; L0023_ui_RowIndex < 4; L0023_ui_RowIndex++) {
                G360_al_MessageAreaRowExpirationTime[L0023_ui_RowIndex] = -1;
        }
}

VOID F044_xxxx_TEXT_MESSAGEAREA_ClearExpiredRows()
{
        register int L0025_i_Unreferenced; /* BUG0_00 Useless code */
        register unsigned int L0026_ui_RowIndex;
        register long L0027_l_ExpirationTime;
        BOX_WORD L0028_s_Box;


        G578_B_UseByteBoxCoordinates = FALSE;
        L0028_s_Box.X1 = 0;
        L0028_s_Box.X2 = 319;
        for(L0026_ui_RowIndex = 0; L0026_ui_RowIndex < 4; L0026_ui_RowIndex++) {
                L0027_l_ExpirationTime = G360_al_MessageAreaRowExpirationTime[L0026_ui_RowIndex];
                if ((L0027_l_ExpirationTime == -1) || (L0027_l_ExpirationTime > G313_ul_GameTime)) {
                        continue;
                }
                L0028_s_Box.Y2 = (L0028_s_Box.Y1 = 172 + (L0026_ui_RowIndex * 7)) + 6;
                while ((G354_i_MessageAreaScrollingLineCount >= 0) || G355_B_ScrollMessageArea);
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &L0028_s_Box, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                F078_xzzz_MOUSE_ShowPointer();
                G360_al_MessageAreaRowExpirationTime[L0026_ui_RowIndex] = -1;
        }
}

VOID F045_xxxx_TEXT_MESSAGEAREA_CreateNewRow()
{
        register unsigned int L0029_ui_RowIndex;


        if (G358_i_MessageAreaCursorRow == 3) {
                while ((G354_i_MessageAreaScrollingLineCount >= 0) || G355_B_ScrollMessageArea);
                F008_aA19_MAIN_ClearBytes(G356_puc_Bitmap_MessageAreaNewRow, C160_BYTE_WIDTH_SCREEN * 7);
                G354_i_MessageAreaScrollingLineCount = 0;
                for(L0029_ui_RowIndex = 0; L0029_ui_RowIndex < 3; L0029_ui_RowIndex++) {
                        G360_al_MessageAreaRowExpirationTime[L0029_ui_RowIndex] = G360_al_MessageAreaRowExpirationTime[L0029_ui_RowIndex + 1];
                }
                G360_al_MessageAreaRowExpirationTime[3] = -1;
        } else {
                G358_i_MessageAreaCursorRow++;
        }
}

VOID F046_xxxx_TEXT_MESSAGEAREA_PrintString(P067_i_TextColor, P068_pc_String)
int P067_i_TextColor;
register char* P068_pc_String;
{
        register int L0030_i_StringLength;


        L0030_i_StringLength = strlen(P068_pc_String);
        if (G354_i_MessageAreaScrollingLineCount == -1) {
                while (G355_B_ScrollMessageArea);
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F053_aajz_TEXT_PrintToLogicalScreen(G359_i_MessageAreaCursorColumn * 6, (G358_i_MessageAreaCursorRow * 7) + 177, P067_i_TextColor, C00_COLOR_BLACK, P068_pc_String);
                F078_xzzz_MOUSE_ShowPointer();
        } else {
                F040_aacZ_TEXT_Print(G356_puc_Bitmap_MessageAreaNewRow, C160_BYTE_WIDTH_SCREEN, G359_i_MessageAreaCursorColumn * 6, 5, P067_i_TextColor, C00_COLOR_BLACK, P068_pc_String);
                if (G354_i_MessageAreaScrollingLineCount == -1) {
                        G355_B_ScrollMessageArea = TRUE;
                }
        }
        G359_i_MessageAreaCursorColumn += L0030_i_StringLength;
        G360_al_MessageAreaRowExpirationTime[G358_i_MessageAreaCursorRow] = G313_ul_GameTime + 70;
}

VOID F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(P069_i_TextColor, P070_pc_String)
register int P069_i_TextColor;
register char* P070_pc_String;
{
        register unsigned int L0031_ui_CharacterIndex;
        int L0032_i_SpaceString;
        char L0033_ac_String[54];


        while (*P070_pc_String) {
                if (*P070_pc_String == '\n') { /* New line */
                        P070_pc_String++;
                        if ((G359_i_MessageAreaCursorColumn != 0) || (G358_i_MessageAreaCursorRow != 0)) {
                                G359_i_MessageAreaCursorColumn = 0;
                                F045_xxxx_TEXT_MESSAGEAREA_CreateNewRow();
                        }
                        continue;
                }
                if (*P070_pc_String == ' ') {
                        P070_pc_String++;
                        if (G359_i_MessageAreaCursorColumn != 53) {
                                L0032_i_SpaceString = 0x2000;
                                F046_xxxx_TEXT_MESSAGEAREA_PrintString(P069_i_TextColor, &L0032_i_SpaceString);
                        }
                        continue;
                }
                L0031_ui_CharacterIndex = 0;
                do {
                        L0033_ac_String[L0031_ui_CharacterIndex++] = *P070_pc_String++;
                } while (*P070_pc_String && (*P070_pc_String != ' ') && (*P070_pc_String != '\n')); /* End of string, space or New line */
                L0033_ac_String[L0031_ui_CharacterIndex] = '\0';
                if (G359_i_MessageAreaCursorColumn + L0031_ui_CharacterIndex > 53) {
                        G359_i_MessageAreaCursorColumn = 2;
                        F045_xxxx_TEXT_MESSAGEAREA_CreateNewRow();
                }
                F046_xxxx_TEXT_MESSAGEAREA_PrintString(P069_i_TextColor, L0033_ac_String);
        }
}

VOID F048_xxxx_TEXT_MESSAGEAREA_PrintCharacter_Unreferenced(P071_i_TextColor, P072_c_Character) /* BUG0_00 Useless code */
int P071_i_TextColor;
char P072_c_Character;
{
        char L0034_ac_String[2];


        L0034_ac_String[0] = P072_c_Character;
        L0034_ac_String[1] = '\0';
        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(P071_i_TextColor, L0034_ac_String);
}

VOID F049_xxxx_TEXT_MESSAGEAREA_PrintInteger_Unreferenced(P073_i_TextColor, P074_ui_Integer) /* BUG0_00 Useless code */
int P073_i_TextColor;
register unsigned int P074_ui_Integer;
{
        register unsigned int L0035_ui_CharacterIndex;
        char L0036_ac_String[8];


        L0035_ui_CharacterIndex = 7;
        L0036_ac_String[7] = '\0';
        do {
                L0036_ac_String[--L0035_ui_CharacterIndex] = '0' + (P074_ui_Integer % 10);
        } while (P074_ui_Integer /= 10);
        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(P073_i_TextColor, &L0036_ac_String[L0035_ui_CharacterIndex]);
}

VOID F050_xxxx_TEXT_MESSAGEAREA_PrintSpace_Unreferenced() /* BUG0_00 Useless code */
{
        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C15_COLOR_WHITE, " ");
}

VOID F051_AA19_TEXT_MESSAGEAREA_PrintLineFeed()
{
        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C00_COLOR_BLACK, G066_ac_Graphic562_LineFeedCharacterString);
}

VOID F052_aaoz_TEXT_PrintToViewport(P075_i_X, P076_i_Y, P077_i_TextColor, P078_pc_String)
int P075_i_X;
int P076_i_Y;
int P077_i_TextColor;
char* P078_pc_String;
{
        F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, P075_i_X , P076_i_Y, P077_i_TextColor, C12_COLOR_DARKEST_GRAY, P078_pc_String);
}

VOID F053_aajz_TEXT_PrintToLogicalScreen(P079_i_X, P080_i_Y, P081_i_TextColor, P082_i_BackgroundColor, P083_pc_String)
int P079_i_X;
int P080_i_Y;
int P081_i_TextColor;
int P082_i_BackgroundColor;
char* P083_pc_String;
{
        F040_aacZ_TEXT_Print(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, P079_i_X , P080_i_Y, P081_i_TextColor, P082_i_BackgroundColor, P083_pc_String);
}

VOID F054_aAA1_TEXT_Initialize()
{
        register unsigned int L0037_ui_LineIndex;


        F042_xxxx_TEXT_MESSAGEAREA_MoveCursor(0, 3);
        G356_puc_Bitmap_MessageAreaNewRow = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(320, 7), C1_ALLOCATION_PERMANENT);
        G357_puc_InterfaceAndScrollsFont = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)(M75_BITMAP_BYTE_COUNT(1024, 6) / 4), C1_ALLOCATION_PERMANENT); /* The color depth of the font bitmap is 1 bit per pixel instead of 4 for all other bitmaps */
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C557_GRAPHIC_FONT, G357_puc_InterfaceAndScrollsFont); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 4 parameters. No consequence because the missing parameters are not used when MASK0x8000_NOT_EXPANDED is specified */
        for(L0037_ui_LineIndex = 0; L0037_ui_LineIndex < 4; L0037_ui_LineIndex++) {
                G360_al_MessageAreaRowExpirationTime[L0037_ui_LineIndex] = -1;
        }
}
