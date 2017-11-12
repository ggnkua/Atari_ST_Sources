#include "DEFS.H"

/*_Global variables_*/
BOOLEAN G663_B_LZW_RepetitionEnabled;
int G664_i_LZW_CodeBitCount;
int G665_i_LZW_CurrentMaximumCode;
int G666_i_LZW_AbsoluteMaximumCode = 4096;
char G667_ac_LZW_InputBuffer[12];
int G668_i_LZW_DictionaryNextAvailableCode;
BOOLEAN G669_B_LZW_DictionaryFlushed;


overlay "memory"

int F495_xxxx_LZW_GetNextInputCode(P908_i_InputFileHandle, P909_pl_InputByteCount)
int P908_i_InputFileHandle;
long* P909_pl_InputByteCount;
{
        register int L1554_i_NextInputCode;
        register int L1555_i_BitIndex;
        register int L1556_i_RequiredInputBitCount;
        register unsigned char* L1557_puc_InputBuffer;
        static unsigned char G670_auc_LZW_Unreferenced[9] = { 0xFF,0xFE,0xFC,0xF8,0xF0,0xE0,0xC0,0x80,0x00 }; /* BUG0_00 Useless code */
        static unsigned char G671_auc_LZW_LeastSignificantBitMasks[9] = { 0x00,0x01,0x03,0x07,0x0F,0x1F,0x3F,0x7F,0xFF };
        static int G672_i_LZW_InputBufferBitIndex = 0;
        static int G673_i_LZW_InputBufferBitCount = 0;


        L1557_puc_InputBuffer = (unsigned char*)G667_ac_LZW_InputBuffer;
        if ((G669_B_LZW_DictionaryFlushed > 0) || (G672_i_LZW_InputBufferBitIndex >= G673_i_LZW_InputBufferBitCount) || (G668_i_LZW_DictionaryNextAvailableCode > G665_i_LZW_CurrentMaximumCode)) {
                if (G668_i_LZW_DictionaryNextAvailableCode > G665_i_LZW_CurrentMaximumCode) {
                        G664_i_LZW_CodeBitCount++;
                        if (G664_i_LZW_CodeBitCount == 12) {
                                G665_i_LZW_CurrentMaximumCode = G666_i_LZW_AbsoluteMaximumCode;
                        } else {
                                G665_i_LZW_CurrentMaximumCode = (1 << G664_i_LZW_CodeBitCount) - 1;
                        }
                }
                if (G669_B_LZW_DictionaryFlushed > 0) {
                        G665_i_LZW_CurrentMaximumCode = (1 << (G664_i_LZW_CodeBitCount = 9)) - 1;
                        G669_B_LZW_DictionaryFlushed = FALSE;
                }
                if (*P909_pl_InputByteCount > G664_i_LZW_CodeBitCount) {
                        G673_i_LZW_InputBufferBitCount = G664_i_LZW_CodeBitCount;
                } else {
                        G673_i_LZW_InputBufferBitCount = *P909_pl_InputByteCount;
                }
                if (G673_i_LZW_InputBufferBitCount > 0) {
                        Fread(P908_i_InputFileHandle, (long)G673_i_LZW_InputBufferBitCount, G667_ac_LZW_InputBuffer) == (long)G673_i_LZW_InputBufferBitCount; /* Result of fread is ignored */
                        *P909_pl_InputByteCount -= (long)G673_i_LZW_InputBufferBitCount;
                } else {
                        return -1;
                }
                G672_i_LZW_InputBufferBitIndex = 0;
                G673_i_LZW_InputBufferBitCount = (G673_i_LZW_InputBufferBitCount << 3) - (G664_i_LZW_CodeBitCount - 1);
        }
        L1555_i_BitIndex = G672_i_LZW_InputBufferBitIndex;
        L1556_i_RequiredInputBitCount = G664_i_LZW_CodeBitCount;
        L1557_puc_InputBuffer += L1555_i_BitIndex >> 3; /* Address of byte in input buffer containing current bit */
        L1555_i_BitIndex &= 0x0007; /* Bit index of the current bit in the byte */
        L1554_i_NextInputCode = *L1557_puc_InputBuffer++ >> L1555_i_BitIndex; /* Get the first bits of the next input code from the input buffer byte */
        L1556_i_RequiredInputBitCount -= 8 - L1555_i_BitIndex; /* Remaining number of bits to get for a complete input code */
        L1555_i_BitIndex = 8 - L1555_i_BitIndex;
        if (L1556_i_RequiredInputBitCount >= 8) {
                L1554_i_NextInputCode |= *L1557_puc_InputBuffer++ << L1555_i_BitIndex;
                L1555_i_BitIndex += 8;
                L1556_i_RequiredInputBitCount -= 8;
        }
        L1554_i_NextInputCode |= (*L1557_puc_InputBuffer & G671_auc_LZW_LeastSignificantBitMasks[L1556_i_RequiredInputBitCount]) << L1555_i_BitIndex;
        G672_i_LZW_InputBufferBitIndex += G664_i_LZW_CodeBitCount;
        return L1554_i_NextInputCode;
}

