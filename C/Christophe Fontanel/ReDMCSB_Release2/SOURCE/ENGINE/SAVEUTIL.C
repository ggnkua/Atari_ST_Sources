#include "DEFS.H"

/*_Global variables_*/
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
char* G519_pc_D081_ADMGAMEDAT = "A:\\DMGAME.DAT";
char* G520_pc_D082_ADMGAMEBAK = "A:\\DMGAME.BAK";
#endif
int G521_i_GameFileHandle; /* Dungeon file or saved game file */
long G522_l_Unreferenced; /* BUG0_00 Useless code */
BOOLEAN G523_B_RestartGameRequested;
BOOLEAN G524_B_RestartGameAllowed;
long G525_l_GameID;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
unsigned int G526_ui_DungeonID;
int G527_i_Platform;
int G528_i_Format;
int G529_i_Useless; /* BUG0_00 Useless code */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
BOOLEAN G530_B_LoadingCompressedDungeon;
unsigned char* G531_puc_DecompressedDungeonCurrentPosition;
long G532_l_DecompressedDungeonRemainingByteCount;
#endif
#ifndef NOCOPYPROTECTION
char G533_ac_CodePatch2_COPYPROTECTIONE[68];
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
char G534_ac_SaveHeaderAdditionalData[132];
#endif


overlay "start"

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
VOID F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString(P797_pc_DestinationString, P798_pc_SourceString, P799_i_DriveType)
char* P797_pc_DestinationString;
char* P798_pc_SourceString;
int P799_i_DriveType;
{
        char* L1278_pc_TildeCharacter;
        unsigned int L1279_ui_TildeCharacterPosition;


        *P797_pc_DestinationString = '\0';
        if ((L1278_pc_TildeCharacter = index(P798_pc_SourceString, '~')) != NULL) {
                strncpy(P797_pc_DestinationString, P798_pc_SourceString, L1279_ui_TildeCharacterPosition = L1278_pc_TildeCharacter - P798_pc_SourceString);
                P797_pc_DestinationString[L1279_ui_TildeCharacterPosition] = '\0';
                if (G567_B_SingleFloppyDrive || (P799_i_DriveType == C1_DRIVE_TYPE_GAME_DISK)) {
                        strcat(P797_pc_DestinationString, G571_pc_D116_DRIVEA);
                } else {
                        strcat(P797_pc_DestinationString, G572_pc_D117_DRIVEB);
                }
                strcat(P797_pc_DestinationString, L1278_pc_TildeCharacter + 1);
        }
}
#endif

BOOLEAN F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(P800_pc_Buffer, P801_i_ByteCount)
char* P800_pc_Buffer;
int P801_i_ByteCount;
{
        register unsigned long L1280_ul_ByteCount;


        if ((L1280_ul_ByteCount = P801_i_ByteCount) == 0) {
                return TRUE;
        }
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
        if (G530_B_LoadingCompressedDungeon) {
                if (L1280_ul_ByteCount > G532_l_DecompressedDungeonRemainingByteCount) {
                        return FALSE;
                }
                F007_aAA7_MAIN_CopyBytes(G531_puc_DecompressedDungeonCurrentPosition, P800_pc_Buffer, (int)L1280_ul_ByteCount);
                G531_puc_DecompressedDungeonCurrentPosition += L1280_ul_ByteCount;
                G532_l_DecompressedDungeonRemainingByteCount -= L1280_ul_ByteCount;
                return TRUE;
        }
#endif
        return (Fread(G521_i_GameFileHandle, (long)L1280_ul_ByteCount, P800_pc_Buffer) == L1280_ul_ByteCount);
}

BOOLEAN F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(P802_pc_Buffer, P803_i_ByteCount)
char* P802_pc_Buffer;
int P803_i_ByteCount;
{
        register unsigned long L1281_ul_ByteCount;


        if ((L1281_ul_ByteCount = P803_i_ByteCount) == 0) {
                return TRUE;
        }
        return (Fwrite(G521_i_GameFileHandle, (long)L1281_ul_ByteCount, P802_pc_Buffer) == L1281_ul_ByteCount);
}

