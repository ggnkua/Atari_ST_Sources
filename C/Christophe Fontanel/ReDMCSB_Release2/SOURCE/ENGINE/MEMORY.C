#include "DEFS.H"

/*_Global variables_*/
int G630_i_GraphicsDatFileHandle;
int G631_i_GraphicsDatFileReferenceCount;
unsigned int G632_ui_GraphicCount;
long G633_l_GraphicsDatFileSize;
unsigned int* G634_pui_GraphicCompressedByteCount;
unsigned int* G635_pui_GraphicDecompressedByteCount;
unsigned char** G636_ppuc_Graphics;
int* G637_pi_NativeBitmapBlockIndices;
int* G638_pi_DerivedBitmapBlockIndices;
int* G639_pi_DerivedBitmapByteCount;
int G640_i_FloppyDiskReadBufferGraphicsDatChunkIndex = -1;
unsigned char* G641_puc_CacheMemoryBottom;
unsigned char* G642_puc_GraphicMemoryBottom;
unsigned char* G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF;
#ifndef NOCOPYPROTECTION
int G644_i_FloppyDiskReadBufferContentType_COPYPROTECTIONDF;
#endif
unsigned char* G645_puc_HeapMemoryTop;
unsigned char* G646_puc_AvailableHeapMemoryTop;
long G647_l_Unreferenced; /* BUG0_00 Useless code */
long G648_l_AvailableHeapMemoryByteCount;
unsigned char* G649_puc_GraphicMemoryTop;
unsigned char* G650_puc_GraphicMemoryBottomTemp;
unsigned char* G651_puc_CacheMemoryTop;
unsigned char* G652_puc_AvailableGEMMemoryBottom;
long G653_l_AvailableGEMMemoryByteCount;
BOOLEAN G654_B_GraphicMemoryInitialized;
unsigned char** G655_ppuc_Blocks;
long G656_l_AvailableCacheMemoryByteCount;
unsigned char* G657_puc_FirstUnusedBlock;
unsigned char* G658_puc_FirstUsedBlock;
unsigned char* G659_puc_LastUsedBlock;
unsigned char* G660_puc_FirstReferencedUsedBlock;
BOOLEAN G661_B_LargeHeapMemory;
long G662_l_LastResetCacheUsageCountsTime;


overlay "memory"

long F467_xxxx_MEMORY_GetGraphicOffset(P875_ui_GraphicIndex)
register unsigned int P875_ui_GraphicIndex;
{
        register long L1479_l_Offset;
        register unsigned int L1480_ui_GraphicIndex;


        L1479_l_Offset = 2 + (G632_ui_GraphicCount << 2);
        for(L1480_ui_GraphicIndex = 0; L1480_ui_GraphicIndex < P875_ui_GraphicIndex; L1480_ui_GraphicIndex++) {
                L1479_l_Offset += G634_pui_GraphicCompressedByteCount[L1480_ui_GraphicIndex];
        }
        return L1479_l_Offset;
}

