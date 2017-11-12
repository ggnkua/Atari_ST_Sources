#include "DEFS.H"

/*_Global variables_*/
unsigned int G369_ui_EventMaximumCount;
EVENT* G370_ps_Events;
int* G371_pi_Timeline;
unsigned int G372_ui_EventCount;
unsigned int G373_ui_FirstUnusedEventIndex;
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_05_FIX */
long G374_l_WatchdogTime = 0x00FFFFFF;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_05_FIX */
long G374_l_WatchdogTime;
#endif

overlay "timeline"

VOID F233_wzzz_TIMELINE_Initialize()
{
        register int L0576_i_EventIndex;
        register EVENT* L0577_ps_Event;


        G370_ps_Events = (EVENT*)F468_ozzz_MEMORY_Allocate((long)(G369_ui_EventMaximumCount * sizeof(EVENT)), C1_ALLOCATION_PERMANENT);
        G371_pi_Timeline = (int*)F468_ozzz_MEMORY_Allocate((long)(G369_ui_EventMaximumCount * sizeof(int)), C1_ALLOCATION_PERMANENT);
        if (G298_B_NewGame) {
                for(L0576_i_EventIndex = 0, L0577_ps_Event = G370_ps_Events; L0576_i_EventIndex < G369_ui_EventMaximumCount; L0576_i_EventIndex++, L0577_ps_Event++) {
                        L0577_ps_Event->A.A.Type = C00_EVENT_NONE;
                }
                G372_ui_EventCount = 0;
                G373_ui_FirstUnusedEventIndex = 0;
                F256_xxxx_TIMELINE_ProcessEvent53_Watchdog();
        }
}

