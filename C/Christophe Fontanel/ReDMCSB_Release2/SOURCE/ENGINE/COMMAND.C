#include "DEFS.H"

/*_Global variables_*/
COMMAND G432_as_CommandQueue[5]; /* Circular queue. Can only contain up to 4 actual commands at a time */
int G433_i_CommandQueueFirstIndex; /* The queue contains a single command if G434_i_CommandQueueLastIndex = G433_i_CommandQueueFirstIndex */
int G434_i_CommandQueueLastIndex = 4; /* The queue is empty if (G434_i_CommandQueueLastIndex + 1) % 4 = G433_i_CommandQueueFirstIndex */
BOOLEAN G435_B_CommandQueueLocked = TRUE;
BOOLEAN G436_B_PendingClickPresent;
int G437_i_PendingClickX;
int G438_i_PendingClickY;
int G439_i_PendingClickButtonsStatus;
#ifndef NOCOPYPROTECTION
BOOLEAN G440_B_Consequence_StopSearchingMouseInput_COPYPROTECTIONC;
#endif
MOUSE_INPUT* G441_ps_PrimaryMouseInput;
MOUSE_INPUT* G442_ps_SecondaryMouseInput;
KEYBOARD_INPUT* G443_ps_PrimaryKeyboardInput;
KEYBOARD_INPUT* G444_ps_SecondaryKeyboardInput;
MOUSE_INPUT G445_as_Graphic561_PrimaryMouseInput_Entrance[4];
MOUSE_INPUT G446_as_Graphic561_PrimaryMouseInput_RestartGame[2];
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_28_IMPROVEMENT */
MOUSE_INPUT G447_as_Graphic561_PrimaryMouseInput_Interface[16];
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_28_IMPROVEMENT The player can now left click on the champion bars to open their inventory */
MOUSE_INPUT G447_as_Graphic561_PrimaryMouseInput_Interface[20];
#endif
MOUSE_INPUT G448_as_Graphic561_SecondaryMouseInput_Movement[9];
MOUSE_INPUT G449_as_Graphic561_SecondaryMouseInput_ChampionInventory[38];
MOUSE_INPUT G450_as_Graphic561_PrimaryMouseInput_PartySleeping[3];
MOUSE_INPUT G451_as_Graphic561_PrimaryMouseInput_FrozenGame[3];
MOUSE_INPUT G452_as_Graphic561_MouseInput_ActionAreaNames[5];
MOUSE_INPUT G453_as_Graphic561_MouseInput_ActionAreaIcons[5];
MOUSE_INPUT G454_as_Graphic561_MouseInput_SpellArea[9];
MOUSE_INPUT G455_as_Graphic561_MouseInput_ChampionNamesHands[13];
MOUSE_INPUT G456_as_Graphic561_MouseInput_PanelChest[9];
MOUSE_INPUT G457_as_Graphic561_MouseInput_PanelResurrectReincarnateCancel[4];
KEYBOARD_INPUT G458_as_Graphic561_PrimaryKeyboardInput_Interface[7];
KEYBOARD_INPUT G459_as_Graphic561_SecondaryKeyboardInput_Movement[7];
KEYBOARD_INPUT G460_as_Graphic561_PrimaryKeyboardInput_PartySleeping[3];
KEYBOARD_INPUT G461_as_Graphic561_PrimaryKeyboardInput_FrozenGame[2];
BOX_BYTE G462_as_Graphic561_Box_ObjectPiles[4];
BOX_WORD G463_as_Graphic561_Box_MovementArrows[4];
BOX_WORD G464_as_Graphic561_Box_SpellSymbolsAndDelete[7];
int G465_ai_Graphic561_MovementArrowToStepForwardCount[4];
int G466_ai_Graphic561_MovementArrowToStepRightCount[4];
BOX_WORD G467_s_Graphic561_Box_Dialog1ChoicePatchA;
BOX_WORD G468_s_Graphic561_Box_Dialog1ChoicePatchB;
BOX_WORD G469_s_Graphic561_Box_Dialog2ChoicesPatch;
BOX_WORD G470_s_Graphic561_Box_Dialog4ChoicesPatch;
MOUSE_INPUT G471_as_Graphic561_PrimaryMouseInput_ViewportDialog1Choice[2];
MOUSE_INPUT G472_as_Graphic561_PrimaryMouseInput_ViewportDialog2Choices[3];
MOUSE_INPUT G473_as_Graphic561_PrimaryMouseInput_ViewportDialog3Choices[4];
MOUSE_INPUT G474_as_Graphic561_PrimaryMouseInput_ViewportDialog4Choices[5];
MOUSE_INPUT G475_as_Graphic561_PrimaryMouseInput_ScreenDialog1Choice[2];
MOUSE_INPUT G476_as_Graphic561_PrimaryMouseInput_ScreenDialog2Choices[3];
MOUSE_INPUT G477_as_Graphic561_PrimaryMouseInput_ScreenDialog3Choices[4];
MOUSE_INPUT G478_as_Graphic561_PrimaryMouseInput_ScreenDialog4Choices[5];
int G479_i_Graphic561Anchor;
MOUSE_INPUT* G480_aaps_PrimaryMouseInput_DialogSets[2][4] = {{ &G471_as_Graphic561_PrimaryMouseInput_ViewportDialog1Choice,
                                                               &G472_as_Graphic561_PrimaryMouseInput_ViewportDialog2Choices,
                                                               &G473_as_Graphic561_PrimaryMouseInput_ViewportDialog3Choices,
                                                               &G474_as_Graphic561_PrimaryMouseInput_ViewportDialog4Choices },
                                                             { &G475_as_Graphic561_PrimaryMouseInput_ScreenDialog1Choice,
                                                               &G476_as_Graphic561_PrimaryMouseInput_ScreenDialog2Choices,
                                                               &G477_as_Graphic561_PrimaryMouseInput_ScreenDialog3Choices,
                                                               &G478_as_Graphic561_PrimaryMouseInput_ScreenDialog4Choices }};


overlay "user"

VOID F357_qzzz_COMMAND_DiscardAllInput()
{
        while (Cconis()) { /* Read and ignore all keyboard input */
                Crawcin();
        }
        G435_B_CommandQueueLocked = TRUE;
        G433_i_CommandQueueFirstIndex = 0;
        G434_i_CommandQueueLastIndex = 4;
        G435_B_CommandQueueLocked = FALSE;
}

int F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(P721_ps_MouseInput, P722_i_X, P723_i_Y, P724_i_ButtonsStatus)
register MOUSE_INPUT* P721_ps_MouseInput;
register int P722_i_X;
register int P723_i_Y;
register int P724_i_ButtonsStatus;
{
        register int L1107_i_Command;


        if ((P721_ps_MouseInput == NULL)
#ifndef NOCOPYPROTECTION
        || G440_B_Consequence_StopSearchingMouseInput_COPYPROTECTIONC
#endif
        ) {
                return C000_COMMAND_NONE;
        }
        while (L1107_i_Command = P721_ps_MouseInput->Command) {
                if ((P722_i_X <= P721_ps_MouseInput->Box.X2) && (P722_i_X >= P721_ps_MouseInput->Box.X1) &&
                    (P723_i_Y >= P721_ps_MouseInput->Box.Y1) && (P723_i_Y <= P721_ps_MouseInput->Box.Y2) &&
                    (P724_i_ButtonsStatus & P721_ps_MouseInput->Button)) {
                        break;
                }
                P721_ps_MouseInput++;
        }
        return L1107_i_Command;
}