unsigned char* F468_ozzz_MEMORY_Allocate(P876_l_ByteCount, P877_i_AllocationType)
register long P876_l_ByteCount;
int P877_i_AllocationType;
{
        register unsigned char* L1481_puc_Buffer;


        if (P876_l_ByteCount & 0x00000001) { /* Make sure size is even */
                P876_l_ByteCount++;
        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_30_IMPROVEMENT */
        if (P877_i_AllocationType && (G653_l_AvailableGEMMemoryByteCount >= P876_l_ByteCount)) {
                G653_l_AvailableGEMMemoryByteCount -= P876_l_ByteCount;
                L1481_puc_Buffer = G652_puc_AvailableGEMMemoryBottom;
                G652_puc_AvailableGEMMemoryBottom += P876_l_ByteCount;
                return L1481_puc_Buffer;
        }
        if (P876_l_ByteCount > G648_l_AvailableHeapMemoryByteCount) {
                F019_aarz_MAIN_DisplayErrorAndStop(C40_ERROR_OUT_OF_MEMORY);
        }
        G648_l_AvailableHeapMemoryByteCount -= P876_l_ByteCount;
        return (G646_puc_AvailableHeapMemoryTop -= P876_l_ByteCount);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
        if ((P877_i_AllocationType == C1_ALLOCATION_PERMANENT) && (G653_l_AvailableGEMMemoryByteCount >= P876_l_ByteCount)) {
                G653_l_AvailableGEMMemoryByteCount -= P876_l_ByteCount;
                L1481_puc_Buffer = G652_puc_AvailableGEMMemoryBottom;
                G652_puc_AvailableGEMMemoryBottom += P876_l_ByteCount;
        } else {
                if (P876_l_ByteCount > G648_l_AvailableHeapMemoryByteCount) {
                        F019_aarz_MAIN_DisplayErrorAndStop(C40_ERROR_OUT_OF_MEMORY);
                }
                if (P877_i_AllocationType == C2_ALLOCATION_TEMPORARY_ON_BOTTOM_OF_HEAP) {
                        L1481_puc_Buffer = G646_puc_AvailableHeapMemoryTop - G648_l_AvailableHeapMemoryByteCount;
                } else {
                        L1481_puc_Buffer = G646_puc_AvailableHeapMemoryTop = G646_puc_AvailableHeapMemoryTop - P876_l_ByteCount;
                }
                G648_l_AvailableHeapMemoryByteCount -= P876_l_ByteCount;
        }
        return L1481_puc_Buffer;
#endif
}

VOID F469_rzzz_MEMORY_FreeAtHeapTop(P878_l_ByteCount)
register long P878_l_ByteCount;
{
        if (P878_l_ByteCount & 0x00000001) { /* Make sure size is even */
                P878_l_ByteCount++;
        }
        G648_l_AvailableHeapMemoryByteCount += P878_l_ByteCount;
        G646_puc_AvailableHeapMemoryTop += P878_l_ByteCount;
}

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
VOID F470_xzzz_MEMORY_FreeAtHeapBottom(P879_l_ByteCount)
register long P879_l_ByteCount;
{
        if (P879_l_ByteCount & 0x00000001) { /* Make sure size is even */
                P879_l_ByteCount++;
        }
        G648_l_AvailableHeapMemoryByteCount += P879_l_ByteCount;
}
#endif

VOID F471_xxxx_CACHE_RemoveUnusedBlock(P880_puc_Block)
register unsigned char* P880_puc_Block;
{
        register unsigned char* L1482_puc_PreviousUnusedBlock;
        unsigned char* L1483_puc_NextUnusedBlock;


        L1482_puc_PreviousUnusedBlock = M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(P880_puc_Block);
        L1483_puc_NextUnusedBlock = M87_UNUSED_BLOCK_NEXT_ADDRESS(P880_puc_Block);
        if (L1482_puc_PreviousUnusedBlock == NULL) {
                if (L1483_puc_NextUnusedBlock == NULL) {
                        G657_puc_FirstUnusedBlock = NULL;
                } else {
                        G657_puc_FirstUnusedBlock = L1483_puc_NextUnusedBlock;
                        M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(L1483_puc_NextUnusedBlock) = NULL;
                }
        } else {
                M87_UNUSED_BLOCK_NEXT_ADDRESS(L1482_puc_PreviousUnusedBlock) = L1483_puc_NextUnusedBlock;
                if (L1483_puc_NextUnusedBlock != NULL) {
                        M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(L1483_puc_NextUnusedBlock) = L1482_puc_PreviousUnusedBlock;
                }
        }
}

VOID F472_xxxx_CACHE_AddUnusedBlock(P881_puc_Block) /* The linked list of unused blocks is sorted from largest to smallest block size */
unsigned char* P881_puc_Block;
{
        register long L1484_l_BlockSize;
        register BOOLEAN L1485_B_BlockAddedToUnusedList;
        register unsigned char* L1486_puc_FirstUnusedBlock;
        register unsigned char* L1487_puc_UnusedBlock;
        long L1488_l_Unreferenced; /* BUG0_00 Useless code */


        L1487_puc_UnusedBlock = P881_puc_Block;
        if (G657_puc_FirstUnusedBlock == NULL) { /* Add the block as the only one in the list */
                G657_puc_FirstUnusedBlock = L1487_puc_UnusedBlock;
                M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(L1487_puc_UnusedBlock) = M87_UNUSED_BLOCK_NEXT_ADDRESS(L1487_puc_UnusedBlock) = NULL;
        } else {
                L1486_puc_FirstUnusedBlock = G657_puc_FirstUnusedBlock;
                L1484_l_BlockSize = M80_BLOCK_SIZE(L1487_puc_UnusedBlock);
                if (L1484_l_BlockSize >= M80_BLOCK_SIZE(L1486_puc_FirstUnusedBlock)) { /* Add the block as the first in the list */
                        G657_puc_FirstUnusedBlock = L1487_puc_UnusedBlock;
                        M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(L1487_puc_UnusedBlock) = NULL;
                        M87_UNUSED_BLOCK_NEXT_ADDRESS(L1487_puc_UnusedBlock) = L1486_puc_FirstUnusedBlock;
                        M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(L1486_puc_FirstUnusedBlock) = L1487_puc_UnusedBlock;
                } else {
                        L1485_B_BlockAddedToUnusedList = FALSE;
                        while (L1487_puc_UnusedBlock = M87_UNUSED_BLOCK_NEXT_ADDRESS(L1486_puc_FirstUnusedBlock)) {
                                if (L1484_l_BlockSize >= M80_BLOCK_SIZE(L1487_puc_UnusedBlock)) { /* Add the block in the middle of the list */
                                        M87_UNUSED_BLOCK_NEXT_ADDRESS(L1486_puc_FirstUnusedBlock) = M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(L1487_puc_UnusedBlock) = P881_puc_Block;
                                        M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(P881_puc_Block) = L1486_puc_FirstUnusedBlock;
                                        M87_UNUSED_BLOCK_NEXT_ADDRESS(P881_puc_Block) = L1487_puc_UnusedBlock;
                                        L1485_B_BlockAddedToUnusedList = TRUE;
                                        break;
                                }
                                L1486_puc_FirstUnusedBlock = L1487_puc_UnusedBlock;
                        }
                        if (!L1485_B_BlockAddedToUnusedList) { /* Add the block as the last in the list */
                                M87_UNUSED_BLOCK_NEXT_ADDRESS(L1486_puc_FirstUnusedBlock) = P881_puc_Block;
                                M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(P881_puc_Block) = L1486_puc_FirstUnusedBlock;
                                M87_UNUSED_BLOCK_NEXT_ADDRESS(P881_puc_Block) = NULL;
                        }
                }
        }
}

VOID F473_xxxx_MEMORY_SortValues(P882_pui_Values, P883_ui_ValueCount) /* Sorts the values in the specified array from smallest to largest */
register unsigned int* P882_pui_Values;
unsigned int P883_ui_ValueCount;
{
        register int L1489_i_Index;
        register unsigned int L1490_ui_Counter;
        register int L1491_i_Index;
        register unsigned int L1492_ui_Value;
        int L1493_i_Counter;
        int L1494_i_IterationCount;
        unsigned int L1495_ui_Counter;
        unsigned int L1496_ui_IterationCount;


        L1494_i_IterationCount = 0;
        L1493_i_Counter = P883_ui_ValueCount;
        while (L1493_i_Counter >>= 1) {
                L1494_i_IterationCount++;
        }
        for(L1493_i_Counter = L1494_i_IterationCount - 1; L1493_i_Counter >= 0; L1493_i_Counter--) {
                L1496_ui_IterationCount = (L1495_ui_Counter = (1 << L1493_i_Counter) - 1) << 1;
                for(L1490_ui_Counter = L1495_ui_Counter; L1490_ui_Counter <= L1496_ui_IterationCount; L1490_ui_Counter++) {
                        L1492_ui_Value = P882_pui_Values[L1489_i_Index = L1490_ui_Counter];
                        do {
                                if ((L1491_i_Index = (L1489_i_Index << 1) + 1) >= P883_ui_ValueCount) {
                                        break;
                                }
                                if (((L1491_i_Index + 1) < P883_ui_ValueCount) && (P882_pui_Values[L1491_i_Index + 1] >= P882_pui_Values[L1491_i_Index])) {
                                        L1491_i_Index++;
                                }
                                if (L1492_ui_Value < P882_pui_Values[L1491_i_Index]) {
                                        P882_pui_Values[L1489_i_Index] = P882_pui_Values[L1491_i_Index];
                                        L1489_i_Index = L1491_i_Index;
                                } else {
                                        break;
                                }
                        } while ();
                        P882_pui_Values[L1489_i_Index] = L1492_ui_Value;
                }
        }
        for(L1495_ui_Counter = P883_ui_ValueCount - 1; L1495_ui_Counter >= 1; L1495_ui_Counter--) {
                L1492_ui_Value = P882_pui_Values[L1495_ui_Counter];
                P882_pui_Values[L1495_ui_Counter] = P882_pui_Values[L1489_i_Index = 0];
                do {
                        if ((L1491_i_Index = (L1489_i_Index << 1) + 1) > (L1495_ui_Counter - 1)) {
                                break;
                        }
                        if (((L1491_i_Index + 1) < L1495_ui_Counter) && (P882_pui_Values[L1491_i_Index + 1] >= P882_pui_Values[L1491_i_Index])) {
                                L1491_i_Index++;
                        }
                        if (L1492_ui_Value < P882_pui_Values[L1491_i_Index]) {
                                P882_pui_Values[L1489_i_Index] = P882_pui_Values[L1491_i_Index];
                                L1489_i_Index = L1491_i_Index;
                        } else {
                                break;
                        }
                } while ();
                P882_pui_Values[L1489_i_Index] = L1492_ui_Value;
        }
}

VOID F474_xxxx_MEMORY_LoadGraphic_COPYPROTECTIONDF(P884_i_GraphicIndex, P885_puc_Graphic)
int P884_i_GraphicIndex;
unsigned char* P885_puc_Graphic;
{
        register long L1497_l_Offset;
        register long L1498_l_ReadFromOffset;
        register int L1499_i_RemainingByteCount;
        register int L1500_i_StartOffsetInBuffer;
        int L1501_i_GraphicsDatChunkIndex;
        int L1502_i_BufferByteCount;
        long L1503_l_FreadByteCount;


#ifndef NOCOPYPROTECTION
        while (G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF);
#endif
        L1497_l_Offset = F467_xxxx_MEMORY_GetGraphicOffset(P884_i_GraphicIndex);
        L1499_i_RemainingByteCount = G634_pui_GraphicCompressedByteCount[P884_i_GraphicIndex];
        L1501_i_GraphicsDatChunkIndex = L1497_l_Offset >> 10;
        L1498_l_ReadFromOffset = (long)L1501_i_GraphicsDatChunkIndex << 10;
        while (L1499_i_RemainingByteCount > 0) {
                if ((L1501_i_GraphicsDatChunkIndex != G640_i_FloppyDiskReadBufferGraphicsDatChunkIndex)
#ifndef NOCOPYPROTECTION
                || G644_i_FloppyDiskReadBufferContentType_COPYPROTECTIONDF
#endif
                ) {
                        G640_i_FloppyDiskReadBufferGraphicsDatChunkIndex = L1501_i_GraphicsDatChunkIndex;
                        if ((L1503_l_FreadByteCount = G633_l_GraphicsDatFileSize - L1498_l_ReadFromOffset) > 1024) {
                                L1503_l_FreadByteCount = 1024;
                        }
                        Fseek(L1498_l_ReadFromOffset, G630_i_GraphicsDatFileHandle, C0_SEEK_FROM_BEGINNING_OF_FILE) >= 0; /* Result of fseek is ignored */
                        Fread(G630_i_GraphicsDatFileHandle, (long)L1503_l_FreadByteCount, G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF) == (long)L1503_l_FreadByteCount; /* Result of fread is ignored */
#ifndef NOCOPYPROTECTION
                        G644_i_FloppyDiskReadBufferContentType_COPYPROTECTIONDF = MASK0x0000_BUFFER_CONTAINS_GRAPHIC_DATA;
#endif
                }
                L1500_i_StartOffsetInBuffer = L1497_l_Offset - L1498_l_ReadFromOffset;
                L1502_i_BufferByteCount = F024_aatz_MAIN_GetMinimumValue(L1499_i_RemainingByteCount, 1024 - L1500_i_StartOffsetInBuffer);
                F007_aAA7_MAIN_CopyBytes(G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF + L1500_i_StartOffsetInBuffer, P885_puc_Graphic, L1502_i_BufferByteCount);
                L1499_i_RemainingByteCount -= L1502_i_BufferByteCount;
                L1497_l_Offset += L1502_i_BufferByteCount;
                P885_puc_Graphic += L1502_i_BufferByteCount;
                L1501_i_GraphicsDatChunkIndex++;
                L1498_l_ReadFromOffset += 1024;
        }
}

VOID F475_ozzz_MEMORY_Initialize(P886_puc_HeapMemoryBottom, P887_l_AvailableHeapMemoryByteCount, P888_puc_AvailableGEMMemoryBottom, P889_l_AvailableGEMMemoryByteCount)
register unsigned char* P886_puc_HeapMemoryBottom;
register long P887_l_AvailableHeapMemoryByteCount;
unsigned char* P888_puc_AvailableGEMMemoryBottom;
long P889_l_AvailableGEMMemoryByteCount;
{
        G641_puc_CacheMemoryBottom = G651_puc_CacheMemoryTop = P886_puc_HeapMemoryBottom;
        G646_puc_AvailableHeapMemoryTop = G645_puc_HeapMemoryTop = P886_puc_HeapMemoryBottom + P887_l_AvailableHeapMemoryByteCount;
        G648_l_AvailableHeapMemoryByteCount = P887_l_AvailableHeapMemoryByteCount;
        G652_puc_AvailableGEMMemoryBottom = P888_puc_AvailableGEMMemoryBottom;
        G653_l_AvailableGEMMemoryByteCount = P889_l_AvailableGEMMemoryByteCount;
        G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF = (unsigned char*)F468_ozzz_MEMORY_Allocate(1024L, C1_ALLOCATION_PERMANENT);
        G655_ppuc_Blocks = (unsigned char**)F468_ozzz_MEMORY_Allocate((long)((C563_GRAPHIC_COUNT + C712_DERIVED_BITMAP_ACTUAL_COUNT) * sizeof(unsigned char*)), C1_ALLOCATION_PERMANENT);
        F008_aA19_MAIN_ClearBytes(G655_ppuc_Blocks, (C563_GRAPHIC_COUNT + C712_DERIVED_BITMAP_ACTUAL_COUNT) * sizeof(unsigned char*));
        G638_pi_DerivedBitmapBlockIndices = (int*)F468_ozzz_MEMORY_Allocate((long)(C730_DERIVED_BITMAP_MAXIMUM_COUNT * sizeof(int)), C1_ALLOCATION_PERMANENT);
        F010_aAA7_MAIN_WriteSpacedWords(G638_pi_DerivedBitmapBlockIndices, C730_DERIVED_BITMAP_MAXIMUM_COUNT, -1, sizeof(int));
        G639_pi_DerivedBitmapByteCount = (int*)F468_ozzz_MEMORY_Allocate((long)(C730_DERIVED_BITMAP_MAXIMUM_COUNT * sizeof(int)), C1_ALLOCATION_PERMANENT);
        G658_puc_FirstUsedBlock = G659_puc_LastUsedBlock = G660_puc_FirstReferencedUsedBlock = G657_puc_FirstUnusedBlock = NULL;
        G662_l_LastResetCacheUsageCountsTime = -1;
}

VOID F476_mzzz_MEMORY_InitializeGraphicMemory()
{
        if (G661_B_LargeHeapMemory = ((long)G646_puc_AvailableHeapMemoryTop - (long)G641_puc_CacheMemoryBottom) > 370000) {
                F461_AA08_START_AllocateFlippedWallBitmaps();
        }
        G642_puc_GraphicMemoryBottom = G646_puc_AvailableHeapMemoryTop - 10000;
        G654_B_GraphicMemoryInitialized = TRUE;
        G649_puc_GraphicMemoryTop = G650_puc_GraphicMemoryBottomTemp = G642_puc_GraphicMemoryBottom;
        G648_l_AvailableHeapMemoryByteCount = 10000;
        G656_l_AvailableCacheMemoryByteCount = (long)G642_puc_GraphicMemoryBottom - (long)G641_puc_CacheMemoryBottom;
}

VOID F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF()
{
#ifndef NOCOPYPROTECTION
        while (G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF);
#endif
        if (G631_i_GraphicsDatFileReferenceCount++) {
                return;
        }
        G630_i_GraphicsDatFileHandle = Fopen("A:\\GRAPHICS.DAT", C0_READ_ONLY);
        if (G630_i_GraphicsDatFileHandle < 0) {
                F019_aarz_MAIN_DisplayErrorAndStop(C41_ERROR_UNABLE_TO_OPEN_GRAPHICS_DAT);
        }
}

VOID F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF()
{
        if (--G631_i_GraphicsDatFileReferenceCount) {
                return;
        }
#ifndef NOCOPYPROTECTION
        while (G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF);
#endif
        Fclose(G630_i_GraphicsDatFileHandle);
}

VOID F479_izzz_MEMORY_ReadGraphicsDatHeader()
{
        register BOOLEAN L1504_B_AllocationSuccessful;
        register unsigned int L1505_ui_Multiple;
#define A1505_ui_ByteCount    L1505_ui_Multiple
#define A1505_ui_GraphicIndex L1505_ui_Multiple


        G631_i_GraphicsDatFileReferenceCount = 0;
        F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
        L1504_B_AllocationSuccessful = ((Fread(G630_i_GraphicsDatFileHandle, (long)sizeof(G632_ui_GraphicCount), &G632_ui_GraphicCount) == sizeof(G632_ui_GraphicCount)) &&
                                        (A1505_ui_ByteCount = G632_ui_GraphicCount << 1) &&
                                        ((G634_pui_GraphicCompressedByteCount = (unsigned int*)F468_ozzz_MEMORY_Allocate((long)A1505_ui_ByteCount, C1_ALLOCATION_PERMANENT)) != NULL) &&
                                        ((G635_pui_GraphicDecompressedByteCount = (unsigned int*)F468_ozzz_MEMORY_Allocate((long)A1505_ui_ByteCount, C1_ALLOCATION_PERMANENT)) != NULL) &&
                                        (Fread(G630_i_GraphicsDatFileHandle, (long)A1505_ui_ByteCount, G634_pui_GraphicCompressedByteCount) == A1505_ui_ByteCount) &&
                                        (Fread(G630_i_GraphicsDatFileHandle, (long)A1505_ui_ByteCount, G635_pui_GraphicDecompressedByteCount) == A1505_ui_ByteCount) &&
                                        ((G636_ppuc_Graphics = (unsigned char**)F468_ozzz_MEMORY_Allocate((long)(A1505_ui_ByteCount << 1), C1_ALLOCATION_PERMANENT)) != NULL) &&
                                        ((G637_pi_NativeBitmapBlockIndices = (int*)F468_ozzz_MEMORY_Allocate((long)A1505_ui_ByteCount, C1_ALLOCATION_PERMANENT)) != NULL));
        if (!L1504_B_AllocationSuccessful) {
        } else {
                F008_aA19_MAIN_ClearBytes(G636_ppuc_Graphics, A1505_ui_ByteCount << 1);
                F010_aAA7_MAIN_WriteSpacedWords(G637_pi_NativeBitmapBlockIndices, A1505_ui_ByteCount >>= 1, -1, sizeof(int));
                A1505_ui_GraphicIndex--;
                G633_l_GraphicsDatFileSize = F467_xxxx_MEMORY_GetGraphicOffset(A1505_ui_GraphicIndex) + G634_pui_GraphicCompressedByteCount[A1505_ui_GraphicIndex];
                if ((G343_puc_Graphic_DialogBox = (unsigned char*)F468_ozzz_MEMORY_Allocate((long)G635_pui_GraphicDecompressedByteCount[C000_GRAPHIC_DIALOG_BOX], C1_ALLOCATION_PERMANENT)) == NULL) {
                } else {
                        F474_xxxx_MEMORY_LoadGraphic_COPYPROTECTIONDF(C000_GRAPHIC_DIALOG_BOX, G343_puc_Graphic_DialogBox);
                        return;
                }
        }
        F019_aarz_MAIN_DisplayErrorAndStop(C42_ERROR_UNABLE_TO_LOAD_GRAPHICS_DAT_HEADER);
}

VOID F480_AA07_CACHE_ReleaseBlock(P890_i_BitmapIndex)
int P890_i_BitmapIndex;
{
        register long L1506_l_Size;
        register long L1507_l_PreviousBlockSize;
        register int L1508_i_BlockIndex;
        register int L1509_i_NextBlockIndex;
        register unsigned char* L1510_puc_BlockToRelease;
        register unsigned char* L1511_puc_Block;


        if (P890_i_BitmapIndex >= 0) {
                if ((L1508_i_BlockIndex = G637_pi_NativeBitmapBlockIndices[P890_i_BitmapIndex]) == -1) {
                        return;
                }
                G637_pi_NativeBitmapBlockIndices[P890_i_BitmapIndex] = -1;
        } else {
                M09_CLEAR(P890_i_BitmapIndex, MASK0x8000_DERIVED_BITMAP);
                if ((L1508_i_BlockIndex = G638_pi_DerivedBitmapBlockIndices[P890_i_BitmapIndex]) == -1) {
                        return;
                }
                G638_pi_DerivedBitmapBlockIndices[P890_i_BitmapIndex] = -1;
        }
        L1510_puc_BlockToRelease = G655_ppuc_Blocks[L1508_i_BlockIndex];
        G655_ppuc_Blocks[L1508_i_BlockIndex] = NULL;
        L1506_l_Size = -M80_BLOCK_SIZE(L1510_puc_BlockToRelease);
        G656_l_AvailableCacheMemoryByteCount += L1506_l_Size;
        L1508_i_BlockIndex = M82_USED_BLOCK_PREVIOUS_INDEX(L1510_puc_BlockToRelease);
        L1509_i_NextBlockIndex = M83_USED_BLOCK_NEXT_INDEX(L1510_puc_BlockToRelease);
        if (L1508_i_BlockIndex == -1) {
                if (L1509_i_NextBlockIndex == -1) {
                        G658_puc_FirstUsedBlock = NULL;
                        G659_puc_LastUsedBlock = NULL;
                        G660_puc_FirstReferencedUsedBlock = NULL;
                } else {
                        G658_puc_FirstUsedBlock = G655_ppuc_Blocks[L1509_i_NextBlockIndex];
                        M82_USED_BLOCK_PREVIOUS_INDEX(G658_puc_FirstUsedBlock) = -1;
                        if (G660_puc_FirstReferencedUsedBlock == L1510_puc_BlockToRelease) {
                                G660_puc_FirstReferencedUsedBlock = G658_puc_FirstUsedBlock;
                        }
                }
        } else {
                L1511_puc_Block = G655_ppuc_Blocks[L1508_i_BlockIndex];
                M83_USED_BLOCK_NEXT_INDEX(L1511_puc_Block) = L1509_i_NextBlockIndex;
                if (L1509_i_NextBlockIndex == -1) {
                        G659_puc_LastUsedBlock = L1511_puc_Block;
                        if (G660_puc_FirstReferencedUsedBlock == L1510_puc_BlockToRelease) {
                                G660_puc_FirstReferencedUsedBlock = NULL;
                        }
                } else {
                        L1511_puc_Block = G655_ppuc_Blocks[L1509_i_NextBlockIndex];
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1511_puc_Block) = L1508_i_BlockIndex;
                        if (G660_puc_FirstReferencedUsedBlock == L1510_puc_BlockToRelease) {
                                G660_puc_FirstReferencedUsedBlock = L1511_puc_Block;
                        }
                }
        }
        if ((L1510_puc_BlockToRelease != G641_puc_CacheMemoryBottom) && ((L1507_l_PreviousBlockSize = M79_PREVIOUS_BLOCK_SIZE(L1510_puc_BlockToRelease)) > 0)) {
                L1510_puc_BlockToRelease -= L1507_l_PreviousBlockSize;
                F471_xxxx_CACHE_RemoveUnusedBlock(L1510_puc_BlockToRelease);
                L1506_l_Size += L1507_l_PreviousBlockSize;
        }
        if ((L1510_puc_BlockToRelease + L1506_l_Size) == G651_puc_CacheMemoryTop) {
                G651_puc_CacheMemoryTop = L1510_puc_BlockToRelease;
                return;
        }
        if ((L1507_l_PreviousBlockSize = M80_BLOCK_SIZE(L1511_puc_Block = L1510_puc_BlockToRelease + L1506_l_Size)) > 0) {
                F471_xxxx_CACHE_RemoveUnusedBlock(L1511_puc_Block);
                L1506_l_Size += L1507_l_PreviousBlockSize;
        }
        M80_BLOCK_SIZE(L1510_puc_BlockToRelease) = L1506_l_Size;
        M79_PREVIOUS_BLOCK_SIZE(L1510_puc_BlockToRelease + L1506_l_Size) = L1506_l_Size;
        F472_xxxx_CACHE_AddUnusedBlock(L1510_puc_BlockToRelease);
}