#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_01_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
BOOLEAN F234_xxxx_TIMELINE_IsEventABeforeEventB(P509_ps_EventA, P510_ps_EventB)
register EVENT* P509_ps_EventA;
register EVENT* P510_ps_EventB;
{
        register BOOLEAN L0578_B_Simultaneous;


        return (M30_TIME(P509_ps_EventA->Map_Time) < M30_TIME(P510_ps_EventB->Map_Time)) ||
               ((L0578_B_Simultaneous = (M30_TIME(P509_ps_EventA->Map_Time) == M30_TIME(P510_ps_EventB->Map_Time))) && (P509_ps_EventA->A.Type_Priority > P510_ps_EventB->A.Type_Priority)) ||
               (L0578_B_Simultaneous && (P509_ps_EventA->A.Type_Priority == P510_ps_EventB->A.Type_Priority) && (P509_ps_EventA <= P510_ps_EventB));
}
#endif
#ifdef C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE3_01_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
BOOLEAN F234_xxxx_TIMELINE_IsEventABeforeEventB(P509_ps_EventA, P510_ps_EventB)
register EVENT* P509_ps_EventA;
register EVENT* P510_ps_EventB;
{
        asm {
                        moveq   #1,D0
                        move.l  #0x00FFFFFF,D1
                        move.l  (P509_ps_EventA)+,D2
                        and.l   D1,D2                           /* D2 is the time of Event A */
                        and.l   (P510_ps_EventB)+,D1            /* D1 is the time of Event B */
                        cmp.l   D1,D2
                        blt.s   T234_005_Return                 /* If Event A expires before Event B */
                        bne.s   T234_001                        /* If Event A and Event B do not expire at the same time (implies that Event B expires before Event A) */
                        move.w  (P509_ps_EventA),D2
                        cmp.w   (P510_ps_EventB),D2             /* Compare next word in Event (event type and priority) */
                        bhi.s   T234_005_Return
                        bne.s   T234_001
                        cmpa.l  P509_ps_EventA,P510_ps_EventB   /* As a last resort, compare memory addresses of the events */
                        bcc.s   T234_005_Return
                T234_001:
                        moveq   #0,D0
                T234_005_Return:
        }
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION Variable definition changed */
BOOLEAN F234_xxxx_TIMELINE_IsEventABeforeEventB(P509_ps_EventA, P510_ps_EventB)
EVENT* P509_ps_EventA;
EVENT* P510_ps_EventB;
{
        asm {
                        movea.l P509_ps_EventA(A6),A0
                        movea.l P510_ps_EventB(A6),A1
                        moveq   #1,D0
                        move.l  #0x00FFFFFF,D1
                        move.l  (A0)+,D2
                        and.l   D1,D2                   /* D2 is the time of Event A */
                        and.l   (A1)+,D1                /* D1 is the time of Event B */
                        cmp.l   D1,D2
                        blt.s   T234_005_Return         /* If Event A expires before Event B */
                        bne.s   T234_001                /* If Event A and Event B do not expire at the same time (implies that Event B expires before Event A) */
                        cmpm.w  (A1)+,(A0)+             /* Compare next word in Event (event type and priority) */
                        bhi.s   T234_005_Return
                        bne.s   T234_001
                        cmpa.l  A0,A1                   /* As a last resort, compare memory addresses of the events */
                        bcc.s   T234_005_Return
                T234_001:
                        moveq   #0,D0
                T234_005_Return:
        }
}
#endif

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
int F235_bzzz_TIMELINE_GetIndex(P511_i_EventIndex)
register int P511_i_EventIndex;
{
        register int L0579_i_TimelineIndex;
        register int* L0580_pi_TimelineEntry;


        for(L0579_i_TimelineIndex = 0, L0580_pi_TimelineEntry = G371_pi_Timeline; L0579_i_TimelineIndex < G369_ui_EventMaximumCount; L0579_i_TimelineIndex++) {
                if (*L0580_pi_TimelineEntry++ == P511_i_EventIndex) {
                        break;
                }
        }
        if (L0579_i_TimelineIndex >= G369_ui_EventMaximumCount) { /* BUG0_00 Useless code. The function is always called with event indices that are in the timeline */
                L0579_i_TimelineIndex = 0; /* BUG0_01 Coding error without consequence. Wrong return value. If the specified event index is not found in the timeline the function returns 0 which is the same value that is returned if the event index is found in the first timeline entry. No consequence because this code is never executed */
        }
        return L0579_i_TimelineIndex;
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
int F235_bzzz_TIMELINE_GetIndex(P511_i_EventIndex)
int P511_i_EventIndex;
{
        asm {
                        movea.l G371_pi_Timeline(A4),A0
                        move.w  G369_ui_EventMaximumCount(A4),D1 
                        move.w  P511_i_EventIndex(A6),D2         
                        moveq   #0,D0                            
                T235_001_Loop:                                   
                        cmp.w   (A0)+,D2                         
                        beq.s   T235_005_Return                  
                        addq.w  #1,D0                            
                        cmp.w   D1,D0                            
                        bcs.s   T235_001_Loop                    
                        moveq   #0,D0                            /* BUG0_01 Coding error without consequence. Wrong return value. If the specified event index is not found in the timeline the function returns 0 which is the same value that is returned if the event index is found in the first timeline entry. No consequence because this code is never executed */
                T235_005_Return:
        }
}
#endif

/* This function fixes the placement of the specified timeline entry so that event indices are sorted chronologically in the timeline */
VOID F236_pzzz_TIMELINE_FixChronology(P512_ui_TimelineIndex)
register unsigned int P512_ui_TimelineIndex;
{
        register unsigned int L0581_ui_TimelineIndex;
        register int L0582_i_EventIndex;
        register unsigned int L0583_ui_EventCount;
        register EVENT* L0584_ps_Event;
        BOOLEAN L0585_B_ChronologyFixed;


        if ((L0583_ui_EventCount = G372_ui_EventCount) == 1) {
                return;
        }
        L0584_ps_Event = &G370_ps_Events[L0582_i_EventIndex = G371_pi_Timeline[P512_ui_TimelineIndex]];
        L0585_B_ChronologyFixed = FALSE;
        while (P512_ui_TimelineIndex > 0) { /* Check if the event should be moved earlier in the timeline */
                L0581_ui_TimelineIndex = (P512_ui_TimelineIndex - 1) >> 1;
                if (F234_xxxx_TIMELINE_IsEventABeforeEventB(L0584_ps_Event, &G370_ps_Events[G371_pi_Timeline[L0581_ui_TimelineIndex]])) {
                        G371_pi_Timeline[P512_ui_TimelineIndex] = G371_pi_Timeline[L0581_ui_TimelineIndex];
                        P512_ui_TimelineIndex = L0581_ui_TimelineIndex;
                        L0585_B_ChronologyFixed = TRUE;
                        continue;
                }
                break;
        }
        if (L0585_B_ChronologyFixed) {
                goto T236_011;
        }
        L0583_ui_EventCount = ((L0583_ui_EventCount - 1) - 1) >> 1;
        while (P512_ui_TimelineIndex <= L0583_ui_EventCount) { /* Check if the event should be moved later in the timeline */
                L0581_ui_TimelineIndex = (P512_ui_TimelineIndex << 1) + 1;
                if (((L0581_ui_TimelineIndex + 1) < G372_ui_EventCount) && (F234_xxxx_TIMELINE_IsEventABeforeEventB(&G370_ps_Events[G371_pi_Timeline[L0581_ui_TimelineIndex + 1]], &G370_ps_Events[G371_pi_Timeline[L0581_ui_TimelineIndex]]))) {
                        L0581_ui_TimelineIndex++;
                }
                if (F234_xxxx_TIMELINE_IsEventABeforeEventB(&G370_ps_Events[G371_pi_Timeline[L0581_ui_TimelineIndex]], L0584_ps_Event)) {
                        G371_pi_Timeline[P512_ui_TimelineIndex] = G371_pi_Timeline[L0581_ui_TimelineIndex];
                        P512_ui_TimelineIndex = L0581_ui_TimelineIndex;
                        continue;
                }
                break;
        }
        T236_011:
        G371_pi_Timeline[P512_ui_TimelineIndex] = L0582_i_EventIndex;
}

VOID F237_rzzz_TIMELINE_DeleteEvent(P513_i_EventIndex)
register int P513_i_EventIndex;
{
        register int L0586_i_TimelineIndex;
        register int L0587_i_EventCount;


        G370_ps_Events[P513_i_EventIndex].A.A.Type = C00_EVENT_NONE;
        if (P513_i_EventIndex < G373_ui_FirstUnusedEventIndex) {
                G373_ui_FirstUnusedEventIndex = P513_i_EventIndex;
        }
        G372_ui_EventCount--;
        if ((L0587_i_EventCount = G372_ui_EventCount) == 0) {
                return;
        }
        L0586_i_TimelineIndex = F235_bzzz_TIMELINE_GetIndex(P513_i_EventIndex);
        if (L0586_i_TimelineIndex == L0587_i_EventCount) {
                return;
        }
        G371_pi_Timeline[L0586_i_TimelineIndex] = G371_pi_Timeline[L0587_i_EventCount];
        F236_pzzz_TIMELINE_FixChronology(L0586_i_TimelineIndex);
}

int F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P514_ps_Event)
register EVENT* P514_ps_Event;
{
        register int L0588_i_EventIndex;
        register int L0589_i_Unreferenced; /* BUG0_00 Useless code */
        register int L0590_i_NewEventIndex;
        register EVENT* L0591_ps_Event;


        if (G372_ui_EventCount == G369_ui_EventMaximumCount) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_05_FIX */
                T238_001:
                return 0; /* BUG0_18 When events are exhausted and the timeline is full, new events are not added to the timeline which can cause various issues: A projectile stays immobile in the air, an explosion remains forever on a square, a spell effect stays active forever (like Light, Shields, Footprints), a champion action icon remains disabled forever */
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_05_FIX The game stops instead of not adding event to the timeline */
                F019_aarz_MAIN_DisplayErrorAndStop(C45_ERROR_TIMELINE_FULL);
#endif
        }
#ifndef NOCOPYPROTECTION
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_04_IMPROVEMENT */
        if (G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE != C03217_FALSE) {
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT Events are not added anymore if G418_l_LastEvent22Time_COPYPROTECTIONE is 0 (set by graphic #21 or by F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits if there are no differences in fuzzy bits) */
        if ((G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE != C03217_FALSE) || G418_l_LastEvent22Time_COPYPROTECTIONE == 0) {
#endif
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_05_FIX */
                goto T238_001;
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_05_FIX The goto is not possible anymore as the first return 0 was removed */
                return 0;
#endif
        }
#endif
        if ((P514_ps_Event->A.A.Type >= C05_EVENT_CORRIDOR) && (P514_ps_Event->A.A.Type <= C10_EVENT_DOOR)) {
                for(L0588_i_EventIndex = 0, L0591_ps_Event = G370_ps_Events; L0588_i_EventIndex < G369_ui_EventMaximumCount; L0588_i_EventIndex++, L0591_ps_Event++) {
                        if ((L0591_ps_Event->A.A.Type >= C05_EVENT_CORRIDOR) && (L0591_ps_Event->A.A.Type <= C10_EVENT_DOOR)) {
                                if ((P514_ps_Event->Map_Time == L0591_ps_Event->Map_Time) && (P514_ps_Event->B.MapXY == L0591_ps_Event->B.MapXY) && ((L0591_ps_Event->A.A.Type != C06_EVENT_WALL) || (L0591_ps_Event->C.A.Cell == P514_ps_Event->C.A.Cell))) {
                                        L0591_ps_Event->C.A.Effect = P514_ps_Event->C.A.Effect;
                                        return L0588_i_EventIndex;
                                }
                                continue;
                        } else {
                                if ((L0591_ps_Event->A.A.Type == C01_EVENT_DOOR_ANIMATION) && (P514_ps_Event->Map_Time == L0591_ps_Event->Map_Time) && (P514_ps_Event->B.MapXY == L0591_ps_Event->B.MapXY)) {
                                        if (P514_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                                                P514_ps_Event->C.A.Effect = 1 - L0591_ps_Event->C.A.Effect;
                                        }
                                        F237_rzzz_TIMELINE_DeleteEvent(L0588_i_EventIndex);
                                        break;
                                }
                        }
                }
        } else {
                if (P514_ps_Event->A.A.Type == C01_EVENT_DOOR_ANIMATION) {
                        for(L0588_i_EventIndex = 0, L0591_ps_Event = G370_ps_Events; L0588_i_EventIndex < G369_ui_EventMaximumCount; L0588_i_EventIndex++, L0591_ps_Event++) {
                                if ((P514_ps_Event->Map_Time == L0591_ps_Event->Map_Time) && (P514_ps_Event->B.MapXY == L0591_ps_Event->B.MapXY)) {
                                        if (L0591_ps_Event->A.A.Type == C10_EVENT_DOOR) {
                                                if (L0591_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                                                        L0591_ps_Event->C.A.Effect = 1 - P514_ps_Event->C.A.Effect;
                                                }
                                                return L0588_i_EventIndex;
                                        }
                                        if (L0591_ps_Event->A.A.Type == C01_EVENT_DOOR_ANIMATION) {
                                                L0591_ps_Event->C.A.Effect = P514_ps_Event->C.A.Effect;
                                                return L0588_i_EventIndex;
                                        }
                                }
                        }
                } else {
                        if (P514_ps_Event->A.A.Type == C02_EVENT_DOOR_DESTRUCTION) {
                                for(L0588_i_EventIndex = 0, L0591_ps_Event = G370_ps_Events; L0588_i_EventIndex < G369_ui_EventMaximumCount; L0588_i_EventIndex++, L0591_ps_Event++) {
                                        if ((P514_ps_Event->B.MapXY == L0591_ps_Event->B.MapXY) && (M29_MAP(P514_ps_Event->Map_Time) == M29_MAP(L0591_ps_Event->Map_Time))) {
                                                if ((L0591_ps_Event->A.A.Type == C01_EVENT_DOOR_ANIMATION) || (L0591_ps_Event->A.A.Type == C10_EVENT_DOOR)) {
                                                        F237_rzzz_TIMELINE_DeleteEvent(L0588_i_EventIndex);
                                                }
                                        }
                                }
                        }
                }
        }
        G370_ps_Events[L0590_i_NewEventIndex = G373_ui_FirstUnusedEventIndex] = *P514_ps_Event; /* Copy the event data (Megamax C can assign structures) */
        do {
                if (G373_ui_FirstUnusedEventIndex == G369_ui_EventMaximumCount) {
                        break;
                }
                G373_ui_FirstUnusedEventIndex++;
        } while ((G370_ps_Events[G373_ui_FirstUnusedEventIndex]).A.A.Type != C00_EVENT_NONE);
        G371_pi_Timeline[G372_ui_EventCount] = L0590_i_NewEventIndex;
        F236_pzzz_TIMELINE_FixChronology(G372_ui_EventCount++);
        return L0590_i_NewEventIndex;
}

VOID F239_xxxx_TIMELINE_ExtractFirstEvent(P515_ps_Event)
EVENT* P515_ps_Event;
{
        register int L0592_i_EventIndex;


        *P515_ps_Event = G370_ps_Events[L0592_i_EventIndex = G371_pi_Timeline[0]];
        F237_rzzz_TIMELINE_DeleteEvent(L0592_i_EventIndex);
}

BOOLEAN F240_xxxx_TIMELINE_IsFirstEventExpired_COPYPROTECTIONE()
{
        return (G372_ui_EventCount && (M30_TIME(G370_ps_Events[G371_pi_Timeline[0]].Map_Time) <= G313_ul_GameTime))
#ifndef NOCOPYPROTECTION
        && (G330_i_StopExpiringEvents_COPYPROTECTIONE < 2)
#endif
        ;
}

VOID F241_xxxx_TIMELINE_ProcessEvent1_DoorAnimation(P516_ps_Event)
register EVENT* P516_ps_Event;
{
        register unsigned int L0593_ui_MapX;
        register unsigned int L0594_ui_MapY;
        register int L0595_i_Effect;
        register int L0596_i_DoorState;
        register unsigned char* L0597_puc_Square;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        DOOR* L0598_ps_Door;
#endif
        THING L0599_T_GroupThing;
        unsigned int L0600_ui_CreatureAttributes;
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_06_FIX Useless code removed */
        char L0601_ac_Unreferenced[8]; /* BUG0_00 Useless code */
#endif
        unsigned int L0602_ui_Multiple;
#define A0602_ui_VerticalDoor L0602_ui_Multiple
#define A0602_ui_Height       L0602_ui_Multiple


        L0597_puc_Square = &G271_ppuc_CurrentMapData[L0593_ui_MapX = P516_ps_Event->B.Location.MapX][L0594_ui_MapY = P516_ps_Event->B.Location.MapY];
        if ((L0596_i_DoorState = M36_DOOR_STATE(*L0597_puc_Square)) == C5_DOOR_STATE_DESTROYED) {
                return;
        }
        P516_ps_Event->Map_Time++;
        L0595_i_Effect = P516_ps_Event->C.A.Effect;
        if (L0595_i_Effect == C01_EFFECT_CLEAR) {
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0598_ps_Door = (DOOR*)F157_rzzz_DUNGEON_GetSquareFirstThingData(L0593_ui_MapX, L0594_ui_MapY);
                A0602_ui_VerticalDoor = L0598_ps_Door->Vertical;
#endif
                if ((G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (L0593_ui_MapX == G306_i_PartyMapX) && (L0594_ui_MapY == G307_i_PartyMapY) && (L0596_i_DoorState != C0_DOOR_STATE_OPEN)) {
                        if (G305_ui_PartyChampionCount > 0) {
                                M37_SET_DOOR_STATE(*L0597_puc_Square, C0_DOOR_STATE_OPEN);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                if (F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount(5, MASK0x0008_TORSO | ((((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(L0593_ui_MapX, L0594_ui_MapY))].Vertical) ? MASK0x0004_HEAD : MASK0x0001_READY_HAND | MASK0x0002_ACTION_HAND), C2_ATTACK_SELF)) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                if (F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount(5, MASK0x0008_TORSO | A0602_ui_VerticalDoor ? MASK0x0004_HEAD : MASK0x0001_READY_HAND | MASK0x0002_ACTION_HAND, C2_ATTACK_SELF)) {
#endif
                                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C18_SOUND_PARTY_DAMAGED, L0593_ui_MapX, L0594_ui_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                }
                        }
                        P516_ps_Event->Map_Time++;
                        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P516_ps_Event);
                        return;
                }
                if (((L0599_T_GroupThing = F175_gzzz_GROUP_GetThing(L0593_ui_MapX, L0594_ui_MapY)) != C0xFFFE_THING_ENDOFLIST) && !M07_GET(L0600_ui_CreatureAttributes = F144_amzz_DUNGEON_GetCreatureAttributes(L0599_T_GroupThing), MASK0x0040_NON_MATERIAL)) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        A0602_ui_Height = (((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[M13_INDEX(F161_szzz_DUNGEON_GetSquareFirstThing(L0593_ui_MapX, L0594_ui_MapY))].Vertical) ? M51_HEIGHT(L0600_ui_CreatureAttributes) : 1;
                        if (L0596_i_DoorState >= A0602_ui_Height) { /* Creature height or 1 */
                                if (F191_aayz_GROUP_GetDamageAllCreaturesOutcome(&((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L0599_T_GroupThing)], L0593_ui_MapX, L0594_ui_MapY, 5, TRUE) != C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        if (L0596_i_DoorState >= (A0602_ui_Height ? M51_HEIGHT(L0600_ui_CreatureAttributes) : 1)) { /* Creature height or 1 */
                                if (F191_aayz_GROUP_GetDamageAllCreaturesOutcome((GROUP*)F156_afzz_DUNGEON_GetThingData(L0599_T_GroupThing), L0593_ui_MapX, L0594_ui_MapY, 5, TRUE) != C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP) {
#endif
                                        F209_xzzz_GROUP_ProcessEvents29to41(L0593_ui_MapX, L0594_ui_MapY, CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE, 0);
                                }
                                L0596_i_DoorState = (L0596_i_DoorState == C0_DOOR_STATE_OPEN) ? C0_DOOR_STATE_OPEN : (L0596_i_DoorState - 1);
                                M37_SET_DOOR_STATE(*L0597_puc_Square, L0596_i_DoorState);
                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C04_SOUND_WOODEN_THUD, L0593_ui_MapX, L0594_ui_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                P516_ps_Event->Map_Time++;
                                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P516_ps_Event);
                                return;
                        }
                }
        }
        if (((L0595_i_Effect == C00_EFFECT_SET) && (L0596_i_DoorState == C0_DOOR_STATE_OPEN)) || ((L0595_i_Effect == C01_EFFECT_CLEAR) && (L0596_i_DoorState == C4_DOOR_STATE_CLOSED))) {
                return;
        }
        L0596_i_DoorState += (L0595_i_Effect == C00_EFFECT_SET) ? -1 : 1;
        M37_SET_DOOR_STATE(*L0597_puc_Square, L0596_i_DoorState);
        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C02_SOUND_DOOR_RATTLE, L0593_ui_MapX, L0594_ui_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
        if (L0595_i_Effect == C00_EFFECT_SET) {
                if (L0596_i_DoorState == C0_DOOR_STATE_OPEN) {
                        return;
                }
        } else {
                if (L0596_i_DoorState == C4_DOOR_STATE_CLOSED) {
                        return;
                }
        }
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P516_ps_Event);
}

VOID F242_xxxx_TIMELINE_ProcessEvent7_Square_FakeWall(P517_ps_Event)
register EVENT* P517_ps_Event;
{
        register unsigned int L0603_ui_MapX;
        register unsigned int L0604_ui_MapY;
        register int L0605_i_Effect;
        register THING L0606_T_Thing;
        register unsigned char* L0607_puc_Square;


        L0607_puc_Square = &G271_ppuc_CurrentMapData[L0603_ui_MapX = P517_ps_Event->B.Location.MapX][L0604_ui_MapY = P517_ps_Event->B.Location.MapY];
        L0605_i_Effect = P517_ps_Event->C.A.Effect;
        if (L0605_i_Effect == C02_EFFECT_TOGGLE) {
                L0605_i_Effect = M07_GET(*L0607_puc_Square, MASK0x0004_FAKEWALL_OPEN) ? C01_EFFECT_CLEAR : C00_EFFECT_SET;
        }
        if (L0605_i_Effect == C01_EFFECT_CLEAR) {
                if ((G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (L0603_ui_MapX == G306_i_PartyMapX) && (L0604_ui_MapY == G307_i_PartyMapY)) {
                        P517_ps_Event->Map_Time++;
                        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P517_ps_Event);
                } else {
                        if (((L0606_T_Thing = F175_gzzz_GROUP_GetThing(L0603_ui_MapX, L0604_ui_MapY)) != C0xFFFE_THING_ENDOFLIST) && !M07_GET(F144_amzz_DUNGEON_GetCreatureAttributes(L0606_T_Thing), MASK0x0040_NON_MATERIAL)) {
                                P517_ps_Event->Map_Time++;
                                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P517_ps_Event);
                        } else {
                                M09_CLEAR(*L0607_puc_Square, MASK0x0004_FAKEWALL_OPEN);
                        }
                }
        } else {
                M08_SET(*L0607_puc_Square, MASK0x0004_FAKEWALL_OPEN);
        }
}

VOID F243_xxxx_TIMELINE_ProcessEvent2_DoorDestruction(P518_ps_Event)
register EVENT* P518_ps_Event;
{
        register unsigned char* L0608_puc_Square;


        L0608_puc_Square = &G271_ppuc_CurrentMapData[P518_ps_Event->B.Location.MapX][P518_ps_Event->B.Location.MapY];
        M37_SET_DOOR_STATE(*L0608_puc_Square, C5_DOOR_STATE_DESTROYED);
}

VOID F244_xxxx_TIMELINE_ProcessEvent10_Square_Door(P519_ps_Event)
register EVENT* P519_ps_Event;
{
        register int L0609_i_DoorState;


        if ((L0609_i_DoorState = M36_DOOR_STATE(G271_ppuc_CurrentMapData[P519_ps_Event->B.Location.MapX][P519_ps_Event->B.Location.MapY])) == C5_DOOR_STATE_DESTROYED) {
                return;
        }
        if (P519_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                P519_ps_Event->C.A.Effect = (L0609_i_DoorState == C0_DOOR_STATE_OPEN) ? C01_EFFECT_CLEAR : C00_EFFECT_SET;
        } else {
                if (P519_ps_Event->C.A.Effect == C00_EFFECT_SET) {
                        if (L0609_i_DoorState == C0_DOOR_STATE_OPEN) {
                                return;
                        }
                } else {
                        if (L0609_i_DoorState == C4_DOOR_STATE_CLOSED) {
                                return;
                        }
                }
        }
        P519_ps_Event->A.A.Type = C01_EVENT_DOOR_ANIMATION;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P519_ps_Event);
}

VOID F245_xxxx_TIMELINE_ProcessEvent5_Square_Corridor(P520_ps_Event)
register EVENT* P520_ps_Event;
{
        register int L0610_i_ThingType;
        register BOOLEAN L0611_B_TextCurrentlyVisible;
        register int L0612_i_CreatureCount;
        register THING L0613_T_Thing;
        register SENSOR* L0614_ps_Sensor;
        TEXT* L0615_ps_Text;
        unsigned int L0616_ui_MapX;
        unsigned int L0617_ui_MapY;
        unsigned int L0618_ui_Multiple;
#define A0618_ui_HealthMultiplier L0618_ui_Multiple
#define A0618_ui_Ticks            L0618_ui_Multiple
        EVENT L0619_s_Event;


        for(L0613_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(L0616_ui_MapX = P520_ps_Event->B.Location.MapX, L0617_ui_MapY = P520_ps_Event->B.Location.MapY); L0613_T_Thing != C0xFFFE_THING_ENDOFLIST; L0613_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0613_T_Thing)) {
                if ((L0610_i_ThingType = M12_TYPE(L0613_T_Thing)) == C02_THING_TYPE_TEXT) {
                        L0615_ps_Text = (TEXT*)F156_afzz_DUNGEON_GetThingData(L0613_T_Thing);
                        L0611_B_TextCurrentlyVisible = L0615_ps_Text->Visible;
                        if (P520_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                                L0615_ps_Text->Visible = !L0611_B_TextCurrentlyVisible;
                        } else {
                                L0615_ps_Text->Visible = (P520_ps_Event->C.A.Effect == C00_EFFECT_SET);
                        }
                        if (!L0611_B_TextCurrentlyVisible && L0615_ps_Text->Visible && (G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (L0616_ui_MapX == G306_i_PartyMapX) && (L0617_ui_MapY == G307_i_PartyMapY)) {
                                F168_ajzz_DUNGEON_DecodeText(G353_ac_StringBuildBuffer, L0613_T_Thing, C1_TEXT_TYPE_MESSAGE);
                                F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C15_COLOR_WHITE, G353_ac_StringBuildBuffer);
                        }
                } else {
                        if (L0610_i_ThingType == C03_THING_TYPE_SENSOR) {
                                L0614_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0613_T_Thing);
                                if (M39_TYPE(L0614_ps_Sensor) == C006_SENSOR_FLOOR_GROUP_GENERATOR) {
                                        L0612_i_CreatureCount = L0614_ps_Sensor->A.Value;
                                        if (M07_GET(L0612_i_CreatureCount, MASK0x0008_RANDOMIZE_GENERATED_CREATURE_COUNT)) {
                                                L0612_i_CreatureCount = M02_RANDOM(M07_GET(L0612_i_CreatureCount, MASK0x0007_GENERATED_CREATURE_COUNT));
                                        } else {
                                                L0612_i_CreatureCount--;
                                        }
                                        if ((A0618_ui_HealthMultiplier = M45_HEALTH_MULTIPLIER(L0614_ps_Sensor)) == 0) {
                                                A0618_ui_HealthMultiplier = G269_ps_CurrentMap->C.Difficulty;
                                        }
                                        F185_auzz_GROUP_GetGenerated(M40_DATA(L0614_ps_Sensor), A0618_ui_HealthMultiplier, L0612_i_CreatureCount, M04_RANDOM(4), L0616_ui_MapX, L0617_ui_MapY);
                                        if (L0614_ps_Sensor->A.Audible) {
                                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, L0616_ui_MapX, L0617_ui_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                        }
                                        if (L0614_ps_Sensor->A.OnceOnly) {
                                                M44_SET_TYPE_DISABLED(L0614_ps_Sensor);
                                        } else {
                                                if ((A0618_ui_Ticks = M46_TICKS(L0614_ps_Sensor)) != 0) {
                                                        M44_SET_TYPE_DISABLED(L0614_ps_Sensor);
                                                        if (A0618_ui_Ticks > 127) {
                                                                A0618_ui_Ticks = (A0618_ui_Ticks - 126) << 6;
                                                        }
                                                        L0619_s_Event.A.A.Type = C65_EVENT_ENABLE_GROUP_GENERATOR;
                                                        M33_SET_MAP_AND_TIME(L0619_s_Event.Map_Time, G272_i_CurrentMapIndex, G313_ul_GameTime + A0618_ui_Ticks);
                                                        L0619_s_Event.A.A.Priority = 0;
                                                        L0619_s_Event.B.Location.MapX = L0616_ui_MapX;
                                                        L0619_s_Event.B.Location.MapY = L0617_ui_MapY;
                                                        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0619_s_Event);
                                                }
                                        }
                                }
                        }
                }
        }
}