VOID F359_hzzz_COMMAND_ProcessClick_COPYPROTECTIONC(P725_i_X, P726_i_Y, P727_i_ButtonsStatus)
register int P725_i_X;
register int P726_i_Y;
int P727_i_ButtonsStatus;
{
        register int L1108_i_CommandQueueIndex;
        register int L1109_i_Command;


        asm {
                        tas     G435_B_CommandQueueLocked(A4)   /* Test and set bit 7 in G435_B_CommandQueueLocked
                                                                BUG0_73 A mouse click may be ignored. The tas instruction works on the most significant byte of G435_B_CommandQueueLocked but when G435_B_CommandQueueLocked is set to TRUE elsewhere in the code, this affects the least significant byte only. Consequently, the code below may run while another function is modifying the command queue. The only possible consequence is when a key press is being processed in F361_nzzz_COMMAND_ProcessKeyPress */
                        beq.s   T359_002                        /* Branch if the command queue is not already being accessed (if G435_B_CommandQueueLocked = FALSE, before bit 7 is set above) */
        }
        G436_B_PendingClickPresent = TRUE;
        G437_i_PendingClickX = P725_i_X;
        G438_i_PendingClickY = P726_i_Y;
        G439_i_PendingClickButtonsStatus = P727_i_ButtonsStatus;
#ifndef NOCOPYPROTECTION
        if (!G440_B_Consequence_StopSearchingMouseInput_COPYPROTECTIONC && (F464_AA07_COPYPROTECTIONC_GetChecksumSub(&F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC) != CHECKSUM_B)) {
                G440_B_Consequence_StopSearchingMouseInput_COPYPROTECTIONC++;
        }
#endif
        return;
        T359_002:
        if ((L1108_i_CommandQueueIndex = G434_i_CommandQueueLastIndex + 2) > 4) {
                L1108_i_CommandQueueIndex -= 5;
        }
        if (L1108_i_CommandQueueIndex == G433_i_CommandQueueFirstIndex) { /* If the command queue is full */
                return;
        }
        L1109_i_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G441_ps_PrimaryMouseInput, P725_i_X , P726_i_Y, P727_i_ButtonsStatus);
        if (L1109_i_Command == C000_COMMAND_NONE) {
                L1109_i_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G442_ps_SecondaryMouseInput, P725_i_X , P726_i_Y, P727_i_ButtonsStatus);
        }
        if (L1109_i_Command != C000_COMMAND_NONE) {
                if (!L1108_i_CommandQueueIndex--) {
                        L1108_i_CommandQueueIndex = 4;
                }
                G432_as_CommandQueue[G434_i_CommandQueueLastIndex = L1108_i_CommandQueueIndex].Command = L1109_i_Command;
                G432_as_CommandQueue[L1108_i_CommandQueueIndex].X = P725_i_X;
                G432_as_CommandQueue[L1108_i_CommandQueueIndex].Y = P726_i_Y;
        }
        G435_B_CommandQueueLocked = FALSE;
}

VOID F360_xxxx_COMMAND_ProcessPendingClick()
{
        if (G436_B_PendingClickPresent) {
                G436_B_PendingClickPresent = FALSE;
                F359_hzzz_COMMAND_ProcessClick_COPYPROTECTIONC(G437_i_PendingClickX, G438_i_PendingClickY, G439_i_PendingClickButtonsStatus);
        }
}

VOID F361_nzzz_COMMAND_ProcessKeyPress(P728_l_KeyCode)
register long P728_l_KeyCode;
{
        register int L1110_i_CommandQueueIndex;
        register int L1111_i_Command;
        register KEYBOARD_INPUT* L1112_ps_KeyboardInput;


        if ((L1112_ps_KeyboardInput = G443_ps_PrimaryKeyboardInput) == NULL) {
                return;
        }
        G435_B_CommandQueueLocked = TRUE;
        if ((int)P728_l_KeyCode == 0) {
                P728_l_KeyCode >>= 8;
        }
        if ((L1110_i_CommandQueueIndex = G434_i_CommandQueueLastIndex + 2) > 4) {
                L1110_i_CommandQueueIndex -= 5;
        }
        if (L1110_i_CommandQueueIndex == G433_i_CommandQueueFirstIndex) { /* If the command queue is full */
                goto T361_014;
        } /* BUG0_73 A mouse click may be ignored. At this point, the command index where the keyboard command will be stored in the command queue is determined by L1110_i_CommandQueueIndex. If a mouse click interrupt occurs before the command is actually written into the command queue below then the mouse command will be stored at the same location in the queue and then be overwritten by the keyboard command */
        while (L1111_i_Command = L1112_ps_KeyboardInput->Command) {
                if ((int)P728_l_KeyCode == L1112_ps_KeyboardInput->Code) {
                        if (!L1110_i_CommandQueueIndex--) {
                                L1110_i_CommandQueueIndex = 4;
                        }
                        G432_as_CommandQueue[G434_i_CommandQueueLastIndex = L1110_i_CommandQueueIndex].Command = L1111_i_Command;
                        goto T361_014;
                }
                L1112_ps_KeyboardInput++;
        }
        if ((L1112_ps_KeyboardInput = G444_ps_SecondaryKeyboardInput) == NULL) {
                goto T361_014;
        }
        while (L1111_i_Command = L1112_ps_KeyboardInput->Command) {
                if ((int)P728_l_KeyCode == L1112_ps_KeyboardInput->Code) {
                        if (!L1110_i_CommandQueueIndex--) {
                                L1110_i_CommandQueueIndex = 4;
                        }
                        G432_as_CommandQueue[G434_i_CommandQueueLastIndex = L1110_i_CommandQueueIndex].Command = L1111_i_Command;
                        goto T361_014;
                }
                L1112_ps_KeyboardInput++;
        }
        T361_014:
        G435_B_CommandQueueLocked = FALSE;
        F360_xxxx_COMMAND_ProcessPendingClick();
}

VOID F362_xxxx_COMMAND_HighlightBoxEnable(P729_i_X1, P730_i_X2, P731_i_Y1, P732_i_Y2)
int P729_i_X1;
int P730_i_X2;
int P731_i_Y1;
int P732_i_Y2;
{
        while (G340_B_HighlightBoxInversionRequested);
        G336_i_HighlightBoxX1 = P729_i_X1;
        G337_i_HighlightBoxX2 = P730_i_X2;
        G338_i_HighlightBoxY1 = P731_i_Y1;
        G339_i_HighlightBoxY2 = P732_i_Y2;
        G340_B_HighlightBoxInversionRequested = TRUE;
        Vsync();
}

VOID F363_pzzz_COMMAND_HighlightBoxDisable()
{
        while (G340_B_HighlightBoxInversionRequested);
        if (G341_B_HighlightBoxEnabled) {
                G340_B_HighlightBoxInversionRequested = TRUE;
                Vsync();
        }
}

VOID F364_xxxx_COMMAND_TakeStairs(P733_B_StairsGoDown)
BOOLEAN P733_B_StairsGoDown;
{
        int L1113_i_Unreferenced; /* BUG0_00 Useless code */


        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, G306_i_PartyMapX, G307_i_PartyMapY, CM1_MAPX_NOT_ON_A_SQUARE, 0);
        G327_i_NewPartyMapIndex = F154_afzz_DUNGEON_GetLocationAfterLevelChange(G309_i_PartyMapIndex, P733_B_StairsGoDown ? -1 : 1, &G306_i_PartyMapX, &G307_i_PartyMapY);
        F173_gzzz_DUNGEON_SetCurrentMap(G327_i_NewPartyMapIndex);
        F284_czzz_CHAMPION_SetPartyDirection(F155_ahzz_DUNGEON_GetStairsExitDirection(G306_i_PartyMapX, G307_i_PartyMapY));
        F173_gzzz_DUNGEON_SetCurrentMap(G309_i_PartyMapIndex);
}

VOID F365_xxxx_COMMAND_ProcessTypes1To2_TurnParty(P734_i_Command)
int P734_i_Command;
{
        register unsigned int L1114_ui_Square;


        G321_B_StopWaitingForPlayerInput = TRUE;
        if (P734_i_Command == C001_COMMAND_TURN_LEFT) {
                F362_xxxx_COMMAND_HighlightBoxEnable(234, 261, 125, 145);
        } else {
                F362_xxxx_COMMAND_HighlightBoxEnable(291, 318, 125, 145);
        }
        if (M34_SQUARE_TYPE(L1114_ui_Square = F151_rzzz_DUNGEON_GetSquare(G306_i_PartyMapX, G307_i_PartyMapY)) == C03_ELEMENT_STAIRS) {
                F364_xxxx_COMMAND_TakeStairs(M07_GET(L1114_ui_Square, MASK0x0004_STAIRS_UP));
                return;
        }
        F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(G306_i_PartyMapX, G307_i_PartyMapY, C0xFFFF_THING_PARTY, TRUE, FALSE);
        F284_czzz_CHAMPION_SetPartyDirection(M21_NORMALIZE(G308_i_PartyDirection + ((P734_i_Command == C002_COMMAND_TURN_RIGHT) ? 1 : 3)));
        F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval(G306_i_PartyMapX, G307_i_PartyMapY, C0xFFFF_THING_PARTY, TRUE, TRUE);
}

