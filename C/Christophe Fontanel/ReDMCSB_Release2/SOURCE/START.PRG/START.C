/* This program performs the following actions:
- Load the compressed PRG stored in START.PAK in a temporary memory location
- Decompress the data in another temporary memory location
- Overwrite itself in memory with the decompressed executable. In this purpose, it updates the base page with the new segment addresses and sizes and applies the relocation data. Before copying the decompressed executable, the small routine to perform the copy is itself copied to a safe location where it will not be overwritten during the copy.
- Run the decompressed executable */

/*_********************** Types, Constants and macros **********************_*/
typedef int VOID; /* There is no void type in Megamax C. It is not possible to declare a function with no return value */
                  /* This fake VOID type is used only to clearly indicate functions that do not return any value */

typedef struct {
        long DecompressedDataWordCount;
        unsigned int Signature;
        long TextSegmentSize;
        long DataSegmentSize;
        long BSSSegmentSize;
        long SymbolsSize;
} PAK_HEADER;

#define Fopen(a, b)    (long)R3_gemdos(0x3D, a, b)
#define Fread(a, b, c) (long)R3_gemdos(0x3F, a, b, c)
#define Fseek(a, b, c) (long)R3_gemdos(0x42, a, b, c)

#define C0_READ_ONLY                   0
#define C0_SEEK_FROM_BEGINNING_OF_FILE 0
#define C2_SEEK_FROM_END_OF_FILE       2

extern char* _base;
extern long R3_gemdos();


/*_Global variables_*/
char* G0_pc_SystemCallReturnAddress;


VOID main() {
        register long L00_l_ProcessTopAddress;
        register long L01_l_BasePageAddress;
        register long L02_l_CompressedDataAddress;
        register long L03_l_DecompressedPRGAddress;
        register long* L04_pl_Multiple;
#define A04_pl_BasePageValue  L04_pl_Multiple
#define A04_pl_RelocationData L04_pl_Multiple
        register long* L05_pl_RelocationAddress;
        PAK_HEADER L06_s_PAKHeader;
        long L07_l_StartOffset;
        long L08_l_Multiple;
#define A08_l_EndOffset      L08_l_Multiple
#define A08_l_RelocationByte L08_l_Multiple
        long L09_l_TotalSizeInLongs;
        int L10_i_FileHandle;
        unsigned char* L11_puc_RelocationData;


        A04_pl_BasePageValue = (long*)_base;
        L00_l_ProcessTopAddress = A04_pl_BasePageValue[1]; /* htpa value from base page (All available memory is allocated to the process when GEMDOS runs a PRG) */
        L01_l_BasePageAddress = (long)_base;
        if ((L10_i_FileHandle = Fopen("start.pak", C0_READ_ONLY)) < 0) {
                for(;;);
        }
        Fread(L10_i_FileHandle, (long)sizeof(PAK_HEADER), &L06_s_PAKHeader); /* Read first 22 bytes of header. The actual header is 32 bytes large but the last ten bytes are 0x00 and are not read */
        if (L06_s_PAKHeader.Signature != 0x601A) {
                for(;;);
        }
        A08_l_EndOffset = Fseek(0L, L10_i_FileHandle, C2_SEEK_FROM_END_OF_FILE);
        L07_l_StartOffset = Fseek(32L, L10_i_FileHandle, C0_SEEK_FROM_BEGINNING_OF_FILE); /* PAK Header is 32 bytes large */
        L02_l_CompressedDataAddress = L00_l_ProcessTopAddress - ((A08_l_EndOffset - L07_l_StartOffset + 1) & 0xFFFFFFFE);
        L03_l_DecompressedPRGAddress = L01_l_BasePageAddress + 16000; /* Decompress at arbitrary location after the START.PRG */
        Fread(L10_i_FileHandle, A08_l_EndOffset - L07_l_StartOffset, L02_l_CompressedDataAddress);
        F4_DecompressPAK(L02_l_CompressedDataAddress, L02_l_CompressedDataAddress + 3840, L06_s_PAKHeader.DecompressedDataWordCount, L03_l_DecompressedPRGAddress);
        /* Apply relocation data */
        A04_pl_RelocationData = (long*)(L03_l_DecompressedPRGAddress + (L09_l_TotalSizeInLongs = L06_s_PAKHeader.TextSegmentSize + L06_s_PAKHeader.DataSegmentSize + L06_s_PAKHeader.SymbolsSize)); /* Address where the first relocation should occur */
        L09_l_TotalSizeInLongs = (L09_l_TotalSizeInLongs >> 2) + 1;
        L05_pl_RelocationAddress = (long*)((*A04_pl_RelocationData++) + L03_l_DecompressedPRGAddress);
        L11_puc_RelocationData = (unsigned char*)A04_pl_RelocationData;
        *L05_pl_RelocationAddress += L01_l_BasePageAddress + 256;
        while ((A08_l_RelocationByte = *L11_puc_RelocationData++) != 0) {
                if (A08_l_RelocationByte == 1) {
                        L05_pl_RelocationAddress += 254; /* BUG: This will add 254 * 4 = 1016 instead of the required 254 because L05_pl_RelocationAddress is a pointer to a long (4 bytes). No consequence because there are no relocation bytes with value 1 in the compressed PRG file */
                } else {
                        L05_pl_RelocationAddress = (char*)L05_pl_RelocationAddress + A08_l_RelocationByte;
                        *L05_pl_RelocationAddress += L01_l_BasePageAddress + 256;
                }
        }
        /* Update the base page with information for the decompressed PRG */
        A04_pl_BasePageValue = (long*)(_base + 12);
        *A04_pl_BasePageValue++ = L06_s_PAKHeader.TextSegmentSize;                                                                 /* Update codelen in base page */
        *A04_pl_BasePageValue++ = L01_l_BasePageAddress + L06_s_PAKHeader.TextSegmentSize + 256;                                   /* Update ldata in base page */
        *A04_pl_BasePageValue++ = L06_s_PAKHeader.DataSegmentSize;                                                                 /* Update datalen in base page */
        *A04_pl_BasePageValue++ = L01_l_BasePageAddress + L06_s_PAKHeader.TextSegmentSize + L06_s_PAKHeader.DataSegmentSize + 256; /* Update lbss in base page */
        *A04_pl_BasePageValue = L06_s_PAKHeader.BSSSegmentSize;                                                                    /* Update bsslen in base page */
        /* Overwrite START.PRG in memory with the decompressed and relocated PRG. The small routine to perform the copy is itself copied first at the location where the compressed data was stored so that it is not overwritten while copying the decompressed PRG */
        asm {
                lea     CopyDecompressedPRG(PC),A0              /* Copy routine to copy decompressed PRG */
                movea.l L02_l_CompressedDataAddress,A1
                movea.l A1,A2
                move.w  #32,D0                                  /* Copy 32 bytes (more than necessary) */
        Loop1:
                move.b  (A0)+,(A1)+
                dbf     D0,Loop1
                movea.l L00_l_ProcessTopAddress,A7              /* Set new stack address */
                movea.l _base(A4),A1
                move.l  A1,-(A7)
                adda.l  #256,A1                                 /* Address of TEXT segment (after base page) */
                movea.l L03_l_DecompressedPRGAddress,A0
                move.l  L09_l_TotalSizeInLongs(A6),D0
                jmp     (A2)                                    /* Call routine below to copy decompressed PRG in place of the loaded START.PRG */
        CopyDecompressedPRG:
                movea.l A1,A2
        Loop2:
                move.l  (A0)+,(A1)+
                dbf     D0,Loop2
                jsr     (A2)                                    /* Run the decompressed PRG */
        }
}