VOID F496_xxxx_LZW_OutputCharacter(P910_uc_Character, P911_ppc_Output)
register unsigned char P910_uc_Character;
char** P911_ppc_Output;
{
        register char* L1558_pc_Output;
        static int G674_i_LZW_CharacterToRepeat;


        L1558_pc_Output = *P911_ppc_Output;
        switch (G663_B_LZW_RepetitionEnabled) {
                case FALSE:
                        if (P910_uc_Character == 0x90) {
                                G663_B_LZW_RepetitionEnabled = TRUE;
                        } else {
                                *L1558_pc_Output++ = G674_i_LZW_CharacterToRepeat = P910_uc_Character;
                        }
                        *P911_ppc_Output = L1558_pc_Output;
                        return;
                case TRUE:
                        if (P910_uc_Character) { /* If character following 0x90 is not 0x00 then it is the repeat count */
                                while (--P910_uc_Character) {
                                        *L1558_pc_Output++ = G674_i_LZW_CharacterToRepeat;
                                }
                        } else { /* else output a 0x90 character */
                                *L1558_pc_Output++ = 0x90;
                        }
                        G663_B_LZW_RepetitionEnabled = FALSE;
                        *P911_ppc_Output = L1558_pc_Output;
                        return;
                default:
                        for(;;); /*_Infinite loop_*/
        }
}