VOID F481_xxxx_CACHE_FreeMemory(P891_l_ByteCount)
long P891_l_ByteCount;
{
        while (G656_l_AvailableCacheMemoryByteCount < P891_l_ByteCount) {
                if (G658_puc_FirstUsedBlock == NULL) {
                        F019_aarz_MAIN_DisplayErrorAndStop(C43_ERROR_NOT_ENOUGH_MEMORY_TO_ALLOCATE_BLOCK);
                }
                F480_AA07_CACHE_ReleaseBlock(M84_USED_BLOCK_BITMAP_INDEX(G658_puc_FirstUsedBlock));
        }
}

VOID F482_xxxx_CACHE_Defragment() /* Compact used blocks and remove all unused blocks */
{
        register long L1512_l_BlockSize;
        register int L1513_i_BitmapIndex;
        register int L1514_i_BlockIndex;
        register unsigned char* L1515_puc_UnusedBlock;
        register unsigned char* L1516_puc_UsedBlockToMove;


        if (G657_puc_FirstUnusedBlock == NULL) {
                return;
        }
        L1515_puc_UnusedBlock = L1516_puc_UsedBlockToMove = G641_puc_CacheMemoryBottom;
        do {
                if ((L1512_l_BlockSize = M80_BLOCK_SIZE(L1516_puc_UsedBlockToMove)) > 0) { /* If block is unused */
                        L1516_puc_UsedBlockToMove += L1512_l_BlockSize;
                } else {
                        L1512_l_BlockSize = -L1512_l_BlockSize; /* Get size of used block */
                        if (L1516_puc_UsedBlockToMove != L1515_puc_UnusedBlock) {
                                L1513_i_BitmapIndex = M84_USED_BLOCK_BITMAP_INDEX(L1516_puc_UsedBlockToMove);
                                if (L1513_i_BitmapIndex >= 0) {
                                        L1514_i_BlockIndex = G637_pi_NativeBitmapBlockIndices[L1513_i_BitmapIndex];
                                } else {
                                        L1514_i_BlockIndex = G638_pi_DerivedBitmapBlockIndices[M07_GET(L1513_i_BitmapIndex, MASK0x7FFF_GRAPHIC_INDEX)];
                                }
                                G655_ppuc_Blocks[L1514_i_BlockIndex] = L1515_puc_UnusedBlock;
                                F007_aAA7_MAIN_CopyBytes(L1516_puc_UsedBlockToMove, L1515_puc_UnusedBlock, (int)L1512_l_BlockSize);
                                if (G658_puc_FirstUsedBlock == L1516_puc_UsedBlockToMove) {
                                        G658_puc_FirstUsedBlock = L1515_puc_UnusedBlock;
                                }
                                if (G659_puc_LastUsedBlock == L1516_puc_UsedBlockToMove) {
                                        G659_puc_LastUsedBlock = L1515_puc_UnusedBlock;
                                }
                                if (G660_puc_FirstReferencedUsedBlock == L1516_puc_UsedBlockToMove) {
                                        G660_puc_FirstReferencedUsedBlock = L1515_puc_UnusedBlock;
                                }
                        }
                        L1516_puc_UsedBlockToMove += L1512_l_BlockSize;
                        L1515_puc_UnusedBlock += L1512_l_BlockSize;
                }
        } while (L1516_puc_UsedBlockToMove != G651_puc_CacheMemoryTop);
        G651_puc_CacheMemoryTop = L1515_puc_UnusedBlock;
        G657_puc_FirstUnusedBlock = NULL;
}