/* This function enables the first disabled sensor on the square by changing its type to C006_SENSOR_FLOOR_GROUP_GENERATOR */
VOID F246_xxxx_TIMELINE_ProcessEvent65_EnableGroupGenerator(P521_ps_Event)
register EVENT* P521_ps_Event;
{
        register THING L0620_T_Thing;
        register SENSOR* L0621_ps_Sensor;


        for(L0620_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P521_ps_Event->B.Location.MapX, P521_ps_Event->B.Location.MapY); L0620_T_Thing != C0xFFFF_THING_NONE; L0620_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0620_T_Thing)) {
                if (M12_TYPE(L0620_T_Thing) == C03_THING_TYPE_SENSOR) {
                        L0621_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0620_T_Thing);
                        if (M39_TYPE(L0621_ps_Sensor) == C000_SENSOR_DISABLED) {
                                L0621_ps_Sensor->Type_Data |= C006_SENSOR_FLOOR_GROUP_GENERATOR;
                                return;
                        }
                }
        }
}

VOID F247_xxxx_TIMELINE_TriggerProjectileLauncher(P522_ps_Sensor, P523_ps_Event)
register SENSOR* P522_ps_Sensor;
register EVENT* P523_ps_Event;
{
        register THING L0622_T_FirstProjectileAssociatedThing;
        register THING L0623_T_SecondProjectileAssociatedThing;
        register unsigned int L0624_ui_Cell;
        register int L0625_i_SensorType;
        int L0626_i_MapX;
        int L0627_i_MapY;
        unsigned int L0628_ui_ProjectileCell;
        int L0629_i_SensorData;
        int L0630_i_KineticEnergy;
        int L0631_i_StepEnergy;
        BOOLEAN L0632_B_LaunchSingleProjectile;
        unsigned int L0633_ui_ThingCell;


        L0626_i_MapX = P523_ps_Event->B.Location.MapX;
        L0627_i_MapY = P523_ps_Event->B.Location.MapY;
        L0624_ui_Cell = P523_ps_Event->C.A.Cell;
        L0628_ui_ProjectileCell = M18_OPPOSITE(L0624_ui_Cell);
        L0625_i_SensorType = M39_TYPE(P522_ps_Sensor);
        L0629_i_SensorData = M40_DATA(P522_ps_Sensor);
        L0630_i_KineticEnergy = M47_KINETIC_ENERGY(P522_ps_Sensor);
        L0631_i_StepEnergy = M48_STEP_ENERGY(P522_ps_Sensor);
        L0632_B_LaunchSingleProjectile = (L0625_i_SensorType == C007_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_NEW_OBJECT) ||
                                      (L0625_i_SensorType == C008_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_EXPLOSION) ||
                                      (L0625_i_SensorType == C014_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT);
        if ((L0625_i_SensorType == C008_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_EXPLOSION) || (L0625_i_SensorType == C010_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_EXPLOSION)) {
                L0622_T_FirstProjectileAssociatedThing = L0623_T_SecondProjectileAssociatedThing = L0629_i_SensorData + C0xFF80_THING_FIRST_EXPLOSION;
        } else {
                if ((L0625_i_SensorType == C014_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT) || (L0625_i_SensorType == C015_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT)) {
                        for(L0622_T_FirstProjectileAssociatedThing = F161_szzz_DUNGEON_GetSquareFirstThing(L0626_i_MapX, L0627_i_MapY); L0622_T_FirstProjectileAssociatedThing != C0xFFFF_THING_NONE; L0622_T_FirstProjectileAssociatedThing = F159_rzzz_DUNGEON_GetNextThing(L0622_T_FirstProjectileAssociatedThing)) { /* BUG0_19 The game crashes when an object launcher sensor is triggered. C0xFFFF_THING_NONE should be C0xFFFE_THING_ENDOFLIST. If there are no more objects on the square then this loop may return an undefined value, this can crash the game. In the original DM and CSB dungeons, the number of times that these sensors are triggered is always controlled to be equal to the number of available objects (with a countdown sensor or a number of once only sensors) */
                                L0633_ui_ThingCell = M11_CELL(L0622_T_FirstProjectileAssociatedThing);
                                if ((M12_TYPE(L0622_T_FirstProjectileAssociatedThing) > C03_THING_TYPE_SENSOR) && ((L0633_ui_ThingCell == L0624_ui_Cell) || (L0633_ui_ThingCell == M17_NEXT(L0624_ui_Cell)))) {
                                        break;
                                }
                        }
                        if (L0622_T_FirstProjectileAssociatedThing == C0xFFFF_THING_NONE) { /* BUG0_19 The game crashes when an object launcher sensor is triggered. C0xFFFF_THING_NONE should be C0xFFFE_THING_ENDOFLIST */
                                return;
                        }
                        F164_dzzz_DUNGEON_UnlinkThingFromList(L0622_T_FirstProjectileAssociatedThing, 0, L0626_i_MapX, L0627_i_MapY); /* The object is removed without triggering any sensor effects */
                        if (!L0632_B_LaunchSingleProjectile) {
                                for(L0623_T_SecondProjectileAssociatedThing = F161_szzz_DUNGEON_GetSquareFirstThing(L0626_i_MapX, L0627_i_MapY); L0623_T_SecondProjectileAssociatedThing != C0xFFFF_THING_NONE; L0623_T_SecondProjectileAssociatedThing = F159_rzzz_DUNGEON_GetNextThing(L0623_T_SecondProjectileAssociatedThing)) { /* BUG0_19 The game crashes when an object launcher sensor is triggered. C0xFFFF_THING_NONE should be C0xFFFE_THING_ENDOFLIST. If there are no more objects on the square then this loop may return an undefined value, this can crash the game */
                                        L0633_ui_ThingCell = M11_CELL(L0623_T_SecondProjectileAssociatedThing);
                                        if ((M12_TYPE(L0623_T_SecondProjectileAssociatedThing) > C03_THING_TYPE_SENSOR) && ((L0633_ui_ThingCell == L0624_ui_Cell) || (L0633_ui_ThingCell == M17_NEXT(L0624_ui_Cell)))) {
                                                break;
                                        }
                                }
                                if (L0623_T_SecondProjectileAssociatedThing == C0xFFFF_THING_NONE) { /* BUG0_19 The game crashes when an object launcher sensor is triggered. C0xFFFF_THING_NONE should be C0xFFFE_THING_ENDOFLIST */
                                        L0632_B_LaunchSingleProjectile = TRUE;
                                } else {
                                        F164_dzzz_DUNGEON_UnlinkThingFromList(L0623_T_SecondProjectileAssociatedThing, 0, L0626_i_MapX, L0627_i_MapY); /* The object is removed without triggering any sensor effects */
                                }
                        }
                } else {
                        if ((L0622_T_FirstProjectileAssociatedThing = F167_aozz_DUNGEON_GetObjectForProjectileLauncherOrObjectGenerator(L0629_i_SensorData)) == C0xFFFF_THING_NONE) {
                                return;
                        }
                        if (!L0632_B_LaunchSingleProjectile && ((L0623_T_SecondProjectileAssociatedThing = F167_aozz_DUNGEON_GetObjectForProjectileLauncherOrObjectGenerator(L0629_i_SensorData)) == C0xFFFF_THING_NONE)) {
                                L0632_B_LaunchSingleProjectile = TRUE;
                        }
                }
        }
        if (L0632_B_LaunchSingleProjectile) {
                L0628_ui_ProjectileCell = M21_NORMALIZE(L0628_ui_ProjectileCell + M05_RANDOM(2));
        }
        L0626_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[L0624_ui_Cell], L0627_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[L0624_ui_Cell]; /* BUG0_20 The game crashes if the launcher sensor is on a map boundary and shoots in a direction outside the map */
        G365_B_CreateLauncherProjectile = TRUE;
#ifdef C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN /* CHANGE8_01_FIX */
        F212_mzzz_PROJECTILE_Create(L0622_T_FirstProjectileAssociatedThing, L0626_i_MapX, L0627_i_MapY, L0628_ui_ProjectileCell, L0624_ui_Cell, L0630_i_KineticEnergy, 100, 0); /* BUG0_21 Projectiles created by launcher sensors never run out of kinetic energy and move until they impact something. Projectile launcher sensors have a step energy value defining how much kinetic energy is consumed with each step of movement of the projectiles they create. This value is ignored and 0 is always used so that such projectiles always move until they impact something (wall, creature or party) */
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_01_FIX Projectiles created by launcher sensors use the step energy value stored in the sensor instead of 0 */
        F212_mzzz_PROJECTILE_Create(L0622_T_FirstProjectileAssociatedThing, L0626_i_MapX, L0627_i_MapY, L0628_ui_ProjectileCell, L0624_ui_Cell, L0630_i_KineticEnergy, 100, L0631_i_StepEnergy);
#endif
        if (!L0632_B_LaunchSingleProjectile) {
#ifdef C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN /* CHANGE8_01_FIX */
                F212_mzzz_PROJECTILE_Create(L0623_T_SecondProjectileAssociatedThing, L0626_i_MapX, L0627_i_MapY, M17_NEXT(L0628_ui_ProjectileCell), L0624_ui_Cell, L0630_i_KineticEnergy, 100, 0); /* BUG0_21 */
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_01_FIX Projectiles created by launcher sensors use the step energy value stored in the sensor instead of 0 */
                F212_mzzz_PROJECTILE_Create(L0623_T_SecondProjectileAssociatedThing, L0626_i_MapX, L0627_i_MapY, M17_NEXT(L0628_ui_ProjectileCell), L0624_ui_Cell, L0630_i_KineticEnergy, 100, L0631_i_StepEnergy);
#endif
        }
        G365_B_CreateLauncherProjectile = FALSE;
}

