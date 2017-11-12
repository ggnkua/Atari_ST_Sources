#include "DEFS.H"

overlay "timeline"

BOOLEAN F221_xxxx_GROUP_IsFluxcageOnSquare(P464_i_MapX, P465_i_MapY)
int P464_i_MapX;
int P465_i_MapY;
{
        register THING L0540_T_Thing;
        register int L0541_i_SquareType;


        if (((L0541_i_SquareType = M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(P464_i_MapX, P465_i_MapY))) == C00_ELEMENT_WALL) || (L0541_i_SquareType == C03_ELEMENT_STAIRS)) {
                return FALSE;
        }
        for(L0540_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P464_i_MapX, P465_i_MapY); L0540_T_Thing != C0xFFFE_THING_ENDOFLIST; L0540_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0540_T_Thing)) {
                if ((M12_TYPE(L0540_T_Thing) == C15_THING_TYPE_EXPLOSION) && (((EXPLOSION*)G284_apuc_ThingData[C15_THING_TYPE_EXPLOSION])[M13_INDEX(L0540_T_Thing)].Type == C050_EXPLOSION_FLUXCAGE)) {
                        return TRUE;
                }
        }
        return FALSE;
}

unsigned int F222_xxxx_GROUP_IsLordChaosOnSquare(P466_i_MapX, P467_i_MapY)
int P466_i_MapX;
int P467_i_MapY;
{
        register THING L0542_T_Thing;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        register GROUP* L0543_ps_Group;
#endif


        if ((L0542_T_Thing = F175_gzzz_GROUP_GetThing(P466_i_MapX, P467_i_MapY)) == C0xFFFE_THING_ENDOFLIST) {
                return 0;
        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        if (((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L0542_T_Thing)].Type == C23_CREATURE_LORD_CHAOS) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0543_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0542_T_Thing);
        if (L0543_ps_Group->Type == C23_CREATURE_LORD_CHAOS) {
#endif
                return L0542_T_Thing;
        }
        return 0;
}

#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
BOOLEAN F223_xxxx_GROUP_IsSquareACorridorTeleporterPitOrDoor(P468_i_MapX, P469_i_MapY)
int P468_i_MapX;
int P469_i_MapY;
{
        register int L0544_i_SquareType;


        return (((L0544_i_SquareType = M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(P468_i_MapX, P469_i_MapY))) == C01_ELEMENT_CORRIDOR) || (L0544_i_SquareType == C05_ELEMENT_TELEPORTER) || (L0544_i_SquareType == C02_ELEMENT_PIT) || (L0544_i_SquareType == C04_ELEMENT_DOOR));
}
#endif

VOID F224_zzzz_GROUP_FluxCageAction(P470_i_MapX, P471_i_MapY)
register int P470_i_MapX;
register int P471_i_MapY;
{
        register THING L0545_T_Thing;
        register int L0546_i_Multiple;
#define A0546_i_SquareType    L0546_i_Multiple
#define A0546_i_FluxcageCount L0546_i_Multiple
        EVENT L0547_s_Event;


        if (((A0546_i_SquareType = M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(P470_i_MapX, P471_i_MapY))) == C00_ELEMENT_WALL) || (A0546_i_SquareType == C03_ELEMENT_STAIRS)) {
                return;
        }
        if ((L0545_T_Thing = F166_szzz_DUNGEON_GetUnusedThing(C15_THING_TYPE_EXPLOSION)) == C0xFFFF_THING_NONE) {
                return;
        }
        F163_amzz_DUNGEON_LinkThingToList(L0545_T_Thing, 0, P470_i_MapX, P471_i_MapY);
        (((EXPLOSION*)G284_apuc_ThingData[C15_THING_TYPE_EXPLOSION])[M13_INDEX(L0545_T_Thing)]).Type = C050_EXPLOSION_FLUXCAGE;
        M33_SET_MAP_AND_TIME(L0547_s_Event.Map_Time, G272_i_CurrentMapIndex, G313_ul_GameTime + 100);
        L0547_s_Event.A.A.Type = C24_EVENT_REMOVE_FLUXCAGE;
        L0547_s_Event.A.A.Priority = 0;
        L0547_s_Event.C.Slot = L0545_T_Thing;
        L0547_s_Event.B.Location.MapX = P470_i_MapX;
        L0547_s_Event.B.Location.MapY = P471_i_MapY;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0547_s_Event);
        if (F222_xxxx_GROUP_IsLordChaosOnSquare(P470_i_MapX, P471_i_MapY - 1)) {
                P471_i_MapY--;
                A0546_i_FluxcageCount = F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX + 1, P471_i_MapY);
                goto T224_005;
        }
        if (F222_xxxx_GROUP_IsLordChaosOnSquare(P470_i_MapX - 1, P471_i_MapY)) {
                P470_i_MapX--;
                A0546_i_FluxcageCount = F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX, P471_i_MapY + 1);
                T224_005:
                A0546_i_FluxcageCount += F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX, P471_i_MapY - 1) + F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX - 1, P471_i_MapY);
        } else {
                if (F222_xxxx_GROUP_IsLordChaosOnSquare(P470_i_MapX + 1, P471_i_MapY)) {
                        P470_i_MapX++;
                        A0546_i_FluxcageCount = F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX, P471_i_MapY - 1);
                        goto T224_008;
                }
                if (F222_xxxx_GROUP_IsLordChaosOnSquare(P470_i_MapX, P471_i_MapY + 1)) {
                        P471_i_MapY++;
                        A0546_i_FluxcageCount = F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX - 1, P471_i_MapY);
                        T224_008:
                        A0546_i_FluxcageCount += F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX, P471_i_MapY + 1) + F221_xxxx_GROUP_IsFluxcageOnSquare(P470_i_MapX + 1, P471_i_MapY);
                } else {
                        A0546_i_FluxcageCount = 0;
                }
        }
        if (A0546_i_FluxcageCount == 2) {
                F209_xzzz_GROUP_ProcessEvents29to41(P470_i_MapX, P471_i_MapY, CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE, 0);
        }
}