/* When the party moves from one square to another, sensors are processed on the source square to manage effects of the party departure and then on the destination square to manage effects of the party arrival.
Stairs are a special case: when the party moves from a non stairs square to a stairs square, sensors are processed on the source square to manage the party departure but sensors are not processed on the destination stairs square to manage the party arrival. Then sensors are processed on the stairs square to manage the party departure and sensors are processed on the corresponding stairs square on the destination map to process the party arrival.
When the party moves from a stairs square to a non stairs square, sensors are not processed on the stairs square to manage the party departure but sensors are processed on the destination square to manage the party arrival.
When the party moves from a stairs square to another stairs square (take the stairs by turning or moving backward while standing on a stairs square), sensors are processed normally to manage the party departure from the source stairs square and the party arrival on the destination stairs square */
VOID F366_xxxx_COMMAND_ProcessTypes3To6_MoveParty(P735_i_Command)
int P735_i_Command;
{
        register unsigned int L1115_ui_Multiple;
#define A1115_ui_Square L1115_ui_Multiple
#define A1115_ui_Ticks  L1115_ui_Multiple
        register int L1116_i_SquareType;
        register BOOLEAN L1117_B_MovementBlocked;
        register int L1118_i_Multiple;
#define A1118_i_ChampionIndex      L1118_i_Multiple
#define A1118_i_MovementArrowIndex L1118_i_Multiple
        register CHAMPION* L1119_ps_Champion;
        register BOX_WORD* L1120_ps_Box;
        int L1121_i_MapX;
        int L1122_i_MapY;
        BOOLEAN L1123_B_StairsSquare;
        int L1124_i_FirstDamagedChampionIndex;
        int L1125_i_SecondDamagedChampionIndex;


        G321_B_StopWaitingForPlayerInput = TRUE;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
        L1119_ps_Champion = G407_s_Party.Champions, A1118_i_ChampionIndex = C00_CHAMPION_FIRST;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
        L1119_ps_Champion = G407_s_Party.Champions;
        A1118_i_ChampionIndex = C00_CHAMPION_FIRST;
#endif
        while (A1118_i_ChampionIndex < G305_ui_PartyChampionCount) {
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_10_FIX Do not decrease stamina of dead champions when the party moves */
                if (L1119_ps_Champion->CurrentHealth) {
#endif
                        F325_bzzz_CHAMPION_DecrementStamina(A1118_i_ChampionIndex, ((L1119_ps_Champion->Load * 3) / F309_awzz_CHAMPION_GetMaximumLoad(L1119_ps_Champion)) + 1); /* BUG0_50 When a champion is brought back to life at a Vi Altar, his current stamina is lower than what it was before dying. Each time the party moves the current stamina of all champions is decreased, including for dead champions, by an amount that depends on the current load of the champion. For a dead champion the load before he died is used */
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_10_FIX */
                }
#endif
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                L1119_ps_Champion++, A1118_i_ChampionIndex++;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                L1119_ps_Champion++;
                A1118_i_ChampionIndex++;
#endif
        }
        A1118_i_MovementArrowIndex = P735_i_Command - C003_COMMAND_MOVE_FORWARD;
        L1120_ps_Box = &G463_as_Graphic561_Box_MovementArrows[A1118_i_MovementArrowIndex];
        F362_xxxx_COMMAND_HighlightBoxEnable(L1120_ps_Box->X1, L1120_ps_Box->X2, L1120_ps_Box->Y1, L1120_ps_Box->Y2);
        L1123_B_StairsSquare = (M34_SQUARE_TYPE(A1115_ui_Square = F151_rzzz_DUNGEON_GetSquare(L1121_i_MapX = G306_i_PartyMapX, L1122_i_MapY = G307_i_PartyMapY)) == C03_ELEMENT_STAIRS);
        if (L1123_B_StairsSquare && (A1118_i_MovementArrowIndex == 2)) { /* If moving backward while in stairs */
                F364_xxxx_COMMAND_TakeStairs(M07_GET(A1115_ui_Square, MASK0x0004_STAIRS_UP));
                return;
        }
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(G308_i_PartyDirection, G465_ai_Graphic561_MovementArrowToStepForwardCount[A1118_i_MovementArrowIndex], G466_ai_Graphic561_MovementArrowToStepRightCount[A1118_i_MovementArrowIndex], &L1121_i_MapX, &L1122_i_MapY);
        L1116_i_SquareType = M34_SQUARE_TYPE(A1115_ui_Square = F151_rzzz_DUNGEON_GetSquare(L1121_i_MapX, L1122_i_MapY));
        if (L1116_i_SquareType == C03_ELEMENT_STAIRS) {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, G306_i_PartyMapX, G307_i_PartyMapY, CM1_MAPX_NOT_ON_A_SQUARE, 0);
                G306_i_PartyMapX = L1121_i_MapX;
                G307_i_PartyMapY = L1122_i_MapY;
                F364_xxxx_COMMAND_TakeStairs(M07_GET(A1115_ui_Square, MASK0x0004_STAIRS_UP));
                return;
        }
        L1117_B_MovementBlocked = FALSE;
        if (L1116_i_SquareType == C00_ELEMENT_WALL) {
                L1117_B_MovementBlocked = TRUE;
        } else {
                if (L1116_i_SquareType == C04_ELEMENT_DOOR) {
                        L1117_B_MovementBlocked = M36_DOOR_STATE(A1115_ui_Square);
                        L1117_B_MovementBlocked = (L1117_B_MovementBlocked != C0_DOOR_STATE_OPEN) && (L1117_B_MovementBlocked != C1_DOOR_STATE_CLOSED_ONE_FOURTH) && (L1117_B_MovementBlocked != C5_DOOR_STATE_DESTROYED);
                } else {
                        if (L1116_i_SquareType == C06_ELEMENT_FAKEWALL) {
                                L1117_B_MovementBlocked = (!M07_GET(A1115_ui_Square, MASK0x0004_FAKEWALL_OPEN) && !M07_GET(A1115_ui_Square, MASK0x0001_FAKEWALL_IMAGINARY));
                        }
                }
        }
        if (G305_ui_PartyChampionCount == 0) {
        } else {
                if (L1117_B_MovementBlocked) {
                        L1117_B_MovementBlocked = F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(L1124_i_FirstDamagedChampionIndex = F286_hzzz_CHAMPION_GetTargetChampionIndex(L1121_i_MapX, L1122_i_MapY, M21_NORMALIZE(A1118_i_MovementArrowIndex += (G308_i_PartyDirection + 2))), 1, MASK0x0008_TORSO | MASK0x0010_LEGS, C2_ATTACK_SELF);
                        if (L1124_i_FirstDamagedChampionIndex != (L1125_i_SecondDamagedChampionIndex = F286_hzzz_CHAMPION_GetTargetChampionIndex(L1121_i_MapX, L1122_i_MapY, M17_NEXT(A1118_i_MovementArrowIndex)))) {
                                L1117_B_MovementBlocked |= F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(L1125_i_SecondDamagedChampionIndex, 1, MASK0x0008_TORSO | MASK0x0010_LEGS, C2_ATTACK_SELF);
                        }
                        if (L1117_B_MovementBlocked) {
                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C18_SOUND_PARTY_DAMAGED, G306_i_PartyMapX, G307_i_PartyMapY, C00_MODE_PLAY_IMMEDIATELY);
                        }
                } else {
                        if (L1117_B_MovementBlocked = (F175_gzzz_GROUP_GetThing(L1121_i_MapX, L1122_i_MapY) != C0xFFFE_THING_ENDOFLIST)) {
                                F209_xzzz_GROUP_ProcessEvents29to41(L1121_i_MapX, L1122_i_MapY, CM1_EVENT_CREATE_REACTION_EVENT_31_PARTY_IS_ADJACENT, 0);
                        }
                }
        }
        if (L1117_B_MovementBlocked) {
                F357_qzzz_COMMAND_DiscardAllInput();
                G321_B_StopWaitingForPlayerInput = FALSE;
                return;
        }
        if (L1123_B_StairsSquare) {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, CM1_MAPX_NOT_ON_A_SQUARE, 0, L1121_i_MapX, L1122_i_MapY);
        } else {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, G306_i_PartyMapX, G307_i_PartyMapY, L1121_i_MapX, L1122_i_MapY);
        }
        A1115_ui_Ticks = 1;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
        L1119_ps_Champion = G407_s_Party.Champions, A1118_i_ChampionIndex = C00_CHAMPION_FIRST;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
        L1119_ps_Champion = G407_s_Party.Champions;
        A1118_i_ChampionIndex = C00_CHAMPION_FIRST;
#endif
        while (A1118_i_ChampionIndex < G305_ui_PartyChampionCount) {
                if (L1119_ps_Champion->CurrentHealth) {
                        A1115_ui_Ticks = F025_aatz_MAIN_GetMaximumValue(A1115_ui_Ticks, F310_AA08_CHAMPION_GetMovementTicks(L1119_ps_Champion));
                }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                A1118_i_ChampionIndex++, L1119_ps_Champion++;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                L1119_ps_Champion++;
                A1118_i_ChampionIndex++;
#endif
        }
        G310_i_DisabledMovementTicks = A1115_ui_Ticks;
        G311_i_ProjectileDisabledMovementTicks = 0;
}