VOID F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall(P524_ps_Event)
register EVENT* P524_ps_Event;
{
        register THING L0634_T_Thing;
        register int L0635_i_ThingType;
        register int L0636_i_Multiple;
#define A0636_B_TriggerSetEffect L0636_i_Multiple
#define A0636_i_BitMask          L0636_i_Multiple
        register unsigned int L0637_ui_SensorData;
        register SENSOR* L0638_ps_Sensor;
        TEXT* L0639_ps_Text;
        unsigned int L0640_ui_SensorType;
        int L0641_i_MapX;
        int L0642_i_MapY;
        unsigned int L0643_ui_Cell;


        L0634_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(L0641_i_MapX = P524_ps_Event->B.Location.MapX, L0642_i_MapY = P524_ps_Event->B.Location.MapY);
        L0643_ui_Cell = P524_ps_Event->C.A.Cell;
        while (L0634_T_Thing != C0xFFFE_THING_ENDOFLIST) {
                if (((L0635_i_ThingType = M12_TYPE(L0634_T_Thing)) == C02_THING_TYPE_TEXT) && (M11_CELL(L0634_T_Thing) == P524_ps_Event->C.A.Cell)) {
                        L0639_ps_Text = (TEXT*)F156_afzz_DUNGEON_GetThingData(L0634_T_Thing);
                        if (P524_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                                L0639_ps_Text->Visible = !L0639_ps_Text->Visible;
                        } else {
                                L0639_ps_Text->Visible = (P524_ps_Event->C.A.Effect == C00_EFFECT_SET);
                        }
                } else {
                        if (L0635_i_ThingType == C03_THING_TYPE_SENSOR) {
                                L0638_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0634_T_Thing);
                                L0640_ui_SensorType = M39_TYPE(L0638_ps_Sensor);
                                L0637_ui_SensorData = M40_DATA(L0638_ps_Sensor);
                                if (L0640_ui_SensorType == C006_SENSOR_WALL_COUNTDOWN) {
                                        if (L0637_ui_SensorData > 0) {
                                                if (P524_ps_Event->C.A.Effect == C00_EFFECT_SET) {
                                                        if (L0637_ui_SensorData < 511) {
                                                                L0637_ui_SensorData++;
                                                        }
                                                } else {
                                                        L0637_ui_SensorData--;
                                                }
                                                M41_SET_DATA(L0638_ps_Sensor, L0637_ui_SensorData);
                                                if (L0638_ps_Sensor->A.Effect == C03_EFFECT_HOLD) {
                                                        A0636_B_TriggerSetEffect = ((L0637_ui_SensorData == 0) != L0638_ps_Sensor->A.RevertEffect);
                                                        F272_xxxx_SENSOR_TriggerEffect(L0638_ps_Sensor, A0636_B_TriggerSetEffect ? C00_EFFECT_SET : C01_EFFECT_CLEAR, L0641_i_MapX, L0642_i_MapY, L0643_ui_Cell);
                                                } else {
                                                        if (L0637_ui_SensorData == 0) {
                                                                F272_xxxx_SENSOR_TriggerEffect(L0638_ps_Sensor, L0638_ps_Sensor->A.Effect, L0641_i_MapX, L0642_i_MapY, L0643_ui_Cell);
                                                        }
                                                }
                                        }
                                } else {
                                        if (L0640_ui_SensorType == C005_SENSOR_WALL_AND_OR_GATE) {
                                                A0636_i_BitMask = 1 << (P524_ps_Event->C.A.Cell);
                                                if (P524_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                                                        if (M07_GET(L0637_ui_SensorData, A0636_i_BitMask)) {
                                                                M09_CLEAR(L0637_ui_SensorData, A0636_i_BitMask);
                                                        } else {
                                                                M08_SET(L0637_ui_SensorData, A0636_i_BitMask);
                                                        }
                                                } else {
                                                        if (P524_ps_Event->C.A.Effect) {
                                                                M09_CLEAR(L0637_ui_SensorData, A0636_i_BitMask);
                                                        } else {
                                                                M08_SET(L0637_ui_SensorData, A0636_i_BitMask);
                                                        }
                                                }
                                                M41_SET_DATA(L0638_ps_Sensor, L0637_ui_SensorData);
                                                A0636_B_TriggerSetEffect = (M42_MASK1(L0637_ui_SensorData) == M43_MASK2(L0637_ui_SensorData)) != L0638_ps_Sensor->A.RevertEffect;
                                                if (L0638_ps_Sensor->A.Effect == C03_EFFECT_HOLD) {
                                                        F272_xxxx_SENSOR_TriggerEffect(L0638_ps_Sensor, A0636_B_TriggerSetEffect ? C00_EFFECT_SET : C01_EFFECT_CLEAR, L0641_i_MapX, L0642_i_MapY, L0643_ui_Cell);
                                                } else {
                                                        if (A0636_B_TriggerSetEffect) {
                                                                F272_xxxx_SENSOR_TriggerEffect(L0638_ps_Sensor, L0638_ps_Sensor->A.Effect, L0641_i_MapX, L0642_i_MapY, L0643_ui_Cell);
                                                        }
                                                }
                                        } else {
                                                if ((((L0640_ui_SensorType >= C007_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_NEW_OBJECT) && (L0640_ui_SensorType <= C010_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_EXPLOSION)) || (L0640_ui_SensorType == C014_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT) || (L0640_ui_SensorType == C015_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT)) && (M11_CELL(L0634_T_Thing) == P524_ps_Event->C.A.Cell)) {
                                                        F247_xxxx_TIMELINE_TriggerProjectileLauncher(L0638_ps_Sensor, P524_ps_Event);
                                                        if (L0638_ps_Sensor->A.OnceOnly) {
                                                                M44_SET_TYPE_DISABLED(L0638_ps_Sensor);
                                                        }
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_21_IMPROVEMENT New floor sensor type: end game. The game ends immediately when this sensor is triggered */
                                                } else {
                                                        if (L0640_ui_SensorType == C018_SENSOR_WALL_END_GAME) {
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_02_IMPROVEMENT The end game sensor now includes an optional delay before drawing the end of the game (not used in the original dungeon) */
                                                                F022_aaaU_MAIN_Delay(60 * L0638_ps_Sensor->A.Value);
#endif
                                                                G524_B_RestartGameAllowed = FALSE;
                                                                G302_B_GameWon = TRUE;
                                                                F444_AA29_STARTEND_Endgame(TRUE);
                                                        }
#endif
                                                }
                                        }
                                }
                        }
                }
                L0634_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0634_T_Thing);
        }
        F271_xxxx_SENSOR_ProcessRotationEffect();
}