unsigned char* F483_xxxx_CACHE_GetNewBlock(P892_l_Size)
register long P892_l_Size;
{
        register BOOLEAN L1517_B_BlockToReuseFound;
        register long L1518_l_BlockSize;
        register unsigned char* L1519_puc_NewBlock;
        register unsigned char* L1520_puc_Block;


        F481_xxxx_CACHE_FreeMemory(P892_l_Size);
        if (((long)G642_puc_GraphicMemoryBottom - (long)G651_puc_CacheMemoryTop) >= P892_l_Size) { /* If there is enough cache memory then allocate a new block */
                L1519_puc_NewBlock = G651_puc_CacheMemoryTop;
                G651_puc_CacheMemoryTop += P892_l_Size;
        } else { /* else find an existing unused block to reuse */
                if (M80_BLOCK_SIZE(G657_puc_FirstUnusedBlock) < P892_l_Size) { /* If the largest unused block is not large enough */
                        F482_xxxx_CACHE_Defragment();
                        L1519_puc_NewBlock = G651_puc_CacheMemoryTop;
                        G651_puc_CacheMemoryTop += P892_l_Size;
                } else { /* else find an unused block that has the required size (or split the largest block and use a part of it) */
                        L1519_puc_NewBlock = G657_puc_FirstUnusedBlock;
                        L1517_B_BlockToReuseFound = FALSE;
                        do {
                                if (M80_BLOCK_SIZE(L1519_puc_NewBlock) == P892_l_Size) { /* If a block of exactly the required size if found */
                                        L1517_B_BlockToReuseFound = TRUE;
                                } else {
                                        if ((M80_BLOCK_SIZE(L1519_puc_NewBlock) < P892_l_Size) || ((L1520_puc_Block = M87_UNUSED_BLOCK_NEXT_ADDRESS(L1519_puc_NewBlock)) == NULL)) { /* If the block is too small or is the last in the list of unused blocks */
                                                L1519_puc_NewBlock = G657_puc_FirstUnusedBlock;
                                                L1517_B_BlockToReuseFound = TRUE;
                                        } else {
                                                L1519_puc_NewBlock = L1520_puc_Block;
                                        }
                                }
                        } while (!L1517_B_BlockToReuseFound);
                        F471_xxxx_CACHE_RemoveUnusedBlock(L1519_puc_NewBlock);
                        L1518_l_BlockSize = M80_BLOCK_SIZE(L1519_puc_NewBlock);
                        L1518_l_BlockSize -= P892_l_Size;
                        if (L1518_l_BlockSize >= 24) { /* The reused block is split only if the remaining size is at least 24 bytes because a block cannot be smaller (12 bytes header, 4 bytes footer and at least 8 bytes for the smallest possible bitmap of 16x1 pixels */
                                L1520_puc_Block = L1519_puc_NewBlock + P892_l_Size;
                                M80_BLOCK_SIZE(L1520_puc_Block) = M79_PREVIOUS_BLOCK_SIZE(L1520_puc_Block + L1518_l_BlockSize) = L1518_l_BlockSize;
                                F472_xxxx_CACHE_AddUnusedBlock(L1520_puc_Block);
                        } else {
                                P892_l_Size = M80_BLOCK_SIZE(L1519_puc_NewBlock);
                        }
                }
        }
        G656_l_AvailableCacheMemoryByteCount -= P892_l_Size;
        M80_BLOCK_SIZE(L1519_puc_NewBlock) = -P892_l_Size;
        M79_PREVIOUS_BLOCK_SIZE(L1519_puc_NewBlock + P892_l_Size) = -P892_l_Size;
        return L1519_puc_NewBlock;
}