VOID F225_dzzz_GROUP_FuseAction(P472_ui_MapX, P473_ui_MapY)
register unsigned int P472_ui_MapX;
register unsigned int P473_ui_MapY;
{
        register int L0548_i_MapX;
        register int L0549_i_MapY;
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        int L0550_i_SquareType;
#endif
        unsigned int L0551_ui_FluxcageCount;
        int L0552_i_FluxcageIndex;
        int L0553_i_Counter;
        BOOLEAN L0554_aB_Fluxcages[4];
        THING L0555_T_LordChaosThing;


#ifdef C24_COMPILE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE5_02_FIX The Fuse action is aborted if the specified coordinates are outside the map bounds */
        if ((P472_ui_MapX < 0) || (P472_ui_MapX >= G273_i_CurrentMapWidth) || (P473_ui_MapY < 0) || (P473_ui_MapY >= G274_i_CurrentMapHeight)) {
                return;
        }
#endif
        F213_hzzz_EXPLOSION_Create(C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL, 255, P472_ui_MapX, P473_ui_MapY, C255_SINGLE_CENTERED_CREATURE); /* BUG0_17 The game crashes after the Fuse action is performed while looking at a wall on a map boundary. An explosion thing is created on the square in front of the party but there is no check to ensure the square coordinates are in the map bounds. This corrupts a memory location and leads to a game crash */
        if (L0555_T_LordChaosThing = F222_xxxx_GROUP_IsLordChaosOnSquare(P472_ui_MapX, P473_ui_MapY)) {
                L0551_ui_FluxcageCount = (L0554_aB_Fluxcages[0] = F221_xxxx_GROUP_IsFluxcageOnSquare(P472_ui_MapX - 1, P473_ui_MapY)) +
                                         (L0554_aB_Fluxcages[1] = F221_xxxx_GROUP_IsFluxcageOnSquare(P472_ui_MapX + 1, P473_ui_MapY)) +
                                         (L0554_aB_Fluxcages[2] = F221_xxxx_GROUP_IsFluxcageOnSquare(P472_ui_MapX, P473_ui_MapY - 1)) +
                                         (L0554_aB_Fluxcages[3] = F221_xxxx_GROUP_IsFluxcageOnSquare(P472_ui_MapX, P473_ui_MapY + 1));
                while (L0551_ui_FluxcageCount++ < 4) {
                        L0548_i_MapX = P472_ui_MapX;
                        L0549_i_MapY = P473_ui_MapY;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                        L0553_i_Counter = 5, L0552_i_FluxcageIndex = M04_RANDOM(4);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                        L0552_i_FluxcageIndex = M04_RANDOM(4);
                        L0553_i_Counter = 5;
#endif
                        while (--L0553_i_Counter) {
                                if (!L0554_aB_Fluxcages[L0552_i_FluxcageIndex]) {
                                        L0554_aB_Fluxcages[L0552_i_FluxcageIndex] = TRUE;
                                        switch (L0552_i_FluxcageIndex) {
                                                case 0:
                                                        L0548_i_MapX--;
                                                        break;
                                                case 1:
                                                        L0548_i_MapX++;
                                                        break;
                                                case 2:
                                                        L0549_i_MapY--;
                                                        break;
                                                case 3:
                                                        L0549_i_MapY++;
                                        }
                                        break;
                                }
                                L0552_i_FluxcageIndex = M17_NEXT(L0552_i_FluxcageIndex);
                        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        if (((L0550_i_SquareType = M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(L0548_i_MapX, L0549_i_MapY))) == C01_ELEMENT_CORRIDOR) || (L0550_i_SquareType == C05_ELEMENT_TELEPORTER) || (L0550_i_SquareType == C02_ELEMENT_PIT) || (L0550_i_SquareType == C04_ELEMENT_DOOR)) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        if (F223_xxxx_GROUP_IsSquareACorridorTeleporterPitOrDoor(L0548_i_MapX, L0549_i_MapY)) {
#endif
                                if (!F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0555_T_LordChaosThing, P472_ui_MapX, P473_ui_MapY, L0548_i_MapX, L0549_i_MapY)) {
                                        F180_hzzz_GROUP_StartWandering(L0548_i_MapX, L0549_i_MapY);
                                }
                                return;
                        }
                }
                F446_zzzz_STARTEND_FuseSequence();
        }
}