/* This function moves all things on the specified square to the same location in order to apply the square effects when a teleporter or pit is open */
VOID F249_xxxx_TIMELINE_MoveTeleporterOrPitSquareThings(P525_ui_MapX, P526_ui_MapY)
register unsigned int P525_ui_MapX;
register unsigned int P526_ui_MapY;
{
        register unsigned int L0644_ui_Multiple;
#define A0644_ui_ThingType  L0644_ui_Multiple
#define A0644_ui_EventIndex L0644_ui_Multiple
        register THING L0645_T_Thing;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        register PROJECTILE* L0646_ps_Projectile;
#endif
        register EVENT* L0647_ps_Event;
        THING L0648_T_NextThing;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_22_FIX */
        int L0649_i_ThingsToMoveCount;
#endif


        if ((G272_i_CurrentMapIndex == G309_i_PartyMapIndex) && (P525_ui_MapX == G306_i_PartyMapX) && (P526_ui_MapY == G307_i_PartyMapY)) {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, P525_ui_MapX, P526_ui_MapY, P525_ui_MapX, P526_ui_MapY);
                F296_aizz_CHAMPION_DrawChangedObjectIcons();
        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_22_FIX */
        L0645_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(P525_ui_MapX, P526_ui_MapY);
        while (L0645_T_Thing != C0xFFFE_THING_ENDOFLIST) { /* BUG0_22 When a teleporter or pit opens, the game hangs or some things are not moved correctly. The program enters an infinite loop if there are at least two things on a closed teleporter or closed pit square and these things end up on the same square when the teleporter or pit opens. This occurs in these cases:
- On a teleporter square targetting itself if there are at least two things on the square when the teleporter is opened.
- On a pit square if there are at least two things levitating over the pit (two projectiles or one group and one projectile) when the pit is opened

Some things are not moved correctly if the list of things on the square contains a group followed by a projectile that impacts the group and then other things. When the group is processed, the projectile is removed from the list of things on the square. The loop then proceeds with the projectile that is now out of the linked list of things on the square, which breaks the loop */
                L0648_T_NextThing = F159_rzzz_DUNGEON_GetNextThing(L0645_T_Thing);
                A0644_ui_ThingType = M12_TYPE(L0645_T_Thing);
                if (A0644_ui_ThingType >= C04_THING_TYPE_GROUP) {
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_22_FIX Process the group before all the other things on the square in order to process potential projectile impacts that would remove things from the square (projectiles or the group itself if killed). Count the remaining things on the square to make sure each one is processed only once and thus avoid infinite loops */
        if ((L0645_T_Thing = F175_gzzz_GROUP_GetThing(P525_ui_MapX, P526_ui_MapY)) != C0xFFFE_THING_ENDOFLIST) {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0645_T_Thing, P525_ui_MapX, P526_ui_MapY, P525_ui_MapX, P526_ui_MapY);
        }
        L0645_T_Thing = F162_afzz_DUNGEON_GetSquareFirstObject(P525_ui_MapX, P526_ui_MapY);
        L0648_T_NextThing = L0645_T_Thing;
        L0649_i_ThingsToMoveCount = 0;
        while (L0645_T_Thing != C0xFFFE_THING_ENDOFLIST) {
                if (M12_TYPE(L0645_T_Thing) > C04_THING_TYPE_GROUP) {
                        L0649_i_ThingsToMoveCount++;
                }
                L0645_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0645_T_Thing);
        }
        L0645_T_Thing = L0648_T_NextThing;
        while ((L0645_T_Thing != C0xFFFE_THING_ENDOFLIST) && L0649_i_ThingsToMoveCount) {
                L0649_i_ThingsToMoveCount--;
                L0648_T_NextThing = F159_rzzz_DUNGEON_GetNextThing(L0645_T_Thing);
                A0644_ui_ThingType = M12_TYPE(L0645_T_Thing);
                if (A0644_ui_ThingType > C04_THING_TYPE_GROUP) {
#endif
                        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L0645_T_Thing, P525_ui_MapX, P526_ui_MapY, P525_ui_MapX, P526_ui_MapY);
                }
                if (A0644_ui_ThingType == C14_THING_TYPE_PROJECTILE) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0647_ps_Event = &G370_ps_Events[((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(L0645_T_Thing)].EventIndex];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0646_ps_Projectile = (PROJECTILE*)F156_afzz_DUNGEON_GetThingData(L0645_T_Thing);
                        L0647_ps_Event = &G370_ps_Events[L0646_ps_Projectile->EventIndex];
#endif
                        L0647_ps_Event->C.Projectile.MapX = G397_i_MoveResultMapX;
                        L0647_ps_Event->C.Projectile.MapY = G398_i_MoveResultMapY;
                        L0647_ps_Event->C.Projectile.Direction = G400_i_MoveResultDirection;
                        L0647_ps_Event->B.Slot = M15_THING_WITH_NEW_CELL(L0645_T_Thing, G401_ui_MoveResultCell);
                        M31_SET_MAP(L0647_ps_Event->Map_Time, G399_ui_MoveResultMapIndex);
                } else {
                        if (A0644_ui_ThingType == C15_THING_TYPE_EXPLOSION) {
                                for(A0644_ui_EventIndex = 0, L0647_ps_Event = G370_ps_Events; A0644_ui_EventIndex < G369_ui_EventMaximumCount; L0647_ps_Event++, A0644_ui_EventIndex++) {
                                        if ((L0647_ps_Event->A.A.Type == C25_EVENT_EXPLOSION) && (L0647_ps_Event->C.Slot == L0645_T_Thing)) { /* BUG0_23 A Fluxcage explosion remains on a square forever. If you open a pit or teleporter on a square where there is a Fluxcage explosion, the Fluxcage explosion is moved but the associated event is not updated (because Fluxcage explosions do not use C25_EVENT_EXPLOSION but rather C24_EVENT_REMOVE_FLUXCAGE) causing the Fluxcage explosion to remain in the dungeon forever on its destination square. When the C24_EVENT_REMOVE_FLUXCAGE expires the explosion thing is not removed, but it is marked as unused. Consequently, any objects placed on the Fluxcage square after it was moved but before it expires become orphans upon expiration. After expiration, any object placed on the fluxcage square is cloned when picked up */
                                                L0647_ps_Event->B.Location.MapX = G397_i_MoveResultMapX;
                                                L0647_ps_Event->B.Location.MapY = G398_i_MoveResultMapY;
                                                L0647_ps_Event->C.Slot = M15_THING_WITH_NEW_CELL(L0645_T_Thing, G401_ui_MoveResultCell);
                                                M31_SET_MAP(L0647_ps_Event->Map_Time, G399_ui_MoveResultMapIndex);
                                        }
                                }
                        }
                }
                L0645_T_Thing = L0648_T_NextThing;
        }
}