VOID F484_gzzz_MEMORY_LoadGraphics_COPYPROTECTIONDEF(P893_pi_GraphicIndices, P894_i_GraphicCount)
int* P893_pi_GraphicIndices;
int P894_i_GraphicCount;
{
        register int L1521_i_Counter1;
        register int L1522_i_Counter2;
        register int L1523_i_Multiple;
#define A1523_i_GraphicIndex     L1523_i_Multiple
#define A1523_i_GraphicByteCount L1523_i_Multiple
        register long L1524_l_ByteCount;
        register unsigned char* L1525_puc_Graphic;
        register unsigned char* L1526_puc_Graphic;
        long L1527_l_TotalGraphicByteCountRequired;
        long L1528_l_AvailableCacheMemoryByteCountAfterLoadingGraphics;
        unsigned char* L1529_puc_LZWTemporaryBuffer;
        BOOLEAN L1530_B_GraphicsDatOpened;


        L1530_B_GraphicsDatOpened = FALSE;
        F473_xxxx_MEMORY_SortValues(P893_pi_GraphicIndices, P894_i_GraphicCount);
        L1527_l_TotalGraphicByteCountRequired = 0;
        for(L1521_i_Counter1 = 0; L1521_i_Counter1 < P894_i_GraphicCount; L1521_i_Counter1++) {
                A1523_i_GraphicIndex = P893_pi_GraphicIndices[L1521_i_Counter1];
                while (((L1522_i_Counter2 = L1521_i_Counter1 + 1) < P894_i_GraphicCount) && (A1523_i_GraphicIndex == P893_pi_GraphicIndices[L1522_i_Counter2])) { /* Remove duplicates from array */
                        F007_aAA7_MAIN_CopyBytes(&P893_pi_GraphicIndices[L1522_i_Counter2], &P893_pi_GraphicIndices[L1521_i_Counter1], (P894_i_GraphicCount-- - L1522_i_Counter2) << 1);
                }
                L1524_l_ByteCount = 2 + G635_pui_GraphicDecompressedByteCount[A1523_i_GraphicIndex]; /* In memory, each graphic is followed by 2 bytes containing the size of the graphic in bytes */
                if (L1524_l_ByteCount & 0x00000001) { /* Make sure size is even */
                        L1524_l_ByteCount++;
                }
                L1527_l_TotalGraphicByteCountRequired += L1524_l_ByteCount;
        }
        if (G654_B_GraphicMemoryInitialized) {
                L1528_l_AvailableCacheMemoryByteCountAfterLoadingGraphics = (long)G649_puc_GraphicMemoryTop - L1527_l_TotalGraphicByteCountRequired - (long)G641_puc_CacheMemoryBottom;
        } else {
                L1528_l_AvailableCacheMemoryByteCountAfterLoadingGraphics = (long)G642_puc_GraphicMemoryBottom - (long)G641_puc_CacheMemoryBottom; /* BUG0_00 Useless code. This code is never executed because G654_B_GraphicMemoryInitialized is always TRUE when this function is called. If it were FALSE, G642_puc_GraphicMemoryBottom would still be NULL and the resulting value in L1528_l_AvailableCacheMemoryByteCountAfterLoadingGraphics would be negative */
        }
        G348_pl_Bitmap_LogicalScreenBase[8000] = L1528_l_AvailableCacheMemoryByteCountAfterLoadingGraphics; /* BUG0_00 Useless code. The value is stored in the first long after video memory and is never used afterwards */
        /* The required minimum memory size for the cache is the total size of all bitmaps required at one time in the cache (including the overhead of 16 bytes per block in the cache). This occurs when calling F133_xxxx_VIDEO_BlitBoxFilledWithMaskedBitmap as this function requires three bitmaps at once in the cache:
                - A bitmap used as a source of pixels (graphic #73 for a teleporter, graphic #74 for a fluxcage or graphics #351 to #359 for explosions at D0)
                - A mask (graphics #69 to #72 for a teleporter or fluxcage, no mask for explosions at D0) 
                - The derived bitmap #0 which has the size of the viewport and is used as a temporary bitmap
        The resulting value is 19576 but is actually slightly above the real required minimum because:
                - When drawing an explosion, the bitmap used as pixel source is indeed the largest but no mask is used so the required size is smaller in that case
                - When drawing a teleporter or fluxcage, a mask is used but the bitmap used as pixel source is a bit smaller so the required size is smaller in that case too */
        if ((long)(M75_BITMAP_BYTE_COUNT(224, 136) + 16 +  /* Derived bitmap #0 */
                   M75_BITMAP_BYTE_COUNT(64, 111)  + 16 +  /* Largest possible mask (graphic #71 for teleporters and fluxcages) */
                   M75_BITMAP_BYTE_COUNT(48, 31)   + 16)   /* Largest possible pixel source bitmap (graphics #351 to #359 for explosions at D0) */
            > L1528_l_AvailableCacheMemoryByteCountAfterLoadingGraphics) {
                F019_aarz_MAIN_DisplayErrorAndStop(C44_ERROR_NOT_ENOUGH_CACHE_MEMORY_AFTER_LOADING_GRAPHICS);
        }
        for(L1521_i_Counter1 = 0; L1521_i_Counter1 < C730_DERIVED_BITMAP_MAXIMUM_COUNT; L1521_i_Counter1++) {
                if (G638_pi_DerivedBitmapBlockIndices[L1521_i_Counter1] != -1) {
                        F480_AA07_CACHE_ReleaseBlock(L1521_i_Counter1 | MASK0x8000_DERIVED_BITMAP);
                }
        }
        L1522_i_Counter2 = L1521_i_Counter1 = 0;
        do {
                A1523_i_GraphicIndex = P893_pi_GraphicIndices[L1521_i_Counter1];
                while (L1522_i_Counter2 < A1523_i_GraphicIndex) { /* Remove from memory all graphics that are not in the list of graphics to load (between two graphics to load) */
                        if (L1525_puc_Graphic = G636_ppuc_Graphics[L1522_i_Counter2]) { /* If the graphic is loaded in memory (non NULL address) */
                                F480_AA07_CACHE_ReleaseBlock(L1522_i_Counter2); /* Remove the corresponding bitmap from the cache */
                                G636_ppuc_Graphics[L1522_i_Counter2] = NULL;
                                L1524_l_ByteCount = G635_pui_GraphicDecompressedByteCount[L1522_i_Counter2];
                                if (L1524_l_ByteCount & 0x00000001) { /* Make sure size is even */
                                        L1524_l_ByteCount++;
                                }
                                M90_GRAPHIC_INDEX_OR_SIZE(L1525_puc_Graphic + L1524_l_ByteCount) = -L1524_l_ByteCount; /* Negative size means the graphic buffer is unused */
                        }
                        L1522_i_Counter2++;
                }
                if (G636_ppuc_Graphics[L1522_i_Counter2++] != NULL) { /* If graphic is already in memory */
                        P893_pi_GraphicIndices[L1521_i_Counter1] = ~P893_pi_GraphicIndices[L1521_i_Counter1];
                }
        } while (++L1521_i_Counter1 < P894_i_GraphicCount);
        while (L1522_i_Counter2 < G632_ui_GraphicCount) { /* Same loop as the previous one to remove from memory the remaining graphics not in the list of graphics to load (after the last graphic to load) */
                if ((L1525_puc_Graphic = G636_ppuc_Graphics[L1522_i_Counter2]) != NULL) {
                        F480_AA07_CACHE_ReleaseBlock(L1522_i_Counter2);
                        G636_ppuc_Graphics[L1522_i_Counter2] = NULL;
                        L1524_l_ByteCount = G635_pui_GraphicDecompressedByteCount[L1522_i_Counter2];
                        if (L1524_l_ByteCount & 0x00000001) { /* Make sure size is even */
                                L1524_l_ByteCount++;
                        }
                        M90_GRAPHIC_INDEX_OR_SIZE(L1525_puc_Graphic + L1524_l_ByteCount) = -L1524_l_ByteCount;
                }
                L1522_i_Counter2++;
        }
        if (G654_B_GraphicMemoryInitialized) { /* G654_B_GraphicMemoryInitialized is always TRUE when this function is called */
                L1524_l_ByteCount = (long)G650_puc_GraphicMemoryBottomTemp - ((long)G649_puc_GraphicMemoryTop - L1527_l_TotalGraphicByteCountRequired);
                if (L1524_l_ByteCount > 0) {
                        F481_xxxx_CACHE_FreeMemory(L1524_l_ByteCount);
                }
                F482_xxxx_CACHE_Defragment();
                G656_l_AvailableCacheMemoryByteCount -= L1524_l_ByteCount;
        }
        L1525_puc_Graphic = (L1526_puc_Graphic = G649_puc_GraphicMemoryTop) - 2;
        while (L1525_puc_Graphic > G650_puc_GraphicMemoryBottomTemp) { /* This loop defragments the graphics memory by removing unnecessary graphics */
                if ((A1523_i_GraphicByteCount = M90_GRAPHIC_INDEX_OR_SIZE(L1525_puc_Graphic)) < 0) { /* A negative value is the size of the graphic */
                        L1525_puc_Graphic += A1523_i_GraphicByteCount - 2;
                } else {
                        L1524_l_ByteCount = 2 + ((long)L1525_puc_Graphic - (long)G636_ppuc_Graphics[A1523_i_GraphicIndex]);
                        L1526_puc_Graphic -= L1524_l_ByteCount;
                        L1525_puc_Graphic -= L1524_l_ByteCount;
                        if (L1525_puc_Graphic + 2 != L1526_puc_Graphic) {
                                F007_aAA7_MAIN_CopyBytes(L1525_puc_Graphic + 2, L1526_puc_Graphic, (int)L1524_l_ByteCount);
                                G636_ppuc_Graphics[A1523_i_GraphicIndex] = L1526_puc_Graphic;
                        }
                }
        }
        L1529_puc_LZWTemporaryBuffer = F468_ozzz_MEMORY_Allocate(C5004_LZW_TEMPORARY_BUFFER_BYTE_COUNT, C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
#ifndef NOCOPYPROTECTION
        while (G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF);
#endif
        for(L1521_i_Counter1 = 0; L1521_i_Counter1 < P894_i_GraphicCount; L1521_i_Counter1++) { /* Loop to load all graphics not already loaded */
                if ((A1523_i_GraphicIndex = P893_pi_GraphicIndices[L1521_i_Counter1]) < 0) { /* If the graphic to load is already loaded in memory */
                        P893_pi_GraphicIndices[L1521_i_Counter1] = ~P893_pi_GraphicIndices[L1521_i_Counter1];
                } else {
                        M90_GRAPHIC_INDEX_OR_SIZE(L1526_puc_Graphic - 2) = A1523_i_GraphicIndex;
                        L1524_l_ByteCount = 2 + G635_pui_GraphicDecompressedByteCount[A1523_i_GraphicIndex];
                        if (L1524_l_ByteCount & 0x00000001) { /* Make sure size is even */
                                L1524_l_ByteCount++;
                        }
                        L1526_puc_Graphic -= L1524_l_ByteCount;
                        if (!L1530_B_GraphicsDatOpened) {
                                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, FALSE);
                                F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
                                L1530_B_GraphicsDatOpened = TRUE;
                        }
                        if (G634_pui_GraphicCompressedByteCount[A1523_i_GraphicIndex] != G635_pui_GraphicDecompressedByteCount[A1523_i_GraphicIndex]) {
                                (Fseek(F467_xxxx_MEMORY_GetGraphicOffset(A1523_i_GraphicIndex), G630_i_GraphicsDatFileHandle, C0_SEEK_FROM_BEGINNING_OF_FILE)) >= 0; /* Result of fseek is ignored */
                                F497_pzzz_LZW_Decompress(G630_i_GraphicsDatFileHandle, (long)G634_pui_GraphicCompressedByteCount[A1523_i_GraphicIndex], L1526_puc_Graphic, G296_puc_Bitmap_Viewport, L1529_puc_LZWTemporaryBuffer);
                                G297_B_DrawFloorAndCeilingRequested = TRUE;
                        } else {
                                F474_xxxx_MEMORY_LoadGraphic_COPYPROTECTIONDF(A1523_i_GraphicIndex, L1526_puc_Graphic);
                        }
                        G636_ppuc_Graphics[A1523_i_GraphicIndex] = L1526_puc_Graphic;
                }
        }
        if (L1530_B_GraphicsDatOpened) {
                F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
        }
        G650_puc_GraphicMemoryBottomTemp = L1526_puc_Graphic;
        if (G654_B_GraphicMemoryInitialized) {
                G642_puc_GraphicMemoryBottom = G650_puc_GraphicMemoryBottomTemp;
        }
#ifndef NOCOPYPROTECTION
        Floprd(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE, C0L_FILLER, C0_FLOPPY_DRIVE_A, C007_SECTOR_7, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR);
#endif
        F469_rzzz_MEMORY_FreeAtHeapTop(C5004_LZW_TEMPORARY_BUFFER_BYTE_COUNT);
}