int F226_ozzz_GROUP_GetDistanceBetweenSquares(P474_i_SourceMapX, P475_i_SourceMapY, P476_i_DestinationMapX, P477_i_DestinationMapY)
register int P474_i_SourceMapX;
register int P475_i_SourceMapY;
int P476_i_DestinationMapX;
int P477_i_DestinationMapY;
{
        return ((((P474_i_SourceMapX -= P476_i_DestinationMapX) < 0) ? -P474_i_SourceMapX : P474_i_SourceMapX) +
                (((P475_i_SourceMapY -= P477_i_DestinationMapY) < 0) ? -P475_i_SourceMapY : P475_i_SourceMapY));
}

BOOLEAN F227_qzzz_GROUP_IsDestinationVisibleFromSource(P478_i_Direction, P479_i_SourceMapX, P480_i_SourceMapY, P481_i_DestinationMapX, P482_i_DestinationMapY)
int P478_i_Direction;
register int P479_i_SourceMapX;
register int P480_i_SourceMapY;
register int P481_i_DestinationMapX;
register int P482_i_DestinationMapY;
{
        switch (P478_i_Direction) { /* If direction is not 'West' then swap variables so that the same test as for west can be applied */
                case C2_DIRECTION_SOUTH:
                        asm {
                                exg     P479_i_SourceMapX,P482_i_DestinationMapY        /* Exchange values */
                                exg     P481_i_DestinationMapX,P480_i_SourceMapY        /* Exchange values */
                        }
                        break;
                case C1_DIRECTION_EAST:
                        asm {
                                exg     P479_i_SourceMapX,P481_i_DestinationMapX        /* Exchange values */
                                exg     P480_i_SourceMapY,P482_i_DestinationMapY        /* Exchange values */
                        }
                        break;
                case C0_DIRECTION_NORTH:
                        asm {
                                exg     P479_i_SourceMapX,P480_i_SourceMapY             /* Exchange values */
                                exg     P481_i_DestinationMapX,P482_i_DestinationMapY   /* Exchange values */
                        }
        }
        return ((P479_i_SourceMapX -= (P481_i_DestinationMapX - 1)) > 0) && ((((P480_i_SourceMapY -= P482_i_DestinationMapY) < 0) ? -P480_i_SourceMapY : P480_i_SourceMapY) <= P479_i_SourceMapX);
}