VOID F250_xxxx_TIMELINE_ProcessEvent8_Square_Teleporter(P527_ps_Event)
register EVENT* P527_ps_Event;
{
        register int L0650_i_MapX;
        register int L0651_i_MapY;
        register unsigned char* L0652_puc_Square;


        L0652_puc_Square = &G271_ppuc_CurrentMapData[L0650_i_MapX = P527_ps_Event->B.Location.MapX][L0651_i_MapY = P527_ps_Event->B.Location.MapY];
        if (P527_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                P527_ps_Event->C.A.Effect = M07_GET(*L0652_puc_Square, MASK0x0008_TELEPORTER_OPEN) ? C01_EFFECT_CLEAR : C00_EFFECT_SET;
        }
        if (P527_ps_Event->C.A.Effect == C00_EFFECT_SET) {
                M08_SET(*L0652_puc_Square, MASK0x0008_TELEPORTER_OPEN);
                F249_xxxx_TIMELINE_MoveTeleporterOrPitSquareThings(L0650_i_MapX, L0651_i_MapY);
        } else {
                M09_CLEAR(*L0652_puc_Square, MASK0x0008_TELEPORTER_OPEN);
        }
}

VOID F251_xxxx_TIMELINE_ProcessEvent9_Square_Pit(P528_ps_Event)
register EVENT* P528_ps_Event;
{
        register int L0653_i_MapX;
        register int L0654_i_MapY;
        register unsigned char* L0655_puc_Square;


        L0655_puc_Square = &G271_ppuc_CurrentMapData[L0653_i_MapX = P528_ps_Event->B.Location.MapX][L0654_i_MapY = P528_ps_Event->B.Location.MapY];
        if (P528_ps_Event->C.A.Effect == C02_EFFECT_TOGGLE) {
                P528_ps_Event->C.A.Effect = M07_GET(*L0655_puc_Square, MASK0x0008_PIT_OPEN) ? C01_EFFECT_CLEAR : C00_EFFECT_SET;
        }
        if (P528_ps_Event->C.A.Effect == C00_EFFECT_SET) {
                M08_SET(*L0655_puc_Square, MASK0x0008_PIT_OPEN);
                F249_xxxx_TIMELINE_MoveTeleporterOrPitSquareThings(L0653_i_MapX, L0654_i_MapY);
        } else {
                M09_CLEAR(*L0655_puc_Square, MASK0x0008_PIT_OPEN);
        }
}

VOID F252_xxxx_TIMELINE_ProcessEvents60to61_MoveGroup(P529_ps_Event)
register EVENT* P529_ps_Event;
{
        register unsigned int L0656_ui_MapX;
        register unsigned int L0657_ui_MapY;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_07_FIX */
        register GROUP* L0658_ps_Group;
        BOOLEAN L0659_B_RandomDirectionMoveRetried;


        L0659_B_RandomDirectionMoveRetried = FALSE;
#endif
        L0656_ui_MapX = P529_ps_Event->B.Location.MapX;
        L0657_ui_MapY = P529_ps_Event->B.Location.MapY;
        T252_001:
        if (((G272_i_CurrentMapIndex != G309_i_PartyMapIndex) || (L0656_ui_MapX != G306_i_PartyMapX) || (L0657_ui_MapY != G307_i_PartyMapY)) && (F175_gzzz_GROUP_GetThing(L0656_ui_MapX, L0657_ui_MapY) == C0xFFFE_THING_ENDOFLIST)) { /* BUG0_24 Lord Chaos may teleport into one of the Black Flames and become invisible until the Black Flame is killed. In this case, F175_gzzz_GROUP_GetThing returns the Black Flame thing and the Lord Chaos thing is not moved into the dungeon until the Black Flame is killed */
                if (P529_ps_Event->A.A.Type == C61_EVENT_MOVE_GROUP_AUDIBLE) {
                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, L0656_ui_MapX, L0657_ui_MapY, C01_MODE_PLAY_IF_PRIORITIZED);
                }
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(P529_ps_Event->C.Slot, CM1_MAPX_NOT_ON_A_SQUARE, 0, L0656_ui_MapX, L0657_ui_MapY);
                return;
        }
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_07_FIX If the group to move is Lord Chaos and 1/4 chance then try to move to a random adjacent destination square. This additional code makes sure Lord Chaos is soon moved to an adjacent square */
        if (!L0659_B_RandomDirectionMoveRetried) {
                L0659_B_RandomDirectionMoveRetried = TRUE;
                L0658_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(P529_ps_Event->C.Slot);
                if ((L0658_ps_Group->Type == C23_CREATURE_LORD_CHAOS) && !M04_RANDOM(4)) {
                        switch (M04_RANDOM(4)) {
                                case 0:
                                        L0656_ui_MapX--;
                                        break;
                                case 1:
                                        L0656_ui_MapX++;
                                        break;
                                case 2:
                                        L0657_ui_MapY--;
                                        break;
                                case 3:
                                        L0657_ui_MapY++;
                        }
                        if (F223_xxxx_GROUP_IsSquareACorridorTeleporterPitOrDoor(L0656_ui_MapX, L0657_ui_MapY)) {
                                goto T252_001;
                        }
                }
        }
#endif
        P529_ps_Event->Map_Time += 5;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P529_ps_Event);
}