VOID F367_xxxx_COMMAND_ProcessTypes12To27_ClickInChampionStatusBox(P736_ui_ChampionIndex, P737_i_X , P738_i_Y)
unsigned int P736_ui_ChampionIndex;
register int P737_i_X;
register int P738_i_Y;
{
        register unsigned int L1126_ui_Command;


        if (M00_INDEX_TO_ORDINAL(P736_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal) {
                F368_fzzz_COMMAND_SetLeader(P736_ui_ChampionIndex);
                return;
        }
        L1126_ui_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G455_as_Graphic561_MouseInput_ChampionNamesHands, P737_i_X, P738_i_Y, MASK0x0002_MOUSE_LEFT_BUTTON);
        if ((L1126_ui_Command >= C016_COMMAND_SET_LEADER_CHAMPION_0) && (L1126_ui_Command <= C019_COMMAND_SET_LEADER_CHAMPION_3)) {
                F368_fzzz_COMMAND_SetLeader(L1126_ui_Command - C016_COMMAND_SET_LEADER_CHAMPION_0);
                return;
        }
        if ((L1126_ui_Command >= C020_COMMAND_CLICK_ON_SLOT_BOX_00_CHAMPION_0_STATUS_BOX_READY_HAND) && (L1126_ui_Command <= C027_COMMAND_CLICK_ON_SLOT_BOX_07_CHAMPION_3_STATUS_BOX_ACTION_HAND)) {
                F302_mzzz_CHAMPION_ProcessCommands28To65_ClickOnSlotBox(L1126_ui_Command - C020_COMMAND_CLICK_ON_SLOT_BOX_00_CHAMPION_0_STATUS_BOX_READY_HAND);
        }
}

VOID F368_fzzz_COMMAND_SetLeader(P739_i_ChampionIndex)
register int P739_i_ChampionIndex;
{
        register int L1127_i_LeaderIndex;
        register int L1128_i_Unreferenced; /* BUG0_00 Useless code */
        register CHAMPION* L1129_ps_Champion;


        if ((P739_i_ChampionIndex == G411_i_LeaderIndex) || ((P739_i_ChampionIndex != CM1_CHAMPION_NONE) && !G407_s_Party.Champions[P739_i_ChampionIndex].CurrentHealth)) {
                return;
        }
        if (G411_i_LeaderIndex != CM1_CHAMPION_NONE) {
                M08_SET(G407_s_Party.Champions[L1127_i_LeaderIndex = G411_i_LeaderIndex].Attributes, MASK0x0200_LOAD | MASK0x0080_NAME_TITLE);
                G407_s_Party.Champions[L1127_i_LeaderIndex].Load -= F140_yzzz_DUNGEON_GetObjectWeight(G414_T_LeaderHandObject);
                G411_i_LeaderIndex = CM1_CHAMPION_NONE;
                F292_arzz_CHAMPION_DrawState(L1127_i_LeaderIndex);
        }
        if (P739_i_ChampionIndex == CM1_CHAMPION_NONE) {
                G411_i_LeaderIndex = CM1_CHAMPION_NONE;
                return;
        }
        L1129_ps_Champion = &G407_s_Party.Champions[G411_i_LeaderIndex = P739_i_ChampionIndex];
        L1129_ps_Champion->Direction = G308_i_PartyDirection;
        G407_s_Party.Champions[P739_i_ChampionIndex].Load += F140_yzzz_DUNGEON_GetObjectWeight(G414_T_LeaderHandObject);
        if (M00_INDEX_TO_ORDINAL(P739_i_ChampionIndex) != G299_ui_CandidateChampionOrdinal) {
                M08_SET(L1129_ps_Champion->Attributes, MASK0x0400_ICON | MASK0x0200_LOAD | MASK0x0080_NAME_TITLE);
                F292_arzz_CHAMPION_DrawState(P739_i_ChampionIndex);
        }
}

VOID F369_xxxx_COMMAND_ProcessTypes101To108_ClickInSpellSymbolsArea_COPYPROTECTIONE(P740_i_Command)
int P740_i_Command;
{
        register unsigned int L1130_ui_SymbolIndex;
        register BOX_WORD* L1131_ps_Box;


        if (P740_i_Command == C108_COMMAND_CLICK_IN_SPELL_AREA_CAST_SPELL) {
                if (G407_s_Party.Champions[G514_i_MagicCasterChampionIndex].Symbols[0] == '\0') {
                        return;
                }
                F362_xxxx_COMMAND_HighlightBoxEnable(234, 303, 63, 73);
#ifndef NOCOPYPROTECTION
                if ((G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE != C00136_TRUE) && !F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE)) {
                        G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE = C00136_TRUE;
                }
#endif
                G321_B_StopWaitingForPlayerInput = F408_xxxx_MENUS_GetClickOnSpellCastResult(C0_USELESS); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 0 parameters. No consequence because additional parameters are ignored */
        } else {
                L1130_ui_SymbolIndex = P740_i_Command - C101_COMMAND_CLICK_IN_SPELL_AREA_SYMBOL_1;
                L1131_ps_Box = &G464_as_Graphic561_Box_SpellSymbolsAndDelete[L1130_ui_SymbolIndex];
                F362_xxxx_COMMAND_HighlightBoxEnable(L1131_ps_Box->X1, L1131_ps_Box->X2, L1131_ps_Box->Y1, L1131_ps_Box->Y2);
                Vsync();
                F363_pzzz_COMMAND_HighlightBoxDisable();
                if (L1130_ui_SymbolIndex < 6) {
                        F399_xxxx_MENUS_AddChampionSymbol(L1130_ui_SymbolIndex);
                } else {
                        F400_xxxx_MENUS_DeleteChampionSymbol();
                }
        }
}

VOID F370_xxxx_COMMAND_ProcessType100_ClickInSpellArea(P741_ui_X, P742_ui_Y)
unsigned int P741_ui_X;
unsigned int P742_ui_Y;
{
        register int L1132_i_Command;
        register int L1133_i_ChampionIndex;


        L1133_i_ChampionIndex = CM1_CHAMPION_NONE;
        if (P742_ui_Y <= 48) {
                switch (G514_i_MagicCasterChampionIndex) {
                        case 0:
                                if ((P741_ui_X >= 280) && (P741_ui_X <= 291)) {
                                        L1133_i_ChampionIndex = 1;
                                } else {
                                        if ((P741_ui_X >= 294) && (P741_ui_X <= 305)) {
                                                L1133_i_ChampionIndex = 2;
                                        } else {
                                                if (P741_ui_X >= 308) {
                                                        L1133_i_ChampionIndex = 3;
                                                }
                                        }
                                }
                                break;
                        case 1:
                                if ((P741_ui_X >= 233) && (P741_ui_X <= 244)) {
                                        L1133_i_ChampionIndex = 0;
                                } else {
                                        if ((P741_ui_X >= 294) && (P741_ui_X <= 305)) {
                                                L1133_i_ChampionIndex = 2;
                                        } else {
                                                if (P741_ui_X >= 308) {
                                                        L1133_i_ChampionIndex = 3;
                                                }
                                        }
                                }
                                break;
                        case 2:
                                if ((P741_ui_X >= 233) && (P741_ui_X <= 244)) {
                                        L1133_i_ChampionIndex = 0;
                                } else {
                                        if ((P741_ui_X >= 247) && (P741_ui_X <= 258)) {
                                                L1133_i_ChampionIndex = 1;
                                        } else {
                                                if (P741_ui_X >= 308) {
                                                        L1133_i_ChampionIndex = 3;
                                                }
                                        }
                                }
                                break;
                        case 3:
                                if ((P741_ui_X >= 247) && (P741_ui_X <= 258)) {
                                        L1133_i_ChampionIndex = 1;
                                } else {
                                        if ((P741_ui_X >= 261) && (P741_ui_X <= 272)) {
                                                L1133_i_ChampionIndex = 2;
                                        } else {
                                                if (P741_ui_X <= 244) {
                                                        L1133_i_ChampionIndex = 0;
                                                }
                                        }
                                }
                }
                if ((L1133_i_ChampionIndex != CM1_CHAMPION_NONE) && (L1133_i_ChampionIndex < G305_ui_PartyChampionCount)) {
                        F394_ozzz_MENUS_SetMagicCasterAndDrawSpellArea(L1133_i_ChampionIndex);
                }
        } else {
                L1132_i_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G454_as_Graphic561_MouseInput_SpellArea, P741_ui_X, P742_ui_Y, MASK0x0002_MOUSE_LEFT_BUTTON);
                if (L1132_i_Command != C000_COMMAND_NONE) {
                        F369_xxxx_COMMAND_ProcessTypes101To108_ClickInSpellSymbolsArea_COPYPROTECTIONE(L1132_i_Command);
                }
        }
}