int F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource(P483_i_SourceMapX, P484_i_SourceMapY, P485_i_DestinationMapX, P486_i_DestinationMapY)
register int P483_i_SourceMapX;
#define AP483_i_PrimaryDirection P483_i_SourceMapX
register int P484_i_SourceMapY;
register int P485_i_DestinationMapX;
int P486_i_DestinationMapY;
{
        register int L0556_i_Direction;


        if (P483_i_SourceMapX == P485_i_DestinationMapX) {
                G363_i_SecondaryDirectionToOrFromParty = (M06_RANDOM(65536) & 0x0002) + 1; /* Resulting direction may be 1 or 3 (East or West) */
                if (P484_i_SourceMapY > P486_i_DestinationMapY) {
                        return C0_DIRECTION_NORTH;
                }
                return C2_DIRECTION_SOUTH;
        }
        if (P484_i_SourceMapY == P486_i_DestinationMapY) {
                G363_i_SecondaryDirectionToOrFromParty = (M06_RANDOM(65536) & 0x0002) + 0; /* Resulting direction may be 0 or 2 (North or South) */
                if (P483_i_SourceMapX > P485_i_DestinationMapX) {
                        return C3_DIRECTION_WEST;
                }
                return C1_DIRECTION_EAST;
        }
        L0556_i_Direction = C0_DIRECTION_NORTH;
        do {
                if (F227_qzzz_GROUP_IsDestinationVisibleFromSource(L0556_i_Direction, P483_i_SourceMapX, P484_i_SourceMapY, P485_i_DestinationMapX, P486_i_DestinationMapY)) {
                        if (!F227_qzzz_GROUP_IsDestinationVisibleFromSource(G363_i_SecondaryDirectionToOrFromParty = M17_NEXT(L0556_i_Direction), P483_i_SourceMapX, P484_i_SourceMapY, P485_i_DestinationMapX, P486_i_DestinationMapY)) {
                                if ((L0556_i_Direction != C0_DIRECTION_NORTH) || !F227_qzzz_GROUP_IsDestinationVisibleFromSource(G363_i_SecondaryDirectionToOrFromParty = M19_PREVIOUS(L0556_i_Direction), P483_i_SourceMapX, P484_i_SourceMapY, P485_i_DestinationMapX, P486_i_DestinationMapY)) {
                                        G363_i_SecondaryDirectionToOrFromParty = M17_NEXT((M06_RANDOM(65536) & 0x0002) + L0556_i_Direction);
                                        return L0556_i_Direction;
                                }
                        }
                        if (M05_RANDOM(2)) {
                                AP483_i_PrimaryDirection = G363_i_SecondaryDirectionToOrFromParty;
                                G363_i_SecondaryDirectionToOrFromParty = L0556_i_Direction;
                                return AP483_i_PrimaryDirection;
                        }
                        return L0556_i_Direction;
                }
                L0556_i_Direction++;
        } while ();
}

VOID F229_hzzz_GROUP_SetOrderedCellsToAttack(P487_pc_OrderedCellsToAttack, P488_i_TargetMapX, P489_i_TargetMapY, P490_i_AttackerMapX, P491_i_AttackerMapY, P492_ui_CellSource)
char* P487_pc_OrderedCellsToAttack;
int P488_i_TargetMapX;
int P489_i_TargetMapY;
int P490_i_AttackerMapX;
int P491_i_AttackerMapY;
unsigned int P492_ui_CellSource;
{
        register int L0557_i_OrderedCellsToAttackIndex;


        if (!((L0557_i_OrderedCellsToAttackIndex = F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource(P488_i_TargetMapX, P489_i_TargetMapY, P490_i_AttackerMapX, P491_i_AttackerMapY) << 1) & 0x0002)) {
                P492_ui_CellSource++;
        }
        L0557_i_OrderedCellsToAttackIndex += (P492_ui_CellSource >> 1) & 0x0001;
        F007_aAA7_MAIN_CopyBytes(G023_aac_Graphic562_OrderedCellsToAttack[L0557_i_OrderedCellsToAttackIndex], P487_pc_OrderedCellsToAttack, 4);
}

