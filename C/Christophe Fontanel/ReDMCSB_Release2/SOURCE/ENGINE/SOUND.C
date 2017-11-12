#include "DEFS.H"

/*_Global variables_*/
BOOLEAN G578_B_UseByteBoxCoordinates = FALSE;
int G579_i_Unreferenced; /* BUG0_00 Useless code */
unsigned int G580_ui_PSGModeRegisterBackup;
char* G581_pc_contermSystemVariable = C0x0484_ADDRESS_SYSTEM_VARIABLE_conterm;
char G582_c_contermSystemVariableBackup;
int G583_i_PendingSoundIndex = -1;
unsigned int G584_ui_PendingSoundLoud = FALSE;
#ifndef NOCOPYPROTECTION
char G585_ac_CodePatch0_COPYPROTECTIONE[68];
#endif


overlay "main"

VOID F060_AA29_SOUND_Play(P084_puc_SoundData, P085_i_Period, P086_B_Loud)
unsigned char* P084_puc_SoundData;
register int P085_i_Period;
BOOLEAN P086_B_Loud;
{
        register long L0038_l_NextSoundSample; /* 'Virtual' address of the first sound sample: the quotient of this value divided by 2 is the address of the byte containing the sample, the remainder of the same division determines which 4 bit sample is addressed in the byte */
        register int L0039_i_RemainingSoundSampleCount;
        int L0040_i_PSGModeRegisterBackup;
        long L0041_l_SupervisorStack;


        L0038_l_NextSoundSample = (long)P084_puc_SoundData;
        L0038_l_NextSoundSample = (L0038_l_NextSoundSample + 2) * 2; /* The first two bytes contain the sample count. There are two samples per byte of sound data */
        L0039_i_RemainingSoundSampleCount = ((unsigned char)P084_puc_SoundData[0] << 8) | (unsigned char)P084_puc_SoundData[1];
        Giaccess(0, MASK0x0080_WRITE_PSG_REGISTER | C11_REGISTER_PSG_WAVEFORM_FREQUENCY_LOW_BYTE);
        Giaccess(0, MASK0x0080_WRITE_PSG_REGISTER | C12_REGISTER_PSG_WAVEFORM_FREQUENCY_HIGH_BYTE);
        L0040_i_PSGModeRegisterBackup = Giaccess(C0_RESERVED, MASK0x0000_READ_PSG_REGISTER | C07_REGISTER_PSG_MODE);
        Giaccess(L0040_i_PSGModeRegisterBackup | C0x003F_MODE_ENABLE_TONE_AND_WHITE_NOISE_CHANNELS_A_B_C, MASK0x0080_WRITE_PSG_REGISTER | C07_REGISTER_PSG_MODE);
        if (P085_i_Period > 10) {
                L0041_l_SupervisorStack = Super(0L);
                asm {
                        lea     0xFFFFFA1F,A0           /* Address of MFP-ST Timer A Data Register */
                        move.b  P085_i_Period,(A0)      /* Write to Timer A Data Register
                                                                Value 145 (used for the Door sound on the main menu): 2.4576 MHz / (4 * 145) = 4237 Hz
                                                                Value 112 (used for all other sounds): 2.4576 MHz / (4 * 112) = 5486 Hz */
                }
                Super(L0041_l_SupervisorStack);
        }
        asm {
                lea     V061_3_aav_l_NextSoundSample(PC),A0
                move.l  L0038_l_NextSoundSample,(A0)
                lea     V061_1_HHH_i_RemainingSoundSampleCount(PC),A0
                move.w  L0039_i_RemainingSoundSampleCount,(A0)
                lea     V061_2_A79_i_SoundSampleRepeatCount(PC),A0
                clr.w   (A0)
        }
        if (P086_B_Loud == FALSE) {
                asm {
                        lea     V061_6_dzz_al_ChannelsAmplitudeTableSoft(PC),A0
                        lea     V061_4_GFF_l_CurrentChannelsAmplitudeTable(PC),A1
                        move.l  A0,(A1)                                                 /* Set current channels amplitude to table B (soft) */
                }
        } else {
                asm {
                        lea     V061_5_xxx_al_ChannelsAmplitudeTableLoud(PC),A0
                        lea     V061_4_GFF_l_CurrentChannelsAmplitudeTable(PC),A1
                        move.l  A0,(A1)                                                 /* Set current channels amplitude to table A (loud) */
                }
        }
        Jenabint(C13_INTERRUPT_TIMER_A);
}