VOID F371_xxxx_COMMAND_ProcessType111To115_ClickInActionArea_COPYPROTECTIONE(P743_i_X, P744_i_Y)
int P743_i_X;
int P744_i_Y;
{
        register unsigned int L1134_ui_Command;


        if (G506_i_ActingChampionOrdinal) {
                L1134_ui_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G452_as_Graphic561_MouseInput_ActionAreaNames, P743_i_X, P744_i_Y, MASK0x0002_MOUSE_LEFT_BUTTON);
                if (L1134_ui_Command != C000_COMMAND_NONE) {
                        if (L1134_ui_Command == C112_COMMAND_CLICK_IN_ACTION_AREA_PASS) {
                                F362_xxxx_COMMAND_HighlightBoxEnable(285, 319, 77, 83);
                                F391_xxxx_MENUS_DidClickTriggerAction(-1);
                        } else {
                                if ((L1134_ui_Command - C112_COMMAND_CLICK_IN_ACTION_AREA_PASS) <= G507_ui_ActionCount) {
                                        if (L1134_ui_Command == C113_COMMAND_CLICK_IN_ACTION_AREA_ACTION_0) {
                                                F362_xxxx_COMMAND_HighlightBoxEnable(234, 318, 86, 96);
                                        } else {
                                                if (L1134_ui_Command == C114_COMMAND_CLICK_IN_ACTION_AREA_ACTION_1) {
                                                        F362_xxxx_COMMAND_HighlightBoxEnable(234, 318, 98, 108);
#ifndef NOCOPYPROTECTION
                                                        if ((G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE != C00136_TRUE) && !F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE)) {
                                                                G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE = C00136_TRUE;
                                                        }
#endif
                                                } else {
                                                        F362_xxxx_COMMAND_HighlightBoxEnable(234, 318, 110, 120);
                                                }
                                        }
                                        G321_B_StopWaitingForPlayerInput = F391_xxxx_MENUS_DidClickTriggerAction(L1134_ui_Command - C113_COMMAND_CLICK_IN_ACTION_AREA_ACTION_0);
                                }
                        }
                }
        } else {
                if (G509_B_ActionAreaContainsIcons) {
                        L1134_ui_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G453_as_Graphic561_MouseInput_ActionAreaIcons, P743_i_X, P744_i_Y, MASK0x0002_MOUSE_LEFT_BUTTON);
                        if (L1134_ui_Command != C000_COMMAND_NONE) {
                                if ((L1134_ui_Command = L1134_ui_Command - C116_COMMAND_CLICK_IN_ACTION_AREA_CHAMPION_0_ACTION) < G305_ui_PartyChampionCount) {
                                        F389_xxxx_MENUS_ProcessCommands116To119_SetActingChampion(L1134_ui_Command);
                                }
                        }
                }
        }
}

VOID F372_xxxx_COMMAND_ProcessType80_ClickInDungeonView_TouchFrontWall()
{
        unsigned int L1135_ui_MapX;
        unsigned int L1136_ui_MapY;


        L1135_ui_MapX = G306_i_PartyMapX;
        L1136_ui_MapY = G307_i_PartyMapY;
        L1135_ui_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L1136_ui_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
        if ((L1135_ui_MapX >= 0) && (L1135_ui_MapX < G273_i_CurrentMapWidth) && (L1136_ui_MapY >= 0) && (L1136_ui_MapY < G274_i_CurrentMapHeight)) {
                G321_B_StopWaitingForPlayerInput = F275_aszz_SENSOR_IsTriggeredByClickOnWall(L1135_ui_MapX, L1136_ui_MapY, M18_OPPOSITE(G308_i_PartyDirection));
        }
}

VOID F373_xxxx_COMMAND_ProcessType80_ClickInDungeonView_GrabLeaderHandObject(P745_ui_ViewCell)
register unsigned int P745_ui_ViewCell; /* Cells 0 and 1 are on the party square, cells 2 and 3 are on the square in front of the party */
{
        register int L1137_i_MapX;
        register int L1138_i_MapY;
        register THING L1139_T_Thing;


        if (G411_i_LeaderIndex == CM1_CHAMPION_NONE) {
                return;
        }
        L1137_i_MapX = G306_i_PartyMapX;
        L1138_i_MapY = G307_i_PartyMapY;
        if (P745_ui_ViewCell >= C02_VIEW_CELL_BACK_RIGHT) {
                L1137_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L1138_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
                if (((L1139_T_Thing = F175_gzzz_GROUP_GetThing(L1137_i_MapX, L1138_i_MapY)) != C0xFFFE_THING_ENDOFLIST) &&
                    !F264_avzz_MOVE_IsLevitating(L1139_T_Thing, C04_THING_TYPE_GROUP) && /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 1 parameter. No consequence because additional parameters are ignored */
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                    F176_avzz_GROUP_GetCreatureOrdinalInCell(&(((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L1139_T_Thing)]), M21_NORMALIZE(P745_ui_ViewCell + G308_i_PartyDirection))) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                    F176_avzz_GROUP_GetCreatureOrdinalInCell((GROUP*)F156_afzz_DUNGEON_GetThingData(L1139_T_Thing), M21_NORMALIZE(P745_ui_ViewCell + G308_i_PartyDirection))) {
#endif
                        return; /* It is not possible to grab an object on floor if there is a non levitating creature on its cell */
                }
        }
        L1139_T_Thing = G292_aT_PileTopObject[P745_ui_ViewCell];
        if (F033_aaaz_OBJECT_GetIconIndex(L1139_T_Thing) != CM1_ICON_NONE) {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L1139_T_Thing, L1137_i_MapX, L1138_i_MapY, CM1_MAPX_NOT_ON_A_SQUARE, 0);
                G416_i_Useless = 1; /* BUG0_00 Useless code */
                F297_atzz_CHAMPION_PutObjectInLeaderHand(L1139_T_Thing, TRUE);
        }
        G321_B_StopWaitingForPlayerInput = TRUE;
}

VOID F374_xxxx_COMMAND_ProcessType80_ClickInDungeonView_DropLeaderHandObject(P746_ui_ViewCell)
register unsigned int P746_ui_ViewCell; /* Cells 0 and 1 are on the party square, cells 2 and 3 are on the square in front of the party */
{
        register int L1140_i_MapX;
        register int L1141_i_MapY;
        register THING L1142_T_Thing;
        register JUNK* L1143_ps_Junk;
        int L1144_i_IconIndex;
        unsigned int L1145_ui_Cell;
        BOOLEAN L1146_B_DroppingIntoAnAlcove;
        EVENT L1147_s_Event;


        if (G411_i_LeaderIndex == CM1_CHAMPION_NONE) {
                return;
        }
        L1140_i_MapX = G306_i_PartyMapX;
        L1141_i_MapY = G307_i_PartyMapY;
        if (L1146_B_DroppingIntoAnAlcove = (P746_ui_ViewCell == C04_VIEW_CELL_ALCOVE)) {
                P746_ui_ViewCell = C02_VIEW_CELL_BACK_RIGHT;
        }
        if (P746_ui_ViewCell > C01_VIEW_CELL_FRONT_RIGHT) {
                L1140_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L1141_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
        }
        L1145_ui_Cell = M21_NORMALIZE(G308_i_PartyDirection + P746_ui_ViewCell);
        L1142_T_Thing = F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(M15_THING_WITH_NEW_CELL(L1142_T_Thing, L1145_ui_Cell), CM1_MAPX_NOT_ON_A_SQUARE, 0, L1140_i_MapX, L1141_i_MapY);
        if (L1146_B_DroppingIntoAnAlcove && G287_B_FacingViAltar && ((L1144_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L1142_T_Thing)) == C147_ICON_JUNK_CHAMPION_BONES)) {
                L1143_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L1142_T_Thing);
                M33_SET_MAP_AND_TIME(L1147_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + 1);
                L1147_s_Event.A.A.Type = C13_EVENT_VI_ALTAR_REBIRTH;
                L1147_s_Event.A.A.Priority = L1143_ps_Junk->ChargeCount;
                L1147_s_Event.B.Location.MapX = L1140_i_MapX;
                L1147_s_Event.B.Location.MapY = L1141_i_MapY;
                L1147_s_Event.C.A.Cell = L1145_ui_Cell;
                L1147_s_Event.C.A.Effect = C02_EFFECT_TOGGLE;
                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L1147_s_Event);
        }
        G321_B_StopWaitingForPlayerInput = TRUE;
}