VOID F485_xxxx_CACHE_ResetUsageCounts()
{
        register int L1531_i_BlockIndex;
        register unsigned char* L1532_puc_Block;


        G662_l_LastResetCacheUsageCountsTime = G313_ul_GameTime;
        G660_puc_FirstReferencedUsedBlock = NULL;
        if ((L1532_puc_Block = G659_puc_LastUsedBlock) == NULL) {
                return;
        }
        while (M81_USED_BLOCK_USAGE_COUNT(L1532_puc_Block) != 0) {
                M81_USED_BLOCK_USAGE_COUNT(L1532_puc_Block) = 0;
                if ((L1531_i_BlockIndex = M82_USED_BLOCK_PREVIOUS_INDEX(L1532_puc_Block)) == -1) {
                        return;
                }
                L1532_puc_Block = G655_ppuc_Blocks[L1531_i_BlockIndex];
        }
}

VOID F486_xxxx_MEMORY_AddBlockToUsedList(P895_i_BlockIndex)
register int P895_i_BlockIndex;
{
        register int L1533_i_PreviousUsedBlockIndex;
        register int L1534_i_BlockIndex;
        register int L1535_i_BitmapIndex;
        register unsigned char* L1536_puc_BlockToAdd;
        register unsigned char* L1537_puc_Block;


        L1536_puc_BlockToAdd = G655_ppuc_Blocks[P895_i_BlockIndex];
        M81_USED_BLOCK_USAGE_COUNT(L1536_puc_BlockToAdd) = 1;
        if (G660_puc_FirstReferencedUsedBlock == NULL) {
                M83_USED_BLOCK_NEXT_INDEX(L1536_puc_BlockToAdd) = -1;
                if (G659_puc_LastUsedBlock == NULL) {
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1536_puc_BlockToAdd) = -1;
                        G658_puc_FirstUsedBlock = L1536_puc_BlockToAdd;
                } else {
                        M83_USED_BLOCK_NEXT_INDEX(G659_puc_LastUsedBlock) = P895_i_BlockIndex;
                        L1535_i_BitmapIndex = M84_USED_BLOCK_BITMAP_INDEX(G659_puc_LastUsedBlock);
                        L1533_i_PreviousUsedBlockIndex = (L1535_i_BitmapIndex >= 0) ? G637_pi_NativeBitmapBlockIndices[L1535_i_BitmapIndex] : G638_pi_DerivedBitmapBlockIndices[M07_GET(L1535_i_BitmapIndex, MASK0x7FFF_GRAPHIC_INDEX)];
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1536_puc_BlockToAdd) = L1533_i_PreviousUsedBlockIndex;
                }
                G659_puc_LastUsedBlock = L1536_puc_BlockToAdd;
        } else {
                L1533_i_PreviousUsedBlockIndex = M82_USED_BLOCK_PREVIOUS_INDEX(G660_puc_FirstReferencedUsedBlock);
                M82_USED_BLOCK_PREVIOUS_INDEX(G660_puc_FirstReferencedUsedBlock) = P895_i_BlockIndex;
                M82_USED_BLOCK_PREVIOUS_INDEX(L1536_puc_BlockToAdd) = L1533_i_PreviousUsedBlockIndex;
                if (L1533_i_PreviousUsedBlockIndex != -1) {
                        L1537_puc_Block = G655_ppuc_Blocks[L1533_i_PreviousUsedBlockIndex];
                        M83_USED_BLOCK_NEXT_INDEX(L1536_puc_BlockToAdd) = M83_USED_BLOCK_NEXT_INDEX(L1537_puc_Block);
                        M83_USED_BLOCK_NEXT_INDEX(L1537_puc_Block) = P895_i_BlockIndex;
                } else {
                        L1535_i_BitmapIndex = M84_USED_BLOCK_BITMAP_INDEX(G660_puc_FirstReferencedUsedBlock);
                        L1534_i_BlockIndex = (L1535_i_BitmapIndex >= 0) ? G637_pi_NativeBitmapBlockIndices[L1535_i_BitmapIndex] : G638_pi_DerivedBitmapBlockIndices[M07_GET(L1535_i_BitmapIndex, MASK0x7FFF_GRAPHIC_INDEX)];
                        M83_USED_BLOCK_NEXT_INDEX(L1536_puc_BlockToAdd) = L1534_i_BlockIndex;
                        G658_puc_FirstUsedBlock = L1536_puc_BlockToAdd;
                }
        }
        G660_puc_FirstReferencedUsedBlock = L1536_puc_BlockToAdd;
}