VOID F061_xxxx_SOUND_SetChannelAmplitudes(P087_i_AmplitudeIndex)
register int P087_i_AmplitudeIndex;
{
        register long L0042_l_Multiple;
#define A0042_l_SupervisorStack        L0042_l_Multiple
#define A0042_l_SoundSampleRepeatCount L0042_l_Multiple


        A0042_l_SupervisorStack = Super(0L);
        asm {
                and.w   #0x000F,P087_i_AmplitudeIndex                                   /* This function is called only once with P087_i_AmplitudeIndex = 8 */
                add.b   P087_i_AmplitudeIndex,P087_i_AmplitudeIndex
                add.b   P087_i_AmplitudeIndex,P087_i_AmplitudeIndex                     /* P087_i_AmplitudeIndex is now 4 * AmplitudeIndex = 32 */
                movea.w #0x8800,A1                                                      /* Address of the PSG Register Select */
                lea     V061_5_xxx_al_ChannelsAmplitudeTableLoud(PC),A0
                move.l  -64(A0,P087_i_AmplitudeIndex),(A1)                              /* Writing a long writes both a word for PSG Register Select and a word for PSG Write Data Channel A amplitude (0 for P087_i_AmplitudeIndex = 32) */
                move.l  0(A0,P087_i_AmplitudeIndex),(A1)                                /* Channel B amplitude (0 for P087_i_AmplitudeIndex = 32) */
                move.l  64(A0,P087_i_AmplitudeIndex),(A1)                               /* Channel C amplitude (0 for P087_i_AmplitudeIndex = 32) */
                bra     T061_017
                E061_aAA6_SOUND_Exception77Handler_TimerA_SoundPlayer:
                        movem.l D7/A0-A1,-(A7)
                        lea     V061_1_HHH_i_RemainingSoundSampleCount(PC),A0
                        tst.w   (A0)
                        beq.s   T061_005                                                /* If there are no sound samples left to play */
                        subq.w  #1,(A0)+                                                /* There is now one less sample to play. Increment A0 which is now the address of V061_2_A79_i_SoundSampleRepeatCount */
                        tst.w   (A0)+                                                   /* Test V061_2_A79_i_SoundSampleRepeatCount and increment A0 which is now the address of V061_3_aav_l_NextSoundSample */
                        beq.s   T061_002                                                /* Branch if V061_2_A79_i_SoundSampleRepeatCount = 0 */
                        subq.w  #1,-(A0)                                                /* Decrement V061_2_A79_i_SoundSampleRepeatCount */
                        bra.s   T061_003
                T061_002:
                        move.l  (A0),D7                                                 /* Address of the next sound sample to play */
                        addq.l  #1,(A0)+                                                /* Proceed to next sound sample to play. Increment A0 which is now the address of V061_4_GFF_l_CurrentChannelsAmplitudeTable */
                        lsr.l   #1,D7                                                   /* Address of the byte containing the next sound sample to play. Bits are shifted to the right, Bit 0 is removed and placed in C and X bits in the CCR. Bit 31 is set to 0 */
                        bcs.s   T061_004                                                /* Branch if bit 0 of the address was 1. The second 4 bits sound sample in the byte should be played (least significant bits) */
                        movea.l D7,A1                                                   /* Address of the byte containing the next sound sample to play */
                        move.b  (A1),D7                                                 /* Byte containing the sound sample to play */
                        lsr.b   #2,D7                                                   /* Sample value multiplied by 4 (each entry in the table is 4 bytes large) */
                        andi.w  #0x003C,D7                                              /* The 4 bits sound sample to play (most significant nibble) */
                        beq.s   T061_006                                                /* If sound sample = 0. If the previous sample should be repeated */
                        movea.w #0x8800,A1                                              /* Address of the PSG Register Select */
                        movea.l (A0),A0                                                 /* V061_4_GFF_l_CurrentChannelsAmplitudeTable */
                        move.l  -64(A0,D7.w),(A1)                                       /* Writing a long writes both a word for PSG Register Select and a word for PSG Write Data. Channel A amplitude */
                        move.l  0(A0,D7.w),(A1)                                         /* Channel B amplitude */
                        move.l  64(A0,D7.w),(A1)                                        /* Channel C amplitude */
                T061_003:
                        bclr    #0x05,0xFFFFFA0F                                        /* Clear bit 5 on MFP 'Interrupt In-Service Register A' to indicate that the Timer A interrupt processing is complete */
                        movem.l (A7)+,D7/A0-A1
                        rte
                T061_004:
                        movea.l D7,A1
                        move.b  (A1),D7
                        andi.w  #0x000F,D7                                              /* Get least significant bits of the sound data byte */
                        beq.s   T061_006                                                /* If the sound sample should be repeated */
                        add.b   D7,D7
                        add.b   D7,D7                                                   /* Sample value multiplied by 4 (each entry in the table is 4 bytes large) */
                        movea.w #0x8800,A1                                              /* Address of the PSG Register Select */
                        movea.l (A0),A0                                                 /* V061_4_GFF_l_CurrentChannelsAmplitudeTable */
                        move.l  -64(A0,D7.w),(A1)                                       /* Writing a long writes both a word for PSG Register Select and a word for PSG Write Data. Channel A amplitude */
                        move.l  0(A0,D7.w),(A1)                                         /* Channel B amplitude */
                        move.l  64(A0,D7.w),(A1)                                        /* Channel C amplitude */
                        bclr    #0x05,0xFFFFFA0F                                        /* Clear bit 5 on MFP 'Interrupt In-Service Register A' to indicate that the Timer A interrupt processing is complete */
                        movem.l (A7)+,D7/A0-A1
                        rte
                T061_005:
                        bclr    #5,0xFFFFFA07                                           /* Clear bit 5 on MFP 'Interrupt Enable Register A' to disable Timer A interrupts. This marks the end of processing for playing a sound */
                        bclr    #5,0xFFFFFA0F                                           /* Clear bit 5 on MFP 'Interrupt In-Service Register A' to indicate that the Timer A interrupt processing is complete */
                        movem.l (A7)+,D7/A0-A1
                        rte
                T061_006:
                        move.l  A0042_l_SupervisorStack,-(A7)
                        clr.w   A0042_l_SoundSampleRepeatCount
                T061_007:
                        lea     V061_3_aav_l_NextSoundSample(PC),A0
                        move.l  (A0),D7
                        addq.l  #1,(A0)                                                 /* Proceed to the next sound sample */
                        lsr.l   #1,D7                                                   /* Address of the byte containing the next sound sample to play */
                        bcs.s   T061_008                                                /* Branch if bit 0 of the address was 1. The second 4 bit sound sample in the byte should be played */
                        movea.l D7,A1
                        move.b  (A1),D7
                        lsr.b   #4,D7                                                   /* Get 4 most significant bits */
                        bra.s   T061_009
                T061_008:
                        movea.l D7,A1
                        move.b  (A1),D7                                                 /* Get 4 least significant bits */
                T061_009:
                        btst    #3,D7
                        beq.s   T061_010                                                /* Branch if bit 3 of D7 = 0. If the repeat count value is complete */
                        and.w   #0x0007,D7                                              /* Keep only the 3 bits of the repeat count */
                        lsl.w   #3,A0042_l_SoundSampleRepeatCount                       /* Make room in A0042_l_SoundSampleRepeatCount for the next 3 bits */
                        add.w   D7,A0042_l_SoundSampleRepeatCount                       /* Place the 3 bits in A0042_l_SoundSampleRepeatCount */
                        bra.s   T061_007
                T061_010:
                        lsl.w   #3,A0042_l_SoundSampleRepeatCount                       /* Make room in A0042_l_SoundSampleRepeatCount for the last 3 bits */
                        and.w   #0x0007,D7
                        add.w   D7,A0042_l_SoundSampleRepeatCount                       /* Place the last 3 bits in A0042_l_SoundSampleRepeatCount */
                        addq.w  #2,A0042_l_SoundSampleRepeatCount
                        lea     V061_2_A79_i_SoundSampleRepeatCount(PC),A0
                        move.w  A0042_l_SoundSampleRepeatCount,(A0)                     /* Set the repeat count value. The sound sample is played A0042_l_SoundSampleRepeatCount + 3 times total (the first time + repeat count + 2) */
                        bclr    #5,0xFFFFFA0F                                           /* Clear bit 5 on MFP 'Interrupt In-Service Register A' to indicate that the Timer A interrupt processing is complete */
                        move.l  (A7)+,A0042_l_SupervisorStack
                        movem.l (A7)+,D7/A0-A1
                        rte
                V061_1_HHH_i_RemainingSoundSampleCount:
                        dc.w    0x0000
                V061_2_A79_i_SoundSampleRepeatCount:
                        dc.w    0x0000
                V061_3_aav_l_NextSoundSample:
                        dc.l    0x00000000
                V061_4_GFF_l_CurrentChannelsAmplitudeTable:
                        dc.l    0x00000000
                        dc.w    0x0800,0x0000,0x0800,0x0800                             /* 192 bytes: 3x64 bytes for channel A (register 8), channel B (register 9) and channel C (register 10) */
                        dc.w    0x0800,0x0A00,0x0800,0x0B00                             /* Accessed using V061_5_xxx_al_ChannelsAmplitudeTableLoud with offsets -64, 0 and 64 */
                        dc.w    0x0800,0x0C00,0x0800,0x0D00                             /* First byte: Register number (for channel selection) */
                        dc.w    0x0800,0x0D00,0x0800,0x0D00                             /* Third byte: Channel A/B/C amplitude */
                        dc.w    0x0800,0x0E00,0x0800,0x0E00                             /* Second and fourth bytes are padding 0x00 as data is written as longs to write to both PSG addresses in one instruction */
                        dc.w    0x0800,0x0E00,0x0800,0x0E00
                        dc.w    0x0800,0x0F00,0x0800,0x0E00
                        dc.w    0x0800,0x0E00,0x0800,0x0E00
                V061_5_xxx_al_ChannelsAmplitudeTableLoud:
                        dc.w    0x0900,0x0000,0x0900,0x0500
                        dc.w    0x0900,0x0700,0x0900,0x0900
                        dc.w    0x0900,0x0900,0x0900,0x0500
                        dc.w    0x0900,0x0A00,0x0900,0x0C00
                        dc.w    0x0900,0x0800,0x0900,0x0A00
                        dc.w    0x0900,0x0C00,0x0900,0x0D00
                        dc.w    0x0900,0x0B00,0x0900,0x0E00
                        dc.w    0x0900,0x0E00,0x0900,0x0E00
                        dc.w    0x0A00,0x0000,0x0A00,0x0000
                        dc.w    0x0A00,0x0000,0x0A00,0x0000
                        dc.w    0x0A00,0x0000,0x0A00,0x0000
                        dc.w    0x0A00,0x0600,0x0A00,0x0000
                        dc.w    0x0A00,0x0000,0x0A00,0x0A00
                        dc.w    0x0A00,0x0A00,0x0A00,0x0A00
                        dc.w    0x0A00,0x0000,0x0A00,0x0B00
                        dc.w    0x0A00,0x0D00,0x0A00,0x0E00
                        dc.w    0x0800,0x0000,0x0800,0x0500                             /* 192 bytes: 3x64 bytes for Channel A (register 8), channel B (register 9) and channel C (register 10) */
                        dc.w    0x0800,0x0700,0x0800,0x0800                             /* Accessed using V061_6_dzz_al_ChannelsAmplitudeTableSoft with offsets -64, 0 and 64 */
                        dc.w    0x0800,0x0900,0x0800,0x0900                             /* First byte: Register number (for channel selection) */
                        dc.w    0x0800,0x0A00,0x0800,0x0A00                             /* Third byte: Channel A/B/C amplitude */
                        dc.w    0x0800,0x0B00,0x0800,0x0B00                             /* Second and fourth bytes are padding 0x00 as data is written as longs to write to both PSG addresses in one instruction */
                        dc.w    0x0800,0x0B00,0x0800,0x0B00
                        dc.w    0x0800,0x0C00,0x0800,0x0C00
                        dc.w    0x0800,0x0C00,0x0800,0x0C00
                V061_6_dzz_al_ChannelsAmplitudeTableSoft:
                        dc.w    0x0900,0x0000,0x0900,0x0000
                        dc.w    0x0900,0x0100,0x0900,0x0200
                        dc.w    0x0900,0x0200,0x0900,0x0500
                        dc.w    0x0900,0x0200,0x0900,0x0600
                        dc.w    0x0900,0x0300,0x0900,0x0600
                        dc.w    0x0900,0x0700,0x0900,0x0800
                        dc.w    0x0900,0x0400,0x0900,0x0600
                        dc.w    0x0900,0x0800,0x0900,0x0900
                        dc.w    0x0A00,0x0000,0x0A00,0x0000
                        dc.w    0x0A00,0x0000,0x0A00,0x0000
                        dc.w    0x0A00,0x0000,0x0A00,0x0200
                        dc.w    0x0A00,0x0200,0x0A00,0x0100
                        dc.w    0x0A00,0x0100,0x0A00,0x0200
                        dc.w    0x0A00,0x0400,0x0A00,0x0500
                        dc.w    0x0A00,0x0100,0x0A00,0x0200
                        dc.w    0x0A00,0x0000,0x0A00,0x0000
                T061_017:
        }
        Super(A0042_l_SupervisorStack);
}