BOOLEAN F375_xxxx_COMMAND_ProcessType80_ClickInDungeonView_IsLeaderHandObjectThrown(P747_i_X, P748_i_Y)
int P747_i_X;
int P748_i_Y;
{
        register int L1148_i_Unreferenced; /* BUG0_00 Useless code */
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_11_FIX */
        register BOOLEAN L1149_B_ObjectThrown;
#endif


        if ((P748_i_Y < 47) || (P748_i_Y > 102)) {
                return FALSE;
        }
        if (P747_i_X <= 111) {
                if (G285_i_SquareAheadElement == C17_ELEMENT_DOOR_FRONT) {
                        if (P747_i_X < 64) {
                                return FALSE;
                        }
                } else {
                        if (P747_i_X < 32) {
                                return FALSE;
                        }
                }
#ifdef C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN /* CHANGE8_11_FIX */
                return F329_hzzz_CHAMPION_IsLeaderHandObjectThrown(C0_SIDE_LEFT); /* BUG0_51 Throwing the object in the leader hand does not stop the wait for player input in the main loop. Each time player input with the mouse or keyboard causes some meaningful activity in the game (like moving, performing an action, casting a spell, etc.) the main game loop stops waiting for more player input and proceeds with advancing the game time by one tick and managing everything else. Throwing the object in the leader hand is the only such activity inconsistent with all others */
        }
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_11_FIX Throwing the object in the leader hand stops the wait for player input in the main loop */
                L1149_B_ObjectThrown = F329_hzzz_CHAMPION_IsLeaderHandObjectThrown(C0_SIDE_LEFT);
        } else {
#endif
                if (G285_i_SquareAheadElement == C17_ELEMENT_DOOR_FRONT) {
                        if (P747_i_X > 163) {
                                return FALSE;
                        }
                } else {
                        if (P747_i_X > 191) {
                                return FALSE;
                        }
                }
#ifdef C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN /* CHANGE8_11_FIX */
                return F329_hzzz_CHAMPION_IsLeaderHandObjectThrown(C1_SIDE_RIGHT); /* BUG0_51 */
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_11_FIX Throwing the object in the leader hand stops the wait for player input in the main loop */
                L1149_B_ObjectThrown = F329_hzzz_CHAMPION_IsLeaderHandObjectThrown(C1_SIDE_RIGHT);
        }
        if (L1149_B_ObjectThrown) {
                G321_B_StopWaitingForPlayerInput = TRUE;
        }
        return L1149_B_ObjectThrown;
#endif
}

BOOLEAN F376_xxxx_COMMAND_IsPointInBox(P749_ps_Box, P750_i_X, P751_i_Y)
register BOX_BYTE* P749_ps_Box;
register int P750_i_X;
register int P751_i_Y;
{
        return ((P750_i_X <= P749_ps_Box->X2) && (P750_i_X >= P749_ps_Box->X1) && (P751_i_Y <= P749_ps_Box->Y2) && (P751_i_Y >= P749_ps_Box->Y1));
}

VOID F377_xxxx_COMMAND_ProcessType80_ClickInDungeonView(P752_i_X, P753_i_Y)
register int P752_i_X;
register int P753_i_Y;
{
        register unsigned int L1150_ui_ViewCell;
        register JUNK* L1151_ps_Junk;
        THING L1152_T_Thing;
        unsigned int L1153_ui_IconIndex;
        unsigned int L1154_ui_Weight;
        int L1155_i_MapX;
        int L1156_i_MapY;


        if (G285_i_SquareAheadElement == C17_ELEMENT_DOOR_FRONT) {
                if (G411_i_LeaderIndex == CM1_CHAMPION_NONE) {
                        return;
                }
                L1155_i_MapX = G306_i_PartyMapX;
                L1156_i_MapY = G307_i_PartyMapY;
                L1155_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L1156_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
                if (G415_B_LeaderEmptyHanded) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        if ((((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(L1155_i_MapX, L1156_i_MapY))].Button) && (F376_xxxx_COMMAND_IsPointInBox(G291_aauc_DungeonViewClickableBoxes[C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT], P752_i_X, P753_i_Y - 33))) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L1151_ps_Junk = (JUNK*)F157_rzzz_DUNGEON_GetSquareFirstThingData(L1155_i_MapX, L1156_i_MapY);
                        if ((((DOOR*)L1151_ps_Junk)->Button) && (F376_xxxx_COMMAND_IsPointInBox(G291_aauc_DungeonViewClickableBoxes[C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT], P752_i_X, P753_i_Y - 33))) {
#endif
                                G321_B_StopWaitingForPlayerInput = TRUE;
                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C01_SOUND_SWITCH, G306_i_PartyMapX, G307_i_PartyMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                F268_fzzz_SENSOR_AddEvent(C10_EVENT_DOOR, L1155_i_MapX, L1156_i_MapY, 0, C02_EFFECT_TOGGLE, G313_ul_GameTime + 1);
                                return;
                        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_09_OPTIMIZATION */
                }
                if (!G415_B_LeaderEmptyHanded) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_09_OPTIMIZATION Code deduplication */
                } else {
#endif
                        if (F375_xxxx_COMMAND_ProcessType80_ClickInDungeonView_IsLeaderHandObjectThrown(P752_i_X, P753_i_Y)) {
                                return;
                        }
                }
        }
        if (G415_B_LeaderEmptyHanded) {
                for(L1150_ui_ViewCell = C00_VIEW_CELL_FRONT_LEFT; L1150_ui_ViewCell < C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT + 1; L1150_ui_ViewCell++) {
                        if (F376_xxxx_COMMAND_IsPointInBox(G291_aauc_DungeonViewClickableBoxes[L1150_ui_ViewCell], P752_i_X, P753_i_Y - 33)) {
                                if (L1150_ui_ViewCell == C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT) {
                                        if (!G286_B_FacingAlcove) {
                                                F372_xxxx_COMMAND_ProcessType80_ClickInDungeonView_TouchFrontWall();
                                        }
                                } else {
                                        F373_xxxx_COMMAND_ProcessType80_ClickInDungeonView_GrabLeaderHandObject(L1150_ui_ViewCell);
                                }
                                return;
                        }
                }
                return;
        }
        L1152_T_Thing = G414_T_LeaderHandObject;
        L1151_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L1152_T_Thing);
        if (G285_i_SquareAheadElement == C00_ELEMENT_WALL) {
                for(L1150_ui_ViewCell = C00_VIEW_CELL_FRONT_LEFT; L1150_ui_ViewCell < C01_VIEW_CELL_FRONT_RIGHT + 1; L1150_ui_ViewCell++) {
                        if (F376_xxxx_COMMAND_IsPointInBox(&G462_as_Graphic561_Box_ObjectPiles[L1150_ui_ViewCell], P752_i_X, P753_i_Y)) {
                                F374_xxxx_COMMAND_ProcessType80_ClickInDungeonView_DropLeaderHandObject(L1150_ui_ViewCell);
                                return;
                        }
                }
                if (F376_xxxx_COMMAND_IsPointInBox(G291_aauc_DungeonViewClickableBoxes[C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT], P752_i_X, P753_i_Y - 33)) {
                        if (G286_B_FacingAlcove) {
                                F374_xxxx_COMMAND_ProcessType80_ClickInDungeonView_DropLeaderHandObject(C04_VIEW_CELL_ALCOVE);
                        } else {
                                if (G288_B_FacingFountain) {
                                        L1153_ui_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L1152_T_Thing);
                                        L1154_ui_Weight = F140_yzzz_DUNGEON_GetObjectWeight(L1152_T_Thing);
                                        if ((L1153_ui_IconIndex >= C008_ICON_JUNK_WATER) && (L1153_ui_IconIndex <= C009_ICON_JUNK_WATERSKIN)) {
                                                L1151_ps_Junk->ChargeCount = 3; /* Full */
                                        } else {
                                                if (L1153_ui_IconIndex == C195_ICON_POTION_EMPTY_FLASK) {
                                                        ((POTION*)L1151_ps_Junk)->Type = C15_POTION_WATER_FLASK;
                                                } else {
                                                        goto T377_019;
                                                }
                                        }
                                        F296_aizz_CHAMPION_DrawChangedObjectIcons();
                                        G407_s_Party.Champions[G411_i_LeaderIndex].Load += F140_yzzz_DUNGEON_GetObjectWeight(L1152_T_Thing) - L1154_ui_Weight;
                                }
                                T377_019:
                                F372_xxxx_COMMAND_ProcessType80_ClickInDungeonView_TouchFrontWall();
                        }
                }
                return;
        }
        if (F375_xxxx_COMMAND_ProcessType80_ClickInDungeonView_IsLeaderHandObjectThrown(P752_i_X, P753_i_Y)) {
                return;
        }
        for(L1150_ui_ViewCell = C00_VIEW_CELL_FRONT_LEFT; L1150_ui_ViewCell < C03_VIEW_CELL_BACK_LEFT + 1; L1150_ui_ViewCell++) {
                if (F376_xxxx_COMMAND_IsPointInBox(&G462_as_Graphic561_Box_ObjectPiles[L1150_ui_ViewCell], P752_i_X, P753_i_Y)) {
                        F374_xxxx_COMMAND_ProcessType80_ClickInDungeonView_DropLeaderHandObject(L1150_ui_ViewCell);
                        return;
                }
        }
}