VOID F253_xxxx_TIMELINE_ProcessEvent11Part1_EnableChampionAction(P530_i_ChampionIndex)
register int P530_i_ChampionIndex;
{
        register int L0660_i_SlotIndex;
        register int L0661_i_QuiverSlotIndex;
        register CHAMPION* L0662_ps_Champion;


        L0662_ps_Champion = &G407_s_Party.Champions[P530_i_ChampionIndex];
        L0662_ps_Champion->EnableActionEventIndex = -1;
        M09_CLEAR(L0662_ps_Champion->Attributes, MASK0x0008_DISABLE_ACTION);
        if (L0662_ps_Champion->ActionIndex != C255_ACTION_NONE) {
                L0662_ps_Champion->ActionDefense -= G495_ac_Graphic560_ActionDefense[L0662_ps_Champion->ActionIndex];
        }
        if (L0662_ps_Champion->CurrentHealth) {
                if ((L0662_ps_Champion->ActionIndex == C032_ACTION_SHOOT) && (L0662_ps_Champion->Slots[C00_SLOT_READY_HAND] == C0xFFFF_THING_NONE)) {
                        if (F294_aozz_CHAMPION_IsAmmunitionCompatibleWithWeapon(P530_i_ChampionIndex, C01_SLOT_ACTION_HAND, L0660_i_SlotIndex = C12_SLOT_QUIVER_LINE1_1)) {
                                T253_002:
                                F301_apzz_CHAMPION_AddObjectInSlot(P530_i_ChampionIndex, F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P530_i_ChampionIndex, L0660_i_SlotIndex), C00_SLOT_READY_HAND);
                        } else {
                                for(L0661_i_QuiverSlotIndex = 0; L0661_i_QuiverSlotIndex < 3; L0661_i_QuiverSlotIndex++) {
                                        if (F294_aozz_CHAMPION_IsAmmunitionCompatibleWithWeapon(P530_i_ChampionIndex, C01_SLOT_ACTION_HAND, L0660_i_SlotIndex = L0661_i_QuiverSlotIndex + C07_SLOT_QUIVER_LINE2_1)) {
                                                goto T253_002;
                                        }
                                }
                        }
                }
                M08_SET(L0662_ps_Champion->Attributes, MASK0x8000_ACTION_HAND);
                F292_arzz_CHAMPION_DrawState(P530_i_ChampionIndex);
        }
        L0662_ps_Champion->ActionIndex = C255_ACTION_NONE;
}

VOID F254_xxxx_TIMELINE_ProcessEvent12_HideDamageReceived(P531_ui_ChampionIndex)
register unsigned int P531_ui_ChampionIndex;
{
        register CHAMPION* L0663_ps_Champion;


        L0663_ps_Champion = &G407_s_Party.Champions[P531_ui_ChampionIndex];
        L0663_ps_Champion->HideDamageReceivedEventIndex = -1;
        if (!L0663_ps_Champion->CurrentHealth) {
                return;
        }
        if (M00_INDEX_TO_ORDINAL(P531_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal) {
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F354_szzz_INVENTORY_DrawStatusBoxPortrait(P531_ui_ChampionIndex);
                F078_xzzz_MOUSE_ShowPointer();
        } else {
                M08_SET(L0663_ps_Champion->Attributes, MASK0x0080_NAME_TITLE);
                F292_arzz_CHAMPION_DrawState(P531_ui_ChampionIndex);
        }
}

VOID F255_xxxx_TIMELINE_ProcessEvent13_ViAltarRebirth(P532_ps_Event)
register EVENT* P532_ps_Event;
{
        register int L0664_i_MapX;
        register int L0665_i_MapY;
        register unsigned int L0666_ui_Cell;
        register THING L0667_T_Thing;
        register JUNK* L0668_ps_Junk;
        int L0669_i_IconIndex;
        int L0670_i_Step;
        unsigned int L0671_ui_ChampionIndex;


        L0664_i_MapX = P532_ps_Event->B.Location.MapX;
        L0665_i_MapY = P532_ps_Event->B.Location.MapY;
        L0666_ui_Cell = P532_ps_Event->C.A.Cell;
        L0671_ui_ChampionIndex = P532_ps_Event->A.A.Priority;
        switch (L0670_i_Step = P532_ps_Event->C.A.Effect) { /* Rebirth is a 3 steps process (Step 2 -> Step 1 -> Step 0). Step is stored in the Effect value of the event */
                case 2:
                        F213_hzzz_EXPLOSION_Create(C0xFFE4_THING_EXPLOSION_REBIRTH_STEP1, 0, L0664_i_MapX, L0665_i_MapY, L0666_ui_Cell);
                        P532_ps_Event->Map_Time += 5;
                        T255_002:
                        L0670_i_Step--;
                        P532_ps_Event->C.A.Effect = L0670_i_Step;
                        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(P532_ps_Event);
                        break;
                case 1:
                        for(L0667_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(L0664_i_MapX, L0665_i_MapY); L0667_T_Thing != C0xFFFE_THING_ENDOFLIST; L0667_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0667_T_Thing)) {
                                if ((M11_CELL(L0667_T_Thing) == L0666_ui_Cell) && (M12_TYPE(L0667_T_Thing) == C10_THING_TYPE_JUNK)) {
                                        L0669_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L0667_T_Thing);
                                        if (L0669_i_IconIndex == C147_ICON_JUNK_CHAMPION_BONES) {
                                                L0668_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L0667_T_Thing);
                                                if (L0668_ps_Junk->ChargeCount == L0671_ui_ChampionIndex) {
                                                        F164_dzzz_DUNGEON_UnlinkThingFromList(L0667_T_Thing, 0, L0664_i_MapX, L0665_i_MapY); /* BUG0_25 When a champion dies, no bones object is created so it is not possible to bring the champion back to life at an altar of Vi. Each time a champion is brought back to life, the bones object is removed from the dungeon but it is not marked as unused and thus becomes an orphan. After a large number of champion deaths, all JUNK things are exhausted and the game cannot create any more. This also affects the creation of JUNK things dropped by some creatures when they die (Screamer, Rockpile, Magenta Worm, Pain Rat, Red Dragon) */
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_03_FIX Mark the thing data as unused so it is not orphaned anymore */
                                                        L0668_ps_Junk->Next = C0xFFFF_THING_NONE;
#endif
                                                        P532_ps_Event->Map_Time += 1;
                                                        goto T255_002;
                                                }
                                        }
                                }
                        }
                        break;
                case 0:
                        F283_azzz_CHAMPION_ViAltarRebirth(P532_ps_Event->A.A.Priority);
        }
}

VOID F256_xxxx_TIMELINE_ProcessEvent53_Watchdog()
{
        EVENT L0672_s_Event;


        L0672_s_Event.A.A.Type = C53_EVENT_WATCHDOG;
        L0672_s_Event.Map_Time = G374_l_WatchdogTime = G313_ul_GameTime + 300;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0672_s_Event);
}

VOID F257_xxxx_TIMELINE_ProcessEvent70_Light(P534_ps_Event)
register EVENT* P534_ps_Event;
{
        register int L0673_i_WeakerLightPower;
        register int L0674_i_Multiple;
#define A0674_i_LightPower  L0674_i_Multiple
#define A0674_i_LightAmount L0674_i_Multiple
        register BOOLEAN L0675_B_NegativeLightPower;
        EVENT L0676_s_Event;


        if ((A0674_i_LightPower = P534_ps_Event->B.LightPower) == 0) {
                return;
        }
        if (L0675_B_NegativeLightPower = (A0674_i_LightPower < 0)) {
                A0674_i_LightPower = -A0674_i_LightPower;
        }
        L0673_i_WeakerLightPower = A0674_i_LightPower - 1;
        A0674_i_LightAmount = G039_ai_Graphic562_LightPowerToLightAmount[A0674_i_LightPower] - G039_ai_Graphic562_LightPowerToLightAmount[L0673_i_WeakerLightPower];
        if (L0675_B_NegativeLightPower) {
                A0674_i_LightAmount = -A0674_i_LightAmount;
                L0673_i_WeakerLightPower = -L0673_i_WeakerLightPower;
        }
        G407_s_Party.MagicalLightAmount += A0674_i_LightAmount;
        if (L0673_i_WeakerLightPower) {
                L0676_s_Event.A.A.Type = C70_EVENT_LIGHT;
                L0676_s_Event.B.LightPower = L0673_i_WeakerLightPower;
                M33_SET_MAP_AND_TIME(L0676_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + 4);
                L0676_s_Event.A.A.Priority = 0;
                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0676_s_Event);
        }
}

BOOLEAN F258_xxxx_TIMELINE_HasWeaponMovedToSlot(P535_i_ChampionIndex, P536_ps_Champion, P537_i_SourceSlotIndex, P538_i_DestinationSlotIndex)
register int P535_i_ChampionIndex;
register CHAMPION* P536_ps_Champion;
register int P537_i_SourceSlotIndex;
register int P538_i_DestinationSlotIndex;
{
        if (M12_TYPE(P536_ps_Champion->Slots[P537_i_SourceSlotIndex]) == C05_THING_TYPE_WEAPON) {
                F301_apzz_CHAMPION_AddObjectInSlot(P535_i_ChampionIndex, F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P535_i_ChampionIndex, P537_i_SourceSlotIndex), P538_i_DestinationSlotIndex);
                return TRUE;
        }
        return FALSE;
}

VOID F259_xxxx_TIMELINE_ProcessEvent11Part2_MoveWeaponFromQuiverToSlot(P539_i_ChampionIndex, P540_i_SlotIndex)
register int P539_i_ChampionIndex;
register int P540_i_SlotIndex;
{
        register unsigned int L0677_ui_SlotIndex;
        register CHAMPION* L0678_ps_Champion;


        L0678_ps_Champion = &G407_s_Party.Champions[P539_i_ChampionIndex];
        if (L0678_ps_Champion->Slots[P540_i_SlotIndex] != C0xFFFF_THING_NONE) {
                return;
        }
        if (F258_xxxx_TIMELINE_HasWeaponMovedToSlot(P539_i_ChampionIndex, L0678_ps_Champion, C12_SLOT_QUIVER_LINE1_1, P540_i_SlotIndex)) {
                return;
        }
        for(L0677_ui_SlotIndex = C07_SLOT_QUIVER_LINE2_1; L0677_ui_SlotIndex <= C09_SLOT_QUIVER_LINE2_2; L0677_ui_SlotIndex++) {
                if (F258_xxxx_TIMELINE_HasWeaponMovedToSlot(P539_i_ChampionIndex, L0678_ps_Champion, L0677_ui_SlotIndex, P540_i_SlotIndex)) {
                        return;
                }
        }
}

