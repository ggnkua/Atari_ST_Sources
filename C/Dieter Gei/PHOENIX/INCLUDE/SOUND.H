/*****************************************************************************/
/*                                                                           */
/* Modul: SOUND.H                                                            */
/* Datum: 05/01/91                                                           */
/*                                                                           */
/*                                                                           */
/* ms: Meinolf Schneider (Module-Holder)                                     */
/*     Copyright (c) DA-Meinolf Schneider 1990                               */
/*     All Rights Reserved.                                                  */
/*                                                                           */
/*****************************************************************************/

#ifndef __SOUND__
#define __SOUND__

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

GLOBAL VOID       Init_PH_Sound               _((VOID));
GLOBAL VOID       Exit_PH_Sound               _((VOID));
GLOBAL VOID CDECL Set_PH_Sound_Volume         _((WORD The_New_Volume));
GLOBAL VOID CDECL Set_Normal_Sample_Frequency _((WORD Sampel_Freq_Hz));
GLOBAL VOID CDECL Play_PH_Sound               _((WORD *PCM_Sound, ULONG PCM_file_length));
GLOBAL VOID CDECL Super_Play_PH_Sound         _((WORD *PCM_Sound, ULONG PCM_file_length));
GLOBAL VOID       Stop_PH_Sound               _((VOID));
GLOBAL BOOLEAN    PH_Sound_Is_Playing         _((VOID));

#endif /* __SOUND__ */