VOID F378_xxxx_COMMAND_ProcessType81_ClickInPanel(P754_i_X, P755_i_Y)
register int P754_i_X;
register int P755_i_Y;
{
        register int L1157_i_Command;
        register BOOLEAN L1158_B_NoLeader;


        L1158_B_NoLeader = (G411_i_LeaderIndex == CM1_CHAMPION_NONE);
        switch (G424_i_PanelContent) {
                case C4_PANEL_CHEST:
                        if (L1158_B_NoLeader) {
                                break;
                        }
                        L1157_i_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G456_as_Graphic561_MouseInput_PanelChest, P754_i_X, P755_i_Y, MASK0x0002_MOUSE_LEFT_BUTTON);
                        if (L1157_i_Command != C000_COMMAND_NONE) {
                                F302_mzzz_CHAMPION_ProcessCommands28To65_ClickOnSlotBox(L1157_i_Command - C020_COMMAND_CLICK_ON_SLOT_BOX_00_CHAMPION_0_STATUS_BOX_READY_HAND);
                        }
                        break;
                case C5_PANEL_RESURRECT_REINCARNATE:
                        if (!G415_B_LeaderEmptyHanded) {
                                break;
                        }
                        L1157_i_Command = F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC(G457_as_Graphic561_MouseInput_PanelResurrectReincarnateCancel, P754_i_X, P755_i_Y, MASK0x0002_MOUSE_LEFT_BUTTON);
                        if (L1157_i_Command != C000_COMMAND_NONE) {
                                F282_xzzz_CHAMPION_ProcessCommands160To162_ClickInResurrectReincarnatePanel(L1157_i_Command);
                        }
        }
}

VOID F379_jzzz_COMMAND_DrawSleepScreen()
{
        F134_zzzz_VIDEO_FillBitmap(G296_puc_Bitmap_Viewport, C00_COLOR_BLACK, M76_BITMAP_UNIT_COUNT(224, 136));
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
        F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 93, 69, C04_COLOR_CYAN, C00_COLOR_BLACK, "WAKE UP");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
        F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 96, 69, C04_COLOR_CYAN, C00_COLOR_BLACK, "WECKEN");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
        F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 72, 69, C04_COLOR_CYAN, C00_COLOR_BLACK, "REVEILLEZ-VOUS");
#endif
}