int F230_ezzz_GROUP_GetChampionDamage(P493_ps_Group, P494_i_ChampionIndex)
register GROUP* P493_ps_Group;
int P494_i_ChampionIndex;
{
        register int L0558_i_Multiple;
#define A0558_i_Attack L0558_i_Multiple
#define A0558_i_Damage L0558_i_Multiple
        register unsigned int L0559_ui_Multiple;
#define A0559_ui_WoundTest    L0559_ui_Multiple
#define A0559_ui_PoisonAttack L0559_ui_Multiple
        register unsigned int L0560_ui_WoundProbabilities;
        register unsigned int L0561_ui_Multiple;
#define A0561_ui_WoundProbabilityIndex L0561_ui_Multiple
#define A0561_ui_AllowedWound          L0561_ui_Multiple
        register CHAMPION* L0562_ps_Champion;
        int L0563_i_DoubledMapDifficulty;
        CREATURE_INFO L0564_s_CreatureInfo;


        L0562_ps_Champion = &G407_s_Party.Champions[P494_i_ChampionIndex];
        if (P494_i_ChampionIndex >= G305_ui_PartyChampionCount) {
                return 0;
        }
        if (!L0562_ps_Champion->CurrentHealth) {
                return 0;
        }
        if (G300_B_PartyIsSleeping) {
                F314_gzzz_CHAMPION_WakeUp();
        }
        L0563_i_DoubledMapDifficulty = G269_ps_CurrentMap->C.Difficulty << 1;
        L0564_s_CreatureInfo = G243_as_Graphic559_CreatureInfo[P493_ps_Group->Type];
        F304_apzz_CHAMPION_AddSkillExperience(P494_i_ChampionIndex, C07_SKILL_PARRY, M58_EXPERIENCE(L0564_s_CreatureInfo.Properties));
        if (G300_B_PartyIsSleeping || (((F311_wzzz_CHAMPION_GetDexterity(L0562_ps_Champion) < (M03_RANDOM(32) + L0564_s_CreatureInfo.Dexterity + L0563_i_DoubledMapDifficulty - 16)) || !M04_RANDOM(4)) && !F308_vzzz_CHAMPION_IsLucky(L0562_ps_Champion, 60))) {
                if ((A0559_ui_WoundTest = M06_RANDOM(65536)) & 0x0070) {
                        A0559_ui_WoundTest &= 0x000F;
                        L0560_ui_WoundProbabilities = L0564_s_CreatureInfo.WoundProbabilities;
                        A0561_ui_WoundProbabilityIndex = 0;
                        while (A0559_ui_WoundTest > (L0560_ui_WoundProbabilities & 0x000F)) {
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                                L0560_ui_WoundProbabilities >>= 4, A0561_ui_WoundProbabilityIndex++;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                                A0561_ui_WoundProbabilityIndex++;
                                L0560_ui_WoundProbabilities >>= 4;
#endif
                        }
                        A0561_ui_AllowedWound = G024_ac_Graphic562_WoundProbabilityIndexToWoundMask[A0561_ui_WoundProbabilityIndex];
                } else {
                        A0561_ui_AllowedWound = A0559_ui_WoundTest & 0x0001; /* 0 (Ready hand) or 1 (action hand) */
                }
                if ((A0558_i_Attack = (M03_RANDOM(16) + L0564_s_CreatureInfo.Attack + L0563_i_DoubledMapDifficulty) - (F303_AA09_CHAMPION_GetSkillLevel(P494_i_ChampionIndex, C07_SKILL_PARRY) << 1)) <= 1) {
                        if (M05_RANDOM(2)) {
                                goto T230_014;
                        }
                        A0558_i_Attack = M04_RANDOM(4) + 2;
                }
                A0558_i_Attack >>= 1;
                A0558_i_Attack += M02_RANDOM(A0558_i_Attack) + M04_RANDOM(4);
                A0558_i_Attack += M02_RANDOM(A0558_i_Attack);
                A0558_i_Attack >>= 2;
                A0558_i_Attack += M04_RANDOM(4) + 1;
                if (M05_RANDOM(2)) {
                        A0558_i_Attack -= M02_RANDOM((A0558_i_Attack >> 1) + 1) - 1;
                }
                if (A0558_i_Damage = F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(P494_i_ChampionIndex, A0558_i_Attack, A0561_ui_AllowedWound, L0564_s_CreatureInfo.AttackType)) {
                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C09_SOUND_CHAMPION_0_DAMAGED + P494_i_ChampionIndex, G306_i_PartyMapX, G307_i_PartyMapY, C02_MODE_PLAY_ONE_TICK_LATER);
                        if ((A0559_ui_PoisonAttack = L0564_s_CreatureInfo.PoisonAttack) && M05_RANDOM(2) && ((A0559_ui_PoisonAttack = F307_fzzz_CHAMPION_GetStatisticAdjustedAttack(L0562_ps_Champion, C4_STATISTIC_VITALITY, A0559_ui_PoisonAttack)) >= 0)) {
                                F322_lzzz_CHAMPION_Poison(P494_i_ChampionIndex, A0559_ui_PoisonAttack);
                        }
                        return A0558_i_Damage;
                }
        }
        T230_014:
        return 0;
}