/* Obfuscation and deobfuscation are the same reversible operation */
unsigned int F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(P804_pui_Buffer, P805_ui_Key, P806_i_WordCount)
register unsigned int* P804_pui_Buffer;
register unsigned int P805_ui_Key;
register int P806_i_WordCount;
{
        register unsigned int L1282_ui_Checksum;


        L1282_ui_Checksum = P805_ui_Key;
        do {
                L1282_ui_Checksum += *P804_pui_Buffer;
                *P804_pui_Buffer ^= P805_ui_Key;
                L1282_ui_Checksum += *P804_pui_Buffer++;
                P805_ui_Key += P806_i_WordCount;
        } while (--P806_i_WordCount);
        return L1282_ui_Checksum;
}

unsigned int F418_xxxx_SAVEUTIL_GetChecksum(P807_pui_Buffer, P808_ui_Key, P809_i_WordCount)
register unsigned int* P807_pui_Buffer;
register unsigned int P808_ui_Key;
register int P809_i_WordCount;
{
        register unsigned int L1283_ui_Checksum;


        L1283_ui_Checksum = P808_ui_Key;
        do {
                L1283_ui_Checksum += *P807_pui_Buffer;
                L1283_ui_Checksum += *P807_pui_Buffer++ ^ P808_ui_Key;
                P808_ui_Key += P809_i_WordCount;
        } while (--P809_i_WordCount);
        return L1283_ui_Checksum;
}

BOOLEAN F419_xxxx_SAVEUTIL_IsReadObfuscatedBytesAndValidateChecksumSuccessful(P810_pc_Buffer, P811_ui_ByteCount, P812_ui_Key, P813_ui_ExpectedChecksum)
char* P810_pc_Buffer;
unsigned int P811_ui_ByteCount;
unsigned int P812_ui_Key;
unsigned int P813_ui_ExpectedChecksum;
{
        return (F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(P810_pc_Buffer, P811_ui_ByteCount) && (P813_ui_ExpectedChecksum == F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(P810_pc_Buffer, P812_ui_Key, P811_ui_ByteCount >> 1)));
}

BOOLEAN F420_xxxx_SAVEUTIL_IsWriteObfuscatedSavePartSuccessful(P814_pc_Buffer, P815_ui_ByteCount, P816_i_Key, P817_pi_Checksum)
register char* P814_pc_Buffer;
unsigned int P815_ui_ByteCount;
int P816_i_Key;
int* P817_pi_Checksum;
{
        register BOOLEAN L1284_B_IsWriteObfuscatedBytesSuccessful;
        register int L1285_i_WordCount;


        *P817_pi_Checksum = F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(P814_pc_Buffer, P816_i_Key, L1285_i_WordCount = P815_ui_ByteCount >> 1); /* Obfuscate before writing */
        L1284_B_IsWriteObfuscatedBytesSuccessful = F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(P814_pc_Buffer, P815_ui_ByteCount);
        F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(P814_pc_Buffer, P816_i_Key, L1285_i_WordCount); /* Deobfuscate after writing */
        return L1284_B_IsWriteObfuscatedBytesSuccessful;
}

#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
BOOLEAN F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(P818_puc_Buffer, P819_pi_RunningChecksum, P820_i_ByteCount)
register unsigned char* P818_puc_Buffer;
register int* P819_pi_RunningChecksum;
register int P820_i_ByteCount;
{
        register int L1286_i_Checksum;


        L1286_i_Checksum = 0;
        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(P818_puc_Buffer, P820_i_ByteCount)) {
                return FALSE;
        }
        while (P820_i_ByteCount--) {
                L1286_i_Checksum += *P818_puc_Buffer++;
        }
        *P819_pi_RunningChecksum += L1286_i_Checksum;
        return TRUE;
}