VOID F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC()
{
        register int L1159_i_Multiple;
#define A1159_i_CommandQueueIndex L1159_i_Multiple
#define A1159_i_ChampionIndex     L1159_i_Multiple
        register int L1160_i_Command;
        register int L1161_i_CommandX;
        register int L1162_i_CommandY;
        register char* L1163_pc_Unreferenced; /* BUG0_00 Useless code */
        static KEYBOARD_INPUT* G481_ps_PrimaryKeyboardInputBackup;
        static KEYBOARD_INPUT* G482_ps_SecondaryKeyboardInputBackup;
        static MOUSE_INPUT* G483_ps_PrimaryMouseInputBackup;
        static MOUSE_INPUT* G484_ps_SecondaryMouseInputBackup;


        G435_B_CommandQueueLocked = TRUE;
        if ((A1159_i_CommandQueueIndex = G434_i_CommandQueueLastIndex + 1) > 4) {
                A1159_i_CommandQueueIndex = 0;
        }
        if (A1159_i_CommandQueueIndex == G433_i_CommandQueueFirstIndex) { /* If the command queue is empty */
                G435_B_CommandQueueLocked = FALSE;
                F360_xxxx_COMMAND_ProcessPendingClick();
                return;
        }
        L1160_i_Command = G432_as_CommandQueue[G433_i_CommandQueueFirstIndex].Command;
        if ((L1160_i_Command >= C003_COMMAND_MOVE_FORWARD) && (L1160_i_Command <= C006_COMMAND_MOVE_LEFT) && (G310_i_DisabledMovementTicks || (G311_i_ProjectileDisabledMovementTicks && (G312_i_LastProjectileDisabledMovementDirection == (M21_NORMALIZE(G308_i_PartyDirection + L1160_i_Command - C003_COMMAND_MOVE_FORWARD)))))) { /* If movement is disabled */
                G435_B_CommandQueueLocked = FALSE;
                F360_xxxx_COMMAND_ProcessPendingClick();
                return;
        }
        L1161_i_CommandX = G432_as_CommandQueue[G433_i_CommandQueueFirstIndex].X;
        L1162_i_CommandY = G432_as_CommandQueue[G433_i_CommandQueueFirstIndex].Y;
        if (++G433_i_CommandQueueFirstIndex > 4) {
                G433_i_CommandQueueFirstIndex = 0;
        }
        G435_B_CommandQueueLocked = FALSE;
        F360_xxxx_COMMAND_ProcessPendingClick();
        if ((L1160_i_Command == C002_COMMAND_TURN_RIGHT) || (L1160_i_Command == C001_COMMAND_TURN_LEFT)) {
                F365_xxxx_COMMAND_ProcessTypes1To2_TurnParty(L1160_i_Command);
                return;
        }
        if ((L1160_i_Command >= C003_COMMAND_MOVE_FORWARD) && (L1160_i_Command <= C006_COMMAND_MOVE_LEFT)) {
                F366_xxxx_COMMAND_ProcessTypes3To6_MoveParty(L1160_i_Command);
                return;
        }
        if ((L1160_i_Command >= C012_COMMAND_CLICK_IN_CHAMPION_0_STATUS_BOX) && (L1160_i_Command <= C015_COMMAND_CLICK_IN_CHAMPION_3_STATUS_BOX)) {
                if (((A1159_i_ChampionIndex = L1160_i_Command - C012_COMMAND_CLICK_IN_CHAMPION_0_STATUS_BOX) < G305_ui_PartyChampionCount) && !G299_ui_CandidateChampionOrdinal) {
                        F367_xxxx_COMMAND_ProcessTypes12To27_ClickInChampionStatusBox(A1159_i_ChampionIndex, L1161_i_CommandX, L1162_i_CommandY);
                }
                return;
        }
        if ((L1160_i_Command >= C125_COMMAND_CLICK_ON_CHAMPION_ICON_TOP_LEFT) && (L1160_i_Command <= C128_COMMAND_CLICK_ON_CHAMPION_ICON_LOWER_LEFT)) {
                F070_aajz_MOUSE_ProcessCommands125To128_ClickOnChampionIcon(L1160_i_Command - C125_COMMAND_CLICK_ON_CHAMPION_ICON_TOP_LEFT);
                return;
        }
        if ((L1160_i_Command >= C028_COMMAND_CLICK_ON_SLOT_BOX_08_INVENTORY_READY_HAND) && (L1160_i_Command < (C065_COMMAND_CLICK_ON_SLOT_BOX_45_CHEST_8 + 1))) {
                if (G411_i_LeaderIndex != CM1_CHAMPION_NONE) {
                        F302_mzzz_CHAMPION_ProcessCommands28To65_ClickOnSlotBox(L1160_i_Command - C020_COMMAND_CLICK_ON_SLOT_BOX_00_CHAMPION_0_STATUS_BOX_READY_HAND);
                }
                return;
        }
        if ((L1160_i_Command >= C007_COMMAND_TOGGLE_INVENTORY_CHAMPION_0) && (L1160_i_Command <= C011_COMMAND_CLOSE_INVENTORY)) {
                if ((((A1159_i_ChampionIndex = L1160_i_Command - C007_COMMAND_TOGGLE_INVENTORY_CHAMPION_0) == C04_CHAMPION_CLOSE_INVENTORY) || (A1159_i_ChampionIndex < G305_ui_PartyChampionCount)) && !G299_ui_CandidateChampionOrdinal) {
                        F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(A1159_i_ChampionIndex);
                }
                return;
        }
#ifndef NOCOPYPROTECTION
        if ((L1160_i_Command == C140_COMMAND_SAVE_GAME) && (F464_AA07_COPYPROTECTIONC_GetChecksumSub(&F433_AA39_STARTEND_ProcessCommand140_SaveGame_COPYPROTECTIONCDF) != CHECKSUM_C)) {
                F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(C04_CHAMPION_CLOSE_INVENTORY);
                return;
        }
#endif
        if (L1160_i_Command == C083_COMMAND_TOGGLE_INVENTORY_LEADER) {
                if (G411_i_LeaderIndex != CM1_CHAMPION_NONE) {
                        F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(G411_i_LeaderIndex);
                }
                return;
        }
        if (L1160_i_Command == C100_COMMAND_CLICK_IN_SPELL_AREA) {
                if ((!G299_ui_CandidateChampionOrdinal) && (G514_i_MagicCasterChampionIndex != CM1_CHAMPION_NONE)) {
                        F370_xxxx_COMMAND_ProcessType100_ClickInSpellArea(L1161_i_CommandX, L1162_i_CommandY);
                }
                return;
        }
        if (L1160_i_Command == C111_COMMAND_CLICK_IN_ACTION_AREA) {
                if (!G299_ui_CandidateChampionOrdinal) {
                        F371_xxxx_COMMAND_ProcessType111To115_ClickInActionArea_COPYPROTECTIONE(L1161_i_CommandX, L1162_i_CommandY);
                }
                return;
        }
        if (L1160_i_Command == C070_COMMAND_CLICK_ON_MOUTH) {
                F349_dzzz_INVENTORY_ProcessCommand70_ClickOnMouth();
                return;
        }
        if (L1160_i_Command == C071_COMMAND_CLICK_ON_EYE) {
                F352_aszz_INVENTORY_ProcessCommand71_ClickOnEye();
                return;
        }
        if (L1160_i_Command == C080_COMMAND_CLICK_IN_DUNGEON_VIEW) {
                F377_xxxx_COMMAND_ProcessType80_ClickInDungeonView(L1161_i_CommandX, L1162_i_CommandY);
                return;
        }
        if (L1160_i_Command == C081_COMMAND_CLICK_IN_PANEL) {
                F378_xxxx_COMMAND_ProcessType81_ClickInPanel(L1161_i_CommandX, L1162_i_CommandY);
                return;
        }
        /* BUG0_52 The remaining commands should be ignored while pressing the eye or mouth (pressing the mouth is only possible when the panel does not contain the Food and Water bars but a scroll, a chest or the resurrect/reincarnate panel). If you press CTRL-S on the keyboard while pressing the eye or mouth with the mouse, the save game menu appears but the mouse pointer is missing on screen. If you press ESC on the keyboard while pressing the eye or the mouth, the game is frozen but the panel is drawn on screen when you release the mouse button (Food and Water bars, scroll in hand, open chest or resurrect/reincarnate). If you press ESC again to unfreeze before releasing the mouse button, the panel is drawn over the dungeon view, and the game may crash because mouse input is not configured correctly (you can still click on the eye or mouth while the dungeon view is displayed) */
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_02_FIX Stop processing commands that should be ignored while pressing the eye or mouth */
        if (G331_B_PressingEye || G333_B_PressingMouth) {
                return;
        }
#endif
        if (L1160_i_Command == C145_COMMAND_SLEEP) { /* BUG0_53 It is possible to sleep while the inventory of a candidate champion is open. When the party wakes up, it is possible to add a duplicate copy of the same champion to the party. All the champion possessions are then cloned objects. It is also possible to grab an object from the candidate champion before sleeping and this will clone that object. The sleep icon is erased when the inventory of a candidate champion is opened but it is still possible to click on the sleep icon location on the top right of the viewport */
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_15_FIX The sleep action is disabled when the inventory of a candidate champion is opened */
                if (!G299_ui_CandidateChampionOrdinal) {
#endif
                        if (G423_i_InventoryChampionOrdinal) {
                                F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(C04_CHAMPION_CLOSE_INVENTORY);
                        }
                        F456_vzzz_START_DrawDisabledMenus();
                        G300_B_PartyIsSleeping = TRUE;
                        F379_jzzz_COMMAND_DrawSleepScreen();
                        F097_lzzz_DUNGEONVIEW_DrawViewport(C2_VIEWPORT_AS_BEFORE_SLEEP_OR_FREEZE_GAME);
                        G318_i_WaitForInputMaximumVerticalBlankCount = 0;
                        G441_ps_PrimaryMouseInput = G450_as_Graphic561_PrimaryMouseInput_PartySleeping;
                        G442_ps_SecondaryMouseInput = NULL;
                        G443_ps_PrimaryKeyboardInput = G460_as_Graphic561_PrimaryKeyboardInput_PartySleeping;
                        G444_ps_SecondaryKeyboardInput = NULL;
                        F357_qzzz_COMMAND_DiscardAllInput();
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_15_FIX */
                }
#endif
                return;
        }
        if (L1160_i_Command == C146_COMMAND_WAKE_UP) {
                F314_gzzz_CHAMPION_WakeUp();
                return;
        }
        if (L1160_i_Command == C140_COMMAND_SAVE_GAME) {
                if ((G305_ui_PartyChampionCount > 0) && !G299_ui_CandidateChampionOrdinal) {
                        F433_AA39_STARTEND_ProcessCommand140_SaveGame_COPYPROTECTIONCDF();
                }
                return;
        }
        if (L1160_i_Command == C147_COMMAND_FREEZE_GAME) {
                G301_B_GameTimeTicking = FALSE;
                F456_vzzz_START_DrawDisabledMenus();
                F134_zzzz_VIDEO_FillBitmap(G296_puc_Bitmap_Viewport, C00_COLOR_BLACK, M76_BITMAP_UNIT_COUNT(224, 136));
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 81, 69, C04_COLOR_CYAN, C00_COLOR_BLACK, "GAME FROZEN");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 66, 69, C04_COLOR_CYAN, C00_COLOR_BLACK, "SPIEL ANGEHALTEN");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                F040_aacZ_TEXT_Print(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 84, 69, C04_COLOR_CYAN, C00_COLOR_BLACK, "JEU BLOQUE");
#endif
                F097_lzzz_DUNGEONVIEW_DrawViewport(C2_VIEWPORT_AS_BEFORE_SLEEP_OR_FREEZE_GAME);
                G483_ps_PrimaryMouseInputBackup = G441_ps_PrimaryMouseInput;
                G484_ps_SecondaryMouseInputBackup = G442_ps_SecondaryMouseInput;
                G481_ps_PrimaryKeyboardInputBackup = G443_ps_PrimaryKeyboardInput;
                G482_ps_SecondaryKeyboardInputBackup = G444_ps_SecondaryKeyboardInput;
                G441_ps_PrimaryMouseInput = G451_as_Graphic561_PrimaryMouseInput_FrozenGame;
                G442_ps_SecondaryMouseInput = NULL;
                G443_ps_PrimaryKeyboardInput = G461_as_Graphic561_PrimaryKeyboardInput_FrozenGame;
                G444_ps_SecondaryKeyboardInput = NULL;
                F357_qzzz_COMMAND_DiscardAllInput();
                return;
        }
        if (L1160_i_Command == C148_COMMAND_UNFREEZE_GAME) {
                G301_B_GameTimeTicking = TRUE;
                F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF();
                G441_ps_PrimaryMouseInput = G483_ps_PrimaryMouseInputBackup;
                G442_ps_SecondaryMouseInput = G484_ps_SecondaryMouseInputBackup;
                G443_ps_PrimaryKeyboardInput = G481_ps_PrimaryKeyboardInputBackup;
                G444_ps_SecondaryKeyboardInput = G482_ps_SecondaryKeyboardInputBackup;
                F357_qzzz_COMMAND_DiscardAllInput();
                return;
        }
        if (L1160_i_Command == C200_COMMAND_ENTRANCE_ENTER_DUNGEON) {
                G298_B_NewGame = C001_MODE_LOAD_DUNGEON;
                return;
        }
        if (L1160_i_Command == C201_COMMAND_ENTRANCE_RESUME) {
                G298_B_NewGame = C000_MODE_LOAD_SAVED_GAME;
                return;
        }
        if (L1160_i_Command == C202_COMMAND_ENTRANCE_DRAW_CREDITS) {
                F442_AA08_STARTEND_ProcessCommand202_EntranceDrawCredits();
                return;
        }
        if ((L1160_i_Command >= C210_COMMAND_CLICK_ON_DIALOG_CHOICE_1) && (L1160_i_Command <= C213_COMMAND_CLICK_ON_DIALOG_CHOICE_4)) {
                G335_i_SelectedDialogChoice = L1160_i_Command - (C210_COMMAND_CLICK_ON_DIALOG_CHOICE_1 - 1);
                return;
        }
        if (L1160_i_Command == C215_COMMAND_RESTART_GAME) {
                G523_B_RestartGameRequested = TRUE;
        }
}