unsigned char* F487_xxxx_CACHE_GetBlockAndIncrementUsageCount(P896_i_BlockIndex) /* Used blocks are sorted in decreasing order of usage count */
register int P896_i_BlockIndex;
{
        register int L1538_i_PreviousUsedBlockIndex;
        register int L1539_i_NextUsedBlockIndex;
        register unsigned int L1540_ui_UsageCount;
        register unsigned char* L1541_puc_Block;
        register unsigned char* L1542_puc_Block;
        unsigned char* L1543_puc_Block;


        L1543_puc_Block = L1541_puc_Block = G655_ppuc_Blocks[P896_i_BlockIndex];
        if ((L1540_ui_UsageCount = M81_USED_BLOCK_USAGE_COUNT(L1541_puc_Block)) == 0) {
                if ((L1539_i_NextUsedBlockIndex = M83_USED_BLOCK_NEXT_INDEX(L1541_puc_Block)) == -1) {
                        G660_puc_FirstReferencedUsedBlock = L1541_puc_Block;
                        M81_USED_BLOCK_USAGE_COUNT(L1541_puc_Block) = 1;
                        return L1541_puc_Block;
                }
                L1542_puc_Block = G655_ppuc_Blocks[L1539_i_NextUsedBlockIndex];
                if ((L1538_i_PreviousUsedBlockIndex = M82_USED_BLOCK_PREVIOUS_INDEX(L1541_puc_Block)) == -1) {
                        G658_puc_FirstUsedBlock = L1542_puc_Block;
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1542_puc_Block) = -1;
                } else {
                        L1541_puc_Block = G655_ppuc_Blocks[L1538_i_PreviousUsedBlockIndex];
                        M83_USED_BLOCK_NEXT_INDEX(L1541_puc_Block) = L1539_i_NextUsedBlockIndex;
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1542_puc_Block) = L1538_i_PreviousUsedBlockIndex;
                }
                F486_xxxx_MEMORY_AddBlockToUsedList(P896_i_BlockIndex);
                return L1543_puc_Block;
        }
        M81_USED_BLOCK_USAGE_COUNT(L1541_puc_Block) = (L1540_ui_UsageCount = L1540_ui_UsageCount + 1);
        if (L1541_puc_Block == G659_puc_LastUsedBlock) {
                return L1541_puc_Block;
        }
        L1542_puc_Block = G655_ppuc_Blocks[L1539_i_NextUsedBlockIndex = M83_USED_BLOCK_NEXT_INDEX(L1541_puc_Block)];
        if (M81_USED_BLOCK_USAGE_COUNT(L1542_puc_Block) >= L1540_ui_UsageCount) {
                return L1541_puc_Block;
        }
        if ((L1538_i_PreviousUsedBlockIndex = M82_USED_BLOCK_PREVIOUS_INDEX(L1541_puc_Block)) == -1) {
                G658_puc_FirstUsedBlock = G660_puc_FirstReferencedUsedBlock = L1542_puc_Block;
                M82_USED_BLOCK_PREVIOUS_INDEX(L1542_puc_Block) = -1;
        } else {
                if (G660_puc_FirstReferencedUsedBlock == L1541_puc_Block) {
                        G660_puc_FirstReferencedUsedBlock = L1542_puc_Block;
                }
                L1541_puc_Block = G655_ppuc_Blocks[L1538_i_PreviousUsedBlockIndex];
                M83_USED_BLOCK_NEXT_INDEX(L1541_puc_Block) = L1539_i_NextUsedBlockIndex;
                M82_USED_BLOCK_PREVIOUS_INDEX(L1542_puc_Block) = L1538_i_PreviousUsedBlockIndex;
        }
        do {
                L1541_puc_Block = L1542_puc_Block;
                L1538_i_PreviousUsedBlockIndex = L1539_i_NextUsedBlockIndex;
                if ((L1539_i_NextUsedBlockIndex = M83_USED_BLOCK_NEXT_INDEX(L1541_puc_Block)) == -1) {
                        M83_USED_BLOCK_NEXT_INDEX(L1541_puc_Block) = P896_i_BlockIndex;
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1543_puc_Block) = L1538_i_PreviousUsedBlockIndex;
                        M83_USED_BLOCK_NEXT_INDEX(L1543_puc_Block) = -1;
                        return G659_puc_LastUsedBlock = L1543_puc_Block;
                }
                L1542_puc_Block = G655_ppuc_Blocks[L1539_i_NextUsedBlockIndex];
                if (M81_USED_BLOCK_USAGE_COUNT(L1542_puc_Block) >= L1540_ui_UsageCount) {
                        M83_USED_BLOCK_NEXT_INDEX(L1541_puc_Block) = P896_i_BlockIndex;
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1543_puc_Block) = L1538_i_PreviousUsedBlockIndex;
                        M83_USED_BLOCK_NEXT_INDEX(L1543_puc_Block) = L1539_i_NextUsedBlockIndex;
                        M82_USED_BLOCK_PREVIOUS_INDEX(L1542_puc_Block) = P896_i_BlockIndex;
                        return L1543_puc_Block;
                }
        } while (TRUE);
}