BOOLEAN F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(P821_puc_Buffer, P822_pi_RunningChecksum, P823_i_ByteCount)
register unsigned char* P821_puc_Buffer;
register int* P822_pi_RunningChecksum;
register int P823_i_ByteCount;
{
        register int L1287_i_Checksum;


        L1287_i_Checksum = 0;
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(P821_puc_Buffer, P823_i_ByteCount)) {
                return FALSE;
        }
        while (P823_i_ByteCount--) {
                L1287_i_Checksum += *P821_puc_Buffer++;
        }
        *P822_pi_RunningChecksum += L1287_i_Checksum;
        return TRUE;
}
#endif

#ifdef C28_COMPILE_CSB21EN /* CHANGE8_12_FIX New function called right after loading a saved game to clean up cloned things caused by BUG0_12. It contains several loops to flag things that are referenced as square first things, things possessed by groups, things in chests (things are removed from chest if they are already referenced elsewhere), scroll texts and projectile associated things. It also removes things from champion slots and from the leader hand if they are already flagged as referenced elsewhere */
VOID F423_xxxx_SAVEUTIL_FixClonedThings()
{
        register int L1288_i_Multiple;
#define A1288_i_Counter    L1288_i_Multiple
#define A1288_i_ThingIndex L1288_i_Multiple
#define A1288_i_BitMask    L1288_i_Multiple
        register int L1289_i_Multiple;
#define A1289_i_ThingIndex    L1289_i_Multiple
#define A1289_i_BitMask       L1289_i_Multiple
#define A1289_i_ByteIndex     L1289_i_Multiple
#define A1289_i_ChampionIndex L1289_i_Multiple
        register THING L1290_T_Thing;
        register int L1291_i_Multiple;
#define A1291_i_ByteIndex  L1291_i_Multiple
#define A1291_i_ThingIndex L1291_i_Multiple
#define A1291_i_BitMask    L1291_i_Multiple
        register unsigned char* L1292_puc_Buffer;
        register char* L1293_pc_Address;
        int L1294_i_ByteOffset;
        long L1295_l_Unreferenced; /* BUG0_00 Useless code */
        THING L1296_T_PreviousThing;
        GENERIC* L1297_ps_Generic;
        static unsigned char G535_auc_BitIndexToMaskConversionTable[8] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };


        L1292_puc_Buffer = F468_ozzz_MEMORY_Allocate(2048L, C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP); /* 2048 bytes = 16384 bits = 1024 * 16 (one bit for each thing of each type)
        In the following loops, each bit is set if the corresponding thing is referenced in order to detect things that are referenced multiple times (clones) */
        F008_aA19_MAIN_ClearBytes(L1292_puc_Buffer, 2048);
        for(A1288_i_Counter = 0; A1288_i_Counter < G278_ps_DungeonHeader->SquareFirstThingCount; A1288_i_Counter++) {
                if ((L1290_T_Thing = G283_pT_SquareFirstThings[A1288_i_Counter]) != C0xFFFF_THING_NONE) {
                        do {
                                A1289_i_ThingIndex = M13_INDEX(L1290_T_Thing);
                                A1291_i_ByteIndex = (M12_TYPE(L1290_T_Thing) << 7) + (A1289_i_ThingIndex >> 3);
                                A1289_i_BitMask = G535_auc_BitIndexToMaskConversionTable[A1289_i_ThingIndex & 0x0007];
                                if (L1292_puc_Buffer[A1291_i_ByteIndex] & A1289_i_BitMask) {
                                        continue;
                                }
                                L1292_puc_Buffer[A1291_i_ByteIndex] |= A1289_i_BitMask;
                        } while ((L1290_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L1290_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
                }
        }
        L1293_pc_Address = (char*)G284_apuc_ThingData[C04_THING_TYPE_GROUP];
        A1288_i_Counter = 0;
        while (A1288_i_Counter < G278_ps_DungeonHeader->ThingCount[C04_THING_TYPE_GROUP]) {
                if ((((GROUP*)L1293_pc_Address)->Next != C0xFFFF_THING_NONE) && ((L1290_T_Thing = ((GROUP*)L1293_pc_Address)->Slot) != C0xFFFE_THING_ENDOFLIST)) { /* If group thing data is used and has possessions */
                        do {
                                A1289_i_ThingIndex = M13_INDEX(L1290_T_Thing);
                                A1291_i_ByteIndex = (M12_TYPE(L1290_T_Thing) << 7) + (A1289_i_ThingIndex >> 3);
                                A1289_i_BitMask = G535_auc_BitIndexToMaskConversionTable[A1289_i_ThingIndex & 0x0007];
                                if (L1292_puc_Buffer[A1291_i_ByteIndex] & A1289_i_BitMask) {
                                        continue;
                                }
                                L1292_puc_Buffer[A1291_i_ByteIndex] |= A1289_i_BitMask;
                        } while ((L1290_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L1290_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
                }
                L1293_pc_Address += sizeof(GROUP);
                A1288_i_Counter++;
        }
        L1293_pc_Address = (char*)G284_apuc_ThingData[C09_THING_TYPE_CONTAINER];
        A1288_i_Counter = 0;
        while (A1288_i_Counter < G278_ps_DungeonHeader->ThingCount[C09_THING_TYPE_CONTAINER]) {
                if ((((CONTAINER*)L1293_pc_Address)->Next != C0xFFFF_THING_NONE) && ((L1290_T_Thing = ((CONTAINER*)L1293_pc_Address)->Slot) != C0xFFFE_THING_ENDOFLIST)) { /* If container thing data is used and has possessions */
                        L1296_T_PreviousThing = C0xFFFF_THING_NONE;
                        do {
                                A1289_i_ThingIndex = M13_INDEX(L1290_T_Thing);
                                A1291_i_ByteIndex = (M12_TYPE(L1290_T_Thing) << 7) + (A1289_i_ThingIndex >> 3);
                                A1289_i_BitMask = G535_auc_BitIndexToMaskConversionTable[A1289_i_ThingIndex & 0x0007];
                                if (L1292_puc_Buffer[A1291_i_ByteIndex] & A1289_i_BitMask) { /* If the thing is a clone (already marked in L1292_puc_Buffer) then remove it from the chest */
                                        if (L1296_T_PreviousThing == C0xFFFF_THING_NONE) {
                                                ((CONTAINER*)L1293_pc_Address)->Slot = C0xFFFE_THING_ENDOFLIST;
                                        } else {
                                                L1297_ps_Generic = (GENERIC*)F156_afzz_DUNGEON_GetThingData(L1296_T_PreviousThing);
                                                L1297_ps_Generic->Next = C0xFFFE_THING_ENDOFLIST;
                                        }
                                        break;
                                }
                                L1292_puc_Buffer[A1291_i_ByteIndex] |= A1289_i_BitMask;
                                L1296_T_PreviousThing = L1290_T_Thing;
                        } while ((L1290_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L1290_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
                }
                L1293_pc_Address += sizeof(CONTAINER);
                A1288_i_Counter++;
        }
        L1293_pc_Address = (char*)G284_apuc_ThingData[C07_THING_TYPE_SCROLL];
        A1288_i_Counter = 0;
        while (A1288_i_Counter < G278_ps_DungeonHeader->ThingCount[C07_THING_TYPE_SCROLL]) {
                if (((SCROLL*)L1293_pc_Address)->Next != C0xFFFF_THING_NONE) {
                        A1289_i_ThingIndex = ((SCROLL*)L1293_pc_Address)->TextThingIndex;
                        A1291_i_ByteIndex = (C02_THING_TYPE_TEXT << 7) + (A1289_i_ThingIndex >> 3);
                        A1289_i_BitMask = G535_auc_BitIndexToMaskConversionTable[A1289_i_ThingIndex & 0x0007];
                        if (L1292_puc_Buffer[A1291_i_ByteIndex] & A1289_i_BitMask) {
                                goto T423_022;
                        }
                        L1292_puc_Buffer[A1291_i_ByteIndex] |= A1289_i_BitMask;
                }
                T423_022:
                L1293_pc_Address += sizeof(SCROLL);
                A1288_i_Counter++;
        }
        L1293_pc_Address = (char*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE];
        A1288_i_Counter = 0;
        while (A1288_i_Counter < G278_ps_DungeonHeader->ThingCount[C14_THING_TYPE_PROJECTILE]) {
                if (((PROJECTILE*)L1293_pc_Address)->Next != C0xFFFF_THING_NONE) {
                        if ((L1290_T_Thing = ((PROJECTILE*)L1293_pc_Address)->Slot) == C0xFFFE_THING_ENDOFLIST) {
                                goto T423_028;
                        }
                        if (L1290_T_Thing == C0xFFFF_THING_NONE) {
                                goto T423_028;
                        }
                        if (M12_TYPE(L1290_T_Thing) != C15_THING_TYPE_EXPLOSION) {
                                A1289_i_ThingIndex = M13_INDEX(L1290_T_Thing);
                                A1291_i_ByteIndex = (M12_TYPE(L1290_T_Thing) << 7) + (A1289_i_ThingIndex >> 3);
                                A1289_i_BitMask = G535_auc_BitIndexToMaskConversionTable[A1289_i_ThingIndex & 0x0007];
                                if (L1292_puc_Buffer[A1291_i_ByteIndex] & A1289_i_BitMask) {
                                        goto T423_028;
                                }
                                L1292_puc_Buffer[A1291_i_ByteIndex] |= A1289_i_BitMask;
                        }
                }
                T423_028:
                L1293_pc_Address += sizeof(PROJECTILE);
                A1288_i_Counter++;
        }
        for(A1289_i_ChampionIndex = C00_CHAMPION_FIRST; A1289_i_ChampionIndex < G305_ui_PartyChampionCount; A1289_i_ChampionIndex++) {
                L1293_pc_Address = (char*)G407_s_Party.Champions[A1289_i_ChampionIndex].Slots;
                for(A1288_i_Counter = C00_SLOT_READY_HAND; A1288_i_Counter < C30_SLOT_CHEST_1; A1288_i_Counter++) {
                        L1290_T_Thing = ((THING*)L1293_pc_Address)[A1288_i_Counter];
                        if (L1290_T_Thing != C0xFFFF_THING_NONE) {
                                A1291_i_ThingIndex = M13_INDEX(L1290_T_Thing);
                                L1294_i_ByteOffset = (M12_TYPE(L1290_T_Thing) << 7) + (A1291_i_ThingIndex >> 3);
                                A1291_i_BitMask = G535_auc_BitIndexToMaskConversionTable[A1291_i_ThingIndex & 0x0007];
                                if (L1292_puc_Buffer[L1294_i_ByteOffset] & A1291_i_BitMask) { /* If the thing is a clone (already marked in L1292_puc_Buffer) then remove it from the champion slot */
                                        ((THING*)L1293_pc_Address)[A1288_i_Counter] = C0xFFFF_THING_NONE;
                                        continue;
                                }
                                L1292_puc_Buffer[L1294_i_ByteOffset] |= A1291_i_BitMask;
                        }
                }
        }
        if ((L1290_T_Thing = G414_T_LeaderHandObject) != C0xFFFF_THING_NONE) {
                A1288_i_ThingIndex = M13_INDEX(L1290_T_Thing);
                A1289_i_ByteIndex = (M12_TYPE(L1290_T_Thing) << 7) + (A1288_i_ThingIndex >> 3);
                A1288_i_BitMask = G535_auc_BitIndexToMaskConversionTable[A1288_i_ThingIndex & 0x0007];
                if (L1292_puc_Buffer[A1289_i_ByteIndex] & A1288_i_BitMask) { /* If the thing is a clone (already marked in L1292_puc_Buffer) then remove it from the leader hand */
                        G414_T_LeaderHandObject = C0xFFFF_THING_NONE;
                } else {
                        L1292_puc_Buffer[A1289_i_ByteIndex] |= A1288_i_BitMask;
                }
        }
        F469_rzzz_MEMORY_FreeAtHeapTop(2048L);
}
#endif