long F497_pzzz_LZW_Decompress(P912_i_InputFileHandle, P913_l_InputByteCount, P914_l_OutputAddress, P915_puc_Dictionary, P916_puc_TemporaryBuffer)
int P912_i_InputFileHandle;
long P913_l_InputByteCount;
long P914_l_OutputAddress;
unsigned char* P915_puc_Dictionary;
unsigned char* P916_puc_TemporaryBuffer; /* 5004 bytes buffer max decoded string size */
{
        register int L1559_i_Character;
        register int L1560_i_Code;
        register int L1561_i_OldCode;
        register int L1562_i_NewCode;
        register int* L1563_pi_PrefixCode;
        register unsigned char* L1564_puc_AppendCharacter;
        unsigned char* L1565_puc_ReversedDecodedStringEnd;
        unsigned char* L1566_puc_ReversedDecodedStringStart;
        long L1567_l_OutputAddress;


        L1563_pi_PrefixCode = (int*)P915_puc_Dictionary;
        L1564_puc_AppendCharacter = P915_puc_Dictionary + (5003 * sizeof(int)); /* Splits the 15232 bytes buffer in two parts 10006 + 5226 (= enough for 5003 bytes)
                10006 = space necessary to store 5003 codes (integers). 5004 is the space to store 5003 characters + 1 padding byte so the size if even.
                5003 is a prime number, around 22% larger than 4096 which is the maximum code value when codes are 12 bits large.
                This particular size is useful when compressing data (in order to use a hash algorithm to search for strings in the dictionary) */
        L1565_puc_ReversedDecodedStringEnd = L1566_puc_ReversedDecodedStringStart = P916_puc_TemporaryBuffer;
        L1567_l_OutputAddress = (long)P914_l_OutputAddress;
        G663_B_LZW_RepetitionEnabled = FALSE;
        L1560_i_Code = 12; /* BUG0_00 Useless code */
        G664_i_LZW_CodeBitCount = 9;
        G669_B_LZW_DictionaryFlushed = FALSE;
        G665_i_LZW_CurrentMaximumCode = (1 << (G664_i_LZW_CodeBitCount = 9)) - 1;
        for(L1560_i_Code = 255; L1560_i_Code >= 0; L1560_i_Code--) {
                L1563_pi_PrefixCode[L1560_i_Code] = 0;
                L1564_puc_AppendCharacter[L1560_i_Code] = (unsigned char)L1560_i_Code;
        }
        G668_i_LZW_DictionaryNextAvailableCode = 257;
        L1559_i_Character = L1561_i_OldCode = F495_xxxx_LZW_GetNextInputCode(P912_i_InputFileHandle, &P913_l_InputByteCount);
        if (L1561_i_OldCode == -1) {
                return -1L;
        }
        F496_xxxx_LZW_OutputCharacter((int)((char)L1559_i_Character), &P914_l_OutputAddress);
        while ((L1560_i_Code = F495_xxxx_LZW_GetNextInputCode(P912_i_InputFileHandle, &P913_l_InputByteCount)) > -1) {
                if (L1560_i_Code == 256) { /* This code is used to flush the dictionary */
                        F008_aA19_MAIN_ClearBytes(L1563_pi_PrefixCode, 256 * sizeof(int));
                        G669_B_LZW_DictionaryFlushed = TRUE;
                        G668_i_LZW_DictionaryNextAvailableCode = 256;
                        if ((L1560_i_Code = F495_xxxx_LZW_GetNextInputCode(P912_i_InputFileHandle, &P913_l_InputByteCount)) == -1) {
                                break;
                        }
                }
                /* This code checks for the special STRING+CHARACTER+STRING+CHARACTER+STRING case which generates an undefined code. It handles it by decoding the last code, adding a single character to the end of the decoded string */
                L1562_i_NewCode = L1560_i_Code;
                if (L1560_i_Code >= G668_i_LZW_DictionaryNextAvailableCode) { /* If code is not defined yet */
                        *L1565_puc_ReversedDecodedStringEnd++ = L1559_i_Character;
                        L1560_i_Code = L1561_i_OldCode;
                }
                /* Use the string table to decode the string corresponding to the code and store the string in the temporary buffer */
                while (L1560_i_Code >= 256) {
                        *L1565_puc_ReversedDecodedStringEnd++ = L1564_puc_AppendCharacter[L1560_i_Code];
                        L1560_i_Code = L1563_pi_PrefixCode[L1560_i_Code];
                }
                *L1565_puc_ReversedDecodedStringEnd++ = (L1559_i_Character = L1564_puc_AppendCharacter[L1560_i_Code]);
                /* Output the decoded string in reverse order */
                do {
                        F496_xxxx_LZW_OutputCharacter(*(--L1565_puc_ReversedDecodedStringEnd), &P914_l_OutputAddress);
                } while (L1565_puc_ReversedDecodedStringEnd > L1566_puc_ReversedDecodedStringStart);
                /* If possible, add a new code to the string table */
                if ((L1560_i_Code = G668_i_LZW_DictionaryNextAvailableCode) < G666_i_LZW_AbsoluteMaximumCode) {
                        L1563_pi_PrefixCode[L1560_i_Code] = (int)L1561_i_OldCode;
                        L1564_puc_AppendCharacter[L1560_i_Code] = L1559_i_Character;
                        G668_i_LZW_DictionaryNextAvailableCode = L1560_i_Code + 1;
                }
                L1561_i_OldCode = L1562_i_NewCode;
        }
        return P914_l_OutputAddress - L1567_l_OutputAddress; /* Byte count of decompressed data */
}