VOID F062_aalz_SOUND_Initialize()
{
        F063_aA05_SOUND_KeyClickOff();
        Giaccess(0, MASK0x0080_WRITE_PSG_REGISTER | C11_REGISTER_PSG_WAVEFORM_FREQUENCY_LOW_BYTE);
        Giaccess(0, MASK0x0080_WRITE_PSG_REGISTER | C12_REGISTER_PSG_WAVEFORM_FREQUENCY_HIGH_BYTE);
        G580_ui_PSGModeRegisterBackup = Giaccess(C0_RESERVED, MASK0x0000_READ_PSG_REGISTER | C07_REGISTER_PSG_MODE);
        Giaccess(G580_ui_PSGModeRegisterBackup | C0x003F_MODE_ENABLE_TONE_AND_WHITE_NOISE_CHANNELS_A_B_C, MASK0x0080_WRITE_PSG_REGISTER | C07_REGISTER_PSG_MODE);
        F061_xxxx_SOUND_SetChannelAmplitudes(8);
        Jdisint(C13_INTERRUPT_TIMER_A);
        Xbtimer(C0_TIMER_A, C1_DELAY_MODE_4_PRESCALE, 112, (char*)&E061_aAA6_SOUND_Exception77Handler_TimerA_SoundPlayer); /* Every 4 MFP input clock ticks, the timer A data (initial value 112) is decremented. An interrupt is triggered each time the data reaches 0. This means every 448 MFP input clock ticks, the actual frequency is then 2457600 Hz / 448 = 5486 Hz */
        Jdisint(C13_INTERRUPT_TIMER_A);
}