int F231_izzz_GROUP_GetMeleeActionDamage(P495_ps_Champion, P496_i_ChampionIndex, P497_ps_Group, P498_i_CreatureIndex, P499_i_MapX, P500_i_MapY, P501_i_ActionHitProbability, P502_ui_ActionDamageFactor, P503_i_SkillIndex)
register CHAMPION* P495_ps_Champion;
int P496_i_ChampionIndex;
register GROUP* P497_ps_Group;
int P498_i_CreatureIndex;
int P499_i_MapX;
int P500_i_MapY;
int P501_i_ActionHitProbability;
unsigned int P502_ui_ActionDamageFactor;
int P503_i_SkillIndex;
{
        register int L0565_i_Damage;
        register int L0566_i_Damage;
        register int L0567_i_DoubledMapDifficulty;
        register int L0568_i_Defense;
        int L0569_i_Outcome;
        BOOLEAN L0570_B_ActionHitsNonMaterialCreatures;
        int L0571_i_ActionHandObjectIconIndex;
        CREATURE_INFO* L0572_ps_CreatureInfo;


        if (P496_i_ChampionIndex >= G305_ui_PartyChampionCount) {
                return 0;
        }
        if (!P495_ps_Champion->CurrentHealth) {
                return 0;
        }
        L0567_i_DoubledMapDifficulty = G269_ps_CurrentMap->C.Difficulty << 1;
        L0572_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[P497_ps_Group->Type];
        L0571_i_ActionHandObjectIconIndex = F033_aaaz_OBJECT_GetIconIndex(P495_ps_Champion->Slots[C01_SLOT_ACTION_HAND]);
        if (L0570_B_ActionHitsNonMaterialCreatures = M07_GET(P501_i_ActionHitProbability, MASK0x8000_HIT_NON_MATERIAL_CREATURES)) {
                M09_CLEAR(P501_i_ActionHitProbability, MASK0x8000_HIT_NON_MATERIAL_CREATURES);
        }
        if ((!M07_GET(L0572_ps_CreatureInfo->Attributes, MASK0x0040_NON_MATERIAL) || L0570_B_ActionHitsNonMaterialCreatures) &&
            ((F311_wzzz_CHAMPION_GetDexterity(P495_ps_Champion) > (M03_RANDOM(32) + L0572_ps_CreatureInfo->Dexterity + L0567_i_DoubledMapDifficulty - 16)) ||
             (!M04_RANDOM(4)) ||
             (F308_vzzz_CHAMPION_IsLucky(P495_ps_Champion, 75 - P501_i_ActionHitProbability)))) {
                if (!(L0565_i_Damage = F312_xzzz_CHAMPION_GetStrength(P496_i_ChampionIndex, C01_SLOT_ACTION_HAND))) {
                        goto T231_009;
                }
                L0565_i_Damage += M02_RANDOM((L0565_i_Damage >> 1) + 1);
                L0565_i_Damage = ((long)L0565_i_Damage * (long)P502_ui_ActionDamageFactor) >> 5;
                L0568_i_Defense = M03_RANDOM(32) + L0572_ps_CreatureInfo->Defense + L0567_i_DoubledMapDifficulty;
                if (L0571_i_ActionHandObjectIconIndex == C039_ICON_WEAPON_DIAMOND_EDGE) {
                        L0568_i_Defense -= L0568_i_Defense >> 2;
                } else {
                        if (L0571_i_ActionHandObjectIconIndex == C043_ICON_WEAPON_HARDCLEAVE_EXECUTIONER) {
                                L0568_i_Defense -= L0568_i_Defense >> 3;
                        }
                }
                if ((L0566_i_Damage = L0565_i_Damage = M03_RANDOM(32) + L0565_i_Damage - L0568_i_Defense) <= 1) {
                        T231_009:
                        if (!(L0565_i_Damage = M04_RANDOM(4))) {
                                goto T231_015;
                        }
                        L0565_i_Damage++;
                        if (((L0566_i_Damage += M03_RANDOM(16)) > 0) || (M05_RANDOM(2))) {
                                L0565_i_Damage += M04_RANDOM(4);
                                if (!M04_RANDOM(4)) {
                                        L0565_i_Damage += F025_aatz_MAIN_GetMaximumValue(0, L0566_i_Damage + M03_RANDOM(16));
                                }
                        }
                }
                L0565_i_Damage >>= 1;
                L0565_i_Damage += M02_RANDOM(L0565_i_Damage) + M04_RANDOM(4);
                L0565_i_Damage += M02_RANDOM(L0565_i_Damage);
                L0565_i_Damage >>= 2;
                L0565_i_Damage += M04_RANDOM(4) + 1;
                if ((L0571_i_ActionHandObjectIconIndex == C040_ICON_WEAPON_VORPAL_BLADE) && !M07_GET(L0572_ps_CreatureInfo->Attributes, MASK0x0040_NON_MATERIAL) && !(L0565_i_Damage >>= 1)) {
                        goto T231_015;
                }
                if (M03_RANDOM(64) < F303_AA09_CHAMPION_GetSkillLevel(P496_i_ChampionIndex, P503_i_SkillIndex)) {
                        L0565_i_Damage += L0565_i_Damage + 10;
                }
                L0569_i_Outcome = F190_zzzz_GROUP_GetDamageCreatureOutcome(P497_ps_Group, P498_i_CreatureIndex, P499_i_MapX, P500_i_MapY, L0565_i_Damage, TRUE);
                F304_apzz_CHAMPION_AddSkillExperience(P496_i_ChampionIndex, P503_i_SkillIndex, (L0565_i_Damage * M58_EXPERIENCE(L0572_ps_CreatureInfo->Properties) >> 4) + 3);
                F325_bzzz_CHAMPION_DecrementStamina(P496_i_ChampionIndex, M04_RANDOM(4) + 4);
                goto T231_016;
        }
        T231_015:
        L0565_i_Damage = 0;
        L0569_i_Outcome = C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP;
        F325_bzzz_CHAMPION_DecrementStamina(P496_i_ChampionIndex, M05_RANDOM(2) + 2);
        T231_016:
        F292_arzz_CHAMPION_DrawState(P496_i_ChampionIndex);
        if (L0569_i_Outcome != C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP) {
                F209_xzzz_GROUP_ProcessEvents29to41(P499_i_MapX, P500_i_MapY, CM1_EVENT_CREATE_REACTION_EVENT_31_PARTY_IS_ADJACENT, 0);
        }
        return L0565_i_Damage;
}

