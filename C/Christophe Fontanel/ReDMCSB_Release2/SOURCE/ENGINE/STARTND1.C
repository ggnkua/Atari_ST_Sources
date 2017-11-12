#include "DEFS.H"

overlay "start"

BOOLEAN F429_xxxx_STARTEND_IsReadSaveHeaderSuccessful(P846_pi_Buffer)
int* P846_pi_Buffer;
{
        register int L1320_i_Counter;
        register int L1321_i_ExpectedChecksum;
        register int L1322_i_Checksum;
        register int* L1323_pi_HeaderData;


        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(L1323_pi_HeaderData = P846_pi_Buffer, 512)) {
                return FALSE;
        }
        L1320_i_Counter = 32;
        L1321_i_ExpectedChecksum = 0;
        /* Compute expected checksum over the first 256 bytes of the header */
        do {
                L1321_i_ExpectedChecksum += *L1323_pi_HeaderData++;
                L1321_i_ExpectedChecksum ^= *L1323_pi_HeaderData++;
                L1321_i_ExpectedChecksum -= *L1323_pi_HeaderData++;
                L1321_i_ExpectedChecksum ^= *L1323_pi_HeaderData++;
        } while (--L1320_i_Counter);
        /* Deobfuscate the last 256 bytes of the header */
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_29_IMPROVEMENT */
        F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(L1323_pi_HeaderData, P846_pi_Buffer[10], 128);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
        F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(L1323_pi_HeaderData, P846_pi_Buffer[29], 128);
#endif
        L1322_i_Checksum = 0;
        L1320_i_Counter = 128;
        do {
                L1322_i_Checksum += *L1323_pi_HeaderData++;
        } while (--L1320_i_Counter);
        return (L1321_i_ExpectedChecksum == L1322_i_Checksum);
}

BOOLEAN F430_xxxx_STARTEND_IsWriteObfuscatedSaveHeaderSuccessful(P847_pi_Buffer)
int* P847_pi_Buffer;
{
        register int L1324_i_Multiple;
#define A1324_i_Counter                     L1324_i_Multiple
#define A1324_B_IsWriteSaveHeaderSuccessful L1324_i_Multiple
        register int L1325_i_LastWord;
        register int L1326_i_Checksum;
        register int* L1327_pi_HeaderData;


        L1326_i_Checksum = 0;
        A1324_i_Counter = 128;
        L1327_pi_HeaderData = P847_pi_Buffer + 128;
        do {
                L1326_i_Checksum += *L1327_pi_HeaderData++;
        } while (--A1324_i_Counter);
        A1324_i_Counter = 32;
        L1325_i_LastWord = 0;
        L1327_pi_HeaderData = P847_pi_Buffer;
        do {
                L1325_i_LastWord += *L1327_pi_HeaderData++ = M06_RANDOM(65536);
                L1325_i_LastWord ^= *L1327_pi_HeaderData++ = M06_RANDOM(65536);
                L1325_i_LastWord -= *L1327_pi_HeaderData++ = M06_RANDOM(65536);
                if (--A1324_i_Counter) {
                        L1325_i_LastWord ^= *L1327_pi_HeaderData++ = M06_RANDOM(65536);
                } else {
                        *L1327_pi_HeaderData++ = L1325_i_LastWord ^ L1326_i_Checksum;
                        break;
                }
        } while ();
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_29_IMPROVEMENT */
        F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(L1327_pi_HeaderData, P847_pi_Buffer[10], 128); /* Obfuscate before writing */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
        F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(L1327_pi_HeaderData, P847_pi_Buffer[29], 128); /* Obfuscate before writing */
#endif
        A1324_B_IsWriteSaveHeaderSuccessful = F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(P847_pi_Buffer, 512);
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_29_IMPROVEMENT */
        F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(L1327_pi_HeaderData, P847_pi_Buffer[10], 128); /* Deobfuscate after writing */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
        F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate(L1327_pi_HeaderData, P847_pi_Buffer[29], 128); /* Deobfuscate after writing */
#endif
        return A1324_B_IsWriteSaveHeaderSuccessful;
}

unsigned int F431_xxxx_STARTEND_GetDarkenedColor(P848_ui_RGBColor)
register unsigned int P848_ui_RGBColor;
{
        if (M07_GET(P848_ui_RGBColor, MASK0x0007_BLUE_COMPONENT)) {
                P848_ui_RGBColor--;
        }
        if (M07_GET(P848_ui_RGBColor, MASK0x0070_GREEN_COMPONENT)) {
                P848_ui_RGBColor -= 16;
        }
        if (M07_GET(P848_ui_RGBColor, MASK0x0700_RED_COMPONENT)) {
                P848_ui_RGBColor -= 256;
        }
        return P848_ui_RGBColor;
}