VOID F260_pzzz_TIMELINE_RefreshAllChampionStatusBoxes()
{
        register int L0679_i_ChampionIndex;


        for(L0679_i_ChampionIndex = C00_CHAMPION_FIRST; L0679_i_ChampionIndex < G305_ui_PartyChampionCount; L0679_i_ChampionIndex++) {
                M08_SET(G407_s_Party.Champions[L0679_i_ChampionIndex].Attributes, MASK0x1000_STATUS_BOX);
        }
        F293_ahzz_CHAMPION_DrawAllChampionStates();
}

VOID F261_hzzz_TIMELINE_Process_COPYPROTECTIONEF()
{
        register unsigned int L0680_ui_Multiple;
#define A0680_ui_EventType     L0680_ui_Multiple
#define A0680_ui_ChampionIndex L0680_ui_Multiple
        register EVENT* L0681_ps_Event;
        EVENT L0682_s_Event;


        while (F240_xxxx_TIMELINE_IsFirstEventExpired_COPYPROTECTIONE()) {
                L0681_ps_Event = &L0682_s_Event;
                F239_xxxx_TIMELINE_ExtractFirstEvent(L0681_ps_Event);
                F173_gzzz_DUNGEON_SetCurrentMap(M29_MAP(L0682_s_Event.Map_Time));
#ifndef NOCOPYPROTECTION
                if (G319_ul_LoadGameTime_COPYPROTECTIONF <= G313_ul_GameTime) { /* This condition is always true */
#endif
                        A0680_ui_EventType = L0682_s_Event.A.A.Type;
#ifndef NOCOPYPROTECTION
                }
#endif
                if ((A0680_ui_EventType > (C29_EVENT_GROUP_REACTION_DANGER_ON_SQUARE - 1)) && (A0680_ui_EventType < (C41_EVENT_UPDATE_BEHAVIOR_CREATURE_3 + 1))) {
                        F209_xzzz_GROUP_ProcessEvents29to41(L0682_s_Event.B.Location.MapX, L0682_s_Event.B.Location.MapY, A0680_ui_EventType, L0682_s_Event.C.Ticks);
                } else {
                        switch (A0680_ui_EventType) {
                                case C48_EVENT_MOVE_PROJECTILE_IGNORE_IMPACTS:
                                case C49_EVENT_MOVE_PROJECTILE:
                                        F219_xxxx_PROJECTILE_ProcessEvents48To49_Projectile(L0681_ps_Event);
                                        break;
                                case C01_EVENT_DOOR_ANIMATION:
                                        F241_xxxx_TIMELINE_ProcessEvent1_DoorAnimation(L0681_ps_Event);
                                        break;
                                case C25_EVENT_EXPLOSION:
                                        F220_xxxx_EXPLOSION_ProcessEvent25_Explosion(L0681_ps_Event);
                                        break;
                                case C07_EVENT_FAKEWALL:
                                        F242_xxxx_TIMELINE_ProcessEvent7_Square_FakeWall(L0681_ps_Event);
                                        break;
                                case C02_EVENT_DOOR_DESTRUCTION:
                                        F243_xxxx_TIMELINE_ProcessEvent2_DoorDestruction(L0681_ps_Event);
                                        break;
                                case C10_EVENT_DOOR:
                                        F244_xxxx_TIMELINE_ProcessEvent10_Square_Door(L0681_ps_Event);
                                        break;
                                case C09_EVENT_PIT:
                                        F251_xxxx_TIMELINE_ProcessEvent9_Square_Pit(L0681_ps_Event);
                                        break;
                                case C08_EVENT_TELEPORTER:
                                        F250_xxxx_TIMELINE_ProcessEvent8_Square_Teleporter(L0681_ps_Event);
                                        break;
                                case C06_EVENT_WALL:
                                        F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall(L0681_ps_Event);
                                        break;
                                case C05_EVENT_CORRIDOR:
                                        F245_xxxx_TIMELINE_ProcessEvent5_Square_Corridor(L0681_ps_Event);
                                        break;
                                case C60_EVENT_MOVE_GROUP_SILENT:
                                case C61_EVENT_MOVE_GROUP_AUDIBLE:
                                        F252_xxxx_TIMELINE_ProcessEvents60to61_MoveGroup(L0681_ps_Event);
                                        break;
                                case C65_EVENT_ENABLE_GROUP_GENERATOR:
                                        F246_xxxx_TIMELINE_ProcessEvent65_EnableGroupGenerator(L0681_ps_Event);
                                        break;
                                case C20_EVENT_PLAY_SOUND:
                                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(L0682_s_Event.C.SoundIndex, L0682_s_Event.B.Location.MapX, L0682_s_Event.B.Location.MapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                        break;
                                case C24_EVENT_REMOVE_FLUXCAGE:
                                        if (!G302_B_GameWon) {
                                                F164_dzzz_DUNGEON_UnlinkThingFromList(L0682_s_Event.C.Slot, 0, L0682_s_Event.B.Location.MapX, L0682_s_Event.B.Location.MapY);
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                                ((EXPLOSION*)G284_apuc_ThingData[C15_THING_TYPE_EXPLOSION])[M13_INDEX(L0682_s_Event.C.Slot)].Next = C0xFFFF_THING_NONE;
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                                                L0681_ps_Event = (EVENT*)F156_afzz_DUNGEON_GetThingData(L0682_s_Event.C.Slot);
                                                ((EXPLOSION*)L0681_ps_Event)->Next = C0xFFFF_THING_NONE;
#endif
                                        }
                                        break;
#ifndef NOCOPYPROTECTION
                                case C22_EVENT_COPYPROTECTIONE:
                                        if (!F210_uzzz_COPYPROTECTIONE_ProcessEvent22_IsSector7Valid_NormalBytes(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE)) {
                                                G022_i_Graphic562_IndirectStopExpiringEvent_COPYPROTECTIONE = C00136_TRUE;
                                        }
                                        break;
#endif
                                case C11_EVENT_ENABLE_CHAMPION_ACTION:
                                        F253_xxxx_TIMELINE_ProcessEvent11Part1_EnableChampionAction(L0682_s_Event.A.A.Priority);
                                        if (L0682_s_Event.B.SlotOrdinal) {
                                                F259_xxxx_TIMELINE_ProcessEvent11Part2_MoveWeaponFromQuiverToSlot(L0682_s_Event.A.A.Priority, M01_ORDINAL_TO_INDEX(L0682_s_Event.B.SlotOrdinal));
                                        }
                                        goto T261_048;
                                case C12_EVENT_HIDE_DAMAGE_RECEIVED:
                                        F254_xxxx_TIMELINE_ProcessEvent12_HideDamageReceived(L0682_s_Event.A.A.Priority);
                                        break;
                                case C53_EVENT_WATCHDOG:
                                        F256_xxxx_TIMELINE_ProcessEvent53_Watchdog(L0681_ps_Event); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 0 parameters. No consequence because additional parameters are ignored */
                                        break;
                                case C70_EVENT_LIGHT:
                                        F173_gzzz_DUNGEON_SetCurrentMap(G309_i_PartyMapIndex);
                                        F257_xxxx_TIMELINE_ProcessEvent70_Light(L0681_ps_Event);
                                        F337_akzz_INVENTORY_SetDungeonViewPalette();
                                        break;
                                case C71_EVENT_INVISIBILITY:
                                        G407_s_Party.Event71Count_Invisibility--;
                                        break;
                                case C72_EVENT_CHAMPION_SHIELD:
                                        G407_s_Party.Champions[L0682_s_Event.A.A.Priority].ShieldDefense -= L0682_s_Event.B.Defense;
                                        M08_SET(G407_s_Party.Champions[L0682_s_Event.A.A.Priority].Attributes, MASK0x1000_STATUS_BOX);
                                        T261_048:
                                        F292_arzz_CHAMPION_DrawState(L0682_s_Event.A.A.Priority);
                                        break;
                                case C73_EVENT_THIEVES_EYE:
                                        G407_s_Party.Event73Count_ThievesEye--;
                                        break;
                                case C74_EVENT_PARTY_SHIELD:
                                        G407_s_Party.ShieldDefense -= L0682_s_Event.B.Defense;
                                        T261_053:
                                        F260_pzzz_TIMELINE_RefreshAllChampionStatusBoxes();
                                        break;
                                case C77_EVENT_SPELLSHIELD:
                                        G407_s_Party.SpellShieldDefense -= L0682_s_Event.B.Defense;
                                        goto T261_053;
                                case C78_EVENT_FIRESHIELD:
                                        G407_s_Party.FireShieldDefense -= L0682_s_Event.B.Defense;
                                        goto T261_053;
                                case C75_EVENT_POISON_CHAMPION:
                                        G407_s_Party.Champions[A0680_ui_ChampionIndex = L0682_s_Event.A.A.Priority].PoisonEventCount--;
                                        F322_lzzz_CHAMPION_Poison(A0680_ui_ChampionIndex, L0682_s_Event.B.Attack);
                                        break;
                                case C13_EVENT_VI_ALTAR_REBIRTH:
                                        F255_xxxx_TIMELINE_ProcessEvent13_ViAltarRebirth(L0681_ps_Event);
                                        break;
                                case C79_EVENT_FOOTPRINTS:
                                        G407_s_Party.Event79Count_Footprints--;
                        }
                }
                F173_gzzz_DUNGEON_SetCurrentMap(G309_i_PartyMapIndex);
        }
}