BOOLEAN F232_dzzz_GROUP_IsDoorDestroyedByAttack(P504_ui_MapX, P505_ui_MapY, P506_i_Attack, P507_B_MagicAttack, P508_i_Ticks)
unsigned int P504_ui_MapX;
unsigned int P505_ui_MapY;
int P506_i_Attack;
BOOLEAN P507_B_MagicAttack;
int P508_i_Ticks;
{
        register DOOR* L0573_ps_Door;
        register unsigned char* L0574_puc_Square;
        EVENT L0575_s_Event;


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0573_ps_Door = &((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(P504_ui_MapX, P505_ui_MapY))];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0573_ps_Door = (DOOR*)F157_rzzz_DUNGEON_GetSquareFirstThingData(P504_ui_MapX, P505_ui_MapY);
#endif
        if ((P507_B_MagicAttack && !L0573_ps_Door->MagicDestructible) || (!P507_B_MagicAttack && !L0573_ps_Door->MeleeDestructible)) {
                return FALSE;
        }
        if (P506_i_Attack >= G275_as_CurrentMapDoorInfo[L0573_ps_Door->Type].Defense) {
                L0574_puc_Square = &G271_ppuc_CurrentMapData[P504_ui_MapX][P505_ui_MapY];
                if (M36_DOOR_STATE(*L0574_puc_Square) == C4_DOOR_STATE_CLOSED) {
                        if (P508_i_Ticks) {
                                M33_SET_MAP_AND_TIME(L0575_s_Event.Map_Time, G272_i_CurrentMapIndex, G313_ul_GameTime + P508_i_Ticks);
                                L0575_s_Event.A.A.Type = C02_EVENT_DOOR_DESTRUCTION;
                                L0575_s_Event.A.A.Priority = 0;
                                L0575_s_Event.B.Location.MapX = P504_ui_MapX;
                                L0575_s_Event.B.Location.MapY = P505_ui_MapY;
                                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0575_s_Event);
                        } else {
                                M37_SET_DOOR_STATE(*L0574_puc_Square, C5_DOOR_STATE_DESTROYED);
                        }
                        return TRUE;
                }
        }
        return FALSE;
}