asm {
        R3_gemdos:
                move.l  A2,D3                                   /* Backup A2 register in D3 */
                move.l  (A7)+,G0_pc_SystemCallReturnAddress(A4) /* Backup return address and remove it from the stack */
                trap    #1                                      /* Call GEMDOS */
                movea.l G0_pc_SystemCallReturnAddress(A4),A0    /* Restore return address */
                movea.l D3,A2                                   /* Restore A2 from D3 */
                jmp     (A0)                                    /* Jump to return address */
}

VOID F4_DecompressPAK(P0_pui_MostFrequentWordsAddress, P1_pui_CompressedDataAddress, P2_l_DecompressedDataWordCount, P3_pui_DecompressedPRGAddress)
unsigned int* P0_pui_MostFrequentWordsAddress; /* Array of 1920 most used words in decompressed PRG. Two parts: the first 128 words are the most used words, followed by 1792 words less used words */
unsigned int* P1_pui_CompressedDataAddress;
long P2_l_DecompressedDataWordCount;
unsigned int* P3_pui_DecompressedPRGAddress;
{
        asm {
                        movem.l D4-D5/A2-A3,-(A7)
                        movea.l P0_pui_MostFrequentWordsAddress(A6),A3
                        movea.l P3_pui_DecompressedPRGAddress(A6),A1
                        movea.l P1_pui_CompressedDataAddress(A6),A0
                        move.l  P2_l_DecompressedDataWordCount(A6),D4
                        moveq   #0,D3
                        moveq   #15,D1
                        moveq   #8,D0
                MainLoop:
                        subq.l  #1,D4                           /* D4 contains the number of decompressed words left to output */
                        bmi     RestoreRegistersAndExit
                        moveq   #1,D5                           /* Read one nibble (4 bit) from compressed data. This is a control code */
                        bsr.s   ClearD2AndGetNibbles
                        cmp.w   D0,D2
                        bpl.s   LessFrequentWord                /* Branch if control code >= 8 */
                        moveq   #1,D5                           /* Read one more nibble from compressed data and use the two nibbles as an index in the most frequent words array (first 128 words) */
                        bsr.s   GetNibbles
                        add.w   D2,D2
                        move.w  0(A3,D2.w),(A1)+
                        bra.s   MainLoop
                LessFrequentWord:
                        cmp.w   D1,D2
                        beq.s   DirectWord                      /* Branch if control code = 15 */
                        moveq   #2,D5                           /* Read two more nibbles from compressed data and use the three nibbles as an index in the most frequent words array (last 1792 words) */
                        bsr.s   GetNibbles
                        sub.l   #1920,D2
                        add.w   D2,D2
                        move.w  0(A3,D2.w),(A1)+
                        bra.s   MainLoop
                DirectWord:
                        moveq   #4,D5                           /* Read word (4 nibbles) directly from compressed data (do not use most frequent words array) */
                        bsr.s   ClearD2AndGetNibbles
                        move.w  D2,(A1)+
                        bra.s   MainLoop
                ClearD2AndGetNibbles:
                        clr.w   D2
                GetNibbles:
                        swap    D2
                Loop:
                        subq.w  #1,D3                           /* D3 contains the number of nibbles in D2 that have not been used yet */
                        bpl.s   NibbleInD2
                        moveq   #3,D3
                        move.w  (A0)+,D2                        /* Read 4 nibbles from compressed data */
                NibbleInD2:
                        lsl.l   #4,D2
                        subq.w  #1,D5                           /* One less nibble to get. D5 contains the number of nibble to read */
                        bne.s   Loop
                        swap    D2
                        rts
                RestoreRegistersAndExit:
                        movem.l (A7)+,D4-D5/A2-A3
        }
}