VOID F488_bzzz_MEMORY_ExpandGraphicToBitmap(P897_i_GraphicIndex, P898_puc_Bitmap)
int P897_i_GraphicIndex;
register unsigned char* P898_puc_Bitmap;
{
        register unsigned char* L1544_puc_Graphic;


        L1544_puc_Graphic = G636_ppuc_Graphics[P897_i_GraphicIndex];
        F466_rzzz_EXPAND_GraphicToBitmap(L1544_puc_Graphic, P898_puc_Bitmap, 0, 0);
}

unsigned char* F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(P899_i_NativeBitmapOrGraphicIndex)
register int P899_i_NativeBitmapOrGraphicIndex;
{
        register int L1545_i_BlockIndex;
        register long L1546_l_ByteCount;
        register unsigned char* L1547_puc_Block;
        register unsigned char* L1548_puc_Graphic;


        if (M07_GET(P899_i_NativeBitmapOrGraphicIndex, MASK0x8000_NOT_EXPANDED)) {
                L1548_puc_Graphic = G636_ppuc_Graphics[M07_GET(P899_i_NativeBitmapOrGraphicIndex, MASK0x7FFF_GRAPHIC_INDEX)];
                return L1548_puc_Graphic;
        }
        if (G313_ul_GameTime != G662_l_LastResetCacheUsageCountsTime) {
                F485_xxxx_CACHE_ResetUsageCounts();
        }
        if ((L1545_i_BlockIndex = G637_pi_NativeBitmapBlockIndices[P899_i_NativeBitmapOrGraphicIndex]) != -1) {
                return M85_USED_BLOCK_BITMAP(F487_xxxx_CACHE_GetBlockAndIncrementUsageCount(L1545_i_BlockIndex));
        }
        L1548_puc_Graphic = G636_ppuc_Graphics[P899_i_NativeBitmapOrGraphicIndex];
        L1546_l_ByteCount = 16 + (M88_GRAPHIC_BYTE_WIDTH(L1548_puc_Graphic) * M89_GRAPHIC_HEIGHT(L1548_puc_Graphic)); /* Each block contains 16 bytes of data in addition to the bitmap itself */
        L1547_puc_Block = F483_xxxx_CACHE_GetNewBlock(L1546_l_ByteCount);
        L1545_i_BlockIndex = 0;
        while (G655_ppuc_Blocks[L1545_i_BlockIndex++] != NULL);
        G637_pi_NativeBitmapBlockIndices[P899_i_NativeBitmapOrGraphicIndex] = --L1545_i_BlockIndex;
        G655_ppuc_Blocks[L1545_i_BlockIndex] = L1547_puc_Block;
        M84_USED_BLOCK_BITMAP_INDEX(L1547_puc_Block) = P899_i_NativeBitmapOrGraphicIndex;
        F486_xxxx_MEMORY_AddBlockToUsedList(L1545_i_BlockIndex);
        L1547_puc_Block += 12; /* Address of the bitmap in the block */
        F466_rzzz_EXPAND_GraphicToBitmap(L1548_puc_Graphic, L1547_puc_Block, 0, 0);
        return L1547_puc_Block;
}

VOID F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(P900_i_GraphicIndex, P901_puc_Bitmap, P902_i_DestinationX, P903_i_DestinationY)
register int P900_i_GraphicIndex;
register unsigned char* P901_puc_Bitmap;
int P902_i_DestinationX;
int P903_i_DestinationY;
{
        register BOOLEAN L1549_B_DoNotExpand;
        register unsigned char* L1550_puc_LZWTemporaryBuffer;


        F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
        L1549_B_DoNotExpand = M07_GET(P900_i_GraphicIndex, MASK0x8000_NOT_EXPANDED);
        M09_CLEAR(P900_i_GraphicIndex, MASK0x8000_NOT_EXPANDED);
        if (G634_pui_GraphicCompressedByteCount[P900_i_GraphicIndex] != G635_pui_GraphicDecompressedByteCount[P900_i_GraphicIndex]) {
                L1550_puc_LZWTemporaryBuffer = F468_ozzz_MEMORY_Allocate(C5004_LZW_TEMPORARY_BUFFER_BYTE_COUNT, C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
                Fseek(F467_xxxx_MEMORY_GetGraphicOffset(P900_i_GraphicIndex), G630_i_GraphicsDatFileHandle, C0_SEEK_FROM_BEGINNING_OF_FILE) >= 0; /* Result of fseek is ignored */
                F497_pzzz_LZW_Decompress(G630_i_GraphicsDatFileHandle, (long)G634_pui_GraphicCompressedByteCount[P900_i_GraphicIndex], P901_puc_Bitmap, G296_puc_Bitmap_Viewport, L1550_puc_LZWTemporaryBuffer);
                G297_B_DrawFloorAndCeilingRequested = TRUE;
                F469_rzzz_MEMORY_FreeAtHeapTop(C5004_LZW_TEMPORARY_BUFFER_BYTE_COUNT);
                if (!L1549_B_DoNotExpand) {
                        F007_aAA7_MAIN_CopyBytes(P901_puc_Bitmap, G296_puc_Bitmap_Viewport, G635_pui_GraphicDecompressedByteCount[P900_i_GraphicIndex]);
                }
        } else {
                F474_xxxx_MEMORY_LoadGraphic_COPYPROTECTIONDF(P900_i_GraphicIndex, L1549_B_DoNotExpand ? P901_puc_Bitmap : G296_puc_Bitmap_Viewport);
        }
        if (!L1549_B_DoNotExpand) {
                F466_rzzz_EXPAND_GraphicToBitmap(G296_puc_Bitmap_Viewport, P901_puc_Bitmap, P902_i_DestinationX, P903_i_DestinationY);
                G297_B_DrawFloorAndCeilingRequested = TRUE;
        }
        F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
}

/* If the specified derived bitmap is already in the cache, its reference count is incremented and the function returns TRUE else a block is allocated for the derived bitmap and the function returns FALSE */
BOOLEAN F491_xzzz_CACHE_IsDerivedBitmapInCache(P904_i_DerivedBitmapIndex)
register int P904_i_DerivedBitmapIndex;
{
        register int L1551_i_BlockIndex;
        register unsigned long L1552_ul_ByteCount;
        register unsigned char* L1553_puc_Block;


        if (G313_ul_GameTime != G662_l_LastResetCacheUsageCountsTime) {
                F485_xxxx_CACHE_ResetUsageCounts();
        }
        if ((L1551_i_BlockIndex = G638_pi_DerivedBitmapBlockIndices[P904_i_DerivedBitmapIndex]) != -1) {
                F487_xxxx_CACHE_GetBlockAndIncrementUsageCount(L1551_i_BlockIndex);
                return TRUE;
        }
        L1552_ul_ByteCount = 16 + G639_pi_DerivedBitmapByteCount[P904_i_DerivedBitmapIndex]; /* Each block contains 16 bytes of data in addition to the bitmap itself */
        L1553_puc_Block = F483_xxxx_CACHE_GetNewBlock(L1552_ul_ByteCount);
        L1551_i_BlockIndex = 0;
        while (G655_ppuc_Blocks[L1551_i_BlockIndex++] != NULL);
        G638_pi_DerivedBitmapBlockIndices[P904_i_DerivedBitmapIndex] = --L1551_i_BlockIndex;
        G655_ppuc_Blocks[L1551_i_BlockIndex] = L1553_puc_Block;
        M84_USED_BLOCK_BITMAP_INDEX(L1553_puc_Block) = P904_i_DerivedBitmapIndex | MASK0x8000_DERIVED_BITMAP;
        return FALSE;
}

unsigned char* F492_mzzz_CACHE_GetDerivedBitmap(P905_i_DerivedBitmapIndex)
int P905_i_DerivedBitmapIndex;
{
        return M85_USED_BLOCK_BITMAP(G655_ppuc_Blocks[G638_pi_DerivedBitmapBlockIndices[P905_i_DerivedBitmapIndex]]);
}

VOID F493_hzzz_CACHE_AddDerivedBitmap(P906_i_DerivedBitmapIndex)
int P906_i_DerivedBitmapIndex;
{
        F486_xxxx_MEMORY_AddBlockToUsedList(G638_pi_DerivedBitmapBlockIndices[P906_i_DerivedBitmapIndex]);
}

unsigned int F494_ozzz_MEMORY_GetGraphicDecompressedByteCount(P907_i_GraphicIndex)
int P907_i_GraphicIndex;
{
        return G635_pui_GraphicDecompressedByteCount[P907_i_GraphicIndex];
}