VOID F063_aA05_SOUND_KeyClickOff()
{
        long L0043_l_SupervisorStack;


        L0043_l_SupervisorStack = Super(0L);
        G582_c_contermSystemVariableBackup = *G581_pc_contermSystemVariable;
        M09_CLEAR(*G581_pc_contermSystemVariable, MASK0xFF01_KEY_CLICK);
        Super(L0043_l_SupervisorStack);
}

VOID F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(P088_i_SoundIndex, P089_i_MapX, P090_i_MapY, P091_ui_Mode)
int P088_i_SoundIndex;
int P089_i_MapX;
int P090_i_MapY;
unsigned int P091_ui_Mode;
{
        register SOUND* L0044_ps_Sound;
        EVENT L0045_s_Event;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION Variable definition changed */
        register BOOLEAN L0046_B_Loud;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION Variable definition changed */
        BOOLEAN L0046_B_Loud;
#endif
        register int L0047_i_DistanceToParty;
#ifndef NOCOPYPROTECTION
        static int G586_i_ImmediateSoundCount_COPYPROTECTIOND;
#endif



        if (P091_ui_Mode && (G272_i_CurrentMapIndex != G309_i_PartyMapIndex)) {
                return;
        }
        L0044_ps_Sound = &G060_as_Graphic562_Sounds[P088_i_SoundIndex];
        if (P091_ui_Mode > C01_MODE_PLAY_IF_PRIORITIZED) { /* Add an event in the timeline to play the sound (P091_ui_Mode - 1) ticks later */
                M33_SET_MAP_AND_TIME(L0045_s_Event.Map_Time, G272_i_CurrentMapIndex, G313_ul_GameTime + P091_ui_Mode - 1);
                L0045_s_Event.A.A.Type = C20_EVENT_PLAY_SOUND;
                L0045_s_Event.A.A.Priority = L0044_ps_Sound->Priority;
                L0045_s_Event.C.SoundIndex = P088_i_SoundIndex;
                L0045_s_Event.B.Location.MapX = P089_i_MapX;
                L0045_s_Event.B.Location.MapY = P090_i_MapY;
                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0045_s_Event);
        } else {
                L0047_i_DistanceToParty = (((L0047_i_DistanceToParty = (P089_i_MapX - G306_i_PartyMapX)) < 0) ? -L0047_i_DistanceToParty : L0047_i_DistanceToParty) + (((L0047_i_DistanceToParty = (P090_i_MapY - G307_i_PartyMapY)) < 0) ? -L0047_i_DistanceToParty : L0047_i_DistanceToParty);
                if (L0047_i_DistanceToParty < L0044_ps_Sound->LoudDistance) {
                        L0046_B_Loud = TRUE;
                } else {
                        if (L0047_i_DistanceToParty < L0044_ps_Sound->SoftDistance) {
                                L0046_B_Loud = FALSE;
                        } else {
                                return;
                        }
                }
#ifndef NOCOPYPROTECTION
                G586_i_ImmediateSoundCount_COPYPROTECTIOND++;
                if (((unsigned int)G586_i_ImmediateSoundCount_COPYPROTECTIOND >= 88) && !G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF) {
                        G586_i_ImmediateSoundCount_COPYPROTECTIOND = 0;
                        G240_i_Graphic559_State_COPYPROTECTIOND += 3;
                        M08_SET(G644_i_FloppyDiskReadBufferContentType_COPYPROTECTIONDF, MASK0x0002_BUFFER_CONTAINS_SECTOR247);
                        S465_qzzz_COPYPROTECTIOND_ReadSector247(G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF + 512);
                        G329_i_Useless_COPYPROTECTIOND &= (G058_i_Graphic562_Useless_COPYPROTECTIOND = G240_i_Graphic559_State_COPYPROTECTIOND << 2); /* BUG0_00 Useless code */
                }
#endif
                if (!P091_ui_Mode) { /* Play the sound immediately */
                        F060_AA29_SOUND_Play(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0044_ps_Sound->GraphicIndex | MASK0x8000_NOT_EXPANDED), L0044_ps_Sound->Period, L0046_B_Loud);
                } else { /* Set the requested sound as the pending sound if it is louder or has a higher priority than the current pending sound */
                        if ((G583_i_PendingSoundIndex == -1) || (L0046_B_Loud > G584_ui_PendingSoundLoud) || ((L0046_B_Loud == G584_ui_PendingSoundLoud) && (L0044_ps_Sound->Priority > G060_as_Graphic562_Sounds[G583_i_PendingSoundIndex].Priority))) {
                                G583_i_PendingSoundIndex = P088_i_SoundIndex;
                                G584_ui_PendingSoundLoud = L0046_B_Loud;
                        }
                }
        }
}

VOID F065_aanz_SOUND_PlayPendingSound_COPYPROTECTIOND()
{
        register SOUND* L0048_ps_Sound;


        if (G583_i_PendingSoundIndex != -1) {
                L0048_ps_Sound = &G060_as_Graphic562_Sounds[G583_i_PendingSoundIndex];
                F060_AA29_SOUND_Play(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0048_ps_Sound->GraphicIndex | MASK0x8000_NOT_EXPANDED), L0048_ps_Sound->Period, G584_ui_PendingSoundLoud);
#ifndef NOCOPYPROTECTION
                if ((G240_i_Graphic559_State_COPYPROTECTIOND & 0x0001) && !G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF) { /* If variable has an odd value, this means sector 247 was read */
                        if (M07_GET(G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF, MASK0x0004_SECTOR247)) {
                                M09_CLEAR(G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF, MASK0x0004_SECTOR247);
                                M09_CLEAR(G315_i_SectorsReadFailure_COPYPROTECTIONDF, MASK0x0004_SECTOR247);
                        }
                        G240_i_Graphic559_State_COPYPROTECTIOND++; /* Variable has an even value again */
                }
#endif
                G583_i_PendingSoundIndex = -1;
                G584_ui_PendingSoundLoud = FALSE;
        }
}
